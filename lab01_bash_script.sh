#!/usr/bin/bash
export servera="192.168.56.188"
for server in $servera; do
    echo "$(ssh -i ~/.ssh/id_ed25519 contsvc@$server hostname -f)" >> "output-$server"
    echo "#####################" >> "output-$server"
    echo "$(ssh -i ~/.ssh/id_ed25519 contsvc@$server lsblk)" >> "output-$server"
    echo "#####################" >> "output-$server"
    echo "$(ssh -i ~/.ssh/id_ed25519 contsvc@$server grep ^[^#] /etc/selinux/config)" >> "output-$server"
    echo "#####################" >> "output-$server"
    ssh -i ~/.ssh/id_ed25519 contsvc@$server "sudo grep 'Failed password' /var/log/secure" >> "output-$server"
    echo "#####################" >> "output-$server"
done
