#!/bin/bash

bluetooth_addr=$1
outfileprefix=$2

python ../../measurement.py ${bluetooth_addr} 1500 1 > ./measurement_data/${outfileprefix}.csv
sleep 5