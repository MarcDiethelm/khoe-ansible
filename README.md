Khoe Cloud server administration with Ansible
===

This project is for people who want to **self-host a personal cloud** at home or at a small business. The project goal is to create truly useful hardware independent services with **default settings that just work**, but also leaving the door open for extensive customization.

On a more philosophical level **this project exists because digital privacy should be easy and inexpensive**. This goal can be made a reality by bringing the opensource tools already used in professional cloud and server environments into your home and office.

Khoe uses Ansible to configure a personal cloud server.

The poject is in an early stage and is not yet suited for your typical grandma or grandpa, instead the ideal early adopter is someone with some knowledge of Linux systems, **Ansible**, Samba, etc.

## Prerequisites

- A Ubuntu Server 18.04 LTS install. A fresh install is recommended.
- Create a standard user with username `khoe`.

> If you want khoe running on different distros, PRs are welcome of course. But presently I will only support Ubuntu. Debian is under consideration, PRs for it would be very welcome.

The following assumes `khoe.lan` as the server's hostname in the local network.

Getting your ssh keys on the server (if not done during Ubuntu install.) On your computer:

```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub khoe@khoe.lan
```
  

## Install

**Log in to server**
 
 ```bash
 ssh khoe.lan
 ```

**Server**

To do: update this for releases / Github.

```bash
git clone --branch develop https://gitlab.com/marcdiethelm/khoe-ansible.git ansible
cd ansible
./install.sh
```
Enter `khoe` user's password.

`install.sh` sets up passwordless `sudo` for the `khoe` user, installs Ansible and then uses `ansible-playbook` to set up the server software. After that the system packages are upgraded and the server will reboot if needed. The process will take a few minutes.


##  Operation

Creating a user with Khoe also creates

- a set of GPG keys for encryption
- a Samba share (NAS)
- a Duply backup profile for the Samba share

```bash
ansible-playbook playbooks/user.yml -e task=create -e username=<example1> -e password=<1234> [-e share_path=/home/example1/nas] [-e smbpassword=<1234>]
```


## Setup normal usage vs. development

Standard administration of a khoe server is currently performed by executing `ansible-playbook` commands logged-in as user `khoe` on the server. (This will be replaced with a web frontend.)

For development however it is much more convenient to fall back to typical Ansible execution from a "control machine", e.g. your personal machine.


## Development

For *remote* development from your work machine some additional steps are required:

**on work machine**

- Install ansible
- Clone the khoe-ansible project to a local workspace
* `ansible-galaxy install -r requirements.yml` (satisfy dependencies; installs to `roles/_galaxy`)
* `sudo easy_install pip && pip install --user passlib` (Mac only, needed for password hashing in user:create task)
- Edit the file `ansible.cfg`: search for `inventory` and un/comment the  development/localhost lines respectively. By default the `localhost` line is uncommented.
* Enter the correct hostname in `inventory/development` [default: khoe.lan].
