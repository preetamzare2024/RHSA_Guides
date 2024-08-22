#!/usr/bin/bash

echo "this is simple bash script" >>~/info.log
echo " " >>~/info.log
echo "############################" >>~/info.log
echo "########  ########" >>~/data.info
echo "List Block Devices" >>~/data.info
echo "######## ########" >>~/data.info
echo "$(lsblk)" >>~/data.info
echo "########  ########" >>~/data.info
echo "List free space" >>~/data.info
echo "########  ########" >>~/data.info
echo "$(df -h)" >>~/data.info
echo "########################################" >>~/data.info