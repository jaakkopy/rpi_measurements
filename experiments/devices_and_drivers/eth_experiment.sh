#!/bin/bash

user=$1
host=$2
bluetooth_addr=$3

# Disable WiFi with rfkill (while Ethernet is active)
ssh ${user}@${host} "sudo rfkill block wifi"
# Sleep for a bit to make sure the command is completed
sleep 2

# Collect the samples 
for i in {1..50}
do
    python ../../measurement.py ${bluetooth_addr} 30 1 > ./measurement_data/eth_iter${i}.csv
    sleep 5
done