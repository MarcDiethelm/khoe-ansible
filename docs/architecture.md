## WIP: Architecture

### Changing state

To do: Users communicate with the Khoe application (Ansible playbooks) though a web server (khoe-frontend). Examples are changes to the application state, e.g. adding/removing users and shares. The web server executes the relevant Ansible playbooks through shell commands. The khoe-nas application manages creation/removal of the resources and is the authoritative source of state. Data is passed to `ansible-playbook` using command line arguments (simple key/value or JSON strings). Until successful playbook execution state change is confirmed (via exit code), the resource model is in a state of limbo in the frontend. On successful completion khoe-frontend may then read the config files to refresh its resource models.

## References

* ansible-playbook exit codes
  https://github.com/ansible/ansible/blob/devel/bin/ansible
  https://groups.google.com/forum/#!topic/ansible-project/TZUToE_vYdA
  https://www.systutorials.com/docs/linux/man/1-ansible-playbook/
