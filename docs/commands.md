Commands
========

##### Quick links
- [User](#user)
- [Mount](#mount)
- [Network shares](#network-shares)
- [Backup](#backup)
  - [Options](#option-formats)
- [Recovery](#recovery)
- [GPG keys](#gpg-keys)

> See [Operation](../README.md#operation) in the README for a short introduction on how the different services go together.

Optional arguments to the commands are indicated with square brackets: `[option=value]`. Most optional arguments have default values which are also documented below.

> Note: You should prepend any command that contain a secret with a space, this way it will not enter bash history. To be sure add:  
`export HISTCONTROL="ignorespace${HISTCONTROL:+:$HISTCONTROL}"` to your .bash_profile


### User

```
ansible-playbook playbooks/user.yml -e task=create -e username=example1 -e "password='1234'" [-e share_name=username] [-e disk_label=label] [-e "smbpassword='2345'"]
ansible-playbook playbooks/user.yml -e task=delete -e username=example1
```

###### Create
Create a new user who can own network shares. See NAS for explanation of the optional arguments.

###### Delete
Deleting a user also deletes their home directory and any data in it. The corresponding Samba user is also deleted.

### Mount

Removable drives need to have a *label* (name) to be mounted by Khoe.
To see the labelled drives available on the system: `ls /dev/disk/by-label/`. To see disks mounted by khoe: `pmount`.
`pmount` is used to mount removable drives without changing `/etc/fstab`.

Note: The disk label must not contain ascii hex codes. E.g. NTFS drives with `\x20` (space).

```
ansible-playbook playbooks/mount.yml -e task=create -e disk_label=label
ansible-playbook playbooks/mount.yml -e task=delete -e disk_label=label
ansible-playbook playbooks/mount.yml
```

###### Create
Mount a removable drive with `label` to `/media/label`. The label is stored in `config/mounts.yml` and the drive will be re-mounted after a reboot.

###### Delete
Unmount a drive with `label` from `/media/label` and remove the label from `config/mounts.yml`.

###### Re-mount
Re-mount drives that were previously mounted with create.


### Network shares

Khoe uses Samba to share directories in the local network. Samba runs in a Docker container (however this may well change to save on memory requirements.)  
Samba's VFS "recycle bin" is disabled, because of its questionable usability. May add option to enable it (per share) if requested.

```
ansible-playbook playbooks/nas.yml -e task=create -e username=example1 -e smbpassword=1234 [-e share_name=example1] [-e disk_label=label]
ansible-playbook playbooks/nas.yml -e task=delete -e username=example1 -e share_name=example1
ansible-playbook playbooks/nas.yml
```

##### Create
Creates a new network share and applies `smbpassword` to the user. Shares are automatically started after a reboot.

###### Delete
Remove the network share. The data and Samba user are not removed.

###### Restart
(Re-)start all shares


### Backup

The backup API is a bit more technical than the other commands. Khoe uses the well-known [Duplicity](http://duplicity.nongnu.org/) through a wrapper named [Duply](https://duply.net/) to create backups of user shares. Cron is used to schedule regular backup jobs. Backups are run by the `khoe` user with `sudo`.

```
ansible-playbook playbooks/backup.yml -e task=setup -e username=example1 [-e "passphrase=''"] [-e share_name=username] [-e remote_name=remotename] [-e "backup_list_name='default'"] [-e max_age=1Y] [-e max_fullbkp_age=2M] [-e max_fulls_with_incrs=2]

ansible-playbook playbooks/backup.yml -e task=backup -e username=example1 [-e share_name=username] [-e remote_name=remotename] [-e "backup_list_name='default'"] [-e dry_run=no]
ansible-playbook playbooks/backup.yml -e task=restore -e username=example1 [-e share_name=username] [-e remote_name=remotename] [-e "backup_list_name='default'"] [-e age=0D] [-e age=2019-01-23]
ansible-playbook playbooks/backup.yml -e task=fetch -e username=username -e "fetch_path='dir/filename'" [-e share_name=nas] [-e remote_name=remotename] [-e "backup_list_name='default'"] [-e age=0D] [-e age=2019-01-23]

ansible-playbook playbooks/backup.yml -e task=create-cronjob -e username=example1 [-e share_name=username] [-e remote_name=remotename] [-e "backup_list_name='default'"] [-e minute=0] [-e hour=4] [-e day=*] [-e month=*] [-e weekday=*] [-e dry_run=no]
ansible-playbook playbooks/backup.yml -e task=delete-cronjob -e username=example1 [-e share_name=username] [-e remote_name=remotename] [-e "backup_list_name='default'"]

ansible-playbook playbooks/backup.yml -e task=status -e username=example1 [-e share_name=username] [-e remote_name=remotename] [-e "backup_list_name='default'"]
ansible-playbook playbooks/backup.yml -e task=list -e username=example1 [-e share_name=username] [-e remote_name=remotename] [-e "backup_list_name='default'"] [-e age=0D] [-e age=2019-01-23]
```

See [Options](#option-formats) below for specifics for some of the arguments

###### Setup
This command creates and updates a Duply backup *profile* and creates a backup file list for a network share. To modify an existing profile including its associated *backup list* run setup again with the same `username`, `share_name`, `remote_name` and `backup_list_name` as used initially, varying only the other arguments. Any changes including an edited backup list will be integrated into the profile.  
To create additional profiles just vary any of the values for the just listed arguments. E.g. to add a backup to a second remote with a different list, change `remote_name` and `backup_list_name` and edit the created backup list. Then run setup again with the same values, to integrate the edited list into the profile.

- `max_age`: When a full backup reaches this [`age`](#age) it is deleted. Default: 1 year
- `max_fullbkp_age`: When the last full backup reaches this [`age`](#age) a new full backup is made. Default: 2 months
- `max_fulls_with_incrs`: Number of full backups for which incrementals are preserved. Default: 2

Combined with a daily cron job the default values result in 6 full backups spaced 2 months apart, kept for 1 year. And daily incrementals for 4 months.

> For all following commands `username`, `share_name`, `remote_name` and `backup_list_name` are used to specify the Duply backup profile to use.

###### Backup
Manually run a backup. Set `dry_run=yes` to let Duplicity simulate the backup run, e.g to catch errors in the setup.

###### Restore
Perform a full restore from backup. Restored data is written to the share in a new directory with the name `_restored`. To restore from an older backup specify [`age`](#age).

###### Fetch
Perform a partial restore from backup. Restored data is written to the share in a new directory with the name `_restored`. To restore from an older backup specify [`age`](#age).

###### Create Cronjob
Schedule a regular backup run in `khoe`'s crontab. Using the default values cron starts a backup daily at 04:00. If you're creating multiple backup profiles e.g. by creating multiple shares, you should adjust the scheduled time, otherwise the backups will all run at the same time, which could be bad.  
Set `dry_run=yes` to let Duplicity simulate the backup run, e.g to catch errors in the created crontab setup.

###### Delete Cronjob
Removes a backup schedule from `khoe`'s crontab'.

###### Status
Commands Duplicity to output a list of all existing backups in a chain of backups with their dates and types (full, incremental) for a profile.

###### List
Commands Duplicity to output a list of all backed up files at a certain date for a profile. Specify [`age`](#age) to set the date.

#### <a name=option-formats>Option formats</a>
Some of the command and configuration options need to be in specific formats understood by the underlying tools.

<a name=option-remotename>**remotename**</a>: Backup destinations and their authentication secrets should be added to the file `/etc/khoe/remote-backups.yml`. The *key* (first line of a configuration block) defines the `remotename` which may then be specified as an option in the commands.  
Currently file (local) and S3 protocols are implemented. More [protocols supported by Duplicity](http://duplicity.nongnu.org/duplicity.1.html#sect7) can be [added by pull request](#adding-backup-protocols) or by [creating an issue](https://github.com/khoe-cloud/khoe-ansible/issues/new).

<a name=age>**age**</a>: used for `setup`, `restore`, `fetch` and `list`. Specified in [Duplicity time format](http://duplicity.nongnu.org/duplicity.1.html#sect8).  
`s`, `m`, `h`, `D`, `W`, `M`, or `Y` are converted to seconds, minutes, hours, days, weeks, months, or years.

**"cron time"**: used for `create-cronjob` and `delete-cronjob`. Here's a good [primer](https://www.ostechnix.com/a-beginners-guide-to-cron-jobs/) on the format.

**backup_list_name**: by default all files in a share are added to the backup. Typically you will want to add only certain directories to a remote backup to save on cost and time for backup operations. The default backup lists are created by the setup task as `/home/[username]/config/backup-list-[share_name]-[remote_name]-backup_list_name].txt`. To include and exclude directories (or files) see the [Duplicity docs](http://duplicity.nongnu.org/duplicity.1.html#toc9) for its `exclude-filelist` option. For more info see Setup below.

### Recovery

(Currently recovery is only implemented for individual users, not the whole system. As such it does not recreate mounts and remote storage configurations. Recovery of cron jobs is also not yet implemented.)

Writes all information (including encryption keys) needed to recreate a Khoe server  to a removable drive, e.g. a small USB "key" drive. The data is stored in encrypted files using the supplied password. The removable drive itself may be formatted with FAT32 for universal use.

> It is recommended to carry this key on your person, on your keyring just like your door keys.

The recovery playbook mounts and then unmounts the specified drive automatically without saving the mount config. When the operation completes the drive may be removed immediately. See [Mounts](#mounts) for specifics.

```
ansible-playbook playbooks/recovery.yml -e task=create -e username=example1 -e password=1234 -e recovery_disk_label=label
ansible-playbook playbooks/recovery.yml -e task=recover -e username=example1 -e password=1234 -e recovery_disk_label=label
```
###### Create user recovery
Collects the needed data needed to recover a  user and their data and writes it to the removable drive.  

> Note: previous recovery data of the same user is deleted!

###### Recover user
Recreates a user, their shares, backup profiles and imports their gpg keys. but Restoration of share contents from backup is not part of recovery may be run manually, if desired.


### GPG Keys

Khoe does not use passphrases for the generated keys. (Although they work.) Passphrases (e.g. of imported keys) are not stored in recovery data (and likely never will be).

```
ansible-playbook playbooks/gpg.yml -e task=import -e username=example1 [-e export_path=/home/khoe/gpg-export/username]
```
###### Import
To import existing gpg keys to a user and use them with Khoe. Two files are required and should be named: `gpgkey.[username]-master.sec.asc, gpgkey.[username].ownertrust.txt`
