#!/bin/bash
#########################################################
# SCRIPT  : swtor-tools.sh                              #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 7.2 or higher                         #
#                                                       #
# VERSION : 0.90                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 15-11-2025                                  #
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

         # We need to wait

         sleep 7

         ./cli_freezing.sh
         sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
         --text="\n\n                          System is now freezed !                \n\n" > /dev/null 2>&1)
      else
         if [ $TERMINAL_VERBOSE == "1" ] ; then
            echo freezing not possible -> allready freezed
         fi
      fi
   else
       if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo freezing not possible missing dotfile option 
       fi
   fi
fi


if [ "$selection" == "2" ] ; then
   if [ -f ~/Persistent/swtorcfg/freezing ] ; then
      if [ -f ~/Persistent/swtorcfg/freezed.cgf ] ; then
         ./cli_unfreezing.sh
         sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
          --text="\n\n                            System is now unfreezed !                       \n\n" > /dev/null 2>&1)
      else
          if [ $TERMINAL_VERBOSE == "1" ] ; then
             echo unfreezing not possible -> system not freezed
          fi
      fi
   else
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo unfreezing not possible missing dotfile
      fi
   fi
fi


if [ "$selection" == "3" ] ; then
    zenity --question --width=600 \
    --text="\n\n   Prior to make a backup of the Persistent Volume, please close this programms first,\n   if any of them are open.\n\n   * Tor Browser\n   * Thunderbird\n   * Electrum Bitcoin Wallet \n   * Pidgin Internet Messanger\n   * Synaptic Package Manager\n   * Kleopatra    \n   * KeePassXC   \n\n If none of the above programms is open,please continue the backub by pressing 'Yes'.\n Otherwise press 'No' to cancel the backup.  \n\n"
    case $? in
         0) if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo backup started
            fi
            ./create_image.sh
         ;;
         1) if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo backup not started
            fi
         ;;
    esac
fi

if [ "$selection" == "4" ] ; then
  ./update.sh
fi

if [ "$selection" == "6" ] ; then
   evince /home/amnesia/Persistent/doc/sample-configuration.pdf > /dev/null 2>&1
fi


if [ "$selection" == "5" ] ; then
if [ -f ~/Persistent/swtorcfg/p_bookmarks.config ] ; then

    zenity --question --width=600 --text="All your current Bookmarks for the TOR-Browser will be overwritten ! \n\n" > /dev/null 2>&1
    case $? in
         0) zenity --info --width=600 --title="" \
            --text="Please close all open windows of the TOR-Browser or the import will not work.   \n\n Please press OK to continue." > /dev/null 2>&1

            # Delete the current used Bookmarks

            rm ~/.mozilla/firefox/bookmarks/places.sqlite > /dev/null 2>&1

            # Replace it with provided Bookmarks

            cp  ~/Persistent/swtor-addon-to-tails/bookmarks/places.sqlite ~/.mozilla/firefox/bookmarks/  > /dev/null 2>&1
         ;;
         1) if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo no import
            fi
         ;;
    esac
else
    sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
     --text="\n\n   Import is not possible because the bookmark-option is not activated for persistent !     \n\n" > /dev/null 2>&1)
fi
fi


if [ "$selection" == "7" ] ; then
    evince /home/amnesia/Persistent/doc/swtor-0.85.pdf > /dev/null 2>&1
fi

if [ "$selection" == "8" ] ; then
    ./cleanup.sh
    cd ~/Persistent/settings
    tar xzf tmp.tar.gz
fi

if [ "$selection" == "10" ] ; then
   ./swtor-about & 2>&1 > /dev/null
   sleep 3
   pkill swtor-about
fi

if [ "$selection" == "9" ] ; then
   gnome-text-editor ~/Persistent/swtor-addon-to-tails/CHANGES
fi

if [ "$selection" == "11" ] ; then
   menu=0
fi


done

exit 0



