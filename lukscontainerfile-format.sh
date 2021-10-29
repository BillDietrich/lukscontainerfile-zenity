#!/usr/bin/env sh

# lukscontainerfile-mount.sh for Thunar or Nautilus file-manager.
# This file must have execute permission set.
# Argument is container file full pathname.

#set -o errexit
set -o nounset

FULLFILENAME=$1
BASENAME=`basename "$FULLFILENAME" ".luks"`
TITLE="Format LUKS Container '$BASENAME'"

FSTYPE=`zenity --title "$TITLE" --text "Select filesystem type:" --list --radiolist --hide-header --column="Filesystem type" --column="Fstype" "" "Btrfs not mixed (recommended if > 5 GB)" "" "Btrfs mixed (recommended if < 5 GB)" "" "ext4" --width=600 --height=200`
RETVAL=$?

if [ $RETVAL != "0" ]; then
	exit $RETVAL
fi

case $FSTYPE in
	"Btrfs not mixed (recommended if > 5 GB)")
		FSTYPE=1
		;;
	"Btrfs mixed (recommended if < 5 GB)")
		FSTYPE=2
		;;
	"ext4")
		FSTYPE=3
		;;
	*)
		zenity --title "$TITLE" --error --text="Invalid FSTYPE '$FSTYPE'." --width=600 --height=200
		exit 1
		;;
esac

case $FSTYPE in
	1)
		MSG="File must be 125 MB or greater (filesystem will be 16 MB less).  How many MB for file ? "
		;;
	2)
		MSG="File must be 32 MB or greater (filesystem will be 16 MB less).  How many MB for file ? "
		;;
	3)
		MSG="File must be 24 MB or greater (filesystem will be 21 MB less).  How many MB for file ? "
		;;
	*)
		zenity --title "$TITLE" --error --text="Invalid FSTYPE '$FSTYPE'." --width=600 --height=200
		exit 1
		;;
esac

NMB=`zenity --title "$TITLE" --entry --text="$MSG" --width=600 --height=200`
RETVAL=$?

if [ $RETVAL != "0" ]; then
	exit $RETVAL
fi

# could check NMB against size limit here, but too lazy

zenity --title "$TITLE" --warning --text="Sure you want to overwrite contents of '$FULLFILENAME' with $NMB MB LUKS2 container ?" --width=600 --height=200
RETVAL=$?

if [ $RETVAL != "0" ]; then
	exit $RETVAL
fi

USERPASSWD=`zenity --title "Enter your SUDO password to $TITLE" --entry --hide-text --width=600 --height=200`
RETVAL=$?

if [ $RETVAL != "0" ]; then
	exit $RETVAL
fi

echo "$USERPASSWD" | sudo --stdin --validate
RETVAL=$?
USERPASSWD=""

if [ $RETVAL != "0" ]; then
	zenity --title "$TITLE" --error --text="Sudo failed (exit code $RETVAL)." --width=600 --height=200
	exit $RETVAL
fi

CONTAINERPASSWD=`zenity --title "Passphrase to set on container '$BASENAME':" --entry --hide-text --width=600 --height=200`
RETVAL=$?

if [ $RETVAL != "0" ]; then
	exit $RETVAL
fi

touch lukscontainerfile.tmp
chmod 600 lukscontainerfile.tmp
echo -n "$CONTAINERPASSWD" >lukscontainerfile.tmp

dd if=/dev/zero of="$FULLFILENAME" bs=1 count=0 seek="$NMB"M
sudo rm -f "$FULLFILENAME.HeaderBackup"

sudo cryptsetup luksFormat --batch-mode --type luks2 --iter-time 4400 --key-file lukscontainerfile.tmp "$FULLFILENAME"
RETVAL=$?

if [ $RETVAL != "0" ]; then
	zenity --title "$TITLE" --error --text="Container luksFormat failed (exit code $RETVAL)." --width=600 --height=200
	exit $RETVAL
fi

sudo cryptsetup luksHeaderBackup "$FULLFILENAME" --header-backup-file "$FULLFILENAME.HeaderBackup"

sudo chown "$USER" "$FULLFILENAME.HeaderBackup"

sudo cryptsetup --key-file lukscontainerfile.tmp luksOpen "$FULLFILENAME" "$BASENAME"

rm lukscontainerfile.tmp

case $FSTYPE in
	1)
		MKFSCMD="mkfs.btrfs -f -q --label $BASENAME /dev/mapper/$BASENAME"
		;;
	2)
		MKFSCMD="mkfs.btrfs -f -q --mixed --label $BASENAME /dev/mapper/$BASENAME"
		;;
	3)
		MKFSCMD="mke2fs -t ext4 -F -q -L $BASENAME /dev/mapper/$BASENAME"
		;;
	*)
		zenity --title "$TITLE" --error --text="Invalid FSTYPE '$FSTYPE'." --width=600 --height=200
		exit 1
		;;
esac

sudo $MKFSCMD
RETVAL=$?

if [ $RETVAL != "0" ]; then
	zenity --title "$TITLE" --error --text="'$MKFSCMD' failed (exit code $RETVAL)." --width=600 --height=200
	exit $RETVAL
fi

sudo cryptsetup luksClose "$BASENAME"

if [ ! -d "/mnt/$BASENAME" ]; then
	sudo mkdir "/mnt/$BASENAME"
	RETVAL=$?

	if [ $RETVAL != "0" ]; then
		zenity --title "$TITLE" --error --text="Making mountpoint '/mnt/$BASENAME' failed (exit code $RETVAL)." --width=600 --height=200
		exit $RETVAL
	fi
fi

sudo chown "$USER" "/mnt/$BASENAME"

sudo chmod 700 "/mnt/$BASENAME"

zenity --info --title "$TITLE" --text="Success !  LUKS2 container '$BASENAME' has been formatted with a filesystem.  Now you can mount it.  And perhaps save file '$FULLFILENAME.HeaderBackup' somewhere safe." --width=600 --height=200

exit 0
