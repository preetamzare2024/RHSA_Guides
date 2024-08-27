
# Logical Volume Tutorial

## Step:01 add disks to the VM and check if the disks are visible

```bash
[poseidon@serverb ~]$ sudo lsblk -f
NAME          FSTYPE      FSVER            LABEL                    UUID                                   FSAVAIL FSUSE% MOUNTPOINTS
sr0           iso9660     Joliet Extension RHEL-9-3-0-BaseOS-x86_64 2023-10-25-09-17-25-00
nvme0n1
├─nvme0n1p1   vfat        FAT32                                     5D95-E47A                               591.8M     1% /boot/efi
├─nvme0n1p2   xfs                                                   d1207c49-9ec0-4400-96e4-1f94ccf6bcac    668.9M    30% /boot
└─nvme0n1p3   LVM2_member LVM2 001                                  N7OQvZ-wR6W-zoBO-vtGv-clgF-YOL8-crIUAa
  ├─rhel-root xfs                                                   4b7934d2-611c-4b98-a257-8703435af3f7     10.8G    34% /
  └─rhel-swap swap        1                                         e2c97d63-eb5b-4881-8de6-bfe409f14269                  [SWAP]
nvme0n2 # <-- disk1
nvme0n3 # <-- disk2
nvme0n4 # disk3
```

## Step:02 - Create a physical volume of only disk1 and disk2 using pvcreate

```bash

[poseidon@serverb ~]$ sudo pvcreate /dev/nvme0n2 /dev/nvme0n3
  Physical volume "/dev/nvme0n2" successfully created.
  Physical volume "/dev/nvme0n3" successfully created.

```

Check if the physical volume is created. Note, we do not give any name to the physical volume

```bash
[poseidon@serverb ~]$ sudo pvs
  PV             VG   Fmt  Attr PSize  PFree
  /dev/nvme0n1p3 rhel lvm2 a--  18.41g     0  # (Zero free space on this disk available to expand)
  /dev/nvme0n2        lvm2 ---  10.00g 10.00g # 100% free space
  /dev/nvme0n3        lvm2 ---  10.00g 10.00g # 100% free space
```

Check volume group before creating new volume group. There is one single volume group, which we will not touch.

```bash
18:27:10_~:$ sudo vgs
  VG   #PV #LV #SN Attr   VSize  VFree
  rhel   1   2   0 wz--n- 18.41g    0
```

## Step: 03 - Create volume group, here we need to give name to the volume group

```bash
[ 18:32:40_tmp ]:$ -> sudo vgcreate vg_securedb /dev/nvme0n2 /dev/nvme0n3
  Volume group "vg_securedb" successfully created
```

Check if the volume group, we just created is there.

```bash
[ 18:32:54_tmp ]:$ -> sudo vgs
  VG          #PV #LV #SN Attr   VSize  VFree
  rhel          1   2   0 wz--n- 18.41g     0
  vg_securedb   2   0   0 wz--n- 19.99g 19.99g # (100% free)
```

## Step: 04 - Create a volumes out of the volume group. e.g. we have VG of 20 GiB

### Create Volume with name lv_logs

`sudo lvcreate -n lv_logs -L 2GiB vg_securedb`

### volume with name lv_db

`sudo lvcreate -n lv_db -L 8GiB vg_securedb`

Lets display the changed VG

```bash
[ 18:46:39_tmp ]:$ -> sudo vgs
  VG          #PV #LV #SN Attr   VSize  VFree
  rhel          1   2   0 wz--n- 18.41g    0
  vg_securedb   2   2   0 wz--n- 19.99g 9.99g # <-- Volume group free space is reduced
```

You can see vg_securedb is reduced to 10g under VFree column. Now, you are ready to create file system on these volumes. Before that, let me show how the Dir structure is created

```bash
[ 19:24:29_tmp ]:$ -> tree  /dev/vg_securedb/
/dev/vg_securedb/
├── lv_db -> ../dm-3
└── lv_logs -> ../dm-2
```

The above Dir structure should be used to create volumes

```bash
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

```

In the above output you do not see the size of the volumes, so just type lsblk without options. 
> Interesting observation, 8 GB is created on Disk2 and 2 GB is created on Disk1

```bash
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
```

### Increase the logs size by 2 GiB

Here -L is --size and -r is --resizefs (or you have to resize fs separately using `resizetofs` or `xfs_growfs`)

`sudo lvresize -L +2GiB -r /dev/vg_securedb/lv_logs`

```bash
## check the change

sudo lvs
  LV      VG          Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root    rhel        -wi-ao---- 16.41g
  swap    rhel        -wi-ao----  2.00g
  lv_db   vg_securedb -wi-ao----  8.00g
  lv_logs vg_securedb -wi-ao----  4.00g

```

Here we increased the logical volume size because there was space available on volume group. 

But then how about, when the the Volume Group is full. Now, lets use disk4 for this.

## Steps to expand volume group

### Step:01 - Create a physical volume using the following command

`sudo pvcreate /dev/nvme0n4`

#### Add physical volume to the volume group

`sudo vgextend vg_securedb /dev/nvme0n4`

You can evacuate disks e.g. moving data out of disk1.

```bash

[ 08:20:24_Documents ]:$ -> sudo pvs
  PV             VG          Fmt  Attr PSize   PFree
  /dev/nvme0n1p3 rhel        lvm2 a--   18.41g      0
  /dev/nvme0n2   vg_securedb lvm2 a--  <10.00g      0
  /dev/nvme0n3   vg_securedb lvm2 a--  <10.00g      0
  /dev/nvme0n4   vg_securedb lvm2 a--  <15.00g <15.00g
```

Move data from disk2, in this case OS decides where to move the data

```bash

[ 08:20:28_Documents ]:$ -> sudo pvmove /dev/nvme0n2
  /dev/nvme0n2: Moved: 2.77%
  /dev/nvme0n2: Moved: 40.02%
  /dev/nvme0n2: Moved: 80.07%
  /dev/nvme0n2: Moved: 100.00%


Check how the data is spread across, you can see all data is moved to nvme0n4 from nvme0n2

[ 08:24:23_Documents ]:$ -> sudo pvs
  PV             VG          Fmt  Attr PSize   PFree
  /dev/nvme0n1p3 rhel        lvm2 a--   18.41g      0
  /dev/nvme0n2   vg_securedb lvm2 a--  <10.00g <10.00g
  /dev/nvme0n3   vg_securedb lvm2 a--  <10.00g      0
  /dev/nvme0n4   vg_securedb lvm2 a--  <15.00g   5.00g

```

#### Remove the disk from volume group using vgreduce

```bash
[ 08:24:26_Documents ]:$ -> sudo vgreduce vg_securedb /dev/nvme0n2
  Removed "/dev/nvme0n2" from volume group "vg_securedb"
```

Check if the disk is showing 100% free

```bash
[ 08:26:54_Documents ]:$ -> sudo pvs
  PV             VG          Fmt  Attr PSize   PFree
  /dev/nvme0n1p3 rhel        lvm2 a--   18.41g     0
  /dev/nvme0n2               lvm2 ---   10.00g 10.00g
  /dev/nvme0n3   vg_securedb lvm2 a--  <10.00g     0
  /dev/nvme0n4   vg_securedb lvm2 a--  <15.00g  5.00g
```

Finally remove the disk from physical volume

```bash
[ 08:27:01_Documents ]:$ -> sudo pvremove /dev/nvme0n2
  Labels on physical volume "/dev/nvme0n2" successfully wiped.
```

------------------- clean everything --------------------------

### First remove logical volume from volume group

#### Step: 1 Check the current volume group status

```bash
[ 18:12:17_~ ]:$ -> sudo vgs
  VG          #PV #LV #SN Attr   VSize  VFree
  rhel          1   2   0 wz--n- 18.41g     0
  vg_securedb   2   2   0 wz--n- 59.99g 41.99g
```

#### Step: 2 Remove the logical volume using lvremove. 

Just remember the format, it is same format. We use to mount the logical volume.

```bash
[ 18:13:30_~ ]:$ -> sudo lvremove vg_securedb/lv_logs
Do you really want to remove active logical volume vg_securedb/lv_logs? [y/n]: y
  Logical volume "lv_logs" successfully removed.
```

#### Step: 3 Remove the second logical volume using lvremove

```bash
[ 18:13:56_~ ]:$ -> sudo lvremove vg_securedb/lv_db
Do you really want to remove active logical volume vg_securedb/lv_db? [y/n]: y
  Logical volume "lv_db" successfully removed.
```

#### Compare vgs with the step 1

```bash
[ 18:14:18_~ ]:$ -> sudo vgs
  VG          #PV #LV #SN Attr   VSize  VFree
  rhel          1   2   0 wz--n- 18.41g     0
  vg_securedb   2   0   0 wz--n- 59.99g 59.99g
```

#### Remove VG

```bash
sudo vgremove vg_securedb
```

```bash
[ poseidon 07:41:42 ~ $ ] sudo pvremove /dev/nvme0n2p3
  Labels on physical volume "/dev/nvme0n2p3" successfully wiped.
[ poseidon 07:42:05 ~ $ ]
```

Finally you can delete the partition and remove the disk