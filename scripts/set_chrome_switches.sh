#!/bin/bash

# Import system info
. sanickiosk/config/system.cfg

# Set Log
log_it="sanickiosk/logs/kioskscript.log"

# Quiet
shh="/dev/null"

# Import variables
. sanickiosk/config/browser.cfg

# Get SanicKiosk extension app id
str=`cat ~/.config/google-chrome/Default/Preferences` # Read file as string
IFS=’\"’ read -ra blocks <<< "$str" echo ${blocks[1]} # Convert string to array

# Find index of extension
find_app_id () {
  for i in "${!blocks[@]}"; do
     if [[ "${blocks[$i]}" = "${1}" ]]; then
         index=${i}
     fi
  done
  index=`expr $index - 6` # The app id is 6 delimeters prior to the app name
  app_id=${blocks[$index]}
  echo $app_id
}

SanicKiosk_app_id=`find_app_id 'SanicKiosk'`

switches=""
for option in kioskmode fullscreen nokeys nomenu nodownload noprint nomaillinks ; do
	value=${!option}
	if [ $value != "False" ]
	then
		switches=$switches" -"$option
	fi
done

echo $switches > sanickiosk/config/chrome_switches.cfg
