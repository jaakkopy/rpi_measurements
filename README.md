# About
Experiments for measuring the energy consumption of a Raspberry Pi device.

# Experiments
The `experiments` folder contains the code for all of the experiments. There are also  R scripts for analysis generating plots from the data.

# measurement.py
- Reads measurement values from a RuiDeng UM25C measurement device and writes them to stdout in CSV format.

To run and redirect the output to a file:
```
python measurement.py a l t > out.csv
```
where:
- a = The bluetooth address of your UM25C device. The address can be found with bluetoothctl, for example.
- l = total measurement time limit in seconds. For example 10.23 for 10.23 seconds.
- t = Wait time between polling in seconds

## References
- https://sigrok.org/wiki/RDTech_UM_series. For figuring out the UM25C device protocol. The site documents the response format if you wish to extend the program to read other measurements or modify it for other UMxx measurement devices.