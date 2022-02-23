#!/bin/bash
#########################################################
# SCRIPT  : startup.sh                                  #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.25 or higher                        #
#                                                       #
# VERSION : 0.60                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 04-11-2021                                  #
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

source ~/Persistent/scripts/swtor-global.sh

# the following global variables are exported from the main
# script swtor-menu.sh and are visible here.
#
# IMPORT_BOOKMAKRS
# GUI_LINKS
# CHECK_UPDATE
# BACKUP_FIXED_PROFILE
# BACKUP_APT_LIST
# TERMINAL_VERBOSE
# BROWSER_SOCKS5
# BYPASS
# CHECK_SSH
# AUTOCLOSE_BROWSER
# TIMEOUT_TB
# TIMEOUT_SSH
# XCLOCK_SIZE
# DEBUGW
# 


# Has setup ever run on this tails system ?
# Prior to use the menu, you have to execute the script swtor-setup.sh

if [ !  -f ~/Persistent/swtor-addon-to-tails/setup ] ; then
   end_wait_dialog && sleep 0.5
   sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information"\
    --text="\n\n                Please execute the command \"setup-swtor.sh\" first !                  \n\n" > /dev/null 2>&1)
   exit 1
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo "step01 : setup-swtor has ben executed once ....  "
    fi
fi


# This script has to be run only once ... no more

if [ -f ~/swtor_init ] ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "startup.sh was allready executed once"
   fi
   end_wait_dialog && sleep 0.5
   sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information"\
   --text="\n\n                 The command \"startup.sh\" was allready executed !                    \n\n" > /dev/null 2>&1)
   exit 0
fi


# Check the TOR-Connection over Internet

end_wait_dialog && sleep 0.5

check_tor_network
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "step02 : Tor over internet is working as expected  ....  "
    fi
    show_wait_dialog && sleep 2
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "no active internet connection found !"
       echo >&2 "startup.sh exiting with error-code 1"
    fi
    exit 1
fi

##################################################################################################
if [ "$CHECK_SSH" == "1" ] ; then
##################################################################################################

# check for a empty ~/.ssh directory

end_wait_dialog && sleep 0.5
test_empty_ssh
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "step03 : ~/.ssh for user amnesia is not empty ! "
    fi
    show_wait_dialog && sleep 0,5
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "~/.ssh is empty !"
       echo >&2 "startup.sh exiting with error-code 1"
    fi
    exit 1
fi



else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "the option CHECK-EMPTY-SSH:NO was found inside your configuration"
       echo "we don't test for a empty ~/.ssh folder inside of this startup.sh"
    fi
##################################################################################################
fi
##################################################################################################






##################################################################################################
if [ "$BYPASS" == "0" ] ; then
##################################################################################################

# test for installed yad from persistent volume

sleep 2
end_wait_dialog

test_for_yad
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "step04 : yad is installed  ! "
    fi
    show_wait_dialog && sleep 0.5
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "yad is not installed !"
       echo >&2 "startup.sh exiting with error-code 1"
    fi
    exit 1
fi


# test for installed sshpass from persistent volume

end_wait_dialog && sleep 0.5

test_for_sshpass
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "step05 : sshpass is installed  ! "
    fi
    show_wait_dialog sleep 0.5
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "sshpass is not installed !"
       echo >&2 "startup.sh exiting with error-code 1"
    fi
    exit 1
fi


# test for installed html2text from persistent volume

end_wait_dialog && sleep 0.5

test_for_html2text
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "step06 : html2text is installed  ! "
    fi
    show_wait_dialog && sleep 0,5
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "html2text is not installed !"
       echo >&2 "startup.sh exiting with error-code 1"
    fi
    exit 1
fi


# test for installed chromium from persistent volume

sleep 2
end_wait_dialog

test_for_chromium
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "step07 : chromium is installed  ! "
    fi
    show_wait_dialog && sleep 0.5
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "chromium is not installed !"
       echo >&2 "startup.sh exiting with error-code 1"
    fi
    exit 1
fi


# test for installed chromium-sandbox from persistent volume

end_wait_dialog && sleep 0.5

test_for_chromium-sandbox
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "step08 : chromium-sandbox is installed  ! "
    fi
    show_wait_dialog && sleep 0,5
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "chromium-sandbox is not installed !"
       echo >&2 "startup.sh exiting with error-code 1"
    fi
    exit 1
fi

else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "the option BYPASS-SOFTWARE-CHECK:YES was found inside your configuration"
       echo "we don't check all the 5 packages on first startup of swtor-menu.sh inside Tails ... "
    fi
fi
##################################################################################################
##################################################################################################





# Check for a existing administration password on startup of Tails ?

end_wait_dialog && sleep 1.5

test_password_greeting
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "step09 : password was set on startup of Tails  ! "
    fi
    show_wait_dialog && sleep 1.5
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "no password set on startup !"
       echo >&2 "starteup.sh exiting with error-code 1"
    fi
    rmdir $lockdir > /dev/null 2>&1
    exit 1
fi


# Ask for the administration password and store it in the tmp directory

end_wait_dialog & sleep 0.5

test_admin_password
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "step10 : password was correct and stored ! "
    fi

    # It is better to parse the persistent.conf on every startup here
    # than inside setup.sh. It is faster and cleaner.
    #
    # So we know on every startup of Tails , the current status of all options from
    # persistent volume.

    cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
    sudo -S cp /live/persistence/TailsData_unlocked/persistence.conf /home/amnesia/Persistent/swtorcfg > /dev/null 2>&1

    cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
    sudo -S chmod 666 /home/amnesia/Persistent/swtorcfg/persistence.conf > /dev/null 2>&1


    # If any of the 2  mandatory options for Persistent have changed from on to off ..
    # We have a error.

    # Mandatory : openssh-client

    if grep -q openssh-client ~/Persistent/swtorcfg/persistence.conf ; then
       if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo >&2 "ssh settings are present on this persistent volume"
       fi
    else
       echo "ssh settings are not longer present on this persistent Volume"
       exit 1
    fi

    # Mandatory : additional software part01

    if grep -q /var/cache/apt/archives  ~/Persistent/swtorcfg/persistence.conf ; then
       if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo >&2 "additional-software is  present on this persistent volume"
       fi
    else
       echo "additional-software is  not longer present on this persistent Volume"
       exit 1
    fi

    # Mandatory : additional software part02

    if grep -q /var/lib/apt/lists ~/Persistent/swtorcfg/persistence.conf ; then
       if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo >&2 "additional-software is  present on this persistent volume"
       fi
    else
       echo "additional-software is  not longer present on this persistent Volume"
       exit 1
    fi


    # Do we have network-connections active ?
    # This option is not mandatory

    if grep -q system-connection ~/Persistent/swtorcfg/persistence.conf ; then
       if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo >&2 "network settings are present on this persistent volume"
       fi
       echo 1 > ~/Persistent/swtorcfg/p_system-connection.config
    else
       rm  ~/Persistent/swtorcfg/p_system-connection.config > /dev/null 2>&1
    fi

    # Do we have greeter-settings active ?
    # This option is not mandatory

   if grep -q greeter-settings ~/Persistent/swtorcfg/persistence.conf ; then
      if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo >&2 "greeter-settings are present on this persistent volume"
      fi
      echo 1 > ~/Persistent/swtorcfg/p_greeter.config
   else
      rm ~/Persistent/swtorcfg/p_greeter.config > /dev/null 2>&1
   fi

   # Do we have Bookmarks active ?
   # This option is not mandatory

   if grep -q bookmarks ~/Persistent/swtorcfg/persistence.conf ; then
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo >&2 "bookmarks are present on this persistent volume"
      fi
      echo 1 > ~/Persistent/swtorcfg/p_bookmarks.config
   else
      rm ~/Persistent/swtorcfg/p_bookmarks.config > /dev/null 2>&1
   fi

   # Do we have cups active ?
   # This option is not mandatory

   if grep -q cups-configuration ~/Persistent/swtorcfg/persistence.conf ; then
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo >&2 "cups settings are present on this persistent volume"
      fi
      echo 1 > ~/Persistent/swtorcfg/p_cups-settings.config
   else
      rm ~/Persistent/swtorcfg/p_cups-settings.config > /dev/null 2>&1
   fi

   # Do we have thunderbird active ?
   # This option is not mandatory

   if grep -q thunderbird ~/Persistent/swtorcfg/persistence.conf ; then
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo >&2 "thunderbird settings are present on this persistent volume"
      fi
      echo 1 > ~/Persistent/swtorcfg/p_thunderbird.config
   else
      rm  ~/Persistent/swtorcfg/p_thunderbird.config > /dev/null 2>&1
   fi

   # Do we have gnupg active ?
   # This option is not mandatory

   if grep -q gnupg ~/Persistent/swtorcfg/persistence.conf ; then
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo >&2 "gnupg settings are present on this persistent volume"
      fi
      echo 1 > ~/Persistent/swtorcfg/p_gnupg.config
   else
      rm ~/Persistent/swtorcfg/p_gnupg.config  > /dev/null 2>&1
   fi

   # Do we have electrum active ?
   # This option is not mandatory

   if grep -q electrum ~/Persistent/swtorcfg/persistence.conf ; then
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo >&2 "electrum settings are present on this persistent volume"
      fi
      echo 1 > ~/Persistent/swtorcfg/p_electrum.config
   else
      rm ~/Persistent/swtorcfg/p_electrum.config > /dev/null 2>&1
   fi

   # Do we have pidgin active ?
   # This option is not mandatory

   if grep -q pidgin ~/Persistent/swtorcfg/persistence.conf ; then
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo >&2 "pidgin settings are present on this persistent volume"
      fi
      echo 1 > ~/Persistent/swtorcfg/p_pidgin.config
   else
      rm ~/Persistent/swtorcfg/p_pidgin.config > /dev/null 2>&1
   fi

   # Do we have tca active ?
   # This option is not mandatory

   if grep -q tca ~/Persistent/swtorcfg/persistence.conf ; then
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo >&2 "tca settings are present on this persistent volume"
      fi
      echo 1 > ~/Persistent/swtorcfg/p_tca.config
   else
      rm ~/Persistent/swtorcfg/p_tca.config > /dev/null 2>&1
   fi


   # Do we have dotfiles active ?
   # This option is not mandatory but highly recommandet

   if grep -q dotfiles ~/Persistent/swtorcfg/persistence.conf ; then
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo >&2 "dotfiles are present on this persistent volume"
      fi
      echo 1 > ~/Persistent/swtorcfg/freezing
      echo 1 > ~/Persistent/swtorcfg/p_dotfiles.config

      # The user may have jumped from non dotfiles to activated dotfiles

      rm  ~/Persistent/swtorcfg/no-freezing > /dev/null 2>&1

   else

      rm ~/Persistent/swtorcfg/freezing > /dev/null 2>&1
      rm ~/Persistent/swtorcfg/p_dotfiles.config > /dev/null 2>&1

      echo 1 > ~/Persistent/swtorcfg/no-freezing

      # This volume may was once actived with dotfiles and in the state freezed  ....
      # but by now it is not longer  possible ... missing dotfiles option
      # We have to clean up the mess.



   fi
   show_wait_dialog && sleep 2
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "password was 3 times wrong"
       echo >&2 "startupsh exiting with error-code 1"
    fi
    rmdir $lockdir > /dev/null 2>&1
    exit 1
fi


# test for a frezzed system and comparing the state of a freezed system  with the current Tails

end_wait_dialog && sleep 0.5

test_for_freezed
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "step11 : system not freezed or if freezed and the two system do match together ! "
    fi
    show_wait_dialog && sleep 0.5
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "freezed system missmatch !"
       echo >&2 "startup.sh exiting with error-code 1"
    fi
    exit 1
fi


# change the firewall to accept a socks5 server on port 9999

end_wait_dialog && sleep 0.5
change_tails_firewall
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "step12 : changed firewall settings for socks5 server !"
    fi
    show_wait_dialog && sleep 0.5
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "firewall was not changed because configuration"
       echo >&2 "startup.sh exiting with error-code 1"
    fi
    rmdir $lockdir > /dev/null 2>&1
    exit 1
fi


# The last thing to do is to check for udates or not. This depends on the configuration file
# swtor.cfg.The default value is CHECK-UPDATE:NO

end_wait_dialog && sleep 0.5
swtor_update
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "step 13 : update-check was executed"
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "failure with auto-update !"
    fi
    rmdir $lockdir > /dev/null 2>&1
    exit 1
fi



swtor_clean_files

if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "step 14 : all files cleaned-up"
fi

# We are done here , signal swtor-menu.sh with Error Code 0

echo 1 > ~/swtor_init

exit 0

