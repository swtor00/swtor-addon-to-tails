#!/bin/bash
#########################################################
# SCRIPT  : browser_fix.sh        	                #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 5.0 or higher                         #
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


cd /home/amnesia/Persistent/scripts

if [ -f /home/amnesia/Persistent/scripts/state/online ] ; then
    chromium --proxy-server="socks5://127.0.0.1:9999" \
             --disable-logging \
             --user-data-dir=/home/amnesia/Persistent/personal-files/3 \
             --disable-translate \
             --disable-plugins-discovery \
             www.startpage.com > /dev/null 2>&1 &
    exit 0
fi

sleep 5
exit 1
