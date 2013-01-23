#!/bin/bash

if [ $(id -u) -ne "0" ] ;then
    echo "il faut être root pour lancer ce script"
    exit 2
fi

_xfsdump="/usr/sbin/xfsdump -e -J -"
_xfsrestore="/usr/sbin/xfsrestore -J -"

initial_device="/dev/sda2"
device_to_sync="/dev/sda3"
mount_point=$(mktemp -d)

files_not_to_sync="\
/etc/fstab \
/etc/security/limits.conf \
/etc/sysctl.conf \
/usr/share/awesome/themes/back.jpg \
/etc/pam.d/su \
/etc/systemd/system/multi-user.target.wants/rpcbind.service \
/etc/systemd/system/multi-user.target.wants/sshd.service"

for i in $files_not_to_sync ;do
    chattr +d $i
done

mount $device_to_sync $mount_point

$_xfsdump $initial_device | $_xfsrestore $mount_point

umount $mount_point
if [ $? -eq "0" ] ;then
    rmdir $mount_point
fi 
