#!/usr/bin/env sh

# lukscontainerfile-mount.sh for Thunar or Nautilus file-manager.
# This file must have execute permission set.
# Argument is container file full pathname.

#set -o errexit
set -o nounset

FULLFILENAME=$1
BASENAME=`basename "$FULLFILENAME" ".luks"`
TITLE="Mount LUKS Container '$BASENAME'"

USERPASSWD=`zenity --title="Enter SUDO password to $TITLE" --entry --hide-text --width=600 --height=200`
RETVAL=$?

if [ $RETVAL != "0" ]; then
	exit $RETVAL
fi

echo "$USERPASSWD" | sudo --stdin --validate
RETVAL=$?
USERPASSWD=""

if [ $RETVAL != "0" ]; then
	zenity --title="$TITLE" --error --text="Sudo failed (exit code $RETVAL)."
	exit $RETVAL
fi

CONTAINERPASSWD=`zenity --title="Enter container passphrase to $TITLE" --entry --hide-text --width=600 --height=200`
RETVAL=$?

if [ $RETVAL != "0" ]; then
	exit $RETVAL
fi

touch lukscontainerfile.tmp
chmod 600 lukscontainerfile.tmp
echo -n "$CONTAINERPASSWD" >lukscontainerfile.tmp

sudo cryptsetup luksOpen --key-file lukscontainerfile.tmp "$FULLFILENAME" "$BASENAME"
RETVAL=$?

rm lukscontainerfile.tmp

if [ $RETVAL != "0" ]; then
	zenity --title="$TITLE" --error --text="Decryption failed (exit code $RETVAL)." --width=600 --height=200
	exit $RETVAL
fi

if [ ! -d "/mnt/$BASENAME" ]; then
	sudo mkdir "/mnt/$BASENAME"
	RETVAL=$?

	if [ $RETVAL != "0" ]; then
		zenity --title="$TITLE" --error --text="Making mountpoint '/mnt/$BASENAME' failed (exit code $RETVAL)." --width=600 --height=200
		exit $RETVAL
	fi
fi

sudo mount -o defaults,noatime "/dev/mapper/$BASENAME" "/mnt/$BASENAME"
RETVAL=$?

if [ $RETVAL != "0" ]; then
	zenity --title="$TITLE" --error --text="Filesystem mount failed (exit code $RETVAL)." --width=600 --height=200
	exit $RETVAL
fi

sudo chown "$USER" "/mnt/$BASENAME"

sudo chmod 700 "/mnt/$BASENAME"

zenity --info --title="$TITLE" --text="Success !  Container '$BASENAME' has been mounted." --width=600 --height=200

exit 0
