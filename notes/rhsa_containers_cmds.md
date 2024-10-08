# Podman and containers

OCI stands for Open Container Initiative
Container Image is all you need to run containers, but containers are run using container runtime (container engine) e.g Docker or Podman...etc

Container Image is a Tar archive

Little bit about podman to manage containers
In case, you wish to know on which port containers is running i.e. what are the exposed ports? just run, 

```bash
podman inspect <imagename> | grep Config -A 25
```

you need to know exposed port, environmental variables and entry point.

## Basic Commands

Read man pages for podman using podman-<command_name> e.g. man podman-login

Check what is configured in /etc/containers/registries.conf, You can also create you own registries.conf file using the following procedure

```bash
# step:01
mkdir -pv ~/.config/containers
cd ~/.config/containers
vim registries.conf

# the content of registries.conf file you can pick from the /etc/containers/registries.conf
# At high level you need
# - unqualified-search-registries = ["registry.access.redhat.com", "registry.redhat.io", "docker.io"]
     # [[registries]]
     # location = "registry.redhat.io"
     # insecure = false
     # blocked = false
```

To confirm registries configuration is indeed setup, you can you parse the file using the following command

```bash
podman info | grep registries -A 10 -n
```

```bash
# step:02
podman login 
# remember to configure the registries.conf file in your home directory as mentioned above, 
# or you must give full qualified name

# step:03 since If you do not remember name of the image, you can start with httpd
podman search httpd
```

I'm going to avoid outputting because it creates a clutter. So, now when you run this image, you can pick anything which starts with ubi, I choosed ubi9/httpd-24. Now since you have only registry.redhat.io configured in the registry, you do not need to provide complete path.

```bash

# step:04 
podman pull ubi9/httpd-24

# step:05 Now we have pulled the image, we can check the image.
podman images

# step:06 now run the container using the image, 


podman run --rm -d -p 8090:8080 ubi9/httpd-24

```

let me explain the flag
`--rm` will remove the image if you stop the container
`-p` is port, localport 8090 will get redirected to 8080
`-d` in detached mode
finally the name of the image and I'm avoiding flag `--name` to give name to the container

```bash
# step: 07 check the container status using

podman ps
# or 
podman ps --all # this is esp required when the container exits immediately, since it is httpd,
# you may not use --all flag

# step: 08 check if the default web page is available

curl http://localhost:8090

# step: 09 check the logs of the container
# check what is gone wrong with container or why it has exited

podman container logs nameofthecontainer

# step: 10 stop the container and since we used --rm flag, container will also be deleted

podman stop nameofthecontainer

# this means, when you stop the container and run podman ps --all, 
# you will not find this container at all because we used --rm flag
# you also add a tag --time=x where x stands for number of seconds which allow container to gracefully stop.

# forcefully stop the container

podman rm nameofthecontainer -f # here the container is not stopped with -f flag it is force to stop and kill

# last option is kill

podman kill nameofthecontainer

# you can pause the container, and restart the container.

```

## Advance concepts

The most important concept which i would describe below is how to map local storage inside the container.
For this you need to ensure you have index.html file and it has right selinux permission.

```bash
# step: 01 create folder
mkdir -pv web1

# step: 02 create a smaple index file
echo "Hello from container2" >/home/web1/index.html

# step: 03 run the container and point it to local storage using -v option. 
# Do remember that in the below example
# /home/web1 is directed to /var/www/html, please note you have to ensure source directory is mapped to the destination directory.
# or you can simple man /home/web1 to /var/www/
# Mount the /home/web1 directory from the host to the /var/www directory in the container.
podman run -d --rm --name mycontainer2 -p 8090:8080 -v /home/web1:/var/www/html:Z pathtothecontainerimage

```

### Additional example of mounting storage using mysql

- First we need to create a directory e.g. /home/poseidon/mydb
- assign permission to mysql user. For that you must know the UID of mysql. It is normally 27, you can find the information in `podman inspect <containerimagename>`
  - assign permission is done via podman command

```bash
podman unshare chown 27:27 /home/poseidon/mydb00
```

- run the container using the following using the following command

```bash

podman run --detach -e MYSQL_USER=student \
-e MYSQL_PASSWORD=student123 \
-e MYSQL_DATABASE=db01 \
-e MYSQL_ROOT_PASSWORD=student321 \
-v /home/poseidon/mysqldb01:/var/lib/mysql \
registry.redhat.io/rhel9/mysql-80

# The above command fails because we are not using selinux, also try to find more information about the image esp environment variables using podman inspect <imagename> | grep usage

podman run --detach -e MYSQL_USER=student \
-e MYSQL_PASSWORD=student123 \
-e MYSQL_DATABASE=db01 \
-e MYSQL_ROOT_PASSWORD=student321 \
-v /home/poseidon/mysqldb01:/var/lib/mysql:Z \
registry.redhat.io/rhel9/mysql-80


```

### Additional Concept

You can also start and stop the container when the system is rebooted. There are two things you need to do for it

- ensure the container is running e.g. in my case mycontainer2
- create .service file
- start the service
- use loginctl enable-linger (this ensures that container is started in non-interactive way i.e. you do not have login to start the container)

```bash
# step:01 create a folder in .config directory

mkdir -pv .config/systemd/user 
cd .config/systemd/user

# step:02 create a .service file
podman generate systemd --files --new --name mycontainer2

# now stop the container using
podman stop mycontainer2

# step:03 reload systemd 

systemctl --user daemon-reload

# step:04 enable and start the container
systemctl --user enable --now container-web01.service

# check the status of the container
systemctl --user status container-web01.service
# or
podman ps

# step:05 enable container service to start in non-interactive way

loginctl enable-linger

# check
loginctl show-user $(whoami)

# reboot the machine
# wait 5 minutes
# if possible, open http://nameofthevm:8090 from your local machine


```

Things to remember, systemctl --user option and where to create directory because systemctl --user option is going to look for that directory.

Another thing, how to disable this is not documented.

As of today (when my memory is fresh), it is so simple. Disable systemctl --user service name and then simply delete the file in the .config/systemd/user folder.


```bash

# by default format is json, you can use the same command with podman inspect
podman info  --format {{ .Host.NetworkBackend }}

# double curl brackets is the something i also seen in ansible. In the above command, you see space after curly bracket.
# You do not need this space.
podman inspect 668d5331f2b7 --format "{{ .State.Status }}"

podman network ls

skopeo inspect docker://registry.access.redhat.com/rhel8/mariadb-1011 | grep usage
"usage": "podman run -d -e MYSQL_USER=user -e MYSQL_PASSWORD=pass -e MYSQL_DATABASE=db -p 3306:3306 rhel8/mariadb-1011",

# check the permission on mysql folder inside the container db9
podman exec -it db9 ls -l /var/lib/mysql
total 4
drwxrwxr-x. 1 mysql root  4096 May 25 11:57 data
srwxrwxrwx. 1 mysql mysql    0 May 25 11:57 mysql.sock


# mapping uid and gid
[ db09_data ]$ podman unshare cat /proc/self/uid_map
         0       1000          1
         1     100000      65536
[ db09_data ]$ podman unshare cat /proc/self/gid_map
         0       1000          1
         1     100000      65536
# this means, if you are user with id 2 you will start uid and gid with 100001 (which is 1 minus than your id)


# mapping local folder in the container

podman run -d --name=redb01 -e MYSQL_USER=student -e MYSQL_PASSWORD=student -e MYSQL_DATABASE=redb01 -p 3308:3306 \
-v /home/vagrant/db09_data:/usr/lib/mysql:Z rhel8/mariadb-1011

podman run -d --name=topdb01 -e MYSQL_USER=student -e MYSQL_PASSWORD=student -e MYSQL_DATABASE=redb01 -p 3309:3306 -v /home/vagrant/redb01_data:/usr/lib/mysql:Z registry.access.redhat.com/rhel8/mariadb-1011

podman port -a
6e84c6ecaf77	3306/tcp -> 0.0.0.0:3306
c0ed58b8fc68	3306/tcp -> 0.0.0.0:3308
6077ca3bb732	3306/tcp -> 0.0.0.0:3309
c478dbc619dc	3306/tcp -> 0.0.0.0:3310

# check which network backend is used.
[ db09_data ]$ podman info | grep networkBackend:
  networkBackend: netavarkpod
[ db09_data ]$

```

## Create Networks

```bash
[ db09_data ]$ podman network create --gateway 10.87.0.1 --subnet 10.87.0.0/16 db_net
db_net
[ db09_data ]$ podman network ls
NETWORK ID    NAME        DRIVER
799bd99521a6  db_net      bridge
2f259bab93aa  podman      bridge
[ db09_data ]$ podman network inspect db_net
[
     {
          "name": "db_net",
          "id": "799bd99521a6f61106ef8537a7de542136d71bd32c873cadd1154a913b1cdaab",
          "driver": "bridge",
          "network_interface": "podman1",
          "created": "2024-05-25T14:10:26.598006189Z",
          "subnets": [
               {
                    "subnet": "10.87.0.0/16",
                    "gateway": "10.87.0.1"
               }
          ],
          "ipv6_enabled": false,
          "internal": false,
          "dns_enabled": true,
          "ipam_options": {
               "driver": "host-local"
          }
     }
]

podman run -d --name redbsrv01 -e MYSQL_USER=preetam -e MYSQL_PASSWORD=VMware1\!2303 -e MYSQL_DATABASE=redb \
-p 3306:3306 -v /home/vagrant/redb01_data:/usr/lib/mysql:Z --network db_net registry.access.redhat.com/rhel8/mariadb-1011

```

podman logs <nameofthecontainer> to get the log info