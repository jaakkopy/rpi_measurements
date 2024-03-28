#!/bin/bash

user=$1
host=$2

scp ./experiment2.py ${user}@${host}:/home/${user}/
# The new version must be copied to the /bin folder where the cron job will find it
ssh ${user}@${host} "sudo cp ./experiment2.py /bin/"