#!/bin/bash
#########################################################
# SCRIPT  : cli_get_chrome.sh                           #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 7.7.3 or higher                       #
#                                                       #
# VERSION : 0.91                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 12-05-2026                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################

wget -O ~/Persistent/swtor-addon-to-tails/deb/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

cd ~/Persistent/swtor-addon-to-tails/deb
dpkg-deb -x chrome.deb ~/Persistent/swtor-addon-to-tails/deb
rm -rf etc
mv opt/google/chrome/WidevineCdm/_platform_specific/linux_x64/libwidevinecdm.so .
rm -rf opt
rm -rf usr
rm ~/Persistent/swtor-addon-to-tails/deb/chrome.deb
exit 0





