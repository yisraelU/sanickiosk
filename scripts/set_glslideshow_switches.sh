#!/bin/bash

# Import system info
. `dirname $PWD`/config/system.cfg

# Set Log
log_it="> /dev/null 2>$install_dir/logs/sanickiosk.log"

# Import variables
. $install_dir/config/browser.cfg

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

echo $switches > /home/sanickiosk/sanickiosk/config/glslideshow_switches.cfg
