#!/bin/bash

user=$1
host=$2
bluetooth_addr=$3
master_host=$4
master_port=$5

mkdir -p ./measurement_data

amount_transmissions=200

for payload_size in 200 400 600 800 1000 1200 1400
do
    for wait_time in 2 4 8 10 12 14 16
    do
        measuretime=$(($wait_time * $amount_transmissions))
        python server_on_master.py $((measuretime + 5)) $master_host $master_port $payload_size &
        id=$!
        ssh ${user}@${host} "python transmit.py $payload_size $wait_time $amount_transmissions $master_host $master_port" &
        python ../../measurement.py ${bluetooth_addr} ${measuretime} 2 n > ./measurement_data/p$payload_size-w$wait_time.csv
        kill -INT $id
        sleep 10
    done
done