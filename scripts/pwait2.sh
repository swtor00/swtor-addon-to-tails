#!/bin/bash
#########################################################
# SCRIPT  : pwait2.sh                                   #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 5.0 or higher                         #
#                                                       #
# VERSION : 0.80                                        #
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

pid=$$
echo process pwait2.sh $pid
echo global_tmp is defined as $global_tmp
echo $pid > $global_tmp/pid_wait
sleep 800 |  tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n              [ Please wait ]               \n")

pkill -15 -P $pid
exit 0
