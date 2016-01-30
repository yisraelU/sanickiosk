#!/bin/bash

## Kioskscript, a script for building the Sanickiosk web kiosk
## August 2015
## Tested on Ubuntu Minimal x64 14.04.3 fresh install
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
## sudo -H ./sanickiosk/scripts/kioskscript.sh
##
## If testing in Virtualbox:
## sudo apt-get install -y virtualbox-guest-utils

# Functions
ask() {
  # http://djm.me/ask
  while true; do

    if [ "${2:-}" = "Y" ]; then
      prompt="Y/n"
      default=Y
    elif [ "${2:-}" = "N" ]; then
      prompt="y/N"
      default=N
    else
      prompt="y/n"
      default=
    fi

    # Ask the question - use /dev/tty in case stdin is redirected from somewhere else
    read -p "$1 [$prompt] " REPLY </dev/tty

    # Default?
    if [ -z "$REPLY" ]; then
      REPLY=$default
    fi

    # Check if the reply is valid
    case "$REPLY" in
      Y*|y*) return 0 ;;
      N*|n*) return 1 ;;
    esac

  done
}

# Pretty colors
red='\e[1;31m'
green='\e[1;32m'
yellow='\e[1;33m'
nc='\e[0m' # No color

# Root?
if [[ $UID != 0 ]]; then
  echo -e "${red}You must run kioskscript using the command: ${yellow}sudo ./sanickiosk/scripts/kioskscript.sh${nc}\n"
  exit 1
fi

# Set Log
mkdir sanickiosk/logs && touch sanickiosk/logs/kioskscript.log # Create log directory and file
log_it="sanickiosk/logs/kioskscript.log"

# Begin
clear

# Get operating system information
. /etc/os-release
. /etc/lsb-release

# Get user information
user=`who am i | awk '{print $1}'`

echo -e "${red}Installing Sanickiosk on $NAME $VERSION.${nc}\n"

if ask ${red}"Run in verbose mode?"${nc} N; then
  echo -e "${yellow}Verbose mode${nc}\n"
  shh="/dev/tty"
else
  echo -e "${yellow}Quiet mode${nc}\n"
  shh="/dev/null"
fi

# Make empty directories
mkdir sanickiosk/screensavers >> $shh 2>> $log_it
mkdir sanickiosk/settings >> $shh 2>> $log_it

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
# Systemback
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 73C62A1B >> $shh 2>> $log_it
echo -e "deb http://ppa.launchpad.net/nemh/systemback/ubuntu $DISTRIB_CODENAME main" > /etc/apt/sources.list.d/systemback.list
# Flash
echo -e "deb http://archive.canonical.com/ubuntu/ $DISTRIB_CODENAME partner" > /etc/apt/sources.list.d/canonical_partner.list
apt-get -q update >> $shh 2>> $log_it
packagelist=(
  curl
  xorg nodm matchbox-window-manager # GUI
  software-properties-common python-software-properties # Enable PPA installs
  #tasksel # Task selection
  chromium-browser # Browser
  adobe-flashplugin icedtea-7-plugin ttf-liberation # Flash, Java, and fonts
  #ajenti # Browser-based system administration tool
  systemback-cli # Systemback custom image maker
  xscreensaver xscreensaver-data-extra xscreensaver-gl-extra libwww-perl # Screensaver
  #xserver-xorg-input-multitouch xinput-calibrator # Touchscreen support
  unclutter # Hide cursor
  wpasupplicant # Secure wireless support
  alsa # Audio
)
apt-get -qy install --no-install-recommends ${packagelist[@]} >> $shh 2>> $log_it
# Ajenti
#wget -q http://repo.ajenti.org/debian/key -O- | apt-key add - >> $shh 2>> $log_it
#echo 'deb http://repo.ajenti.org/ng/debian main main ubuntu' > /etc/apt/sources.list.d/ajenti.list
curl https://raw.githubusercontent.com/ajenti/ajenti/master/scripts/install.sh > sanickiosk/scripts/install_ajenti.sh && bash sanickiosk/scripts/install_ajenti.sh >> $shh 2>> $log_it
echo -e "${green}Done!${nc}"

echo -e "${red}Disabling root recovery mode...${nc}"
sed -i -e 's/#GRUB_DISABLE_RECOVERY/GRUB_DISABLE_RECOVERY/g' /etc/default/grub >> $shh 2>> $log_it
update-grub >> $shh 2>> $log_it
echo -e "${green}Done!${nc}"

echo -e "${red}Enabling SanicKiosk autologin...${nc}"
sed -i -e 's/NODM_ENABLED=false/NODM_ENABLED=true/g' /etc/default/nodm >> $shh 2>> $log_it
sed -i -e "s/NODM_USER=root/NODM_USER=$user/g" /etc/default/nodm >> $shh 2>> $log_it
echo -e "${green}Done!${nc}"

echo -e "${red}Configuring the splash screen...${nc}"
cp -r sanickiosk/lib/plymouth/themes/sanickiosk-logo /lib/plymouth/themes/ >> $shh 2>> $log_it
ln -sf /lib/plymouth/themes/sanickiosk-logo/sanickiosk-logo.plymouth /etc/alternatives/default.plymouth >> $shh 2>> $log_it
ln -sf /lib/plymouth/themes/sanickiosk-logo/sanickiosk-logo.grub /etc/alternatives/default.plymouth.grub >> $shh 2>> $log_it
#update-alternatives --install /lib/plymouth/themes/default.plymouth default.plymouth /lib/plymouth/themes/sanickiosk-logo/sanickiosk-logo.plymouth 10 >> $shh 2>> $log_it
#update-alternatives --config default.plymouth >> $shh 2>> $log_it
#update-initramfs -u >> $shh 2>> $log_it
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
chown -R $user:$user $HOME >> $shh 2>> $log_it
# Unnecessarily making sure all scripts to exexutable
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

if ask "${green}\nReboot?${nc}" Y; then
    reboot ;;
else
  ask "${green}\nDisplay install log?${nc}" && less $log_it
  exit 1 ;;
fi
