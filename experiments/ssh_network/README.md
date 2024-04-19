# The experiment
- This experiment (`experiment.sh`) evaluates how network traffic via SSH affects the power consumption of RPi.
- The experiment starts the program `experiment_ssh_and_network.py` on the RPi and simultaneously starts the measurement collection program on the Master node to collect power consumption measurements from the UM25C.
- The program on the RPi is instructed to either write or not write messages (determined by an argument given to the program) via SSH. When the program is started, a waiting time between sending (or not sending) messages is also given.
- When writing messages, by varying the time between sending messages, the effect of varying transmission bandwidth (from the RPi to the Master node) via SSH can be assessed.
- By not writing messages, a baseline for comparison is achieved for each wait time between sending messages.
- The program on the RPi measures the transmission bandwidth over a speficied network interface. After the experiment is completed, the data is copied from the RPi to the Master node.