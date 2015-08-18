#!/bin/bash

# Import variables
. /home/kiosk/.sanickiosk/browser.cfg

switches=""
for option in kioskmode fullscreen nokeys nomenu nodownload noprint nomaillinks ; do
	value=${!option}
	if [ $value != "False" ]
	then
		switches=$switches" -"$option
	fi
done

echo $switches > /home/kiosk/.sanickiosk/opera_switches.cfg
