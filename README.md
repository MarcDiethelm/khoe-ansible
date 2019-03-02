Khoe Cloud
===

This project is for people who want to **self-host an easy to use personal cloud** at home or at a small business **with default settings that just work**, while leaving the door open for customisation.

On a more philosophical level this project exists because **digital privacy and data security should be simple and universally affordable**. Which can be made a reality by bringing the open source tools already used in professional cloud and server environments into your home and office by taking care of the complex configuration those tools need. Convenience without sacrificing essential security.

Khoe currently offers:

- NAS
- encrypted remote backups
- data recovery USB key

On top of this foundation myriad useful cloud services can be built.

Right now the project is in an early stage and is not yet suited for your typical grandparent. Instead the ideal early adopter is someone with some knowledge of Linux systems, Ansible, Samba, etc. Khoe uses **Ansible** to set up and maintain a personal cloud server.

## The good stuff
- Hardware independent. If it can run Linux it probably can run Khoe.
- Concise command line API, which abstracts away the complexities of the underlying tools like Samba, GnuPG, Duplicity, eCryptFS and so on.
- Network shares are visible in network browsers (except Windows 10).
- Network shares are Apple Time Machine compatible.
- Share permissions are backed by real Linux users and file system permissions (soon: and support simple multi-user file sharing.)
- Simple setup of backup profiles for network shares using Duply/Duplicity.
  - Easy configuration of remote backup destination for a backup profile.
  - Easy setup of cronjobs for automated backups.
  - Multiple profiles possible per share, with individual backup file lists.
- Disaster recovery of users and their setups from encrypted data on a USB key. USB drive may be FAT32 for additional storage use.
- Automatic encryption key creation for each user using gnupg


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
git clone --branch develop https://github.com/MarcDiethelm/khoe-ansible.git ansible
cd ansible && ./install.sh
```
Then enter `khoe` user's password once, when `sudo` asks for it.

`install.sh` sets up passwordless `sudo` for the `khoe` user, installs Ansible and then uses `ansible-playbook` to set up the server software. After that the system packages are upgraded and the server will reboot if needed. The process will take a few minutes.

**After that you should re-login.**


##  Operation

Standard administration of a Khoe server is currently performed by executing `ansible-playbook` commands logged-in as user `khoe` on the server. (This will be replaced with a web frontend.)

**Quick start**: the following command will create a user with default options.

```bash
ansible-playbook playbooks/user.yml -e task=create -e username=example1 -e password=1234
```

Creating a user with Khoe also creates

- a GPG primary key pair and an encryption key pair
- a Samba share (NAS)
- a Duply backup profile for the Samba share

A share can either be created in the users home directory on the boot drive (default) or on a removable drive by specifying a disk label. The share paths are created programmatically from disk label, username and share name and may not be specified. To use existing data with a Khoe share see Migration.
Backup profiles are bound to share directories, since the only way a standard user interacts with Khoe is via Samba shares. (future: likely also restricted rsync.)

## Commands

> Note: You should prepend any command that contain a secret with a space, this way it will not enter bash history.

### User

**Create**
```
ansible-playbook playbooks/user.yml -e task=create -e username=example1 -e "password='1234'" [-e share_name=username] [-e disk_label=label] [-e "smbpassword='2345'"]
```
Create a new user who can own network shares. See NAS for explanation of the optional options.

**Delete**
```
ansible-playbook playbooks/user.yml -e task=delete -e username=example1
```
Deleting a user also deletes their home directory and any data in it. The corresponding Samba user is also deleted.

### Mount

Removable drives need to have a *label* to mount them with Khoe.
To see the labelled drives available on the system: `ls /dev/disk/by-label/`. To see disks mounted by khoe: `pmount`.
`pmount` is used to mount removable drives without changing `/etc/fstab`.

**Create**
```
ansible-playbook playbooks/mount.yml -e task=create -e disk_label=label
```
Mount a removable drive with `label` to `/media/label`. The drive will be re-mounted after a reboot. The label is stored in `config/mounts.yml`.

**Delete**
```
ansible-playbook playbooks/mount.yml -e task=delete -e disk_label=label
```
Unmount a drive with `label` from `/media/label` and remove the label from `config/mounts.yml`.

**Re-mount**
```
ansible-playbook playbooks/mount.yml
```
Re-mount drives that were previously mounted with create.


### NAS shares

Khoe uses Samba to share directories in the local network.

**Create**
```
ansible-playbook playbooks/nas.yml -e task=create -e username=example1 -e smbpassword=1234 [-e share_name=example1] [-e disk_label=label]
```
Creates a new network share and applies `smbpassword` to the user. Shares are automatically started after a reboot.

**Delete**
```
ansible-playbook playbooks/nas.yml -e task=delete -e username=example1 -e share_name=example1
```
Remove the network share. The data and Samba user are not removed.

**Restart**
```
ansible-playbook playbooks/nas.yml
```
(Re-)start all shares


### Backup

To do: documention of

Duplicity time format:  
s, m, h, D, W, M, or Y (indicating seconds, minutes, hours, days, weeks, months, or years

host_vars, backup exclude/include, backup list

Remotes setups: file, S3. More can be added.

```
ansible-playbook playbooks/backup.yml -e task=setup -e username=example1 [-e "passphrase=''"] [-e share_name=username] [-e remote_name=remotename] [-e "backup_list_name='default'"] [-e max_age=1Y] [-e max_fullbkp_age=2M] [-e max_fulls_with_incrs=2]
```

```
ansible-playbook playbooks/backup.yml -e task=backup -e username=example1 [-e share_name=username] [-e remote_name=remotename] [-e "backup_list_name='default'"] [-e dry_run=no]
```

```
ansible-playbook playbooks/backup.yml -e task=restore -e username=example1 [-e share_name=username] [-e remote_name=remotename] [-e "backup_list_name='default'"] [-e age=0D] [-e age=2019-01-23]
```

```
ansible-playbook playbooks/backup.yml -e task=fetch -e username=username -e "fetch_path='dir/filename'" [-e share_name=nas] [-e remote_name=remotename] [-e "backup_list_name='default'"] [-e age=0D] [-e age=2019-01-23]
```

```
ansible-playbook playbooks/backup.yml -e task=create-cronjob -e username=example1 [-e share_name=username] [-e remote_name=remotename] [-e "backup_list_name='default'"] [-e minute=0] [-e hour=4] [-e day=*] [-e month=*] [-e weekday=*] [-e dry_run=no]
```

If set to yes cron starts a backup daily at 04:00 hours.
all backup jobs (on a machine) will run at the same time. bad.  
https://www.ostechnix.com/a-beginners-guide-to-cron-jobs/

```
ansible-playbook playbooks/backup.yml -e task=delete-cronjob -e username=example1 [-e share_name=username] [-e remote_name=remotename] [-e "backup_list_name='default'"]
```

```
ansible-playbook playbooks/backup.yml -e task=status -e username=example1 [-e share_name=username] [-e remote_name=remotename] [-e "backup_list_name='default'"]
```

```
ansible-playbook playbooks/backup.yml -e task=list -e username=example1 [-e share_name=username] [-e remote_name=remotename] [-e "backup_list_name='default'"] [-e age=0D] [-e age=2019-01-23]
```


### Recovery

Writes all information (including encryption keys) needed to recreate a user and their data to a removable drive, e.g. a small USB "key" drive. The data is stored in an encrypted file system using the supplied password. The removable drive itself may be formatted with FAT32 for universal use. It is recommended to carry this key on your person, on your keyring just like your door keys.

**Create**
```
ansible-playbook playbooks/recovery.yml -e task=create -e username=example1 -e password=1234 -e recovery_disk_label=label
```
Note: previous recovery data of the same user is removed.

**Recover**
```
ansible-playbook playbooks/recovery.yml -e task=recover -e username=example1 -e password=1234 -e recovery_disk_label=label
```

The recovery playbook mounts and then unmounts the specified disk automatically without saving the mount config. When the operation completes successfully the drive may be removed immediately.


### GPG

**Import**
```
ansible-playbook playbooks/gpg.yml -e task=import -e username=example1 [-e export_path=~/gpg-export/username]
```

---
move to new doc:

## Migration

To use existing data, e.g. on a removable drive in a Khoe share and enjoy the correct permissions here are some tips.

- Mount the drive using the mount task.
- Create the share and move the data into it.
- Then adjust the owner and group of the moved data with the following commands. The group name should be the same as the user name, e.g. example1

```bash
find /media/disk_label/shares/share_name -user olduser -exec chown example1 {} \;
find /media/disk_label/shares/share_name -group oldgroup -exec chgrp example1 {} \;
find /media/disk_label/shares/share_name -uid 2001 -exec chown example1 {} \;
find /media/disk_label/shares/share_name -gid 2001 -exec chgrp example1 {} \;
```

## Setup normal usage vs. development

Standard administration of a khoe server is currently performed by executing `ansible-playbook` commands logged-in as user `khoe` on the server. (This will be replaced with a web frontend.)

For development however it is much more convenient to fall back to typical Ansible execution from a "control machine", e.g. your personal machine.


## Development

For *remote* development from your work machine some additional steps are required:

**on work machine**

- Install ansible
- Clone the khoe-ansible project to a local workspace
- `ansible-galaxy install -r requirements.yml` (satisfy dependencies; installs to `roles/_galaxy`)
- `sudo easy_install pip && pip install --user passlib` (Mac only, needed for password hashing in user:create task)
- Edit the file `ansible.cfg`: search for `inventory` and un/comment the  development/localhost lines respectively. By default the `localhost` line is uncommented.
- Enter the correct hostname in `inventory/development` [default: khoe.lan].
- Create a file `domain.tld.yml` in `inventory/host_vars` with your remote storage credentials.
