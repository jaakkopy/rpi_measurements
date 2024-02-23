#!/bin/bash

bluetooth_addr=$1
outfileprefix=$2

for i in {1..50}
do
    python ../../measurement.py ${bluetooth_addr} 30 1 > ./measurement_data/${outfileprefix}${i}.csv
    sleep 5
done