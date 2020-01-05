#!/bin/bash
#########################################################
# SCRIPT  : swtor-menu.sh                               #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.1.1 or higher                       #
# TASKS   : Nainmenu of all swtor-functions             #
#                                                       #
# VERSION : 0.51                                        #
# STATE   : BETA                                        #
#                                                       #
# Main-Menu of of the swtor-addon-to-tails              #
#                                                       #
# DATE    : 05-01-2020                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################


# On every startup of Tails, the initial process of the addon has to be run once

if [ ! -f ~/swtor_init ]
   then
   echo init not done

   sleep 2 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Starting initialization of addon  ..,," > /dev/null 2>&1)

   # We call it now ..
  
   ~/Persistent/scripts/init-swtor.sh
   if [ ! -f ~/swtor_init ]
      then
          zenity --error --width=600 --text "The initial-process has failed !"
      exit 1
   fi
   sleep 2 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Addon initialized  .. done" > /dev/null 2>&1)
fi

# Check to see if TOR is allready runnig ....

curl --socks5 localhost:9050 --socks5-hostname localhost:9050 -s https://check.torproject.org/ | cat | grep -m 1 Congratulations
if [ $? -eq 0 ] ; then
   echo TOR is running and we can continue with the execution of the script ....
else
  sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="TOR Network is not ready !" > /dev/null 2>&1)
  exit 1
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



