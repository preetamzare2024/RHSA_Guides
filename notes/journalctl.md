# Journalctl

This is the most important command. Lot of things to learn here for troubleshooting

first journalctl always start with message old to new. But almost, always we are interested in last logged message. You can achieve this using

`journalctl -r`

Remember `journalctl` always run in less mode, but in case you wish tail the logs, use

`journalctl -f`

Now, you wish to search for error messages, remember the priority thing we learnt in rsyslog lesson. This information comes handy here. And this is how

`journalctl --priority err`
`journalctl --priority warning`

you can also use `-u` to mentioned the service or user.

In case you wish to check what logged since last one hour.

`journalctl --priority err --since "-1 hour"`

In short, try to think journalctl is same as tail, why see below similarities

```bash

journalctl -f
journalctl -n 10
journalctl -

```

## Preserving Journal

By default journal is /var/run/journal and it remains there unless there is `journal` directory created under /var/log/.
If there is `journal` directory, then journal is persistent.
If there directory is not there, create that directory and reboot systemd-journald.service

```bash
# create the Directory
sudo mkdir -pv /var/log/journal

# restart the Service
sudo systemctl restart systemd-journald.service

# Reboot the system
sudo systemctl reboot now

# check the directory

sudo ls -l /var/log/journal

# check the boot entries

journalctl --list-boots


```