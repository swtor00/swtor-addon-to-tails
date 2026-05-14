#!/bin/bash
#########################################################
# SCRIPT  : show-build-number.sh                        #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 7.7.3 or higher                       #
#                                                       #
# VERSION : 0.91                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 12-05-2026                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################

year=$(date +%Y)
month=$(date +%m)
day=$(date +%d)

echo $((($(date -d "$year-$month-$day" +%s) - $(date -d "1970-01-01" +%s))/86400))
