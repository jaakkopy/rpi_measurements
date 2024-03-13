#!/bin/bash

user=$1
host=$2

ssh ${user}@${host} "sudo systemctl enable hciuart"
ssh ${user}@${host} "sudo systemctl enable bluetooth"
ssh ${user}@${host} "sudo mv /boot/firmware/cmdline.txt /boot/firmware/cmdline2.txt; sudo mv /boot/firmware/cmdline-original.txt /boot/firmware/cmdline.txt"
ssh ${user}@${host} "head -n -7 /boot/firmware/config.txt > temp && sudo mv temp /boot/firmware/config.txt && sudo reboot"