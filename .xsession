#!/bin/bash

# Import variables
. /home/kiosk/.sanickiosk/screensaver.cfg
. /home/kiosk/.sanickiosk/browser.cfg

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
	bash /home/kiosk/.sanickiosk/set_glslideshow_switches.sh

	# Read latest screensaver switches
	screensaver_switches=`cat /home/kiosk/.sanickiosk/glslideshow_switches.cfg`

	# Set screensaver timeout
	sed -i "/timeout:/c\timeout:	$xscreensaver_idle" /home/kiosk/.xscreensaver
	# Set glslideshow switches
	sed -i "/programs:/c\programs:	glslideshow -root $screensaver_switches" /home/kiosk/.xscreensaver
	xscreensaver -nosplash &
else
	xset s off # Disable screensaver
	xset -dpms # Disable DPMS (Energy Star) features
	xset s noblank # Do not blank the screen
fi

# Get screen resolution
res=$(xrandr -q | awk -F'"'"'current'"'"' -F'"'"','"'"' '"'"'NR==1 {gsub("( |current)","");print $2}'"'"')

# Nuke it from orbit
rm -rf /home/kiosk/.opera/cache
mkdir /home/kiosk/.opera/cache

rm /home/kiosk/.opera/global_history.dat
rm /home/kiosk/.opera/bookmarks.adr
rm /home/kiosk/.opera/download.dat

# Write latest operaprefs.ini
sh /home/kiosk/.sanickiosk/operaprefs.sh

# Avoid Opera Welcome screen
touch -t 201401010001 /home/kiosk/.opera/operaprefs.ini

# Write latest toolbar
sh /home/kiosk/.sanickiosk/toolbar/sanickiosk_toolbar_builder.sh

# Restore keyboard shortcuts
mkdir /home/kiosk/.opera/keyboard
cp /home/kiosk/.sanickiosk/sanickiosk_keyboard.ini /home/kiosk/.opera/keyboard/

# Write latest browser switches
bash /home/kiosk/.sanickiosk/set_opera_switches.sh

# Read latest browser switches
browser_switches=`cat /home/kiosk/.sanickiosk/opera_switches.cfg`

# Start browser killer
sh /home/kiosk/.sanickiosk/browser_killer.sh &

# Start window manager
matchbox-window-manager &

# Relaunch browser if closed
while true; do
	# Restore Opera Speed Dial
	cp /home/kiosk/.opera/speeddial.sav /home/kiosk/.opera/speeddial.ini

	# Delete Opera Bookmarks
	rm /home/kiosk/.opera/bookmarks.adr

	# Relaunch Opera
	if [ $kioskspeeddial = "True" ]
	then
		opera -geometry $res+0+0 $browser_switches
	else
		opera -geometry $res+0+0 $browser_switches $home_url
	fi
	sleep 5s
done
