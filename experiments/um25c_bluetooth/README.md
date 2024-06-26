# The experiment
- This experiment is designed to evaluate if the use of Bluetooth to fetch measurements from the UM25C measurement device has an effect on the accumulated energy consumption as reported by the meter.
- To that end, first the experiment disables WiFi and Bluetooth on the RPi via SSH to minimize the variance in power consumption.
- After that, using the poll wait times of 1 s, 5 s, 10 s, and 15 s, 250 observations of accumulated energy from 30 second time periods are collected from the UM25C. That is, measurements are collected every t seconds, for 30 seconds, 250 times, where t=1,5,10,15.
- By varying the poll time, it could be that the accumulated energy from the 30s periods differ.
- Because t varies but the time period remains 30 seconds, there are less values in between the first and the last value when t increases. This is not an issue as the experiment is interested in the total accumulated energy (accumulation of consumed energy between the first and the last reading). The meter calculates the energy accumulation even if it's not being polled.

## Starting the experiment
On the Master node run:
```
./experiment.sh <bluetooth address of the measurement device> <username on the RPi> <hostname of the RPi>
```