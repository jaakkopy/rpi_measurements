#!/bin/bash

user=$1
host=$2
bluetooth_addr=$3  # measurement device bluetooth address
interface=$4       # which interface to check (e.g wlan0)
fileprefix=$5

# Make sure the necessary directories exist
mkdir -p ./measurement_data
mkdir -p ./bandwidth_data

measuretime=1500

for poll_wait in 1 5 10 15
do
    # Experiment phase 1: Print the output and therefore cause additional network traffic over the SSH connection
    python ../../measurement.py ${bluetooth_addr} ${measuretime} 1 n > ./measurement_data/$fileprefix-$poll_wait-with_print.csv &
    # Start the program at the raspberry. Assumed to be stored in /home/<username>/ssh_experiment/experiment_ssh_and_network.py
    ssh ${user}@${host} "cd ./ssh_experiment && python experiment_ssh_and_network.py $measuretime $poll_wait $interface ./data/$fileprefix-$poll_wait-with_print.csv y"
    sleep 15

    # Experiment phase 2: Don't print the output. This will not cause additional network traffic over the SSH connection
    python ../../measurement.py ${bluetooth_addr} ${measuretime} 1 n > ./measurement_data/$fileprefix-$poll_wait-without_print.csv &
    ssh ${user}@${host} "cd ./ssh_experiment && python experiment_ssh_and_network.py $measuretime $poll_wait $interface ./data/$fileprefix-$poll_wait-without_print.csv n"
    sleep 15
done

# Copy the bandwidth data from the Raspberry Pi
scp -rp ${user}@${host}:/home/${user}/ssh_experiment/data/* ./bandwidth_data