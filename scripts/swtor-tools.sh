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

       selection=$(zenity --width=600 --height=400 --list --hide-header --title "swtor-addon tools-menu" --column="ID"  --column="" \
       "1"  "[01]  ->  Freeze current settings to persistent (needs dot-file activated)" \
       "2"  "[02]  ->  Unfreeze settings from persistent (needs dot-file activated) " \
       "3"  "[03]  ->  Backup persistent volume" \
       "4"  "[04]  ->  Check for updates on github" \
       "5"  "[05]  ->  Import bookmarks for the TOR-Browser" \
       "6"  "[06]  ->  Show documentation for swtor.cfg" \
       "7"  "[07]  ->  Show documentation for the addon" \
       "8"  "[08]  ->  Clean current Profiles 1 & 2" \
       "9"  "[09]  ->  Show Changes in this release" \
       "10" "[10]  ->  About swtor-addon" \
       "11" "[11]  ->  Back to the mainmenu" \
       --hide-column=1 \
       --print-column=1)

if [ "$selection" == "" ] ; then
    menu=0
fi

if [ $selection == "1" ] ; then
   echo freezing

   if [ ! -f ~/Persistent/swtorcfg/freezed.cgf ]
      then
            mkdir /live/persistence/TailsData_unlocked/dotfiles/.config

            cp -r ~/.config/dconf /live/persistence/TailsData_unlocked/dotfiles/.config
            cp -r ~/.config/gtk-3.0 /live/persistence/TailsData_unlocked/dotfiles/.config
            cp -r ~/.config/pulse /live/persistence/TailsData_unlocked/dotfiles/.config
            cp -r ~/.config/ibus /live/persistence/TailsData_unlocked/dotfiles/.config
            cp -r ~/.config/nautilus /live/persistence/TailsData_unlocked/dotfiles/.config
            cp -r ~/.config/gnome-session /live/persistence/TailsData_unlocked/dotfiles/.config
            cp -r ~/Desktop /live/persistence/TailsData_unlocked/dotfiles
            cp -r ~/Pictures /live/persistence/TailsData_unlocked/dotfiles

            echo freezing done

            # Do markup the version of Tails we used to freezing ... we store it right here

            tails-version > ~/Persistent/swtorcfg/freezed.cgf
            sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Current settings of Tails are now freezed !" > /dev/null 2>&1)
   else
            sleep 5 | tee >(zenity --error --text="Freezing not possible ! \nThis Tails system seems already in the state to be freezed !" > /dev/null 2>&1)

   fi
fi


if [ $selection == "2" ] ; then
   echo unfreezing

   if [ ! -f ~/Persistent/swtorcfg/freezed.cgf ]
      then
          sleep 5 | tee >(zenity --error --text="Unfreezing not possible ! \nThis Tails seems not to be in the state of to be freezed !" > /dev/null 2>&1)
   else
          rm -rf /live/persistence/TailsData_unlocked/dotfiles/.config
          rm -rf /live/persistence/TailsData_unlocked/dotfiles/Desktop
          rm -rf /live/persistence/TailsData_unlocked/dotfiles/Pictures

          rm ~/Persistent/swtorcfg/freezed.cgf > /dev/null 2>&1

          sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Current settings are now unfreezed.\nPlease reboot Tails now ! " > /dev/null 2>&1)
  fi 
fi


if [ $selection == "3" ] ; then
   ./create_image.sh 2>&1 > /dev/null
fi


if [ $selection == "4" ] ; then

    cd ~/Persistent/scripts
    sleep 3 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Checking for updates ... please wait !" > /dev/null 2>&1)

    # We contact github to see what version is over there stored ....

    wget -O REMOTE.html  https://github.com/swtor00/swtor-addon-to-tails/blob/master/swtorcfg/swtor.cfg
    html2text REMOTE.html > REMOTE.TXT

    REMOTE=$(grep "SWTOR-VERSION" REMOTE.TXT)
    REMOTE=$(echo $REMOTE | tr -d " ")
    LOCAL=$(grep SWTOR-VERSION ~/Persistent/swtorcfg/swtor.cfg)

    rm REMOTE.html > /dev/null 2>&1
    rm REMOTE.TXT > /dev/null 2>&1

    # Comparing the remote and the local version of the scirpt..

    echo REMOTE-VERSION [$REMOTE] LOCAL-VERSION [$LOCAL]

    if [ "$REMOTE" == "$LOCAL" ]
    then
        echo "no updates found ...."
        sleep 3 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="No updates found to download." > /dev/null 2>&1) 
    else

         # Is this script controlled with git or not ?

         if [ ! -d ~/Persistent/swtor-addon-to-tails/.git ]
         then
             zenity --info --width=600 --text="Addon has no .git directory inside of ~/Persistent/swtor-addon-to-tails !"  > /dev/null 2>&1
             exit 1
         fi

        zenity --question --width=600 --text "On Github is a newer version of swtor to download.\n Would you like to update the addon now ?"
        case $? in
                0) sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="The addon is now updating to the latest release ... please wait !" > /dev/null 2>&1)
                   ./udpate.sh
                   sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="The addon is now ready to execute again." > /dev/null 2>&1)
                   exit 0
                ;;
                1) echo update select was no
                ;;
        esac
    fi
fi

if [ $selection == "6" ] ; then
   evince /home/amnesia/Persistent/doc/sample-configuration.pdf.pdf
fi


if [ $selection == "5" ] ; then
   rsync -aqzh ~/Persistent/swtor-addon-to-tails/bookmarks /live/persistence/TailsData_unlocked
fi


if [ $selection == "7" ] ; then
    evince /home/amnesia/Persistent/doc/swtor0-52.pdf
fi

if [ $selection == "8" ] ; then
    ./cleanup.sh
    sleep 3 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Chromium profiles 1 & 2 deleted and new created !" > /dev/null 2>&1)
    cd ~/Persistent/settings
    tar xzf tmp.tar.gz
fi

if [ $selection == "10" ] ; then
    ./swtor-about &
    sleep 4
    pid=$(ps | grep swtor-about | awk '{print $1}')
    kill -9 $(echo $pid) > /dev/null 2>&1
fi

if [ $selection == "9" ] ; then
   gedit ~/Persistent/swtor-addon-to-tails/CHANGES
fi

if [ $selection == "11" ] ; then
   menu=0
fi

done

exit 0



