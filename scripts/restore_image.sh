#/bin/bash
#########################################################
# SCRIPT  : restore_image.sh                            #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.1.1 or higher                       #
# TASKS   : Restore a saved image of all important      #
# persistent files of tails                             #
#                                                       #
# VERSION : 0.51                                        #
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

# Check to see if TOR is allready runnig ....

curl --socks5 localhost:9050 --socks5-hostname localhost:9050 -s https://check.torproject.org/ | cat | grep -m 1 Congratulations
if [ $? -eq 0 ] ; then
   echo TOR is running and we can continue with the execution of the script ....
else
  sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="TOR Network is not ready !" > /dev/null 2>&1)
  exit 1
fi


# We need a administration password, or the addon will not work properly
cd ~/Persistent

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


if [ -z "$(ls -A ~/Persistent/swtor-addon-to-tails )" ];then

   zenity --info --width=600 --text="Welcome to the swtor-addon-for-tails.\nThis ist the first time you startup this recovery-mode.\n\nPlease press OK to continue."

   echo
   echo we need to download the script ... execute git command to donwload
   echo
   echo
   sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Download current swtor-shell code from github.Please wait.This may needs some time" > /dev/null 2>&1)
         git clone https://github.com/swtor00/swtor-addon-to-tails
   echo
   cp ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.git-hub
   sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Download finished." > /dev/null 2>&1)

   echo creating symlinks

   ln -s ~/Persistent/swtor-addon-to-tails/settings  ~/Persistent/settings
   ln -s ~/Persistent/swtor-addon-to-tails/scripts   ~/Persistent/scripts
   ln -s ~/Persistent/swtor-addon-to-tails/swtorcfg  ~/Persistent/swtorcfg
   ln -s ~/Persistent/swtor-addon-to-tails/doc ~/Persistent/doc

   if [ ! -d ~/Persistent/swtor-addon-to-tails/swtorcfg/log ]
      then
          mkdir -p ~/Persistent/swtor-addon-to-tails/swtorcfg/log
   fi

else
       sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Addon allready found on this device." > /dev/null 2>&1)
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
    zenity --info  --text="Password was not coorect !"  > /dev/null 2>&1
    rm ~/Persistent/password
    rm ~/Persistent/password_correct
    exit 1
else
   echo .
   echo all clear. We proceed with the restore of inmage
   echo .
fi


cat password | sudo -S chown root:root /home/amnesia/Persistent/tails-image*.tar.gz
tar xf tails-image*.tar.gz


# Creating personal-files and restore  bookmarks

mkdir ~/Persistent/personal-files

zenity --question  --text "Should a symlink created for the directory ~/personal-files ?"
case $? in
         0) symlinkdir=$(zenity --entry --text="Please give the name of the symlinked directory  ? " --title=Directory)
            ln -s ~/Persistent/personal-files ~/Persistent/$symlinkdir
            cp ~/Persistent/home/amnesia/Persistent/backup/personal-files/* ~/Persistent/personal-files
         ;;
         1) echo not creating symlink
         ;;
esac


zenity --question  --text "Would you like to create a fixed chromium profile  ? \nAll cookys stored in this profile remain stored even after a reboot !"
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

if [ -z "$(ls -A ~/Persistent/home/amnesia/Persistent/backup/bookmarks )" ]; then
    echo no data for [bookmarks]
else
    zenity --question  --text "Should the saved bookmarks from backup be restored ?"
    case $? in
         0) rsync -aqzh ~/Persistent/home/amnesia/Persistent/backup/bookmarks /live/persistence/TailsData_unlocked
         ;;
         1) echo bookmarks from backup not restored on demand
         ;;
    esac
fi


if [ -z "$(ls -A ~/Persistent/home/amnesia/Persistent/backup/dotfiles )" ]; then
   echo no data for [dotfiles]
else
    zenity --question  --text "Should the dotfiles be restored ?"
    case $? in
         0) rsync -aqzh ~/Persistent/home/amnesia/Persistent/backup/dotfiles /live/persistence/TailsData_unlocked
         ;;
         1) echo dotfiles not restored on demand
         ;;
    esac
fi


if [ -z "$(ls -A ~/Persistent/home/amnesia/Persistent/backup/electrum )" ]; then
    echo no data for [electrum]
else
    zenity --question  --text "Should the electrum files be restored ?"
    case $? in
         0) rsync -aqzh ~/Persistent/home/amnesia/Persistent/backup/dotfiles /live/persistence/TailsData_unlocked
         ;;
         1) echo electrum files not restored on demand
         ;;
    esac
fi


if [ -z "$(ls -A ~/Persistent/home/amnesia/Persistent/backup/gnupg )" ]; then
    echo no data for [gnupg]
else
    zenity --question  --text "Should the gnupg files be restored ?"
    case $? in
         0) rsync -aqzh ~/Persistent/home/amnesia/Persistent/backup/gnupg  /live/persistence/TailsData_unlocked
         ;;
         1) echo gnupg files not restored on demand
         ;;
    esac
fi


if [ -z "$(ls -A ~/Persistent/home/amnesia/Persistent/backup/openssh-client )" ]; then
    echo no data for [openssh-client]
else
    zenity --question  --text "Should the openssh-client files be restored ?"
    case $? in
         0) rsync -aqzh ~/Persistent/home/amnesia/Persistent/backup/openssh-client /live/persistence/TailsData_unlocked
         ;;
         1) echo openssh-client files not restored on demand
         ;;
    esac
fi



if [ -z "$(ls -A ~/Persistent/home/amnesia/Persistent/backup/pidgin )" ]; then
    echo no data for [pidgin]
else
    zenity --question  --text "Should the pidgin files be restored ?"
    case $? in
         0) rsync -aqzh ~/Persistent/home/amnesia/Persistent/backup/pidgin /live/persistence/TailsData_unlocked
         ;;
         1) echo pidgin files not restored on demand
         ;;
    esac
fi



if [ -z "$(ls -A ~/Persistent/home/amnesia/Persistent/backup/thunderbird )" ]; then
    echo no data for [thunderbird]
else
    zenity --question  --text "Should the thunderbird files be restored ?"
    case $? in
         0) rsync -aqzh ~/Persistent/home/amnesia/Persistent/backup/thunderbird /live/persistence/TailsData_unlocked
         ;;
         1) echo thunderbird files not restored on demand
         ;;
    esac
fi


if [ -z "$(ls -A ~/Persistent/home/amnesia/Persistent/backup/swtorcfg )" ]; then
    echo no data for [swtorcfg]
else
    zenity --question  --text "Should the swtor configuration files be restored ?"
    case $? in
         0) cp ~/Persistent/home/amnesia/Persistent/backup/swtorcfg/*.cfg  ~/Persistent/swtorcfg
            cp ~/Persistent/swtorcfg/swtor.cfg ~/Persistent/swtorcfg/swtor.old-config
            cp ~/Persistent/swtorcfg/swtor.github ~/Persistent/swtorcfg/swtor.cfg
         ;;
         1) echo swtor configuration files not restored on demand
         ;;
    esac
fi



if [ -z "$(ls -A ~/Persistent/home/amnesia/Persistent/backup/personal-files/3 )" ]; then
    echo no data for [personal-files]
else
    zenity --question  --text "Should the fixed profile from backup be restored ?"
    case $? in
         0) rsync -aqzh ~/Persistent/home/amnesia/Persistent/backup/personal-files/3  /home/amnesia/Persistent/personal-files
         ;;
         1) echo fixed profile files not restored on demand
         ;;
    esac
fi


if [ -z "$(ls -A ~/Persistent/home/amnesia/Persistent/backup/Tor)" ]; then
    echo no data for [personal-files]
else
    zenity --question  --text "Should the TOR Browser directory inside of ~/Persistent from backup be restored ?"
    case $? in
         0) cp -r ~/Persistent/home/amnesia/Persistent/backup/Tor/*  ~/Persistent/Tor\ Browser/
         ;;
         1) echo TOR Browser directory inside ~/Persistent not restored on demand
         ;;
    esac
fi


cat ~/Persistent/password | sudo -S chown -R root:root /home/amnesia/Persistent/home/amnesia/Persistent/backup/cups-configuration
cat ~/Persistent/password | sudo -S chown -R root:root /home/amnesia/Persistent/home/amnesia/Persistent/backup/nm-system-connections

zenity --question  --text "Should the cups files from backup be restored ?"
case $? in
         0) cat ~/Persistent/password | sudo -S rsync -aqzh /home/amnesia/Persistent/home/amnesia/Persistent/backup/cups-configuration /live/persistence/TailsData_unlocked
         ;;
         1) echo cups files not restored on demand
         ;;
esac


zenity --question  --text "Should the network-configuration from backup with all stored passwords be restored ?"
case $? in
         0) cat ~/Persistent/password | sudo -S rsync -aqzh /home/amnesia/Persistent/home/amnesia/Persistent/backup/nm-system-connections /live/persistence/TailsData_unlocked
         ;;
         1) echo network-configuration not restored on demand
         ;;
esac


zenity --question  --text "Configure the additional software for the addon  ?"
case $? in
         0) echo we do install the additional software

         # apt-get update

         sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Update the paket-list with apt-get update.\nThis may needs some time" > /dev/null 2>&1)
         sleep 1
         cat ~/Persistent/password | sudo -S apt-get update
         sleep 1
         sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Update is done.\nNow we can install the additional software\n" > /dev/null 2>&1)

         # Install chromium

         cat ~/Persistent/password | sudo -S apt-get install -y chromium

         # Install sshpass

         cat ~/Persistent/password | sudo -S apt-get install -y sshpass

         ;;
         1) echo nothing to do ..
         ;;
esac


zenity --question  --text "Remove the extracted backup-directory ?"
case $? in
         0) cat ~/Persistent/password | sudo -S rm -rf /home/amnesia/Persistent/home
         ;;
         1) echo do not remove the backup directory
         ;;
esac


rm ~/Persistent/password
rm ~/Persistent/password_correct


echo 1 > ~/Persistent/swtor-addon-to-tails/setup


sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Restore is now complete.Please restart Tails to have all settings active ! " > /dev/null 2>&1)


exit 0


