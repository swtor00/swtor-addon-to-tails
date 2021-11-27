#/bin/bash
#########################################################
# SCRIPT  : create_image.sh                             #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.24 or higher                        #
#                                                       #
# VERSION : 0.60                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 19-11-2021                                  #
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

cd ~/Persistent/swtor-addon-to-tails/scripts

sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
--text="\n\n           Starting backup of the persistent data.Please wait !          \n\n" > /dev/null 2>&1)

show_wait_dialog && sleep 1


# backup all important files for the user amnesia

if [ -z "$(ls -A /live/persistence/TailsData_unlocked/bookmarks )" ]; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "no data from persistent [bookmarks]"
   fi
else
    rsync -aqzh /live/persistence/TailsData_unlocked/bookmarks /home/amnesia/Persistent/backup
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "backup made from bookmarks"
    fi
fi


if [ -z "$(ls -A /live/persistence/TailsData_unlocked/dotfiles )" ]; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "no data from persistent [dotfiles]"
   fi
else
    rsync -aqzh /live/persistence/TailsData_unlocked/dotfiles /home/amnesia/Persistent/backup
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "backup made from dotfiles"
    fi
fi

if [ -z "$(ls -A /live/persistence/TailsData_unlocked/electrum )" ]; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "no data from persistent[electrum]"
   fi
else
    rsync -aqzh /live/persistence/TailsData_unlocked/electrum /home/amnesia/Persistent/backup
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "backup made from electrum"
    fi
fi

if [ -z "$(ls -A /live/persistence/TailsData_unlocked/gnupg )" ]; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "no data from persistent[gnupg]"
   fi
else
    rsync -aqzh /live/persistence/TailsData_unlocked/gnupg /home/amnesia/Persistent/backup
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "backup made from gnupg"
    fi
fi

if [ -z "$(ls -A /live/persistence/TailsData_unlocked/openssh-client )" ]; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "no data from persistent [openssh-client]"
   fi
else
    rsync -aqzh /live/persistence/TailsData_unlocked/openssh-client /home/amnesia/Persistent/backup
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "backup made from openssh-client"
    fi
fi

if [ -z "$(ls -A /live/persistence/TailsData_unlocked/pidgin )" ]; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "no data from persistent [pidgin]"
   fi
else
    rsync -aqzh /live/persistence/TailsData_unlocked/pidgin /home/amnesia/Persistent/backup
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "backup made from pidgin"
    fi
fi

if [ -z "$(ls -A /live/persistence/TailsData_unlocked/thunderbird )" ]; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "no data from persistent [thunderbird]"
   fi
else
    rsync -aqzh /live/persistence/TailsData_unlocked/thunderbird /home/amnesia/Persistent/backup > /dev/null 2>&1
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "backup made from thunderbird"
    fi
fi

if [ "$BACKUP_FIXED_PROFILE" == "1" ] ; then
   if [ -z "$(ls -A ~/Persistent/personal-files/3 )" ]; then
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo "no data to backup for ~/Persistent/personal-files/3"
      fi
   else
      rsync -avzh ~/Persistent/personal-files/3 /home/amnesia/Persistent/backup/fixed-profile
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo "backup made from fixed-profile ~/Persistent/personal-files/3"
      fi
   fi
else
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "no data backup configured for fixed profile"
      echo "current configuration was set to BACKUP-FIXED-PROFILE:NO" 
   fi
fi


if [ -z "$(ls -A ~/Persistent/swtorcfg )" ]; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "no data to backup for directory [swtorcfg]"
   fi
else
    mkdir -p /home/amnesia/Persistent/backup/swtorcfg
    cp ~/Persistent/swtorcfg/*.cfg /home/amnesia/Persistent/backup/swtorcfg
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "backup made from configuration files addon [swtorcfg]"
    fi
fi

mkdir -p "/home/amnesia/Persistent/backup/Tor Browser"
mkdir -p /home/amnesia/Persistent/backup/personal-files

cp -r ~/Persistent/Tor\ Browser/*  "/home/amnesia/Persistent/backup/Tor Browser"
cp -r ~/Persistent/personal-files/* /home/amnesia/Persistent/backup/personal-files

# the fixed profile was controlled by a configuration setting
# The default setting is no ...

if [ "$BACKUP_FIXED_PROFILE" == "0" ] ; then
   rm -rf /home/amnesia/Persistent/backup/personal-files/3 > /dev/null 2>&1
fi


sleep 2
end_wait_dialog

# Ask for the administration password and store it in the tmp directory

test_admin_password
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "password was correct and stored ! "
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "password was 3 times wrong"
       echo >&2 "create_image.sh exiting with error-code 1"
    fi
    exit 1
fi


show_wait_dialog
sleep 1

cd ~/Persistent/swtor-addon-to-tails/tmp

# The following backup is only made if the configuration file swtor.cfg contains BACKUP-APT-LIST:YES
# If your bandwith is very low and maybe limited, it may make sense to backup this files.
# Please be warned,that the backup-size will grow by 300 MB or even more if you activate this option.
# The standard  configuration for swtor.cfg is BACKUP-APT-LIST:NO

if [ "$BACKUP_APT_LIST" == "1" ] ; then
    cat password | sudo -S rsync -avzh /live/persistence/TailsData_unlocked/apt /home/amnesia/Persistent/backup > /dev/null 2>&1
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "backup made from apt-lists: BACKUP-APT-LIST:YES"
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "no data to backup from apt-lists BACKUP-APT-LIST:NO"
    fi
fi

# CUPS

cat password | sudo -S rsync -aqzh /live/persistence/TailsData_unlocked/cups-configuration /home/amnesia/Persistent/backup > /dev/null 2>&1

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo >&2 "backup made from cups-configuration"
fi


# Network connections

cat password | sudo -S rsync -aqzh /live/persistence/TailsData_unlocked/nm-system-connections /home/amnesia/Persistent/backup > /dev/null 2>&1

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo >&2 "backup made from nm-system-connections"
fi

# Additional Software configuration

cat password | sudo -S rsync -aqzh /live/persistence/TailsData_unlocked/live-additional-software.conf /home/amnesia/Persistent/backup > /dev/null 2>&1

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo >&2 "backup made from additional software configuration"
fi

# Configuration of Persysten Volume

cat password | sudo -S rsync -aqzh /live/persistence/TailsData_unlocked/persistence.conf /home/amnesia/Persistent/backup > /dev/null 2>&1

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo >&2 "backup made from configuration of Persistent Volume"
fi

# Configuration of greeter-settings

cat password | sudo -S rsync -aqzh /live/persistence/TailsData_unlocked/greeter-settings /home/amnesia/Persistent/backup > /dev/null 2>&1

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo >&2 "backup made from greeter-settings"
fi



end_wait_dialog && sleep 2

# The backup is done here ....

sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
--text="\n\n           Backup was created inside of the Persistent Volume !          \n\n" > /dev/null 2>&1)


if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo >&2 "backup completed"
fi

# We create the non encrypted image (tar.gz) with the user root and after the creation of the backup we change the owner
# from root to amnesia, so we can copy it anywhere we would like to have it


time_stamp=$(date '+%Y-%m-%d-%H-%M')
filename="$(tails-version | head -n1 | awk {'print $1'})-$time_stamp)"
filename_tar="$(tails-version | head -n1 | awk {'print $1'})-$time_stamp.tar.gz"
final_backup_directory="/home/amnesia/Persistent/$(echo $filename)"
backup_stamp="$(tails-version | head -n1 | awk {'print $1'})-$time_stamp)"

cat password | sudo -S tar czf "/home/amnesia/Persistent/$filename_tar" ~/Persistent/backup > /dev/null 2>&1
cat password | sudo -S chmod 777 "/home/amnesia/Persistent/$filename_tar" > /dev/null 2>&1
cat password | sudo -S chown amnesia:amnesia "/home/amnesia/Persistent/$filename_tar" > /dev/null 2>&1


# We delete now the temporary backup directory from ~/Persistent

cat password | sudo -S rm -rf ~/Persistent/backup > /dev/null 2>&1

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo >&2 "temporary backup directory removed"
fi

mkdir -p $final_backup_directory
mv ~/Persistent/$filename_tar $final_backup_directory

backupdir=~/Persistent/$backup_stamp
backupfile=$(cd ~/Persistent/$backup_stamp && ls *)

# create md5 check for the tar

cd $final_backup_directory
md5sum $filename_tar |  awk  {'print $1'}  > md5check

sleep 15 | tee >(zenity --progress --pulsate --no-cancel --auto-close \
--text="\n\n     The backup was created inside of the directory $(echo $final_backup_directory)      \n\n      Please be informed that this backup is only a simple tar.gz file and is not protected by a password !  \n\n" > /dev/null 2>&1)

sleep 1

zenity --question --width 600 --text "\n\n         Should the created backup to be encrypted with gpg ?    \n\n\n         If you say 'Yes' here and don't get the right password to decrypt it, nobody\n         can help you to get your data back from your encrypted backup ! \n\n"
case $? in
    0)
       gpg --symmetric --cipher-algo aes256  -o crypted_tails_image.tar.gz.gpg $filename_tar
       rm -f $filename_tar > /dev/null
       WARNING_SSH="0"
    ;;
    1)
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo "no encryption chosen from the user for the created backup"
      fi
      WARNING_SSH="1"
    ;;
esac

# By now , we have we have the following things ...
# A single backupfolder that contains a simple tar.gz file or a encrypted tar.gz file

cp ~/Persistent/scripts/restore.sh $final_backup_directory

cd ~/Persistent

final_backup_file="persistent-$(date '+%Y-%m-%d-%H-%M').tar.gz"

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo final_directory : $final_backup_directory
   echo final name      : $final_backup_file
fi

tar czf $final_backup_file $final_backup_directory > /dev/null 2>&1
md5sum $final_backup_file | awk {'print $1'} > $final_backup_file.md5

rm -rf $final_backup_directory > /dev/null 2>&1


# If there is no backup host defined inside swtorssh.cfg we are finished here ...

sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close  --title="Information" \
--text="\n\n      Checking for a backup host SSH inside your configuration swtorssh.cfg     \n\n" > /dev/null 2>&1)

if grep -q "backup" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtorssh.cfg ; then
   BACKUP_HOST="1"
else
   BACKUP_HOST="0"
fi


if [ $BACKUP_HOST == "0" ] ; then
   zenity --info --width=600 --title="" \
   --text="\n\n     Backup was created and stored in the file '$final_backup_file'      \n     Please copy this backup files away from here to a very safe place. \n\n" /
   > /dev/  null 2>&1
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "backup is now finished and stored : $final_backup_file"
   fi
fi


sleep 3 | tee >(zenity --progress --pulsate --no-cancel --auto-close  --title="Information" \
--text="\n\n      Found a valid backup server inside your configuration swtorssh.cfg     \n\n" > /dev/null 2>&1)


if [ $BACKUP_HOST == "1" ] ; then
   if [ $WARNING_SSH == "1" ] ; then
       zenity --error --width=600 --text="\n\n    This simple unencrpyted backup can not be transfered to a remote host over SSH.    \n\n" > /dev/null 2>&1
       exit 1
   fi
fi

# we can go away here ...

line=$(grep backup ~/Persistent/swtorcfg/swtorssh.cfg)

# Ok.We found a backup host .... the backup is encrypted ... let's copy the files.

port="ssh -p "
port+=$(echo $line | awk '{print $6}' )
single_port=$(echo $line | awk '{print $6}' )
ssh_hs=$(echo $line | awk '{print $9}' )
ssh_host=$(echo $line | awk '{print $9}' )
ssh_host+=":~/"


sleep 15 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="\n\n    The transfer of the backup to the remote host is in progress. Please wait !     \n\n" > /dev/null 2>&1)

if [ $TERMINAL_VERBOSE == "1" ] ; then
    echo "transfer backup $final_backup_file file with rsync over ssh is in progress is in progess ..."
fi


show_wait_dialog && sleep 2

cd ~/Persistent

# copy md5 checksum

rsync -avHPe '"$port"' /home/amnesia/Persistent/$final_backup_file.md5 -e ssh $ssh_host > /dev/null 2>&1

sleep 1

# copy backup-file

rsync -avHPe '$port' /home/amnesia/Persistent/$final_backup_file -e ssh $ssh_host > /dev/null 2>&1

if [ $? -eq 0 ] ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo backup-transfered
   fi

   end_wait_dialog && sleep 2

   # After the transfer to the remote host , we restrict the access a bit to this file
   # by running chmod 0600 on the remote host over SSH.
   # This little trick with "bash -s" amd SSH allows us to generate the sript localy and
   # be executed after the connection over SSH was made.
   # This single phrase from Dennis M. Ritchie may say it all.
   #  „UNIX is very simple, it just needs a genius to understand its simplicity.“

   echo "#/bin/bash" > tmp.sh
   echo  "chmod 0600 ~/$final_backup_file.md5 && chmod 0600 ~/$final_backup_file && exit" >> tmp.sh
   chmod +x tmp.sh > /dev/null 2>&1
   ssh -42C -p $single_port $ssh_hs 'bash -s' < tmp.sh > /dev/null 2>&1
   rm tmp.sh > /dev/null 2>&1

   sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close  --title="Information" \
   --text="\n\n      Backup was transfered successfull to the remote system with rsync     \n\n" > /dev/null 2>&1)

else

    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "error on copy to the remote host"
    fi
    end_wait_dialog && sleep 2
    zenity --error --width=600 --text="\n\n     The transfer of the backup to the remote host was not possible !      \n\n" > /dev/null 2>&1
    exit 1
fi


exit 0
