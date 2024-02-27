#!/bin/bash

user=$1
host=$2
bluetooth_addr=$3  # measurement device bluetooth address

# Set the frequency governor to userspace
ssh ${user}@${host} "echo userspace | sudo tee /sys/devices/system/cpu/cpufreq/policy0/scaling_governor > /dev/null;"

# Get the allowed CPU frequencies for the userspace governor
allowed_frequencies=$(ssh ${user}@${host} "cat /sys/devices/system/cpu/cpufreq/policy0/scaling_available_frequencies")

for x in ${allowed_frequencies}
do
    # Set the frequency
    ssh ${user}@${host} "echo $x | sudo tee /sys/devices/system/cpu/cpufreq/policy0/scaling_setspeed > /dev/null;"
    # Collect samples
    for i in {1..50}
    do
        python ../../measurement.py ${bluetooth_addr} 30 1 > ./measurement_data/idle-freq-$x-iter-$i.csv
        sleep 10
    done
done

# Reset the governor to ondemand (default) after the experiment is done
ssh ${user}@${host} "echo ondemand | sudo tee /sys/devices/system/cpu/cpufreq/policy0/scaling_governor > /dev/null;"