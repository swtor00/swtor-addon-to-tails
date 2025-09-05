#!/bin/bash
#########################################################
# SCRIPT  : browser_anonymous.sh                        #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 6.19 or higher                        #
#                                                       #
# VERSION : 0.85                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 05-09-2024                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################


cd /home/amnesia/Persistent/scripts

if [ -f /home/amnesia/Persistent/scripts/state/online ] ; then
    chromium --proxy-server="socks5://127.0.0.1:9999" \
             --disable-logging \
             --incognito \
             --user-data-dir=/home/amnesia/Persistent/settings/2 \
             --disable-translate \             
             --disable-webgl \
             --disable-webgl2 \
             --disable-plugins-discovery \
             www.startpage.com > /dev/null 2>&1 &
    exit 0
fi

sleep 5
exit 1
