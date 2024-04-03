#!/bin/bash

user=$1
host=$2
bluetooth_addr=$3
outfileprefix=$4
measuretime=800

# Starts a script RPi and begins collecting measurements
# The script makes the pi iterate over the allowed frequencies of the userspace governor and wait for the given time between each frequency change

# Will hang due to closing WiFi so run in background
ssh ${user}@${host} "./idle_freq_no_wifi_bt.sh $outfileprefix $measuretime" > amount_frequencies &
# Wait a bit to make sure the RPi has written the amount of frequencies to stdout
sleep 3
# Read the amount of frequencies to calculate the experiment time
x=$(cat amount_frequencies)

python ../../measurement.py ${bluetooth_addr} $((${x} * ${measuretime})) 1 n > ./measurement_data/$outfileprefix-freq.csv
rm amount_frequencies