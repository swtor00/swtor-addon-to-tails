#!/bin/bash
#########################################################
# SCRIPT  : startup.sh                                  #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.24 or higher                        #
#                                                       #
# VERSION : 0.60                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 04-11-2021                                  #
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

source ~/Persistent/scripts/swtor-global.sh

# the following global variables are exported from the main
# script swtor-menu.sh and are visible here.
#
# IMPORT_BOOKMAKRS
# GUI_LINKS
# CHECK_UPDATE
# BACKUP_FIXED_PROFILE
# BACKUP_APT_LIST
# TERMINAL_VERBOSE
# TIMEOUT_TB


# Has setup ever run on this tails system ?
# Prior to use the menu, you have to execute the script swtor-setup.sh

if [ !  -f ~/Persistent/swtor-addon-to-tails/setup ] ; then
   sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information"\
    --text="\n\n                Please execute the command \"setup-swtor.sh\" first !                  \n\n" > /dev/null 2>&1)
   exit 1
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo "step01 : setup-swtor has ben executed once ....  "
    fi
fi


# This script has to be run only once ... no more

if [ -f ~/swtor_init ] ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "startup.sh was allready executed once"
   fi
   sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information"\
   --text="\n\n                 The command \"startup.sh\" was allready executed !                    \n\n" > /dev/null 2>&1)
   exit 0
fi


# Check the TOR-Connection over Internet

check_tor_network
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "step02 : Tor over internet is working as expected  ....  "
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "no active internet connection found !"
       echo >&2 "startup.sh exiting with error-code 1"
    fi
    exit 1
fi

# check empty ~/.ssh directory

test_empty_ssh
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "step03 : ~/.ssh for user amnesia is not empty ! "
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "~/.ssh is empty !"
       echo >&2 "startup.sh exiting with error-code 1"
    fi
    exit 1
fi


# test for installed yad from persistent volume

test_for_yad
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "step04 : yad is installed  ! "
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "yad is not installed !"
       echo >&2 "startup.sh exiting with error-code 1"
    fi
    exit 1
fi


# test for installed sshpass from persistent volume

test_for_sshpass
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "step05 : sshpass is installed  ! "
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "sshpass is not installed !"
       echo >&2 "startup.sh exiting with error-code 1"
    fi
    exit 1
fi


# test for installed html2text from persistent volume

test_for_html2text
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "step06 : html2text is installed  ! "
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "html2text is not installed !"
       echo >&2 "startup.sh exiting with error-code 1"
    fi
    exit 1
fi


# test for installed chromium from persistent volume

test_for_chromium
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "step07 : chromium is installed  ! "
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "chromium is not installed !"
       echo >&2 "startup.sh exiting with error-code 1"
    fi
    exit 1
fi


# test for installed chromium-sandbox from persistent volume

test_for_chromium-sandbox
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "step08 : chromium-sandbox is installed  ! "
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "chromium-sandbox is not installed !"
       echo >&2 "startup.sh exiting with error-code 1"
    fi
    exit 1
fi


# Check for a existing administration password on startup of Tails ?

test_password_greeting
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "step09 : password was set on startup of Tails  ! "
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "no password set on startup !"
       echo >&2 "starteup.sh exiting with error-code 1"
    fi
    rmdir $lockdir > /dev/null 2>&1
    exit 1
fi


# Ask for the administration password and store it in the tmp directory

test_admin_password
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "step10 : password was correct and stored ! "
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "password was 3 times wrong"
       echo >&2 "startupsh exiting with error-code 1"
    fi
    rmdir $lockdir > /dev/null 2>&1
    exit 1
fi


# test for a frezzed system and comparing the state of a freezed system  with the current Tails

test_for_freezed
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "step11 : system not freezed or if freezed the system do match together ! "
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "freezed system missmatch !"
       echo >&2 "startup.sh exiting with error-code 1"
    fi
    exit 1
fi



# change the firewall to accept a socks5 server on port 9999

change_tails_firewall
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "step12 : changed firewall settings for socks5 server !"
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "firewall was not changed because configuration"
       echo >&2 "startup.sh exiting with error-code 1"
    fi
    rmdir $lockdir > /dev/null 2>&1
    exit 1
fi





# cleanup old connection-files file inside cfg directory

rm -rf /home/amnesia/Persistent/swtorcfg/*.arg > /dev/null 2>&1
rm -rf /home/amnesia/Persistent/swtorcfg/log/*.* > /dev/null 2>&1


# cleanup all browser-settings and extract all settings from tar file

if [ -d /home/amnesia/Persistent/settings/1  ] ; then
   rm -rf  ~/Persistent/settings/1 >/dev/null 2>&1
fi

if [ -d /home/amnesia/Persistent/settings/2  ] ; then
  rm -rf  ~/Persistent/settings/2 >/dev/null 2>&1
fi


# Test the state of the connection

if [ -f /home/amnesia/Persistent/scripts/state/online ] ; then
    cd /home/amnesia/Persistent/scripts/state
    rm online
fi


echo 1 > /home/amnesia/Persistent/scripts/state/offline


# We are done here , signal with Error Code 0

echo 1 > ~/swtor_init

exit 0

