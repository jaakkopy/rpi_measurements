from time import time, sleep
from sys import stdout

'''
This program will be running on the Raspberry Pi to measure the bandwidth.
'''

# Assumes the interface exists.
def get_interface_readings(lines: list[str], interface: str) -> tuple[int, int]:
    for l in lines:
        spl = l.split()
        if spl[0][:-1] == interface:
            # bytes received, bytes transmitted
            return (int(spl[1]), int(spl[9]))


def read_pnd(interface: str):
    # The file is opened again every time to allow it to refresh
    with open("/proc/net/dev", "r") as f:
        l = f.read()
        return get_interface_readings(l.splitlines(), interface)


def main(loop_time: float, check_interval: float, interface: str, out_file: str, should_print: str) -> None:
    RR = [] # bandwidth for bytes received
    RT = [] # bandwidth for bytes transmitted
    T  = [] # measurement time since start (seconds)
    # Read current bytes received/transmitted
    (br, bt) = read_pnd(interface)
    last_received = br
    last_transmit = bt
    i = 0
    dt = 0 
    start = time()
    t = start
    while dt < loop_time + check_interval:
        (br, bt) = read_pnd(interface)
        RR.append( (br - last_received) / check_interval )
        RT.append( (bt - last_transmit) / check_interval )
        last_received = br
        last_transmit = bt
        T.append(t)
        i += 1
        if should_print == 'y':
            print(dt)
            stdout.flush() # To prevent buffering.
        sleep(check_interval)
        t = time()
        dt = t - start
    with open(out_file, "w") as f:
        f.write("time_s,receive_bandwidth_bytes_per_s,transmit_bandwidth_bytes_per_s\n")
        for j in range(1, i):
            f.write(f"{T[j]},{RR[j]},{RT[j]}\n")


if __name__ == "__main__":
    from sys import argv
    loop_time = float(argv[1])  # seconds
    check_interval = float(argv[2]) # seconds
    interface = argv[3] # the network interface to check (e.g wlan0)
    out_file = argv[4] # where to write the output
    should_print = argv[5] # y/n to determine if the time value will be written to stdout
    main(loop_time, check_interval, interface, out_file, should_print)
        