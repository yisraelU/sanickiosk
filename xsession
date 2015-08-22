#!/bin/bash

# Import system info
. sanickiosk/config/system.cfg

# Import variables
. sanickiosk/config/screensaver.cfg
. sanickiosk/config/browser.cfg

# Set correct user and group permissions for home directory
chown -R $UID:$UID $HOME >> $shh 2>> $log_it

# Uncomment to run touchscreen calibration on next boot
#xterm xinput_calibrator

# Disable right-click
if [ $nocontextmenu != "False" ]
	then xmodmap -e "pointer = 1 2 99"
fi

# Autorun screensaver on login
if [ $xscreensaver_enable = "True" ]
then
	# Look for new screensaver images
	rm ~/.xscreensaver-getimage.cache

	# Write latest screensaver switches
	bash sanickiosk/scripts/set_glslideshow_switches.sh

	# Read latest screensaver switches
	screensaver_switches=`cat sanickiosk/config/glslideshow_switches.cfg`

	# Set screensaver timeout
	sed -i "/timeout:/c\timeout:	$xscreensaver_idle" ~/.xscreensaver
	# Set glslideshow switches
	sed -i "/programs:/c\programs:	glslideshow -root $screensaver_switches" ~/.xscreensaver
	xscreensaver -nosplash &
else
	xset s off # Disable screensaver
	xset -dpms # Disable DPMS (Energy Star) features
	xset s noblank # Do not blank the screen
fi

# Write latest toolbar

# Restore keyboard shortcuts
#mkdir /home/sanickiosk/sanickiosk/.opera/keyboard
#cp /home/sanickiosk/sanickiosk/.sanickiosk_keyboard.ini /home/sanickiosk/sanickiosk/.opera/keyboard/

# Set home url

# Write latest browser switches
#bash /home/sanickiosk/sanickiosk/scripts/set_opera_switches.sh

# Read latest browser switches
#browser_switches=`cat /home/sanickiosk/sanickiosk/config/opera_switches.cfg`

# Start browser killer
#sh /home/sanickiosk/sanickiosk/scripts/browser_killer.sh &

# Start window manager
matchbox-window-manager -use_titlebar no &

# Look for latest SanicKiosk Chrome extension
array=(sanickiosk/chrome_extension/sanickiosk/*)
sanickiosk_extension=${array[-1]}

xterm

# Relaunch browser if closed
while true; do
	# Start Chrome
	chromium-browser --load-and-launch-app=$sanickiosk_extension
	sleep 5s
done
