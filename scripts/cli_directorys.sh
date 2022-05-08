#/bin/bash
#########################################################
# SCRIPT  : cli_directorys.sh                           #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 5.0 or higher                         #
#                                                       #
#                                                       #
# VERSION : 0.81                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 08-05-2022                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################


if [ ! -L ~/Persistent/settings ] ; then
   ln -s ~/Persistent/swtor-addon-to-tails/settings ~/Persistent/settings > /dev/null 2>&1
   echo "creating symlink ~/Persistent/settings"
else
   echo "symlink ~/Persistent/settings was allready made"
fi

if [ ! -L ~/Persistent/scripts ] ; then
   ln -s ~/Persistent/swtor-addon-to-tails/scripts  ~/Persistent/scripts > /dev/null 2>&1
   echo "creating symlink ~/Persistent/scripts"
else
   echo "symlink ~/Persistent/scripts was allready made"
fi

if [ ! -L ~/Persistent/swtorcfg ] ; then
   ln -s ~/Persistent/swtor-addon-to-tails/swtorcfg ~/Persistent/swtorcfg > /dev/null 2>&1
   echo "creating symlink ~/Persistent/swtorcfg"
else
   echo "symlink ~/Persistent/swtorcfg was allready made"
fi

if [ ! -L ~/Persistent/doc ] ; then
   ln -s ~/Persistent/swtor-addon-to-tails/doc ~/Persistent/doc > /dev/null 2>&1
   echo "creating symlink ~/Persistent/doc"
else
   echo "symlink ~/Persistent/doc was allready made"
fi

if [ ! -d ~/Persistent/swtor-addon-to-tails/swtorcfg/log ] ; then
   mkdir -p ~/Persistent/swtor-addon-to-tails/swtorcfg/log
   echo "directory ~/Persistent/swtor-addon-to-tails/swtorcfg/log created"
else
   echo "directory ~/Persistent/swtor-addon-to-tails/swtorcfg/log was allready made"
fi

if [ ! -d ~/Persistent/personal-files ] ; then
   mkdir -p ~/Persistent/personal-files
   mkdir -p ~/Persistent/personal-files/tails-repair-disk
   echo "directory ~/Persistent/personal-files created"
   echo "directory ~/Persistent/personal-files created/tails-repair-disk"
else
   echo "directory ~/Persistent/personal-files was allready made"
   if [ ! -d ~/Persistent/personal-files/tails-repair-disk ] ; then
       mkdir -p ~/Persistent/personal-files/tails-repair-disk
   fi
fi


