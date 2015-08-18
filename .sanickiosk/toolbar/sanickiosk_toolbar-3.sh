#!/bin/bash
# Import variables
. /home/kiosk/.sanickiosk/browser.cfg

echo "[Document Toolbar.content]" > /home/kiosk/.sanickiosk/toolbar/sanickiosk_toolbar-3.cfg
if [ $hide_home = "False" ]
then
	if [ $kioskspeeddial = "False" ]
	then
		echo "Button0, \"Home\"=\"Go to homepage,,,,Go to homepage\"" >> /home/kiosk/.sanickiosk/toolbar/sanickiosk_toolbar-3.cfg
	else
		echo "Button0, \"Home\"=\"New page,,,,Go to homepage\"" >> /home/kiosk/.sanickiosk/toolbar/sanickiosk_toolbar-3.cfg
	fi
fi
if [ $hide_back = "False" ]
then
	echo "Button1, \"Back\"=\"Back,,,,Back\"" >> /home/kiosk/.sanickiosk/toolbar/sanickiosk_toolbar-3.cfg
fi
if [ $hide_forward = "False" ]
then
	echo "Button2, \"Forward\"=\"Forward,,,,Forward\"" >> /home/kiosk/.sanickiosk/toolbar/sanickiosk_toolbar-3.cfg
fi
if [ $hide_reload = "False" ]
then
	echo "Button3, \"Stop_Reload\"=\"Stop | Reload,,,Reload\"" >> /home/kiosk/.sanickiosk/toolbar/sanickiosk_toolbar-3.cfg
fi
if [ $hide_addressbar = "False" ]
then
	echo "Address4" >> /home/kiosk/.sanickiosk/toolbar/sanickiosk_toolbar-3.cfg
fi
if [ $hide_find = "False" ]
then
	echo "Button5, \"Find\"=\"Find,,,,Find\"" >> /home/kiosk/.sanickiosk/toolbar/sanickiosk_toolbar-3.cfg
fi
if [ $hide_zoom = "False" ]
then
	echo "ZoomSlider6" >> /home/kiosk/.sanickiosk/toolbar/sanickiosk_toolbar-3.cfg
fi
if [ $hide_ppreview = "False" ]
then
	echo "Button7, \"Print preview\"=\"Print preview,,,,Cascade\"" >> /home/kiosk/.sanickiosk/toolbar/sanickiosk_toolbar-3.cfg
fi
if [ $hide_print = "False" ]
then
	echo "Button8, \"Print\"=\"Print document,,,,Print document\"" >> /home/kiosk/.sanickiosk/toolbar/sanickiosk_toolbar-3.cfg
fi
if [ $hide_reset = "False" ]
then
	echo "Button9, \"Reset Kiosk\"=\"Zoom to,100,,,Restart transfer > Exit\"" >> /home/kiosk/.sanickiosk/toolbar/sanickiosk_toolbar-3.cfg
fi
