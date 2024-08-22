
# First we find out about the disks present on the system

$ lsblk
NAME          MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
nvme0n1       259:0    0 238.5G  0 disk # ( only disk available)
├─nvme0n1p1   259:1    0   600M  0 part /boot/efi  # Partition 1
├─nvme0n1p2   259:2    0     1G  0 part /boot # Partition 2
└─nvme0n1p3   259:3    0 236.9G  0 part # Partition 3 (LVM)
  ├─rhel-root 253:0    0    70G  0 lvm  /
  ├─rhel-swap 253:1    0   7.8G  0 lvm  [SWAP]
  └─rhel-home 253:2    0 159.1G  0 lvm  /home

# But above does not show file system type, you get that information using lsblk -f

# you use disk path to print partition information without going into interactive mode
$ sudo parted /dev/nvme0n1 print
Model: KXG50ZNV256G NVMe TOSHIBA 256GB (nvme)
Disk /dev/nvme0n1: 256GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name                  Flags
 1      1049kB  630MB   629MB   fat32        EFI System Partition  boot, esp
 2      630MB   1704MB  1074MB  xfs
 3      1704MB  256GB   254GB                                      lvm

# you can further explore e.g. change the start and End display unit
$ sudo parted /dev/nvme0n1 unit GiB print
Model: KXG50ZNV256G NVMe TOSHIBA 256GB (nvme)
Disk /dev/nvme0n1: 238GiB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start    End      Size     File system  Name                  Flags
 1      0.00GiB  0.59GiB  0.59GiB  fat32        EFI System Partition  boot, esp
 2      0.59GiB  1.59GiB  1.00GiB  xfs
 3      1.59GiB  238GiB   237GiB                                      lvm

