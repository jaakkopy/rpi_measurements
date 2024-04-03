# About
Experiments for measuring the energy consumption of a Raspberry Pi device.

# Experiments
The `experiments` folder contains the code for all of the experiments. There are also  R scripts for analysis and generating plots from the data.

# measurement.py
- Reads measurement values from a RuiDeng UM25C measurement device and writes them to stdout in CSV format.

To run and redirect the output to a file:
```
python measurement.py a l t e > out.csv
```
where:
- `a` = The bluetooth address of your UM25C device. The address can be found with bluetoothctl, for example.
- `l` = Measurement time. 
- `t` = Wait time target between polling in seconds (time between measurements can vary due to delays/errors in response)
- `e` = "y" or "n". If `e` = "y", exactly `ceil(l/t)` measurements will be collected. If `e` = "n", the measurement process will be stopped when `l` seconds have passed even if less than `ceil(l/t)` measurements have been collected.

With ctrl + C the measurement program can be stopped without issue before the time is up.

## References
- https://sigrok.org/wiki/RDTech_UM_series. For figuring out the UM25C device protocol. The site documents the response format if you wish to extend the program to read other measurements or modify it for other UMxx measurement devices.


# Experiment scripts
- Bash and Python scripts for performing the experiments
- Most of the experiments assume that there is an SSH key generated such that the user does not have to keep typing their password if SSH usage is required during the experiment


# The R scripts
- Not meant to be ran as a script from the command line, but rather used in the interactive mode to run commands recorded in the R file.
- These files only record the R instructions that I used for my specific use case