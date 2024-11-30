#/bin/bash
#########################################################
# SCRIPT  : cli_create_fixed_profile.sh                 #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 6.10 or higher                        #
#                                                       #
#                                                       #
# VERSION : 0.83                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 01-11-2024                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################



if [ -d ~/Persistent/personal-files/3 ] ; then
   echo "removed old profile ~/Persistent/personal-files/3"
   rm -rf ~/Persistent/personal-files/3
else
   echo "~/Persistent/personal-files/3 did not exist"
fi


cd ~/Persistent/settings
tar xzf tmp.tar.gz > /dev/null 2>&1

mv  ~/Persistent/settings/2 ~/Persistent/personal-files/
mv  ~/Persistent/personal-files/2 ~/Persistent/personal-files/3

rm  -rf ~/Persistent/settings/1  > /dev/null 2>&1

