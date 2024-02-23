#!/bin/bash

bluetooth_addr=$1


for poll_time in 1 5 10 15
do
    for i in {1..50}
    do
        python ../../measurement.py ${bluetooth_addr} 30 ${poll_time} > ./measurement_data/${poll_time}s_30s_i${i}.csv
        sleep 5
    done
done