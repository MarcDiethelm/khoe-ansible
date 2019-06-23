
Development
=============

## Setup normal usage vs. development

Standard administration of a khoe server is currently performed by executing `ansible-playbook` commands logged-in as user `khoe` on the server. (This will be replaced with a web frontend.)

For development however it is much more convenient to fall back to typical Ansible execution from a "control machine", e.g. your personal machine.

For *remote* development from your work machine some additional steps are required:

**on work machine**

- Install ansible
- Clone the khoe-ansible project to a local workspace: `git clone --branch develop https://github.com/khoe-cloud/khoe-ansible.git khoe-ansible`
- `ansible-galaxy install -r requirements.yml` (satisfy dependencies; installs to `roles/_galaxy`)
- `sudo easy_install pip && pip install --user passlib` (Mac only, needed for password hashing in user:create task)
- Edit the file `ansible.cfg`: search for `inventory` and un/comment the  development/localhost lines respectively. By default the `localhost` line is uncommented.
- Enter the correct hostname in `inventory/development` [default: khoe.lan].

### Adding backup protocols

To add to the backup protocols supported by Khoe the following files need to be edited:

- `inventory/host_vars/example.yml`
- `roles/duply/tasks/backup.yml`
- `roles/duply/tasks/restore.yml`
- `roles/duply/tasks/fetch.yml`

For testing `[hostname].yml` needs to be amended too.
