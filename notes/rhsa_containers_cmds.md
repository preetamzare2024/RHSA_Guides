# Command from Mac Pro

```bash
podman run -d --name mycontainer -p 8080:8080 pathtothecontainerimage
echo "Hello from container2" >/home/web1/index.html
podman run -d --name mycontainer2 -p 8081:8080 -v /home/web1:/var/www/html:Z pathtothecontainerimage

# check what is gone wrong with container or why it has exited
podman logs nameofthecontainer
# or
podman container logs nameofthecontainer

podman info  --format {{ .Host.NetworkBackend }}
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
