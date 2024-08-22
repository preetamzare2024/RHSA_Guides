
# Step:01 add disks to the VM and check if the disks are visible
[poseidon@serverb ~]$ sudo lsblk -f
NAME          FSTYPE      FSVER            LABEL                    UUID                                   FSAVAIL FSUSE% MOUNTPOINTS
sr0           iso9660     Joliet Extension RHEL-9-3-0-BaseOS-x86_64 2023-10-25-09-17-25-00
nvme0n1
├─nvme0n1p1   vfat        FAT32                                     5D95-E47A                               591.8M     1% /boot/efi
├─nvme0n1p2   xfs                                                   d1207c49-9ec0-4400-96e4-1f94ccf6bcac    668.9M    30% /boot
└─nvme0n1p3   LVM2_member LVM2 001                                  N7OQvZ-wR6W-zoBO-vtGv-clgF-YOL8-crIUAa
  ├─rhel-root xfs                                                   4b7934d2-611c-4b98-a257-8703435af3f7     10.8G    34% /
  └─rhel-swap swap        1                                         e2c97d63-eb5b-4881-8de6-bfe409f14269                  [SWAP]
nvme0n2 # disk1
nvme0n3 # disk2
nvme0n4 # disk3


# Step:02 create a physicak volume of only disk1 and disk2
[poseidon@serverb ~]$ sudo pvcreate /dev/nvme0n2 /dev/nvme0n3
  Physical volume "/dev/nvme0n2" successfully created.
  Physical volume "/dev/nvme0n3" successfully created.
## Check if the physical volume is created. Note, we do not give any name to the physical volume
[poseidon@serverb ~]$ sudo pvs
  PV             VG   Fmt  Attr PSize  PFree
  /dev/nvme0n1p3 rhel lvm2 a--  18.41g     0  # (Zero free space on this disk available to expand)
  /dev/nvme0n2        lvm2 ---  10.00g 10.00g # 100% free space
  /dev/nvme0n3        lvm2 ---  10.00g 10.00g # 100% free space

# Check volume group before creating new volume group
18:27:10_~:$ sudo vgs
  VG   #PV #LV #SN Attr   VSize  VFree
  rhel   1   2   0 wz--n- 18.41g    0

# create volume group, here we need to give name to the volume group
[ 18:32:40_tmp ]:$ -> sudo vgcreate vg_securedb /dev/nvme0n2 /dev/nvme0n3
  Volume group "vg_securedb" successfully created
## check if volume group, we just created
[ 18:32:54_tmp ]:$ -> sudo vgs
  VG          #PV #LV #SN Attr   VSize  VFree
  rhel          1   2   0 wz--n- 18.41g     0
  vg_securedb   2   0   0 wz--n- 19.99g 19.99g # (100% free)

## Create a volumes out of the volume group. e.g. we have VG of 20 GiB
### volume with name lv_logs
sudo lvcreate -n lv_logs -L 2GiB vg_securedb
### volume with name lv_db
sudo lvcreate -n lv_db -L 8GiB vg_securedb

## lets display changed VG
[ 18:46:39_tmp ]:$ -> sudo vgs
  VG          #PV #LV #SN Attr   VSize  VFree
  rhel          1   2   0 wz--n- 18.41g    0
  vg_securedb   2   2   0 wz--n- 19.99g 9.99g

# you can see vg_securedb is reduced to 10g under VFree column

## Now you are ready to create file system on these volumes
### Before that, let me show how the tree is created
[ 19:24:29_tmp ]:$ -> tree  /dev/vg_securedb/
/dev/vg_securedb/
├── lv_db -> ../dm-3
└── lv_logs -> ../dm-2

[ 19:26:12_tmp ]:$ -> sudo mkfs.xfs /dev/vg_securedb/lv_db
# --------- Output Omitted ------------ #

[ 19:26:34_tmp ]:$ -> sudo mkfs.xfs /dev/vg_securedb/lv_logs
# --------- Output Omitted ------------ #
[ 19:26:38_tmp ]:$ -> lsblk -fp
NAME                              FSTYPE      FSVER            LABEL                    UUID                                   FSAVAIL FSUSE% MOUNTPOINTS
/dev/sr0                          iso9660     Joliet Extension RHEL-9-3-0-BaseOS-x86_64 2023-10-25-09-17-25-00
/dev/nvme0n1
├─/dev/nvme0n1p1                  vfat        FAT32                                     5D95-E47A                               591.8M     1% /boot/efi
├─/dev/nvme0n1p2                  xfs                                                   d1207c49-9ec0-4400-96e4-1f94ccf6bcac    668.9M    30% /boot
└─/dev/nvme0n1p3                  LVM2_member LVM2 001                                  N7OQvZ-wR6W-zoBO-vtGv-clgF-YOL8-crIUAa
  ├─/dev/mapper/rhel-root         xfs                                                   4b7934d2-611c-4b98-a257-8703435af3f7     10.8G    34% /
  └─/dev/mapper/rhel-swap         swap        1                                         e2c97d63-eb5b-4881-8de6-bfe409f14269                  [SWAP]
/dev/nvme0n2                      LVM2_member LVM2 001                                  wb1KTo-INg7-Nze6-vx3O-F6Qe-1eVA-vAKeqz
└─/dev/mapper/vg_securedb-lv_logs xfs                                                   fd9706db-876f-4be7-ab8f-37be2a58040a
/dev/nvme0n3                      LVM2_member LVM2 001                                  hpfTUX-ReVD-EqK9-YK3H-Y4hx-cyyH-VyYk83
└─/dev/mapper/vg_securedb-lv_db   xfs                                                   13c195fb-c561-47a8-b0cc-eae90d30c170
/dev/nvme0n4

# In the above output you do not see the size of the volumes, so just type lsblk without options
# Interesting observation, 8 GB is created on Disk2 and 2 GB is created on Disk1
[ 19:28:43_tmp ]:$ -> lsblk
NAME                  MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sr0                    11:0    1  9.8G  0 rom
nvme0n1               259:0    0   20G  0 disk
├─nvme0n1p1           259:1    0  600M  0 part /boot/efi
├─nvme0n1p2           259:2    0    1G  0 part /boot
└─nvme0n1p3           259:3    0 18.4G  0 part
  ├─rhel-root         253:0    0 16.4G  0 lvm  /
  └─rhel-swap         253:1    0    2G  0 lvm  [SWAP]
nvme0n2               259:4    0   10G  0 disk
└─vg_securedb-lv_logs 253:2    0    2G  0 lvm
nvme0n3               259:5    0   10G  0 disk
└─vg_securedb-lv_db   253:3    0    8G  0 lvm
nvme0n4               259:6    0   15G  0 disk

# Increase  the logs size by 2 GiB
sudo lvresize -L +2GiB -r /dev/vg_securedb/lv_logs

## check the change
sudo lvs
  LV      VG          Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root    rhel        -wi-ao---- 16.41g
  swap    rhel        -wi-ao----  2.00g
  lv_db   vg_securedb -wi-ao----  8.00g
  lv_logs vg_securedb -wi-ao----  4.00g

# Here we increased the logical volume size because there was space available on volume group

# Increase Volume Group.
# Steps

## create a physical volume using the following command
sudo pvcreate /dev/diskname

## add physical volume to the volume group
sudo vgextend vg_securedb /dev/nvme0n4

## you can evacuate disks e.g. moving data out of disk1 to disk3

[ 08:20:24_Documents ]:$ -> sudo pvs
  PV             VG          Fmt  Attr PSize   PFree
  /dev/nvme0n1p3 rhel        lvm2 a--   18.41g      0
  /dev/nvme0n2   vg_securedb lvm2 a--  <10.00g      0
  /dev/nvme0n3   vg_securedb lvm2 a--  <10.00g      0
  /dev/nvme0n4   vg_securedb lvm2 a--  <15.00g <15.00g

# move data from disk2, in this case OS decides where to move the data
[ 08:20:28_Documents ]:$ -> sudo pvmove /dev/nvme0n2
  /dev/nvme0n2: Moved: 2.77%
  /dev/nvme0n2: Moved: 40.02%
  /dev/nvme0n2: Moved: 80.07%
  /dev/nvme0n2: Moved: 100.00%
# check how the data is spread across, you can see all data is moved to nvme0n4 from nvme0n2
[ 08:24:23_Documents ]:$ -> sudo pvs
  PV             VG          Fmt  Attr PSize   PFree
  /dev/nvme0n1p3 rhel        lvm2 a--   18.41g      0
  /dev/nvme0n2   vg_securedb lvm2 a--  <10.00g <10.00g
  /dev/nvme0n3   vg_securedb lvm2 a--  <10.00g      0
  /dev/nvme0n4   vg_securedb lvm2 a--  <15.00g   5.00g

# remove the disk from volume group using vgreduce

[ 08:24:26_Documents ]:$ -> sudo vgreduce vg_securedb /dev/nvme0n2
  Removed "/dev/nvme0n2" from volume group "vg_securedb"

# check if the disk is showing 100% free
[ 08:26:54_Documents ]:$ -> sudo pvs
  PV             VG          Fmt  Attr PSize   PFree
  /dev/nvme0n1p3 rhel        lvm2 a--   18.41g     0
  /dev/nvme0n2               lvm2 ---   10.00g 10.00g
  /dev/nvme0n3   vg_securedb lvm2 a--  <10.00g     0
  /dev/nvme0n4   vg_securedb lvm2 a--  <15.00g  5.00g

# finally remove the disk from physical volume
[ 08:27:01_Documents ]:$ -> sudo pvremove /dev/nvme0n2
  Labels on physical volume "/dev/nvme0n2" successfully wiped.

# ------------------- clean everything --------------------------#

# first remove logical volume from volume group

## 1 ----> check the current volume group status
[ 18:12:17_~ ]:$ -> sudo vgs
  VG          #PV #LV #SN Attr   VSize  VFree
  rhel          1   2   0 wz--n- 18.41g     0
  vg_securedb   2   2   0 wz--n- 59.99g 41.99g

## 2 ----> remove the logical volume using lvremove. Just remember the format, it is same format
# we use to mount the logical volume.
[ 18:13:30_~ ]:$ -> sudo lvremove vg_securedb/lv_logs
Do you really want to remove active logical volume vg_securedb/lv_logs? [y/n]: y
  Logical volume "lv_logs" successfully removed.

## 3 ----> remove the second logical volume using lvremove
[ 18:13:56_~ ]:$ -> sudo lvremove vg_securedb/lv_db
Do you really want to remove active logical volume vg_securedb/lv_db? [y/n]: y
  Logical volume "lv_db" successfully removed.

## compare vgs with the step 1
[ 18:14:18_~ ]:$ -> sudo vgs
  VG          #PV #LV #SN Attr   VSize  VFree
  rhel          1   2   0 wz--n- 18.41g     0
  vg_securedb   2   0   0 wz--n- 59.99g 59.99g

