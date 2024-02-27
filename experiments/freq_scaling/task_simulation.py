from time import sleep
import threading


job_lock = threading.Lock()
condition = threading.Condition()
job_queue = []


def simulate_job_processing(counter: int):
    i = 0
    while i < counter:
        i += 1


# Add a task during specified intervals
def task_adder(processing_counter: int, interval: float, amount_jobs: int):
    global job_queue, condition
    while amount_jobs > 0:
        # Add the job
        with condition:
            with job_lock:
                job_queue.append(processing_counter)
                # Notify the thread of the new job
                condition.notify() 
        amount_jobs -= 1
        sleep(interval)


def main(processing_counter: int, interval: float, amount_jobs: int):
    global job_queue, condition
    t = threading.Thread(target=task_adder, args=(processing_counter, interval, amount_jobs))
    t.start()
    while amount_jobs > 0:
        with condition:
            while len(job_queue) == 0 and amount_jobs > 0:
                condition.wait()
            job = 0
            with job_lock:
                job = job_queue.pop(0)
            simulate_job_processing(job)
            amount_jobs -= 1
    t.join()


if __name__ == "__main__":
    from sys import argv
    processing_counter = int(argv[1])
    interval = float(argv[2])
    amount_jobs = int(argv[3])
    main(processing_counter, interval, amount_jobs)
