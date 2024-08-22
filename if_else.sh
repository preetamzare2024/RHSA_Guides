#!/bin/bash
echo "checking if the sshd.service is on or off"
sudo systemctl is-active sshd.service > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    echo "service is started, doing nothing"
else
    sudo systemctl start sshd.service
    sudo systemctl status sshd.service