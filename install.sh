#!/usr/bin/env bash

# This script is used to set up Ansible and dependencies on the server and is run on the server not on a development machine.
# The idea is to do as little as possible, but as much as needed in this script.

scriptpath=$(dirname $(realpath $0))
#source $scriptpath/env.template

printf '\n%s\n' "Running install/passwordless-sudo.sh."
$scriptpath/scripts/passwordless-sudo.sh

printf '\n%s\n' "Running install/install-ansible.sh."
$scriptpath/scripts/install-ansible.sh

printf '\n%s\n' "Installing playbook dependencies from Ansible Galaxy."
# ./ansible.cfg sets roles_path
ansible-galaxy install -r requirements.yml

printf '\n%s\n' "Installing programs and config files."
ansible-playbook $scriptpath/playbooks/install.yml

# https://github.com/ansible/ansible-examples/blob/master/language_features/ansible_pull.yml
# ansible-pull # need to check it out!

printf '\n%s\n%s\n' "Installation complete." "Quickstart: 'ansible-playbook playbooks/user.yml -e task=create -e username=<example1> -e password=<1234> [-e share_path=/home/example1/nas] [-e smbpassword=<2345>]'."
