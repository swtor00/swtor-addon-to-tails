#!/bin/bash
#########################################################
# SCRIPT  : pwait2.sh                                   #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 6.14.1 or higher                      #
#                                                       #
# VERSION : 0.83                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 01-11-2024                                  #
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
