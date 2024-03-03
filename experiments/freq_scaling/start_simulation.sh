#!/bin/bash

interval=$1
amount_jobs=$2
counter=$3
outputfile=$4

# Start the utilization monitor in the background on cpu 1 and make it monitor cpu 0
taskset --cpu-list 1 python ./utilization_monitor.py cpu0 1 ${outputfile} &

monitor_program_id=$!

# Start the task processing simulation on cpu 0
taskset --cpu-list 0 python ./task_simulation.py ${counter} ${interval} ${amount_jobs}

# Stop the monitor
kill -USR1 ${monitor_program_id}