#!/bin/bash
#########################################################
# SCRIPT  : testroot.sh                                 #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 3.10.1 or higher                      #
# TASKS   : Testing tails-administrator password        #
#                                                       #
# VERSION : 0.41                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 05-09-10                                    #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################

cat /home/amnesia/Persistent/scripts/password | sudo -S echo 1 > password_correct

