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


## Architecture

### Changing state

Users communicate with the Khoe application (khoe-ansible) though a web server (khoe-frontend). Examples are changes to the application state, e.g. adding/removing users and shares. The web server executes the relevant Ansible playbooks through the system shell. The khoe-ansible application manages creation/removal of the resources and is the authoritative source of state. Data is passed to `ansible-playbook` using command line arguments (simple key/value or JSON strings). Until successful playbook execution state change is confirmed (via exit code), the resource model is in a state of limbo in the frontend. On successful completion khoe-frontend may then read the config files to refresh its resource models.

## References

* ansible-playbook exit codes
  https://github.com/ansible/ansible/blob/devel/bin/ansible
  https://groups.google.com/forum/#!topic/ansible-project/TZUToE_vYdA
  https://www.systutorials.com/docs/linux/man/1-ansible-playbook/
