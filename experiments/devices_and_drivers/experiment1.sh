#!/bin/bash

bluetooth_addr=$1
user=$2
host=$3
device=$4 # should be rpi3, rpi4 or rpi5 (used to check a condition)

reboot_wait=120 # Time waited after reboot command to make sure the idle state is stable after booting up
configfile=/boot/firmware/config.txt
measure_time=800
after_command_wait=30
measure_interval=1


measure () {
    python ../../measurement.py ${bluetooth_addr} ${measure_time} ${measure_interval} > ./measurement_data/$device-$1.csv
}

echo "Start"
measure start

# WiFi first due to causing high variance in power
echo "WiFi"
ssh ${user}@${host} "echo 'dtoverlay=disable-wifi' | sudo tee -a $configfile > /dev/null; sudo reboot"
sleep ${reboot_wait}
measure wifi 

echo "Bluetooth"
ssh ${user}@${host} "echo 'dtoverlay=disable-bt' | sudo tee -a $configfile > /dev/null; sudo systemctl disable bluetooth; sudo reboot"
sleep ${reboot_wait}
measure bt

echo "HDMI"
ssh ${user}@${host} "echo 'dtparam=hdmi=off' | sudo tee -a $configfile > /dev/null; sudo reboot"
sleep ${reboot_wait}
measure hdmi

echo "PCIE"
ssh ${user}@${host} "echo 'dtparam=pcie=off' | sudo tee -a $configfile > /dev/null; sudo reboot"
sleep ${reboot_wait}
measure pcie

echo "UART"
ssh ${user}@${host} "sudo systemctl disable hciuart; sudo reboot"
sleep ${reboot_wait}
measure uart

echo "1 CPU core"
# cmdline2.txt is a copy of the original cmdline.txt with the line maxcpus=1 set.
ssh ${user}@${host} "sudo mv /boot/firmware/cmdline.txt /boot/firmware/cmdline-original.txt; sudo mv /boot/firmware/cmdline2.txt /boot/firmware/cmdline.txt; sudo reboot"
sleep ${reboot_wait}
measure cpu

# NOTE: Only works on RPi 3 and 4
if [ "$device" = "rpi3" ] || [ "$device" = "rpi4" ]; then
    echo "USB" 
    ssh ${user}@${host} "echo '1-1' | sudo tee /sys/bus/usb/drivers/usb/unbind > /dev/null" &
    sleep ${after_command_wait}
    measure usb
fi

# The pi 3 has a shared bus with USB and Ethernet, so the above step is enough for the pi 3
if [ "$device" != "rpi3" ]; then
    echo "Ethernet"
    ssh ${user}@${host} "sudo ifconfig eth0 down" &
    sleep ${after_command_wait}
    measure eth
fi

echo "Done"