#!/bin/bash
#########################################################
# SCRIPT  : update.sh                                   #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 6.9 or higher                         #
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


if [ "$TERMINAL_VERBOSE" == "" ];then
   echo "this shell-script can not longer direct executed over the terminal."
   echo "you have to call this shell-script over swtor-menu.sh"
   exit 1
fi

# Function from swtor-global.sh *
swtor_connected
if [ $? -eq 0 ] ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "connection check executed"
   fi
else
    exit 1
fi

zenity --question --width=600 --text="Please read this warning carefully.\n\nIf you update the addon, all local changes made by you,will be overwriten.\n\This also includes the configuration file swtor.cfg and all scripts.\n\nAre you sure, you would like to proceed with the update ?" > /dev/null 2>&1
case $? in
         0)
           cd ~/Persistent/swtor-addon-to-tails

           sleep 10 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n\nThe update is now executed. Please wait ! \n\n" > /dev/null 2>&1)

           show_wait_dialog && sleep 2

           git reset --hard > /dev/null 2>&1
           git pull --rebase=preserve --allow-unrelated-histories https://github.com/swtor00/swtor-addon-to-tails > /dev/null 2>&1


           end_wait_dialog && sleep 1

           if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo update was executed
           fi

           sleep 10 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n\nThe update is now completed ! \n\n" > /dev/null 2>&1)

         ;;
         1) if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo update will not be executed
            fi
         ;;
esac


exit 0










