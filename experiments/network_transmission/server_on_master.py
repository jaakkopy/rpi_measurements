import socket
import time
import logging
import signal

FORMAT = "%(asctime)-15s %(message)s"
logging.basicConfig(format=FORMAT, level=logging.INFO, datefmt="%Y-%m-%d %H:%M:%S")
logger = logging.getLogger()

loop = True

def sigint(sig, frame):
    global loop
    loop = False

def listen(time_active: float, host: str, port: int, payload_size: int):
    signal.signal(signal.SIGINT, sigint) 
    start_time = time.time()
    curr_time = start_time
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind((host, port))
        s.listen()
        logging.log(logging.INFO, f"Listening on {host}:{port} for {time_active} seconds")
        while (curr_time - start_time) < time_active and loop:
            try:
                conn, _ = s.accept()
                with conn:
                    data = conn.recv(payload_size)
                    logging.log(logging.INFO, f"Received {len(data)} bytes.")
                curr_time = time.time()
            except Exception as e:
                print(logger.error(e))


if __name__ == "__main__":
    from sys import argv
    time_active = float(argv[1])
    host = argv[2]
    port = int(argv[3])
    payload_size = int(argv[4])
    listen(time_active, host, port, payload_size)