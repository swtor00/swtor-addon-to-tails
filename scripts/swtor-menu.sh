#!/bin/bash
#########################################################
# SCRIPT  : swtor-menu.sh                               #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.23 or higher                        #
#                                                       #
# VERSION : 0.60                                        #
# STATE   : BETA                                        #
#                                                       #
# Main-Menu of of the swtor-addon-to-tails              #
#                                                       #
# DATE    : 01-11-2021                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################


if grep -q "IMPORT-BOOKMARKS:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
   export IMPORT_BOOKMAKRS="1"
else
   export IMPORT_BOOKMAKRS="0"
fi

if grep -q "GUI-LINKS:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
   export GUI_LINKS="1"
else
   export GUI_LINKS="0"
fi

if grep -q "CHECK-UPDATE:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
   export CHECK_UPDATE="1"
else
   export CHECK_UPDATE="0"
fi

if grep -q "BACKUP-FIXED-PROFILE:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
   export BACKUP_FIXED_PROFILE="1"
else
   export BACKUP_FIXED_PROFILE="0"
fi

if grep -q "BACKUP_APT_LIST:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
     export BACKUP_APT_LIST="1"
else
     export BACKUP_APT_LIST="0"
fi

if grep -q "TERMINAL-VERBOSE:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
     export TERMINAL_VERBOSE="1"
else
     export TERMINAL_VERBOSE="0"
fi

export TIMEOUT_TB=$(grep TIMEOUT ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg | sed 's/[A-Z:-]//g')


function check_tor_network()
     {

      # Check to see if the ONION Network is allready runnig ....

      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo testing the internet-connection over the onion-network with TIMEOUT $TIMEOUT_TB
      fi

      curl --socks5 localhost:9050 --socks5-hostname localhost:9050 -s https://check.torproject.org/ -m $TIMEOUT_TB | grep -m 1 Congratulations > /dev/null 2>&1

      if [ $? -eq 0 ] ; then
         if [ $TERMINAL_VERBOSE == "1" ] ; then
            echo "TOR is up and running and we can continue with the execution of the script ...."
         fi
         sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n\nTesting the Internet connection over TOR was successful ! \n\n" > /dev/null 2>&1)
         exit 0

      else
           zenity --error --width=600 --text="\n\nInternet not ready or no active connection found ! \nPlease make a connection to the Internet first and try it again ! \n\n" > /dev/null 2>&1
           rmdir $lockdir > /dev/null 2>&1
           if [ $TERMINAL_VERBOSE == "1" ] ; then
              echo >&2 "TOR is not ready"
              echo >&2 "check_tor_network() exiting with error-code 1"
           fi
      exit 1
      fi
     }






# Creating the lockdirectory ....

lockdir=~/Persistent/scripts/menu.lock
if mkdir "$lockdir" > /dev/null 2>&1

   then
       # the directory did not exist, but was created successfully

       if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo >&2 "successfully acquired lock: $lockdir"
       fi
   else

       # failed to create the directory, presumably because it already exists

       if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo >&2 "cannot acquire lock, giving up on $lockdir"
          echo >&2 "swtor-menu.sh exiting with error-code 1"
       fi
       zenity --error --width=600 --text="Lockdirectory can not be created !"
       exit 1
fi






# On every single startup of Tails, the initial process of the addon has to be run once ...

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo starting initial-process of the addon
fi

sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Info" --text="Initialisation has started !" > /dev/null 2>&1)


if [ ! -f ~/swtor_init ] ; then
   ~/Persistent/scripts/init-swtor.sh
   if [ ! -f ~/swtor_init ] ; then
          sleep 6 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Info" --text="Error during the initialisation of the addon !" > /dev/null 2>&1)
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo >&2 "initial-process swtor-init.sh has terminated with error-code 1"
         echo >&2 "swtor-menu.sh exiting with error-code 1"
      fi
      rmdir $lockdir > /dev/null 2>&1
      exit 1
   fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo initial-process has ben executed successfully
    fi
    sleep 2 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Info" --text="Iinitialisation complete !" > /dev/null 2>&1)
fi

# show version of script prior to show menu

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo show info about addon
fi

cd ~/Persistent/scripts/
./swtor-about & 2>&1 > /dev/null
sleep 3
pkill swtor-about


# Build main menu

menu=1
while [ $menu -eq 1 ]; do

       cd ~/Persistent/scripts

       if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo show main menu of addon
       fi

       if [ ! -d "~/Peristent/personal-files/3" ]
          then
            selection=$(zenity --width=600 --height=400 --list --hide-header --title "swtor-addon mainmenu" --column="ID"  --column="" \
            "1"  "[01]  ->  Select SSH-Server to connect" \
            "2"  "[02]  ->  RESERVED-FOR-FIXED-PROFILE" \
            "3"  "[03]  ->  Browser for over ssh-socks 5 :Normal Profile" \
            "4"  "[04]  ->  Browser for over ssh-socks 5 :Anonymous Profile" \
            "5"  "[05]  ->  Utilitys & Help" \
            "6"  "[06]  ->  Exit" \
            --hide-column=1 \
            --print-column=1)
       else
            selection=$(zenity --width=600 --height=400 --list --hide-header --title "swtor-addon mainmenu" --column="ID"  --column="" \
            "1"  "[01]  ->  Select SSH-Server to connect" \
            "2"  "[02]  ->  Browser for over ssh-socks 5 :Fixed Profile" \
            "3"  "[03]  ->  Browser for over ssh-socks 5 :Normal Profile" \
            "4"  "[04]  ->  Browser for over ssh-socks 5 :Anonymous Profile" \
            "5"  "[05]  ->  Utilitys & Help" \
            "6"  "[06]  ->  Exit" \
            --hide-column=1 \
            --print-column=1)
       fi

if [ -z ${selection} ]; then
   menu=0
else
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo chosen entry from menu :  $selection
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
fi

done


# remove lockdir ...

rmdir $lockdir 2>&1 >/dev/null

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo >&2 "successfully removed lock: $lockdir"
fi

exit 0



