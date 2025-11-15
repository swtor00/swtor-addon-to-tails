#/bin/bash
#########################################################
# SCRIPT  : setup.sh                                    #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 7.2 or higher                         #
#                                                       #
#                                                       #
# VERSION : 0.90                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 15-11-2025                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################

CLI_OUT="0"

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

if grep -q "BROWSER-SOCKS5:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
     export BROWSER_SOCKS5="1"
else
     export BROWSER_SOCKS5="0"
fi

if grep -q "BYPASS-SOFTWARE-CHECK:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
     export BYPASS="1"
else
     export BYPASS="0"
fi

if grep -q "CHECK-EMPTY-SSH:NO" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
     export CHECK_SSH="0"
else
     export CHECK_SSH="1"
fi

if grep -q "AUTOCLOSE-BROWSER:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
     export AUTOCLOSE_BROWSER="1"
else
     export AUTOCLOSE_BROWSER="0"
fi


export TIMEOUT_TB=$(grep TIMEOUT-TB ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg | sed 's/[A-Z:-]//g')
export TIMEOUT_SSH=$(grep TIMEOUT-SSH ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg | sed 's/[A-Z:-]//g')
export XCLOCK_SIZE=$(grep XCLOCK-SIZE ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg | sed 's/[A-Z:-]//g')

export  DEBUGW="0"


source ~/Persistent/swtor-addon-to-tails/scripts/swtor-global.sh
global_init
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "global_init() done"
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "failure during initialisation of global-init() !"
       echo >&2 "setup.sh exiting with error-code 1"
    fi
    exit 1
fi

if [ "$DEBUGW" == "1" ] ; then
   pid_to_kill=$(ps axu | grep zenity | grep wait | awk {'print $2'})
   echo wait_dialog 01 with PID $pid_to_kill created
fi

# Creating the Lock

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

    if [ "$DEBUGW" == "1" ] ; then
       echo wait_dialog 01 with PID $pid_to_kill will be killed
    fi

    end_wait_dialog
    zenity --error --width=600 --text="\n\nLockdirectory for setup.sh can not be created ! \n\n" > /dev/null 2>&1
    exit 1
fi


####################################################################################################################
# if this script was started in restore-mode from a backup ..... we do copy back here
####################################################################################################################
if [ $# -eq 1 ] ; then

# If we don't have a password on startup .... we show a error and do exit the script

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo Password test
fi

echo _123UUU__ | sudo -S /bin/bash > test_admin 2>&1

if grep -q "provided" test_admin ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo password asked
   fi
   rm test_admin 2>&1
else
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo no password set
   fi
   rm test_admin > /dev/null 2>&1
   rmdir $lockdir 2>&1 >/dev/null
   zenity --error --width=600 \
     --text="\n\n         This addon needs a administration password set on the greeter-screen.\n         You have to set this option first ! \n\n" \
    > /dev/null 2>&1
   echo "no password set on startup of Tails"
   exit 1
fi

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo test for password is done
fi


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
               if [ $CLI_OUT == "1" ] ; then
                  echo >&2 "password was empty !"
               fi
            fi
         else
            cd /home/amnesia/Persistent/swtor-addon-to-tails/tmp
            /home/amnesia/Persistent/swtor-addon-to-tails/scripts/testroot.sh >/dev/null 2>&1
            if [ -s password_correct ] ; then
               if [ $CLI_OUT == "1" ] ; then
                  echo >&2 "the provided administration password was correct"
               fi
               menu=0
               correct=1
               if [ $CLI_OUT == "1" ] ; then
                  echo password is correct
               fi
             break
         else
             if [ "$menu" == "3" ] ; then
                menu=0
                zenity --error --width=400 --text "\n\nYou have to restart again. The password was 3 times wrong ! \n\n"
                break
             else
                if [ $CLI_OUT == "1" ] ; then
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

    # We need to know what options are active inside of the persistent volume by now 

    cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
    sudo -S cp /live/persistence/TailsData_unlocked/persistence.conf  /home/amnesia/Persistent/swtor-addon-to-tails/swtorcfg > /dev/null 2>&1

    cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
    sudo -S chmod 666 /home/amnesia/Persistent/swtor-addon-to-tails/swtorcfg/persistence.conf > /dev/null 2>&1

    # Test mandatory option : ssh

   if grep -q openssh-client /home/amnesia/Persistent/swtor-addon-to-tails/swtorcfg/persistence.conf ; then
      if [ $CLI_OUT == "1" ] ; then
         echo >&2 "ssh settings are present on this persistent volume"
      fi
   else
      zenity --error --width=600 \
      --text="\n\n         This addon needs the ssh option inside of the persistent volume.\n         You have to set this option first ! \n\n" \
      > /dev/null 2>&1   
      rmdir $lockdir 2>&1 >/dev/null 
      exit 1
   fi

   # Mandatory : additional software part01

   if grep -q /var/cache/apt/archives /home/amnesia/Persistent/swtor-addon-to-tails/swtorcfg/persistence.conf ; then
      if [ $CLI_OUT == "1" ] ; then
        echo >&2 "additional-software is  present on this persistent volume"
      fi
   else
      zenity --error --width=600 \
      --text="\n\n         This addon needs the additional software option inside of the persistent volume.\n         You have to set this option first ! \n\n" \
      > /dev/null 2>&1
      rmdir $lockdir 2>&1 >/dev/null 
      exit 1
   fi

   # Mandatory : additional software part02

   if grep -q /var/lib/apt/lists /home/amnesia/Persistent/swtor-addon-to-tails/swtorcfg/persistence.conf ; then
      if [ $CLI_OUT == "1" ] ; then
         echo >&2 "additional-software is  present on this persistent volume"
      fi
   else
      zenity --error --width=600 \
      --text="\n\n         This addon needs the additional software option inside of the persistent volume.\n         You have to set this option first ! \n\n" \
      > /dev/null 2>&1
      rmdir $lockdir 2>&1 >/dev/null 
      exit 1
   fi 
   
   # Prior to restoring files from the backup , we check the backup-files and 
   # the optional settings from the Persistent Volume. The User can choose what to do ..

   if [ -d ~/Persistent/backup/dotfiles ] ; then
        if grep -q dotfiles  /home/amnesia/Persistent/swtor-addon-to-tails/swtorcfg/persistence.conf ; then
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for Dotfiles and persistent option is set"
           fi    
        else
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files with activated Dotfiles option and this persistent option is not set on this volume"
           fi
           zenity --question --width 600 \
           --text "\n\n         The extracted backup contains files from a volume with a activated Dotfiles option. \n\
                   \n         This option is not activated on this currently used volume !                             \n \
                   \n\nIf you say 'Yes' to the following question, the restore will stop here and you can set the above \
                   \noption and restart Tails.\n \         
                   \nIf you say 'No' the backup will not restore the backup files from the Dotfiles location ! \n\n"
           case $? in
           0)
             rmdir $lockdir 2>&1 >/dev/null 
             exit 1 
           ;; 
           1)
             if [ $CLI_OUT == "1" ] ; then
                echo "backup will not be canceled here ... we go further"
             fi
           ;;
           esac                 
        fi
    fi
    

    if [ -d ~/Persistent/backup/greeter-settings ] ; then
       if grep -q greeter-settings /home/amnesia/Persistent/swtor-addon-to-tails/swtorcfg/persistence.conf ; then
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for "Welcome-Screen" and this persistent option is set"
           fi    
        else
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for the Welcome-Screen and this persistent option is not set on this volume"
           fi
           zenity --question --width 600 \
           --text "\n\n         The extracted backup contains files from a volume with a activated Welcome Screen option. \n\
                   \n         This option is not activated on this currently used volume !                             \n \
                   \n\nIf you say 'Yes' to the following question, the restore will stop here and you can set the above \
                   \noption and restart Tails.\n \         
                   \nIf you say 'No' the backup will not restore the backup files from the Welcome Sceeen location ! \n\n"
           case $? in
           0)
             rmdir $lockdir 2>&1 >/dev/null 
             exit 1 
           ;; 
           1)                
             if [ $CLI_OUT == "1" ] ; then
		echo "backup will not be canceled here ... we go further"
             fi
           ;;
           esac                 
        fi
    fi
    
    if [ -d ~/Persistent/backup/cups-configuration ] ; then
        if grep -q cups-configuration /home/amnesia/Persistent/swtor-addon-to-tails/swtorcfg/persistence.conf ; then
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for cups and persistent option is set"
           fi    
        else
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for cups and persistent option is not set on this volume"
           fi
           zenity --question --width 600 \
           --text "\n\n         The extracted backup contains files from a volume with a activated cups option.\n\
                   \n         This option is not activated on this currently used volume !                             \n \
                   \n\nIf you say 'Yes' to the following question, the restore will stop here and you can set the above \
                   \noption and restart Tails.\n \         
                   \nIf you say 'No' the backup will not restore the backup files from the cups-location ! \n\n"
           case $? in
           0)
             rmdir $lockdir 2>&1 >/dev/null 
             exit 1 
           ;; 
           1)
             if [ $CLI_OUT == "1" ] ; then
                echo "backup will not be canceled here ... we go further"
             fi
           ;;
           esac                 
        fi
    fi


    if [ -d ~/Persistent/backup/tca  ] ; then
        if grep -q tca /home/amnesia/Persistent/swtor-addon-to-tails/swtorcfg/persistence.conf ; then
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for tca and persistent option is set"
           fi    
        else
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for tca and persistent option is not set on this volume"
           fi
           zenity --question --width 600 \
           --text "\n\n         The extracted backup contains files from a volume with a activated tca option.\n\
                   \n         This option is not activated on this currently used volume !                             \n \
                   \n\nIf you say 'Yes' to the following question, the restore will stop here and you can set the above \
                   \noption and restart Tails.\n \         
                   \nIf you say 'No' the backup will not restore the backup files from the tca-location ! \n\n"
           case $? in
           0)
             rmdir $lockdir 2>&1 >/dev/null 
             exit 1 
           ;; 
           1)
             if [ $CLI_OU == "1" ] ; then
                echo "backup will not be canceled here ... we go further"
             fi
           ;;
           esac                 
        fi
    fi
   
    if [ -d ~/Persistent/backup/nm-system-connections ] ; then
        if grep -q system-connection ~/Persistent/swtorcfg/persistence.conf ; then
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for network-connections and persistent option is set"
           fi    
        else
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for network-connections and persistent option is not set on this volume"
           fi
           zenity --question --width 600 \
           --text "\n\n         The extracted backup contains files from a volume with a activated network option.\n\
                   \n         This option is not activated on this currently used volume !                             \n \
                   \n\nIf you say 'Yes' to the following question, the restore will stop here and you can set the above \
                   \noption and restart Tails.\n \         
                   \nIf you say 'No' the backup will not restore the backup files from the network-location ! \n\n"
           case $? in
           0)
             rmdir $lockdir 2>&1 >/dev/null 
             exit 1 
           ;; 
           1)
             if [ $CLI_OU == "1" ] ; then
                echo "backup will not be canceled here ... we go further"
             fi                
           ;;
           esac                 
        fi    
    fi
        
    if [ -d ~/Persistent/backup/electrum  ] ; then
        if mount | grep -q /home/amnesia/.electrum  ; then
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for electrum and persistent option is set"
           fi    
        else
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for electrum and persistent option is not set on this volume"
           fi

           zenity --question --width 600 \
           --text "\n\n         The extracted backup contains files from a volume with a activated electrum-wallet.\n\
                   \n         This option is not activated on this currently used volume !                             \n \
                   \n\nIf you say 'Yes' to the following question, the restore will stop here and you can set the above \
                   \noption and restart Tails.\n \         
                   \nIf you say 'No' the backup will not restore the backup files from the electrum-wallet ! \n\n"
           case $? in
           0)
             rmdir $lockdir 2>&1 >/dev/null 
             exit 1 
           ;; 
           1)
             if [ $CLI_OUT == "1" ] ; then
                echo "backup will not be canceled here ... we go further" 
             fi
           ;;
           esac                 
        fi
    fi
    
    if [ -d ~/Persistent/backup/pidgin ] ; then
        if mount | grep -q /home/amnesia/.purple ; then
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for pidgin and persistent option is set"
           fi    
        else
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for pidgin and persistent option is not set on this voulume"
           fi
           
           zenity --question --width 600 \      
           --text "\n\n         The extracted backup contains files from a volume with a activated pidgin.\n\
                   \n         This option is not activated on this currently used volume !                             \n \
                   \n\nIf you say 'Yes' to the following question, the restore will stop here and you can set the above \
                   \noption and restart Tails.\n \         
                   \nIf you say 'No' the backup will not restore the backup files from the pidgin ! \n\n"
           case $? in
           0)
             rmdir $lockdir 2>&1 >/dev/null 
             exit 1 
           ;; 
           1)
             if [ $CLI_OUT == "1" ] ; then
                echo "backup will not be canceled here ... we go further" 
             fi
           ;;
           esac                 
        fi
    fi

    if [ -d ~/Persistent/backup/thunderbird ] ; then
        if mount | grep -q home/amnesia/.thunderbird ; then
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for thunderbird and persistent option is set"
           fi    
        else
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for thunderbid and persistent option is not set on this volume"
           fi
           
           zenity --question --width 600 \      
           --text "\n\n         The extracted backup contains files from a volume with a activated thunderbird.\n\
                   \n         This option is not activated on this currently used volume !                             \n \
                   \n\nIf you say 'Yes' to the following question, the restore will stop here and you can set the above \
                   \noption and restart Tails.\n \         
                   \nIf you say 'No' the backup will not restore the backup files from the thunderbird ! \n\n"
           case $? in
           0)
             rmdir $lockdir 2>&1 >/dev/null    
             exit 1 
           ;; 
           1)
             if [ $CLI_OUT == "1" ] ; then
                echo "backup will not be canceled here ... we go further" 
             fi
           ;;
           esac                 
        fi
    fi

    if [ -d ~/Persistent/backup/gnupg ] ; then
        if mount | grep -q /home/amnesia/.gnupg ; then
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for gnupg and persistent option is set"
           fi    
        else
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for gnupg and persistent option is not set on this volume"
           fi
           zenity --question --width 600 \      
           --text "\n\n         The extracted backup contains files from a volume with a activated gnupg.\n\
                   \n         This option is not activated on this currently used volume !                             \n \
                   \n\nIf you say 'Yes' to the following question, the restore will stop here and you can set the above \
                   \noption and restart Tails.\n \         
                   \nIf you say 'No' the backup will not restore the backup files from the gnupg ! \n\n"
           case $? in
           0)
             rmdir $lockdir 2>&1 >/dev/null 
             exit 1 
           ;; 
           1)
             if [ $CLI_OUT == "1" ] ; then
                echo "backup will not be canceled here ... we go further" 
             fi
           ;;
           esac                 
        fi
    fi


    if [ -d ~/Persistent/backup/bookmarks ] ; then
        if mount | grep -q /home/amnesia/.mozilla/firefox/bookmarks ; then
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for bookmarks and persistent option is set"
           fi    
        else
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for bookmarks and persistent option is not set on this volume"
           fi
           
           zenity --question --width 600 \      
           --text "\n\n         The extracted backup contains files from a volume with a activated bookmarks.\n\
                   \n         This option is not activated on this currently used volume !                             \n \
                   \n\nIf you say 'Yes' to the following question, the restore will stop here and you can set the above \
                   \noption and restart Tails.\n \         
                   \nIf you say 'No' the backup will not restore the backup files from the bookmarks ! \n\n"
           case $? in
           0)
             rmdir $lockdir 2>&1 >/dev/null 
             exit 1 
           ;; 
           1)
             if [ $CLI_OUT == "1" ] ; then
                echo "backup will not be canceled here ... we go further" 
             fi
           ;;
           esac                 
        fi
    fi

    # From here to the end of the script ... we show the wait dialog 

    show_wait_dialog & sleep 1

    browser='/home/amnesia/Persistent/backup/Tor*Browser/'
    pfiles="/home/amnesia/Persistent/backup/personal-files/"

    cd $browser && cbrowser=$(ls -A)

    cd $pfiles && cpfiles=$(ls -A)

    if [ $CLI_OUT == "1" ] ; then  
       echo $cbrowser
       echo $cpfiles
    fi

    cd ~/Persistent/scripts

    if [ "$cbrowser" == "" ] ; then
       if [ $CLI_OUT == "1" ] ; then        
          echo "directory "$browser" was empty so nothing restored"
       fi
    else
       cp -r ~/Persistent/backup/Tor\ Browser/* ~/Persistent/Tor\ Browser/
       if [ $CLI_OUT == "1" ] ; then 
          echo "Backup files ~/Persistent/TOR Browser restored"
       fi
    fi

    if [ "$cpfiles" == "" ] ; then
       if [ $CLI_OUT == "1" ] ; then 
          echo "directory "$pfiles" was empty so nothing restored"
          mkdir -p ~/Persistent/personal-files/tails-repair-disk > /dev/null 2>&1
       fi
    else
       cp -r ~/Persistent/backup/personal-files/* ~/Persistent/personal-files/
       mkdir -p ~/Persistent/personal-files/tails-repair-disk > /dev/null 2>&1
       if [ $CLI_OUT == "1" ] ; then
          echo "Backup files ~/Persistent/personal-files restored"
       fi
    fi
 
    # The above part was easy ... the restored files are independent from the version
    # of the running Tails-OS
    # Even most of the configuration files are not critical, as long we are using the same
    # Version of Tails to restore.

    backup_version=$(cat ~/Persistent/backup/tails-backup-version)
    current_version=$(cat /etc/os-release | grep VERSION |sed "s/[^0-9.]*//g")

    if [ $CLI_OUT == "1" ] ; then
       echo the backup-was made with version :$backup_version
       echo the current tails is :$current_version
    fi
    
    if [ $backup_version == $current_version ] ; then

       restore_bookmarks
       restore_gnupg
       restore_thunderbird
       restore_pidgin
       restore_electrum
       restore_git
       restore_ssh
       restore_network_connections
       restore_tca
       restore_cups
       restore_greeter_screen
       restore_software
       restore_dotfiles
       restore_finish

    else

        # By now, we have 2 possible scenarios ...

        # 1. The backup was made with a newer Tails and the current Tails is older ... 
        # Stop restoring and recommend to make a upgrade to a higher version

        # 2. The backup was made with a older system and the current Tails is newer 
        # Asking on every restore-point ....  


        if [ $backup_version -gt $current_version ] ; then  
        
           if [ $CLI_OUT == "1" ] ; then   
              echo The backup version is newer than the current one
           fi

           end_wait_dialog && sleep 1.5
  
           echo    
           echo "We have a conflict here : " 
           echo "Backup was made with Tails : "$(cat ~/Persistent/backup/tails-backup-version)
           echo "Current Tails in use is    : "$(cat /etc/os-release | grep VERSION |sed "s/[^0-9.]*//g")
           echo "Restore is not possible !!! " 
           echo "For restoring the backup-data,the Tails must be equal or higher !!!"   

           zenity --error --width=600 \
           --text="\n\n         The backup you made, used a newer Tails version than the current one ! \n\n" > /dev/null 2>&1
           rmdir $lockdir 2>&1 >/dev/null 
           exit 1
        fi
             
        if [ $current_version -gt $backup_version ] ; then 
           if [ $CLI_OUT == "1" ] ; then
              echo The current version is greater than the backup-system 
           fi

           echo
           echo "We have a little conflict here : " 
           echo "Backup was made with Tails : "$(cat ~/Persistent/backup/tails-backup-version)
           echo "Current Tails in use is    : "$(cat /etc/os-release | grep VERSION |sed "s/[^0-9.]*//g")
           echo "Restore is possible but dotfiles and greeter-screen is not restored !!"               

           # Because the backup was made with a older version of Tails ..
           # We have to ask on very restore-point with the exception 
           # of the following entrys ...

           restore_bookmarks
           restore_gnupg
           restore_ssh
           restore_network_connections
           restore_git
           restore_tca
           restore_cups
           restore_software

           end_wait_dialog && sleep 1.5

           # The following options may have problems, in the moment you restore a older version over a new version
           # restore_thunderbird
           # restore_pidgin  
           # restore_electrum

           zenity --question --width=600 \
           --text="\n\n   Should the backup-data from thunderbird be restored ?   \n\n" > /dev/null 2>&1
           case $? in
                 0)
                   restore_thunderbird  
                 ;;
                 1) if [ $CLI_OUT == "1" ] ; then  
                       echo "not restoring thunderbird"
                    fi         
                 ;;
           esac

           zenity --question --width=600 \
           --text="\n\n   Should the backup-data from pidgin be restored ?   \n\n" > /dev/null 2>&1
           case $? in
                 0)
                   restore_pidgin 
                 ;;
                 1) if [ $CLI_OUT == "1" ] ; then  
                       echo "not restoring pidgin"
                    fi         
                 ;;
           esac

           zenity --question --width=600 \
           --text="\n\n   Should the backup-data from electrum be restored ?   \n\n" > /dev/null 2>&1
           case $? in
                 0)
                   restore_electrum
                 ;;
                 1) if [ $CLI_OUT == "1" ] ; then
                       echo "not restoring electrum"
                    fi
                 ;;
           esac

           # The following 2 options are not restored
           # restore_dotfile
           # restore_greeter_screen


           killall -s SIGINT zenity > /dev/null 2>&1

           restore_finish
           exit 0
        fi
    fi

    # We are finished in restore-mode

    rmdir $lockdir 2>&1 >/dev/null 
    exit 0
fi

####################################################################################################################



if [ -f ~/Persistent/swtor-addon-to-tails/setup ] ; then

   if [ "$DEBUGW" == "1" ] ; then
      pid_to_kill=$(ps axu | grep zenity | grep wait | awk {'print $2'})
      echo wait_dialog 01 with PID $pid_to_kill will be killed
   fi

   end_wait_dialog
   zenity --error --width=600 --text="\n\nsetup.sh has failed. \n\nThis programm was allready executed once on this persistent volume ! \nIf you would like to start it again, you have to remove the file\n~/Persisten/swtor-addon-to-tails/setup \n\n" > /dev/null 2>&1
   rmdir $lockdir > /dev/null 2>&1
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "removed acquired lock: $lockdir"
      echo >&2 "setup.sh exiting with error-code 1"
   fi
   exit 1
else
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "swtor-setup.sh was not executed on this volume"
   fi
fi

# If we don't have a password on startup .... we show a error and do exit the script

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo Password test
fi

echo _123UUU__ | sudo -S /bin/bash > test_admin 2>&1

if grep -q "provided" test_admin ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo password asked
   fi
   rm test_admin 2>&1
else
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo no password set
   fi
   rm test_admin > /dev/null 2>&1
   rmdir $lockdir 2>&1 >/dev/null
   zenity --error --width=600 \
     --text="\n\n         This addon needs a administration password set on the greeter-screen.\n         You have to set this option first ! \n\n" \
    > /dev/null 2>&1
   echo "no password set on startup of Tails"
   exit 1
fi

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo test for password is done
fi


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
               if [ $CLI_OUT == "1" ] ; then
                  echo >&2 "password was empty !"
               fi
            fi
         else
            cd /home/amnesia/Persistent/swtor-addon-to-tails/tmp
            /home/amnesia/Persistent/swtor-addon-to-tails/scripts/testroot.sh >/dev/null 2>&1
            if [ -s password_correct ] ; then
               if [ $CLI_OUT == "1" ] ; then
                  echo >&2 "the provided administration password was correct"
               fi
               menu=0
               correct=1
               if [ $CLI_OUT == "1" ] ; then
                  echo password is correct
               fi
             break
         else
             if [ "$menu" == "3" ] ; then
                menu=0
                zenity --error --width=400 --text "\n\nYou have to restart again. The password was 3 times wrong ! \n\n"
                break
             else
                if [ $CLI_OUT == "1" ] ; then
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

# We have a valid password .... we do continue ....

cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
sudo -S cp /live/persistence/TailsData_unlocked/persistence.conf /home/amnesia/Persistent/swtorcfg > /dev/null 2>&1

cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
sudo -S chmod 666 /home/amnesia/Persistent/swtorcfg/persistence.conf > /dev/null 2>&1

# If any of the mandatory options for Persistent have changed from on to off ..
# We have a error and stop further execution of the script

# Mandatory : openssh-client

if grep -q openssh-client ~/Persistent/swtorcfg/persistence.conf ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "ssh settings are present on this persistent volume"
   fi
else
   zenity --error --width=600 \
   --text="\n\n         This addon needs the ssh option inside of the persistent volume.\n         You have to set this option first ! \n\n" \
   > /dev/null 2>&1
   rmdir $lockdir 2>&1 >/dev/null
   exit 1
fi


# Mandatory : additional software part01

if grep -q /var/cache/apt/archives  ~/Persistent/swtorcfg/persistence.conf ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "additional-software is  present on this persistent volume"
   fi
else
   zenity --error --width=600 \
   --text="\n\n         This addon needs the additional software option inside of the persistent volume.\n         You have to set this option first ! \n\n" \
   > /dev/null 2>&1
   rmdir $lockdir 2>&1 >/dev/null
   exit 1
fi

# Mandatory : additional software part02

if grep -q /var/lib/apt/lists ~/Persistent/swtorcfg/persistence.conf ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "additional-software is present on this persistent volume"
   fi
else
   zenity --error --width=600 \
   --text="\n\n         This addon needs the additional software option inside of the persistent volume.\n         You have to set this option first ! \n\n" \
   > /dev/null 2>&1
   rmdir $lockdir 2>&1 >/dev/null
   exit 1
fi

# Do we have network-connections active ?
# This option is not mandatory

if grep -q system-connection ~/Persistent/swtorcfg/persistence.conf ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo >&2 "network settings are present on this persistent volume"
   fi
    echo 1 > ~/Persistent/swtorcfg/p_system-connection.config
 else
    rm  ~/Persistent/swtorcfg/p_system-connection.config > /dev/null 2>&1
fi

# Do we have greeter-settings active ?
# This option is not mandatory ... but very usefull 

if grep -q greeter-settings ~/Persistent/swtorcfg/persistence.conf ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "greeter-settings are present on this persistent volume"
   fi
   echo 1 > ~/Persistent/swtorcfg/p_greeter.config
else
   rm ~/Persistent/swtorcfg/p_greeter.config > /dev/null 2>&1
fi

# Do we have Bookmarks active ?
# This option is not mandatory

if grep -q bookmarks ~/Persistent/swtorcfg/persistence.conf ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "bookmarks are present on this persistent volume"
   fi
   echo 1 > ~/Persistent/swtorcfg/p_bookmarks.config
else
   rm ~/Persistent/swtorcfg/p_bookmarks.config > /dev/null 2>&1
fi

# Do we have cups active ?
# This option is not mandatory

if grep -q cups-configuration ~/Persistent/swtorcfg/persistence.conf ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "cups settings are present on this persistent volume"
   fi
   echo 1 > ~/Persistent/swtorcfg/p_cups-settings.config
else
   rm ~/Persistent/swtorcfg/p_cups-settings.config > /dev/null 2>&1
fi

# Do we have thunderbird active ?
# This option is not mandatory

if grep -q thunderbird ~/Persistent/swtorcfg/persistence.conf ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "thunderbird settings are present on this persistent volume"
   fi
   echo 1 > ~/Persistent/swtorcfg/p_thunderbird.config
else
   rm  ~/Persistent/swtorcfg/p_thunderbird.config > /dev/null 2>&1
fi

# Do we have gnupg active ?
# This option is not mandatory

if grep -q gnupg ~/Persistent/swtorcfg/persistence.conf ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "gnupg settings are present on this persistent volume"
   fi
   echo 1 > ~/Persistent/swtorcfg/p_gnupg.config
else
   rm ~/Persistent/swtorcfg/p_gnupg.config  > /dev/null 2>&1
fi

# Do we have electrum active ?
# This option is not mandatory

if grep -q electrum ~/Persistent/swtorcfg/persistence.conf ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "electrum settings are present on this persistent volume"
   fi
   echo 1 > ~/Persistent/swtorcfg/p_electrum.config
else
   rm ~/Persistent/swtorcfg/p_electrum.config > /dev/null 2>&1
fi

# Do we have pidgin active ?
# This option is not mandatory

if grep -q pidgin ~/Persistent/swtorcfg/persistence.conf ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "pidgin settings are present on this persistent volume"
   fi
   echo 1 > ~/Persistent/swtorcfg/p_pidgin.config
else
   rm ~/Persistent/swtorcfg/p_pidgin.config > /dev/null 2>&1
fi


# Do we have tca active ?
# This option is not mandatory

if grep -q tca ~/Persistent/swtorcfg/persistence.conf ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "tca settings are present on this persistent volume"
   fi
   echo 1 > ~/Persistent/swtorcfg/p_tca.config
else
   rm ~/Persistent/swtorcfg/p_tca.config > /dev/null 2>&1
fi

# Do we have dotfiles active ?

if grep -q dotfiles ~/Persistent/swtorcfg/persistence.conf ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "dotfiles are present on this persistent volume"
   fi
   echo 1 > ~/Persistent/swtorcfg/freezing
   echo 1 > ~/Persistent/swtorcfg/p_dotfiles.config

   # The user may have jumped from non dotfiles to activated dotfiles

   rm  ~/Persistent/swtorcfg/no-freezing > /dev/null 2>&1

else

   rm ~/Persistent/swtorcfg/freezing > /dev/null 2>&1
   rm ~/Persistent/swtorcfg/p_dotfiles.config > /dev/null 2>&1

   echo 1 > ~/Persistent/swtorcfg/no-freezing

   # This volume may was once actived with dotfiles and in the state freezed  ....
   # but by now it is not longer  possible ... missing dotfiles option
   # We have to clean up the mess.

fi

# All options are scanned now

zenity --info --width=600 --title="" \
--text="Welcome to the swtor addon for Tails.\nThis is the first time you startup this setup tool on this persistent volume of Tails.\n\n
* We create a few symbolic links inside of the persistent volume\n
* We create a folder personal-files\n
* We install 3 additional debian software-packages\n
\n\nPlease press OK to continue." > /dev/null 2>&1


# Creating personal-files

if [ ! -d ~/Persistent/personal-files ] ; then
   mkdir ~/Persistent/personal-files > /dev/null 2>&1
   mkdir ~/Persistent/personal-files/tails-repair-disk > /dev/null 2>&1
   if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo "directory ~/Persistent/personal-files was created"
   fi
else
   if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo "directory ~/Persistent/personal-files not created because it allready exist"
   fi
fi

if [ "$DEBUGW" == "1" ] ; then
      pid_to_kill=$(ps axu | grep zenity | grep wait | awk {'print $2'})
      echo wait_dialog 04 with PID $pid_to_kill will be killed
fi



zenity --question --width=600 \
--text="Configure the additional software for the addon ?\nOnly answer to 'No' if the 3 additional debian software packages are allready installed."  > /dev/null 2>&1

case $? in
         0)

         if [ $TERMINAL_VERBOSE == "1" ] ; then
            echo we do install the additional software
         fi

         sleep 10 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n\n    Update the debian packet-list and installing all the software.\n     This may need very long time to complete ! \n\n" > /dev/null 2>&1)

         show_wait_dialog && sleep 2

         # apt-get update

         cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
         sudo -S cp ~/Persistent/swtorcfg/live-additional-software.conf /live/persistence/TailsData_unlocked/ > /dev/null 2>&1

         cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
         sudo -S chown tails-persistence-setup:tails-persistence-setup /live/persistence/TailsData_unlocked/live-additional-software.conf > /dev/null 2>&1

         cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
         sudo -S apt-get update > /dev/null 2>&1 

         cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
         sudo -S apt-get install -y chromium > /dev/null 2>&1 

         cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
         sudo -S apt-get install -y chromium-sandbox > /dev/null 2>&1 

         cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
         sudo -S apt-get install -y sshpass > /dev/null 2>&1

         end_wait_dialog
         sleep 10 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n\nInstalling software is now complete.\n\n" > /dev/null 2>&1)
         ;;
         1) if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo nothing to install  ..
            fi
         ;;
esac

echo 0 > ~/Persistent/swtor-addon-to-tails/setup

sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
--text="\n\n             Setup is now complete. Congratulations !  \n\n" > /dev/null 2>&1)

# Delete the lock-file and all temporary files ...

rm ~/Persistent/swtor-addon-to-tails/tmp/password > /dev/null 2>&1
rmdir ~/Persistent/swtor-addon-to-tails/scripts/setup.lock > /dev/null 2>&1
rm -rf ~/Persistent/settings/1  > /dev/null 2>&1
rm -rf ~/Persistent/settings/2  > /dev/null 2>&1
rm -f ~/Persistent/swtor-addon-to-tails/scripts/scripts > /dev/null 2>&1

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo >&2 "removed acquired lock: $lockdir"
   echo >&2 "setup.sh was sucessfull exiting with return-code 0"
fi

# cleanup the mess with the wait dialog
swtor_cleanup
exit 0


