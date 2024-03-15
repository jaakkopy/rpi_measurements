#!/bin/bash

user=$1
host=$2

ssh ${user}@${host} "mkdir -p measurement_data"
scp ./idle_freq_no_wifi_bt.sh ${user}@${host}:/home/${user}/