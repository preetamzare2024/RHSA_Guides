# Time configuration in RHEL

## Crontab

- to list job `crontab -l`
- to delete job `crontab -r`
- to find job of other user `crontab -l -u <username>`
  
### Field in crontab

M = Minutes
H = Hour

`M H DayOfMonth Month DayoftheWeek`

- which minute of hour i.e. 22 minutes of
- which hour of the day e.g. 14 hour
- which day of month 13 day
- which month e.g 06
- which Day i.e. monday-sunday (1-7) Sunday can be represented by `0` or `7`

### Example: 03

so in case you wish to schedule a job 13 June at 14:22 then below is the syntax

```bash
22 14 13 6 * /absolute_path_ofthe_command
```

### Example: 02

To run a command on the 11th day of every month, and every Friday at 12:15 (24-hour format)

```bash
15 12 11 * Fri /absolute_path_ofthe_command
```

### Example:03

The following job executes the /usr/local/bin/yearly_backup command at exactly 09:00 on 3 February, every year.

```bash
0 9 3 2 * /usr/local/bin/yearly_backup
```

### Example:04

The following job sends an email that contains the Chime word to the owner of this job every five minutes between and including 09:00 and 16:00, but only on each Friday in July.

```bash
*/5 9-16 * Jul 5 echo "Chime"




M H DayOfMonth Month DayoftheWeek
*/5 9-15 * 7 Fri /absolute_path_ofthe_command

# The following job runs the /usr/local/bin/daily_report command every working day (Monday to Friday) two minutes before midnight.
58 23 * * Mon-Fri /usr/local/bin/daily_report

### Example:05
# The following job executes the mutt command to send the Checking in mail message to the developer@example.com recipient every working day (Monday to Friday), at 9 AM.
0 9 * * Mon-Fri mutt -s "Checking in" developer@example.com % Hi there, just checking in.

```

### Example:06

Schedule a recurring job as the student user that appends the current date and time to the /home/student/my_first_cron_job.txt file every two minutes. 
Use the date command to display the current date and time. 
The job must run only from one day before to one day after the current time. The job must not run on any other day.

```bash
H M DayoftheMonth Month DayoftheWeek
*/2 * * * Fri-Sun /usr/bin/date >> /home/student/my_first_cron_job.txt
````

--------------------------------------------------------------------------------------------------------------

## Anacron

Do you want to run a job even if the machine is rebooted or unavailable for specific period of time. Or you want to ensure a specific job always run, then Anacron is the answer. Anacron is configured in `/etc/anacron` and its contains are below.

```bash
/poseidon\ 16:40:08 ~ $ cat /etc/anacrontab
# /etc/anacrontab: configuration file for anacron

# See anacron(8) and anacrontab(5) for details.

SHELL=/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
# the maximal random delay added to the base delay of the jobs
RANDOM_DELAY=45
# the jobs will be started during the following hours only
START_HOURS_RANGE=3-22

#period in days   delay in minutes   job-identifier   command
1   5   cron.daily  nice run-parts /etc/cron.daily
7   25  cron.weekly nice run-parts /etc/cron.weekly
@monthly 45 cron.monthly  nice run-parts /etc/cron.monthly
```

The important part of this file is the last three lines. You might notice `nice` command in the above file as well.

```bash
/poseidon\ 16:47:52 ~ $ sudo tree /var/spool/cron/
sudo tree /var/spool/cron/
/var/spool/cron/
└── poseidon

0 directories, 1 file
/poseidon\ 16:48:03 ~ $ sudo tree /var/spool/anacron/
/var/spool/anacron/
├── cron.daily
├── cron.monthly
└── cron.weekly

```

### How to find if the job has ran?

When the crond daemon starts a job from the /etc/anacrontab file, it updates the timestamps of those files. With this timestamp, you can determine the last time that the job executed.

