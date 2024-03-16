#!/bin/bash

# This script assumes that the experiment2.py program has been copied and set up on the RPi

# For calculating the measurement time on the Master
# (the experiment program on the RPi creates timestamps for each phase)
measure_time_wait=1000
cool_off_wait=10
reboot_time=30 # might be higher than needed; can be modified based on how safe you want to play

user=$1
host=$2
bluetooth_addr=$3
device=$4

phases=9
if [ "$device" = "rpi3" ]; then
    phases=10
fi

measure_time=$(($phases * ($measure_time_wait + $reboot_time) + ($phases - 1) * $cool_off_wait + $reboot_time))

echo "Measuring for $measure_time seconds"
# Reboot the RPi. This should start the experiment. Start taking measurements.
ssh ${user}@${host} "sudo reboot"
python ../../measurement.py ${bluetooth_addr} ${measure_time} 1 > ./measurement_data/$device-experiment2.csv