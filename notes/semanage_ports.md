# SELINUX - semanage ports

semanage ports is where we are dealing with ports.

in this example we are changing the ssh port from 22 to 23. Since it is a change, you have to follow bit different approach.

```bash
# first find out on which port ssh is running

ss -tulps | grep ssh
tcp   LISTEN 0      128          0.0.0.0:ssh        0.0.0.0:*
tcp   LISTEN 0      128             [::]:ssh           [::]:*

# check the port context for ssh and telnet
sudo semanage port -l | grep -e ssh -e telnet
ssh_port_t # (<-- we need this for --type, see below )                     tcp      22
telnetd_port_t                 tcp      23

# step:02 change the ssh port inside sshd_config file, that line is comment, 
# uncomment and change the port to 23
# restart the sshd service, it will fail
# you can check journalctl -p err

# step:03 Change the port using semanage

sudo semanage port --modify --type ssh_port_t --proto tcp 23

# you must use --modify flag here, because semanage does have entry for port 23.
# if you use --modify  flag for port 82, it will fail because there is nothing defined
# for port 82
# restart sshd service and it should be successful, check the status of the service 
# --> e.g. you will see something like this

Oct 05 07:48:22 servera systemd[1]: Starting "This is our own SSH Service description"...
Oct 05 07:48:22 servera sshd[39800]: Server listening on 0.0.0.0 port 23.
Oct 05 07:48:22 servera sshd[39800]: Server listening on :: port 23.

# add port 23 in the firewall and try to login to server using -p 23 
# it should work.
```

In case, you wish to know the modification you mande, you can use the following command

```bash
sudo semanage port --list --locallist
SELinux Port Type              Proto    Port Number

ssh_port_t                     tcp      23
```

