# How to reset root password in rhel9

This is part of systemunits but i want to create a separate markdown for this scenario.
First to learn about on how to reset root password, also increase the timeout for a grub.

Grub config which we are allowed to modify or customize is under 

`/etc/default/grub`

Under this file, you will find GRUB_TIMEOUT parameter.

## Step:01 - Modify timeout parameter as per your wish.

```bash

sudo vim /etc/default/grub 
# change GRUB_TIMEOUT, in case forget where this file is located,
# check grub2.cfg file under /etc/grub2.cfg

```

## Step:02 - update grub file using the following command

```bash
# in case you forgot the location of the file, simply do ls -l /etc/grub2.cfg, because this file is symlined to the /boot/grub2/grub.cfg

sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

## Step:03 

The actual root filesystem is mounted under /sysroot and sysroot is mounted as read only. So always remember to remount sysroot and then change the root to sysroot.

- reboot the machine and press any key and then press `e`
- find the line starting with linux and at the end type rd.break
- press ctrl + x
- now just to make sure all looks good, try ls -l
- now, mount the partition in rw mode using mount -o remount,rw /sysroot
- change the root using chroot /sysroot
- change the password using normal mode
- check ls -l /etc/shadow
- since selinux is not there, 
- load the selinux using load_policy -i
- lets fix this using restorecon command
- check again ls -lZ /etc/shadow
- press ctrl + d twice
- and password is reset

