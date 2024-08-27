# Purpose: Small guide to help me remember how to expand the disk on linux vm

Date: 22.08.2024

**Scenario**: You have VM deployed on a hypervisor. You wish to expand the disk size and this disk is part of logical volume

## Little explaination

- There are three main terms used in LVM
  - Physical volume. Remember this as raw disk.
  - Volume Group. Group of disks. You need to define a name for the group.
  - Logical Volume. This is volume carved out of Volume Group. In other words, logical Volume is always a part of Volume Group.

You always start