#!/bin/bash
#########################################################
# SCRIPT  : testroot.sh                                 #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.111 or higher                       #
# TASKS   : Testing tails-administrator password        #
#                                                       #
# VERSION : 0.50                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 02-01-2020                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################

cat /home/amnesia/Persistent/scripts/password | sudo -S echo 1 > password_correct

