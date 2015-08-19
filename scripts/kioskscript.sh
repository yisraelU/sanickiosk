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
## cd sanickiosk/scripts
## sudo su
## chmod +x kioskscript.sh
## .kioskscript.sh

clear

# Import system info
. `dirname $PWD`/config/system.cfg

# Make required empty directories
mkdir $INSTALL_DIR/logs
mkdir $INSTALL_DIR/screensavers > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log

# Pretty colors
red='\e[1;31m'
green='\e[1;32m'
yellow='\e[1;33m'
NC='\e[0m' # No color

# Prevent terminal blanking
setterm -powersave off -blank 0 > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log

echo -e "${red}Installing operating system updates ${yellow}(this *may* take a while)${red}...${NC}"
# Use mirror method
sed -i "1i \
deb mirror://mirrors.ubuntu.com/mirrors.txt $VERSION main restricted universe multiverse\n\
deb mirror://mirrors.ubuntu.com/mirrors.txt $VERSION-updates main restricted universe multiverse\n\
deb mirror://mirrors.ubuntu.com/mirrors.txt $VERSION-backports main restricted universe multiverse\n\
deb mirror://mirrors.ubuntu.com/mirrors.txt $VERSION-security main restricted universe multiverse\n\
" /etc/apt/sources.list > /dev/null
# Refresh
apt-get -q update > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
# Download & Install
apt-get -q upgrade > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
# Clean
apt-get -q autoremove > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
apt-get -q clean > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
echo -e "${green}Done!${NC}"

echo -e "${red}Installing software ${yellow}(this **will** take a while)${red}...${NC}"
# Ajenti
wget -q http://repo.ajenti.org/debian/key -O- | apt-key add - > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
echo '
deb http://repo.ajenti.org/ng/debian main main ubuntu
'  >> /etc/apt/sources.list.d/ajenti.list > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
# Systemback
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 73C62A1B > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
echo -e "
deb http://ppa.launchpad.net/nemh/systemback/ubuntu $VERSION main
"  >> /etc/apt/sources.list.d/systemback.list > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
# Flash
echo -e "
deb http://archive.canonical.com/ubuntu/ $VERSION partner
"  >> /etc/apt/sources.list.d/canonical_partner.list > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
apt-get -q update > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
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
apt-get -q install --no-install-recommends ${packagelist[@]} > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
tasksel install print-server > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
echo -e "${green}Done!${NC}"

echo -e "${red}Disabling root recovery mode...${NC}"
sed -i -e 's/#GRUB_DISABLE_RECOVERY/GRUB_DISABLE_RECOVERY/g' /etc/default/grub > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
update-grub > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
echo -e "${green}Done!${NC}"

echo -e "${red}Configuring autologin...${NC}"
sed -i -e 's/NODM_ENABLED=false/NODM_ENABLED=true/g' /etc/default/nodm > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
sed -i -e 's/NODM_USER=root/NODM_USER=sanickiosk/g' /etc/default/nodm > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
echo -e "${green}Done!${NC}"

echo -e "${red}Configuring the screensaver...${NC}"
# Link .xscreensaver
ln -s $INSTALL_DIR/xscreensaver $HOME_DIR/.xscreensaver > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
# Add a sample image
wget -q http://beginwithsoftware.com/wallpapers/archive/Various/images/free_desktop_wallpaper_logo_space_for_rent_1024x768.gif -O $INSTALL_DIR/screensavers/deleteme.gif > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
echo -e "${green}Done!${NC}"

echo -e "${red}Configuring the browser ${yellow}(Firefox)${red}...${NC}"
# Overwrite default Opera Bookmarks
#find /usr/share/opera -name "bookmarks.adr" -print0 | xargs -0 rm -rf
# Delete default Opera Speed Dial
#find /usr/share/opera -name "standard_speeddial.ini" -print0 | xargs -0 rm -rf
# Link Opera Speed Dial save file
#ln -s /home/sanickiosk/sanickiosk/.opera/speeddial.sav /home/sanickiosk/.opera/speeddial.sav
# Link the Opera filter
#ln -s /home/sanickiosk/sanickiosk/.opera/urlfilter.ini /home/sanickiosk/.opera/urlfilter.ini
echo -e "${green}Done!${NC}"

echo -e "${red}Setting up the SanicKiosk scripts...${NC}"
# Link .xsession
ln -s $INSTALL_DIR/xsession $HOME_DIR/.xsession > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
# Set correct user and group permissions for /home/kiosk
chown -R $USER:$USER $HOME_DIR > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
# Set scripts to exexutable
find $INSTALL_DIR/scripts -type f -exec chmod +x {} \; > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
echo -e "${green}Done!${NC}"

echo -e "${red}Configuring the browser-based system administration tool ${yellow}(Ajenti)${red}...${NC}"
service ajenti stop > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
# Changing to default https port
sed -i 's/"port": 8000/"port": 443/' /etc/ajenti/config.json > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
# Linking SanicKiosk plugins to Ajenti
ln -s $INSTALL_DIR/ajenti_plugins/sanickiosk_browser /var/lib/ajenti/plugins/sanickiosk_browser > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
ln -s $INSTALL_DIR/ajenti_plugins/sanickiosk_screensaver /var/lib/ajenti/plugins/sanickiosk_screensaver > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
echo -e "${green}Done!${NC}"

echo -e "${red}Enabling audio...${NC}"
adduser $USER audio > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
echo -e "${green}Done!${NC}"

echo -e "${red}Setting up print server...${NC}"
usermod -aG lpadmin $USER > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
usermod -aG lp,sys $USER > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
rm -f /etc/cups/cupsd.conf > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
ln -s $INSTALL_DIR/etc/cups/cupsd.conf /etc/cups/cupsd.conf > /dev/null 2>$INSTALL_DIR/logs/kioskscript.log
echo -e "${green}Done!${NC}"

echo -e "${red}Locking down the SanicKiosk user...${NC}"
#deluser $USER sudo
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
