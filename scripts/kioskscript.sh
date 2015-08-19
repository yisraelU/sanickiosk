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

# Set Log
mkdir $install_dir/logs && touch $install_dir/logs/kioskscript.log # Create log directory and file
log_it="$install_dir/logs/kioskscript.log"

# Quiet
shh="/dev/null"

# Make empty directories
mkdir $install_dir/screensavers >> $shh 2>> $log_it

# Pretty colors
red='\e[1;31m'
green='\e[1;32m'
orange='\e[0;33m'
nc='\e[0m' # No color

# Prevent terminal blanking
setterm -powersave off -blank 0 >> $shh 2>> $log_it

echo -e "${red}Installing Sanickiosk on $NAME $VERSION...${nc}\n"

echo -e "${red}Performing operating system updates ${orange}(this may take a while)${red}...${nc}"
# Use mirror method
sed -i "1i \
deb mirror://mirrors.ubuntu.com/mirrors.txt $ver_code main restricted universe multiverse\n\
deb mirror://mirrors.ubuntu.com/mirrors.txt $ver_code-updates main restricted universe multiverse\n\
deb mirror://mirrors.ubuntu.com/mirrors.txt $ver_code-backports main restricted universe multiverse\n\
deb mirror://mirrors.ubuntu.com/mirrors.txt $ver_code-security main restricted universe multiverse\n\
" /etc/apt/sources.list > /dev/null
# Refresh
apt-get -q update >> $shh 2>> $log_it
# Download & Install
apt-get -q upgrade >> $shh 2>> $log_it
# Clean
apt-get -q autoremove >> $shh 2>> $log_it
apt-get -q clean >> $shh 2>> $log_it
echo -e "${green}Done!${nc}"

echo -e "${red}Installing software ${orange}(this will take a while)${red}...${nc}"
# Ajenti
wget -q http://repo.ajenti.org/debian/key -O- | apt-key add - >> $shh 2>> $log_it
echo 'deb http://repo.ajenti.org/ng/debian main main ubuntu'  > /etc/apt/sources.list.d/ajenti.list >> $shh 2>> $log_it
# Systemback
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 73C62A1B >> $shh 2>> $log_it
echo -e "deb http://ppa.launchpad.net/nemh/systemback/ubuntu $ver_code main"  > /etc/apt/sources.list.d/systemback.list >> $shh 2>> $log_it
# Flash
echo -e "deb http://archive.canonical.com/ubuntu/ $ver_code partner"  > /etc/apt/sources.list.d/canonical_partner.list >> $shh 2>> $log_it
apt-get -q update >> $shh 2>> $log_it
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
apt-get -q install --no-install-recommends ${packagelist[@]} >> $shh 2>> $log_it
tasksel install print-server >> $shh 2>> $log_it
echo -e "${green}Done!${nc}"

echo -e "${red}Disabling root recovery mode...${nc}"
sed -i -e 's/#GRUB_DISABLE_RECOVERY/GRUB_DISABLE_RECOVERY/g' /etc/default/grub >> $shh 2>> $log_it
update-grub >> $shh 2>> $log_it
echo -e "${green}Done!${nc}"

echo -e "${red}Configuring autologin...${nc}"
sed -i -e 's/NODM_ENABLED=false/NODM_ENABLED=true/g' /etc/default/nodm >> $shh 2>> $log_it
sed -i -e 's/NODM_USER=root/NODM_USER=sanickiosk/g' /etc/default/nodm >> $shh 2>> $log_it
echo -e "${green}Done!${nc}"

echo -e "${red}Configuring the screensaver...${nc}"
# Link .xscreensaver
ln -s $install_dir/xscreensaver $home_dir/.xscreensaver >> $shh 2>> $log_it
# Add a sample image
wget -q http://beginwithsoftware.com/wallpapers/archive/Various/images/free_desktop_wallpaper_logo_space_for_rent_1024x768.gif -O $install_dir/screensavers/deleteme.gif >> $shh 2>> $log_it
echo -e "${green}Done!${nc}"

echo -e "${red}Configuring the browser ${orange}(Firefox)${red}...${nc}"
# Overwrite default Opera Bookmarks
#find /usr/share/opera -name "bookmarks.adr" -print0 | xargs -0 rm -rf
# Delete default Opera Speed Dial
#find /usr/share/opera -name "standard_speeddial.ini" -print0 | xargs -0 rm -rf
# Link Opera Speed Dial save file
#ln -s /home/sanickiosk/sanickiosk/.opera/speeddial.sav /home/sanickiosk/.opera/speeddial.sav
# Link the Opera filter
#ln -s /home/sanickiosk/sanickiosk/.opera/urlfilter.ini /home/sanickiosk/.opera/urlfilter.ini
echo -e "${green}Done!${nc}"

echo -e "${red}Setting up the SanicKiosk scripts...${nc}"
# Link .xsession
ln -s $install_dir/xsession $home_dir/.xsession >> $shh 2>> $log_it
# Set correct user and group permissions for /home/kiosk
chown -R $user:$user $home_dir >> $shh 2>> $log_it
# Set scripts to exexutable
find $install_dir/scripts -type f -exec chmod +x {} \; >> $shh 2>> $log_it
echo -e "${green}Done!${nc}"

echo -e "${red}Configuring the browser-based system administration tool ${orange}(Ajenti)${red}...${nc}"
service ajenti stop >> $shh 2>> $log_it
# Changing to default https port
sed -i 's/"port": 8000/"port": 443/' /etc/ajenti/config.json >> $shh 2>> $log_it
# Linking SanicKiosk plugins to Ajenti
ln -s $install_dir/ajenti_plugins/sanickiosk_browser /var/lib/ajenti/plugins/sanickiosk_browser >> $shh 2>> $log_it
ln -s $install_dir/ajenti_plugins/sanickiosk_screensaver /var/lib/ajenti/plugins/sanickiosk_screensaver >> $shh 2>> $log_it
echo -e "${green}Done!${nc}"

echo -e "${red}Enabling audio...${nc}"
adduser $user audio >> $shh 2>> $log_it
echo -e "${green}Done!${nc}"

echo -e "${red}Setting up print server...${nc}"
usermod -aG lpadmin $user >> $shh 2>> $log_it
usermod -aG lp,sys $user >> $shh 2>> $log_it
rm -f /etc/cups/cupsd.conf >> $shh 2>> $log_it
ln -s $install_dir/etc/cups/cupsd.conf /etc/cups/cupsd.conf >> $shh 2>> $log_it
echo -e "${green}Done!${nc}"

echo -e "${red}Locking down the SanicKiosk user...${nc}"
#deluser $user sudo
echo -e "${green}Done!${nc}\n"

echo -e "${red}Installation log saved to ${orange}$install_dir/logs/kioskscript.log${red}.${nc}"

echo -e "${green}\nReboot?${nc}"
select yn in "Yes" "No"; do
        case $yn in
                Yes )
                        reboot ;;
                No )
                        exit 1 ;;
        esac
done
