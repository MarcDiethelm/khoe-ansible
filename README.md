Khoe Cloud server administration with Ansible
===


## Setup

Adjust ansible.cfg `inventory` line to switch between local ansible commands on server (default) and remote ansible calls (development).


## Install vs. Operations

* `cd` to this directory.
* `./install.sh`.
* Edit configuration files in `config/`.
* Run `ansible-playbook khoe.yml` to start cloud operation.



## Development

Administering Khoe is done directly on the Khoe server. However initially it may be more convenient to execute the playbook remotely from the development environment.

For *remote* development you need to configure some additional values:

* Target host in `development` inventory, in the project root directory.
* `roles_path` in ansible.cfg: path to installed Ansible Galaxy dependencies.

However once SMB is up and running you can develop directly on the server, which should simplify things. By default the khoe home directory of the server is shared as `dev`.
