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

# Set browser switches
# browser_switches="--disable --disable-translate --disable-infobars --disable-suggestions-service --disable-save-password-bubble"
# " --disk-cache-dir=$CHROMIUM_TEMP/cache/ --user-data-dir=$CHROMIUM_TEMP/user_data/ --start-maximized"

# Set browser extensions
browser_extensions="sanickiosk/chrome_extensions/blocksi/1.0.101_0,sanickiosk/chrome_extensions/virtual_keyboard/1.10.7_0"
browser_apps="sanickiosk/chrome_extensions/sanickiosk/0.1,sanickiosk/chrome_extensions/blocksi/1.0.101_0,sanickiosk/chrome_extensions/virtual_keyboard/1.10.7_0"

xterm

# Relaunch browser if closed
while true; do
	# Start Chrome
	chromium-browser --load-extension=$browser_extensions --load-and-launch-app=sanickiosk/chrome_extensions/sanickiosk/0.1
	#chromium-browser --load-apps=$browser_apps
	sleep 5s
done
