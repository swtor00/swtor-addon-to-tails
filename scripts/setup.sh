#/bin/bash
#########################################################
# SCRIPT  : setup.sh                                    #
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
# DATE    : 24-10-21                                    #
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

export TIMEOUT_TB=$(grep TIMEOUT ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg | sed 's/[A-Z:-]//g')

# Creating the lockdirectory ....

lockdir=~/Persistent/swtor-addon-to-tails/scripts/setup.lock
if mkdir "$lockdir" > /dev/null 2>&1 ; then

   # the directory did not exist, but was created successfully

   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "successfully acquired lock: $lockdir"
   fi
else

    # failed to create the directory, presumably because it already exists

    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "cannot acquire lock, giving up on $lockdir"
       echo >&2 "setup.sh exiting with error-code 1"
    fi
    zenity --error --width=600 --text="\n\nLockdirectory for setup.sh can not be created ! \n\n" > /dev/null 2>&1
    exit 1
fi


# Check to see if the ONION Network is allready runnig ....

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo testing the internet-connection over the onion-network with TIMEOUT $TIMEOUT_TB
fi

curl --socks5 localhost:9050 --socks5-hostname localhost:9050 -s https://check.torproject.org/ -m $TIMEOUT_TB | grep -m 1 Congratulations > /dev/null 2>&1

if [ $? -eq 0 ] ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo TOR is up and running and we can continue with the execution of the script ....
   fi
   sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n\nTesting the Internet connection over TOR was successful ! \n\n" > /dev/null 2>&1)
else

   zenity --error --width=600 --text="\n\nInternet not ready or no active connection found ! \nPlease make a connection to the Internet first and try it again ! \n\n" > /dev/null 2>&1
   rmdir $lockdir > /dev/null 2>&1
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "removed acquired lock: $lockdir"
      echo >&2 "setup.sh exiting with error-code 1"
   fi
   exit 1
fi



cd ~/Persistent

# on every startup of tais we need a administration password, or the addon will not work properly

echo _123UUU__ | sudo -S /bin/bash > ~/Persistent/test_admin 2>&1

if grep -q "password is disabled" ~/Persistent/test_admin ; then
     rm ~/Persistent/test_admin > /dev/null 2>&1
     zenity --error --width=600 --text="\n\nThis addon needs a administration password for Tails on startup ! \nYou have to set this option first and restart Tails.\n\n" > /dev/null 2>&1
     rmdir $lockdir > /dev/null 2>&1
     if [ $TERMINAL_VERBOSE == "1" ] ; then
        echo >&2 "removed acquired lock: $lockdir"
        echo >&2 "setup.sh exiting with error-code 1"
     fi
     exit 1
else
    rm ~/Persistent/test_admin > /dev/null 2>&1
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "we have a administration password for tails"
    fi
fi


# is .ssh persistent ?

mount > ~/Persistent/mounted
if grep -q "/home/amnesia/.ssh" ~/Persistent/mounted ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo we have .ssh mounted
    fi
else
    zenity --error --width=600 --text="\n\nThis addon needs the ssh option inside of the persistent volume.\nYou have to set this option first and restart Tails.\n\n" > /dev/null 2>&1
    rmdir $lockdir > /dev/null 2>&1
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "removed acquired lock: $lockdir"
       echo >&2 "setup.sh exiting with error-code 1"
    fi
    exit 1
fi


# is additional software peristent ?

if grep -q "/var/cache/apt/archives" ~/Persistent/mounted ; then
     rm ~/Persistent/mounted > /dev/null 2>&1
     if [ $TERMINAL_VERBOSE == "1" ] ; then
        echo we have additional software active
     fi
else
    rm ~/Persistent/mounted > /dev/null 2>&1
    zenity --error --width=600 --text="\n\nThis addon needs the additional-software option inside of the persistent volume.\nYou have to set this option first and restart Tails.\n\n" > /dev/null 2>&1
    rmdir $lockdir > /dev/null 2>&1
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "removed acquired lock: $lockdir"
       echo >&2 "setup.sh exiting with error-code 1"
    fi
    exit 1
fi


# is bookmarks option active in the case of later importing them ?

if [ $IMPORT_BOOKMAKRS == "1" ] ; then
     if grep -q "firefox/bookmarks" ~/Persistent/mounted ; then
        if [ $TERMINAL_VERBOSE == "1" ] ; then
            echo we have bookmarks active and we import them later
        fi
        echo
     else
        rm ~/Persistent/mounted > /dev/null 2>&1
        zenity --error --width=600 --text="\n\nThe import of the bookmarks is not possible if the bookmark option inside of the persistent volume is not set.\nYou have to set this option first and restart Tails.\n\n" > /dev/null 2>&1
        if [ $TERMINAL_VERBOSE == "1" ] ; then
           echo >&2 "removed acquired lock: $lockdir"
           echo >&2 "setup.sh exiting with error-code 1"
        fi
        exit 1
     fi
fi


# Delete test-file for mounting

rm ~/Persistent/mounted > /dev/null 2>&1


# Test for a prior execution of the script setup.sh

if [ ! -f ~/Persistent/swtor-addon-to-tails/setup ] ; then

   zenity --info --width=600 --text="Welcome to the swtor addon for Tails.\nThis ist the first time you startup this tool on this persistent volume of Tails.\n\n* We create a few symbolic links inside of the persistent volume\n* We create a folder personal-files\n* We install 5 additional debian software-packages\n* We import bookmarks depending of the configuration of swtor.cfg\n\n\nPlease press OK to continue." > /dev/null 2>&1

   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "creating symlinks inside of persistent"
   fi

   if [ ! -L ~/Persistent/settings ] ; then
      ln -s ~/Persistent/swtor-addon-to-tails/settings ~/Persistent/settings > /dev/null 2>&1
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo "creating symlink ~/Persistent/settings"
      fi
   else
       if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo "symlink ~/Persistent/settings was allready made"
       fi
   fi

   if [ ! -L ~/Persistent/scripts ] ; then
      ln -s ~/Persistent/swtor-addon-to-tails/scripts  ~/Persistent/scripts > /dev/null 2>&1
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo "creating symlink ~/Persistent/scripts"
      fi
   else
       if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo "symlink ~/Persistent/scripts was allready made"
       fi
   fi

   if [ ! -L ~/Persistent/swtorcfg ] ; then
      ln -s ~/Persistent/swtor-addon-to-tails/swtorcfg ~/Persistent/swtorcfg > /dev/null 2>&1
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo "creating symlink ~/Persistent/swtorcfg"
      fi
   else
       if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo "symlink ~/Persistent/swtorcfg was allready made"
      fi
   fi

   if [ ! -L ~/Persistent/doc ] ; then
      ln -s ~/Persistent/swtor-addon-to-tails/doc ~/Persistent/doc > /dev/null 2>&1
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo "creating symlink ~/Persistent/doc"
      fi
   else
       if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo "symlink ~/Persistent/doc was allready made"
       fi
   fi

   # creating log-directory for ssh

   if [ ! -d ~/Persistent/swtor-addon-to-tails/swtorcfg/log ] ; then
      mkdir -p ~/Persistent/swtor-addon-to-tails/swtorcfg/log > /dev/null 2>&1
       if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo "directory ~/Persistent/swtor-addon-to-tails/swtorcfg/log was created"
       fi
   fi

else
   zenity --error --width=600 --text="\n\nsetup.sh has failed. \nThis programm was allready executed once on this volume ! \n\n" > /dev/null 2>&1
   rmdir $lockdir > /dev/null 2>&1
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "removed acquired lock: $lockdir"
      echo >&2 "setup.sh exiting with error-code 1"
   fi
   exit 1
fi

password=$(zenity --entry --text="Please provide the curent Tails administration-password ? " --title=Password --hide-text)
echo $password > /home/amnesia/Persistent/password

# Empty password ?

if [ "$password" == "" ] ; then
   zenity --error --width=400 --text "\n\nThe password was empty ! \n\n"
   rm /home/amnesia/Persistent/password > /dev/null 2>&1
   rmdir $lockdir > /dev/null 2>&1
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "removed acquired lock: $lockdir"
      echo >&2 "setup.sh exiting with error-code 1"
   fi
   exit 1
fi

# We make the password-test inside a own script

gnome-terminal --window-with-profile=Unnamed -x bash -c /home/amnesia/Persistent/scripts/testroot.sh > /dev/null 2>&1

if [ -s /home/amnesia/Persistent/scripts/password_correct ] ; then
    zenity --error --width=400 --text="\n\nThe provided password was not correct ! \n\n"  > /dev/null 2>&1
    rm ~/Persistent/password
    rm ~/Persistent/password_correct
    rmdir $lockdir > /dev/null 2>&1
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "removed acquired lock: $lockdir"
       echo >&2 "setup.sh exiting with error-code 1"
    fi
    exit 1

else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "the provided administration password was correct"
    fi
fi

# With all the above infos,we have enough information to testing
# if this persistent volume has dotfiles activated or not.
# We aren't able to freeze the seetings without the option dotfiles.

cat ~/Persistent/password | sudo -S cp /live/persistence/TailsData_unlocked/persistence.conf /home/amnesia/Persistent > /dev/null 2>&1
cat ~/Persistent/password | sudo -S chmod 666 /home/amnesia/Persistent/persistence.conf > /dev/null 2>&1


if grep -q dotfiles ~/Persistent/persistence.conf ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "dotfiles are present on this persistent volume"
       echo >&2 "a complete freezing of the settings from Tails is possible"
   fi
   rm ~/Persistent/persistence.conf > /dev/null 2>&1
   echo 1 > ~/Persistent/swtorcfg/freezing
else
   if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "dotfiles are not present on this persistent volume"
       echo >&2 "freezing is not possible in the current state."
   fi
   zenity --question --width=600 --text="On this persistent volume the option for dotfiles isn't set.\nWould you like to stop here and set the option and restart Tails ?" > /dev/null 2>&1
   case $? in
         0) cd ~/Persistent/settings
                 tar xzf tmp.tar.gz
                 cp -r ~/Persistent/settings/2 ~/Persistent/personal-files/3
                 rm -rf /Persistent/settings/2
                 rm -rf /Persistent/settings/1
         rm ~/Persistent/persistence.conf /dev/null 2>&1
         sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n\nPlease don't forget the dotfiles activation ! \n\n" > /dev/null 2>&1)

         rmdir $lockdir > /dev/null 2>&1
         if [ $TERMINAL_VERBOSE == "1" ] ; then
             echo >&2 "The user would like to stop here and reboot Tails."
             echo >&2 "removed acquired lock: $lockdir"
             echo >&2 "setup.sh exiting with error-code 0"
         fi
         exit 0
         ;;
         1) if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo "the user would like to continue wihtout dotfiles activated ...."
               echo "against the tip to activate this option"
            fi
         rm ~/Persistent/persistence.conf /dev/null 2>&1
         echo 1 > ~/Persistent/swtorcfg/no-freezing
         ;;
   esac
fi


# Creating personal-files

if [ ! -d ~/Persistent/personal-files ] ; then
   mkdir ~/Persistent/personal-files > /dev/null 2>&1
   if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo "directory ~/Persistent/personal-files was created"
   fi
else
   if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo "directory ~/Persistent/personal-files not created"
   fi
fi

zenity --question --width=600 --text="Should a symbolic link created for the directory ~/Persistent/personal-files ?" > /dev/null 2>&1
case $? in
         0) symlinkdir=$(zenity --entry --width=600 --text="Please provide the name of the symlinked directory ?" --title=Directory)

            if [ "$symlinkdir" == "" ];then
               if [ $TERMINAL_VERBOSE == "1" ] ; then
                    echo not creating symlink $symlinkdir because the name was empty
                    echo >&2 "removed acquired lock: $lockdir"
                    echo >&2 "setup.sh exiting with error-code 1"
               fi
               exit 1
            else
                 ln -s ~/Persistent/personal-files ~/Persistent/$symlinkdir > /dev/null 2>&1
                 if [ $TERMINAL_VERBOSE == "1" ] ; then
                    echo creating symlink $symlinkdir
                 fi
            fi
         ;;
         1) if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo not creating symlink
            fi
         ;;
esac



zenity --question --width=600 --text="Would you like to create a fixed chromium profile ? \nAll information stored in this profile remains valid even after a reboot !"
case $? in
         0) cd ~/Persistent/settings
            tar xzf tmp.tar.gz
            cp -r ~/Persistent/settings/2 ~/Persistent/personal-files/3
            rm -rf /Persistent/settings/2
            rm -rf /Persistent/settings/1
         ;;
         1) if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo not creatinging fixed browsing profile
            fi
         ;;
esac


# Restore the TOR-Browser  bookmarks depending on the configuration file swtor.cfg

if [ $IMPORT_BOOKMAKRS == "1" ] ; then
   echo
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo importing bookmarks
   fi
   rsync -aqzh ~/Persistent/swtor-addon-to-tails/bookmarks /live/persistence/TailsData_unlocked > /dev/null 2>&1
   echo
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "bookmarks are not imported because the configuration is set to IMPORT-BOOKMARKS:NO"
    fi
fi


zenity --question --width=600 --text="Configure the additional software for the addon ?\nOnly answer No if the software packages are allready installed."  > /dev/null 2>&1

case $? in
         0)

         if [ $TERMINAL_VERBOSE == "1" ] ; then
            echo we do install the additional software
         fi

         # apt-get update

         sleep 25 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n\nUpdate the paket-list.\nThis may needs some very long time to complete ! \n\n" > /dev/null 2>&1)
         sleep 1

         # Righ here would it be very nice
         # to show the user that Tails is still working in the background


         cat ~/Persistent/password | sudo -S apt-get update > /dev/null 2>&1

         ###

         sleep 1
         sleep 14 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n\nUpdating the list is now complete.\nNow we can install the additional software\n\n" > /dev/null 2>&1)

         # Install chromium

         sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n\nchromium will be installed. Please wait  ! \n\n" > /dev/null 2>&1)
         cat ~/Persistent/password | sudo -S apt-get install -y chromium > /dev/null 2>&1

         if [ $TERMINAL_VERBOSE == "1" ] ; then
            echo >&2 "chromium is installed"
         fi

         zenity --info --width=600 --text="chromium has been installed.\nPlease confirm that this software has to be installed on every startup.\n\n\nPlease press OK to continue."         
         sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="chromium-sandbox will be installed. Please wait  !" > /dev/null 2>&1)

         cat ~/Persistent/password | sudo -S apt-get install -y chromium-sandbox > /dev/null 2>&1

         if [ $TERMINAL_VERBOSE == "1" ] ; then
            echo >&2 "chromium-sandbox is installed"
         fi

         zenity --info --width=600 --text="chromium-sandbox has been installed.\nPlease confirm that this software has to be installed on every startup.\n\n\nPlease press OK to continue."

         sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n\nhtml2text will be installed. Please wait  ! \n\n" > /dev/null 2>&1)  
         cat ~/Persistent/password | sudo -S apt-get install -y html2text > /dev/null 2>&1

         if [ $TERMINAL_VERBOSE == "1" ] ; then
            echo >&2 "html2text is installed"
         fi

         zenity --info --width=600 --text="html2text has been installed.\nPlease confirm that this software has to be Installed on every startup.\n\n\nPlease press OK to continue."

         # Install sshpass

         sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n\nsshpass will be installed. Please wait  ! \n\n" > /dev/null 2>&1)
         cat ~/Persistent/password | sudo -S apt-get install -y sshpass> /dev/null 2>&1

         if [ $TERMINAL_VERBOSE == "1" ] ; then
            echo >&2 "sshpass is installed"
         fi

         zenity --info --width=600 --text="sshpass has been installed.\nPlease confirm that this software has to be installed on every startup.\n\n\nPlease press OK to continue."

         # Install yad

         sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n\nyad will be installed. Please wait  ! \n\n" > /dev/null 2>&1)
         cat ~/Persistent/password | sudo -S apt-get install -y yad > /dev/null 2>&1

         if [ $TERMINAL_VERBOSE == "1" ] ; then
            echo >&2 "yad is installed"
         fi

         zenity --info --width=600 --text="yad has been installed.\nPlease confirm that this software has to be installed on every startup.\n\n\nPlease press OK to continue."

         ;;
         1) if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo nothing to install  ..
            fi
         ;;
esac

rm ~/Persistent/password
rm ~/Persistent/password_correct

echo 1 > ~/Persistent/swtor-addon-to-tails/setup

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo >&2 "setup.sh is now completed"
fi

sleep 12 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n\nSetup is now complete !\n\nYou can now start the addon with the command swtor-menu.sh\n\n" > /dev/null 2>&1)

# Delete the lock-file ...

sleep 1

rmdir ~/Persistent/swtor-addon-to-tails/scripts/setup.lock > /dev/null 2>&1
rm -f ~/Persistent/swtor-addon-to-tails/scripts/scripts > /dev/null 2>&1

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo >&2 "removed acquired lock: $lockdir"
   echo >&2 "setup.sh was sucessfull exiting with return-code 0"
fi

exit 0


