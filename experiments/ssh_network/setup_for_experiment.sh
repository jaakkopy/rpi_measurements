#!/bin/bash

user=$1
host=$2

# Create a directory for the experiment on the pi and copy the experiment program to it
ssh ${user}@${host} "mkdir -p /home/${user}/ssh_experiment/data"
scp ./experiment_ssh_and_network.py ${user}@${host}:/home/${user}/ssh_experiment/