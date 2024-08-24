

```bash
[poseidon@rockymacm2 ~]$ w
 17:24:50 up 28 min,  3 users,  load average: 0.18, 0.09, 0.02
USER     TTY        LOGIN@   IDLE   JCPU   PCPU WHAT
poseidon pts/0     17:00    0.00s  0.20s  0.04s w
pzare    seat0     17:23    0.00s  0.00s  0.00s /usr/libexec/gdm-wayland-session --register-session gnome-session
pzare    tty2      17:23     ?     0.01s  0.01s /usr/libexec/gnome-session-binary


### Info

pts - stands for psuedo terminal session. very likely a SSH sessions

# List processes started by the user

sudo ps -l -u pzare

# Lets find out who is logged into the system

[poseidon@rockymacm2 ~]$ w
 17:37:02 up 40 min,  4 users,  load average: 0.08, 0.21, 0.10
USER     TTY        LOGIN@   IDLE   JCPU   PCPU WHAT
poseidon pts/0     17:00    1.00s  0.22s  0.01s w
pzare    seat0     17:23    0.00s  0.00s  0.00s /usr/libexec/gdm-wayland-session --register-session gnome-session
pzare    tty2      17:23     ?     0.01s  0.01s /usr/libexec/gnome-session-binary
pzare    pts/2     17:36   10.00s  0.01s  0.01s -bash

# let's log-off pzare

## NOTE: default signal is 15 i.e. SIGTERM
[poseidon@rockymacm2 ~]$ sudo pkill -SIGTERM -u pzare

## Lets check now who is logged into the system
[poseidon@rockymacm2 ~]$ w
 17:38:32 up 42 min,  2 users,  load average: 0.23, 0.24, 0.12
USER     TTY        LOGIN@   IDLE   JCPU   PCPU WHAT
poseidon pts/0     17:00    0.00s  0.28s  0.03s w

# Let's go little further. Now I have logged into linux using ssh session from different sessions. And I wish to kill only one session
[pzare@rockymacm2 ~]$ w -u pzare
 17:52:32 up 56 min,  5 users,  load average: 0.42, 0.22, 0.12
USER     TTY        LOGIN@   IDLE   JCPU   PCPU WHAT
pzare    seat0     17:50    0.00s  0.00s  0.00s /usr/libexec/gdm-wayland-session --register-session gnome-session
pzare    tty2      17:50     ?     0.01s  0.01s /usr/libexec/gnome-session-binary
pzare    pts/2     17:48    1.00s  0.04s  0.03s w -u pzare
pzare    pts/1     17:48    4:15   0.00s  0.00s -bash

## how to log-off only one session i.e. in above command, we actually killed all sessions. Lets logoff tty2 because I no longer could access console
[poseidon@rockymacm2 ~]$ sudo pkill -t tty2

### Let us check
[poseidon@rockymacm2 ~]$ w
 17:53:58 up 57 min,  4 users,  load average: 0.32, 0.21, 0.12
USER     TTY        LOGIN@   IDLE   JCPU   PCPU WHAT
poseidon pts/0     17:00    5.00s  0.29s  0.01s w
pzare    pts/2     17:48   30.00s  0.03s  0.03s -bash
pzare    pts/1     17:48    5:41   0.00s  0.00s -bash

### If you wish to know from where the user is logged in

[poseidon@rockymacm2 ~]$ w --from
 17:56:51 up  1:00,  4 users,  load average: 0.02, 0.12, 0.09
USER     TTY      FROM              IDLE WHAT
poseidon pts/0    192.168.53.1      2.00s w --from --ip-addr --short -u
pzare    pts/2    192.168.53.1      3:23  -bash
pzare    pts/1    192.168.53.1      8:34  -bash

# PSTREE command.
[poseidon@rockymacm2 ~]$ sudo pstree -A -p -u pzare
sshd(4104)---bash(4105)

sshd(4150)---bash(4152)

systemd(4081)-+-(sd-pam)(4083)
              |-dbus-broker-lau(5082)---dbus-broker(5083)
              |-pipewire(4374)-+-{pipewire}(4383)
              |                `-{pipewire}(4386)
              |-pipewire-pulse(4378)-+-{pipewire-pulse}(4389)
              |                      `-{pipewire-pulse}(4391)
              `-wireplumber(4375)-+-{wireplumber}(4381)
                                  |-{wireplumber}(4382)
                                  |-{wireplumber}(4384)
                                  `-{wireplumber}(4394)

```
### What is difference between pkill and kill?
```bash
# kill -SIGTERM <PID>, here is an example
# find the process id
[poseidon@rockymacm2 ~]$ ps aux | grep tail
poseidon    2991  0.0  0.0 220608  1408 pts/1    S+   19:19   0:00 tail -f info.log
poseidon    2993  0.0  0.0 221432  2048 pts/0    S+   19:19   0:00 grep --color=auto tail
```
or ps -ef | grep tail

now you can kill the process using either kill or pkill. For kill you need pid but for pkill you **must** use name.

### Little bit about top. Something i learned earlier

- shift + m = sorting using memory
- shift + p = sorting using processor (default)
- shift + u = only for specific user

```bash
1 - to expand CPUs e.g.
### below is default
%Cpu(s):  0.0 us,  0.2 sy,  0.0 ni, 99.8 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st

### now lets press 1, you can see below detail utilization per cpu is shown. Another
### way to find how many CPUs are available
%Cpu0  :  0.0 us,  0.0 sy,  0.0 ni,100.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu1  :  0.7 us,  0.3 sy,  0.0 ni, 99.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st

```

To kill the process press 'k', the default pid is shown which is consuming maximum CPU. Enter the pid and press enter one more time and then press enter or provide SIG of your choice. Default is SIGTERM i.e. 15

