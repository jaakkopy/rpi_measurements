#!/bin/bash

bluetooth_addr=$1
user=$2
host=$3

reboot_wait=70 # Time waited after reboot command to make sure the idle state is stable after booting up
configfile=/boot/firmware/config.txt


# Settings:
# USB
# Ethernet
# WiFi
# Bluetooth
# HMDI
# CPU
# All


echo Start state


# Start state: Basic state without modifications. Ethernet cable should be plugged and WiFi should be enabled.
/bin/bash ./take_measurements.sh ${bluetooth_addr} start


echo Disabling USB devices 


# USB controller
ssh ${user}@${host} "echo '1-1' | sudo tee /sys/bus/usb/drivers/usb/unbind > /dev/null"
sleep 10
/bin/bash ./take_measurements.sh ${bluetooth_addr} no_usb
ssh ${user}@${host} "sudo reboot"
sleep ${reboot_wait}


echo Disabling Ethernet


# Ethernet
# Shut down the interface in background to avoid potential hangup
ssh ${user}@${host} "sudo ifconfig eth0 down" &
sleep 10
/bin/bash ./take_measurements.sh ${bluetooth_addr} no_eth


echo Disabling WiFi


# WiFi
# Write to config.txt and reboot
ssh ${user}@${host} "echo 'dtoverlay=disable-wifi' | sudo tee -a $configfile > /dev/null; sudo reboot"
sleep ${reboot_wait}
/bin/bash ./take_measurements.sh ${bluetooth_addr} no_wifi


echo Disabling Bluetooth 


# Remove the WiFi setting, add setting to disable Bluetooth for the next phase, and reboot
ssh ${user}@${host} "sudo sed -i '$ d' $configfile; echo 'dtoverlay=disable-bt' | sudo tee -a $configfile > /dev/null; sudo reboot"
sleep ${reboot_wait}


# Bluetooth
/bin/bash ./take_measurements.sh ${bluetooth_addr} no_bt


echo Disabling HDMI interface 


# Remove the Bluetooth setting, add setting for HDMI, and reboot
ssh ${user}@${host} "sudo sed -i '$ d' $configfile; echo 'hdmi=off' | sudo tee -a $configfile > /dev/null; sudo reboot"
sleep ${reboot_wait}


# HDMI 
/bin/bash ./take_measurements.sh ${bluetooth_addr} no_hdmi


echo Disabling CPUs


# Remove the HDMI setting, add the CPU setting (by replacing cmdline.txt with another file, which has the option set), and reboot
ssh ${user}@${host} "sudo sed -i '$ d' $configfile; sudo mv /boot/firmware/cmdline.txt /boot/firmware/cmdline-original.txt; sudo mv /boot/firmware/cmdline2.txt /boot/firmware/cmdline.txt; sudo reboot"
sleep ${reboot_wait}


# CPU
/bin/bash ./take_measurements.sh ${bluetooth_addr} disabled_cpus


echo Disabling all


# All the previously mentioned settings at once (cpu setting is already on)
# WiFi, Bluetooth, HDMI
ssh ${user}@${host} "printf 'dtoverlay=disable-wifi\ndtoverlay=disable-bt\nhdmi=off' | sudo tee -a $configfile > /dev/null; sudo reboot"
sleep ${reboot_wait}
# USB
ssh ${user}@${host} "echo '1-1' | sudo tee /sys/bus/usb/drivers/usb/unbind > /dev/null"
# Ethernet
ssh ${user}@${host} "sudo ifconfig eth0 down" &
sleep 10
/bin/bash ./take_measurements.sh ${bluetooth_addr} all