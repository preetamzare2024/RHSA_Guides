# rsyslog notes

lets take a use case, where you wish to send all logs to specific folder, then you need to create directive inside /etc/rsyslog.d/ folder.
The directive is something like this

Cntents of /etc/rsyslog.d/99-mycustomlogs.conf. It must have .conf extension. Why `.conf` extension? because under /etc/rsyslog.conf you will find those details.

```bash
*.debug     /var/log/debug-messages.log
```

In the above file, `*` indicates all stuff and then `.debug` represent all priority. More information you can find inside rsyslog.conf man pages. Search for `SELECTORS`. 

```markdown
The facility is one of the following keywords: 
auth, authpriv, cron, daemon, kern, lpr, mail, mark, news, security (same as auth), syslog, user, uucp and local0 through local7. 
The keyword security should not be used anymore and mark is only  for  internal  use  and therefore should not be used in applications.  
Anyway, you may want to specify and redirect these messages here. 
The facility specifies the subsystem that produced the message, i.e. all mail programs log with the mail facility (LOG_MAIL) if they log using syslog.

The  priority  is  one  of the following keywords, in ascending order: 
debug, info, notice, warning, warn (same as warning), err, error (same as err), crit, alert, emerg, panic (same as emerg). 
The keywords error, warn and panic are deprecated and should not be used anymore.
```

let's try to read the file located under `/etc/rsyslog.conf`

```bash
[sugrible@servera rsyslog.d]$ grep ^[^#] /etc/rsyslog.conf
include(file="/etc/rsyslog.d/*.conf" mode="optional")
*.info;mail.none;authpriv.none;cron.none                /var/log/messages
authpriv.*                                              /var/log/secure
mail.*                                                  -/var/log/maillog
cron.*                                                  /var/log/cron
*.emerg                                                 :omusrmsg:*
uucp,news.crit                                          /var/log/spooler
local7.*                                                /var/log/boot.log
```

- *.info means everything goes to /var/log/messages and then mail.none means no mail logs will go to this directory
- similarly authpriv.none does not go /var/log/messages but then authpriv.* goes to /var/log/secure

## Send syslog files to custom directory

now we first we need to find where syslog is sendings it log. This is visible in syslog.conf file

```bash
[sugrible@servera rsyslog.d]$ sudo grep -i syslog /etc/ssh/sshd_config
#SyslogFacility AUTH
```

Syslog is sending it to AUTH facility. Now lets say we want to send this to our own file under /var/log, in this case we have local1 to local0 facilities available to use

The contents of /etc/ssh/sshd_config files are below

```bash
sudo grep -i syslog /etc/ssh/sshd_config
SyslogFacility local6
```

In the above file, i have added a line to send syslog to facility local6, and now we need to update rsyslog.d/ to send local6 to specific directory. I have created a file 99-syslog.conf file and its contents are below

```bash
local6.*	/var/log/mysshd.log
```

In other words, whatever is coming to local6 is send to mysshd.log file. So to test this, we must send a test message to the specific facility

`logger -p local6.info "Hey this is test message for sshd"`

