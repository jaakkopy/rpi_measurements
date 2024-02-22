#!/bin/bash

user=$1
host=$2
bluetooth_addr=$3

# Disable the USB devices
ssh ${user}@${host} "for x in $(ls /sys/bus/usb/drivers/usb | grep '[0-9]+-[0-9]+'); do echo '${x}' | sudo tee /sys/bus/usb/drivers/usb/unbind; done"
# Sleep for a bit to make sure the command takes effect
sleep 2

# Collect the samples 
for i in {1..50}
do
    python ../../measurement.py ${bluetooth_addr} 30 1 > ./measurement_data/usb_iter${i}.csv
    sleep 5
done