#!/bin/bash

user=$1
host=$2
bluetooth_addr=$3
payload_size=$4
wait_time=$5
amount_transmissions=$6
master_host=$7
master_port=$8

mkdir -p ./measurement_data

measuretime=$(($wait_time * $amount_transmissions))
# 5 seconds of extra for slight delay
python server_on_master.py $((measuretime + 5)) $master_host $master_port
ssh ${user}@${host} "python transmit.py $payload_size $wait_time $amount_transmissions $master_host $master_port"
python ../../measurement.py ${bluetooth_addr} ${measuretime} 1 n > ./measurement_data/p$payload_size-w$wait_time.csv