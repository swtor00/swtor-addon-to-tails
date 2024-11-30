#!/bin/bash
#########################################################
# SCRIPT  : cli_unfreezing.sh                           #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 6.10 or higher                        #
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

if [ -f ~/Persistent/swtorcfg/freezed.cgf ] ; then
   rm -rf /live/persistence/TailsData_unlocked/dotfiles/.config > /dev/null 2>&1
   rm -rf /live/persistence/TailsData_unlocked/dotfiles/Pictures > /dev/null 2>&1
   rm ~/Persistent/swtorcfg/freezed.cgf > /dev/null 2>&1
   
   echo ---------------------------------------
   echo please make a reboot of Tails ASAP !!!!
   echo ---------------------------------------
else
   echo "unfreezing is not possible. This system is not freezed"

   # but wait .. there is one option we should think about
   # the user has removed dotfiles option and the system is in state freezed

   rm -rf /live/persistence/TailsData_unlocked/dotfiles/Pictures > /dev/null 2>&1
   rm -rf /live/persistence/TailsData_unlocked/dotfiles/.config > /dev/null 2>&1

fi


