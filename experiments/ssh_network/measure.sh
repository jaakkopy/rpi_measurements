#!/bin/bash

user=$1
host=$2
bluetooth_addr=$3  # measurement device bluetooth address
loop_time=$4       # how many seconds to loop for
check_interval=$5  # how often to check the interface
interface=$6       # which interface to check (e.g wlan0)
outfile=$7         # where to write output
should_print=$8    # write to stdout?

# Start the measurement program in the background.
python ../../measurement.py ${bluetooth_addr} ${loop_time} ${check_interval} > ./measurement_data/${outfile} &
# Start the program at the raspberry. Assumed to be stored in /home/<username>/ssh_experiment/experiment_ssh_and_network.py
ssh ${user}@${host} "cd ./ssh_experiment && python experiment_ssh_and_network.py $loop_time $check_interval $interface ./data/$outfile $should_print"