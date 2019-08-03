#!/usr/bin/env sh
set -eo pipefail

# Mount the Guest Additions ISO and run this script in the Ubuntu guest with sudo

apt install gcc make perl

mount /dev/cdrom /mnt
cd /mnt
./VBoxLinuxAdditions.run

# Give access to Virtualbox-mounted shared folders
usermod -a -G vboxsf $USER

# mount the project here later (if vbox creates the dirs their permissions are wrong)
mkdir -p /usr/local/lib/khoe-nas/versions/dev

umount /dev/cdrom

echo "reboot to complete installation"
