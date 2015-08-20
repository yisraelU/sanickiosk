#!/bin/bash

# Import system info
. ~/sanickiosk/config/system.cfg

# Set Log
log_it="~/sanickiosk/logs/kioskscript.log"

# Quiet
shh="/dev/null"

# Import variables
. ~/sanickiosk/config/browser.cfg

switches=""
for option in glslideshow_duration glslideshow_pan glslideshow_fade glslideshow_zoom glslideshow_clip ; do
	value=${!option}
	delete="glslideshow_"
	option=${option#${delete}}
	if [ $option != "clip" ]
	then
		if [ -n "$value" ]
		then
			switches=$switches" -"$option" "$value
		fi
	else
		if [ $value="True" ]
		then
			switches=$switches" -clip"
		else
			switches=$switches" -letterbox"
		fi
	fi
done

echo $switches > ~/sanickiosk/config/glslideshow_switches.cfg
