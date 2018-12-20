#!/usr/bin/env bash

scriptpath=$(dirname $(realpath $0))
#source $scriptpath/env.template

printf '\n%s\n' "Setting permissions."
chmod +x \
  $scriptpath/install/passwordless-sudo.sh \
  $scriptpath/install/install-ansible.sh \

printf '\n%s\n' "Running install/passwordless-sudo.sh."
$scriptpath/install/passwordless-sudo.sh

printf '\n%s\n' "Running install/install-ansible.sh."
$scriptpath/install/install-ansible.sh

printf '\n%s\n' "Installing playbook dependencies from Ansible Galaxy."
ansible-galaxy install -r requirements.yml

printf '\n%s\n' "Installing command line dependencies and config files."
ansible-playbook $scriptpath/playbooks/install.yml

# https://github.com/ansible/ansible-examples/blob/master/language_features/ansible_pull.yml
# ansible-pull # need to check it out!

printf '\n%s\n%s\n' "You need to edit configuration files in `config/` before continuing." "Then execute 'ansible-playbook $scriptpath/[playbook name].yml'."
#printf '\n%s\n' "Running ansible-playbook khoe.yml."
#ansible-playbook khoe.yml
