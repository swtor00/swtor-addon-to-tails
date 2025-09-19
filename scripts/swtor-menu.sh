#!/bin/bash
#########################################################
# SCRIPT  : swtor-menu.sh                               #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 7.0 or higher                         #
#                                                       #
# VERSION : 0.85                                        #
# STATE   : BETA                                        #
#                                                       #
# Main-Menu of of the swtor-addon-to-tails              #
#                                                       #
# DATE    : 19-09-2025                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################

# wrong order

if [ -f ~/Persistent/scripts/init.lock ] ; then
   echo wrong order of scripts
   exit 1
fi

# The following could happen
# Tails will be started normal with network enabled
# swtor-init.sh will be executed with rc=0
# 10  minutes later the user decide to
# switch to airplane-mode and all connections are gone

if [ -f ~/swtor_init ] ; then

   # swtor-init.sh is allready executed ....

   connect_lost=$(ip route | grep default)

   if [ "$connect_lost" == "" ] ; then
      sleep 10 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information"\
      --text="\n\nAirplane-Mode is active or no active Internet connection found after initialisation ! \n\n" > /dev/null 2>&1)
      exit 1
   else
      echo
   fi
fi


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

if grep -q "BROWSER-SOCKS5:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
     export BROWSER_SOCKS5="1"
else
     export BROWSER_SOCKS5="0"
fi

if grep -q "BYPASS-SOFTWARE-CHECK:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
     export BYPASS="1"
else
     export BYPASS="0"
fi

if grep -q "CHECK-EMPTY-SSH:NO" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
     export CHECK_SSH="0"
else
     export CHECK_SSH="1"
fi

if grep -q "AUTOCLOSE-BROWSER:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
     export AUTOCLOSE_BROWSER="1"
else
     export AUTOCLOSE_BROWSER="0"
fi


export TIMEOUT_TB=$(grep TIMEOUT-TB ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg | sed 's/[A-Z:-]//g')
export TIMEOUT_SSH=$(grep TIMEOUT-SSH ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg | sed 's/[A-Z:-]//g')
export XCLOCK_SIZE=$(grep XCLOCK-SIZE ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg | sed 's/[A-Z:-]//g')

export  DEBUGW="0"


source ~/Persistent/scripts/swtor-global.sh
global_init
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "global_init() done"
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "failure during initialisation of global-init() !"
       echo >&2 "swtor-menu.sh exiting with error-code 1"
    fi
    exit 1
fi

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
# After a successfull initialisation the file swtor_init will be created inside the home
# directory of the user amnesia ~/swtor_init.
# If you delete the file swtor_init with the command rm ~/swtor_init the complete
# process will start over again.

cd ~/Persistent/scripts
./swtor-init.sh yes

# Only on exeuction of swtor-init.sh  with exit code 0 ... ~/swtor_init exist

if [ ! -f ~/swtor_init ] ; then
         sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
          --text="\n\n    Error during the initialisation of the addon !  \n\n " > /dev/null 2>&1)
         swtor_cleanup
         exit 1
else

    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo initial-process has ben executed successfully
    fi

fi

# We are ready to start the watchdog script in the background

cd ~/Persistent/scripts/
./watchdog.sh & > /dev/null 2>&1
sleep 0.3

# Build main menu

menu=1
while [ $menu -eq 1 ]; do

       cd ~/Persistent/scripts

       if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo show main menu of addon
       fi

       if [ ! -d ~/Persistent/personal-files/3 ] ; then
            selection=$(zenity --width=600 --height=400 --list --hide-header --title "swtor-addon mainmenu" --column="ID"  --column="" \
            "1"  "[01]      Select SSH-Server to connect" \
            "2"  "[02]      ---------------------------------------------- " \
            "3"  "[03]      Browser for over ssh-socks 5 :Normal Profile" \
            "4"  "[04]      Browser for over ssh-socks 5 :Anonymous Profile" \
            "5"  "[05]      Utilitys & Help" \
            "6"  "[06]      Exit" \
            --hide-column=1 \
            --print-column=1)
            columm2="0"
       else
            selection=$(zenity --width=600 --height=400 --list --hide-header --title "swtor-addon mainmenu" --column="ID"  --column="" \
            "1"  "[01]      Select SSH-Server to connect" \
            "2"  "[02]      Browser for over ssh-socks 5 :Fixed Profile" \
            "3"  "[03]      Browser for over ssh-socks 5 :Normal Profile" \
            "4"  "[04]      Browser for over ssh-socks 5 :Anonymous Profile" \
            "5"  "[05]      Utilitys & Help" \
            "6"  "[06]      Exit" \
            --hide-column=1 \
            --print-column=1)
            columm2="1"
       fi

if [ -z ${selection} ]; then
   if [ ! -f ~/Persistent/scripts/state/online ] ; then
      menu=0
   else
      swtor_close_first
   fi
else

   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo chosen entry from menu :  $selection
   fi

   if [ $selection == "1" ] ; then
       if [ ! -f ~/Persistent/scripts/state/online ] ; then
          ./selector.sh
       else
          swtor_close_first
       fi
   fi

   if [ $selection == "2" ] ; then
   if [ $columm2 == "1" ] ; then
      if [ -f ~/Persistent/scripts/state/online ] ; then
         ./browser_fix.sh 2>&1 > /dev/null &
      else
         swtor_no_connection
      fi
   fi
   fi

   if [ $selection == "2" ] ; then
   if [ $columm2 == "0" ] ; then
       sleep 6 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
       --text="\n\n   This is not possible without a fixed profile !     \n\n" > /dev/null 2>&1)
       sleep 1
   fi
   fi

   if [ $selection == "3" ] ; then
      if [ -f ~/Persistent/scripts/state/online ] ; then
         ./browser_normal.sh 2>&1  > /dev/null &
      else
         swtor_no_connection
      fi
   fi

   if [ $selection == "4" ] ; then
      if [ -f ~/Persistent/scripts/state/online ] ; then
         ./browser_anonymous.sh 2>&1 > /dev/null &
      else
         swtor_no_connection
      fi
   fi

   if [ $selection == "5" ] ; then
      if [ ! -f ~/Persistent/scripts/state/online ] ; then
         ./swtor-tools.sh
      else
         swtor_close_first
      fi
   fi


   if [ $selection == "6" ] ; then
       if [ ! -f ~/Persistent/scripts/state/online ] ; then
          menu=0
       else
          swtor_close_first
       fi
   fi
fi

done


# remove lockdir ...

rmdir $lockdir 2>&1 >/dev/null

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo >&2 "successfully removed lock: $lockdir"
fi


swtor_cleanup
pkill watchdog.sh

# Increment startup value inside ~/Persistent/swtor-addon-to-tails/setup by one

oldnum=$(cat ~/Persistent/swtor-addon-to-tails/setup)
newnum=`expr $oldnum + 1`
echo $newnum > ~/Persistent/swtor-addon-to-tails/setup

exit 0



