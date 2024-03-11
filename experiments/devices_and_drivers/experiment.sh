#!/bin/bash

bluetooth_addr=$1
user=$2
host=$3
outfileprefix=$4

reboot_wait=120 # Time waited after reboot command to make sure the idle state is stable after booting up
configfile=/boot/firmware/config.txt
measure_time=800
after_command_wait=30
measure_interval=1


measure () {
    python ../../measurement.py ${bluetooth_addr} ${measure_time} ${measure_interval} > ./measurement_data/$outfileprefix-$1.csv
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

echo "cron"
ssh ${user}@${host} "sudo systemctl stop cron; sudo systemctl disable cron"
sleep ${after_command_wait}
measure cron

echo "ModemManager"
ssh ${user}@${host} "sudo systemctl stop ModemManager; sudo systemctl disable ModemManager"
sleep ${after_command_wait}
measure ModemManager

echo "systemd-timesyncd"
ssh ${user}@${host} "sudo systemctl stop systemd-timesyncd; sudo systemctl disable systemd-timesyncd"
sleep ${after_command_wait}
measure systemd-timesyncd

echo "triggerhappy"
ssh ${user}@${host} "sudo systemctl stop triggerhappy; sudo systemctl disable triggerhappy"
sleep ${after_command_wait}
measure triggerhappy

echo "HDMI"
ssh ${user}@${host} "echo 'hdmi=off' | sudo tee -a $configfile > /dev/null; sudo reboot"
sleep ${reboot_wait}
measure hdmi

echo "PCIE"
ssh ${user}@${host} "echo 'pcie=off' | sudo tee -a $configfile > /dev/null; sudo reboot"
sleep ${reboot_wait}
measure pcie

echo "UART"
ssh ${user}@${host} "printf 'uart0=off\nuart1=off\n' | sudo tee -a $configfile > /dev/null; sudo systemctl disable hciuart; sudo reboot"
sleep ${reboot_wait}
measure uart

echo "random"
ssh ${user}@${host} "echo 'random=off' | sudo tee -a $configfile > /dev/null; sudo reboot"
sleep ${reboot_wait}
measure random

echo "1 CPU core"
ssh ${user}@${host} "sudo mv /boot/firmware/cmdline.txt /boot/firmware/cmdline-original.txt; sudo mv /boot/firmware/cmdline2.txt /boot/firmware/cmdline.txt; sudo reboot"
sleep ${reboot_wait}
measure cpu

echo "USB" 
ssh ${user}@${host} "echo '1-1' | sudo tee /sys/bus/usb/drivers/usb/unbind > /dev/null"
sleep ${after_command_wait}
measure usb

echo "Ethernet"
ssh ${user}@${host} "sudo ifconfig eth0 down" &
sleep ${after_command_wait}
measure eth

echo "Done"