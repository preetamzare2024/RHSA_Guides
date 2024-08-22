#!/bin/bash

# basic linux commands esp around nice, renice and process id

# 01 find the total number of processor on the linux

[poseidon@rhelgui ~]$ grep ^proc /proc/cpuinfo
processor	: 0
processor	: 1

# find the process (in detail) under the user
[poseidon@rhelgui ~]$ ps u $(pgrep sha1sum) # here stands for utilization
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
poseidon    2175 48.7  0.1 225364  3328 pts/0    R    08:01   0:28 sha1sum /dev/zero
poseidon    2176 48.7  0.1 225364  3328 pts/0    R    08:01   0:28 sha1sum /dev/zero
poseidon    2177 48.7  0.1 225364  3328 pts/0    R    08:01   0:28 sha1sum /dev/zero
poseidon    2178 48.7  0.1 225364  3328 pts/0    R    08:01   0:28 sha1sum /dev/zero

# check the process other/remote user

ps -u contsvc

# get nice value in ps command
ps -o pcpu,pid,nice,comm 