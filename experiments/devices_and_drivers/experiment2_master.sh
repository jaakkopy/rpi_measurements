#!/bin/bash

# This script assumes that the experiment2.py program has been copied and set up on the RPi

# For calculating the measurement time on the Master
# (the experiment program on the RPi creates timestamps for each phase)
measure_time_wait=1000
cool_off_wait=10
reboot_time=40 # might be higher (or lower) than needed depending on the setup; can be modified without harm based on how safe you want the wait time to be 

user=$1
host=$2
bluetooth_addr=$3
device=$4

phases=9
if [ "$device" = "rpi3" ]; then
    phases=10
fi

measure_time=$(($phases * ($measure_time_wait + $reboot_time + 2 * $cool_off_wait)))

echo "Experiment started. Measuring for $measure_time seconds."
# Reboot the RPi. This should start the experiment via the cron job. Start taking measurements.
ssh ${user}@${host} "sudo reboot"
python ../../measurement.py ${bluetooth_addr} ${measure_time} 1 n > ./measurement_data/$device-experiment2.csv