#/bin/bash
#########################################################
# SCRIPT  : cli_tweak.sh                                #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 5.0 or higher                         #
#                                                       #
#                                                       #
# VERSION : 0.81                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 08-05-2022                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################

gsettings set org.gnome.nautilus.preferences executable-text-activation 'launch'
gsettings set org.gtk.Settings.FileChooser show-hidden true

dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/background-color "'rgb(0,43,54)'"
dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/use-theme-colors "false"
dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/foreground-color "'rgb(131,148,150)'"
dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/use-system-font "false"
dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/font "'Noto Mono 12'"

if [ ! -d ~/Pictures/Wallpapers ] ; then
   mkdir ~/Pictures/Wallpapers > /dev/null 2>&1
   cp ~/Persistent/doc/swtor-desktop-freezed.jpeg ~/Pictures/Wallpapers > /dev/null 2>&1
fi

# If someone is using a other language than english, the folder Pictures needs to be created

if [ ! -f ~/Pictures ] ; then
   mkdir ~/Pictures > /dev/null 2>&1
fi

dconf write  /org/gnome/desktop/background/picture-uri "'file:///home/amnesia/Pictures/Wallpapers/swtor-desktop-freezed.jpeg'"


# Create symbolic link on desktop

if [ ! -L ~/Desktop/swtor-menu.sh ] ; then
   ln -s ~/Persistent/scripts/swtor-menu.sh ~/Desktop/swtor-menu.sh
fi

sleep 1





