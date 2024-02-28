#!/bin/bash

bluetooth_addr=$1


for poll_time in 1 5 10 15
do
    python ../../measurement.py ${bluetooth_addr} 1500 ${poll_time} > ./measurement_data/${poll_time}s.csv
    sleep 5
done