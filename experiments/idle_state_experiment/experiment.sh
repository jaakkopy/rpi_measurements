#!/bin/bash

bluetooth_addr=$1

for i in {1..30}
do
    python ../../measurement.py ${bluetooth_addr} 30 1 > ./measurement_data/iter${i}.csv
    sleep 5
done