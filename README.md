Khoe Cloud server administration with Ansible
===

## Prerequisites

Assuming `khoe.lan` as server hostname.

### local
  - `ssh-copy-id -i /Users/marcd/.ssh/id_rsa.pub khoe@khoe.lan`
  - `ssh khoe.lan`
### server
  - `git clone https://gitlab.com/marcdiethelm/khoe-ansible.git ansible`
  - `cd ansible`
  - `git pull origin develop`


## Setup

Adjust ansible.cfg `inventory` line to switch between local ansible commands on server (default) and remote ansible calls (development).


## Install

* `cd` to this directory.
* chmod +x install.sh
* `./install.sh`.
* Edit configuration files in `config/`.

##  Operation

* ~~Run `ansible-playbook khoe.yml` to start cloud operation.~~


## Development

Administering Khoe during normal use is done directly on the Khoe server through local Ansible use. However it may be more convenient to execute the playbook remotely from a development machine.

For *remote* development you need to configure some additional values:

* `ansible-galaxy install -r requirements.yml` (satisfy dependencies; installs to `roles/_galaxy`)
* # Target hostname in `development` inventory, in the project root directory [default: khoe.lan].

However once SMB is up and running you can develop directly on the server, which should simplify things. By default the khoe home directory of the server is shared as `dev`.


## Architecture

### Changing state

Users communicate with the Khoe application (khoe-ansible) though a web server (khoe-frontend). Examples are changes to the application state, e.g. adding/removing users and shares. The web server executes the relevant Ansible playbooks through the system shell. The khoe-ansible application manages creation/removal of the resources and is the authoritative source of state. Data is passed to `ansible-playbook` using command line arguments (simple key/value or JSON strings). Until successful playbook execution state change is confirmed (via exit code), the resource model is in a state of limbo in the frontend. On successful completion khoe-frontend may then read the config files to refresh its resource models.

## References

* ansible-playbook exit codes
  https://github.com/ansible/ansible/blob/devel/bin/ansible
  https://groups.google.com/forum/#!topic/ansible-project/TZUToE_vYdA
  https://www.systutorials.com/docs/linux/man/1-ansible-playbook/
