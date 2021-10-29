# README for "lukscontainerfile-zenity" add-on for Thunar or Nautilus file manager

This is a "Custom Action" extension for Xfce's Thunar file manager or GNOME's Nautilus file manager, to handle LUKS-encrypted container files.

The file managers have native features to handle LUKS-encrypted volumes (disks, partitions), but not to handle LUKS-encrypted container files.

This extension creates LUKS2 container files with ext4 or Btrfs filesystem inside, and mounts/unmounts LUKS container files. The mount/unmount should work regardless of the container's LUKS version or type of filesystem inside.  So you could create a LUKS container file manually if you wished, and still use the mount/unmount actions of this extension.

You must know the "sudo" password to use this extension.

This software works on Linux only.

Created 2021 by Bill Dietrich ([bill@billdietrich.me](bill@billdietrich.me), [https://www.billdietrich.me](https://www.billdietrich.me))

Source code is at [https://github.com/BillDietrich/lukscontainerfile-zenity](https://github.com/BillDietrich/lukscontainerfile-zenity)


## Pre-Installation

You must have installed Zenity, and (if you want to use it) Btrfs:

```
zenity --version
btrfs --version		# if this fails, install "btrfs-progs"
```


## Install


### For Thunar:

```
# Copy the *.sh files to disk, perhaps somewhere in your PATH, then:

chmod +x lukscontainerfile-*.sh
```

1. In the Thunar file manager, do Edit / Configure custom actions.
2. Click "+" to add a new action.
3. Set Name to "Mount".
4. Set Description to "Mount LUKS container file".
5. Set Command to "/FULLPATHTO/lukscontainerfile-mount.sh %f", or if
the files were copied to somewhere in your path, set to
just "lukscontainerfile-mount.sh %f".
6. Click on Appearance Conditions tab.
7. Set File Pattern to "*.luks".
8. Check the check-box for Other Files.
9. Click OK button.
10. Do similar to add the "Unmount" and "Format" actions.

### For Nautilus:

```
cp *.sh $HOME/.gnome2/nautilus-scripts
# or to make available to all users:
sudo cp *.sh /usr/share/nautilus-scripts

chmod +x lukscontainerfile-*.sh
```

## Un-install

### For Thunar:

1. In the Thunar file manager, do Edit / Configure custom actions.
2. Highlight the "Mount" action.
3. Click "-" to remove the action.
4. Do similar to remove the "Unmount" and "Format" actions.

```
rm lukscontainerfile-*.sh
```

### For Nautilus:

```
rm $HOME/.gnome2/nautilus-scripts/lukscontainerfile-*.sh
# or:
sudo rm /usr/share/nautilus-scripts/lukscontainerfile-*.sh

```


## Use

In Thunar file manager, right-click on a SOMENAME.luks file, and the context menu will include menu items "Format LUKS2 container file", "Mount LUKS container file", and "Unmount LUKS container file".

In Nautilus file manager, right-click on a SOMENAME.luks file, click on Scripts, and the context menu will include menu items "Format LUKS2 container file", "Mount LUKS container file", and "Unmount LUKS container file".

All operations require you to know the "sudo" password.

To use the context menu items:

* Create New / LUKS Container File ...

    In Thunar file manager, select menu-item "File / Create Document", set filename to SOMENAME.luks, and the file will be created with placeholder contents.  In Nautilus file manager, (do similar ???).  In CLI, you could do "touch SOMENAME.luks".  The filename must end with ".luks", and the basename should be alphanum (well, valid as a filesystem label, anyway).

	File basename (without ".luks") will be used as label of filesystem, so for ext4 filesystem it must be 16 characters or less.  I don't know what the length limit is for Btrfs, and what types of chars can be in a label for any type of filesystem.

* Format LUKS2 container file
    
	Right-click on the .luks file you created, and select the "Format LUKS2 container file" menu item.  Follow the dialogs, giving information and passwords as needed.  The file will be formatted as a LUKS2 container with an ext4 or Btrfs filesystem inside, a header backup file called SOMENAME.luks.HeaderBackup will be created, and a mount-point /mnt/SOMENAME will be created.

	Security note: As the container is being LUKS-formatted, very briefly the container's password is stored in a temporary file.  Normal precautions are taken to keep it secure, but for example the file is deleted the standard way, not with any secure-delete facility.

	Note: You are free to delete the header backup file if you wish.  But it is a good idea instead to save it somewhere safe.  If the header of the container file gets damaged, you may be able to use the header backup file to repair it.

	Note: Every time you format a container file, a mount-point such as /mnt/SOMENAME will be created for it.  But when you delete a container file, the mount-point is not deleted.  This could lead to clutter (not very serious) in /mnt.  You could delete the old mount-points (they're just directories) manually, for the ones that correspond to container files you've deleted.

* Mount LUKS container file

	Right-click on the .luks file, select the "Mount LUKS container file" menu item, give the required passwords, and the existing SOMENAME.luks container file will be mounted (with added flag noatime) on mount-point /mnt/SOMENAME.

	Security note: As the container is being LUKS-opened, very briefly the container's password is stored in a temporary file.  Normal precautions are taken to keep it secure, but for example the file is deleted the standard way, not with any secure-delete facility.

	Security note: The mount-point for the container is owned by current user and has 700 permissions (usable only by current user) when mounted.  If you want to change this, you can edit the files lukscontainerfile-format.sh and lukscontainerfile-mount.sh in /usr/share/kservices5/ServiceMenus

* Unmount LUKS container file

	Right-click on the .luks file, select the "Unmount LUKS container file" menu item, give the required password, and the existing SOMENAME.luks container file will be unmounted from mount-point /mnt/SOMENAME.


## Status

### 1.0.0 (10/2021)
* Tested only on Manjaro 21 Xfce with Thunar file manager.

### 1.0.1 (10/2021)
* Add directions for Nautilus file manager.


### To-Do / Quirks
* Test on Nautilus.
* Should object if container size is too small.


## Privacy Policy
This software doesn't collect, store, or transmit your identity or personal information or passwords in any way other than handling your LUKS container files as documented.

