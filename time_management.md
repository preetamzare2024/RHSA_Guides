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
