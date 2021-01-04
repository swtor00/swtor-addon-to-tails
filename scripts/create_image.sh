#/bin/bash
#########################################################
# SCRIPT  : create_image.sh                             #
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


cd ~/Persistent/scripts

sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Starting backup of persistent data.Please wait !" > /dev/null 2>&1)

# backup all important files for the user amnesia

if [ -z "$(ls -A /live/persistence/TailsData_unlocked/bookmarks )" ]; then
    echo no data [bookmarks]
else
    rsync -aqzh /live/persistence/TailsData_unlocked/bookmarks /home/amnesia/Persistent/backup > /dev/null 2>&1
fi

if [ -z "$(ls -A /live/persistence/TailsData_unlocked/dotfiles )" ]; then
    echo no data [dotfiles]
else
    rsync -aqzh /live/persistence/TailsData_unlocked/dotfiles /home/amnesia/Persistent/backup > /dev/null 2>&1
fi

if [ -z "$(ls -A /live/persistence/TailsData_unlocked/electrum )" ]; then
    echo no data [electrum]
else
    rsync -aqzh /live/persistence/TailsData_unlocked/electrum /home/amnesia/Persistent/backup > /dev/null 2>&1
fi

if [ -z "$(ls -A /live/persistence/TailsData_unlocked/gnupg )" ]; then
    echo no data [gnupg]
else
    rsync -aqzh /live/persistence/TailsData_unlocked/gnupg /home/amnesia/Persistent/backup > /dev/null 2>&1
fi

if [ -z "$(ls -A /live/persistence/TailsData_unlocked/openssh-client )" ]; then
    echo no data [openssh-client]
else
    rsync -aqzh /live/persistence/TailsData_unlocked/openssh-client /home/amnesia/Persistent/backup > /dev/null 2>&1
fi

if [ -z "$(ls -A /live/persistence/TailsData_unlocked/pidgin )" ]; then
    echo no data [pidgin]
else
    rsync -aqzh /live/persistence/TailsData_unlocked/pidgin /home/amnesia/Persistent/backup > /dev/null 2>&1
fi

if [ -z "$(ls -A /live/persistence/TailsData_unlocked/thunderbird )" ]; then
    echo no data [thunderbird]
else
    rsync -aqzh /live/persistence/TailsData_unlocked/thunderbird /home/amnesia/Persistent/backup > /dev/null 2>&1
fi



if grep -q BACKUP-FIXED-PROFILE:YES ~/Persistent/swtorcfg/swtor.cfg ; then
if [ -z "$(ls -A ~/Persistent/personal-files/3 )" ]; then
    echo no data [fixed-profile personal-data]
else
    rsync -avzh ~/Persistent/personal-files/3 /home/amnesia/Persistent/backup/personal-files > /dev/null 2>&1
fi
fi

if [ -z "$(ls -A ~/Persistent/swtorcfg )" ]; then
    echo no data [swtorcfg]
else
    mkdir -p /home/amnesia/Persistent/backup/swtorcfg
    cp ~/Persistent/swtorcfg/*.cfg /home/amnesia/Persistent/backup/swtorcfg
fi


mkdir -p /home/amnesia/Persistent/backup/Tor
mkdir -p /home/amnesia/Persistent/backup/personal-files

cp -r ~/Persistent/Tor\ Browser/*  /home/amnesia/Persistent/backup/Tor
cp -r ~/Persistent/personal-files/* /home/amnesia/Persistent/backup/personal-files

password=$(zenity --entry --text="Curent tails administration-password ? " --title=Password --hide-text)
echo $password > /home/amnesia/Persistent/scripts/password

# Empty password ?

if [ "$password" == "" ];then
   zenity --error --text "Password was empty !"
   rm /home/amnesia/Persistent/backup  > /dev/null 2>&1
   rm /home/amnesia/Persistent/scripts/password > /dev/null 2>&1
   exit 1
fi

# We make the password-test inside a own script

gnome-terminal --window-with-profile=Unnamed -x bash -c /home/amnesia/Persistent/scripts/testroot.sh

if [ -s /home/amnesia/Persistent/scripts/password_correct ]
then
    zenity --error  --text="Password was not coorect !"  > /dev/null 2>&1
    rm /home/amnesia/Persistent/backup  > /dev/null 2>&1
    rm password
    rm password_correct
    exit 1
else
   echo .
   echo all clear. We proceed with the backup tails.
   echo .
fi

# If someone with a very slow connection to internet would like to backup the apt-folder
# he has to set BACKUP-APT-LIST:YES inside the configuration swtor.cfg

if grep -q BACKUP-APT-LIST:YES ~/Persistent/swtorcfg/swtor.cfg
   then
        cat password | sudo -S rsync -avzh /live/persistence/TailsData_unlocked/apt /home/amnesia/Persistent/backup
        echo apt backup done.
fi

cat password | sudo -S rsync -aqzh /live/persistence/TailsData_unlocked/cups-configuration /home/amnesia/Persistent/backup > /dev/null 2>&1
echo cups backup done.
cat password | sudo -S rsync -aqzh /live/persistence/TailsData_unlocked/nm-system-connections /home/amnesia/Persistent/backup > /dev/null 2>&1
echo syste-connections backup done.
cat password | sudo -S rsync -aqzh /live/persistence/TailsData_unlocked/live-additional-software.conf /home/amnesia/Persistent/backup > /dev/null 2>&1
echo live-additional-software.conf backup done.
cat password | sudo -S rsync -aqzh /live/persistence/TailsData_unlocked/persistence.conf /home/amnesia/Persistent/backup > /dev/null 2>&1
echo persistence.conf backup done.
cat password | sudo -S rsync -aqzh /live/persistence/TailsData_unlocked/greeter-settings /home/amnesia/Persistent/backup > /dev/null 2>&1
echo greeter-settings backup done.


# We create the image with the user root and after the backup we chance the owner
# to amnesia, so we can copy it anywhere we would like to have it

cat password | sudo -S tar czf "/home/amnesia/Persistent/tails-image-$(date '+%Y-%m-%d').tar.gz" ~/Persistent/backup > /dev/null 2>&1
cat password | sudo -S chmod 777 /home/amnesia/Persistent/tails-image*.tar.gz
cat password | sudo -S chown amnesia:amnesia /home/amnesia/Persistent/tails-image*.tar.gz

# We delete the backup directory

cat password | sudo -S rm -rf ~/Persistent/backup

if [ -f /home/amnesia/Persistent/scripts/password ]
then
    cd /home/amnesia/Persistent/scripts
    rm password
    rm password_correct
fi

mkdir ~/Persistent/backup-$(date '+%Y-%m-%d')
remote_name=$(echo backup-$(date '+%Y-%m-%d'))

mv ~/Persistent/tails-image*.tar.gz ~/Persistent/backup-$(date '+%Y-%m-%d')
cp ~/Persistent/scripts/restore_image.sh ~/Persistent/backup-$(date '+%Y-%m-%d')

backupdir=$(echo ~/Persistent/backup-$(date '+%Y-%m-%d'))
sleep 8 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Backup created inside of the directory\n$(echo $backupdir)" > /dev/null 2>&1)


# Now we have to decide, if we would like to copy this backup to a foreign ssh-host

zenity --question --width=600 --text "Would you like to transfer this backup-files\nwith ssh to a predefined backup-host inside of swtorssh.cfg ?" > /dev/null 2>&1
case $? in
         0) echo we have to transfer the backup to ssh-host

         # search for a backup ssh-server inside configuration file

         line=$(grep backup ~/Persistent/swtorcfg/swtorssh.cfg)

         if [ -z "$line" ] ; then
            zenity --error --width=600 --text "No predefined backup host found inside of ~/Persistent/swtorcfg/swtorssh.cfg !\nYou have to copy the backup files by yourself anywhere else." > /dev/null 2>&1
            exit 1
         fi

         # Ok.We found a backup host .... let's copy the files.

         port="ssh -p"
         port+=$(echo $line | awk '{print $6}' )
         ssh_host=$(echo $line | awk '{print $9}' )
         ssh_host+=":~/"

         sleep 15 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="The copy of the backup-files to the backup host is in progress. Please wait !" > /dev/null 2>&1)

         cd ~/Persistent
         rsync -avHPe "$port" /home/amnesia/Persistent/$remote_name -e ssh $ssh_host

         if [ $? -eq 0 ] ; then
            echo all done ...
            zenity --info --width=600 --text "Congratulations !\nYour backup files have ben succesfull transfered with ssh to a other location." > /dev/null 2>&1
            zenity --question --width=600 --text "Would you like to delete the local created backup-files now ? \n\nIf you answer Yes please be sure to have following ssh information anywhere written.\n\n-username and the correct password\n-port\n-servername or ip\n\nIn the case of a desaster-recovery for tails you neeed this information to copy back the files over ssh!\n\n"
            case $? in
                     0) rm -rf /home/amnesia/Persistent/$remote_name > /dev/null 2>&1

                     zenity --info --width=600 --text "The backup folder $(echo $remote_name) has ben deleted.\nTo copy back this files from the remote server,you should execute the following command inside of a terminal\n\n
scp $(echo $ssh_host$remote_name/* /home/amnesia/Persistent )\n\nYou can copy this information to the clippboard  or write it down"

                    ;;
                    1) echo backup files remain inside of directoty  ~/Persistent
                      zenity --info --width=600 --text "The backup folder $(echo $remote_name) remains inside ~/Persistent.\nTo copy back this files from the remote server,you should execute the following command inside of a terminal\$
scp $(echo $ssh_host$remote_name/* /home/amnesia/Persistent )\n\nYou can copy this information to the clippboard  or write it down"
                    ;;
            esac

         else
            sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Error with rsync.YOUR COPY TO THE BACKUPHOST WAS NOT MADE !!" > /dev/null 2>&1)
         fi

         ;;
         1) echo backup will not be transfered wtih ssh
         ;;
esac



exit 0


