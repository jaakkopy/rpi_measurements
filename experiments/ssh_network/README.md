# The experiment
- This experiment (`experiment.sh`) evaluates how network traffic via SSH affects the power consumption of RPi.
- The experiment starts the program `experiment_ssh_and_network.py` on the RPi and simultaneously starts the measurement collection program on the Master node to collect power consumption measurements from the UM25C.
    - The setup on the RPi can be conducted with the script `setup_for_experiment.sh`, which creates some directories on the RPi and copies the program to the it.
- The program on the RPi is instructed to either write or not write messages (determined by an argument given to the program) via SSH. When the program is started, a waiting time between sending (or not sending) messages is also given.
- When writing messages, by varying the time between sending messages, the effect of varying transmission bandwidth (from the RPi to the Master node) via SSH can be assessed.
- By not writing messages, a baseline for comparison is achieved for each wait time between sending messages.
- The program on the RPi measures the transmission bandwidth over a speficied network interface. After the experiment is completed, the data is copied from the RPi to the Master node to a directory called `bandwidth_data`

## Starting the experiment
After setting up the experiment, on the Master node run:
```
./experiment.sh <username on the RPi> <hostname on the RPi> <bluetooth address of the measurement device> <network interface to monitor on the RPi, e.g. wlan0 or eth0> <prefix to add to the filenames, e.g. "rpi3" or "rpi4">
```
- The file prefix is used to prevent overwriting previous csv files containing measurement data