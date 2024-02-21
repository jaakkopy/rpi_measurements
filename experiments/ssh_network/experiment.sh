#!/bin/bash

user=$1
host=$2
bluetooth_addr=$3  # measurement device bluetooth address
interface=$4       # which interface to check (e.g wlan0)

# Experiment phase 1: Print the output and therefore cause additional network traffic over the SSH connection
for i in {1..50}
do
    /bin/bash ./measure.sh $user $host $bluetooth_addr 30 1 $interface phase1_$i.csv y
    sleep 10
done

# Experiment phase 2: Don't print the output. This will not cause additional network traffic over the SSH connection
for i in {1..50}
do
    /bin/bash ./measure.sh $user $host $bluetooth_addr 30 1 $interface phase2_$i.csv n
    sleep 10
done

# Copy the data from the Raspberry Pi
scp -rp ${user}@${host}:/home/${user}/ssh_experiment/data ./bandwidth_data