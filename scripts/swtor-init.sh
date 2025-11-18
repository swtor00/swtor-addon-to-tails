#!/bin/bash
#########################################################
# SCRIPT  : swtor-init.sh                               #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 7.2 or higher                         #
#                                                       #
# VERSION : 0.90                                        #
# STATE   : BETA                                        #
#                                                       #
#                                                       #
# DATE    : 15-11-2025                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################

# If we found this file ..... The order is wrong !!!

if [ -f ~/Persistent/scripts/menu.lock ] ; then
   exit 1
fi

if grep -q "GUI-LINKS:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
   export GUI_LINKS="1"
else
   export GUI_LINKS="0"
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

# This entry was added after TOR Browser 15.01 / Tails 7.2

cat ~/Persistent/swtor-addon-to-tails/bookmarks/prefs.js > ~/.tor-browser/profile.default/prefs.js

if [ !  -f ~/Persistent/swtor-addon-to-tails/setup ] ; then
   sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information"\
    --text="\n\n     Please execute \"setup-swtor.sh\" first !      \n\n" > /dev/null 2>&1)
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

echo _123UUU__ | sudo -S /bin/bash > /dev/shm/test_admin 2>&1

if grep -q "no password was provided" /dev/shm/test_admin > /dev/null 2>&1 ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo password asked
   fi
   rm /dev/shm/test_admin 2>&1
fi


if grep -q "user amnesia is allowed" /dev/shm/test_admin > /dev/null 2>&1 ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo no password set
   fi
   rm /dev/shm/test_admin > /dev/null 2>&1
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


# Only execute this part if we are started over the folder ~/.config/autostart

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

            # Exactly one min after the login would be
            # the perfect time to check for a active Airplane-Mode
            # If Airplane-Mode is active we don't see
            # eth0 or wlan0 over the ip command

            if [ $auto_init -eq 50 ]; then
                ip address > ~/Persistent/swtor-addon-to-tails/tmp/network-list

                # We should have at least a interface called eth0 or wlan0

                found="0"
                if grep "eth0" ~/Persistent/swtor-addon-to-tails/tmp/network-list > /dev/null ; then
                   ((found++))
                fi

                if grep "wlan0" ~/Persistent/swtor-addon-to-tails/tmp/network-list > /dev/null ; then
                   ((found++))
                fi

                rm ~/Persistent/swtor-addon-to-tails/tmp/network-list > /dev/null 2>&1

                # In the case that no interfaces are found -> We are in Airplane-Mode
                # or we are running Tails on a computer with a unknown interface

                if [ $found == "0" ] ; then
                   sleep 10 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information"\
                   --text="\n\n        Airplane-Mode is active or no active\n        interfaces found on this computer !         \n\n" > /dev/null 2>&1)
                   rmdir $lockdir >/dev/null
                   exit 1
                fi
            fi

            # We wait for about 10 min. to a valid tor-connection ....
            # over eth0 or wlan0
            # After this timeout is reached, we close the script !!!!

            if [ $auto_init -eq 600 ]; then
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
--text="\n\n                        [  Please wait  ]               \n\n" > /dev/null 2>&1)

# We have a valid password .... we do continue ....
# It is better to parse the persistent.conf on every startup here
# than inside setup.sh. It is faster and cleaner.

cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
sudo -S cp /live/persistence/TailsData_unlocked/persistence.conf /home/amnesia/Persistent/swtorcfg > /dev/null 2>&1

cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
sudo -S chmod 666 /home/amnesia/Persistent/swtorcfg/persistence.conf > /dev/null 2>&1


# After a release update(from 7.x to 7.x) we do 2 things
# 1. Update chrome.deb if it exists
# 2. Update the addon over github

if [ -f ~/Persistent/swtor-addon-to-tails/tails-supdate ] ; then
   if [ -f  ~/Persistent/swtor-addon-to-tails/deb/chrome.deb ] ; then
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo Update Chrome Installation file 
      fi
      show_wait_dialog & sleep 1
      cd ~/Persistent/swtor-addon-to-tails/scripts
      ./cli_get_chrome.sh  > /dev/null 2>&1
      end_wait_dialog && sleep 1.5
   else
      if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo no Chrome Installation file fouund 
      fi
   fi

   cd ~/Persistent/swtor-addon-to-tails/tmp

   file1=$(curl -s https://raw.githubusercontent.com/swtor00/swtor-addon-to-tails/refs/heads/master/swtorcfg/build | grep build | tr ':' ' ' | awk '{print $2}')
   file2=$(cat ~/Persistent/swtorcfg/build | grep build | tr ':' ' ' | awk '{print $2}')

   if [[ $file1 -gt $file2 ]]; then

      if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo Addons needs to update ....
      fi

       zenity --question --width=600 \
       --text="\n\nThere is a update to install for this addon.\nWould you like to install it now ?\n\n" > /dev/null 2>&1
       
       case $? in
         0)
           show_wait_dialog & sleep 1
           cd ~/Persistent/swtor-addon-to-tails/scripts
           ./cli_update.sh > /dev/null 2>&1
           end_wait_dialog && sleep 1.5
         ;;

         1) if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo "Addon not updated ..."
            fi
         ;;
       esac
   fi

   rm ~/Persistent/swtor-addon-to-tails/tails-supdate > /dev/null 2>&1
fi


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
# This option is not mandatory but highly recommanded
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
   # but by now it is not longer possible ... missing dotfiles option
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
# is not active ... we may produce here a nice uggly race-condition with dpkg -i
# We look here into to ps tree that not a single  asp-install processs is runnig

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

   # install chrome

   if [ -f ~/Persistent/swtor-addon-to-tails/deb/chrome.deb  ] ; then
      cat password | sudo -S dpkg -i ~/Persistent/swtor-addon-to-tails/deb/chrome.deb > /dev/null 2>&1
   fi

   # install chromne libwidevinecdm.so into current chromium installation
   # the directory /opt/google/chrome/WidevineCdm has to be inside
   #

   if [ -f ~/Persistent/swtor-addon-to-tails/deb/libwidevinecdm.so  ] ; then
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo installation of drm library into chromium installation
      fi

      cat password | sudo -S cp -r /opt/google/chrome/WidevineCdm /usr/lib/chromium
      cat password | sudo -S chmod -R 664 /usr/lib/chromium/WidevineCdm
   fi
fi



if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo --------------
   echo mark 3 $(date)
   echo firewall changed and menu installed
   echo chrome-browser installed on request
   echo --------------
fi

if [ -f ~/Persistent/swtorcfg/freezed.cgf ] ; then

   cat /etc/os-release | grep VERSION |sed "s/[^0-9.]*//g" > ~/Persistent/swtor-addon-to-tails/tmp/current-system
   if diff -q ~/Persistent/swtorcfg/freezed.cgf ~/Persistent/swtor-addon-to-tails/tmp/current-system ; then
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo >&2 "this addon was freezed with the same version of tails that is currently used .."
      fi
   else
   
       # Prior to Version 7.2 of Tails we did unfreezing the system ..... after every update 
       
       date >  ~/Persistent/swtor-addon-to-tails/tails-supdate 
       
       # Do markup the version of Tails we used to freezing or for a update 
       # The command tails-version is obsolete in Tails 6.X and later releases

       cat /etc/os-release | grep VERSION |sed "s/[^0-9.]*//g" > ~/Persistent/swtorcfg/freezed.cgf
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
