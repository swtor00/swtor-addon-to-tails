#/bin/bash
#########################################################
# SCRIPT  : cli_create_fixed_profile.sh                 #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.24 or higher                        #
#                                                       #
#                                                       #
# VERSION : 0.60                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 07-11-21                                    #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################


if [ -d ~/Persistent/personal-files/3 ] ; then
   rmdir ~/Persistent/personal-files/3
fi

cd ~/Persistent/settings
tar xzf tmp.tar.gz > /dev/null 2>&1

mkdir ~/Persistent/personal-files/3 > /dev/null 2>&1
cp -r ~/Persistent/settings/2 ~/Persistent/personal-files/3 > /dev/null 2>&1

