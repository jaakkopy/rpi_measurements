#!/bin/bash

# This script runs on the RPi
# Sets the governor to userspace and iterates through all the allowed frequencies
# Writes a file with timestamps indicating when a frequency has been changed

outfileprefix=$1
measuretime=$2

# Set the frequency governor to userspace
echo userspace | sudo tee /sys/devices/system/cpu/cpufreq/policy0/scaling_governor > /dev/null
# Get the allowed CPU frequencies for the userspace governor
allowed_frequencies=$(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_available_frequencies)
# Write the amount of frequencies to stdout (to allow the caller to calculate how long the experiment will take)
echo ${allowed_frequencies} | wc -w

# Disable WiFi and Bluetooth to prevent high variance in measurement values
sudo rfkill block wifi
sudo rfkill block bluetooth

chtf="./measurement_data/$outfileprefix-changetimes.csv"

echo "time_s,frequency" >> ${chtf}
for x in ${allowed_frequencies}
do
    # Set the frequency
    echo ${x} | sudo tee /sys/devices/system/cpu/cpufreq/policy0/scaling_setspeed
    # Mark the time of the change and the selected frequency
    echo "$(date +%s),$x" >> ${chtf}
    # Wait
    sleep ${measuretime}
done

# Marker with NA to symbolize that the experiment is over
echo "$(date +%s),NA" >> ${chtf}

# Reset the governor to ondemand (default) after the experiment is done
echo ondemand | sudo tee /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
# Bring wifi and bt back up
sudo rfkill unblock wifi
sudo rfkill unblock bluetooth