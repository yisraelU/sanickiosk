#!/bin/bash

# Import system info
. `dirname $PWD`/config/system.cfg

# Set Log
log_it="> /dev/null 2>$install_dir/logs/sanickiosk.log"

# Import variables
. $install_dir/config/browser.cfg

switches=""
for option in kioskmode fullscreen nokeys nomenu nodownload noprint nomaillinks ; do
	value=${!option}
	if [ $value != "False" ]
	then
		switches=$switches" -"$option
	fi
done

echo $switches > /home/sanickiosk/sanickiosk/config/opera_switches.cfg
