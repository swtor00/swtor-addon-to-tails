#!/bin/bash
#########################################################
# SCRIPT  : cli_freezing.sh                             #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.28 or higher                        #
#                                                       #
# VERSION : 0.80                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 13-03-2022                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################

if [ ! -f ~/Persistent/swtorcfg/freezed.cgf ] ; then

  mkdir /live/persistence/TailsData_unlocked/dotfiles/.config > /dev/null 2>&1

  cp -r ~/.config/dconf /live/persistence/TailsData_unlocked/dotfiles/.config > /dev/null 2>&1
  cp -r ~/.config/gtk-3.0 /live/persistence/TailsData_unlocked/dotfiles/.config > /dev/null 2>&1
  cp -r ~/.config/pulse /live/persistence/TailsData_unlocked/dotfiles/.config > /dev/null 2>&1
  cp -r ~/.config/ibus /live/persistence/TailsData_unlocked/dotfiles/.config > /dev/null 2>&1
  cp -r ~/.config/nautilus /live/persistence/TailsData_unlocked/dotfiles/.config > /dev/null 2>&1
  cp -r ~/.config/gnome-session /live/persistence/TailsData_unlocked/dotfiles/.config > /dev/null 2>&1
  cp -r ~/Desktop /live/persistence/TailsData_unlocked/dotfiles > /dev/null 2>&1

  # If someone is using a other language than english, the folder Pictures needs to be created

  if [ ! -f ~/Pictures ] ; then
      mkdir ~/Pictures > /dev/null 2>&1
  fi
  cp -r ~/Pictures /live/persistence/TailsData_unlocked/dotfiles > /dev/null 2>&1

  # Do markup the version of Tails we used to freezing ... we store it right here

  tails-version > ~/Persistent/swtorcfg/freezed.cgf

else
   echo "freezing is not possible. This system is allready freezed"
   echo "according to the ~/Persistent/swtorcfg/freezed.cfg"
fi


