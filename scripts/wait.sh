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

cd ~/Persistent/swtor-addon-to-tails/scripts

# We have to be sure that w-end not exist

if [ -f ~/Persistent/swtor-addon-to-tails/tmp/w-end ]  ; then
    rm ~/Persistent/swtor-addon-to-tails/tmp/w-end > /dev/null
fi

./pwait1.sh &

pid=$$
menu=1
while [ $menu -gt 0 ]; do
      if [ -f ~/Persistent/swtor-addon-to-tails/tmp/w-end ]  ; then
            rm ~/Persistent/swtor-addon-to-tails/tmp/w-end > /dev/null
         pkill -15 -P $(cat $global_tmp/pid_wait) > /dev/null
         menu=0
      else
        ((menu++))
      fi
done
pkill -15  -P$pid > /dev/null
exit 0