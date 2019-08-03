#!/usr/bin/env bash

# This script is used to install Ansible and download the latest Khoe NAS on the server.

set -eo pipefail

install_base_path=/usr/local/lib/khoe-nas/versions

printf '\n%s\n' "Installing Ansible"
sudo apt-add-repository --yes ppa:ansible/ansible
sudo apt-get update
export DEBIAN_FRONTEND=noninteractive
sudo -E apt-get install --yes \
    software-properties-common \
    ansible \
    python-jmespath \
	jq # for parsing versions.json


# Dev: `bash bootstrap.sh no-autoinstall` exits the script here.
# prevents downloading and installing latest published version
if [ "$1" == "no-autoinstall" ]
then
	printf '\n%s\n' "No auto-install requested. Exiting."
	exit 0
fi

# Github sorts the tags correctly (by tag not by date)
# therefore we can use the first element from versions array
# using https://stedolan.github.io/jq/
versions=`curl https://api.github.com/repos/khoe-cloud/khoe-nas/tags`

latest=`echo $versions      | jq '.[0] | .name'        | tr -d \"`
tarball_url=`echo $versions | jq '.[0] | .tarball_url' | tr -d \"`
version=$latest

printf '\n%s\n' "Downloading khoe-nas: $version"
install_path=$install_base_path/$version
sudo mkdir -p $install_path

# Wget download to stdout and pipe into untar, controlling the extracted dir name
sudo bash -c "wget $tarball_url -O - | tar -xz --directory=$install_path --strip-components 1"
printf '%s\n' "Saved to: $install_path"

cd $install_path
printf '\n%s\n' "Running $install_path/install.sh"
bash $install_path/install.sh
