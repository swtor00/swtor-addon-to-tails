#!/bin/bash
#########################################################
# SCRIPT  : cleanup.sh                                  #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.11 or higher                        #
# TASKS   : Clear all profiles and logs                 #
# links on the Desktop of tails.                        #
#                                                       #
# VERSION : 0.50                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 04-01-2020                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################


if [ -d /home/amnesia/Persistent/settings/1  ]
then
   rm -rf  ~/Persistent/settings/1 >/dev/null 2>&1
fi

if [ -d /home/amnesia/Persistent/settings/2  ]
then
  rm -rf  ~/Persistent/settings/2 >/dev/null 2>&1
fi

if [ -f /home/amnesia/Persistent/scripts/password ]
then
    cd /home/amnesia/Persistent/scripts
    rm password >/dev/null 2>&1
    rm password_correct >/dev/null 2>&1
fi

if [ -f /home/amnesia/Persistent/password ]
then
    cd /home/amnesia/Persistent
    rm password >/dev/null 2>&1
    rm password_correct >/dev/null 2>&1
fi

rm -rf /home/amnesia/Persistent/swtorcfg/*.arg > /dev/null 2>&1
rm -rf /home/amnesia/Persistent/swtorcfg/log/*.* > /dev/null 2>&1


