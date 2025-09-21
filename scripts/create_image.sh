#/bin/bash
#########################################################
# SCRIPT  : create_image.sh                             #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 7.0 or higher                         #
#                                                       #
# VERSION : 0.85                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 21-09-2025                                  #
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

cd ~/Persistent

if [ -d backup ] ; then
   rm -rf ~/Persistent/backup > /dev/null 2>&1
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "backup folder deleted"
   fi
fi

# Checking for repair-disk folder

if [ ! -d ~/Persistent/personal-files/tails-repair-disk ] ; then
   mkdir -p ~/Persistent/personal-files/tails-repair-disk
fi

# searching for a backup host

sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close  --title="Information" \
--text="\n\n      Checking for a backup host inside your configuration swtorssh.cfg     \n\n" > /dev/null 2>&1)

if grep -q "backup" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtorssh.cfg ; then

   # We found a backup host definition, but we have to check this entry ... otherwise this
   # entry can not be used to automatic transfer the encrypted backup to a remote host
   # If the entry is not valid ... the option to transfer will not be shown in the transfer-menu.

   BACKUP_HOST="1"
   line=$(grep backup ~/Persistent/swtorcfg/swtorssh.cfg)
   echo $line >  ~/Persistent/swtor-addon-to-tails/tmp/check_parameters_backup

   if grep -q "fullssh" ~/Persistent/swtor-addon-to-tails/tmp/check_parameters_backup ; then
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo found fullssh.sh
      fi
   else
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo ... no fullssh.sh
      fi
      zenity --info --width=600 --text="\n\n    This backup host definition is not valid without fullssh.sh !    \n\n" > /dev/null 2>&1

      rm ~/Persistent/swtor-addon-to-tails/tmp/check_parameters_backup > /dev/null 2>&1
      BACKUP_HOST="0"
   fi

   if grep -q "ssh-id" ~/Persistent/swtor-addon-to-tails/tmp/check_parameters_backup ; then
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo found ssh-id
      fi
   else
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo ... no ssh-id
      fi
      zenity --info --width=600 --text="\n\n    This backup host definition is not valid without ssh-id !    \n\n" > /dev/null 2>&1
      rm ~/Persistent/swtor-addon-to-tails/tmp/check_parameters_backup > /dev/null 2>&1
      BACKUP_HOST="0"
   fi

   if [ $BACKUP_HOST == "1" ] ; then
      sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close  --title="Information" \
      --text="\n\n      Found a valid backup server inside your configuration swtorssh.cfg      \n\n" > /dev/null 2>&1)
      rm ~/Persistent/swtor-addon-to-tails/tmp/check_parameters_backup > /dev/null 2>&1
      BACKUP_HOST="1"
   else
      BACKUP_HOST="0"
   fi
fi


# Ask for the administration password and store it in the tmp directory

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
    cp ~/Persistent/swtorcfg/* /home/amnesia/Persistent/backup/swtorcfg > /dev/null 2>&1
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "backup made from configuration files addon [swtorcfg]"
    fi
fi

mkdir -p "/home/amnesia/Persistent/backup/Tor Browser"
mkdir -p /home/amnesia/Persistent/backup/personal-files

cp -r ~/Persistent/Tor\ Browser/*  "/home/amnesia/Persistent/backup/Tor Browser" > /dev/null 2>&1
cp -r ~/Persistent/personal-files/* /home/amnesia/Persistent/backup/personal-files > /dev/null 2>&1

# the fixed profile was controlled by a configuration setting
# The default setting is no ...

if [ "$BACKUP_FIXED_PROFILE" == "0" ] ; then
   rm -rf /home/amnesia/Persistent/backup/personal-files/3 > /dev/null 2>&1
fi

# We don't copy the repair-disk folder into the backup folder

rm -rf /home/amnesia/Persistent/backup/personal-files/tails-repair-disk > /dev/null 2>&1


cat /etc/os-release | grep VERSION |sed "s/[^0-9.]*//g" > /home/amnesia/Persistent/backup/tails-backup-version

# If you are a like me a developer  .... you need this file also for git push

mkdir /home/amnesia/Persistent/backup/git
cp ~/Persistent/swtor-addon-to-tails/.git/config /home/amnesia/Persistent/backup/git
cd ~/Persistent/swtor-addon-to-tails/tmp

sleep 1

# The following backup is only made if the configuration file swtor.cfg contains BACKUP-APT-LIST:YES
# If your bandwith is very low and maybe limited, it may make sense to backup this files.
# Please be warned,that the backup-size will grow by 500 MB or even more if you activate this option.
# The standard configuration for swtor.cfg is BACKUP-APT-LIST:NO

if [ "$BACKUP_APT_LIST" == "1" ] ; then
    cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
    sudo -S rsync -avzh /live/persistence/TailsData_unlocked/apt /home/amnesia/Persistent/backup > /dev/null 2>&1
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "backup made from apt-lists: BACKUP-APT-LIST:YES"
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "no data to backup from apt-lists BACKUP-APT-LIST:NO"
    fi
fi

# CUPS Configuration / this option is optional for the add-on

if [ -f ~/Persistent/swtor-addon-to-tails/swtorcfg/p_cups-settings.config ] ; then
   cat ~/Persistent/swtor-addon-to-tails/tmp/password \
   | sudo -S rsync -aqzh /live/persistence/TailsData_unlocked/cups-configuration /home/amnesia/Persistent/backup > /dev/null 2>&1
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "backup made from cups-configuration"
   fi
fi

# Network connections / this option is optional for the add-on

if [ -f ~/Persistent/swtor-addon-to-tails/swtorcfg/p_system-connection.config ] ; then
   cat ~/Persistent/swtor-addon-to-tails/tmp/password \
   | sudo -S rsync -aqzh /live/persistence/TailsData_unlocked/nm-system-connections /home/amnesia/Persistent/backup > /dev/null 2>&1
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "backup made from nm-system-connections"
   fi
fi

# TOR-Node configuration / this option is optional for the add-on

if [ -f ~/Persistent/swtor-addon-to-tails/swtorcfg/p_tca.config ] ; then
   cat password | sudo -S rsync -aqzh /live/persistence/TailsData_unlocked/tca /home/amnesia/Persistent/backup > /dev/null 2>&1
if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo >&2 "backup made from tor-node configuration"
fi
fi

# Additional Software configuration / this option is mandatory for the add-on

cat ~/Persistent/swtor-addon-to-tails/tmp/password \
| sudo -S rsync -aqzh /live/persistence/TailsData_unlocked/live-additional-software.conf /home/amnesia/Persistent/backup > /dev/null 2>&1

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo >&2 "backup made from additional software configuration"
fi

# Configuration of the Persistent Volume itself

cat ~/Persistent/swtor-addon-to-tails/tmp/password \
| sudo -S rsync -aqzh /live/persistence/TailsData_unlocked/persistence.conf /home/amnesia/Persistent/backup > /dev/null 2>&1

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo >&2 "backup made from configuration of Persistent Volume"
fi

# Configuration of greeter-settings / only optional and not mandatory for the add-on

if [ -f ~/Persistent/swtor-addon-to-tails/swtorcfg/p_greeter.config ] ; then
   cat ~/Persistent/swtor-addon-to-tails/tmp/password \
   | sudo -S rsync -aqzh /live/persistence/TailsData_unlocked/greeter-settings /home/amnesia/Persistent/backup > /dev/null 2>&1
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "backup made from greeter-settings"
   fi
fi

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo >&2 "backup is now completed"
fi

  # We create the non encrypted image (tar.gz) with the user root and after the creation of the backup we change the owner
  # from root to amnesia, so we can copy it anywhere we would like to have it

   time_stamp=$(date '+%Y-%m-%d-%H-%M')
   filename="$(cat /etc/os-release | grep VERSION |sed "s/[^0-9.]*//g")-$time_stamp"
   filename_tar="$(cat /etc/os-release | grep VERSION |sed "s/[^0-9.]*//g")-$time_stamp.tar.gz"
   final_backup_directory="/home/amnesia/Persistent/$(echo $filename)"

   cat ~/Persistent/swtor-addon-to-tails/tmp/password \
   | sudo -S tar czf "/home/amnesia/Persistent/$filename_tar" ~/Persistent/backup > /dev/null 2>&1
   cat ~/Persistent/swtor-addon-to-tails/tmp/password \
   | sudo -S chmod 777 "/home/amnesia/Persistent/$filename_tar" > /dev/null 2>&1
   cat ~/Persistent/swtor-addon-to-tails/tmp/password \
   | sudo -S chown amnesia:amnesia "/home/amnesia/Persistent/$filename_tar" > /dev/null 2>&1

   # We delete now the temporary backup directory from the Persistent Volume

   cat ~/Persistent/swtor-addon-to-tails/tmp/password | sudo -S rm -rf ~/Persistent/backup > /dev/null 2>&1

   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "temporary backup directory removed"
   fi


   mkdir -p $final_backup_directory > /dev/null 2>&1
   mv ~/Persistent/$filename_tar $final_backup_directory > /dev/null 2>&1

   backupdir=~/Persistent/$backup_stamp

   # create md5 check for the tar

   cd $final_backup_directory
   md5sum $filename_tar |  awk  {'print $1'}  > md5check

   cd ~/Persistent

   final_backup_file="persistent-$(date '+%Y-%m-%d-%H-%M').tar.gz"

   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo final_directory : $final_backup_directory
      echo final name      : $final_backup_file
   fi

   tar czf $final_backup_file $final_backup_directory > /dev/null 2>&1
   md5sum $final_backup_file | awk {'print $1'} > $final_backup_file.md5

   rm -rf $final_backup_directory > /dev/null 2>&1

end_wait_dialog
sleep 0.5

sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
--text="\n\n           Backup was created inside of the persistent volume !          \n\n" > /dev/null 2>&1)


cd ~/Persistent
backup_done=0
menu=1

while [ $menu -eq 1 ]; do

selection=$(zenity --width=600 --height=400 --list --hide-header --title "swtor-addon backup-menu" --column="ID"  --column="" \
         "1"  "[01]  Copy unencrypted backup to the default location "\
         "2"  "[02]  Encrypt the backup and copy it to a remote ssh-host" \
         "3"  "[03]  Encrypt the backup and copy it to the default location" \
         "4"  "[04]  Cancel the current backup" \
        --hide-column=1 \
        --print-column=1)

if [ "$selection" == "" ] ; then

   if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo deleting files
   fi

   rm -f $final_backup_file > /dev/null 2>&1
   rm -f $final_backup_file.md5 > /dev/null 2>&1

   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo backup-files deleted
   fi

   menu=0
   break
fi

if [ "$selection" == "1" ] ; then

   cd ~/Persistent

   # We don't encrpyt the backup

   show_wait_dialog && sleep 1

   # We delete all files inside tails-repair-disk

   rm -rf ~/Persistent/personal-files/tails-repair-disk/* > /dev/null 2>&1

   # we move the backup file and the md5 checksum to ~/Persistent/personal-files/tails-repair-disk

   mv ~/Persistent/persistent* ~/Persistent/personal-files/tails-repair-disk

   cp ~/Persistent/scripts/restore.sh ~/Persistent/personal-files/tails-repair-disk
   cd ~/Persistent/personal-files/tails-repair-disk
   cp ~/Persistent/scripts/restore_p21.sh ~/Persistent/personal-files/tails-repair-disk/restore_part2.sh

   echo "file1="$final_backup_file.md5 >> restore_part2.sh
   echo "file2="$final_backup_file >> restore_part2.sh

   cat restore_part2.sh >> restore.sh
   cat ~/Persistent/scripts/restore_part3.sh >> restore.sh

   # The restore-script is now complete

   rm restore_part2.sh

   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "backup is now finished and stored : $final_backup_file"
   fi

   sleep 2
   end_wait_dialog

   menu=0
   backup_done=1
fi

if [ $selection == "2" ] ; then
   if [ $BACKUP_HOST == "0" ] ; then
      zenity --info --width=600 --title="" \
      --text="\n\n   This function only works with a valid backup-host ! \n\n  " > /dev/null 2>&1
   else

      # We need a passphrase to encrypt :  gpg does terminate after one minute without any activity from
      # the keyboard, therefore we use a a zenity dialog.

      swtor_ask_passphrase
      if [ $? -eq 0 ] ; then
          tar czf $filename_tar $final_backup_file $final_backup_file.md5

          # The final name is unique ... so we can store multiple backups
          # on the remote Server.

          final_destination_name1="crypted_tails_image-$(date '+%Y-%m-%d-%H-%M').tar.gz.gpg"
          final_destination_name2="crypted_tails_image-$(date '+%Y-%m-%d-%H-%M').tar.gz.gpg.md5"

          if [ $TERMINAL_VERBOSE == "1" ] ; then
             echo --------------------------------------
             echo "copy-name 1:"$final_destination_name1
             echo "copy-name 2:"$final_destination_name2
             echo --------------------------------------
          fi

          gpg --batch --passphrase-file /dev/shm/password2 --symmetric --cipher-algo aes256 -o $final_destination_name1 $filename_tar > /dev/null 2>&1
          if [ $? -eq 0 ] ; then
             rm $final_backup_file > /dev/null 2>&1
             rm $final_backup_file.md5 > /dev/null 2>&1
             rm $filename_tar > /dev/null 2>&1
             md5sum $final_destination_name1 | awk {'print $1'} >  $final_destination_name2

             if [ $TERMINAL_VERBOSE == "1" ] ; then
                echo "passed encryption "$(date '+%Y-%m-%d-%H-%M')
             fi

             rm /dev/shm/password1 > /dev/null 2>&1
             rm /dev/shm/password2 > /dev/null 2>&1
             sleep 7 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
             --text="\n\n      Backup is now encrpyted with gpg ! You have to store this password anywhere where it is save.     \n\n" > /dev/null 2>&1)

          else
             zenity --error --width=600 --text="\n\n     Backup canceled by error with gpg !      \n\n" > /dev/null 2>&1
             rm -rf $final_backup_directory > /dev/null 2>&1
             rm -rf $filename_tar > /dev/null 2>&1 
             rm /dev/shm/password1 > /dev/null 2>&1
             rm /dev/shm/password2 > /dev/null 2>&1
             exit 1
          fi
       else
          zenity --error --width=600 --text="\n\n     Backup canceled by user in the password-screen !      \n\n" > /dev/null 2>&1
          rm -rf $final_backup_directory > /dev/null 2>&1
          rm /dev/shm/password1 > /dev/null 2>&1
          rm /dev/shm/password2 > /dev/null 2>&1
          exit 1
       fi


       if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo "preparing upload ....."
       fi

       port="ssh -p "
       port+=$(echo $line | awk '{print $6}')
       single_port=$(echo $line | awk '{print $6}')
       ssh_hs=$(echo $line | awk '{print $9}' )
       ssh_host=$(echo $line | awk '{print $9}' )
       ssh_host+=":~/"

       sleep 15 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="\n\n    The transfer of the backup to the remote host is in progress. Please wait !     \n\n" > /dev/null 2>&1)

       if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo "transfer backup "$final_backup_file" file with rsync over ssh is in progress is in progess ..."
       fi

       show_wait_dialog && sleep 2

       # copy backup-file

       echo "starting backup" > ~/Persistent/swtorcfg/log/backup.log
       rsync -avHPe '$port' /home/amnesia/Persistent/$final_destination_name2  -e ssh $ssh_host >> ~/Persistent/swtorcfg/log/backup.log 2>&1
       echo "crypted_tails_image.tar.gz.gpg.md5 transfered to remote host" >> ~/Persistent/swtorcfg/log/backup.log
       rsync -avHPe '$port' /home/amnesia/Persistent/$final_destination_name1 -e ssh $ssh_host >> ~/Persistent/swtorcfg/log/backup.log 2>&1

       if [ $? -eq 0 ] ; then
          if [ $TERMINAL_VERBOSE == "1" ] ; then
             echo "backup file crypted_tails_image.tar.gz.gpg including md5 transfered to remote host"
          fi

          end_wait_dialog && sleep 2

          # After the transfer to the remote host , we restrict the access a bit to this file
          # by running chmod 0600 on the remote host over SSH.
          # This little trick with "bash -s" amd SSH allows us to generate the sript localy and
          # be executed after the connection over SSH was made.
          # This single phrase from Dennis M. Ritchie may say it all.
          # „UNIX is very simple, it just needs a genius to understand its simplicity.“

          echo "#/bin/bash" > tmp.sh
          echo  "chmod 0600 ~/"$final_destination_name2" &&  chmod 0600 ~/"$final_destination_name1" && exit" >> tmp.sh

          chmod +x tmp.sh > /dev/null 2>&1
          ssh -42C -p $single_port $ssh_hs 'bash -s' < tmp.sh > /dev/null 2>&1
          rm tmp.sh > /dev/null 2>&1
          sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close  --title="Information" \
          --text="\n\n      Backup was transfered successfull to the remote system with rsync     \n\n" > /dev/null 2>&1)
       else
          if [ $TERMINAL_VERBOSE == "1" ] ; then
             echo "error on copy file crypted_tails_image.tar.gz.gpg to the remote host"
          fi
          end_wait_dialog && sleep 2
          zenity --error --width=600 --text="\n\n     The transfer of the backup to the remote host was not possible !      \n\n" > /dev/null 2>&1
final_destination_name1
          rm ~/Persistent/ > /dev/null 2>&1
          rm ~/Persistent/crypted_tails_image.tar.gz.gpg.md5 > /dev/null 2>&1
          exit 1
       fi

       # Delete all local files

       rm ~/Persistent/$final_destination_name1 > /dev/null 2>&1
       rm ~/Persistent/$final_destination_name2 > /dev/null 2>&1

       # Now we have to make a clean tails-repair-disk for this backup

       if [ ! -d ~/Persistent/personal-files/tails-repair-disk ] ; then
          mkdir ~/Persistent/personal-files/tails-repair-disk
       else
          rm -rf ~/Persistent/personal-files/tails-repair-disk/* > /dev/null 2>&1
       fi

       # We copy the ssh-key files

       cd ~/Persistent/personal-files/tails-repair-disk
       cp ~/.ssh/id_rsa ~/Persistent/personal-files/tails-repair-disk
       cp ~/.ssh/id_rsa.pub ~/Persistent/personal-files/tails-repair-disk
       cp ~/.ssh/known_hosts ~/Persistent/personal-files/tails-repair-disk


       cp ~/Persistent/scripts/restore.sh ~/Persistent/personal-files/tails-repair-disk
       cp ~/Persistent/scripts/restore_p22.sh ~/Persistent/personal-files/tails-repair-disk/restore_part2.sh

       echo "                                 " >> restore_part2.sh
       echo "file1="$final_destination_name2 >> restore_part2.sh
       echo "file2="$final_destination_name1 >> restore_part2.sh
       echo "                                 " >> restore_part2.sh
       echo "                                 " >> restore_part2.sh
       echo "if [ ! -f ~/Persistent/stage1b ] ; then" >> restore_part2.sh
       echo "   if [ $"CLI_OUT" == \"1\" ] ; then" >> restore_part2.sh
       echo "      echo Transfer files from remote host " >> restore_part2.sh
       echo "   fi"  >> restore_part2.sh
       echo "                                 " >> restore_part2.sh
       echo "                                 " >> restore_part2.sh
       echo "  sleep 3600 |tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text=\"\\n       [ Downloading the backup from the remote host. Please wait ! ]           \\n\") > /dev/null 2>&1 &" >> restore_part2.sh
       echo "                                 " >> restore_part2.sh
       echo "                                 " >> restore_part2.sh

       if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo -----------------------------------------------
          echo The following arguments will be written to the restore.sh
          echo to get the remote files
          echo
          echo PORT	:$single_port:
          echo HOST	:$ssh_host:
          echo NAME-MD5	:$final_destination_name2:
          echo NAME     :$final_destination_name1:
          echo ------------------------------------------------
       fi

       echo "  scp -P" $single_port $ssh_host$final_destination_name2" . > /dev/null 2>&1" >> restore_part2.sh
       echo "                                 "  >> restore_part2.sh
       echo "  if [ \$? -eq 0 ] ; then" >> restore_part2.sh
       echo "     if [ $"CLI_OUT" == \"1\" ] ; then" >> restore_part2.sh
       echo "        echo file crypted_tails_image.tar.gz.gpg.md5 downloaded" >> restore_part2.sh
       echo "     fi" >> restore_part2.sh
       echo "  else" >> restore_part2.sh
       echo "     if [ $"CLI_OUT" == \"1\" ] ; then" >> restore_part2.sh
       echo "        echo file crypted_tails_image.tar.gz.gpg.md5 not downloaded" >> restore_part2.sh
       echo "     fi" >> restore_part2.sh 
       echo "     sleep 1" >> restore_part2.sh 
       echo "     killall -s SIGINT zenity > /dev/null 2>&1" >> restore_part2.sh
       echo "     sleep 1" >> restore_part2.sh
       echo "     sleep 5 |tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text=\"\\n         [ Download failed ! ]         \\n\")  > /dev/null 2>&1" >> restore_part2.sh 
       echo "     exit 1" >> restore_part2.sh
       echo "  fi"  >> restore_part2.sh
       echo " " >> restore_part2.sh
       echo " " >> restore_part2.sh
       echo "  scp -P" $single_port $ssh_host$final_destination_name1" . > /dev/null 2>&1" >> restore_part2.sh
       echo "  if [ \$? -eq 0 ] ; then" >> restore_part2.sh
       echo "     if [ $"CLI_OUT" == \"1\" ] ; then" >> restore_part2.sh
       echo "        echo file crypted_tails_image.tar.gz.gpg downloaded" >> restore_part2.sh
       echo "     fi" >> restore_part2.sh
       echo "  else" >> restore_part2.sh
       echo "     if [ $"CLI_OUT" == \"1\" ] ; then" >> restore_part2.sh
       echo "        echo file crypted_tails_image.tar.gz.gpg not downloaded" >> restore_part2.sh
       echo "     fi" >> restore_part2.sh
       echo "     sleep 1" >> restore_part2.sh
       echo "     killall -s SIGINT zenity > /dev/null 2>&1" >> restore_part2.sh
       echo "     sleep 1" >> restore_part2.sh
       echo "     sleep 5 |tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text=\"\\n         [ Download failed ! ]         \\n\")  > /dev/null 2>&1" >> restore_part2.sh 
       echo "     exit 1" >> restore_part2.sh
       echo "  fi" >> restore_part2.sh
       echo " " >> restore_part2.sh
       echo " " >> restore_part2.sh
       echo "  if [ $"CLI_OUT" == \"1\" ] ; then" >> restore_part2.sh
       echo "     echo Transfer 2 files from remote host are now finished" >> restore_part2.sh
       echo "  fi" >> restore_part2.sh
       echo "  " >> restore_part2.sh
       echo "  sleep 1" >> restore_part2.sh
       echo "  killall -s SIGINT zenity " >> restore_part2.sh
       echo "  sleep 1" >> restore_part2.sh
       echo " " >> restore_part2.sh
       echo "  sleep 5 |tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text=\"\\n       [ Download is finished ]       \\n\")  > /dev/null 2>&1"   >> restore_part2.sh     
       echo "  echo 1 > ~/Persistent/stage1b" >> restore_part2.sh
       echo "else " >> restore_part2.sh
       echo "  if [ $"CLI_OUT" == \"1\" ] ; then" >> restore_part2.sh
       echo "     echo check for stage1b passed : done" >> restore_part2.sh
       echo "  fi" >> restore_part2.sh
       echo "fi" >> restore_part2.sh
       echo "  " >> restore_part2.sh
       echo "  " >> restore_part2.sh
       echo "  " >> restore_part2.sh


       # The last part of the script is added

       cat ~/Persistent/scripts/restore_part4.sh >> restore_part2.sh

       cat restore_part2.sh >> restore.sh
       rm restore_part2.sh

       menu=0
       backup_done=1
   fi
fi

if [ $selection == "3" ] ; then

      # We need a passphrase to encrypt :  gpg does terminate after one minute without any activity from
      # the keyboard, therefore we use a a zenity dialog.

      swtor_ask_passphrase
      if [ $? -eq 0 ] ; then
          tar czf $filename_tar $final_backup_file $final_backup_file.md5

          final_destination_name1="crypted_tails_image-$(date '+%Y-%m-%d-%H-%M').tar.gz.gpg"
          final_destination_name2="crypted_tails_image-$(date '+%Y-%m-%d-%H-%M').tar.gz.gpg.md5"

          gpg -q --batch --passphrase-file /dev/shm/password2 --symmetric --cipher-algo aes256 -o $final_destination_name1 $filename_tar > /dev/null 2>&1
          if [ $? -eq 0 ] ; then
             rm $final_backup_file > /dev/null 2>&1
             rm $final_backup_file.md5 > /dev/null 2>&1
             rm $filename_tar > /dev/null 2>&1
             md5sum $final_destination_name1 | awk {'print $1'} > $final_destination_name2
             rm /dev/shm/password1 > /dev/null 2>&1
             rm /dev/shm/password2 > /dev/null 2>&1
             sleep 7 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
             --text="\n\n      Backup is now encrpyted with gpg ! You have to store this password anywhere where it is save.     \n\n" > /dev/null 2>&1)

          else
             zenity --error --width=600 --text="\n\n     Backup canceled by error with gpg !      \n\n" > /dev/null 2>&1
             rm -rf $final_backup_directory > /dev/null 2>&1
             rm -rf $filename_tar > /dev/null 2>&1 
             rm /dev/shm/password1 > /dev/null 2>&1
             rm /dev/shm/password2 > /dev/null 2>&1
             exit 1
          fi
       else
          zenity --error --width=600 --text="\n\n     Backup canceled by user in the password-screen !      \n\n" > /dev/null 2>&1
          rm -rf $final_backup_directory > /dev/null 2>&1
          rm /dev/shm/password1 > /dev/null 2>&1
          rm /dev/shm/password2 > /dev/null 2>&1
          exit 1
       fi

       # Now we have to make a clean tails-repair-disk for this backup

       if [ ! -d ~/Persistent/personal-files/tails-repair-disk ] ; then
          mkdir ~/Persistent/personal-files/tails-repair-disk
       else
          rm -rf ~/Persistent/personal-files/tails-repair-disk/* > /dev/null 2>&1
       fi


       # We move  the backup files

       cd ~/Persistent/personal-files/tails-repair-disk
       mv ~/Persistent/$final_destination_name1 . > /dev/null 2>&1
       mv ~/Persistent/$final_destination_name2 . > /dev/null 2>&1

       cp ~/Persistent/scripts/restore.sh ~/Persistent/personal-files/tails-repair-disk
       cp ~/Persistent/scripts/restore_p21.sh ~/Persistent/personal-files/tails-repair-disk/restore_part2.sh

       echo "                                 " >> restore_part2.sh
       echo "file1="$final_destination_name2    >> restore_part2.sh
       echo "file2="$final_destination_name1    >> restore_part2.sh
       echo "                                 " >> restore_part2.sh
       echo "                                 " >> restore_part2.sh

       # The last part of the script is added

       cat ~/Persistent/scripts/restore_part4.sh >> restore_part2.sh

       cat restore_part2.sh >> restore.sh
       rm restore_part2.sh

       menu=0
       backup_done=1
fi


if [ $selection == "4" ] ; then

   if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo deleting files
   fi

   rm -f $final_backup_file > /dev/null 2>&1
   rm -f $final_backup_file.md5 > /dev/null 2>&1

   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo backup-files deleted
   fi
   menu=0
   break
fi

done

if [ $backup_done == "1" ]  ; then
    zenity --info --width=600 --title="" \
    --text="\n\n   Please do not forget to copy the repair-files to a other external storage.\n\n   Without this files in this directory you can not restore the persistent volume !  \n\n" > /dev/null 2>&1 
    
    # Until now , it wasn't possible to hold multiples backups 
    # We do add a date to the folder 
    # So we can hold as many backups as possible
    
    mv ~/Persistent/personal-files/tails-repair-disk  ~/Persistent/personal-files/tails-repair-disk-$(date '+%Y-%m-%d-%H-%M') > /dev/null 2>&1  
    
else
     if [ $TERMINAL_VERBOSE == "1" ] ; then
           echo "backup was canceled"
     fi
fi
exit 0


