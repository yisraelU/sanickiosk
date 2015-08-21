#!/bin/bash

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
echo $SanicKiosk_app_id
