#!/bin/bash
#########################################################
# SCRIPT  : swtor-tools.sh                              #
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
# DATE    : 05-01-2020                                  #
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


menu=1
while [ $menu -eq 1 ]; do

      cd ~/Persistent/scripts

      if [ ! -f ~/Persistent/swtorcfg/freezing ] ; then 
         selection=$(zenity --width=600 --height=400 --list --hide-header --title "swtor-addon tools-menu" --column="ID"  --column="" \
         "1"  "[01]                                             " \
         "2"  "[02]                                             " \
         "3"  "[03]      Backup persistent volume" \
         "4"  "[04]      Check for updates on github" \
         "5"  "[05]      Import bookmarks for the TOR-Browser" \
         "6"  "[06]      Show documentation for the file swtor.cfg" \
         "7"  "[07]      Show documentation for the addon" \
         "8"  "[08]      Clean current Profiles 1 & 2" \
         "9"  "[09]      Show Changes in this release (CHANGES)" \
        "10"  "[10]      About swtor-addon" \
        "11"  "[11]      Back to the mainmenu" \
        --hide-column=1 \
        --print-column=1)
      else
          if [ ! -f ~/Persistent/swtorcfg/freezed.cgf ] ; then
             selection=$(zenity --width=600 --height=400 --list --hide-header --title "swtor-addon tools-menu" --column="ID"  --column="" \
             "1"  "[01]      Freezing the current state             " \
             "2"  "[02]                                             " \
             "3"  "[03]      Backup persistent volume" \
             "4"  "[04]      Check for updates on github" \
             "5"  "[05]      Import bookmarks for the TOR-Browser" \
             "6"  "[06]      Show documentation for the file swtor.cfg" \
             "7"  "[07]      Show documentation for the addon" \
             "8"  "[08]      Clean current Profiles 1 & 2" \
             "9"  "[09]      Show Changes in this release (CHANGES)" \
             "10" "[10]      About swtor-addon" \
            "11"  "[11]      Back to the mainmenu" \
            --hide-column=1 \
            --print-column=1)
          else
             selection=$(zenity --width=600 --height=400 --list --hide-header --title "swtor-addon tools-menu" --column="ID"  --column="" \
             "1"  "[01]                                   " \
             "2"  "[02]      Unfreezing the current state" \
             "3"  "[03]      Backup persistent volume" \
             "4"  "[04]      Check for updates on github" \
             "5"  "[05]      Import bookmarks for the TOR-Browser" \
             "6"  "[06]      Show documentation for the file swtor.cfg" \
             "7"  "[07]      Show documentation for the addon" \
             "8"  "[08]      Clean current Profiles 1 & 2" \
             "9"  "[09]      Show Changes in this release (CHANGES)" \
             "10" "[10]      About swtor-addon" \
            "11"  "[11]      Back to the mainmenu" \
            --hide-column=1 \
            --print-column=1)
          fi
      fi


if [ "$selection" == "" ] ; then
    menu=0
fi

if [ "$selection" == "1" ] ; then
   if [ -f ~/Persistent/swtorcfg/freezing ] ; then
      if [ ! -f ~/Persistent/swtorcfg/freezed.cgf ] ; then
         ./cli_tweak.sh
         ./cli_freezing.sh
         sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
         --text="\n\n                          System has ben freezed !                       \n\n" > /dev/null 2>&1)
      else
         echo freezing not possible -> allready freezed
      fi
   else
       echo freezing not possible missing dotfile
   fi
fi


if [ $selection == "2" ] ; then
   if [ -f ~/Persistent/swtorcfg/freezing ] ; then
      if [  -f ~/Persistent/swtorcfg/freezed.cgf ] ; then
         ./cli_unfreezing.sh
         sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
          --text="\n\n                            System has ben unfreezed !                         \n\n" > /dev/null 2>&1)
      else
          unfreezing not possible -> system not freezed
      fi
   else
      echo unfreezing not possible missing dotfile
   fi
fi


if [ $selection == "3" ] ; then
   ./create_image.sh
fi


if [ $selection == "4" ] ; then
  ./update.sh
fi

if [ $selection == "6" ] ; then
   evince /home/amnesia/Persistent/doc/sample-configuration.pdf
fi


if [ $selection == "5" ] ; then
   rsync -aqzh ~/Persistent/swtor-addon-to-tails/bookmarks /live/persistence/TailsData_unlocked
fi


if [ $selection == "7" ] ; then
    evince /home/amnesia/Persistent/doc/swtor0-60.pdf
fi

if [ $selection == "8" ] ; then
    ./cleanup.sh
    cd ~/Persistent/settings
    tar xzf tmp.tar.gz
fi

if [ $selection == "10" ] ; then
   ./swtor-about & 2>&1 > /dev/null
   sleep 3
   pkill swtor-about
fi

if [ $selection == "9" ] ; then
   gedit ~/Persistent/swtor-addon-to-tails/CHANGES
fi

if [ $selection == "11" ] ; then
   menu=0
fi

done

exit 0



