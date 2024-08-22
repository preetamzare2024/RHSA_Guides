# create a front end network
podman network create frontend --subnet 10.89.1.0/24 --gateway 10.89.1.1

# check the front end network esp the ip subnet
podman network inspect frontend

# now login to the registry  and download the container
podman login registry.lab.example.com
podman run -d --name db_client --network frontend -v /etc/yum.repos.d:/etc/yum.repos.d registry.lab.example.com/ubi9-beta/ubi:latest sleep infinity

# check if the container is running, it won't run in this case because it needs some environmental variables
podman ps -a

# check the container logs, when the container has failed.
podman container logs

# MYSQL_USER (regex: '^[a-zA-Z0-9_]+$')
# MYSQL_PASSWORD (regex: '^[a-zA-Z0-9_~!@#$%^&*()-=<>,.?;:|]+$')
# MYSQL_DATABASE (regex: '^[a-zA-Z0-9_]+$')
# Or the following environment variable:
# MYSQL_ROOT_PASSWORD (regex: '^[a-zA-Z0-9_~!@#$%^&*()-=<>,.?;:|]+$')

# so stop and rm the container
podman stop
podman rm

# check there is no container running
podman ps -a

# create a local directory to mount inside the container
mkdir -pv /home/student/databases

# run the command inside the container to get uid for mysql
podman exec -it db_01 grep mysql /etc/passwd

# assign the right uid to the mysql user
podman unshare chown 27:27 /home/student/databases

# check the mysql uid is assigned
ls -ld /home/student/databases

# now run the container with required variables, including mapping the local directory as persistent volume.
podman run -d --name db_01 --network frontend -e MYSQL_USER=student -e MYSQL_PASSWORD=student -e MYSQL_DATABASE=db01 -e MYSQL_ROOT_PASSWORD=redhat321 -v /home/student/databases:/var/lib/mysql:Z  -p 13306:3306 registry.lab.example.com/rhel8/mariadb-105

# install mariadb inside client_db to access database from the client
podman exec -it db_client dnf install mariadb -y

# login into the database.
podman exec -it db_client mysql -u student -p -h db_01

# create table inside a database db_01
USE db01;
CREATE TABLE crucial_data(column1 int);

# check table is created
SHOW TABLES;

# on the container host, open port 13306
sudo firewall-cmd --add-port=13306/tcp --permanent

# check if the port is listed after reloading
sudo firewall-cmd --reload && sudo firewall-cmd --list-port

# now login into the database from the container host
mysql -u student -p -h servera --port 13306 db01 -e 'SHOW TABLES;'

# now create another network and attach it to the container
podman network create backend && podman network inspect backend
podman network connect backend db_01
podman network connect backend db_client

# now inspect the container if it has ip and subnet
podman inspect db_01 | less

# install ping utils on the  client
podman exec -it db_client dnf install -y iputils

# ping the database
podman exec -it db_client ping -c 4 db_01

