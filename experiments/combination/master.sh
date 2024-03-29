#!/bin/bash

user=$1
host=$2
bluetooth_addr=$3
fileprefix=$4

ssh ${user}@${host} "sudo reboot"
python ../../measurement.py ${bluetooth_addr} 1600 1 > ./measurement_data/$fileprefix-combo.csv