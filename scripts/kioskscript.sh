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
## git clone https://github.com/sanicki/sanickiosk.git .
## cd scripts
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

echo -e "${red}Installing software ${blue}(this may take a while too)${red}...${NC}\n"
# Ajenti
wget -q http://repo.ajenti.org/debian/key -O- | apt-key add - > /dev/null
echo '
deb http://repo.ajenti.org/ng/debian main main ubuntu
'  >> /etc/apt/sources.list.d/ajenti.list
# Systemback
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 73C62A1B > /dev/null
echo -e "
deb http://ppa.launchpad.net/nemh/systemback/ubuntu $VERSION main
"  >> /etc/apt/sources.list.d/systemback.list
# Flash
echo -e "
deb http://archive.canonical.com/ubuntu/ $VERSION partner
"  >> /etc/apt/sources.list.d/canonical_partner.list
apt-get -q=2 update
packagelist=(
  alsa # Audio
  ajenti # Browser-based system administration tool
  wpasupplicant # Secure wireless support
  xorg nodm matchbox-window-manager # GUI
  unclutter # Hide cursor
  xscreensaver xscreensaver-data-extra xscreensaver-gl-extra libwww-perl # Screensaver
  firefox # Browser
  adobe-flashplugin icedtea-7-plugin ttf-liberation # Flash, Java, and fonts
  xprintidle # Browser killer dependency
  tasksel # Task selection
  xserver-xorg-input-multitouch xinput-calibrator # Touchscreen support
  software-properties-common python-software-properties # Enable PPA installs
  systemback-cli # Systemback custom image maker
)
apt-get -q=2 install --no-install-recommends ${packagelist[@]} > /dev/null
tasksel install print-server > /dev/null

echo -e "${red}Disabling root recovery mode...${NC}\n"
sed -i -e 's/#GRUB_DISABLE_RECOVERY/GRUB_DISABLE_RECOVERY/g' /etc/default/grub
update-grub
echo -e "\n${green}Done!${NC}\n"

echo -e "${red}Configuring autologin...${NC}\n"
sed -i -e 's/NODM_ENABLED=false/NODM_ENABLED=true/g' /etc/default/nodm
sed -i -e 's/NODM_USER=root/NODM_USER=sanickiosk/g' /etc/default/nodm
echo -e "${green}Done!${NC}\n"

echo -e "${red}Configuring the screensaver...${NC}\n"
# Link .xscreensaver
ln -s /home/sanickiosk/xscreensaver /home/sanickiosk/.xscreensaver
# Create the screensaver directory
mkdir /home/sanickiosk/screensavers
# Add a sample image
wget -q http://beginwithsoftware.com/wallpapers/archive/Various/images/free_desktop_wallpaper_logo_space_for_rent_1024x768.gif -O /home/sanickiosk/screensavers/deleteme.gif
echo -e "\n${green}Done!${NC}\n"

echo -e "${red}Configuring the browser ${blue}(Firefox)${red}...${NC}\n"
# Overwrite default Opera Bookmarks
#find /usr/share/opera -name "bookmarks.adr" -print0 | xargs -0 rm -rf
# Delete default Opera Speed Dial
#find /usr/share/opera -name "standard_speeddial.ini" -print0 | xargs -0 rm -rf
# Link Opera Speed Dial save file
#ln -s /home/sanickiosk/.opera/speeddial.sav /home/sanickiosk/.opera/speeddial.sav
# Link the Opera filter
#ln -s /home/sanickiosk/.opera/urlfilter.ini /home/sanickiosk/.opera/urlfilter.ini
echo -e "\n${green}Done!${NC}\n"

echo -e "${red}Setting up the SanicKiosk scripts...${NC}\n"
# Link .xsession
ln -s /home/sanickiosk/xsession /home/sanickiosk/.xsession
# Set correct user and group permissions for /home/kiosk
chown -R sanickiosk:sanickiosk /home/sanickiosk/
# Set scripts to exexutable
find /home/sanickiosk/scripts -type f -exec chmod +x {} \;
echo -e "${green}Done!${NC}\n"

echo -e "${red}Configuring the browser-based system administration tool ${blue}(Ajenti)${red}...${NC}\n"
service ajenti stop
# Changing to default https port
sed -i 's/"port": 8000/"port": 443/' /etc/ajenti/config.json
echo -e "\n${green}Done!${NC}\n"
# Linking SanicKiosk plugins to Ajenti
ln -s /home/sanickiosk/ajenti_plugins/sanickiosk_browser /var/lib/ajenti/plugins/sanickiosk_browser
ln -s /home/sanickiosk/ajenti_plugins/sanickiosk_screensaver /var/lib/ajenti/plugins/sanickiosk_screensaver
echo -e "${green}Done!${NC}\n"

echo -e "${red}Enabling audio...${NC}\n"
adduser sanickiosk audio
echo -e "\n${green}Done!${NC}\n"

echo -e "${red}Setting up print server...${NC}\n"
usermod -aG lpadmin sanickiosk
usermod -aG lp,sys sanickiosk
rm -f /etc/cups/cupsd.conf
ln -s /home/sanickiosk/etc/cups/cupsd.conf /etc/cups/cupsd.conf
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
