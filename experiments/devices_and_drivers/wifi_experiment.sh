#!/bin/bash

user=$1
host=$2
bluetooth_addr=$3

# Disable WiFi with rfkill (in background to prevent blocking this thread)
ssh ${user}@${host} "sudo rfkill block wifi" &
# Sleep for a bit to make sure the command is completed
sleep 2
# Kill the background process
kill -9 $(ps -aux | grep ssh | grep -v grep | awk '{ print $2 }')

# Start the measurements with the Wifi being blocked
for i in {1..30}
do
    python ../../measurement.py ${bluetooth_addr} 30 1 > ./measurement_data/wifi_iter${i}.csv
    sleep 5
done