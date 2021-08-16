# Fix NTFS Mounts in linux

`BASH` script that fixes NTFS mounts that have become `READ-ONLY` on Linux.

## Dependencies

The script uses `ntfs-3g` and `ntfsfix`.

## Usage
```
Usage: fix-ntfs.sh <mount_source> <mount_target>

Options:
  <mount_source>  The device to fix, e.g. /dev/sda1
  <mount_target>   The directory to mount to, e.g. /mnt/my_drive
```

## Overview

The script will unmount, fix and remount the drive in `READ-WRITE` mode. If there are running processes that will prevent the drive from unmounting, the script will offer to kill them.

