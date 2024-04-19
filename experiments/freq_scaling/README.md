# The experiment
- This experiment sets the CPU governor to userspace on the RPi, iterates over the allowed CPU clock frequencies, and measures the power consumption
- The goal is to assess how a varying CPU clock frequency affects the power consumption of the idle state of the RPi.
- As WiFi and Bluetooth, to a certain extent, were found in the device feature experiment to be sources of increased variance in power consumption, there are two versions of the experiment.
- The first version leaves WiFi and Bluetooth enabled and the other version disables them.
- The second version requires that the shell script `idle_freq_no_wifi_bt.sh` is present on the RPi. The file `copy_to_rpi.sh` can be used to set up the experiment.