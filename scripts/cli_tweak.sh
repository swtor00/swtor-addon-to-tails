#/bin/bash
#########################################################
#########################################################
# SCRIPT  : cli_tweak.sh                                #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 7.0 or higher                         #
#                                                       #
#                                                       #
# VERSION : 0.85                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
# DATE    : 21-09-2025                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################

# There is no video-conference software that works on tails ....
# And why in hell is this setting enabled by default ???

gsettings set org.gnome.desktop.privacy disable-camera true
gsettings set org.gnome.desktop.privacy disable-microphone true

# I would like to see all files including the hidden ones ...

gsettings set org.gtk.gtk4.Settings.FileChooser show-hidden true

# I don't like the Hot-Corners .... disable it

gsettings set org.gnome.desktop.interface enable-hot-corners false

# I don't like History ... at least inside my Tails ....

gsettings set org.gnome.desktop.privacy remember-recent-files false

# The default terminal color is bullshit to work with on the commandline 

dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/background-color "'rgb(0,43,54)'"
dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/use-theme-colors "false"
dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/foreground-color "'rgb(131,148,150)'"
dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/use-system-font "false"
dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/font "'Noto Mono 12'"

if [ ! -d ~/Pictures/Wallpapers ] ; then
   mkdir ~/Pictures/Wallpapers > /dev/null 2>&1
   cp ~/Persistent/doc/swtor-desktop-freezed.jpeg ~/Pictures/Wallpapers > /dev/null 2>&1

   # We need this file later for the activation of Dark-Mode 

   cp ~/Persistent/doc/swtor-desktop-freezed.jpeg ~/.config/background > /dev/null 2>&1
fi

if [ ! -f ~/Pictures ] ; then
   mkdir ~/Pictures > /dev/null 2>&1
fi

dconf write  /org/gnome/desktop/background/picture-uri "'file:///home/amnesia/Pictures/Wallpapers/swtor-desktop-freezed.jpeg'"

# It was very tricky to activate Dark-Mode with Tails
# By  now all is ready with the execption of the Dark-Mode
# If we freeze ... we should have a dark Tails
# At least it works if I activate the dark mode and change the background by hand
# And the following line of Code also work perfect ....

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
dconf write  /org/gnome/desktop/background/picture-uri-dark "'file:///home/amnesia/.config/background'"












