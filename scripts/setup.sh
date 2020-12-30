#/bin/bash
#########################################################
# SCRIPT  : setup.sh                                    #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.14 or higher                        #
#                                                       #
#                                                       #
# VERSION : 0.52                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 30-12-20                                    #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################


# Check to see if ONION Network is allready runnig ....

curl --socks5 localhost:9050 --socks5-hostname localhost:9050 -s https://check.torproject.org/ -m 6 | grep -m 1 Congratulations > /dev/null
if [ $? -eq 0 ] ; then
   echo TOR is up and running and we can continue with the execution of the script ....
   echo done
else
   sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="ONION network not ready or no internet connection !" > /dev/null 2>&1)
   exit 1
fi




cd ~/Persistent

# We need a administration password, or the addon will not work properly

echo _123UUU__ | sudo -S /bin/bash > ~/Persistent/test_admin 2>&1

if grep -q "password is disabled" ~/Persistent/test_admin
 then
     rm ~/Persistent/test_admin > /dev/null 2>&1
     zenity --error --width=600 --text="This addon needs a administration password for tails on startup !"
     exit 1
else
    rm ~/Persistent/test_admin > /dev/null 2>&1
    echo we have a password 
fi

# is .ssh persistent ?

mount > ~/Persistent/mounted
if grep -q "/home/amnesia/.ssh" ~/Persistent/mounted
 then
     echo we have .ssh mounted
else
    echo failure
    zenity --error --width=600 --text="This addon needs the ssh option inside of the persistent volume.\n\nYou have to set this option and restart Tails !!"
    exit 1
fi


# is additional software peristent ?

if grep -q "/var/cache/apt/archives" ~/Persistent/mounted
 then
     rm ~/Persistent/mounted > /dev/null 2>&1
     echo we have additional software active
else
    rm ~/Persistent/mounted > /dev/null 2>&1
    echo failure

    zenity --error --width=600 --text="This addon needs the additional-software feature inside of the persistent volume.\n\nYou have to set this option and restart Tails !!"
    exit 1
fi


# Test for a prior execution of the script setup.sh

if [ ! -f ~/Persistent/swtor-addon-to-tails/setup ]
   then

   zenity --info --width=600 --text="Welcome to the swtor-addon-for-tails.\nThis ist the first time you startup this tool.\n\n* We create a few symlinks inside of persistent\n* We create a folder personal-files\n* We install additional software chromium and sshpass\n* We import bookmarks on demand\n\n\nPlease press OK to continue."

   echo creating symlinks

   ln -s ~/Persistent/swtor-addon-to-tails/settings ~/Persistent/settings
   ln -s ~/Persistent/swtor-addon-to-tails/scripts  ~/Persistent/scripts
   ln -s ~/Persistent/swtor-addon-to-tails/swtorcfg ~/Persistent/swtorcfg
   ln -s ~/Persistent/swtor-addon-to-tails/doc ~/Persistent/doc


   # creating log-directory for ssh

   if [ ! -d ~/Persistent/swtor-addon-to-tails/swtorcfg/log ]
      then
          mkdir -p ~/Persistent/swtor-addon-to-tails/swtorcfg/log
   fi

   if grep -q IMPORT-BOOKMARKS:YES ~/Persistent/swtorcfg/swtor.cfg
      then
          rsync -aqzh ~/Persistent/swtor-addon-to-tails/bookmarks /live/persistence/TailsData_unlocked
   fi
else
   zenity --error --width=600 --text="Setup has failed. This programm was allready executed once on this volume !"
   exit 1
fi

password=$(zenity --entry --text="Curent tails administration-password ? " --title=Password --hide-text)
echo $password > /home/amnesia/Persistent/password

# Empty password ?

if [ "$password" == "" ];then
   zenity --error --text "Password was empty !"
   rm /home/amnesia/Persistent/password > /dev/null 2>&1
   exit 1
fi

sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Please wait.We check the password !" > /dev/null 2>&1)

# We make the password-test inside a own script

gnome-terminal --window-with-profile=Unnamed -x bash -c /home/amnesia/Persistent/scripts/testroot.sh

if [ -s /home/amnesia/Persistent/scripts/password_correct ]
then
    zenity --info --text="Password was not coorect !"  > /dev/null 2>&1
    rm ~/Persistent/password
    rm ~/Persistent/password_correct
    exit 1
fi

# Creating personal-files and restore  bookmarks

mkdir ~/Persistent/personal-files

zenity --question --width=600 --text="Should a symlink created for the directory ~/personal-files ?"
case $? in
         0) symlinkdir=$(zenity --entry --width=600 --text="Please give the name of the symlinked directory  ? " --title=Directory)
            ln -s ~/Persistent/personal-files ~/Persistent/$symlinkdir
         ;;
         1) echo not creating symlink
         ;;
esac


zenity --question --width=600 --text="Would you like to create a fixed chromium profile  ? \nAll cookys stored in this profile remain stored even after a reboot !"
case $? in
         0) cd ~/Persistent/settings
            tar xzf tmp.tar.gz
            cp -r ~/Persistent/settings/2 ~/Persistent/personal-files/3
            rm -rf /Persistent/settings/2
            rm -rf /Persistent/settings/1
         ;;
         1) echo not creatinging fixed browsing profile
         ;;
esac


zenity --question --width=600 --text="Configure the additional software for the addon  ?"
case $? in
         0) echo we do install the additional software

         # apt-get update

         sleep 14 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Update the paket-list with apt-get update.\nThis may needs some time" > /dev/null 2>&1)
         sleep 1
         cat ~/Persistent/password | sudo -S apt-get update
         sleep 1
         sleep 14 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Update is done.\nNow we can install the additional software\n" > /dev/null 2>&1)

         # Install chromium

         cat ~/Persistent/password | sudo -S apt-get install -y chromium
         cat ~/Persistent/password | sudo -S apt-get install -y chromium-sandbox
         cat ~/Persistent/password | sudo -S apt-get install -y html2text 


         # Install sshpass

         cat ~/Persistent/password | sudo -S apt-get install -y sshpass

         # Install yad

         cat ~/Persistent/password | sudo -S apt-get install -y yad

         ;;
         1) echo nothing to do ..
         ;;
esac

rm ~/Persistent/password
rm ~/Persistent/password_correct

echo 1 > ~/Persistent/swtor-addon-to-tails/setup


sleep 10 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Setup is now complete ! You can now start the addon with swtor-menu.sh" > /dev/null 2>&1)

exit 0


