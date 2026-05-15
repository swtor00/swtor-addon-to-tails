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

sleep 1
curl --socks5 127.0.0.1:9050 -m 2 https://tails.net/home/index.en.html > /dev/null 2>&1

if [ $? -eq 0 ] ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo tor is ready !
   fi
   break
else
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo tor is not ready !
   fi
fi

wget -O ~/Persistent/swtor-addon-to-tails/deb/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

cd ~/Persistent/swtor-addon-to-tails/deb
dpkg-deb -x chrome.deb ~/Persistent/swtor-addon-to-tails/deb
rm -rf etc
mv opt/google/chrome/WidevineCdm/ .
rm -rf opt
rm -rf usr
rm ~/Persistent/swtor-addon-to-tails/deb/chrome.deb
exit 0





