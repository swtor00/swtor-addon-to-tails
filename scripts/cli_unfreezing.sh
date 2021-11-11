#!/bin/bash
#########################################################
# SCRIPT  : cli_unfreezing.sh                           #
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
# DATE    : 09-11-2021                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################


rm -rf /live/persistence/TailsData_unlocked/dotfiles/.config > /dev/null 2>&1
rm -rf /live/persistence/TailsData_unlocked/dotfiles/Desktop > /dev/null 2>&1
rm -rf /live/persistence/TailsData_unlocked/dotfiles/Pictures > /dev/null 2>&1

rm ~/Persistent/swtorcfg/freezed.cgf > /dev/null 2>&1

