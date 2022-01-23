#/bin/bash
#########################################################
# SCRIPT  : restore.sh                                  #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.25 or higher                        #
#                                                       #
# VERSION : 0.60                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 03-01-2022                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################

export CLI_OUT="0"

function killCMD() {
  pid=$(ps axu | grep zenity | grep progress | awk {'print $2'})
  set +m && kill $pid > /dev/null 2>&1 &
}

export -f killCMD

