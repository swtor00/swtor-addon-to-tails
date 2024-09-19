#/bin/bash
#########################################################
# SCRIPT  : swtor-tweak-gui.sh                          #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 6.7 or higher                         #
#                                                       #
#                                                       #
# VERSION : 0.83                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 11-09-2024                                  #
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

gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.settings-daemon.plugins.power idle-dim false

# There is now video-conference software that works on tails ....

gsettings set org.gnome.desktop.privacy disable-camera true
gsettings set org.gnome.desktop.privacy disable-microphone true


gsettings set org.gnome.system.location enabled false
gsettings set org.gnome.desktop.privacy remember-recent-files false


gsettings set org.gnome.desktop.background show-desktop-icons true
gsettings set org.gnome.nautilus.preferences show-hidden-files true


# Starting with Tails 6.X this entry is useless 

#########################################################
# run all executables over the gui of Tails             #
#########################################################
# dconf entry                                           #
# [org/gnome/nautilus/preferences]                      #
# executable-text-activation='launch'                   #
#########################################################
# gsettings set org.gnome.nautilus.preferences executable-text-activation 'launch'

# Starting with Tails 6.X this entry is useless

#########################################################
# show hidden files with Nautilus (beginning with a .)  #
#########################################################
# dconf entry                                           #
# [org/gtk/settings/file-chooser]                       #
# show-hidden=true                                      #
#########################################################
# gsettings set org.gtk.Settings.FileChooser show-hidden true

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
zenity --question --width=600 --text="Would you like to change the color of the Terminal inside Tails ?\nIf you are working very often with the Terminal I would say yes here, otherwise anwser no.\n\nFor me was the Terminal of Tails allmost not readable with the current color, so I made this little change."  > /dev/null 2>&1
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
# change solid background from Tails to a image that show us, we are freezed         #
######################################################################################
# dconf entry                                                                        #
# [org/gnome/desktop/background]                                                     #
#  picture-uri='file:///home/amnesia/Pictures/Wallpapers/swtor-desktop-freezed.jpeg' #
######################################################################################


zenity --question --width=600 --text="Would you like to change the solid background to a picture of the addon ?\n\n"  > /dev/null 2>&1
case $? in
         0)
           if [ ! -d ~/Pictures/Wallpapers ] ; then
              mkdir ~/Pictures/Wallpapers
              cp ~/Persistent/doc/swtor-desktop-freezed.jpeg ~/Pictures/Wallpapers
           fi
           dconf write  /org/gnome/desktop/background/picture-uri "'file:///home/amnesia/Pictures/Wallpapers/swtor-desktop-freezed.jpeg'"
           if [ $TERMINAL_VERBOSE == "1" ] ; then
              echo >&2 "desktop wallpaper changed"
           fi
           ;;
         1)
           if [ $TERMINAL_VERBOSE == "1" ] ; then
              echo >&2 "background color remains at it is ... no changing."
           fi
           ;;
esac

# Create symbolic link on persistent
# After Tails 6.x there are no longer any icons on the Desktop

if [ $GUI_LINKS == "1" ] ; then
    if [ ! -L ~/Persistent/START.sh ] ; then
       ln -s ~/Persistent/scripts/swtor-menu.sh ~/Persistent/START.sh
       if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo symlink created
       fi
    else
       if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo symlink allready exist
       fi
    fi
fi







