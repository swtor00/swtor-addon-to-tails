#!/bin/bash
#########################################################
# SCRIPT  : update.sh                                   #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.14 or higher                        #
#                                                       #
# VERSION : 0.52                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 25-12-2020                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################

# Is this script controlled with git or not ?

if [ ! -d ~/Persistent/swtor-addon-to-tails/.git ]
    then
        yad --title="Information " --width=400 --height=100 --no-buttons --center --timeout=8  --no-buttons --text="\n\nAddon has no .git directory.\nThis means that this addon isn't controlled by git."
        exit 1
fi

# In the case, that someone changed the current confiuration-file
# we copy the current config swtor.cfg

cp ~/Persistent/swtorcfg/swtor.cfg ~/Persistent/swtorcfg/swtor.old-config
cd ~/Persistent/swtor-addon-to-tails

git pull --rebase=preserve --allow-unrelated-histories https://github.com/swtor00/swtor-addon-to-tails







