# About
Experiments for measuring the energy consumption of a Raspberry Pi device.

# Experiments
The `experiments` folder contains the code for all of the experiments. There are also  R scripts for analysis and generating plots from the data.

# measurement.py
- Reads measurement values from a RuiDeng UM25C measurement device and writes them to stdout in CSV format.

To run and redirect the output to a file:
```
python measurement.py a l t > out.csv
```
where:
- a = The bluetooth address of your UM25C device. The address can be found with bluetoothctl, for example.
- l = Measurement time target (not absolute). 
- t = Wait time between polling in seconds

`ceil(l/t)` measurements will be taken with wait times `t` between each one. NOTE: The total measurement time is likely higher than `l` due to delays involved. If exact times are required, the program is easily modifiable.

## References
- https://sigrok.org/wiki/RDTech_UM_series. For figuring out the UM25C device protocol. The site documents the response format if you wish to extend the program to read other measurements or modify it for other UMxx measurement devices.


# Experiment scripts
- Bash and Python scripts for performing the experiments
- Most of the experiments assume that there is an SSH key generated such that the user does not have to keep typing their password if SSH usage is required during the experiment


# The R scripts
- Not meant to be ran as a script from the command line, but rather used in the interactive mode to run commands recorded in the R file.
- These files only record the R instructions that I used for my specific use case