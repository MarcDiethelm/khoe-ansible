Migration
=========

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
