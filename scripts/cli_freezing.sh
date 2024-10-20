#!/bin/bash
#########################################################
# SCRIPT  : cli_freezing.sh                             #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 6.81 or higher                        #
#                                                       #
# VERSION : 0.83                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 15-10-2024                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################

if [ ! -f ~/swtor_init ] ; then
    echo addon is not initialized !
    echo start swtor-menu.sh first
fi


if [ ! -f ~/Persistent/swtorcfg/freezed.cgf ] ; then

   # Create autostart folder and place desktop file inside

   cd ~/.config > /dev/null 2>&1
   mkdir autostart > /dev/null 2>&1
   cd autostart
   cp /usr/share/applications/swtor-init.desktop .

   mkdir /live/persistence/TailsData_unlocked/dotfiles/.config > /dev/null 2>&1

   cp -r ~/.config  /live/persistence/TailsData_unlocked/dotfiles/  > /dev/null 2>&1

   if [ ! -f ~/Pictures ] ; then
      mkdir ~/Pictures > /dev/null 2>&1
   fi
   cp -r ~/Pictures /live/persistence/TailsData_unlocked/dotfiles > /dev/null 2>&1

  # Do markup the version of Tails we used to freezing ... we store it right here
  # the command tails-version is obsolete in Tails 6.X

   cat /etc/os-release | grep VERSION |sed "s/[^0-9.]*//g" > ~/Persistent/swtorcfg/freezed.cgf

else
   echo "freezing is not possible. This system is allready freezed"
   echo "according to the ~/Persistent/swtorcfg/freezed.cfg"
fi


