#!/bin/bash

bluetooth_addr=$1
user=$2
host=$3

reboot_wait=70 # Time waited after reboot command to make sure the idle state is stable after booting up
configfile=/boot/firmware/config.txt


# Settings:
# 1. Ethernet
# 2. WiFi
# 3. Bluetooth
# 4. HMDI
# 5. PCIE
# 6. USB


echo Start state


# Start state: Basic state without modifications. Ethernet cable should be plugged and WiFi should be enabled.
/bin/bash ./take_measurements.sh ${bluetooth_addr} start


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


echo Disabling PCIE interface 


# Remove the HDMI setting, add setting for PCIE, and reboot
ssh ${user}@${host} "sudo sed -i '$ d' $configfile; echo 'pcie=off' | sudo tee -a $configfile > /dev/null; sudo reboot"
sleep ${reboot_wait}


# PCIE 
/bin/bash ./take_measurements.sh ${bluetooth_addr} no_pcie


# Remove the PCIE setting and reboot
ssh ${user}@${host} "sudo sed -i '$ d' $configfile; sudo reboot"
sleep ${reboot_wait}


echo Disabling USB devices 


# USB devices
ssh ${user}@${host} "for x in $(ls /sys/bus/usb/drivers/usb | grep '[0-9]+-[0-9]+'); do echo '${x}' | sudo tee /sys/bus/usb/drivers/usb/unbind > /dev/null; done"
sleep 10
/bin/bash ./take_measurements.sh ${bluetooth_addr} no_usb


echo Disabling all


# All the previously mentioned settings at once
# WiFi, Bluetooth, HDMI, PCIE
ssh ${user}@${host} "printf 'dtoverlay=disable-wifi\ndtoverlay=disable-bt\nhdmi=off\npcie=off' | sudo tee -a $configfile > /dev/null; sudo reboot"
sleep ${reboot_wait}
# USB
ssh ${user}@${host} "for x in $(ls /sys/bus/usb/drivers/usb | grep '[0-9]+-[0-9]+'); do echo '${x}' | sudo tee /sys/bus/usb/drivers/usb/unbind > /dev/null; done"
# Ethernet
ssh ${user}@${host} "sudo ifconfig eth0 down" &
sleep 10
/bin/bash ./take_measurements.sh ${bluetooth_addr} all