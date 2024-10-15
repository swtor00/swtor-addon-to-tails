#!/bin/bash
#########################################################
# SCRIPT  : cleanup.sh                                  #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 6.81 or higher                        #
#                                                       #
# VERSION : 0.83	                                #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 14-04-2023                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################


if [ -d /home/amnesia/Persistent/settings/1  ] ; then
   rm -rf  ~/Persistent/settings/1 >/dev/null 2>&1
fi

if [ -d /home/amnesia/Persistent/settings/2  ] ; then
   rm -rf  ~/Persistent/settings/2 >/dev/null 2>&1
fi

if [ -f /home/amnesia/Persistent/swtor-addon-to-tails/tmp/password ] ; then
   cd /home/amnesia/Persistent/swtor-addon-to-tails/tmp
   rm password >/dev/null 2>&1
fi

rm -rf /home/amnesia/Persistent/swtorcfg/*.arg > /dev/null 2>&1

# This here is very important ! If we can connect to remote host
# without any problem, we don't need longer the log-files.
# But in case  we have some trouble ... we need them !

if [ ! -f /home/amnesia/Persistent/scripts/state/error ] ; then
     rm -rf /home/amnesia/Persistent/swtorcfg/log/*.* > /dev/null 2>&1
fi


