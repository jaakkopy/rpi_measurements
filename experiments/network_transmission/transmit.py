import socket
import os
from time import sleep

def transmit(payload_bytes: int, wait_time: float, amount_transmissions: int, target_host: str, target_port: int):
    # Random bytes to send to the target
    payload = bytearray(os.urandom(payload_bytes))
    while amount_transmissions > 0:
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.connect((target_host, target_port))
                s.sendall(payload)
        except:
            pass
        sleep(wait_time)
        amount_transmissions -= 1


if __name__ == "__main__":
    from sys import argv
    payload_bytes = int(argv[1])
    time_between_transmission = float(argv[2]) # in seconds
    amount_transmissions = int(argv[3])
    target_host = argv[4] # target hot is assumed to be using TCP
    target_port = int(argv[5])
    transmit(payload_bytes, time_between_transmission, amount_transmissions, target_host, target_port)