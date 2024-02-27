#!/bin/bash

user=$1
host=$2

# Create a directory for the experiment on the pi and copy the experiment scripts to it
ssh ${user}@${host} "mkdir -p /home/$user/freq_experiment/data"
scp ./task_simulation.py ${user}@${host}:/home/${user}/freq_experiment/
scp ./utilization_monitor.py ${user}@${host}:/home/${user}/freq_experiment/
scp ./start_simulation.sh ${user}@${host}:/home/${user}/freq_experiment/