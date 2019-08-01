#!/usr/bin/env bash

# This script is used to set up Ansible and dependencies on the server and is run on the server not on a development machine.
# The idea is to do as little as possible, but as much as needed in this script.

# ./ansible.cfg sets roles_path for ansible-galaxy installs (first writeable directory in list)
# ./ansible.cfg sets inventory path

scriptpath=$(dirname $(realpath $0))
khoe_nas_path=/usr/local/lib/khoe-nas/current
khoe_user='khoe'

export KHOE_NAS_PATH=$khoe_nas_path

printf '\n%s\n' "Running scripts/passwordless-sudo.sh." && \
$scriptpath/scripts/passwordless-sudo.sh $khoe_user && \ # todo: do this with ansible
\
sudo chown 700 $scriptpath/ansible.cfg && \
\
printf '\n%s\n' "Installing playbook dependencies from Ansible Galaxy." && \
ansible-galaxy install -r requirements.yml && \
\
printf '\n%s\n' "Setting system, installing khoe-nas dependencies and config files." && \
ansible-playbook $scriptpath/playbooks/install.yml && \
\
printf '\n%s\n' "Symlinking source: $scriptpath to link: $khoe_nas_path" && \
sudo rm -f $khoe_nas_path && \
sudo ln -s $scriptpath $khoe_nas_path && \
\
cat <<DOC
Installation complete.

Quickstart:

To mount a removable drive:
ansible-playbook playbooks/mount.yml -e task=create -e disk_label=label

To create a user with a NAS share:
ansible-playbook playbooks/user.yml -e task=create -e username=example1 -e "password='1234'" [-e share_name=username] [-e disk_label=label] [-e "smbpassword='2345'"]
DOC
