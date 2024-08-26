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

- /etc/tmpfiles.d/*.conf
- /run/tmpfiles.d/*.conf
- /usr/lib/tmpfiles.d/*.conf
