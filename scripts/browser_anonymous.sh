#!/bin/bash
#########################################################
# SCRIPT  : backup_to_ssh.sh                            #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 3.10.1 or higher                      #
# TASKS   : Start browser in anonymous mode             #
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


cd /home/amnesia/Persistent/scripts

if [ !  -d /home/amnesia/Persistent/settings/1  ]
then
    zenity --info  --text="Configuration ~/Persistent/settings/1 not found." &
    exit 1
fi

if [ -f /home/amnesia/Persistent/scripts/state/online ]
then
    chromium --proxy-server="socks5://127.0.0.1:9999" \
             --disable-logging \
             --incognito \
             --user-data-dir=/home/amnesia/Persistent/settings/1 \
             --disable-translate \
             --disable-plugins-discovery \
             www.startpage.com > /dev/null 2>&1 &
    exit 0
fi



if [ -f /home/amnesia/Persistent/scripts/state/offline ]
then
   zenity --info  --text="There is no active ssh-connection." &
fi

sleep 5
exit 1
