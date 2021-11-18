#!/bin/bash
#########################################################
# SCRIPT  : wait.sh                                     #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.24 or higher                        #
#                                                       #
# VERSION : 0.60                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 17-11-2021                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################

cd ~/Persistent/scripts

./pwait1.sh > /dev/null &

menu=1
while [ $menu -gt 0 ]; do
      sleep 1
      if [ -f ~/Persistent/swtor-addon-to-tails/tmp/w-end ]  ; then
         rm ~/Persistent/swtor-addon-to-tails/tmp/w-end > /dev/null
         kill -15 $(ps axu | grep please | grep zenity | awk {'print $2'}) > /dev/null
         menu=0
      else
          ((menu++))
      fi
done


exit 0
