#!/usr/bin/env bash
set -eo pipefail

########################################################################################################################
#
# This script is used to set up Ansible, dependencies and khoe-nas setup.
# (It's used on a server not a development machine.)
# The idea is to do as little as possible, but as much as needed in this script.
#
########################################################################################################################

scriptpath=$(dirname $(realpath $0))
khoe_nas_path=/usr/local/lib/khoe-nas/current
khoe_user='khoe'

export KHOE_NAS_PATH=$khoe_nas_path

printf '\n%s\n' "Running scripts/passwordless-sudo.sh."
$scriptpath/scripts/passwordless-sudo.sh $khoe_user # todo: do this with ansible

if ! [ -x "$(command -v ansible)" ]; then
	printf '\n%s\n' "Installing Ansible"
	sudo apt-add-repository --yes ppa:ansible/ansible
	sudo DEBIAN_FRONTEND=noninteractive \
		apt-get install --yes \
	    software-properties-common \
	    ansible \
	    python-jmespath
fi

printf '\n%s\n' "Installing playbook dependencies from Ansible Galaxy."
# ./ansible.cfg sets roles_path for ansible-galaxy installs (first writeable directory in list)
# The env var prevents `sudo ansible-galaxy` from creating empty config dir/file in ~/ owned by root. This leads to
# permission errors when running playbooks as khoe.
sudo ANSIBLE_LOCAL_TEMP=/tmp ansible-galaxy install -r requirements.yml


# ./ansible.cfg sets inventory path
printf '\n%s\n' "Setting system, installing khoe-nas dependencies and config files."
ansible-playbook $scriptpath/playbooks/install.yml

printf '\n%s\n' "Symlinking source: $scriptpath to link: $khoe_nas_path"
sudo rm -f $khoe_nas_path
sudo ln -s $scriptpath $khoe_nas_path

cat <<DOC
Installation complete.

Quickstart:

To mount a removable drive:
ansible-playbook playbooks/mount.yml -e task=create -e disk_label=label

To create a user with a NAS share:
ansible-playbook playbooks/user.yml -e task=create -e username=example1 -e "password='1234'" [-e share_name=username] [-e disk_label=label] [-e "smbpassword='2345'"]
DOC
