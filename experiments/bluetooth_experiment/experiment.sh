#!/bin/bash

bluetooth_addr=$1

# 1s
for i in {1..30}
do
    python ../../measurement.py ${bluetooth_addr} 30 1 > ./measurement_data/1s_30s_i${i}.csv
    sleep 5
done

# 5s
for i in {1..30}
do
    python ../../measurement.py ${bluetooth_addr} 30 5 > ./measurement_data/5s_30s_i${i}.csv
    sleep 5
done

# 10s
for i in {1..30}
do
    python ../../measurement.py ${bluetooth_addr} 30 10 > ./measurement_data/10s_30s_i${i}.csv
    sleep 5
done