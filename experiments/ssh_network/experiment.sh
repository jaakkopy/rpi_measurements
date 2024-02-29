#!/bin/bash

user=$1
host=$2
bluetooth_addr=$3  # measurement device bluetooth address
interface=$4       # which interface to check (e.g wlan0)

# Experiment phase 1: Print the output and therefore cause additional network traffic over the SSH connection
python ../../measurement.py ${bluetooth_addr} 1500 1 > ./measurement_data/with_print.csv &
# Start the program at the raspberry. Assumed to be stored in /home/<username>/ssh_experiment/experiment_ssh_and_network.py
ssh ${user}@${host} "cd ./ssh_experiment && python experiment_ssh_and_network.py 1500 1 $interface ./data/with_print.csv y"

sleep 30

# Experiment phase 2: Don't print the output. This will not cause additional network traffic over the SSH connection
python ../../measurement.py ${bluetooth_addr} 1500 1 > ./measurement_data/without_print.csv &
# Start the program at the raspberry. Assumed to be stored in /home/<username>/ssh_experiment/experiment_ssh_and_network.py
ssh ${user}@${host} "cd ./ssh_experiment && python experiment_ssh_and_network.py 1500 1 $interface ./data/without_print.csv n"

# Copy the bandwidth data from the Raspberry Pi
scp -rp ${user}@${host}:/home/${user}/ssh_experiment/data/* ./bandwidth_data