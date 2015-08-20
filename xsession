#!/bin/bash

# Import system info
. sanickiosk/config/system.cfg

# Import variables
. sanickiosk/config/screensaver.cfg
. sanickiosk/config/browser.cfg

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
	rm .xscreensaver-getimage.cache

	# Write latest screensaver switches
	bash sanickiosk/scripts/set_glslideshow_switches.sh

	# Read latest screensaver switches
	screensaver_switches=`cat sanickiosk/config/glslideshow_switches.cfg`

	# Set screensaver timeout
	sed -i "/timeout:/c\timeout:	$xscreensaver_idle" .xscreensaver
	# Set glslideshow switches
	sed -i "/programs:/c\programs:	glslideshow -root $screensaver_switches" .xscreensaver
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

# Relaunch browser if closed
while true; do
	chromium-browser --load-extension=sanickiosk/chrome_extensions/sanickiosk --load-extension=sanickiosk/chrome_extensions/virtual_keyboard $browser_switches $home_url
	#firefox $browser_switches $home_url
	sleep 5s
done
