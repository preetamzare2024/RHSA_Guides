# Manage Temporary Files

In order to find the timer unit for the tmp files and folder run the below command

```bash
/poseidon\ 17:21:34 system $ systemctl list-units -t timer
  UNIT                         LOAD   ACTIVE SUB     DESCRIPTION
  dnf-makecache.timer          loaded active waiting dnf makecache --timer
  logrotate.timer              loaded active waiting Daily rotation of log files
  mlocate-updatedb.timer       loaded active waiting Updates mlocate database every day
  sysstat-collect.timer        loaded active waiting Run system activity accounting tool every 2 minutes
  systemd-tmpfiles-clean.timer loaded active waiting Daily Cleanup of Temporary Directories

LOAD   = Reflects whether the unit definition was properly loaded.
ACTIVE = The high-level unit activation state, i.e. generalization of SUB.
SUB    = The low-level unit activation state, values depend on unit type.
5 loaded units listed. Pass --all to see loaded but inactive units, too.
To show all installed unit files use 'systemctl list-unit-files'.
```

For us here the interesting one is systemd-tmpfiles-clean.timer and if you review the contents of this file, which is located under `/usr/lib/systemd/system/systemd-tmpfiles-clean.timer`

Which files to delete or which folder to cleanup is defined in three directories and in the order precedence is

- /etc/tmpfiles.d/*.conf <- This is where you as user defined and is overridden in other directories
- /run/tmpfiles.d/*.conf
- /usr/lib/tmpfiles.d/*.conf

## Difference between d and D

Before we get into this, we should always create our own .conf file if you want to overwrite something which is default configured. Now this means, that you need to understand various flags in the file.

```bash

[ poseidon 18:07:24 tmpfiles.d $ ] grep ^[^#] /usr/lib/tmpfiles.d/tmp.conf
d /tmp 1777 root root 10d
D /var/tmp 1777 root root 30d
[ poseidon 18:07:38 tmpfiles.d $ ]
```

d - Create a directory. The mode and ownership will be adjusted if specified. Contents of this directory are subject to time based cleanup if the age argument is specified.
D - Similar to d, but in addition the contents of the directory will be removed when `--remove` is used.

what does `--remove` here means, it means systemd-tmpfiles --remove /pathtotheconfigurationfile.conf

```bash
systemd-tmpfiles --clean /etc/tmpfiles.d/tmp.conf
```
