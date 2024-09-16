# Systemunits

List all units available in a system use the following command

type could be path, slice, mount, timer, service, automount, scope, socket, target

```bash
systemctl list-units --type=path

systemctl list-automounts

systemctl list-timers

systemctl list-sockets
```

## Customize service description

There are few things you might learn here.
Service defination is defined under /usr/lib/systemd/system/name.service e.g.
`/usr/lib/systemd/system/chronyd.service`

but for customization, you should create directory `/etc/systemd/system/httpd.service.d` with the same name as of the service
e.g. httpd.service you should create a folder with httpd.service.d (here d stands for drop in directory)

Inside httpd.service.d directory, create a file (with any name, as long as the file has .conf extension)
Here is the example for 

```bash
[sugrible@servera httpd.service.d]$ cat 99-httpd.conf
[Unit]
Description = "This our home httpd server"
```

And just reload daemon using `systemctl daemon-reload` and the check the status of the service again. You should see the Description text you defined above visible as seen below.

```bash
[sugrible@servera httpd.service.d]$ sudo systemctl status httpd.service
● httpd.service - "This our home httpd server"
---- output ---- omitted -----
```

If you wish to reboot your system in multi-user.target, then you can either do one time change by editing 
kernel parameter in the following ways or you can use systemctl set-default.

Below is bit complicated method of editing kernel parameter

step:01 reboot system, press esc and then select e to edit kernel parameters and then search a line linux, press end on the keyboard to go
to the end of the line and type `systemd.unit=multi-user.target`
press `ctrl + x` to save and system is automatically rebooted

To confirm your parameter is working type

`systemctl get-default`

or type 

`cat /proc/cmdline`

### Types of target

In case you are wondering what other targets are available, you can use the following command

```bash
systemctl list-units --type=target
```

The most important targets are 

- multi-user.target
- graphical.target
- rescue.target - required root password and can be used to fix fstab entries
- emergency.target - requires root password

The emergency target keeps the root file system mounted read-only, 
while the rescue target waits for the sysinit.target unit to complete, so that more of the system is initialized, 
such as the logging service or the file systems. 
The root user at this point cannot change /etc/fstab until the drive is remounted in a read write state with the mount -o remount,rw / command.