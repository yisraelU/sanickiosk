#!/bin/bash

## Kioskscript, a script for building the Sanickiosk web kiosk
## August 2015
## Tested on Ubuntu Server x64 14.04.3 fresh install
##
## Documentation: http://sanickiosk.org
## Download a ready-to-install ISO of Sanickiosk at: http://links.sanicki.com/sanickiosk-dl
##
## This project replaces:
## http://links.sanicki.com/yln.kiosk
## http://tinyurl.com/ppl-kiosk
##
## To use this script:
## sudo apt-get install -y git
## git clone https://github.com/sanicki/sanickiosk
## chmod +x sanickiosk/scripts/kioskscript.sh
## sudo ./sanickiosk/scripts/kioskscript.sh
##
## If testing in Virtualbox insert Guest Additions CD image and:
## sudo apt-get install -y virtualbox-guest-utils

clear

# Import system info
. sanickiosk/config/system.cfg

# Set Log
mkdir sanickiosk/logs && touch sanickiosk/logs/kioskscript.log # Create log directory and file
log_it="sanickiosk/logs/kioskscript.log"

# Quiet
shh="/dev/null"

# Make empty directories
mkdir sanickiosk/screensavers >> $shh 2>> $log_it

# Pretty colors
red='\e[1;31m'
green='\e[1;32m'
yellow='\e[1;33m'
nc='\e[0m' # No color

echo -e "${red}Installing Sanickiosk on $NAME $VERSION.${nc}\n"

echo -e "${red}Performing operating system updates ${yellow}(this may take a while)${red}...${nc}"
# Refresh
apt-get -q update >> $shh 2>> $log_it
# Download & Install
apt-get -q upgrade >> $shh 2>> $log_it
# Clean
apt-get -q autoremove >> $shh 2>> $log_it
apt-get -q clean >> $shh 2>> $log_it
echo -e "${green}Done!${nc}"

echo -e "${red}Downloading and installing software ${yellow}(this will take a while)${red}...${nc}"
# Ajenti
wget -q http://repo.ajenti.org/debian/key -O- | apt-key add - >> $shh 2>> $log_it
echo 'deb http://repo.ajenti.org/ng/debian main main ubuntu' > /etc/apt/sources.list.d/ajenti.list
# Systemback
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 73C62A1B >> $shh 2>> $log_it
echo -e "deb http://ppa.launchpad.net/nemh/systemback/ubuntu $ver_code main" > /etc/apt/sources.list.d/systemback.list
# Flash
echo -e "deb http://archive.canonical.com/ubuntu/ $ver_code partner" > /etc/apt/sources.list.d/canonical_partner.list
apt-get -q update >> $shh 2>> $log_it
packagelist=(
xorg nodm matchbox-window-manager # GUI
  software-properties-common python-software-properties # Enable PPA installs
  #tasksel # Task selection
  chromium-browser # Browser
  adobe-flashplugin icedtea-7-plugin ttf-liberation # Flash, Java, and fonts
  ajenti # Browser-based system administration tool
  systemback-cli # Systemback custom image maker
  xscreensaver xscreensaver-data-extra xscreensaver-gl-extra libwww-perl # Screensaver
  xserver-xorg-input-multitouch xinput-calibrator # Touchscreen support
  unclutter # Hide cursor
  wpasupplicant # Secure wireless support
  alsa # Audio
)
apt-get -qy install --no-install-recommends ${packagelist[@]} >> $shh 2>> $log_it
echo -e "${green}Done!${nc}"

echo -e "${red}Disabling root recovery mode...${nc}"
sed -i -e 's/#GRUB_DISABLE_RECOVERY/GRUB_DISABLE_RECOVERY/g' /etc/default/grub >> $shh 2>> $log_it
update-grub >> $shh 2>> $log_it
echo -e "${green}Done!${nc}"

echo -e "${red}Enabling SanicKiosk autologin...${nc}"
sed -i -e 's/NODM_ENABLED=false/NODM_ENABLED=true/g' /etc/default/nodm >> $shh 2>> $log_it
sed -i -e 's/NODM_USER=root/NODM_USER=sanickiosk/g' /etc/default/nodm >> $shh 2>> $log_it
echo -e "${green}Done!${nc}"

echo -e "${red}Configuring the screensaver ${yellow}(XScreenSaver)${red}...${nc}"
# Link .xscreensaver
ln -s sanickiosk/xscreensaver .xscreensaver >> $shh 2>> $log_it
# Add a sample image
wget -q http://beginwithsoftware.com/wallpapers/archive/Various/images/free_desktop_wallpaper_logo_space_for_rent_1024x768.gif -O sanickiosk/screensavers/deleteme.gif >> $shh 2>> $log_it
echo -e "${green}Done!${nc}"

echo -e "${red}Configuring the browser ${yellow}(Chromium)${red}...${nc}"
# TBD
echo -e "${green}Done!${nc}"

echo -e "${red}Setting up the SanicKiosk scripts...${nc}"
# Link .xsession
ln -s sanickiosk/xsession .xsession >> $shh 2>> $log_it
# Set correct user and group permissions for home directory
chown -R $user:$user $home_dir >> $shh 2>> $log_it
# Set scripts to exexutable
find sanickiosk/scripts -type f -exec chmod +x {} \; >> $shh 2>> $log_it
echo -e "${green}Done!${nc}"

echo -e "${red}Configuring the browser-based system administration tool ${yellow}(Ajenti)${red}...${nc}"
service ajenti stop >> $shh 2>> $log_it
# Changing to default https port
sed -i 's/"port": 8000/"port": 443/' /etc/ajenti/config.json >> $shh 2>> $log_it
# Linking SanicKiosk plugins to Ajenti
ln -s sanickiosk/ajenti_plugins/sanickiosk_browser /var/lib/ajenti/plugins/sanickiosk_browser >> $shh 2>> $log_it
ln -s sanickiosk/ajenti_plugins/sanickiosk_screensaver /var/lib/ajenti/plugins/sanickiosk_screensaver >> $shh 2>> $log_it
echo -e "${green}Done!${nc}"

echo -e "${red}Enabling audio...${nc}"
adduser $user audio >> $shh 2>> $log_it
echo -e "${green}Done!${nc}"

echo -e "${red}Locking down the SanicKiosk user...${nc}"
#deluser $user sudo
echo -e "${green}Done!${nc}\n"

echo -e "${red}Installation log saved to ${yellow}sanickiosk/logs/kioskscript.log${red}.${nc}"

echo -e "${green}\nReboot?${nc}"
select yn in "Yes" "No"; do
        case $yn in
                Yes )
                        reboot ;;
                No )
                        exit 1 ;;
        esac
done
