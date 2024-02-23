#!/bin/bash

user=$1
host=$2
bluetooth_addr=$3

# Disable the USB devices
ssh ${user}@${host} "for x in $(ls /sys/bus/usb/drivers/usb | grep '[0-9]+-[0-9]+'); do echo '${x}' | sudo tee /sys/bus/usb/drivers/usb/unbind; done"
# Sleep for a bit to make sure the command takes effect
sleep 2

/bin/bash ./take_measurements.sh ${bluetooth_addr} measurement_data usb_iter