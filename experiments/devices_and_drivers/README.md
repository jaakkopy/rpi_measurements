# The experiment
- This experiment is designed to evaluate how disabling certain device features affects the power consumption of RPi.
- Unlike the other experiments, Ethernet is assumed to be enabled before beginning (cable + enabled interface).
- The features considered are WiFi, Bluetooth, HDMI, PCIE, UART, disabling CPU cores, USB (RPi 3B+), and Ethernet.
- There are two versions of the experiment:
    1. The first version disables the features in sequence (the same order as listed above). This version can be ran using the file `experiment1.sh`.
    2. The second version first disables all of the considered features and then activates them one by one to allow for assessing how enabling each individual feature affects power consumption. 
- In both experiment versions, measurements are taken of each device state corresponding to enabling/disabling one of the features listed above.
## Modified cmdline.txt
Both versions of the experiment assume that, on the RPi, the directory `/boot/firmware/` contains a file called `cmdline2.txt`. This file should be an exact copy of the original `cmdline.txt` but with one modification: the line `maxcpus=1` should be written after the `console=tty1` option. This file is used to easily turn on and off the cpu option without attempting to modify the contents of the original file.

## Usage of experiment version 2
- Because the second version also disables network features, and certain options used require a reboot, a script running on the RPi is utilized. The `experiment2.py` script should be set up as a cron job on the RPi (instructions are in the file).
- Once the RPi reboots for the first time after the cron job is registered, the sequence of enabling and disabling device features (and rebooting multiple times) begins. To control the timing of when this sequence begins, and to collect measurements while this is taking place, after registering the cron job and before rebooting the RPi, the `experiment2_master.sh` script can be used. This script begins the power consumption measurement program on the Master and reboots the RPi (which begins the experiment procedure).
- The experiment will run until a marker file called `phase_marker` on the RPi indicates that the experiment is over. This file is used to recognize which phase of the experiment should be resumed after the RPi reboots. The `experiment2_master.sh` calculates an estimate of how long the experiment takes and will stop once the time is up.
- Once the experiment is over, the `/root` folder on the RPi (accessible with the root user) contains a file called `phase_times`. This file has timestamps for the beginning and ending times for each of the device states associated with the considered features (WiFi, Bluetooth, etc.). This file is useful during the analysis phase to recognize which power consumption measurements correspond to which device states.

## Starting the experiment
To start experiment version 1, on the Master run:
```
./experiment1.sh <bluetooth address of the measurement device> <username on the RPi> <hostname of the RPi> <device name. Expected to be either "rpi3", "rpi4" or "rpi5">
```

To run experiment version 2, after completing the setup, on the Master run:
```
./experiment2_master.sh <username on RPi> <hostname of the RPi> <measurement device bluetooth address> <device name. Again, either "rpi3", "rpi4" or "rpi5">
```