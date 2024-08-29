# Installing NFS Server

lets practice what i learnt about dnf yesterday.

```bash
[ poseidon 17:00:33 ~ $ ] sudo dnf whatprovides nfs-utils
[sudo] password for poseidon:
Last metadata expiration check: 2:21:09 ago on Wed 28 Aug 2024 02:39:46 PM CEST.
nfs-utils-1:2.5.4-25.el9.aarch64 : NFS utilities and supporting clients and daemons for the kernel NFS server
Repo        : baseos
Matched from:
Provide    : nfs-utils = 1:2.5.4-25.el9
```


`sudo dnf install nfs-utils -y`

Note: For anything in RHEL, you must open firewall. So another opportunity to implement what i learnt. 

```bash
sudo firewall-cmd --get-services | grep -i nfs

[ poseidon 17:13:18 ~ $ ] sudo firewall-cmd --info-service=nfs
nfs
  ports: 2049/tcp
  protocols:
  source-ports:
  modules:
  destination:
  includes:
  helpers:
```

For setting up nfs mount point, create a file with .exports extension and place it in
` /etc/exports.d/<nameofthefile>.exports`
The content of the file should be

`/images *(rw)`

where images is the name of the directory.

To find out what is being shared by your nfs server

showmount -e

export the nfs mount point using `exportfs -r`

