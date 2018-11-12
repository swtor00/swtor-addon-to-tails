
#!/bin/bash
#########################################################
# SCRIPT  : startup.sh                                  #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 3.10.1 or higher                      #
# TASKS   : Install software and create all symbolic    #
# links on the Desktop of tails.                        #
#                                                       #
# VERSION : 0.40                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 05-09-10                                    #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################


# Has setup ever run on this addon ?

if [ !  -f ~/Persistent/swtor-addon-to-tails/setup ]
   then
       sleep 8 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Please execute the command \"setup-swtor.sh\" first !" > /dev/null 2>&1)
       exit 1
fi

# Do we have a freezed Tails ?

if [ -f ~/Persistent/swtorcfg/freezed.cgf ]
   then
       tails-version > ~/Persistent/scripts/current

       if diff -q ~/Persistent/swtorcfg/freezed.cgf ~/Persistent/scripts/current ;then
          echo equal ...
       else
            # Houston ... We have a problem

            zenity --question  --text "Warning - Warning - Warning - Warning - Warning\n\nYour current Tails is freezed with a other version than it was created. Delete the current freezing from the old Tails ?"
            case $? in
            0)  rm -rf /live/persistence/TailsData_unlocked/dotfiles/.config > /dev/null 2>&1
                rm -rf /live/persistence/TailsData_unlocked/dotfiles/Desktop > /dev/null 2>&1
                rm ~/Persistent/swtorcfg/freezed.cgf > /dev/null 2>&1
                sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Current settings are now unfreezed.\nPlease reboot Tails now ! " > /dev/null 2>&1)
                exit 1
                ;;
            1) exit 1
                ;;
            esac
       fi
       rm ~/Persistent/scripts/current > /dev/null 2>&1
fi


# We need a administration password, or the addon will not work properly

echo _123UUU__ | sudo -S /bin/bash > ~/Persistent/scripts/test_admin 2>&1

if grep -q "is not allowed to execute" ~/Persistent/scripts/test_admin
 then
     rm ~/Persistent/scripts/test_admin > /dev/null 2>&1
     zenity --error --text "This addon needs a administration password on startup.\n\nYou have to restart Tails and set a administration password !!"
     exit 1
else
    rm ~/Persistent/scripts/test_admin > /dev/null 2>&1
    echo we have a password
fi

# Check to see if  TOR is allready runnig ....

/usr/local/sbin/tor-has-bootstrapped
if [ $? -eq 0 ] ; then
    echo TOR is running and we can continue to execute the script ....
else
    sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="TOR Network is not ready !" > /dev/null 2>&1)
    exit 1
fi

# Check for updates on demand if CHECK-UPDATE:YES is set of inside swtor.cfg

if grep -q CHECK-UPDATE:YES ~/Persistent/swtorcfg/swtor.cfg
 then
    echo "Checking for updates on github"

    # If you don't like this behavior on startup, you should open with a editor the
    # configuration file ~/Persistent/swtorcfg/swtor.cfg and set the option
    # CHECK-UPDATE:YES
    # to the value
    # CHECK-UPDATE:NO
    # After this little change ... it will not longer look for a update

    sleep 3 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Checking for updates ... please wait !" > /dev/null 2>&1)

    # We contact github to see what version is over there stored ....

    wget -O REMOTE-VERSION https://github.com/swtor00/swtor-addon-to-tails/blob/master/swtorcfg/swtor.cfg

    REMOTE=$(grep ">VERSION" REMOTE-VERSION | cut -d ">" -f2 | cut -d "<" -f 1)
    LOCAL=$(grep VERSION ~/Persistent/swtorcfg/swtor.cfg)

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
             zenity --info  --text="Addon has no .git directory inside of ~/Persistent/swtor-addon-to-tails !"  > /dev/null 2>&1
             exit 1
         fi

        zenity --question  --text "There is a newer version to download. Would you like to update now ?"
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

    rm ~/Persistent/scripts/REMOTE-VERSION > /dev/null 2>&1

else
    echo "Not checking for updates because value CHECK-UPDATES:NO inside configuration swtor.cfg"
fi

# cleanup old connection-files file inside cfg directory

rm -rf /home/amnesia/Persistent/swtorcfg/*.arg > /dev/null 2>&1
rm -rf /home/amnesia/Persistent/swtorcfg/log/*.* > /dev/null 2>&1

# cleanup all browser-settings and extract all settings from tar file

if [ -d /home/amnesia/Persistent/settings/1  ]
then
   rm -rf  ~/Persistent/settings/1 >/dev/null 2>&1
fi

if [ -d /home/amnesia/Persistent/settings/2  ]
then
  rm -rf  ~/Persistent/settings/2 >/dev/null 2>&1
fi


if grep -q BROWSER-SOCKS5:YES ~/Persistent/swtorcfg/swtor.cfg
   then
       sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Extracting profiles 1 + 2 for chromium.\n\nPlease wait." > /dev/null 2>&1)

       # Extract the default directorys 1 & 2

       cd ~/Persistent/settings
       tar xzf tmp.tar.gz
fi

# Test the state of the connection

if [ -f /home/amnesia/Persistent/scripts/state/online ]
then
    cd /home/amnesia/Persistent/scripts/state
    rm online
fi

# Test for old saved passwords

cd /home/amnesia/Persistent/scripts

if [ -f /home/amnesia/Persistent/scripts/password ]
then
    rm password
fi

if [ -f /home/amnesia/Persistent/scripts/password_correct ]
then
    rm password_correct
fi

password=$(zenity --entry --text="Curent Tails administration-password please ? " --title=Password --hide-text)
echo $password > /home/amnesia/Persistent/scripts/password

# Empty password ?

if [ "$password" == "" ];then
   zenity --error --text "Password was empty !"
   rm /home/amnesia/Persistent/scripts/password > /dev/null 2>&1
   exit 1
fi


sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="We check the provided password.\n\nPlease wait !" > /dev/null 2>&1)

# We make the password-test inside a own script

gnome-terminal --window-with-profile=Unnamed -x bash -c /home/amnesia/Persistent/scripts/testroot.sh

# In the case the file password_correct file has a size of 0 bytes ... The submitted password was wrong

if [ -s /home/amnesia/Persistent/scripts/password_correct ]
then
    zenity --info  --text="Password was not coorect !"  > /dev/null 2>&1
    rm password
    rm password_correct
    exit 1
else
   echo .
   echo all clear. We proceed with the customizing of tails.
   echo .
fi


# change firewall for a ssh-socks5-connection

if grep -q BROWSER-SOCKS5:YES ~/Persistent/swtorcfg/swtor.cfg
   then
   echo we do allow port 9999 from lopback-device to ssh.
   cat password | sudo -S iptables -I OUTPUT -o lo -p tcp --dport 9999 -j ACCEPT
   sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Change the firewall-settings for the addon.\n\nPlease wait !" > /dev/null 2>&1)
else
   echo Browser-socks5 not selected
fi


# test for chmomium-browser

if grep -q BROWSER-SOCKS5:YES ~/Persistent/swtorcfg/swtor.cfg
   then
   if [ ! -f /usr/bin/chromium ]
      then
          zenity --error --text "Chromium isn't installed by now ! The addional-software feature of Tails has to be enabled."
          rm password
          rm password_correct
       exit 1
   fi
fi

# test for sshpass

if [ ! -f /usr/bin/sshpass ]
    then
        zenity --error --text "sshpass isn't installed by now ! The addional-software feature of Tails has to be enabled."
        rm password
        rm password_correct
  exit 1
fi


# Make symbolic links on the desktop for the browser and the ssh-connection
# This depends on the setting GUI-LINKS:YES and BROWSER-SOCKS5:YES inside swtor.cfg

if grep -q BROWSER-SOCKS5:YES ~/Persistent/swtorcfg/swtor.cfg
   then
   if grep -q GUI-LINKS:YES ~/Persistent/swtorcfg/swtor.cfg
      then
          cd ~/Persistent/scripts

          if [ ! -L ~/Desktop/swtor-menu.sh ]
             then
             ln -s ~/Persistent/scripts/swtor-menu.sh ~/Desktop/swtor-menu.sh
          else
              echo symlink exist on Desktop
          fi
   fi
fi


if grep -q GUI-LINKS:NO  ~/Persistent/swtorcfg/swtor.cfg
   then
   echo no symbolic links created on desktop of tails !
fi

if [ -f /home/amnesia/Persistent/scripts/password ]
then
    cd /home/amnesia/Persistent/scripts
    rm password
    rm password_correct
fi


echo 1 > /home/amnesia/Persistent/scripts/state/offline

# Show about dialog as last thing

./swtor-about &
sleep 5
pkill swtor-about

# Mark, that we ware through the init-process with Error Code 0

echo 1 > ~/swtor_init
exit 0

