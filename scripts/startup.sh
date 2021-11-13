#!/bin/bash
#########################################################
# SCRIPT  : startup.sh                                  #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.23 or higher                        #
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
# TIMEOUT_TB


# Has setup ever run on this tails system ?

if [ !  -f ~/Persistent/swtor-addon-to-tails/setup ] ; then
   sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information"\
    --text="\n\n                Please execute the command \"setup-swtor.sh\" first !                  \n\n" > /dev/null 2>&1)
   exit 1
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo "setup-swtor has ben executed once ....  "
         echo done
    fi
fi

# This script has to be run only once ... no more

if [ -f ~/swtor_init ] ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "startup.sh was allready executed once"
   fi
   sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information"\
   --text="\n\n                 The command \"startup.sh\" was allready executed !                    \n\n" > /dev/null 2>&1)
   exit 0
fi

# Check tails network

check_tor_network
if [ $? -eq 0 ] ; then
   echo shaga 1 alles gut
else
   echo shaga 2 nix gut
fi




sleep 2 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Info" --text="Testing ssh files for the addon ..." > /dev/null 2>&1)

if [ -z "$(ls -A /home/amnesia/.ssh )" ] ; then
   sleep 8 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Info" --text="The directory /home/amnesia/.ssh is empty.\n\nThis addons needs a predefined SSH connection" > /dev/null 2>&1)
   exit
fi


sleep 2 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Info" --text="Testing the installed additional software !" > /dev/null 2>&1)


# test for installed yad command from persistent volume

if grep -q "status installed yad" /var/log/dpkg.log ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo step 01b.
       echo "yad is installed .... "
       echo done
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo step 01b.
       echo "yad is not installed .... "
       echo done
    fi
    sleep 6 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Info" --text="Tor is ready but yad is not installed by now !" > /dev/null 2>&1)
    exit 1
fi


# test for installed sshpass command from persistent volume

if grep -q "status installed sshpass" /var/log/dpkg.log ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo step 01c.
       echo "sshpass is installed .... "
       echo done
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo step 01c.
       echo "sshpass is not installed .... "
       echo done
    fi
       sleep 6 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Info" --text="Tor is ready but sshpass is not installed by now !" > /dev/null 2>&1)
    exit 1
fi


# test for installed html2text command from persistent volume

if grep -q "status installed html2text" /var/log/dpkg.log ; then 
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo step 01d.
       echo "html2text is installed .... "
       echo done
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo step 01d.
       echo "html2text is not installed .... "
       echo done
    fi
    sleep 6 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Info" --text="Tor is ready but html2text is not installed by now !" > /dev/null 2>&1)
    exit 1
fi

# test for installed chromium command from persistent volume

if grep -q "status installed chromium" /var/log/dpkg.log ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo step 01e.
       echo "chromium is installed .... "
       echo done
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo step 01e.
       echo "chromium is not installed .... "
       echo done
    fi
    sleep 6 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Info" --text="Tor is ready but chromium is not installed by now !" > /dev/null 2>&1)
    exit 1
fi


# test for installed chromium-sandbox command from persistent volume

if grep -q "status installed chromium-sandbox" /var/log/dpkg.log ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo step 01f.
       echo "chromium-sandbox is installed .... "
       echo done
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo step 01f.
       echo "chromium-sandbox is not installed .... "
       echo done
    fi
    sleep 6 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Info" --text="Tor is ready but chromium-sandbox is not installed by now !" > /dev/null 2>&1)
    exit 1
fi



# Do we have a freezed Tails ?

if [ -f ~/Persistent/swtorcfg/freezed.cgf ] ; then 
       tails-version > ~/Persistent/scripts/current
       if diff -q ~/Persistent/swtorcfg/freezed.cgf ~/Persistent/scripts/current ;then
          if [ $TERMINAL_VERBOSE == "1" ] ; then
             echo step 02
             echo this system was freezed with the same version of tails that it was created  ...
             echo done
          fi
          sleep 1
       else
            # Houston ... We have a problem
            # You should not run this addon with a freezed system from a older tails version than the current one used

            rm -rf /live/persistence/TailsData_unlocked/dotfiles/.config > /dev/null 2>&1
            rm -rf /live/persistence/TailsData_unlocked/dotfiles/Desktop > /dev/null 2>&1
            rm ~/Persistent/swtorcfg/freezed.cgf > /dev/null 2>&1

            zenity --info --width=600 --text="\nThis system was freezed with a older version of Tails.\nYou have to reboot for a complete unfreezing\nPlease reboot ASAP !"
            exit 1
       fi
       rm ~/Persistent/scripts/current > /dev/null 2>&1
fi


# We need a administration password, or the addon will not work properly

echo _123UUU__ | sudo -S /bin/bash > ~/Persistent/scripts/test_admin 2>&1

if grep -q "is not allowed to execute" ~/Persistent/scripts/test_admin ; then 
     rm ~/Persistent/scripts/test_admin > /dev/null 2>&1
     zenity --info --width=600 --text="\nYou have to set a administration password on\n the greeting-screen of Tails!" 
     exit 1
else
    rm ~/Persistent/scripts/test_admin > /dev/null 2>&1
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo step 04
       echo we have a administration password
       echo done
    fi
fi

sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Info" --text="Checking for updates\nDepending on the configuration of swtor.cfg" > /dev/null 2>&1)


# Check for updates on demand if CHECK-UPDATE:YES is set of inside swtor.cfg
# The default Value of this setting is : NO

if grep -q CHECK-UPDATE:YES ~/Persistent/swtorcfg/swtor.cfg ; then

    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "Checking for updates on github"
    fi

    # If you don't like this behavior on startup, you should open the
    # configuration file ~/Persistent/swtorcfg/swtor.cfg and set the option
    # CHECK-UPDATE:YES to the value CHECK-UPDATE:NO
    # After this little change ... it will not longer look for a update on startup
    # of the addon.

    sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Info" --text="Checking for updates. Please wait ..." > /dev/null 2>&1)

    # We contact github to see what version is stored over there ....

    wget -O REMOTE-VERSION https://github.com/swtor00/swtor-addon-to-tails/blob/master/swtorcfg/swtor.cfg

    REMOTE=$(grep ">VERSION" REMOTE-VERSION | cut -d ">" -f2 | cut -d "<" -f 1)
    LOCAL=$(grep VERSION ~/Persistent/swtorcfg/swtor.cfg)

    # Comparing the remote and the local version of the scirpt..

    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo REMOTE-VERSION [$REMOTE] LOCAL-VERSION [$LOCAL]
    fi

    if [ "$REMOTE" == "$LOCAL" ] ; then
       if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo step 05
          echo "no updates found"
          echo done
       fi
    else

         # Is this script controlled with git or not ?

         if [ ! -d ~/Persistent/swtor-addon-to-tails/.git ] ; then 
             yad --title="Information " --width=400 --height=100 --center \
             --text="\n\n Addon has no .git directory.\n This means that this addon isn't controlled by git."
             exit 1
         fi
         sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Info" --text="Update found ... install the update ..." > /dev/null 2>&1)       
         ./udpate.sh
         if [ $TERMINAL_VERBOSE == "1" ] ; then
            echo step 05
            echo "Update for addon installed"
            echo done
         fi
    fi
    rm ~/Persistent/scripts/REMOTE-VERSION > /dev/null 2>&1
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
        echo step 05
        echo "Not checking for updates of the script."
        echo done
    fi
fi

sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Info" --text="Clean up all log-files" > /dev/null 2>&1)

# cleanup old connection-files file inside cfg directory

rm -rf /home/amnesia/Persistent/swtorcfg/*.arg > /dev/null 2>&1
rm -rf /home/amnesia/Persistent/swtorcfg/log/*.* > /dev/null 2>&1

# cleanup all browser-settings and extract all settings from tar file

if [ -d /home/amnesia/Persistent/settings/1  ] ; then
   rm -rf  ~/Persistent/settings/1 >/dev/null 2>&1
fi

if [ -d /home/amnesia/Persistent/settings/2  ] ; then
  rm -rf  ~/Persistent/settings/2 >/dev/null 2>&1
fi

if grep -q BROWSER-SOCKS5:YES ~/Persistent/swtorcfg/swtor.cfg ; then
       # Extract the default directorys 1 & 2

       cd ~/Persistent/settings
       tar xzf tmp.tar.gz
fi

# Test the state of the connection

if [ -f /home/amnesia/Persistent/scripts/state/online ] ; then
    cd /home/amnesia/Persistent/scripts/state
    rm online
fi

# Test for old saved passwords

cd /home/amnesia/Persistent/scripts

if [ -f /home/amnesia/Persistent/scripts/password ] ; then
   rm password
fi

if [ -f /home/amnesia/Persistent/scripts/password_correct ] ; then
   rm password_correct
fi


password=$(zenity --entry --text="Curent Tails administration-password please ? " --title=Password --hide-text)
echo $password > /home/amnesia/Persistent/scripts/password

# Empty password ?

if [ "$password" == "" ];then
   sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Info" --text="Password was blank .." > /dev/null 2>&1)
   rm /home/amnesia/Persistent/scripts/password > /dev/null 2>&1
   exit 1
fi

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo step 06
   echo checking password
   echo done
fi

sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Info" --text="Testing administration password ...." > /dev/null 2>&1)

# We make the password-test inside a own script

gnome-terminal --window-with-profile=Unnamed -x bash -c /home/amnesia/Persistent/scripts/testroot.sh > /dev/null 2>&1


# In the case of the file password_correct file has a size of 0 bytes ... The entered password wasn't correct 

if [ -s /home/amnesia/Persistent/scripts/password_correct ] ; then 
    sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Info" --text="Password was not correct .." > /dev/null 2>&1)
    rm password
    rm password_correct
    exit 1
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo step 07
       echo password is correct
       echo done
    fi
fi

sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Info" --text="Changing firewall rules to build a socks5 server  ..." > /dev/null 2>&1) 

# change firewall for a ssh-socks5-connection

if grep -q BROWSER-SOCKS5:YES ~/Persistent/swtorcfg/swtor.cfg ; then
   cat password | sudo -S iptables -I OUTPUT -o lo -p tcp --dport 9999 -j ACCEPT  > /dev/null 2>&1
   cat password | sudo -S apt autoremove --yes  > /dev/null 2>&1
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo step 08
      echo changing iptables firewall to accept socks5 connections
      echo autoremove old unused packages
      echo done
   fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo Browser-socks5 not selected
    fi
fi

# Creating Desktop link

sleep 2 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Info" --text="Creating symbolic link on Desktop  ..." > /dev/null 2>&1) 

# Make symbolic links on the desktop for the main menu
# This depends on the setting GUI-LINKS:YES and BROWSER-SOCKS5:YES inside of swtor.cfg

if grep -q BROWSER-SOCKS5:YES ~/Persistent/swtorcfg/swtor.cfg ; then
   if grep -q GUI-LINKS:YES ~/Persistent/swtorcfg/swtor.cfg ; then
          cd ~/Persistent/scripts

          if [ ! -L ~/Desktop/swtor-menu.sh ]
             then
             ln -s ~/Persistent/scripts/swtor-menu.sh ~/Desktop/swtor-menu.sh
             if [ $TERMINAL_VERBOSE == "1" ] ; then
                echo step 08
                echo symlink on desktop created
                echo done
             fi
          else
              if [ $TERMINAL_VERBOSE == "1" ] ; then
                 echo step 08
                 echo symlink on desktop allready exist
                 echo done
              fi
          fi
   fi
fi

if grep -q GUI-LINKS:NO  ~/Persistent/swtorcfg/swtor.cfg ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo step 08
       echo no symlink on desktop created .. setting GUI-LINKS:NO
       echo done
   fi
fi


# We don't need longer the stored administration password

if [ -f /home/amnesia/Persistent/scripts/password ] ; then
    cd /home/amnesia/Persistent/scripts
    rm password
    rm password_correct
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo step 09
       echo removing password
       echo done
    fi
fi



echo 1 > /home/amnesia/Persistent/scripts/state/offline


# We are done here , signal with Error Code 0

echo 1 > ~/swtor_init

exit 0

