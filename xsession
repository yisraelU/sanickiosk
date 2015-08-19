#!/bin/bash

# Import variables
. /home/sanickiosk/sanickiosk/config/screensaver.cfg
. /home/sanickiosk/sanickiosk/config/browser.cfg

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
	bash /home/sanickiosk/sanickiosk/scripts/set_glslideshow_switches.sh

	# Read latest screensaver switches
	screensaver_switches=`cat /home/sanickiosk/sanickiosk/config/glslideshow_switches.cfg`

	# Set screensaver timeout
	sed -i "/timeout:/c\timeout:	$xscreensaver_idle" /home/sanickiosk/.xscreensaver
	# Set glslideshow switches
	sed -i "/programs:/c\programs:	glslideshow -root $screensaver_switches" /home/sanickiosk/.xscreensaver
	xscreensaver -nosplash &
else
	xset s off # Disable screensaver
	xset -dpms # Disable DPMS (Energy Star) features
	xset s noblank # Do not blank the screen
fi

# Get screen resolution
res=$(xrandr -q | awk -F'"'"'current'"'"' -F'"'"','"'"' '"'"'NR==1 {gsub("( |current)","");print $2}'"'"')

# Nuke it from orbit
#rm -rf /home/sanickiosk/.opera/cache
#mkdir /home/sanickiosk/.opera/cache

#rm /home/sanickiosk/.opera/global_history.dat
#rm /home/sanickiosk/.opera/bookmarks.adr
#rm /home/sanickiosk/.opera/download.dat

# Write latest operaprefs.ini
#sh /home/sanickiosk/.sanickiosk/operaprefs.sh

# Avoid Opera Welcome screen
#touch -t 201401010001 /home/sanickiosk/.opera/operaprefs.ini

# Write latest toolbar
#sh /home/sanickiosk/.sanickiosk/toolbar/sanickiosk_toolbar_builder.sh

# Restore keyboard shortcuts
#mkdir /home/sanickiosk/.opera/keyboard
#cp /home/sanickiosk/.sanickiosk/sanickiosk_keyboard.ini /home/sanickiosk/.opera/keyboard/

# Write latest browser switches
bash /home/sanickiosk/sanickiosk/scripts/set_opera_switches.sh

# Read latest browser switches
browser_switches=`cat /home/sanickiosk/sanickiosk/config/opera_switches.cfg`

# Start browser killer
sh /home/sanickiosk/sanickiosk/scripts/browser_killer.sh &

# Start window manager
exec matchbox-window-manager  -use_titlebar no

# Relaunch browser if closed
while true; do
	# Restore Opera Speed Dial
	#cp /home/sanickiosk/.opera/speeddial.sav /home/sanickiosk/.opera/speeddial.ini

	# Delete Opera Bookmarks
	#rm /home/sanickiosk/.opera/bookmarks.adr

	# Relaunch Browser
	if [ $kioskspeeddial = "True" ]
	then
		firefox $browser_switches
		#firefox -geometry $res+0+0 $browser_switches
	else
		firefox $browser_switches $home_url
		#firefox -geometry $res+0+0 $browser_switches $home_url
	fi
	sleep 5s
done
