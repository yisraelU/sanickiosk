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

# Start Chrome
browser_extensions="sanickiosk/chrome_extensions/sanickiosk/0.1,sanickiosk/chrome_extensions/app_autostart/1.12.14.2_0,sanickiosk/chrome_extensions/blocksi/1.0.101_0,sanickiosk/chrome_extensions/virtual_keyboard/1.10.7_0"
# browser_switches="--disable --disable-translate --disable-infobars --disable-suggestions-service --disable-save-password-bubble"
# " --disk-cache-dir=$CHROMIUM_TEMP/cache/ --user-data-dir=$CHROMIUM_TEMP/user_data/ --start-maximized"

# Need to minimize this
chromium-browser --load-extension=$browser_extensions & #--kiosk http://sanickiosk.org &

sleep 6s

# Get SanicKiosk extension app id
str=`cat .config/chromium/Default/Preferences` # Read file as string
IFS=’\"’ read -ra blocks <<< "$str" echo ${blocks[1]} # Convert string to array
# As function in case needed again
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
# Call function
SanicKiosk_app_id=`find_app_id 'SanicKiosk'`

# Relaunch browser if closed
while true; do
	chromium-browser --app-id=$SanicKiosk_app_id # Start Chrome so SanicKiosk receives an app id
	sleep 5s
done
