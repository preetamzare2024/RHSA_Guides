# Adjust Tuning Profiles

- main command is tuned-adm

```bash
# Check the service
systemctl status tuned
```

### Check which profiles are available to use

```bash
[poseidon@rockymacm2 ~]$ sudo tuned-adm list
Available profiles:
- accelerator-performance     - Throughput performance based tuning with disabled higher latency STOP states
- aws                         - Optimize for aws ec2 instances
- balanced                    - General non-specialized tuned profile
- desktop                     - Optimize for the desktop use-case
- hpc-compute                 - Optimize for HPC compute workloads
- intel-sst                   - Configure for Intel Speed Select Base Frequency
- latency-performance         - Optimize for deterministic performance at the cost of increased power consumption
- network-latency             - Optimize for deterministic performance at the cost of increased power consumption, focused on low latency network performance
- network-throughput          - Optimize for streaming network throughput, generally only necessary on older CPUs or 40G+ networks
- optimize-serial-console     - Optimize for serial console use.
- powersave                   - Optimize for low power consumption
- throughput-performance      - Broadly applicable tuning that provides excellent performance across a variety of common server workloads
- virtual-guest               - Optimize for running inside a virtual guest
- virtual-host                - Optimize for running KVM guests
Current active profile: virtual-guest
```

Above command does provide the information as to which profile is active. But below is explicity command
```bash
[poseidon@rockymacm2 ~]$ sudo tuned-adm active
Current active profile: virtual-guest
```

### To switch from one profile to another
```bash
sudo tuned-adm profile < name of the profile >
```

### Where are the profiles stored
```bash

[poseidon@rockymacm2 ~]$ ls -l /usr/lib/tuned/
total 16
drwxr-xr-x. 2 root root    24 Aug 23 10:56 accelerator-performance
drwxr-xr-x. 2 root root    24 Aug 23 10:56 aws
drwxr-xr-x. 2 root root    24 Aug 23 10:56 balanced
drwxr-xr-x. 2 root root    24 Aug 23 10:56 desktop
-rw-r--r--. 1 root root 15476 Feb 22  2024 functions
drwxr-xr-x. 2 root root    24 Aug 23 10:56 hpc-compute
drwxr-xr-x. 2 root root    24 Aug 23 10:56 intel-sst
drwxr-xr-x. 2 root root    24 Aug 23 10:56 latency-performance
drwxr-xr-x. 2 root root    24 Aug 23 10:56 network-latency
drwxr-xr-x. 2 root root    24 Aug 23 10:56 network-throughput
drwxr-xr-x. 2 root root    24 Aug 23 10:56 optimize-serial-console
drwxr-xr-x. 2 root root    41 Aug 23 10:56 powersave
drwxr-xr-x. 2 root root    27 Aug 23 10:56 recommend.d
drwxr-xr-x. 2 root root    24 Aug 23 10:56 throughput-performance
drwxr-xr-x. 2 root root    24 Aug 23 10:56 virtual-guest
drwxr-xr-x. 2 root root    24 Aug 23 10:56 virtual-host
```