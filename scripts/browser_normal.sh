#!/bin/bash
#########################################################
# SCRIPT  : browser_normal.sh                           #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.14 or higher                        #
#                                                       #
# VERSION : 0.52                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 30-12-2020                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################


cd /home/amnesia/Persistent/scripts

if [ ! -d /home/amnesia/Persistent/settings/2  ]
then
    zenity --info --width=600 --text="Configuration ~/Persistent/settings/2 not found." &
    exit 1
fi

if [ -f /home/amnesia/Persistent/scripts/state/online ]
then
    chromium --proxy-server="socks5://127.0.0.1:9999" \
             --disable-logging \
             --user-data-dir=/home/amnesia/Persistent/settings/2 \
             --disable-translate \
             --disable-plugins-discovery \
             www.startpage.com > /dev/null 2>&1 &
    exit 0
fi

if [ -f /home/amnesia/Persistent/scripts/state/offline ]
then
   zenity --info --width=600 --text="There is no active ssh-connection." &
fi

sleep 5
exit 1
