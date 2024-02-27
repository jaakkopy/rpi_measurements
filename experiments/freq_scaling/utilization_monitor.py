import signal
from time import sleep


keep_measuring = True


def catch_sigusr1(sig, frame):
    global keep_measuring
    keep_measuring = False


def read_proc_stat(cpu: str):
    with open("/proc/stat", "r") as f:
        for l in f.readlines():
            s = l.split()
            if s[0] == cpu:
                #         user        nice     system      idle
                return (int(s[1]), int(s[2]), int(s[3]), int(s[4]))


if __name__ == "__main__":
    from sys import argv
    
    cpu = argv[1]
    interval = float(argv[2])
    out_file = argv[3]

    signal.signal(signal.SIGUSR1, catch_sigusr1) 

    utilization = []
    (user, nice, system, idle) = read_proc_stat(cpu)
    last_busy = user + nice + system
    last_total = last_busy + idle

    while keep_measuring:
        sleep(interval)
        (user, nice, system, idle) = read_proc_stat(cpu)
        busy = user + nice + system
        total = busy + idle
        utilization.append( (busy - last_busy) / (total - last_total) * 100 )
        last_busy = busy
        last_total = total
    
    with open(out_file, "w") as f:
        f.write("cpu_utilization_percentage\n")
        for u in utilization:
            f.write(f"{round(u, 3)}\n")