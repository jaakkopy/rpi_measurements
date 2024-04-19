#!/bin/bash

bluetooth_addr=$1
user=$2
host=$3

mkdir -p ./measurement_data

# To minimize variance in power consumption measurements, stop wifi and bluetooth
# The process will block due to no response
ssh ${user}@${host} "sudo rfkill block bluetooth && sudo rfkill block wifi" &
id=$!
sleep 3
kill -INT $id

for poll_time in 1 5 10 15
do
    for i in {1..250}
    do
        python ../../measurement.py ${bluetooth_addr} 30 ${poll_time} y > ./measurement_data/testi${poll_time}s_i${i}.csv
        sleep 15
    done
done