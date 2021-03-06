#!/usr/bin/env bash
set -eo pipefail

########################################################################################################################
#
# Download this script to fetch the latest Khoe NAS software from Github and place it in $install_base_path/$version
# Once khoe-nas is present, just run install.sh.
#
########################################################################################################################

install_base_path=/usr/local/lib/khoe-nas/versions


# Dev: `bash bootstrap.sh` exits the script here.
if [ -z "$1" ]
then
	printf '\n%s\n' "No auto-install requested. Exiting."
	exit 0
fi

# `bash bootstrap.sh latest` installs the highest tagged version from Github.
if [ "$1" == "latest" ]
then
	if ! [ -x "$(command -v jq)" ]; then
		sudo apt-get install jq # for parsing versions.json
	fi

	# Github sorts the tags correctly (by tag not by date)
	# therefore we can use the first element from versions array
	# using https://stedolan.github.io/jq/
    # NOTE: using pre-release tags (e.g. alpha, beta) will break this
	versions=`curl https://api.github.com/repos/khoe-cloud/khoe-nas/tags`

	latest=`echo $versions      | jq '.[0] | .name'        | tr -d \"`
	tarball_url=`echo $versions | jq '.[0] | .tarball_url' | tr -d \"`
	version=$latest
fi

# `bash bootstrap.sh develop` installs the current state of the develop branch from Github.
if [ "$1" == "develop" ]
then
	tarball_url="https://github.com/khoe-cloud/khoe-nas/archive/develop.tar.gz"
	version="develop"
fi


printf '\n%s\n' "Downloading khoe-nas: $version"
install_path=$install_base_path/$version
sudo rm -rf $install_path
sudo mkdir -p $install_path

# Wget download to stdout and pipe into untar, controlling the extracted dir name
sudo bash -c "wget $tarball_url -O - | tar -xz --directory=$install_path --strip-components 1"
printf '%s\n' "Saved to: $install_path"

cd $install_path
printf '\n%s\n' "Running $install_path/install.sh"
bash $install_path/install.sh
