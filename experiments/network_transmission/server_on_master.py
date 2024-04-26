import socket
import time
import logging

FORMAT = "%(asctime)-15s %(message)s"
logging.basicConfig(format=FORMAT, level=logging.INFO, datefmt="%Y-%m-%d %H:%M:%S")
logger = logging.getLogger()

def listen(time_active: float, host: str, port: int):
    start_time = time.time()
    curr_time = start_time
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind((host, port))
        s.listen()
        logging.log(logging.INFO, f"Listening on {host}:{port} for {time_active} seconds")
        while (curr_time - start_time) < time_active:
            try:
                conn, _ = s.accept()
                with conn:
                    # Assuming that the transmission is at most 2048 bytes
                    data = conn.recv(2048)
                    logging.log(logging.INFO, f"Received {len(data)} bytes.")
                curr_time = time.time()
            except Exception as e:
                print(logger.error(e))


if __name__ == "__main__":
    from sys import argv
    time_active = float(argv[1])
    host = argv[2]
    port = int(argv[3])
    listen(time_active, host, port)