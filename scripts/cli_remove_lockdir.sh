#/bin/bash
#########################################################
# SCRIPT  : cli_remove_lockdir.sh                       #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 6.19 higher                      #
#                                                       #
# VERSION : 0.85                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 05-09-2025                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################

if [ -d ~/Persistent/scripts/init.lock ] ; then
   rm ~/Persistent/scripts/init.lock > /dev/null 2>&1
fi

if [ -d ~/Persistent/scripts/setup.lock ] ; then
   rm ~/Persistent/scripts/setup.lock > /dev/null 2>&1
fi 

if [ -d ~/Persistent/scripts/menu.lock ] ; then
   rm ~/Persistent/scripts/menu.lock > /dev/null 2>&1
fi


