from time import sleep, time
from os import path, system

'''
This version of the experiment first disables all the considered features
and then one by one activates them individually (one feature active, rest disabled)
due to some (most) of the features requiring a reboot to take effect,
the script writes a marker file to indicate which phase of the experiment should be
done

This script should be registered as a cron job to run on reboot
1. copy this program to /bin
2. run sudo crontab -u root -e (this script requires root privileges)
3. Add to the bottom: @reboot python /bin/this_script.py &

The script runs in root mode and writes the results to the /root directory

ASSUMED INITIAL config.txt OPTIONS:

auto_initramfs=1
disable_fw_kms_setup=1
arm_64bit=1
arm_boost=1

This script appends options under the [all] tag, which is assumed to exist at the bottom of the config file.
'''

MEASURE_TIME_WAIT = 1000 # how many seconds to wait in each phase to allow the measurements to be taken
PHASE_MARKER_FILE = "phase_marker" # marks the phase name (needed due to reboots)
TIMESTAMP_FILE = "phase_times" # marks the times on which each phase has started and ended
CONFIG_FILE = "/boot/firmware/config.txt"
RPI3_MODEL = "Raspberry Pi 3 Model B Plus Rev 1.3"
ETH_INTERFACE = "eth0"
COOL_OFF_WAIT = 10

def run_shell_command(cmd):
    system(cmd)

def reboot():
    run_shell_command("sudo reboot")

def get_model():
    with open('/proc/device-tree/model') as f:
        return f.read()[0:-1]

def disable_usb_and_ethernet():
    # This USB option only works on RPi 3B+. On the 3B+ model, this also disables Ethernet
    if get_model() == RPI3_MODEL:
        run_shell_command("echo '1-1' | sudo tee /sys/bus/usb/drivers/usb/unbind")
    run_shell_command(f"ifconfig {ETH_INTERFACE} down")

def add_time_phase_entry(timestamp, entry):
    with open(TIMESTAMP_FILE, "a") as f:
        f.write(f"{timestamp},{entry}\n")

def write_phase_name(phase):
    with open(PHASE_MARKER_FILE, "w") as f:
        return f.write(phase)

def pop_config():
    run_shell_command(f'sed -i "$ d" {CONFIG_FILE}')

def push_config(config):
    with open(CONFIG_FILE, "a") as f:
        f.write(f"{config}\n")

def wait_measurement_time(phase_name):
    add_time_phase_entry(time(), phase_name) # start time marker
    sleep(MEASURE_TIME_WAIT)
    add_time_phase_entry(time(), phase_name) # end time marker

# Init phase. First wait for the given time to allow for taking measurements of the unmodified state
# After, set the persistent changes and reboot.
# NOTE: USB and Ethernet must be disabled separately on each phase due to no config options for them (to my knowledge)
def init():
    # Header.
    with open(TIMESTAMP_FILE, "w") as f:
        f.write("time_s, phase\n")
    wait_measurement_time("start")
    # config options: WiFi, Bluetooth, HDMI, PCIE
    with open(CONFIG_FILE, "a") as f:
        f.write("dtoverlay=disable-wifi\n")
        f.write("dtoverlay=disable-bt\n")
        f.write("dtparam=hdmi=off\n")
        f.write("dtparam=pcie=off\n")
    # service options: bluetooth.service and hciuart.service
    run_shell_command("sudo systemctl disable bluetooth && sudo systemctl disable hciuart")
    # Disable CPU cores
    # cmdline2.txt is an exact copy of the cmdline.txt, but with the added parameter maxcpus=1
    run_shell_command("sudo mv /boot/firmware/cmdline.txt /boot/firmware/cmdline-original.txt; sudo mv /boot/firmware/cmdline2.txt /boot/firmware/cmdline.txt")
    # mark the next phase and reboot
    write_phase_name("all")
    reboot()

# Phase 1: Everything disabled 
# config stack: wifi, bt, hdmi, pcie
def all_disabled():
    disable_usb_and_ethernet()
    sleep(COOL_OFF_WAIT)
    wait_measurement_time("all")
    # Next phase: restored CPU cores.
    run_shell_command("sudo mv /boot/firmware/cmdline.txt /boot/firmware/cmdline2.txt; sudo mv /boot/firmware/cmdline-original.txt /boot/firmware/cmdline.txt")
    write_phase_name("cpu")
    reboot()

# Phase 2: CPU cores back
# config stack: wifi, bt, hdmi, pcie
def cpu_cores():
    disable_usb_and_ethernet()
    sleep(COOL_OFF_WAIT)
    wait_measurement_time("cpu")
    # Disable again for the next phase
    run_shell_command("sudo mv /boot/firmware/cmdline.txt /boot/firmware/cmdline-original.txt; sudo mv /boot/firmware/cmdline2.txt /boot/firmware/cmdline.txt")
    # Next phase: Restore hciuart
    run_shell_command("sudo systemctl enable hciuart")
    write_phase_name("uart")
    reboot()

# Phase 3: UART enabled
# config stack: wifi, bt, hdmi, pcie
def uart():
    disable_usb_and_ethernet()
    sleep(COOL_OFF_WAIT)
    wait_measurement_time("uart")
    # Disable uart again
    run_shell_command("sudo systemctl disable hciuart")
    # Next phase: PCIE enabled (delete the pcie entry)
    pop_config()
    write_phase_name("pcie")
    reboot()

# Phase 4: PCIE enabled
# config stack: wifi, bt, hdmi
def pcie():
    disable_usb_and_ethernet()
    sleep(COOL_OFF_WAIT)
    wait_measurement_time("pcie")
    # For the next phase: enable HDMI again (delete the hdmi entry), disable PCIE again
    pop_config()
    push_config("dtparam=pcie=off")
    write_phase_name("hdmi")
    reboot()

# Phase 5: HDMI enabled
# config stack: wifi, bt, pcie
def hdmi():
    disable_usb_and_ethernet()
    sleep(COOL_OFF_WAIT)
    wait_measurement_time("hdmi")
    # For the next phase: enable Bluetooth again, disable hdmi again
    pop_config() # pop pcie
    pop_config() # pop bluetooth
    push_config("dtparam=pcie=off") # push pcie
    push_config("dtparam=hdmi=off") # push hdmi 
    run_shell_command("sudo systemctl enable bluetooth")
    write_phase_name("bt")
    reboot()

# Phase 6: Bluetooth enabled
# config stack: wifi, pcie, hdmi 
def bt():
    disable_usb_and_ethernet()
    sleep(COOL_OFF_WAIT)
    wait_measurement_time("bt")
    # For the next phase: enable wifi again, disable bluetooth again
    pop_config() # pop hdmi
    pop_config() # pop pcie 
    pop_config() # pop wifi 
    push_config("dtparam=pcie=off") # push pcie
    push_config("dtparam=hdmi=off") # push hdmi 
    push_config("dtoverlay=disable-bt") # push bluetooth 
    run_shell_command("sudo systemctl disable bluetooth")
    write_phase_name("wifi")
    reboot()

# Phase 7: WiFi enabled
# config stack: pcie, hdmi, bt
def wifi():
    disable_usb_and_ethernet()
    sleep(COOL_OFF_WAIT)
    wait_measurement_time("wifi")
    # For the next phase: disable wifi again
    push_config("dtoverlay=disable-wifi")
    write_phase_name("eth")
    reboot()

# Phase 8: Ethernet enabled
# config stack: pcie, hdmi, bt, wifi
def eth():
    # This time disable only USB (leave the Ethernet interface enabled unlike previously)
    # (only for RPi 3B+)
    if get_model() == RPI3_MODEL:
        run_shell_command("echo '1-1' | sudo tee /sys/bus/usb/drivers/usb/unbind")
        sleep(COOL_OFF_WAIT)
    wait_measurement_time("eth")
    # if the device is RPi 3B+, the last phase will disable just the USB.
    # Does not work on RPi 4B and 5 so they are done
    if get_model() == RPI3_MODEL:
        write_phase_name("usb")
    else:
        write_phase_name("done")
    reboot()

# Phase 9: USB enabled. Only for RPi 3B+
# config stack: pcie, hdmi, bt, wifi
def usb():
    # This time disable only the Ethernet interface and leave the USB enabled
    run_shell_command(f"ifconfig {ETH_INTERFACE} down")
    sleep(COOL_OFF_WAIT)
    wait_measurement_time("usb")
    write_phase_name("done")
    reboot()

def main():
    phase = None
    if not path.isfile(PHASE_MARKER_FILE):
        init()
        return
    with open(PHASE_MARKER_FILE, "r") as f:
        phase = f.read()
    match phase:
        case "all" : all_disabled()
        case "cpu" : cpu_cores()
        case "uart": uart()
        case "pcie": pcie()
        case "hdmi": hdmi()
        case "bt"  : bt()
        case "wifi": wifi()
        case "eth" : eth()
        case "usb" : usb()
    if phase == "done":
        # Remove all of the configurations
        for _ in range(4):
            pop_config()
        run_shell_command("sudo mv /boot/firmware/cmdline.txt /boot/firmware/cmdline2.txt; sudo mv /boot/firmware/cmdline-original.txt /boot/firmware/cmdline.txt")
        run_shell_command("sudo systemctl enable bluetooth")
        run_shell_command("sudo systemctl enable hciuart")
        # Marker to prevent this script from doing anything when the cron job activates after reboot
        # To active the experiment again, delete the phase marker file or the cron job
        write_phase_name("terminated")


if __name__ == "__main__":
    main()