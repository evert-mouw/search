#!/bin/bash

# Opens Thunar when in XFCE,
# with the selected folder and file,
# selecting the specified file.

# Documentation: see end of file.

# Evert Mouw <post@evert.net>
# 2019-01-30 first version
# 2019-01-31 dep checking

# dependency checking
DEPENDENCIES="gdbus thunar pidof"
for DEP in $DEPENDENCIES
do
	if ! command -v $DEP > /dev/null
	then
		echo "Missing: $DEP"
		DEPFAIL=1
	fi
done
if [[ $DEPFAIL -eq 1 ]]
then
	echo "My dependencies are: $DEPENDENCIES"
	exit 1
fi

# is Thunar running?
if ! pidof thunar > /dev/null
then
	#thunar & disown
	MSG="Thunar is not running. Start it with:
thunar --daemon
This should be done by the XFCE session
using ~/.config/autostart (or use GUI)."
	echo "Error ⚠️"
	echo "$MSG"
	zenity --error --no-wrap --text="$MSG"
	# I tried this but it did't work.
	nohup thunar --deamon & disown
	# Also see here why this doesn't work:
	# https://forum.manjaro.org/t/prevent-terminal-from-disowning-thunar/21702/5
	exit 1
fi

# basic dbus command and path
COMMAND="gdbus call --session --dest org.xfce.Thunar --object-path /org/xfce/FileManager --method org.xfce.FileManager"
EMPTYARGS="'' ''"

# dbus final part
if [ -d "$1" ]
then
	# open as directory
	METHOD="DisplayFolder"
	DIR="$1"
	$COMMAND.$METHOD "'$DIR'" $EMPTYARGS > /dev/null
else
	if ! [ -f "$1" ]
	then
		echo "Could not find the file using D-Bus for Thunar."
		echo "I tried: $1"
		exit 1
	fi
	# open as file & select
	METHOD="DisplayFolderAndSelect"
	DIR=$(dirname "$1")
	FILE=$(basename "$1")
	$COMMAND.$METHOD "'$DIR'" "'$FILE'" $EMPTYARGS > /dev/null
fi

exit

DOCUMENTATION="

You can open Thunar with a file selected. Unfortunately no command line options are available for this. (With Nautilus of Windows Explorer, this is easily possible). But there is a D-Bus interface so we can write a shellscript for it.

For this to work, Thunar must already be running. Using XFCE, Thunar will often already run in daemon mode. Also assuming XFCE, it will start the Filemanager object/method. I'm not sure if this works outside of XFCE or with another default filemanager (just not tested).

D-Bus types incluse strings (s). For selecting a folder or file in Thunar, you need a struct of 3 or 4 strings.

DisplayFolder
s uri (directory path)
s display
s startup_id

DisplayFolderAndSelect
s uri (directory path)
s filename
s display
s startup_id

Details: Search online for xfdesktop-file-manager-dbus.xml

Alas, dbus-send cannot send structs! But gdbus can :-)

Example 1:

gdbus call --session --dest org.xfce.Thunar --object-path /org/xfce/FileManager --method org.xfce.FileManager.DisplayFolder '/home' '' ''

Example 2:

gdbus call --session --dest org.xfce.Thunar --object-path /org/xfce/FileManager --method org.xfce.FileManager.DisplayFolderAndSelect '/usr/bin/' 'bash' '' ''

"
