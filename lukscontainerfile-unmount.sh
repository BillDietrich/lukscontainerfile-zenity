#!/usr/bin/env sh

# lukscontainerfile-unmount.sh for Thunar or Nautilus file-manager.
# This file must have execute permission set.
# Argument is container file full pathname.

#set -o errexit
set -o nounset

FULLFILENAME=$1
BASENAME=`basename "$FULLFILENAME" ".luks"`
TITLE="Unmount LUKS Container '$BASENAME'"

USERPASSWD=`zenity --title "Enter SUDO password to $TITLE" --entry --hide-text --width=600 --height=200`
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

sudo umount "/mnt/$BASENAME"
RETVAL=$?

if [ $RETVAL != "0" ]; then
	zenity --title "$TITLE" --error --text="Filesystem unmount failed (exit code $RETVAL)." --width=600 --height=200
	exit $RETVAL
fi

sudo cryptsetup close "$BASENAME"
RETVAL=$?

if [ $RETVAL != "0" ]; then
	zenity --title "$TITLE" --error --text="Container close failed (exit code $RETVAL)." --width=600 --height=200
	exit $RETVAL
fi

zenity --title "$TITLE" --info --text="Success !  Container '$BASENAME' has been unmounted." --width=600 --height=200

exit 0
