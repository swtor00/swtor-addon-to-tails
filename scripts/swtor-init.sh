#!/bin/bash
#########################################################
# SCRIPT  : swtor-init.sh                               #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 6.9 or higher                         #
#                                                       #
# VERSION : 0.83                                        #
# STATE   : BETA                                        #
#                                                       #
#                                                       #
# DATE    : 01-110-2024                                 #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################


if grep -q "IMPORT-BOOKMARKS:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
   export IMPORT_BOOKMAKRS="1"
else
   export IMPORT_BOOKMAKRS="0"
fi

if grep -q "GUI-LINKS:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
   export GUI_LINKS="1"
else
   export GUI_LINKS="0"
fi

if grep -q "CHECK-UPDATE:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
   export CHECK_UPDATE="1"
else
   export CHECK_UPDATE="0"
fi

if grep -q "BACKUP-FIXED-PROFILE:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
   export BACKUP_FIXED_PROFILE="1"
else
   export BACKUP_FIXED_PROFILE="0"
fi

if grep -q "BACKUP_APT_LIST:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
     export BACKUP_APT_LIST="1"
else
     export BACKUP_APT_LIST="0"
fi

if grep -q "TERMINAL-VERBOSE:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
     export TERMINAL_VERBOSE="1"
else
     export TERMINAL_VERBOSE="0"
fi

if grep -q "BROWSER-SOCKS5:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
     export BROWSER_SOCKS5="1"
else
     export BROWSER_SOCKS5="0"
fi

if grep -q "BYPASS-SOFTWARE-CHECK:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
     export BYPASS="1"
else
     export BYPASS="0"
fi

if grep -q "CHECK-EMPTY-SSH:NO" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
     export CHECK_SSH="0"
else
     export CHECK_SSH="1"
fi

if grep -q "AUTOCLOSE-BROWSER:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
     export AUTOCLOSE_BROWSER="1"
else
     export AUTOCLOSE_BROWSER="0"
fi


export TIMEOUT_TB=$(grep TIMEOUT-TB ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg | sed 's/[A-Z:-]//g')
export TIMEOUT_SSH=$(grep TIMEOUT-SSH ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg | sed 's/[A-Z:-]//g')
export XCLOCK_SIZE=$(grep XCLOCK-SIZE ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg | sed 's/[A-Z:-]//g')

export  DEBUGW="0"


source ~/Persistent/scripts/swtor-global.sh
global_init

if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo global_init > /dev/null 2>&1
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "failure during initialisation of global-init"
       echo "swtor-init.sh exiting with error-code 1" > /dev/null 2>&1
    fi
    exit 1
fi

if [ ! -f ~/swtor_init ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "swtor-init.sh has never run !" > /dev/null 2>&1
    fi
    if (( $# == 0 )); then
       wait_until_connection="1"
    else
       wait_until_connection="0"
    fi
else
   exit 1
fi



# Creating the lockdirectory ....

lockdir=~/Persistent/scripts/init.lock
if mkdir "$lockdir" > /dev/null 2>&1
   then
       # the directory did not exist, but was created successfully

       if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo >&2 "successfully acquired lock: $lockdir"
       fi

else

       # failed to create the directory, presumably because it already exists

       if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo >&2 "cannot acquire lock, giving up on $lockdir"
          echo >&2 "swtor-menu.sh exiting with error-code 1"
       fi
       zenity --error --width=600 --text="Lockdirectory for initialisation can not be created !"
       exit 1
fi


if [ !  -f ~/Persistent/swtor-addon-to-tails/setup ] ; then
   sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information"\
    --text="\n\n                Please execute the command \"setup-swtor.sh\" first !                  \n\n" > /dev/null 2>&1)
   rmdir $lockdir 2>&1 >/dev/null
   exit 1
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo "step01 : setup-swtor has ben executed once ....  "
    fi
fi

# If we don't have a password on startup .... we show a error and do exit the script

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo Password test
fi

echo _123UUU__ | sudo -S /bin/bash > test_admin 2>&1

if grep -q "provided" test_admin ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo password asked
   fi
   rm test_admin 2>&1
else
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo no password set
   fi
   rm test_admin > /dev/null 2>&1
   rmdir $lockdir 2>&1 >/dev/null
   zenity --error --width=600 \
     --text="\n\n         This addon needs a administration password set on the greeter-screen.\n         You have to set this option first ! \n\n" \
    > /dev/null 2>&1
   echo "no password set on startup of Tails"
   exit 1
fi

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo test for password is done
fi


# Only execute this part if we are started over the autostart folder

if [ $wait_until_connection == "1" ] ; then


    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo wait for connection : $wait_until_connection
    fi

    auto_init=1
    connect=0
    while [ $auto_init -gt 0 ]; do

           sleep 1
           curl --socks5 127.0.0.1:9050 -m 2 https://tails.net/home/index.en.html > /dev/null 2>&1

           if [ $? -eq 0 ] ; then
              if [ $TERMINAL_VERBOSE == "1" ] ; then
                 echo tor is ready !
              fi
              connect=1
              auto_init=0
              break
           else
              if [ $TERMINAL_VERBOSE == "1" ] ; then
                 echo tor is not ready !
              fi
              ((auto_init++))
               connect=0
            fi

            if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo $auto_init
            fi

            # We wait for about 5 min.to a valid connection ....
            # After this time, we close the script !!!!

            if [ $auto_init -eq 300 ]; then
               auto_init=0
               connect=0
               break
            fi
            done

    if [ $connect == "1" ] ; then
        if [ $wait_until_connection == "1" ] ; then

           # We kill the connection Window ...... if it is on the main-screen

           ps_to_kill=$( ps axu | awk '$1 ~ /^amnesia/'|grep application.py | head -1 | awk {'print $2'})
           if test -z "$ps_to_kill"; then
              echo "nothing to kill .... "
           else
              kill -9 $ps_to_kill >/dev/null 2>&1
           fi
        else
           if [ $TERMINAL_VERBOSE == "1" ] ; then
              echo we are not in autostart mode
           fi
        fi
    else
        rmdir $lockdir >/dev/null
        exit 1
    fi
fi


menu=1
while [ $menu -gt 0 ]; do
      password=$(zenity --entry --text="Please type the Tails administration-password !" --title=Password --hide-text)
      echo $password > /home/amnesia/Persistent/swtor-addon-to-tails/tmp/password
      if [ "$password" == "" ] ; then
         if [ "$menu" == "3" ] ; then
             menu=0
             zenity --error --width=400 --text "\n\nThe password was not correct for 3 times ! \n\n"
             break
         else
             zenity --error --width=400 --text "\n\nThe password was empty ! \n\n"
             if [ $TERMINAL_VERBOSE == "1" ] ; then
                echo >&2 "password was empty !"
             fi
         fi
      else
          cd /home/amnesia/Persistent/swtor-addon-to-tails/tmp
         /home/amnesia/Persistent/swtor-addon-to-tails/scripts/testroot.sh >/dev/null 2>&1
          if [ -s password_correct ] ; then
             if [ $TERMINAL_VERBOSE == "1" ] ; then
                  echo >&2 "the provided administration password was correct"
             fi
             menu=0
             correct=1
             if [ $TERMINAL_VERBOSE == "1" ] ; then
                echo --------------
                echo mark 1 $(date)
                echo password is correct
                echo --------------
             fi
             break
         else
             if [ "$menu" == "3" ] ; then
                  menu=0
                  zenity --error --width=400 --text "\n\nYou have to restart again. The password was 3 times wrong ! \n\n"
                  break
              else
                  if [ $TERMINAL_VERBOSE == "1" ] ; then
                     echo >&2 "password was not correct"
                  fi
                  zenity --error --width=400 --text "\n\nThe password was not correct ! \n\n"
             fi
         fi

       fi
      ((menu++))
done


if [ "$correct" == "" ] ; then
   rm password > /dev/null 2>&1
   rm password_correct > /dev/null 2>&1
   rmdir $lockdir 2>&1 >/dev/null
   exit 1
else
   rm password_correct > /dev/null 2>&1
fi

sleep 3 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
--text="\n\n                    Please wait !                          \n\n" > /dev/null 2>&1)

# We have a valid password .... we do continue ....
# It is better to parse the persistent.conf on every startup here
# than inside setup.sh. It is faster and cleaner.

cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
sudo -S cp /live/persistence/TailsData_unlocked/persistence.conf /home/amnesia/Persistent/swtorcfg > /dev/null 2>&1

cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
sudo -S chmod 666 /home/amnesia/Persistent/swtorcfg/persistence.conf > /dev/null 2>&1

# If any of the mandatory options for Persistent have changed from on to off ..
# We have a error and stop further execution of the script

# Mandatory : openssh-client

if grep -q openssh-client ~/Persistent/swtorcfg/persistence.conf ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "ssh settings are present on this persistent volume"
   fi
else
   zenity --error --width=600 \
   --text="\n\n         This addon needs the ssh option inside of the persistent volume.\n         You have to set this option first ! \n\n" \
   > /dev/null 2>&1
   rmdir $lockdir 2>&1 >/dev/null
   exit 1
fi


# Mandatory : additional software part01

if grep -q /var/cache/apt/archives  ~/Persistent/swtorcfg/persistence.conf ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "additional-software is  present on this persistent volume"
   fi
else
   zenity --error --width=600 \
   --text="\n\n         This addon needs the additional software option inside of the persistent volume.\n         You have to set this option first ! \n\n" \
   > /dev/null 2>&1
   rmdir $lockdir 2>&1 >/dev/null
   exit 1
fi

# Mandatory : additional software part02

if grep -q /var/lib/apt/lists ~/Persistent/swtorcfg/persistence.conf ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "additional-software is  present on this persistent volume"
   fi
else
   zenity --error --width=600 \
   --text="\n\n         This addon needs the additional software option inside of the persistent volume.\n         You have to set this option first ! \n\n" \
   > /dev/null 2>&1
   rmdir $lockdir 2>&1 >/dev/null
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
# This option is not mandatory ... but very usefull

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
# and if you would like to autostart the addon it is
# not nice to have -> it is mandatory !!!!

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

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo --------------
   echo mark 2 $(date)
   echo all settings are scanned ...
   echo --------------
 fi

cd /home/amnesia/Persistent/swtor-addon-to-tails/tmp
cat password | sudo -S iptables -I OUTPUT -o lo -p tcp --dport 9999 -j ACCEPT  > /dev/null 2>&1

# We do install the deb file for the menu right here ... but only if the dpkg-lock
# is not active ... we may produce a uggly race-condition with dpkg -i
# we look into to ps tree that no asp-install processs is runnig

pid_asp=$(ps axu | grep -v grep | grep asp-install)
if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo $pid_asp
fi

if test -z "$pid_asp"; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo no asp-install process found !
    fi
else
   auto_init=1
   while [ $auto_init -gt 0 ]; do
         if [ $TERMINAL_VERBOSE == "1" ] ; then
            echo wait termination of asp-install  ,,,,
         fi
         sleep 1         
         pid_asp=$(ps axu | grep -v grep | grep asp-install)
         if [ $TERMINAL_VERBOSE == "1" ] ; then
            echo _$pid_asp
         fi
         if test -z "$pid_asp"; then
            auto_init=0
            if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo asp-install is finished
            fi
            break
         fi
         ((auto_init++))
   done
fi

# We only install the debian files with active GUI_LINKS
# If this option is not set the addon can only started over Terminal !

if [ $GUI_LINKS == "1" ] ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      cat password | sudo -S dpkg -i ~/Persistent/swtor-addon-to-tails/deb/tails-menu-00.deb > /dev/null 2>&1
   else
      cat password | sudo -S dpkg -i ~/Persistent/swtor-addon-to-tails/deb/tails-menu-01.deb > /dev/null 2>&1
   fi
fi

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo --------------
   echo mark 3 $(date)
   echo firewall changed and menu installed
   echo --------------
fi


if [ $CHECK_UPDATE == "1" ] ; then
   if [ ! -d ~/Persistent/swtor-addon-to-tails/.git ] ; then
      zenity --error --width=400 --text "\n\n    Houston, we have a problem !  \n    The .git directory was removed ! \n\n"
      rmdir $lockdir 2>&1 >/dev/nul
      exit 1
   fi

   cd /home/amnesia/Persistent/swtor-addon-to-tails/tmp
   wget -O REMOTE-VERSION https://raw.githubusercontent.com/swtor00/swtor-addon-to-tails/master/swtorcfg/swtor.cfg > /dev/null 2>&1

   REMOTE=$(grep "SWTOR-VERSION" REMOTE-VERSION | sed 's/[A-Z:-]//g')
   LOCAL=$(grep SWTOR-VERSION ~/Persistent/swtorcfg/swtor.cfg | sed 's/[A-Z:-]//g')

   if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo REMOTE-VERSION [$REMOTE]
       echo LOCAL-VERSION [$LOCAL]
   fi

   if [ "$REMOTE" == "$LOCAL" ] ; then
      if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo "no updates found to install "
          echo "both version are equal  ... "
      fi
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo --------------
         echo mark 4 $(date)
         echo checking for updates is active no update found to install !
         echo --------------
      fi
else
      if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo "we found a difference ... "
      fi
      cd ~/Persistent/swtor-addon-to-tails/scripts
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo --------------
         echo mark 4 $(date)
         echo checking for updates is active and we found a update
         echo --------------
      fi
      ./update.sh
      rmdir $lockdir 2>&1 >/dev/null
      exit 1
   fi
else
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo --------------
      echo mark 4 $(date)
      echo checking for updates is inactive
      echo --------------
   fi
fi

if [ -f ~/Persistent/swtorcfg/freezed.cgf ] ; then

   cat /etc/os-release | grep VERSION |sed "s/[^0-9.]*//g" > ~/Persistent/swtor-addon-to-tails/tmp/current-system
   if diff -q ~/Persistent/swtorcfg/freezed.cgf ~/Persistent/swtor-addon-to-tails/tmp/current-system ; then
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo >&2 "this addon was freezed with the same version of tails that is currently used .."
      fi
   else
       zenity --question --width=600 \
       --text="\n\nWe found a real problem with the current configuration.\nThis system was freezed with a older version of Tails.\nWould you like to unfreeze here and make a reboot ?\n\nIf your answer is Yes please do close all your applications prior to press Yes" > /dev/null 2>&1

       case $? in
         0)

         rm -rf /live/persistence/TailsData_unlocked/dotfiles/.config > /dev/null 2>&1
         rm -rf /live/persistence/TailsData_unlocked/dotfiles/Pictures > /dev/null 2>&1

         rm ~/Persistent/swtorcfg/freezed.cgf > /dev/null 2>&1

         rmdir ~/Persistent/scripts/menu.lock 2>&1 >/dev/null
         cd ~/Persistent/swtor-addon-to-tails/tmp
         cat password | sudo -S shutdown -r now

         ;;

         1) if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo "no reboot choosen ..."
            fi
         ;;
       esac
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo --------------
       echo mark 5 $(date)
       echo system is not freezed
       echo --------------
    fi
fi


if [ $CHECK_SSH= == "1" ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo --------------
       echo mark 6 $(date)
       echo systemdirectory ~/.ssh is checked 
       echo --------------
    fi
    if [ "$(ls -A ~/.ssh | wc -l)" -eq 0 ] ; then
      sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
      --text="\n\n                       SSH directory is empty                           \n\n" > /dev/null 2>&1)
      sleep 3
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo --------------
       echo mark 6 $(date)
       echo systemdirectory ~/.ssh is not checked
       echo --------------
    fi
fi


sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
--text="\n\n                       Initialisation is complete                          \n\n" > /dev/null 2>&1)


# remove lockdir ...

rmdir $lockdir 2>&1 >/dev/null


echo 1 > ~/swtor_init

exit 0
