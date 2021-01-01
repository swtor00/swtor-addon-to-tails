
#!/bin/bash
#########################################################
# SCRIPT  : startup.sh                                  #
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
# DATE    : 25-12-2020                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################


# Has setup ever run on this tails system ?

if [ !  -f ~/Persistent/swtor-addon-to-tails/setup ]
   then
       notify-send "Execute the command \"setup-swtor.sh\" first !"
       exit 1

else
    echo step 01a.
    echo "setup-swtor has ben executed once .... "
    echo done
fi

# test for installed yad command from persistent volume

if grep -q "status installed yad" /var/log/dpkg.log
then
    echo step 01b.
    echo "yad is installed .... "
    echo done
else
    echo step 01b.
    echo "yad is not installed .... "
    echo done
    notify-send "Additional software yad isn't installed"
    exit 1
fi

# test for installed sshpass command from persistent volume

if grep -q "status installed sshpass" /var/log/dpkg.log
then
    echo step 01c.
    echo "sshpass is installed .... "
    echo done
else
    echo step 01c.
    echo "sshpass is not installed .... "
    echo done
    notify-send "Additional software sshpass isn't installed"
    exit 1
fi


# test for installed html2text command from persistent volume

if grep -q "status installed html2text" /var/log/dpkg.log
then
    echo step 01d.
    echo "html2text is installed .... "
    echo done
else
    echo step 01d.
    echo "html2text is not installed .... "
    echo done
    notify-send "Additional software html2text isn't installed"
    exit 1
fi

# test for installed chromium command from persistent volume

if grep -q "status installed chromium" /var/log/dpkg.log
then
    echo step 01e.
    echo "chromium is installed .... "
    echo done
else
    echo step 01e.
    echo "chromium is not installed .... "
    echo done
    notify-send "Additional software chromium isn't installed"
    exit 1
fi


# test for installed chromium-sandbox command from persistent volume

if grep -q "status installed chromium-sandbox" /var/log/dpkg.log
then
    echo step 01f.
    echo "chromium-sandbox is installed .... "
    echo done
else
    echo step 01f.
    echo "chromium-sandbox is not installed .... "
    echo done
    notify-send "Additional software chromium-sandbox isn't installed"
    exit 1
fi



# Do we have a freezed Tails ?

if [ -f ~/Persistent/swtorcfg/freezed.cgf ]
   then
       tails-version > ~/Persistent/scripts/current

       if diff -q ~/Persistent/swtorcfg/freezed.cgf ~/Persistent/scripts/current ;then
          echo step 02
          echo this system was freezed with the same version of tails that it was created  ...
          echo done
       else
            # Houston ... We have a problem
            # You should not run this addon with a freezed system from a older tails version than the current one ...

            rm -rf /live/persistence/TailsData_unlocked/dotfiles/.config > /dev/null 2>&1
            rm -rf /live/persistence/TailsData_unlocked/dotfiles/Desktop > /dev/null 2>&1
            rm ~/Persistent/swtorcfg/freezed.cgf > /dev/null 2>&1

            yad --title="Error " --width=400 --height=100 --center \
            --text="\n\nThis system was freezed with a older version of tails.\nYou have to reboot this system to complete unfreezing"
            exit 1
       fi
       rm ~/Persistent/scripts/current > /dev/null 2>&1
fi



# Check to see if ONION Network is allready runnig ....

curl --socks5 localhost:9050 --socks5-hostname localhost:9050 -s https://check.torproject.org/ -m 6 | grep -m 1 Congratulations > /dev/null
if [ $? -eq 0 ] ; then
   echo step 03
   echo TOR is up and running and we can continue with the execution of the script ....
   echo done
else
   yad --title="Error " --width=400 --height=100 --center \
   --text="\n\n ONION network not ready or no internet connection \n\n"
  exit 1
fi



# We need a administration password, or the addon will not work properly

echo _123UUU__ | sudo -S /bin/bash > ~/Persistent/scripts/test_admin 2>&1

if grep -q "is not allowed to execute" ~/Persistent/scripts/test_admin
 then
     rm ~/Persistent/scripts/test_admin > /dev/null 2>&1
     yad --title="Error " --width=400 --height=100 --center --text="\n\n You have to set a administration password on\n the greeting-screen of tails!"
     exit 1
else
    rm ~/Persistent/scripts/test_admin > /dev/null 2>&1
    echo step 04
    echo we have a administration password
    echo done
fi


# Check for updates on demand if CHECK-UPDATE:YES is set of inside swtor.cfg
# The default Value of this setting is : NO

if grep -q CHECK-UPDATE:YES ~/Persistent/swtorcfg/swtor.cfg
 then

    echo "Checking for updates on github because of update"

    # If you don't like this behavior on startup, you should open the
    # configuration file ~/Persistent/swtorcfg/swtor.cfg and set the option
    # CHECK-UPDATE:YES to the value CHECK-UPDATE:NO
    # After this little change ... it will not longer look for a update on startup 

    yad --title="Information " --width=400 --height=100 --no-buttons --center --timeout=4 --text="\n\n Checking for Updates ... Please wait !"

    # We contact github to see what version is stored over there ....

    wget -O REMOTE-VERSION https://github.com/swtor00/swtor-addon-to-tails/blob/master/swtorcfg/swtor.cfg

    REMOTE=$(grep ">VERSION" REMOTE-VERSION | cut -d ">" -f2 | cut -d "<" -f 1)
    LOCAL=$(grep VERSION ~/Persistent/swtorcfg/swtor.cfg)

    # Comparing the remote and the local version of the scirpt..

    echo REMOTE-VERSION [$REMOTE] LOCAL-VERSION [$LOCAL]

    if [ "$REMOTE" == "$LOCAL" ]
    then
        echo step 05
        echo "no updates found"
        echo done
        yad --title="Information " --width=400 --height=100 --no-buttons --center --timeout=4 --text="\n\n No updates found on github !"        

    else

         # Is this script controlled with git or not ?

         if [ ! -d ~/Persistent/swtor-addon-to-tails/.git ]
         then
             yad --title="Information " --width=400 --height=100 --center \
             --text="\n\n Addon has no .git directory.\n This means that this addon isn't controlled by git."
             exit 1
         fi

         yad --title="Information " --width=400 --height=100 --no-buttons --center --timeout=4 \
         --text="\n\n Found a update on github.\n The Addon will be updated to the latest version."         
         ./udpate.sh
         echo step 05
         echo "Update for addon installed"
         echo done  
    fi

    rm ~/Persistent/scripts/REMOTE-VERSION > /dev/null 2>&1

else
    echo step 05
    echo "Not checking for updates of the script."
    echo done
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
   yad --title="Error " --width=400 --height=100 --center --timeout=4 \
   --text="\n\n Password was blank \n\n"
   rm /home/amnesia/Persistent/scripts/password > /dev/null 2>&1
   exit 1
fi

echo step 06
echo checking password
echo done

# We make the password-test inside a own script

gnome-terminal --window-with-profile=Unnamed -x bash -c /home/amnesia/Persistent/scripts/testroot.sh > /dev/null 2>&1


# In the case of the file password_correct file has a size of 0 bytes ... The entered password wasn't correct 

if [ -s /home/amnesia/Persistent/scripts/password_correct ]
then
    yad --title="Error " --width=400 --height=100 --center --timeout=4 \
    --text="\n\n Password was not correct \n\n"
    rm password
    rm password_correct
    exit 1
else
    echo step 07
    echo password is correct 
    echo done
fi


# change firewall for a ssh-socks5-connection

if grep -q BROWSER-SOCKS5:YES ~/Persistent/swtorcfg/swtor.cfg
   then
   cat password | sudo -S iptables -I OUTPUT -o lo -p tcp --dport 9999 -j ACCEPT
   cat password | sudo -S apt autoremove --yes
   echo step 08
   echo changing iptables firewall to accept socks5 connections
   echo autoremove old unused packages    
   echo done
else
   echo Browser-socks5 not selected
fi


# Make symbolic links on the desktop for the main menu 
# This depends on the setting GUI-LINKS:YES and BROWSER-SOCKS5:YES inside of swtor.cfg

if grep -q BROWSER-SOCKS5:YES ~/Persistent/swtorcfg/swtor.cfg
   then
   if grep -q GUI-LINKS:YES ~/Persistent/swtorcfg/swtor.cfg
      then
          cd ~/Persistent/scripts

          if [ ! -L ~/Desktop/swtor-menu.sh ]
             then
             ln -s ~/Persistent/scripts/swtor-menu.sh ~/Desktop/swtor-menu.sh
             echo step 08
             echo symlink on desktop created  
             echo done
          else
             echo step 08
             echo symlink on desktop allready exist   
             echo done
          fi
   fi
fi

if grep -q GUI-LINKS:NO  ~/Persistent/swtorcfg/swtor.cfg
   then
   echo step 08
   echo no symlink on desktop created .. setting GUI-LINKS:NO 
   echo done
fi


# We don't need longer the stored administration password 

if [ -f /home/amnesia/Persistent/scripts/password ]
then
    cd /home/amnesia/Persistent/scripts
    rm password 
    rm password_correct 
    echo step 09
    echo removing password
    echo done
fi


echo 1 > /home/amnesia/Persistent/scripts/state/offline


# We are finished here , signal with Error Code 0

echo 1 > ~/swtor_init
exit 0

