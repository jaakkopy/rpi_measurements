from time import sleep, time

def read_proc_stat():
    cpus = {}
    with open("/proc/stat", "r") as f:
        for l in f.readlines():
            s = l.split()
            if s[0][0:3] != "cpu":
                return cpus
            else:
                #               user        nice     system      idle
                cpus[s[0]] = (int(s[1]), int(s[2]), int(s[3]), int(s[4]))


if __name__ == "__main__":
    from sys import argv
    
    measure_time = float(argv[1]) # seconds
    interval = float(argv[2]) # seconds
    out_file = argv[3]

    # per cpu values
    utilization = {}
    last_busy = {}
    last_total = {}
    # timestamps
    times = []
    
    cpus = read_proc_stat()
    for cpu in cpus:
        (user, nice, system, idle) = cpus[cpu]
        last_busy[cpu] = user + nice + system
        last_total[cpu] = last_busy[cpu] + idle

    start = time()
    t = start
    while (t - start) < measure_time:
        sleep(interval)
        cpus = read_proc_stat()
        t = time()
        times.append(t)
        for cpu in cpus:
            (user, nice, system, idle) = cpus[cpu]
            busy = user + nice + system
            total = busy + idle
            l = utilization.get(cpu, [])
            l.append( (busy - last_busy[cpu]) / (total - last_total[cpu]) * 100 )
            utilization[cpu] = l
            last_busy[cpu] = busy
            last_total[cpu] = total
    
    with open(out_file, "w") as f:
        f.write("time_s,cpu,cpu_utilization_percentage\n")
        for i in range(len(times)):
            for cpu in utilization:
                f.write(f"{times[i]},{cpu},{round(utilization[cpu][i], 3)}\n")