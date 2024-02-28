#!/bin/bash

user=$1
host=$2
bluetooth_addr=$3  # measurement device bluetooth address

# How many jobs to simulate
amount_jobs=1000

for x in "conservative" "ondemand" "powersave" "performance"
do
    # Set the governor 
    ssh ${user}@${host} "echo $x | sudo tee /sys/devices/system/cpu/cpufreq/policy0/scaling_governor > /dev/null;"

    # Different sized tasks (times million)
    for size in 2 4 8
    do
        # Time interval between sending tasks (seconds)
        for interval in 1 2 3
        do
            {
                # Start the measurement process in the background. The measurement time is arbitrary since the measurement will be stopped with a signal
                # but it should be at least as long as the time the program will run
                python ../../measurement.py ${bluetooth_addr} $((2 * $interval * $amount_jobs)) 1 > ./measurement_data/$x-$size-$interval.csv &
                measurement_process=$!
                # Start the simulation on the RPi
                ssh ${user}@${host} "cd /home/$user/freq_experiment/ && ./start_simulation.sh $interval $amount_jobs $(($size * 1000000)) ./data/$x-$size-$interval.csv"
                # Stop the measurement process
                kill -INT ${measurement_process}
                # Wait until next round
            } || {
                # If the above fails for any reason (can fail if the bluetooth device is "busy"), write the failed iteration to stderr
                echo "$x-$size-$interval.csv" > /dev/stderr
            }
            sleep 15
        done
    done
done


# Reset the governor to ondemand (default) after the experiment is done
ssh ${user}@${host} "echo ondemand | sudo tee /sys/devices/system/cpu/cpufreq/policy0/scaling_governor > /dev/null;"
# Copy the data from the pi
scp -rp ${user}@${host}:/home/${user}/freq_experiment/data/* ./measurement_data/utilization/