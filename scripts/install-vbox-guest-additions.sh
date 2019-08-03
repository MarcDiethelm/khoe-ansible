#!/usr/bin/env sh

# run with shutdown

apt install gcc make perl

mount /dev/cdrom /mnt              # or any other mountpoint
cd /mnt
./VBoxLinuxAdditions.run

usermod -a -G vboxsf $USER

# mount the project here later (if vbox creates the dirs their permissions are wrong)
mkdir -p /usr/local/lib/khoe-nas/versions/dev

umount /dev/cdrom

echo "reboot to complete installation"
