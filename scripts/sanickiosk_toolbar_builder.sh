#!/bin/bash
# Import variables
. /home/sanickiosk/sanickiosk/config/browser.cfg

if [ $hide_toolbar = "False" ]
then
	# Show Toolbar
	#sed -i "/Alignment=/c\Alignment=2" /home/kiosk/.sanickiosk/toolbar/sanickiosk_toolbar-2.cfg
	# Generate toolbar buttons
	#sh /home/kiosk/.sanickiosk/toolbar/sanickiosk_toolbar-3.sh
else
	# Hide Toolbar
	#sed -i "/Alignment=/c\Alignment=0" /home/kiosk/.sanickiosk/toolbar/sanickiosk_toolbar-2.cfg
fi
#mkdir /home/kiosk/.opera/toolbar/
#cat /home/kiosk/.sanickiosk/toolbar/sanickiosk_toolbar-*.cfg > /home/kiosk/.opera/toolbar/sanickiosk_toolbar.ini
