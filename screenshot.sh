# below is error because the quotes should for the entire directory
poseidon@rhelgui ~]$ sudo semanage fcontext -a -t httpd_sys_content_t /vhosts('/.*')?
-bash: syntax error near unexpected token '('
[poseidon@rhelgui ~]$ sudo semanage fcontext -a -t httpd_sys_content_t '/vhosts(/.*)?'
sudo ls -lZ /vhosts/
total 0
-rw-r-----. 1 root root unconfined_u:object_r:default_t:s0 0 Aug 11 15:16 index.html

# this moment, only database is updated, but we must run restorecon function to apply policy from the database.
# I ran the command again, you could see the message --> policy is already defined

[poseidon@rhelgui ~]$ sudo semanage fcontext -a -t httpd_sys_content_t '/vhosts(/.*)?'
File context for /vhosts(/.*)? already defined, modifying instead
[poseidon@rhelgui ~]$ sudo ls -lZ /vhosts/
total 0
-rw-r-----. 1 root root unconfined_u:object_r:default_t:s0 0 Aug 11 15:16 index.html
[poseidon@rhelgui ~]$ sudo ls -ldZ /vhosts/
drwxr-x---. 2 root root unconfined_u:object_r:default_t:s0 24 Aug 11 15:16 /vhosts/

# now applying the policy using restorecon

[poseidon@rhelgui ~]$ sudo restorecon -vR /vhosts/
Relabeled /vhosts from unconfined_u:object_r:default_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0
Relabeled /vhosts/index.html from unconfined_u:object_r:default_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0
[poseidon@rhelgui ~]$ sudo ls -lZ /vhosts/
total 0
-rw-r-----. 1 root root unconfined_u:object_r:httpd_sys_content_t:s0 0 Aug 11 15:16 index.html
[poseidon@rhelgui ~]$ sudo ls -lZd /vhosts/
drwxr-x---. 2 root root unconfined_u:object_r:httpd_sys_content_t:s0 24 Aug 11 15:16 /vhosts/
[poseidon@rhelgui ~]$
