#!/bin/bash

bluetooth_addr=$1
user=$2
host=$3

reboot_wait=70 # Time waited after reboot command to make sure the idle state is stable after booting up

# Approximate run time (minimum): 2h 15min

# Reboot for clean slate
ssh ${user}@${host} "sudo reboot"
sleep ${reboot_wait}

# Start state: Basic state without modifications. Ethernet cable should be plugged and WiFi should be enabled.
/bin/bash ./take_measurements.sh ${bluetooth_addr} start

# Ethernet
# Shut down the interface in background to avoid potential hangup
ssh ${user}@${host} "sudo ifconfig eth0 down" &
sleep 10
/bin/bash ./take_measurements.sh ${bluetooth_addr} no_eth

# WiFi
# Write to config.txt and reboot
ssh ${user}@${host} "echo 'dtoverlay=disable-wifi' | sudo tee -a /boot/config.txt > /dev/null; sudo reboot"
sleep ${reboot_wait}
/bin/bash ./take_measurements.sh ${bluetooth_addr} no_wifi

# Remove the WiFi setting, add setting to disable Bluetooth for the next phase, and reboot
ssh ${user}@${host} "sudo sed -i '$ d' /boot/config.txt; echo 'dtoverlay=disable-bt' | sudo tee -a /boot/config.txt > /dev/null; sudo reboot"
sleep ${reboot_wait}

# Bluetooth
/bin/bash ./take_measurements.sh ${bluetooth_addr} no_bt
# Remove the Bluetooth setting and reboot
ssh ${user}@${host} "sudo sed -i '$ d' /boot/config.txt; sudo reboot"
sleep ${reboot_wait}

# USB devices
ssh ${user}@${host} "for x in $(ls /sys/bus/usb/drivers/usb | grep '[0-9]+-[0-9]+'); do echo '${x}' | sudo tee /sys/bus/usb/drivers/usb/unbind > /dev/null; done"
sleep 5
/bin/bash ./take_measurements.sh ${bluetooth_addr} no_usb