#!/bin/bash
#########################################################
# SCRIPT  : update.sh                                   #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 3.10.1 or higher                      #
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

# Check to see if  TOR is allready runnig ....

/usr/local/sbin/tor-has-bootstrapped
if [ $? -eq 0 ] ; then
    echo TOR is running and we can continue to execute the script ....
else
    sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="TOR Network is not ready !" > /dev/null 2>&1)
    exit 1
fi


# Is this script controlled with git or not ?

if [ ! -d ~/Persistent/swtor-addon-to-tails/.git ]
   then
       zenity --info  --text="Addon has no .git directory inside of ~/Persistent/swtor-addon-to-tails !"  > /dev/null 2>&1
       exit 1
fi

# In the case, that someone changed the confiuration-file
# we copy the current config swtor.cfg

cp ~/Persistent/swtorcfg/swtor.cfg ~/Persistent/swtorcfg/swtor.old-config

cd ~/Persistent/swtor-addon-to-tails

git pull --rebase=preserve --allow-unrelated-histories https://github.com/swtor00/swtor-addon-to-tails







