import socket
import logging
import signal

FORMAT = "%(asctime)-15s %(message)s"
logging.basicConfig(format=FORMAT, level=logging.INFO, datefmt="%Y-%m-%d %H:%M:%S")
logger = logging.getLogger()

RECV_MAX_SIZE=2048

loop = True

def sigint(sig, frame):
    global loop
    loop = False

def listen(host: str, port: int):
    signal.signal(signal.SIGINT, sigint) 
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind((host, port))
        s.listen()
        logging.log(logging.INFO, f"Listening on {host}:{port}")
        # Will loop forever until sigint is catched
        while loop:
            try:
                conn, _ = s.accept()
                with conn:
                    data = conn.recv(RECV_MAX_SIZE)
                    logging.log(logging.INFO, f"Received {len(data)} bytes.")
            except Exception as e:
                print(logger.error(e))


if __name__ == "__main__":
    from sys import argv
    host = argv[1]
    port = int(argv[2])
    listen(host, port)