# Using: VS Code Thema oh-lucy and font Cascadia Code


# How to create partition and format partition.
# And end to end guide

# To partition a new drive, start with labelling the disk


[preetam@rhelgui ~]$ lsblk -fp
NAME                      FSTYPE      FSVER            LABEL                    UUID                                   FSAVAIL FSUSE% MOUNTPOINTS
/dev/sr0                  iso9660     Joliet Extension RHEL-9-3-0-BaseOS-x86_64 2023-10-25-09-17-25-00                       0   100% /run/media/preetam/RHEL-9-3-0-BaseOS-x86_64
/dev/nvme0n1
├─/dev/nvme0n1p1          vfat        FAT32                                     6FE2-3FF4                               591.8M     1% /boot/efi
├─/dev/nvme0n1p2          xfs                                                   fa64d359-0d13-4b12-ab89-a126beaebbad    562.4M    41% /boot
└─/dev/nvme0n1p3          LVM2_member LVM2 001                                  vSxDbr-gvI0-PbqP-m5MW-S5wR-W1qt-pQQJb9
  ├─/dev/mapper/rhel-root xfs                                                   25db91be-fd78-46e8-b301-ac69916c6e4e      7.7G    53% /
  └─/dev/mapper/rhel-swap swap        1                                         fb00e800-59a6-42d6-8102-554dd1e19ce8                  [SWAP]
/dev/nvme0n2
├─/dev/nvme0n2p1          xfs                                                   d5ae7ae3-5bcd-401e-8b61-6b789dcb10dd    804.9M     5% /publicimages
├─/dev/nvme0n2p2
└─/dev/nvme0n2p3
/dev/nvme0n3

# mklabel [gpt msdos]

[preetam@rhelgui ~]$ sudo parted /dev/nvme0n3 mklabel gpt
Information: You may need to update /etc/fstab.

# run to read the device change
[preetam@rhelgui ~]$ sudo udevadm settle

# print the new partion information
[preetam@rhelgui ~]$ sudo parted /dev/nvme0n3 print
Model: VMware Virtual NVMe Disk (nvme)
Disk /dev/nvme0n3: 10.7GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:
Number  Start  End  Size  File system  Name  Flags


(parted) mkpart
Partition name?  []? secured
File system type?  [ext2]? xfs
Start? 2048 # this is by default G, so always ensure you mention 2048s or simple 2M
End? 3000M # remember here you can just mention size e.g. 3G for 3 GB
(parted) p # print the information
Model: VMware Virtual NVMe Disk (nvme)
Disk /dev/nvme0n3: 10.7GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size   File system  Name     Flags
 1      2048MB  3000MB  952MB  xfs          secured


# create another partition

(parted) mkpart
Partition name?  []? public
File system type?  [ext2]? xfs
Start? 6GiB # here GiB
End? 100% # in case you do not know how much space is available
(parted) p
Model: VMware Virtual NVMe Disk (nvme)
Disk /dev/nvme0n3: 10.7GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name    Flags
 1      1049kB  3221MB  3220MB               secure
 2      3221MB  6442MB  3221MB               open
 3      6442MB  10.7GB  4294MB  xfs          public


# Create actual file system

[preetam@rhelgui ~]$ sudo mkfs.xfs /dev/nvme0n3p1 # partition 1
# ----- output omitted ----- #

[preetam@rhelgui ~]$ sudo mkfs.xfs /dev/nvme0n3p2 # partition 2
# ----- output omitted ----- #

[preetam@rhelgui ~]$ sudo mkfs.xfs /dev/nvme0n3p3 #partition 3
# ----- output omitted ----- #


# check the file system
[preetam@rhelgui ~]$ lsblk -f
NAME          FSTYPE      FSVER            LABEL                    UUID                                   FSAVAIL FSUSE% MOUNTPOINTS
sr0           iso9660     Joliet Extension RHEL-9-3-0-BaseOS-x86_64 2023-10-25-09-17-25-00                       0   100% /run/media/preetam/RHEL-9-3-0-BaseOS-x86_64
nvme0n1
├─nvme0n1p1   vfat        FAT32                                     6FE2-3FF4                               591.8M     1% /boot/efi
├─nvme0n1p2   xfs                                                   fa64d359-0d13-4b12-ab89-a126beaebbad    562.4M    41% /boot
└─nvme0n1p3   LVM2_member LVM2 001                                  vSxDbr-gvI0-PbqP-m5MW-S5wR-W1qt-pQQJb9
  ├─rhel-root xfs                                                   25db91be-fd78-46e8-b301-ac69916c6e4e      7.7G    53% /
  └─rhel-swap swap        1                                         fb00e800-59a6-42d6-8102-554dd1e19ce8                  [SWAP]
nvme0n2
├─nvme0n2p1   xfs                                                   d5ae7ae3-5bcd-401e-8b61-6b789dcb10dd    804.9M     5% /publicimages
├─nvme0n2p2
└─nvme0n2p3
nvme0n3
├─nvme0n3p1   xfs                                                   06f17c6b-50e6-4e91-aa4f-086a4e86e805
├─nvme0n3p2   xfs                                                   ddcdfa78-71b3-46e0-b180-6181f28ffe6a
└─nvme0n3p3   xfs                                                   6c944a09-671c-4477-a9bb-9693331ae2bf


# Used variable expansion

[preetam@rhelgui ~]$ sudo lsblk --fs /dev/nvme0n3p{1..3}
NAME      FSTYPE FSVER LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
nvme0n3p1 xfs                06f17c6b-50e6-4e91-aa4f-086a4e86e805
nvme0n3p2 xfs                ddcdfa78-71b3-46e0-b180-6181f28ffe6a
nvme0n3p3 xfs                6c944a09-671c-4477-a9bb-9693331ae2bf

# --------- Make Swap Space ------------ #

sudo parted /dev/nvme0n2
(parted) mkpart
Partition type?  primary/extended? primary
File system type?  [ext2]? linux-swap
Start? 2048s
End? 100% # <---- used 100% and you can get warning to confirm
Warning: You requested a partition from 1049kB to 10.7GB (sectors 2048..20971519).
The closest location we can manage is 1049kB to 3000MB (sectors 2048..5859327).
Is this still acceptable to you?
Yes/No? Yes
(parted) p
Model: VMware Virtual NVMe Disk (nvme)
Disk /dev/nvme0n2: 10.7GB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags:

Number  Start   End     Size    Type     File system     Flags
 1      1049kB  3000MB  2999MB  primary  linux-swap(v1)  swap
 2      3000MB  6000MB  3000MB  primary
 3      6000MB  10.0GB  4000MB  primary

[preetam@rhelgui ~]$ sudo mkswap /dev/nvme0n2p1
Setting up swapspace version 1, size = 2.8 GiB (2998923264 bytes)
no label, UUID=23e8fb36-4e0e-4ece-b1ef-1e9a2a9a9509

# list devices

[preetam@rhelgui ~]$ sudo lsblk --fs
NAME          FSTYPE      FSVER            LABEL                    UUID                                   FSAVAIL FSUSE% MOUNTPOINTS
sr0           iso9660     Joliet Extension RHEL-9-3-0-BaseOS-x86_64 2023-10-25-09-17-25-00
nvme0n1
├─nvme0n1p1   vfat        FAT32                                     6FE2-3FF4                               591.8M     1% /boot/efi
├─nvme0n1p2   xfs                                                   fa64d359-0d13-4b12-ab89-a126beaebbad    562.4M    41% /boot
└─nvme0n1p3   LVM2_member LVM2 001                                  vSxDbr-gvI0-PbqP-m5MW-S5wR-W1qt-pQQJb9
  ├─rhel-root xfs                                                   25db91be-fd78-46e8-b301-ac69916c6e4e      7.7G    53% /
  └─rhel-swap swap        1                                         fb00e800-59a6-42d6-8102-554dd1e19ce8                  [SWAP]
nvme0n2
├─nvme0n2p1   swap        1                                         23e8fb36-4e0e-4ece-b1ef-1e9a2a9a9509 # new swap partition
├─nvme0n2p2
└─nvme0n2p3
nvme0n3
├─nvme0n3p1   xfs                                                   06f17c6b-50e6-4e91-aa4f-086a4e86e805
├─nvme0n3p2   xfs                                                   ddcdfa78-71b3-46e0-b180-6181f28ffe6a
└─nvme0n3p3   xfs                                                   6c944a09-671c-4477-a9bb-9693331ae2bf
# now mount this new swap partition

## lets check what is current swap size

[preetam@rhelgui ~]$ free -mh
               total        used        free      shared  buff/cache   available
Mem:           1.7Gi       1.4Gi       221Mi       184Mi       429Mi       319Mi
Swap:          2.0Gi       691Mi       1.3Gi

# The current swap size is 2.0Gi

# Now lets mount the partition
[preetam@rhelgui ~]$ sudo swapon /dev/nvme0n2p1

### Lets check if the swap size is changed.
[preetam@rhelgui ~]$ free -mh
               total        used        free      shared  buff/cache   available
Mem:           1.7Gi       1.4Gi       216Mi       184Mi       431Mi       316Mi
Swap:          4.8Gi       690Mi       4.1Gi # you can see it is changed from 2 to 2.8 Gi

### 03-Add Entry in fstab
/dev/mapper/rhel-root   /                       xfs     defaults        0 0
UUID=fa64d359-0d13-4b12-ab89-a126beaebbad /boot                   xfs     defaults        0 0
UUID=6FE2-3FF4          /boot/efi               vfat    umask=0077,shortname=winnt 0 2
/dev/mapper/rhel-swap   none                    swap    defaults        0 0
UUID=23e8fb36-4e0e-4ece-b1ef-1e9a2a9a9509	swap	swap		pri=100		0 0 # important is pri=100

sudo systemctl daemon-reload
sudo swapon --show

[preetam@rhelgui ~]$ sudo swapon -s
Filename				Type		Size		Used		Priority
/dev/dm-1                               partition	2097148		0		-2
/dev/nvme0n2p1                          partition	2928636		0		100

