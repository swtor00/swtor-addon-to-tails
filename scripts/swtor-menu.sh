#!/bin/bash
#########################################################
# SCRIPT  : swtor-menu.sh                               #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.14 or higher                        #
#                                                       #
# VERSION : 0.52                                        #
# STATE   : BETA                                        #
#                                                       #
# Main-Menu of of the swtor-addon-to-tails              #
#                                                       #
# DATE    : 25-12-2020                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################


# On every single startup of Tails, the initial process of the addon has to be run once ...

notify-send Info "Starting addon ..."

sleep 1

if [ ! -f ~/swtor_init ]
   then
   ~/Persistent/scripts/init-swtor.sh
   if [ ! -f ~/swtor_init ]
      then
          notify-send Error "Error during initialisation of addon  ..."
          sleep 2
      exit 1
   fi
else  
    echo initial-process has ben executed with error-code 0 ... 
fi




# Build main menu

menu=1
while [ $menu -eq 1 ]; do

      cd ~/Persistent/scripts

       selection=$(zenity --width=600 --height=400 --list --hide-header --title "swtor-addon mainmenu" --column="ID"  --column="" \
       "1"  "[01]  ->  Select SSH-Server to connect" \
       "2"  "[02]  ->  Browser for over ssh-socks 5 :Fixed Profile" \
       "3"  "[03]  ->  Browser for over ssh-socks 5 :Normal Profile" \
       "4"  "[04]  ->  Browser for over ssh-socks 5 :Anonymous Profile" \
       "5"  "[05]  ->  Utilitys & Help" \
       "6"  "[06]  ->  Exit" \
       --hide-column=1 \
       --print-column=1)

if [ "$selection" == "" ] ; then
    menu=0
fi


if [ $selection == "1" ] ; then
   ./selector.sh 2>&1  > /dev/null 
fi

if [ $selection == "2" ] ; then
   ./browser_fix.sh 2>&1 > /dev/null &
fi

if [ $selection == "3" ] ; then
   ./browser_normal.sh 2>&1 > /dev/null &
fi

if [ $selection == "4" ] ; then
   ./browser_anonymous.sh 2>&1 > /dev/null &
fi

if [ $selection == "5" ] ; then
   ./swtor-tools.sh
fi

if [ $selection == "6" ] ; then
   menu=0
fi

done

exit 0



