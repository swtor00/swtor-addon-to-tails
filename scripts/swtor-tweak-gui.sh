#/bin/bash
#########################################################
# SCRIPT  : swtor-tweak-gui.sh                          #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.24 or higher                        #
#                                                       #
#                                                       #
# VERSION : 0.60                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 07-11-21                                    #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################


#########################################################
# run all executables over the gui of Tails             #
#########################################################
# dconf entry                                           #
# [org/gnome/nautilus/preferences]                      #
# executable-text-activation='launch'                   #
#########################################################
gsettings set org.gnome.nautilus.preferences executable-text-activation 'launch'


#########################################################
# show hidden files with Nautilus (beginning with a .)  #
#########################################################
# dconf entry                                           #
# [org/gtk/settings/file-chooser]                       #
# show-hidden=true                                      #
#########################################################
gsettings set org.gtk.Settings.FileChooser show-hidden true


#########################################################
# some changes to the gnome-terminal                    #
#########################################################
# dconf entry                                           #
# [org/gnome/terminal/legacy/profiles                   #
#  :/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9]             #
# background-color='rgb(0,43,54)'                       #
# use-theme-colors=false                                #
# foreground-color='rgb(131,148,150)'                   #
# use-system-font=false                                 #
# font='Noto Mono 12'                                   #
#########################################################


