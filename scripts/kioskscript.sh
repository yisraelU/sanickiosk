#!/bin/bash

## Kioskscript, a script for building the Sanickiosk web kiosk
## August 2015
## Tested on Ubuntu Server x86 14.04.3 fresh install
##
## Documentation: http://sanickiosk.org
## Download a ready-to-install ISO of Sanickiosk at: http://links.sanicki.com/sanickiosk-dl
##
## This project replaces:
## http://links.sanicki.com/yln.kiosk
## http://tinyurl.com/ppl-kiosk
##
## To use this script:
## sudo su
## apt-get install -y git
## git clone https://github.com/sanicki/sanickiosk.git
## cd sanickiosk/scripts
## chmod +x kioskscript.sh
## .kioskscript.sh

# Pretty colors
red='\e[0;31m'
green='\e[1;32m'
blue='\e[1;36m'
NC='\e[0m' # No color

clear
# Determine Ubuntu Version Codename
VERSION=$(lsb_release -cs)

echo -e "${red}Installing operating system updates ${blue}(this may take a while)${red}...${NC}\n"
# Use mirror method
sed -i "1i \
deb mirror://mirrors.ubuntu.com/mirrors.txt $VERSION main restricted universe multiverse\n\
deb mirror://mirrors.ubuntu.com/mirrors.txt $VERSION-updates main restricted universe multiverse\n\
deb mirror://mirrors.ubuntu.com/mirrors.txt $VERSION-backports main restricted universe multiverse\n\
deb mirror://mirrors.ubuntu.com/mirrors.txt $VERSION-security main restricted universe multiverse\n\
" /etc/apt/sources.list
# Refresh
apt-get -q=2 update
# Download & Install
apt-get -q=2 upgrade > /dev/null
# Clean
apt-get -q=2 autoremove
apt-get -q=2 clean
echo -e "${green}Done!${NC}\n"

echo -e "${red}Disabling root recovery mode...${NC}\n"
sed -i -e 's/#GRUB_DISABLE_RECOVERY/GRUB_DISABLE_RECOVERY/g' /etc/default/grub
update-grub
echo -e "\n${green}Done!${NC}\n"

echo -e "${red}Enabling secure wireless support...${NC}\n"
apt-get -q=2 install --no-install-recommends wpasupplicant > /dev/null
echo -e "${green}Done!${NC}\n"

echo -e "${red}Installing a graphical user interface...${NC}\n"
apt-get -q=2 install --no-install-recommends xorg nodm matchbox-window-manager > /dev/null
# Hide Cursor
apt-get -q=2 install --no-install-recommends unclutter > /dev/null
echo -e "\n${green}Done!${NC}\n"

echo -e "${red}Configuring autologin...${NC}\n"
sed -i -e 's/NODM_ENABLED=false/NODM_ENABLED=true/g' /etc/default/nodm
sed -i -e 's/NODM_USER=root/NODM_USER=sanickiosk/g' /etc/default/nodm
echo -e "${green}Done!${NC}\n"

echo -e "${red}Installing and configuring the screensaver...${NC}\n"
apt-get -q=2 install --no-install-recommends xscreensaver xscreensaver-data-extra xscreensaver-gl-extra libwww-perl > /dev/null
# Link .xscreensaver
ln -s /home/sanickiosk/sanickiosk/xscreensaver /home/sanickiosk/.xscreensaver
# Create the screensaver directory
mkdir /home/sanickiosk/screensavers
# Add a sample image
wget -q http://beginwithsoftware.com/wallpapers/archive/Various/images/free_desktop_wallpaper_logo_space_for_rent_1024x768.gif -O /home/sanickiosk/screensavers/deleteme.gif
echo -e "\n${green}Done!${NC}\n"

echo -e "${red}Installing the browser ${blue}(Firefox)${red}...${NC}\n"
apt-get -q=2 -y install --force-yes --no-install-recommends firefox > /dev/null
apt-get -q=2 install --no-install-recommends adobe-flashplugin icedtea-7-plugin ttf-liberation > /dev/null # flash, java, and fonts
# Overwrite default Opera Bookmarks
#find /usr/share/opera -name "bookmarks.adr" -print0 | xargs -0 rm -rf
# Delete default Opera Speed Dial
#find /usr/share/opera -name "standard_speeddial.ini" -print0 | xargs -0 rm -rf
# Link Opera Speed Dial save file
#ln -s /home/sanickiosk/sanickiosk/.opera/speeddial.sav /home/sanickiosk/.opera/speeddial.sav
# Link the Opera filter
#ln -s /home/sanickiosk/sanickiosk/.opera/urlfilter.ini /home/sanickiosk/.opera/urlfilter.ini
echo -e "\n${green}Done!${NC}\n"

echo -e "${red}Creating SanicKiosk Scripts...${NC}\n"
# Link .xsession
ln -s /home/sanickiosk/sanickiosk/xsession /home/sanickiosk/.xsession
# Set correct user and group permissions for /home/kiosk
chown -R sanickiosk:sanickiosk /home/sanickiosk/
# Set scripts to exexutable
chmod +x sanickiosk/scripts/*.sh
# Dependency for browser killer
apt-get -q=2 install --no-install-recommends xprintidle > /dev/null
echo -e "${green}Done!${NC}\n"

echo -e "${red}Adding the browser-based system administration tool ${blue}(Ajenti)${red}...${NC}\n"
wget -q http://repo.ajenti.org/debian/key -O- | apt-key add -
echo '
## Ajenti
deb http://repo.ajenti.org/ng/debian main main ubuntu
'  >> /etc/apt/sources.list
apt-get -q=2 update && apt-get -q=2 install --no-install-recommends ajenti > /dev/null
service ajenti stop
# Changing to default https port
sed -i 's/"port": 8000/"port": 443/' /etc/ajenti/config.json
echo -e "\n${green}Done!${NC}\n"

echo -e "${red}Adding SanicKiosk plugins to Ajenti...${NC}\n"
ln -s /home/sanickiosk/sanickiosk/ajenti_plugins/sanickiosk_browser /var/lib/ajenti/plugins/sanickiosk_browser
ln -s /home/sanickiosk/sanickiosk/ajenti_plugins/sanickiosk_screensaver /var/lib/ajenti/plugins/sanickiosk_screensaver
echo -e "${green}Done!${NC}\n"

echo -e "${red}Installing audio...${NC}\n"
apt-get -q=2 install --no-install-recommends alsa > /dev/null
adduser sanickiosk audio
echo -e "\n${green}Done!${NC}\n"

echo -e "${red}Installing print server...${NC}\n"
tasksel install print-server > /dev/null
usermod -aG lpadmin sanickiosk
usermod -aG lp,sys sanickiosk
rm -f /etc/cups/cupsd.conf
ln -s /home/sanickiosk/sanickiosk/etc/cups/cupsd.conf /etc/cups/cupsd.conf
echo -e "${green}Done!${NC}\n"

echo -e "${red}Installing touchscreen support...${NC}\n"
apt-get -q=2 install --no-install-recommends xserver-xorg-input-multitouch xinput-calibrator > /dev/null
echo -e "${green}Done!${NC}\n"

echo -e "${red}Adding the customized image installation maker ${blue}(Systemback)${red}...${NC}\n"
add-apt-repository -y ppa:nemh/systemback
apt-get -q=2 update && apt-get -q=2 install --no-install-recommends systemback-cli
echo -e "${green}Done!${NC}\n"

echo -e "${red}Locking down the SanicKiosk user...${NC}\n"
#deluser sanickiosk sudo
echo -e "${green}Done!${NC}\n"

echo -e "${green}Reboot?${NC}"
select yn in "Yes" "No"; do
        case $yn in
                Yes )
                        reboot ;;
                No )
                        break ;;
        esac
done
