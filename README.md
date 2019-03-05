Khoe Cloud
==========

##### Quick links
- [Commands](docs/commands.md)
- [Development](docs/development.md)
- [Data Import and Migration](docs/migration.md)
- [Roadmap](https://github.com/MarcDiethelm/khoe-ansible/projects/2)

This project is for people who want to **self-host an easy to use personal cloud** at home or at a small business **with default settings that just work**, while leaving the door open for customisation.

Khoe currently offers:

- command-line only, but easy to use
- user management
- NAS (network attached storage)
- encrypted remote backups
- data recovery USB key

On top of this foundation myriad useful cloud services can be built.

On a more philosophical level this project exists because **digital privacy and data security should be simple and universally affordable**. Which can be made a reality by bringing the open source tools already used in professional cloud and server environments into your home and office by taking care of the complex configuration those tools need. Convenience without sacrificing essential security.

Right now the project is in an early stage and is not yet suited for consumers. There's no UI yet. Instead the ideal early adopter is someone with some knowledge of Linux systems, Ansible, Samba, GnuPG, etc. Khoe uses [**Ansible**](https://github.com/ansible/ansible) to set up and maintain a personal cloud server.

## The good stuff

- Open-source
- Hardware independent NAS. If it can run Linux it probably can run Khoe.
- Khoe will be able to run on a Banana Pi / Raspberry Pi. (not tested yet!)
- Automatic GnuPG encryption key creation for every user.
- Concise command line API, which abstracts away the complexities of the underlying tools like Samba, GnuPG, Duplicity, eCryptFS and so on.
- Network shares are visible in network browsers (except Windows 10).
- Network shares are Apple Time Machine compatible.
- Share permissions are backed by actual Linux users and file system permissions (soon: and support simple multi-user file sharing.)
- Simple setup of backup profiles for network shares using Duply/Duplicity.
  - Easy configuration of [remote backup](docs/commands.md#option-remotename) destination (S3 storage) for a backup profile.
  - Easy setup of cron jobs for automated backups.
  - Multiple backup profiles with individual file lists possible per share
- Disaster recovery of users and their setups from encrypted data on a USB key. Key may be FAT32 for additional storage use.
- Easy mounting of removable drives.


## Prerequisites

- A Ubuntu Server 18.04 LTS install. A fresh install is recommended.
- Create a standard user with username `khoe`.

> If you want Khoe running on different distros, PRs are welcome of course. But presently I will only support Ubuntu. Debian is under consideration, PRs for it would be very welcome.


### Connecting to the server

To connect to the server using its hostname you'll want to add it to your local DNS and give it a static IP if you can, i.e. on your router. You may need to consult the documentation for your router. Otherwise use IP address assigned by your DHCP server to log in and also connect shares.

The following assumes `khoe.lan` as the server's domain name in the local network. Substitute it with what you're using.

#### SSH

To get [your ssh keys](https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) on the server, if not done during Ubuntu install. On your computer do the following. Or if you don't have `ssh-copy-id`: [see this](https://serverfault.com/a/583659/311594).

```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub khoe@khoe.lan
```


## Install

**Log in to server**

 ```bash
 ssh khoe.lan
 ```

**Get Khoe**

```bash
git clone https://github.com/MarcDiethelm/khoe-ansible.git ansible
cd ansible && ./install.sh
```
Then enter `khoe` user's password once, when `sudo` asks for it.

`install.sh` sets up passwordless `sudo` for the `khoe` user, installs Ansible and then uses `ansible-playbook` to set up the server software. After that the system packages are upgraded and the server will reboot if needed. The process will take a few minutes.

**After that you should re-login.**


## Operation

Standard administration of a Khoe server is currently performed by executing `ansible-playbook` [commands](docs/commands.md) logged-in as user `khoe` on the server. (This will be replaced with a web frontend.)

**Quick start**: the following command will create a user with default options.

```bash
ansible-playbook playbooks/user.yml -e task=create -e username=example1 -e password=1234
```

Creating a user with Khoe also creates

- a GPG primary key pair and an encryption key pair
- a Samba share (NAS)
- a Duply backup profile for the Samba share

A share can either be created in the users home directory on the boot drive (default) or on a removable drive by specifying a disk label. The share paths are created programmatically from disk label, username and share name and may not be specified. To use existing data with a Khoe share see [Data Import and Migration](docs/migration.md).
Backup profiles are bound to share directories, since the only way a standard user interacts with Khoe is via Samba shares. (future: likely also restricted rsync.)

See [Commands](docs/commands.md) for in-depth usage documentation.
