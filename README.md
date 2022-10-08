# Programming 2 (P2): Revised MLFQ Scheduler
## Instructor: Dr. Shengquan Wang
## Student: Nate Pierce, University of Michigan Dearborn
## CIS 450 Operating Systems

# Overview
This project takes the existing round robin (RR) scheduler for the xv6 operating system and implements a multi-level feedback queue (MLFQ) for the scheduler.

The per-process scheduler will have three queues, with three priorities. The highest priority, Q1, has a quantum size of 10 ms. The next queue, Q2, has a quantum size of 30 ms. The third and lowest queue, Q3, has a quantum size of 90 ms. Processes that exceed the quantum time in the third queue may be boosted back to Q1 three times. After the final boost, the process must finish in queue three. Processes that exceed the quantum time at each queue level will be demoted to the next lower queue.

# Building
Clone the repo, `cd` into the build directory. Within the docker container, use `make` and `make qemu-nox` to build and open the xv6 shell.

# Testing
Run `spin 10000000 &; spin 10000000 &; spin 10000000 &;` within the xv6 shell to launch three spin processes.

# Design and Implementation

The design/logic is best described through the following diagram. I use the existing round robin logic 

![diagram](img/P2_CIS450.drawio.png)