#!/bin/bash
#########################################################
# SCRIPT  : testroot.sh                                 #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 6.7 or higher                         #
#                                                       #
# VERSION : 0.83                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 19-09-2024                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################  
cd ~/Persistent/swtor-addon-to-tails/tmp

echo current directory : $(pwd)

cat password | sudo -S echo "1_234" > password_correct
exit 
