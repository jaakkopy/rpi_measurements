#!/bin/bash

bluetooth_addr=$1
user=$2
host=$3
outfileprefix=$4
configfile=/boot/firmware/config.txt

ssh ${user}@${host} "printf 'dtoverlay=disable-wifi\ndtoverlay=disable-bt\n' | sudo tee -a $configfile; sudo systemctl disable bluetooth; sudo reboot"
sleep 120
ssh ${user}@${host} "sudo ifconfig eth0 down" &
sleep 30
python ../../measurement.py ${bluetooth_addr} 800 1 > ./measurement_data/$outfileprefix-wifi-bt-eth.csv