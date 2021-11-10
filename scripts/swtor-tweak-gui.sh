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
# some changes to the terminal for better reading       #
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
zenity --question --width=600 --text="Would you like to change the color of the Terminal inside Tails ?\nIf you are working very often with the Terminal I would say yes here, otherwise anwser no.\n\nFor me was the standard contrast of the Terminal of Tails allmost not readable so I made this little change."  > /dev/null 2>&1
case $? in
         0)
           dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/background-color "'rgb(0,43,54)'"
           dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/use-theme-colors "false"
           dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/foreground-color "'rgb(131,148,150)'"
           dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/use-system-font "false"
           dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/font "'Noto Mono 12'"
           if [ $TERMINAL_VERBOSE == "1" ] ; then
              echo >&2 "terminal color changed"
           fi
           ;;

         1)
           if [ $TERMINAL_VERBOSE == "1" ] ; then
              echo >&2 "terminal color is unchanged"
           fi
           ;;
esac

######################################################################################
# change solid background from Tails to a image that reflects we are freezed         #
######################################################################################
# dconf entry                                                                        #
# [org/gnome/desktop/background]                                                     #
#  picture-uri='file:///home/amnesia/Pictures/Wallpapers/swtor-desktop-freezed.jpeg' #
######################################################################################

if [ ! -d ~/Pictures/Wallpapers ] ; then
   mkdir ~/Pictures/Wallpapers
   cp ~/Persistent/doc/swtor-desktop-freezed.jpeg ~/Pictures/Wallpapers
fi

dconf write  /org/gnome/desktop/background/picture-uri "'file:///home/amnesia/Pictures/Wallpapers/swtor-desktop-freezed.jpeg'"





