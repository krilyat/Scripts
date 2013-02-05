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

SyncFiles() {
savebase="/home/ben/.mao"
files_not_to_sync="\
/etc/fstab \
/etc/security/limits.conf \
/etc/security/limits.d/99-audio.conf \
/etc/sysctl.conf \
/usr/share/awesome/themes/back.jpg \
/etc/X11/xorg.conf.d/20-intel.conf \
/etc/pam.d/su"

for files in $files_not_to_sync ;do
    chattr +d $files
    mkdir -p "${savebase}/$(dirname $files)"
    cp -fp ${mount_point}$files ${savebase}/$files
done


$_xfsdump $initial_device | $_xfsrestore $mount_point
}
EarlyDeleteFiles() {

early_delete="\
/var/lib/pacman"

echo -ne "\n\n\t Deleting unnecessary files\n\n"
cd $mount_point
for dfiles in $early_delete ;do
    rm -Rf ${mount_point}/${dfiles}
done

}
LateDeleteFiles() {
late_delete="\
/etc/systemd/system/multi-user.target.wants/rpcbind.service \
/etc/systemd/system/multi-user.target.wants/dhcpcd@eth0.service \
/etc/systemd/system/multi-user.target.wants/ntpd.service \
/var/cache/pacman/pkg/ \
/etc/systemd/system/multi-user.target.wants/sshd.service"

echo -ne "\n\n\t Deleting unnecessary files\n\n"
cd $mount_point
for dfiles in $late_delete ;do
    rm -Rf ${mount_point}/${dfiles}
done
}

mount $device_to_sync $mount_point
EarlyDeleteFiles
SyncFiles
LateDeleteFiles

sleep 10
set -x
lsof | grep /tmp/

umount $mount_point
RET=$?
lsof | grep $mount_point
if [ $RET -eq "0" ] ;then
    rmdir $mount_point
fi 
