# How to reset root password in rhel9

This is part of systemunits but i want to create a separate markdown for this scenario.
First to learn about on how to reset root password, also increase the timeout for a grub.

Grub config which we are allowed to modify or customize is under 

`/etc/default/grub`

Under this file, you will find GRUB_TIMEOUT parameter.

Step:01 - Modify this parameter as per your wish.
Step:02 - update grub file using the following command

sudo grub2-mkconfig -o /boot/grub2/grub.cfg

Step:03 

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

