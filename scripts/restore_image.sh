#/bin/bash
#########################################################
# SCRIPT  : restore_image.sh                            #
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
# DATE    : 30-12-2020                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################


# Check to see if ONION Network is allready runnig ....

curl --socks5 localhost:9050 --socks5-hostname localhost:9050 -s https://check.torproject.org/ -m 6 | grep -m 1 Congratulations > /dev/null
if [ $? -eq 0 ] ; then
   echo step 01a.
   echo TOR is up and running and we can continue with the execution of the script ....
   echo done
else
  sleep 6 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Info" --text="TOR is not ready or no internet connection" > /dev/null 2>&1)
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
    rm ~/Persistent/test_admin >/dev/null 2>&1
    echo we have a password > /dev/null 2>&1
fi


# is .ssh persistent ?

mount > ~/Persistent/mounted
if grep -q "/home/amnesia/.ssh" ~/Persistent/mounted
 then
     echo we have .ssh mounted
else
    echo failure
    zenity --error --width=600 --text="This addon needs the ssh option inside of the persistent volume.\nYou have to set this option and restart Tails."
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

    zenity --error --width=600 --text="This addon needs the additional-software feature inside of the persistent volume.\nYou have to set this option and restart Tails."
    exit 1
fi




if [ -z "$(ls -A ~/Persistent/swtor-addon-to-tails > /dev/null 2>&1)" ];then

   zenity --info --width=600 --text="Welcome to the persistent restore-image for-tails.\n\nThis script restores all data from a saved image.\n\nPlease press OK to continue."
   echo we need to download the script ... execute git command to donwload > /dev/null 2>&1
   sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Download current swtor-shell code from github. Please wait ! \nThis may needs some time" > /dev/null 2>&1)
         git clone https://github.com/swtor00/swtor-addon-to-tails > /dev/null 2>&1

   sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Download from github is now finished." > /dev/null 2>&1)

   echo creating symlinks > /dev/null 2>&1

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
   sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Password was empty." > /dev/null 2>&1)
   rm /home/amnesia/Persistent/password > /dev/null 2>&1
   exit 1
fi


# We make the password-test inside a own script

gnome-terminal --window-with-profile=Unnamed -x bash -c /home/amnesia/Persistent/scripts/testroot.sh > /dev/null 2>&1

if [ -s /home/amnesia/Persistent/scripts/password_correct ]
then
    sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Password was not correct." > /dev/null 2>&1)
    rm ~/Persistent/password > /dev/null 2>&1
    rm ~/Persistent/password_correct > /dev/null 2>&1
    exit 1
else
   echo all clear. We proceed with the restore of inmage >/dev/null 2>&1
fi

# Find the backup-file 

backup_file=$(cat password | sudo -S find /home/amnesia/Persistent | grep tails-image* )

if [ "$backup_file" == "" ];then
   sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="No valid Backup-file found on this persistent volume !" > /dev/null 2>&1)
   rm /home/amnesia/Persistent/password > /dev/null 2>&1
   exit 1
fi

cp $(echo $backup_file) /home/amnesia/Persistent/ >/dev/null 2>&1

cat password | sudo -S chown root:root /home/amnesia/Persistent/tails-image*.tar.gz
cat password | sudo -S tar xf tails-image*.tar.gz


# Creating personal-files and copy back symbolic linkes 

mkdir ~/Persistent/personal-files >/dev/null 2>&1

zenity --question --width=500 --text "Should a symlink created for the directory ~/personal-files ?"
case $? in
         0) symlinkdir=$(zenity --entry --text="Please give the name of the symlinked directory  ? " --title=Directory)
            ln -s ~/Persistent/personal-files ~/Persistent/$symlinkdir

            rm  ~/Persistent/home/amnesia/Persistent/backup/personal-files/3 > /dev/null 2>&1
            cp -r ~/Persistent/home/amnesia/Persistent/backup/personal-files/* ~/Persistent/personal-files > /dev/null 2>&1
         ;;
         1) echo not creating symlink > /dev/null 2>&1
         ;;
esac

# Restoring saved bookmarks if they exist 

if [ -z "$(ls -A ~/Persistent/home/amnesia/Persistent/backup/bookmarks)" ]; then
    echo no data [bookmarks] found ... > /dev/null 2>&1
else
    zenity --question --width=500 --text "Should the saved bookmarks from the backup be restored ?"
    case $? in
         0) cp ~/Persistent/home/amnesia/Persistent/backup/bookmarks/* ~/.mozilla/firefox/bookmarks > /dev/null 2>&1
         ;;
         1) echo bookmarks from backup not restored on demand > /dev/null 2>&1
         ;;
    esac
fi

# At first we look inside of the image if there was a fixed profile for chromium. 


if [ -z "$(ls -A ~/Persistent/home/amnesia/Persistent/backup/personal-files/fixed-profile 2>/dev/null)" ]; then
    echo no data [fixed-profile] > /dev/null 2>&1
    zenity --question --width=500 --text "Would you like to create a new fixed chromium profile ?  \nAll information stored in this profile remains even after a reboot"
    case $? in
         0) cd ~/Persistent/settings
            tar xzf tmp.tar.gz
            cp -r ~/Persistent/settings/2 ~/Persistent/personal-files/3 > /dev/null 2>&1
            rm -rf /Persistent/settings/2 > /dev/null 2>&1
            rm -rf /Persistent/settings/1 > /dev/null 2>&1
         ;;
         1) echo not creating fixed browsing profile > /dev/null 2>&1
         ;;
    esac
else
    zenity --question --width=500 --text "Should the fixed profile from the backup be restored ? \nIf you say No there will not be a fixed profile."
    case $? in
         0) mv /home/amnesia/Persistent/backup/fixed-profile /home/amnesia/Persistent/backup/3
            rsync -avzh /home/amnesia/Persistent/backup/3  ~/Persistent/home/amnesia/Persistent/backup/personal-files > /dev/null 2>&1
         ;;
         1) echo fixed profile files not restored on demand > /dev/null 2>&1
         ;;
    esac
fi


# Restoring saved ssh-keys if they exist

if [ -z "$(ls -A ~/Persistent/home/amnesia/Persistent/backup/openssh-client)" ]; then
    echo no data [openssh-client] > /dev/null 2>&1
else
    zenity --question --width=500 --text "Should the openssh-keys be restored from the image ? \nAny existing file inside this directory will may be overwritten !"
    case $? in
         0) cp ~/Persistent/home/amnesia/Persistent/backup/openssh-client/* ~/.ssh
         ;;
         1) echo openssh-client files not restored on demand > /dev/null 2>&1
         ;;
    esac
fi


# Restoring network-connections if they exist 

cat ~/Persistent/password | sudo -S chown -R root:root /home/amnesia/Persistent/home/amnesia/Persistent/backup/nm-system-connections > /dev/null 2>&1

if [ -z "$(ls -A ~/Persistent/home/amnesia/Persistent/backup/nm-system-connections)" ]; then
    echo no data [network-connections] > /dev/null 2>&1
else
   zenity --question --width=500 --text "Should the network-configurations from the image be restored ?\nAll existing files will be overwritten !"
   case $? in
         0) cat ~/Persistent/password | sudo -S rsync -aqzh /home/amnesia/Persistent/home/amnesia/Persistent/backup/nm-system-connections /live/persistence/TailsData_unlocked > /dev/null 2>&1
         ;;
         1) echo network-connections not restored on demand > /dev/null 2>&1
         ;;
   esac
fi 


# Restoring swtor-configuraion files if they exist 

if [ -z "$(ls -A ~/Persistent/home/amnesia/Persistent/backup/swtorcfg)" ]; then
    echo no data for [swtorcfg] > /dev/null 2>&1
else
    zenity --question --width=500 --text "Should the swtor configuration swtorssh.cfg file be restored ?"
    case $? in
         0) cp ~/Persistent/home/amnesia/Persistent/backup/swtorcfg/swtorssh.cfg  ~/Persistent/swtorcfg
            cp ~/Persistent/home/amnesia/Persistent/backup/swtorcfg/my*  ~/Persistent/swtorcfg
         ;;
         1) echo swtor configuration files not restored on demand > /dev/null 2>&1
         ;;
    esac
fi

# Restoring Tor-Browser files inside Persistent if they exist 

if [ -z "$(ls -A ~/Persistent/home/amnesia/Persistent/backup/Tor)" ]; then
    echo no data for [TOR-files] > /dev/null 2>&1
else
    zenity --question --width=500 --text "Should the TOR Browser directory inside of ~/Persistent from the backup be restored ?"
    case $? in
         0) cp -r ~/Persistent/home/amnesia/Persistent/backup/Tor/*  ~/Persistent/Tor\ Browser/
         ;;
         1) echo TOR files inside ~/Persistent not restored on demand > /dev/null 2>&1
         ;;
    esac
fi

# Restoring Gnupg if they exist 
> /dev/null 2>&1
if [ -z "$(ls -A ~/Persistent/home/amnesia/Persistent/backup/gnupg)" ]; then
    echo no data for [gnupg]
else
    zenity --question --width=500 --text "Should the gnupg files from the image be restored ? \nIf you really know, what you are doing .. press Yes \nOtherwise press No"
    case $? in
         0) rsync -aqzh ~/Persistent/home/amnesia/Persistent/backup/gnupg  /live/persistence/TailsData_unlocked
         ;;
         1) echo gnupg files not restored on demand > /dev/null 2>&1
         ;;
    esac
fi

# Restoring electrum files if they exist 

if [ -z "$(ls -A ~/Persistent/home/amnesia/Persistent/backup/electrum 2>/dev/null )" ]; then
    echo no data for [electrum] > /dev/null 2>&1
else
    zenity --question --width=500 --text "Should the electrum files be restored ?\nIf you really know, what you are doing .. press Yes \nOtherwise press No"
    case $? in
         0) rsync -aqzh ~/Persistent/home/amnesia/Persistent/backup/dotfiles /live/persistence/TailsData_unlocked
         ;;
         1) echo electrum files not restored on demand > /dev/null 2>&1
         ;;
    esac
fi

# Restoring pidgin files if they exist 

if [ -z "$(ls -A ~/Persistent/home/amnesia/Persistent/backup/pidgin 2>/dev/null)" ]; then
    echo no data for [pidgin] > /dev/null 2>&1
else
    zenity --question --width=500 --text "Should the pidgin files be restored ? \nIf you really know, what you are doing .. press Yes \nOtherwise press No"
    case $? in
         0) rsync -aqzh ~/Persistent/home/amnesia/Persistent/backup/pidgin /live/persistence/TailsData_unlocked
         ;;
         1) echo pidgin files not restored on demand > /dev/null 2>&1
         ;;
    esac
fi


# Restoring thunderbird files if they exist

if [ -z "$(ls -A ~/Persistent/home/amnesia/Persistent/backup/thunderbird 2>/dev/null)" ]; then
    echo no data for [thunderbird] > /dev/null 2>&1
else
    zenity --question --width=500 --text "Should the thunderbird files be restored ?\nIf you really know, what you are doing .. press Yes \nOtherwise press No"
    case $? in
         0) rsync -aqzh ~/Persistent/home/amnesia/Persistent/backup/thunderbird /live/persistence/TailsData_unlocked
         ;;
         1) echo thunderbird files not restored on demand > /dev/null 2>&1
         ;;
    esac
fi


# Restoring cups-configuration if they exist

cat ~/Persistent/password | sudo -S chown -R root:root /home/amnesia/Persistent/home/amnesia/Persistent/backup/cups-configuration > /dev/null 2>&1
if [ -z "$(cat ~/Persistent/password | sudo -S ls -A ~/Persistent/home/amnesia/Persistent/backup/cups-configuration)" ]; then
    echo no data for [cupps] > /dev/null 2>&1
else
    zenity --question --width=500 --text "Should the cups files be restored ?\nIf you really know, what you are doing .. press Yes \nOtherwise press No"
    case $? in
         0) cat ~/Persistent/password | sudo -S rsync -aqzh /home/amnesia/Persistent/home/amnesia/Persistent/backup/cups-configuration /live/persistence/TailsData_unlocked > /dev/null 2>&1
         ;;
         1) echo cups files not restored on demand > /dev/null 2>&1
         ;;
    esac
fi


sleep 10 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Update the paket-list with apt-get update. \nThis needs a  very long time to complete depending of the internet speed ! Please wait !!" > /dev/null 2>&1)

cat ~/Persistent/password | sudo -S apt-get update > /dev/null 2>&1

sleep 6 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="The update is now complete. \nNow we can install the additional software" > /dev/null 2>&1)


# Install chromium
cat ~/Persistent/password | sudo -S apt-get install -y chromium > /dev/null 2>&1
zenity --info --width=600 --text="chromium has been installed. Please confirm that this software has to be Installed on Every Startup.\n\n\nPlease press OK to continue."

cat ~/Persistent/password | sudo -S apt-get install -y chromium-sandbox > /dev/null 2>&1
zenity --info --width=600 --text="chromium-sandbox has been installed. Please confirm that this software has to be Installed on Every Startup.\n\n\nPlease press OK to continue."

cat ~/Persistent/password | sudo -S apt-get install -y html2text > /dev/null 2>&1
zenity --info --width=600 --text="Html2text has been installed. Please confirm that this software has to be Installed on Every Startup.\n\n\nPlease press OK to continue."

# Install sshpass

cat ~/Persistent/password | sudo -S apt-get install -y sshpass > /dev/null 2>&1
zenity --info --width=600 --text="sshpass has been installed. Please confirm that this software has to be Installed on Every Startup.\n\n\nPlease press OK to continue."

# Install yad

cat ~/Persistent/password | sudo -S apt-get install -y yad > /dev/null 2>&1
zenity --info --width=600 --text="yad has been installed. Please confirm that this software has to be Installed on Every Startup.\n\n\nPlease press OK to continue."



# Removing Backup-directory on request

zenity --question --width=500 --text "Should the extracted backup be removed ?"
    case $? in
         0) cat ~/Persistent/password | sudo -S rm -rf /home/amnesia/Persistent/home >/dev/null 2>&1
            cat ~/Persistent/password | sudo -S rm -rf /home/amnesia/Persistent/tails-image*.tar.gz >/dev/null 2>&1
         ;; 
         1) echo backup remains inside /Persistent > /dev/null 2>&1
         ;;
     esac


rm ~/Persistent/password
rm ~/Persistent/password_correct


echo 1 > ~/Persistent/swtor-addon-to-tails/setup
sleep 6 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Restore from backup is now complete.\nPlease restart Tails to have all settings active ! ")

exit 0







































z
