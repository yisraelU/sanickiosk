#!/bin/bash

# Import variables
. /home/sanickiosk/sanickiosk/config/browser.cfg

switches=""
for option in kioskmode fullscreen nokeys nomenu nodownload noprint nomaillinks ; do
	value=${!option}
	if [ $value != "False" ]
	then
		switches=$switches" -"$option
	fi
done

echo $switches > /home/sanickiosk/sanickiosk/config/opera_switches.cfg
