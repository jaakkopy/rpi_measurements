import bluetooth # from PyBluez package
import struct
from time import sleep, time
import signal

RESPONSE_SIZE = 130
VOLTAGE_OFFSET = 2
VOLTAGE_SIZE = 2
CURRENT_OFFSET = 4
CURRENT_SIZE = 2
WATT_OFFSET = 6
WATT_SIZE = 4
ENERGY_OFFSET = 106
ENERGY_SIZE = 4

DATA_DUMP_REQUEST = 0xf0
COMMAND_SIZE = 1

DATA_DUMP_WAIT = 0.2

keep_looping = True


def interrupt(sig, frame):
    global keep_looping
    keep_looping = False


def unpack_vcpe(response):
    v = struct.unpack(">H", response[VOLTAGE_OFFSET : VOLTAGE_OFFSET + VOLTAGE_SIZE])[0]
    c = struct.unpack(">H", response[CURRENT_OFFSET : CURRENT_OFFSET + CURRENT_SIZE])[0]
    p = struct.unpack(">I", response[WATT_OFFSET : WATT_OFFSET + WATT_SIZE])[0]
    e = struct.unpack(">I", response[ENERGY_OFFSET : ENERGY_OFFSET + ENERGY_SIZE])[0]
    return (v, c, p, e)


def get_measurements(sock):
    while True:
        sock.send(DATA_DUMP_REQUEST.to_bytes(COMMAND_SIZE, byteorder='big'))        
        sleep(DATA_DUMP_WAIT)
        r = bytearray(sock.recv(RESPONSE_SIZE))
        if len(r) != RESPONSE_SIZE:
            continue
        return r

def print_values(t, v, c, p, e):
    print(f"{round(t, 3)},{v},{c},{p},{e}")

def main(addr: str, loop_time: float, poll_wait: float):
    signal.signal(signal.SIGINT, interrupt) 
    sock = None
    sock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
    sock.connect((addr, 1))
    # Remove the necessary wait time between a data dump request and the reading of the result from the poll time
    poll_wait = max(0, poll_wait - DATA_DUMP_WAIT)
    print("time_since_start_s,voltage_mV,current_mA,power_mW,acc_energy_mWh")
    # First measurement at time 0
    r = get_measurements(sock)
    print_values(0, *unpack_vcpe(r))
    # Start the timer
    start = time()
    t = 0 
    while t < loop_time and keep_looping:
        if t + poll_wait < loop_time:
            sleep(poll_wait)
        else:
            sleep(max(0, loop_time - t - DATA_DUMP_WAIT))
        r = get_measurements(sock)
        t = time() - start
        print_values(round(t, 3), *unpack_vcpe(r))
    sock.close()


if __name__ == "__main__":
    from sys import argv
    addr = argv[1] # bluetooth address
    loop_time = float(argv[2]) # loop time in seconds
    poll_wait = float(argv[3]) # wait time between polling in seconds
    main(addr, loop_time, poll_wait)