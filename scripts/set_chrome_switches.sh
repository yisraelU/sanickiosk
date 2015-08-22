#!/bin/bash

# Set Log
log_it="sanickiosk/logs/sanickiosk.log"

# Quiet
shh="/dev/null"

# Import variables
. sanickiosk/config/browser.cfg

switches=""
for option in kioskmode fullscreen nokeys nomenu nodownload noprint nomaillinks ; do
	value=${!option}
	if [ $value != "False" ]
	then
		switches=$switches" -"$option
	fi
done

echo $switches > sanickiosk/config/chrome_switches.cfg
