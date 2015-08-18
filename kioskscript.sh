#!/bin/bash

## Kioskscript, a script for building the Sanickiosk web kiosk
## August 2015
## Tested on Ubuntu Minimal x64 15.04 fresh install
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
## cd sanickiosk
## apt-get install dos2unix # Because of \r woes
## find . -type f -exec dos2unix {} \;
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
apt-get -q=2 dist-upgrade > /dev/null
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

echo -e "${red}Creating kiosk user...${NC}\n"
useradd kiosk -m -d /home/kiosk -p `openssl passwd -crypt kiosk`
# Configure kiosk autologin
sed -i -e 's/NODM_ENABLED=false/NODM_ENABLED=true/g' /etc/default/nodm
sed -i -e 's/NODM_USER=root/NODM_USER=kiosk/g' /etc/default/nodm
echo -e "${green}Done!${NC}\n"

echo -e "${red}Installing and configuring the screensaver...${NC}\n"
apt-get -q=2 install --no-install-recommends xscreensaver xscreensaver-data-extra xscreensaver-gl-extra libwww-perl > /dev/null
# Link .xscreensaver
ln -s .xscreensaver /home/kiosk/.xscreensaver
# Create the screensaver directory
mkdir /home/kiosk/screensavers
# Add a sample image
wget -q http://beginwithsoftware.com/wallpapers/archive/Various/images/free_desktop_wallpaper_logo_space_for_rent_1024x768.gif -O /home/kiosk/screensavers/deleteme.gif
echo -e "\n${green}Done!${NC}\n"

echo -e "${red}Installing the browser ${blue}(Opera)${red}...${NC}\n"
echo "
## Ubuntu Partners
deb http://archive.canonical.com/ $VERSION partner
"  >> /etc/apt/sources.list
wget -O - http://deb.opera.com/archive.key | apt-key add -
echo '
## Opera
deb http://deb.opera.com/opera/ stable non-free
'  >> /etc/apt/sources.list.d/opera.list
apt-get -q=2 update
apt-get -q=2 -y install --force-yes --no-install-recommends opera > /dev/null
apt-get -q=2 install --no-install-recommends flashplugin-installer icedtea-7-plugin ttf-liberation > /dev/null # flash, java, and fonts
mkdir /home/kiosk/.opera
# Delete default Opera RSS Feed Readers
find /usr/share/opera -name "feedreaders.ini" -print0 | xargs -0 rm -rf
# Delete default Opera Webmail Providers
find /usr/share/opera -name "webmailproviders.ini" -print0 | xargs -0 rm -rf
# Overwrite default Opera Bookmarks
find /usr/share/opera -name "bookmarks.adr" -print0 | xargs -0 rm -rf
# Delete default Opera Speed Dial
find /usr/share/opera -name "standard_speeddial.ini" -print0 | xargs -0 rm -rf
# Link Opera Speed Dial save file
ln -s .opera/speeddial.sav /home/kiosk/.opera/speeddial.sav
# Link the Opera filter
ln -s .opera/urlfilter.ini /home/kiosk/.opera/urlfilter.ini
echo -e "\n${green}Done!${NC}\n"

echo -e "${red}Creating Sanickiosk Scripts...${NC}\n"
mkdir .sanickiosk
mkdir /home/kiosk/.sanickiosk
# Link .xsession
ln -s .xsession /home/kiosk/.xsession
# Create file to hold all screensaver variables
touch .sanickiosk/screensaver.cfg
ln -s .sanickiosk/screensaver.cfg /home/kiosk/.sanickiosk/screensaver.cfg
# Create file to hold all GLSlideshow launch switches
touch .sanickiosk/glslideshow_switches.cfg
ln -s .sanickiosk/glslideshow_switches.cfg /home/kiosk/.sanickiosk/glslideshow_switches.cfg
# Create file to hold all browser variables
touch .sanickiosk/browser.cfg
ln -s .sanickiosk/browser.cfg /home/kiosk/.sanickiosk/browser.cfg
# Create file to hold Opera launch switches
touch .sanickiosk/opera_switches.cfg
ln -s .sanickiosk/opera_switches.cfg /home/kiosk/.sanickiosk/opera_switches.cfg
# Link GLSlideshow switches script
ln -s .sanickiosk/set_glslideshow_switches.sh /home/kiosk/.sanickiosk/set_glslideshow_switches.sh
chmod +x .sanickiosk/set_glslideshow_switches.sh
# Link operaprefs.ini
ln -s .sanickiosk/operaprefs.sh /home/kiosk/.sanickiosk/operaprefs.sh
chmod +x .sanickiosk/operaprefs.sh
# Create toolbar configuration script
mkdir /home/kiosk/.sanickiosk/toolbar
# Toolbar Part 1 of 4
ln -s .sanickiosk/toolbar/sanickiosk_toolbar-1.cfg /home/kiosk/.sanickiosk/toolbar/sanickiosk_toolbar-1.cfg
# Toolbar Part 2 of 4
ln -s .sanickiosk/toolbar/sanickiosk_toolbar-2.cfg /home/kiosk/.sanickiosk/toolbar/sanickiosk_toolbar-2.cfg
# Toolbar Part 3 of 4
ln -s .sanickiosk/toolbar/sanickiosk_toolbar-3.sh /home/kiosk/.sanickiosk/toolbar/sanickiosk_toolbar-3.sh
# Toolbar Part 4 of 4
ln -s .sanickiosk/toolbar/sanickiosk_toolbar-4.cfg /home/kiosk/.sanickiosk/toolbar/sanickiosk_toolbar-4.cfg
# Link toolbar builder script
ln -s .sanickiosk/toolbar/sanickiosk_toolbar_builder.sh /home/kiosk/.sanickiosk/toolbar/sanickiosk_toolbar_builder.sh
# Link keyboard shortcuts
ln -s .sanickiosk/sanickiosk_keyboard.ini /home/kiosk/.sanickiosk/sanickiosk_keyboard.ini
# Create Opera switches script
ln -s .sanickiosk/set_opera_switches.sh /home/kiosk/.sanickiosk/set_opera_switches.sh
chmod +x .sanickiosk/set_opera_switches.sh
# Create browser killer
apt-get -q=2 install --no-install-recommends xprintidle > /dev/null
ln -s .sanickiosk/browser_killer.sh /home/kiosk/.sanickiosk/browser_killer.sh
chmod +x .sanickiosk/browser_killer.sh
# Set correct user and group permissions for /home/kiosk
chown -R kiosk:kiosk /home/kiosk/
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

echo -e "${red}Adding Sanickiosk plugins to Ajenti...${NC}\n"
apt-get -q=2 install --no-install-recommends unzip > /dev/null
wget -q https://github.com/sanicki/sanickiosk_plugins/archive/master.zip -O sanickiosk_plugins-master.zip
unzip -qq sanickiosk_plugins-master.zip
mv sanickiosk_plugins-master/* /var/lib/ajenti/plugins/
rm -r sanickiosk_plugins-master*
echo -e "${green}Done!${NC}\n"

echo -e "${red}Installing audio...${NC}\n"
apt-get -q=2 install --no-install-recommends alsa > /dev/null
adduser kiosk audio
echo -e "\n${green}Done!${NC}\n"

echo -e "${red}Installing print server...${NC}\n"
tasksel install print-server > /dev/null
usermod -aG lpadmin administrator
usermod -aG lp,sys kiosk
rm -f /etc/cups/cupsd.conf
ln -s etc/cups/cupsd.conf /etc/cups/cupsd.conf
echo -e "${green}Done!${NC}\n"

echo -e "${red}Installing touchscreen support...${NC}\n"
apt-get -q=2 install --no-install-recommends xserver-xorg-input-multitouch xinput-calibrator > /dev/null
echo -e "${green}Done!${NC}\n"

echo -e "${red}Adding the customized image installation maker ${blue}(Mondo Rescue)${red}...${NC}\n"
wget -q -O - ftp://ftp.mondorescue.org/ubuntu/12.10/mondorescue.pubkey | apt-key add -
echo '
## Mondo Rescue
deb ftp://ftp.mondorescue.org/ubuntu 12.10 contrib
'  >> /etc/apt/sources.list.d/mondo.list
apt-get -q=2 update && apt-get -q=2 install --no-install-recommends --force-yes mondo > /dev/null
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
