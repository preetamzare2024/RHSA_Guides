# All about firewall-cmd command

- To find which is the default zone and what is allowed, run the following command

```bash

[root@rhelonhp ~]# firewall-cmd --list-all
public (active) # this is default zone
  target: default
  icmp-block-inversion: no
  interfaces: eno1 # default zone is associated with this nic
  sources: 
  services: cockpit dhcpv6-client ssh # services or ports opened
  ports: 
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
```

## Little bit about public.xml file

Since the default zone is public.xml, the name of the file is public.xml and it is located in `/usr/lib/firewalld/zones/public.xml`

### Few things to note

- this file not under /usr/lib/systemd rather in /usr/lib/firewalld and `firewalld.service` is under `systemd/system/firewalld.services`
- since public is the name of the zone file is named with that zone.
- this file is not suppose to be modified

When you add custom services or ports, the public.xml file is modified and in this case, public.xml file is modified and stored in /etc/firewalld/zones/public.xml. 


```bash

cat /etc/firewalld/zones/public.xml
<?xml version="1.0" encoding="utf-8"?>
<zone>
  <short>Public</short>
  <description>For use in public areas. You do not trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.</description>
  <service name="ssh"/>
  <service name="dhcpv6-client"/>
  <service name="cockpit"/>
  <forward/>
</zone>
```

#### What is --permanent?

All changes are in the runtime. So to make it permanent, you need to use this command.

```bash

# step:01 add http service
firewall-cmd --add-service=http 
success

# step:02 check public.xml file
cat /etc/firewalld/zones/public.xml
<?xml version="1.0" encoding="utf-8"?>
<zone>
  <short>Public</short>
  <description>For use in public areas. You do not trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.</description>
  <service name="ssh"/>
  <service name="dhcpv6-client"/>
  <service name="cockpit"/>
  <forward/>
</zone>

# step:03 run the same command with permanent flag
firewall-cmd --add-service=http --permanent 
success

# step:04 cat the public.xml file
cat /etc/firewalld/zones/public.xml
<?xml version="1.0" encoding="utf-8"?>
<zone>
  <short>Public</short>
  <description>For use in public areas. You do not trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.</description>
  <service name="ssh"/>
  <service name="dhcpv6-client"/>
  <service name="cockpit"/>
  <service name="http"/>
  <forward/>
</zone>

```

#### -- runtime-to-permanent

There are two options on how you approach this `--permanent`, you can either add it to the single command this permanent option or you can run it separate.
In all cases, you need to reload the firewall or else it won't reflect in firewall-cmd --list-all.
or you can add all services in single command and later, run a single command firewall-cmd --runtime-to-permanent to make permanent changes

#### use case:

you want to test multiple services without making any permanent changes to the firewall e.g. add nfs, https, http
you test all things and you are happy with it.
simple run --runtime-to-permanent

```bash

#step:01
firewall-cmd --add-service=http --add-service=https --add-service=nfs3

# step:02
# check if the changes are in runtime

[root@rhelonhp ~]# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eno1
  sources: 
  services: cockpit dhcpv6-client http https nfs3 ssh
  ports: 
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 

# step:03
# At this stage, public.xml is not updated
# if you are happy, you can make the changes permanent
firewall-cmd --runtime-to-permanent

# step:04
# check if public.xml is updated

# step:05 

```

Finally confirm `firewall-cmd --reload` does not clear recent changes, please note `--reload` flag reads public.xml file and adds it to firewalld. If you do not run `--permanent` flag or `--runtime-to-permanent`, Your recent changes are not recognized by firewalld.

### Add your own service or ports

All definition of ports are stored in `/usr/lib/firewalld/services/` e.g.

```bash
sudo cat /usr/lib/firewalld/services/https.xml
<?xml version="1.0" encoding="utf-8"?>
<service>
  <short>Secure WWW (HTTPS)</short>
  <description>HTTPS is a modified HTTP used to serve Web pages when security is important. Examples are sites that require logins like stores or web mail. This option is not required for viewing pages locally or developing Web pages. You need the httpd package installed for this option to be useful.</description>
  <port protocol="tcp" port="443"/>
</service>
```

Make the copy of this file in `/etc/firewalld/services` and edit it as per your requirement

```bash

cp -v /usr/lib/firewalld/services/https.xml /etc/firewalld/services/
'/usr/lib/firewalld/services/https.xml' -> './https.xml'
mv https.xml mysticwww.xml

# makes changes to the xml file
vim mysticwww.xml

# reload the firewall to recognize mysticwww.xml
firewall-cmd --reload
success

# now try to add the service with same name as the name of the xml file
firewall-cmd --add-service=mysticwww
success

# list the firewall services

[root@serverb ~]# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0 eth1
  sources:
  services: cockpit dhcpv6-client mysticwww ssh
  ports:
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

# to discard the changes, just use --reload flag.

```

Example if you wish add all the incoming traffic from the 172.25.25.11 single IPv4 address to the public zone, use the following commands

```bash
firewall-cmd --permanent --zone=public --add-source=192.168.56.71/32
firewall-cmd --reload
```

In case you wish to try https i.e. curl -k https://servername, assign tls certificate to the webserver, you have should mod_ssl package which is 

```bash

Summary      : SSL/TLS module for the Apache HTTP Server
Description  : The mod_ssl module provides strong cryptography for the Apache HTTP
             : server via the Secure Sockets Layer (SSL) and Transport Layer
             : Security (TLS) protocols.
```

