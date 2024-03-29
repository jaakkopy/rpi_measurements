#!/bin/bash

# An experiment combining some of the features which were found to be useful for reducing power consumption in previous experiments
# This should be registered as a cron job due to requiring a reboot

model3="Raspberry Pi 3 Model B Plus Rev 1.3"
model4="Raspberry Pi 4 Model B Rev 1.5"
model5="Raspberry Pi 5 Model B Rev 1.0"
current_model=$(cat "/proc/device-tree/model")

if test -f "marker"; then
    if [ $(cat "marker") = "0" ]; then
        # USB
        if [ "$current_model" = "$model3" ]; then
            echo '1-1' | sudo tee /sys/bus/usb/drivers/usb/unbind
        fi
        # CPU
        echo userspace | sudo tee /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
        f="600000"
        if [ "$current_model" = "$model5" ]; then
            f="1500000"
        fi
        echo "$f" | sudo tee /sys/devices/system/cpu/cpufreq/policy0/scaling_setspeed

        sleep 30

        echo time_s > time_marks
        echo "$(date +%s)" >> time_marks
        sleep 1500 # wait for measurement taking
        echo "$(date +%s)" >> time_marks

        echo "1" > marker
        # set back to ondemand
        echo ondemand | sudo tee /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
        # remove the options
        options=4
        if [ "$current_model" = "$model5" ]; then
            options=2
        fi
        for ((i=1;i<=$options;i++)); do
            sudo sed -i '$ d' /boot/firmware/config.txt
        done
        # enable the services
        sudo systemctl enable bluetooth
        if [ "$current_model" != "$model5" ]; then
            sudo systemctl enable hciuart
        fi
        # reboot to take effect
        sudo reboot
    fi
else
    # WiFi, Bluetooth, HDMI, PCIE, UART
    if [ "$current_model" = "$model5" ]; then
        printf "dtoverlay=disable-wifi\ndtoverlay=disable-bt" | sudo tee -a /boot/firmware/config.txt
    else
        printf "dtoverlay=disable-wifi\ndtoverlay=disable-bt\ndtparam=hdmi=off\ndtparam=pcie=off" | sudo tee -a /boot/firmware/config.txt
        sudo systemctl disable hciuart
    fi
    sudo systemctl disable bluetooth
    # mark that this phase is completed
    echo "0" > marker
    # reboot to take effect
    sudo reboot
fi