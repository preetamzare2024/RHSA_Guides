lab start containers-review
ssh serverb
sudo dnf install -y container-tools
cp -v /tmp/registries.conf ~/.config/


mkdir -pv /home/podsvc/db_data
podman
podman un chmod 27:27

podman run -d --name inventorydb -p 13306:3306 -v /home/contsvc/db_data:/var/lib/mysql/data:Z -e MYSQL_USER=operator1 \
-e MYSQL_PASSWORD=redhat \
-e MYSQL_DATABASE=inventory \
-e MYSQL_ROOT_PASSWORD=redhat \
registry.access.redhat.com/rhel9/mariadb-1011
