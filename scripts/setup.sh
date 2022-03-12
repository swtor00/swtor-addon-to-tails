#/bin/bash
#########################################################
# SCRIPT  : setup.sh                                    #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.25 or higher                        #
#                                                       #
#                                                       #
# VERSION : 0.60                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 30-12-21                                    #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################


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

####################################################################################################################
# if this script was started in restore-mode from a backup ..... we do copy back here
####################################################################################################################
if [ $# -eq 1 ] ; then
    
    if [ $CLI_OUT == "1" ] ; then 
       echo restore-mode from backup is active
    fi

    # Even if we are in restore mode ... we need a administration password
    # or the installation of software is not working.

    test_password_greeting
    if [ $? -eq 0 ] ; then
       if [ $CLI_OUT == "1" ] ; then
          echo "passwowrd is set" 
       fi
       sleep 0.5
    else
       echo "Error !!!! No Password set on the Greeting-Screen"
       echo "Please make a rebooot and set a password"
       echo
       echo "After booting please open a terminal and type : "
       echo "cd ~/Persistent"
       echo "./restore.sh"
       exit 1
    fi

    test_admin_password
    if [ $? -eq 0 ] ; then
       if [ $CLI_OUT == "1" ] ; then
          echo "provided password is valid" 
       fi
       sleep 0.5

       rm -rf /live/persistence/TailsData_unlocked/dotfiles/Desktop > /dev/null 2>&1
       rm -rf /live/persistence/TailsData_unlocked/dotfiles/Pictures > /dev/null 2>&1
       rm -rf /live/persistence/TailsData_unlocked/dotfiles/.config > /dev/null 2>&1

    else
        echo "Password was wrong or empty"
        echo "Please make a rebooot and set a password"
        echo
        echo "After booting please open a terminal and type : "
        echo "cd ~/Persistent"
        echo "./restore.sh"
        exit 1
    fi

    # We need to know exactly, what options are active inside of the persistent volume by now 

    cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
    sudo -S cp /live/persistence/TailsData_unlocked/persistence.conf /home/amnesia/Persistent > /dev/null 2>&1

    cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
    sudo -S chmod 666 /home/amnesia/Persistent/persistence.conf > /dev/null 2>&1

    # Test mandatory option : ssh

    if grep -q openssh-client ~/Persistent/persistence.conf ; then
       if [ $CLI_OUT == "1" ] ; then
          echo >&2 "ssh settings are present on this persistent volume"
       fi
    else
        zenity --error --width=600 \
        --text="\n\n         This addon needs the ssh option inside of the persistent volume.\n         You have to set this option first ! \n\n" \
        > /dev/null 2>&1
       echo "ssh-settings is not present on this persistent Volume"
       echo
       echo "You have to start over again ... "
       echo "Activate ssh-settings on this persistent Volume"
       echo "and restart Tails"
       echo
       echo "After booting please open a terminal and type : "
       echo "cd ~/Persistent"
       echo "./restore.sh"
       exit 1
    fi

    # Mandatory : additional software part01

    if grep -q /var/cache/apt/archives  ~/Persistent/persistence.conf ; then
       if [ $CLI_OUT == "1" ] ; then 
          echo >&2 "additional-software part 01 is present on this persistent volume"
       fi  
    else
       zenity --error --width=600 \
       --text="\n\n         This addon needs the additional software option inside of the persistent volume.\n         You have to set this option first ! \n\n" \
       > /dev/null 2>&1
       echo "additional-software is not present on this persistent Volume"
       echo
       echo "You have to start over again ... "
       echo "Activate additional-software on this persistent Volume"
       echo "and restart Tails"
       echo
       echo "After booting please open a terminal and type : "
       echo "cd ~/Persistent"
       echo "./restore.sh"
       exit 1
    fi

    # Mandatory : additional software part02

    if grep -q /var/lib/apt/lists ~/Persistent/persistence.conf ; then
       if [ $CLI_OUT == "1" ] ; then 
          echo >&2 "additional-software part 02 is present on this persistent volume"
       fi 
    else
       zenity --error --width=600 \
       --text="\n\n         This addon needs the additional software option inside of the persistent volume.\n         You have to set this option first ! \n\n" \
       > /dev/null 2>&1
       echo "additional-software is not present on this persistent Volume"
       echo
       echo "You have to start over again ... "
       echo "Activate additional-software on this persistent Volume"
       echo "and restart Tails"
       echo
       echo "After booting please open a terminal and type : "
       echo "cd ~/Persistent"
       echo "./restore.sh"
       exit 1
    fi

    # Prior to restoring files from the backup , we check the backup-directorys and 
    # the optional settings from the Persistent Volume. The User can choose what to do ..... 

    if [ -d ~/Persistent/backup/dotfiles ] ; then
        if grep -q dotfiles  ~/Persistent/persistence.conf ; then
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for dotfiles and persistent option is set"
           fi    
        else
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for dotfiles and persistent option is not set on this voulume"
           fi
           zenity --question --width 600 \
           --text "\n\n         This extracted backup contains files from dotfiles. \n\n         If you say 'Yes' the restore stops here and you can set the above option and restart Tails.\n\n         If you say 'No' the backup will not restore the backup files from the above option\n         and will not be interupted ! \n\n"
           case $? in
           0)
             exit 1 
           ;; 
           1)
             if [ $TERMINAL_VERBOSE == "1" ] ; then
                echo "backup not stoped here ... we go further "
             fi
           ;;
           esac                 
        fi
    fi

    if [ -d ~/Persistent/backup/greeter-settings ] ; then
       if grep -q greeter-settings ~/Persistent/persistence.conf ; then
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for gretter-settings and persistent option is set"
           fi    
        else
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for greeter-settings and persistent option is not set on this voulume"
           fi
           zenity --question --width 600 \
           --text "\n\n         This extracted backup contains files from gretter-settings. \n\n         If you say 'Yes' the restore stops here and you can set the above option and restart Tails.\n\n         If you say 'No' the backup will not restore the backup files from the above option\n         and will not be interupted ! \n\n"
           case $? in
           0)
             exit 1 
           ;; 
           1)
             if [ $TERMINAL_VERBOSE == "1" ] ; then
                echo "backup not stoped here ... we go further "
             fi
           ;;
           esac                 
        fi
    fi

    if [ -d ~/Persistent/backup/cups-configuration ] ; then
        if grep -q cups-configuration ~/Persistent/persistence.conf ; then
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for cups and persistent option is set"
           fi    
        else
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for cups and persistent option is not set on this voulume"
           fi
           zenity --question --width 600 \
           --text "\n\n         This extracted backup contains files from cups. \n\n         If you say 'Yes' the restore stops here and you can set the above option and restart Tails.\n\n         If you say 'No' the backup will not restore the backup files from the above option\n         and will not be interupted ! \n\n"
           case $? in
           0)
             exit 1 
           ;; 
           1)
             if [ $TERMINAL_VERBOSE == "1" ] ; then
                echo "backup not stoped here ... we go further "
             fi
           ;;
           esac                 
        fi
    fi

    if [ -d ~/Persistent/backup/tca  ] ; then
        if grep -q tca ~/Persistent/persistence.conf ; then
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for tca and persistent option is set"
           fi    
        else
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for tca and persistent option is not set on this voulume"
           fi
           zenity --question --width 600 \
           --text "\n\n         This extracted backup contains files from tca. \n\n         If you say 'Yes' the restore stops here and you can set the above option and restart Tails.\n\n         If you say 'No' the backup will not restore the backup files from the above option\n         and will not be interupted ! \n\n"
           case $? in
           0)
             exit 1 
           ;; 
           1)
             if [ $TERMINAL_VERBOSE == "1" ] ; then
                echo "backup not stoped here ... we go further "
             fi
           ;;
           esac                 
        fi
    fi

    if [ -d ~/Persistent/backup/nm-system-connections ] ; then
        if grep -q system-connection ~/Persistent/persistence.conf ; then
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for network-connections and persistent option is set"
           fi    
        else
           if [ $CLI_OUT == "1" ] ; then  
              echo "we found backup files for network-connections and persistent option is not set on this voulume"
           fi
           zenity --question --width 600 \
           --text "\n\n         This extracted backup contains files from network-connections. \n\n         If you say 'Yes' the restore stops here and you can set the above option and restart Tails.\n\n         If you say 'No' the backup will not restore the backup files from the above option\n         and will not be interupted ! \n\n"
           case $? in
           0)
             exit 1 
           ;; 
           1)
             if [ $TERMINAL_VERBOSE == "1" ] ; then
                echo "backup not stoped here ... we go further "
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
              echo "we found backup files for electrum and persistent option is not set on this voulume"
           fi
           zenity --question --width 600 \
           --text "\n\n         This extracted backup contains files from electrum. \n\n         If you say 'Yes' the restore stops here and you can set the above option and restart Tails.\n\n         If you say 'No' the backup will not restore the backup files from the above option\n         and will not be interupted ! \n\n"
           case $? in
           0)
             exit 1 
           ;; 
           1)
             if [ $TERMINAL_VERBOSE == "1" ] ; then
                echo "backup not stoped here ... we go further "
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
           --text "\n\n         This extracted backup contains files from pidgin. \n\n         If you say 'Yes' the restore stops here and you can set the above option and restart Tails.\n\n         If you say 'No' the backup will not restore the backup files from the above option\n         and will not be interupted ! \n\n"
           case $? in
           0)
             exit 1 
           ;; 
           1)
             if [ $TERMINAL_VERBOSE == "1" ] ; then
                echo "backup not stoped here ... we go further "
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
              echo "we found backup files for thunderbid and persistent option is not set on this voulume"
           fi
           zenity --question --width 600 \
           --text "\n\n         This extracted backup contains files from thunderbird. \n\n         If you say 'Yes' the restore stops here and you can set the above option and restart Tails.\n\n         If you say 'No' the backup will not restore the backup files from the above option\n         and will not be interupted ! \n\n"
           case $? in
           0)
             exit 1 
           ;; 
           1)
             if [ $TERMINAL_VERBOSE == "1" ] ; then
                echo "backup not stoped here ... we go further "
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
              echo "we found backup files for thunderbid and persistent option is not set on this voulume"
           fi
           zenity --question --width 600 \
           --text "\n\n         This extracted backup contains files from thunderbird. \n\n         If you say 'Yes' the restore stops here and you can set the above option and restart Tails.\n\n         If you say 'No' the backup will not restore the backup files from the above option\n         and will not be interupted ! \n\n"
           case $? in
           0)
             exit 1 
           ;; 
           1)
             if [ $TERMINAL_VERBOSE == "1" ] ; then
                echo "backup not stoped here ... we go further "
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
              echo "we found backup files for gnupg and persistent option is not set on this voulume"
           fi
           zenity --question --width 600 \
           --text "\n\n         This extracted backup contains files from gmupg. \n\n         If you say 'Yes' the restore stops here and you can set the above option and restart Tails.\n\n         If you say 'No' the backup will not restore the backup files from the above option\n         and will not be interupted ! \n\n"
           case $? in
           0)
             exit 1 
           ;; 
           1)
             if [ $TERMINAL_VERBOSE == "1" ] ; then
                echo "backup not stoped here ... we go further "
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
              echo "we found backup files for bookmarks and persistent option is not set on this voulume"
           fi
           zenity --question --width 600 \
           --text "\n\n         This extracted backup contains files from bookmarks. \n\n         If you say 'Yes' the restore stops here and you can set the above option and restart Tails.\n\n         If you say 'No' the backup will not restore the backup files from the above option\n         and will not be interupted ! \n\n"
           case $? in
           0)
             exit 1 
           ;; 
           1)
             if [ $TERMINAL_VERBOSE == "1" ] ; then
                echo "backup not stoped here ... we go further "
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

    # The above part was easy ... the restored files are independet from the version
    # of the running Tails-OS
    # Even most of the configuration files are not critical, as long we are using the same
    # Version of Tails to restore.

    backup_version=$(cat ~/Persistent/backup/tails-backup-version | sed 's/[.]*//g')
    current_version=$(tails-version | head -n1 | awk {'print $1'} | sed 's/[.]*//g')

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
        # Stop restoring and recommand to make a upgrade to a higher version

        # 2. The backup was made with a older system and the current Tails is newer 
        # Asking on every restore-point ....  
 

        if [ $backup_version -gt $current_version ] ; then   
           if [ $CLI_OUT == "1" ] ; then   
              echo The backup version is greater than the current one
           fi

           end_wait_dialog && sleep 1.5
  
           echo    
           echo "We have a conflict here : " 
           echo "Backup was made with Tails : "$(cat ~/Persistent/backup/tails-backup-version)
           echo "Current Tails in use is    : "$(tails-version | head -n1 | awk {'print $1'})
           echo "Restore is not possible !!! " 
           echo "For restoring the backup-data,the Tails must be equal or higher !!!"   

           zenity --error --width=600 \
           --text="\n\n         The backup you made, used a newer Tails version than the current one ! \n\n" > /dev/null 2>&1
           exit 1
        fi 

         
        if [ $current_version -gt $backup_version ] ; then 
           if [ $CLI_OUT == "1" ] ; then   
              echo The current version is greater than the backup-system 
           fi  

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

           restore_finish 
        fi

    fi
    
    end_wait_dialog && sleep 1.5 
    exit 0
fi
####################################################################################################################





# After the initaliation we can use all the functions from swtor-global.sh

show_wait_dialog && sleep 2

if [ "$DEBUGW" == "1" ] ; then
   pid_to_kill=$(ps axu | grep zenity | grep wait | awk {'print $2'})
   echo wait_dialog 01 with PID $pid_to_kill created
fi

# Creating the lockdirectory ....

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


# After the setup is completly executed the file "setup" will be created inside ~/Persistent/swtor-addon-to-tails
# If this file exist , the setup will not executed. If you would like to start-over with ./swtor-setup.sh
# I would recommand the following order.
# 1. If the System is current freezed ... unfreez it and make a reboot of Tails.
# 2. Delete the file "setup" inside the directory ~/Persistent/swtor-addon-to-tails
# 3. execute the command ./swtor-setup.sh and the hole setup process can be started again.


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


# Check the TOR-Connection over Internet

check_tor_network
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "internet is working as expected."
    fi
    show_wait_dialog && sleep 2

    if [ "$DEBUGW" == "1" ] ; then
       pid_to_kill=$(ps axu | grep zenity | grep wait | awk {'print $2'})
       echo wait_dialog 02 with PID $pid_to_kill created
    fi

else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "no active internet connection found !"
       echo >&2 "setup.sh exiting with error-code 1"
    fi
    rmdir $lockdir > /dev/null 2>&1
    exit 1
fi


# Check for ~/.ssh persistent

test_ssh_persistent
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "we have .ssh on persistent."
    fi

    # We can still use the show_wait_dialog from check_tor_network

else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "no ssh option for persistent found !"
       echo >&2 "setup.sh exiting with error-code 1"
    fi
    rmdir $lockdir > /dev/null 2>&1
    exit 1
fi


# Check for additional software inside persistent

test_software_persistent
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "we have additional software persistent."
    fi

    # We can still use the show_wait_dialog from check_tor_network
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "no additional software option for persistent found !"
       echo >&2 "setup.sh exiting with error-code 1"
    fi
    rmdir $lockdir > /dev/null 2>&1
    exit 1
fi


# Check for bookmarks persistent

test_bookmarks_persistent
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "we have bookmarks set and can import them"
    fi

    # We can still use the show_wait_dialog from check_tor_network

else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "import of bookmarks not possible  !"
       echo >&2 "setup.sh exiting with error-code 1"
    fi
    rmdir $lockdir > /dev/null 2>&1
    exit 1
fi


# Check for active administration password on startup is set or not ...

test_password_greeting
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "we have a administration password"
    fi
    show_wait_dialog && sleep 2

    if [ "$DEBUGW" == "1" ] ; then
       pid_to_kill=$(ps axu | grep zenity | grep wait | awk {'print $2'})
       echo wait_dialog 03 with PID $pid_to_kill created
    fi

else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "no password have ben set on the greeter-screen !"
       echo >&2 "setup.sh exiting with error-code 1"
    fi
    rmdir $lockdir > /dev/null 2>&1
    exit 1
fi



# Check for a valid administration password of Tails

test_admin_password
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "we have a correct password"
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "password was wrong or empty"
       echo >&2 "setup.sh exiting with error-code 1"
    fi
    rmdir $lockdir > /dev/null 2>&1
    exit 1
fi


# Ok ... we have all the things needet to start over with setup
#
# * We have at least, the needet options for the persistent volume
# * We have a correct administration password for Tails
# * We can move forward and make some changes to this persist volume.
#

zenity --info --width=600 --title="" \
--text="Welcome to the swtor addon for Tails.\nThis ist the first time you startup this tool on this persistent volume of Tails.\n\n* We create a few symbolic links inside of the persistent volume\n* We create a folder personal-files\n* We install 5 additional debian software-packages\n* We import bookmarks depending of the configuration of swtor.cfg\n\n\nPlease press OK to continue." > /dev/null 2>&1

show_wait_dialog && sleep 2

if [ "$DEBUGW" == "1" ] ; then
   pid_to_kill=$(ps axu | grep zenity | grep wait | awk {'print $2'})
   echo wait_dialog 04 with PID $pid_to_kill created
fi


if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo "creating symlinks inside of ~/Persistent"
fi

if [ ! -L ~/Persistent/settings ] ; then
   ln -s ~/Persistent/swtor-addon-to-tails/settings ~/Persistent/settings > /dev/null 2>&1
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "creating symlink ~/Persistent/settings"
   fi
else
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "symlink ~/Persistent/settings was allready made"
   fi
fi

if [ ! -L ~/Persistent/scripts ] ; then
   ln -s ~/Persistent/swtor-addon-to-tails/scripts  ~/Persistent/scripts > /dev/null 2>&1
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "creating symlink ~/Persistent/scripts"
   fi
else
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "symlink ~/Persistent/scripts was allready made"
   fi
fi

if [ ! -L ~/Persistent/swtorcfg ] ; then
   ln -s ~/Persistent/swtor-addon-to-tails/swtorcfg ~/Persistent/swtorcfg > /dev/null 2>&1
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "creating symlink ~/Persistent/swtorcfg"
   fi
else
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "symlink ~/Persistent/swtorcfg was allready made"
   fi
fi

if [ ! -L ~/Persistent/doc ] ; then
   ln -s ~/Persistent/swtor-addon-to-tails/doc ~/Persistent/doc > /dev/null 2>&1
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "creating symlink ~/Persistent/doc"
   fi
else
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "symlink ~/Persistent/doc was allready made"
   fi
fi

if [ ! -d ~/Persistent/swtor-addon-to-tails/swtorcfg/log ] ; then

   mkdir -p ~/Persistent/swtor-addon-to-tails/swtorcfg/log

   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "directory ~/Persistent/swtor-addon-to-tails/swtorcfg/log was created"
   fi

else
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "directory ~/Persistent/swtor-addon-to-tails/swtorcfg/log was allready made"
   fi
fi


# With all the above infos,we have enough information to testing
# if this persistent volume has dotfiles activated or not.
# We aren't able to freeze the seetings without the option of dotfiles.
# And yes it is only a advice ... activate it if ever possible.


cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
sudo -S cp /live/persistence/TailsData_unlocked/persistence.conf /home/amnesia/Persistent > /dev/null 2>&1

cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
sudo -S chmod 666 /home/amnesia/Persistent/persistence.conf > /dev/null 2>&1



if grep -q dotfiles ~/Persistent/persistence.conf ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "dotfiles are present on this persistent volume"
       echo >&2 "a complete freezing of the settings from Tails is possible"
   fi
   rm ~/Persistent/persistence.conf > /dev/null 2>&1
   echo 1 > ~/Persistent/swtorcfg/freezing
else
   if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "dotfiles are not present on this persistent volume"
       echo >&2 "freezing is not possible in the current state."
   fi


   if [ "$DEBUGW" == "1" ] ; then
      pid_to_kill=$(ps axu | grep zenity | grep wait | awk {'print $2'})
      echo wait_dialog 04 with PID $pid_to_kill will be killed
   fi


   # We have a open dialog to close

   end_wait_dialog


   zenity --question --width=600 --text="On this persistent volume the option for dotfiles isn't set.\nWould you like to stop here and set the option and restart Tails ?" > /dev/null 2>&1
   case $? in
         0)
         rm ~/Persistent/persistence.conf /dev/null 2>&1
         sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n\nPlease don't forget the dotfiles activation ! \n\n" > /dev/null 2>&1)

         rmdir $lockdir > /dev/null 2>&1
         if [ $TERMINAL_VERBOSE == "1" ] ; then
             echo >&2 "The user would like to stop here and reboot Tails."
             echo >&2 "removed acquired lock: $lockdir"
             echo >&2 "setup.sh exiting with error-code 0"
         fi
         exit 0
         ;;
         1) if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo "the user would like to continue wihtout dotfiles activated ...."
               echo "against the tip to activate this option"
            fi

         rm ~/Persistent/persistence.conf > /dev/null 2>&1
         rm ~/Persistent/swtorcfg/freezing > /dev/null 2>&1

         echo 1 > ~/Persistent/swtorcfg/no-freezing

         ;;
   esac
fi


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

# We have a open dialog to close

end_wait_dialog

zenity --question --width=600 \
--text="Should a symbolic link created for the directory ~/Persistent/personal-files ?\nIf you are unsure about this question, you can save answer No.\n" > /dev/null 2>&1
case $? in
         0) symlinkdir=$(zenity --entry --width=600 --text="Please provide the name of the symlinked directory ?" --title=Directory)

            if [ "$symlinkdir" == "" ];then
               if [ $TERMINAL_VERBOSE == "1" ] ; then
                    echo not creating symlink $symlinkdir because the name was empty
                    echo >&2 "removed acquired lock: $lockdir"
                    echo >&2 "setup.sh exiting with error-code 1"
               fi
               exit 1
            else
                 ln -s ~/Persistent/personal-files ~/Persistent/$symlinkdir > /dev/null 2>&1
                 if [ $TERMINAL_VERBOSE == "1" ] ; then
                    echo creating symlink $symlinkdir
                 fi
            fi
         ;;
         1) if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo not creating symlink
            fi
         ;;
esac



zenity --question --width=600 --text="Would you like to create a fixed chromium profile ? \nAll information stored in this profile remains valid even after a reboot !\n\nIf the directory ~Persistent/personal-files/3 allready exist, we don't copy anything."
case $? in
         0) cd ~/Persistent/settings
            tar xzf tmp.tar.gz > /dev/null 2>&1

            if [ ! -d ~/Persistent/personal-files/3 ] ; then
                mv  ~/Persistent/settings/2 ~/Persistent/personal-files/
                mv  ~/Persistent/personal-files/2 ~/Persistent/personal-files/3
                if [ $TERMINAL_VERBOSE == "1" ] ; then
                 echo "new fixed profile created ~/Persistent/personal-files/3"
               fi
         else
              if [ $TERMINAL_VERBOSE == "1" ] ; then
                 echo "directory ~/Persistent/personal-files/3 not created because the directoy exist allready"
              fi
         fi

         ;;
         1) if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo "not creating fixed profile ~/Persistent/personal-files/3"
            fi
         ;;
esac


show_wait_dialog && sleep 2

if [ "$DEBUGW" == "1" ] ; then
   pid_to_kill=$(ps axu | grep zenity | grep wait | awk {'print $2'})
   echo wait_dialog 05 with PID $pid_to_kill created
fi

rm -rf /Persistent/settings/2 > /dev/null 2>&1
rm -rf /Persistent/settings/1 > /dev/null 2>&1


# Restore the TOR-Browser  bookmarks depending on the configuration file swtor.cfg

if [ $IMPORT_BOOKMAKRS == "1" ] ; then
   echo
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo importing bookmarks
   fi
   zenity --info --width=600 --title="" \
   --text="Please close all open windows of the TOR-Browser or the import will not work.   \n\n Please press OK to continue." > /dev/null 2>&1
   rm ~/.mozilla/firefox/bookmarks/places.sqlite > /dev/null 2>&1
   rm /live/persistence/TailsData_unlocked/bookmarks/places.sqlite > /dev/null 2>&1
   rsync -aqzh ~/Persistent/swtor-addon-to-tails/bookmarks /live/persistence/TailsData_unlocked
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "bookmarks are not imported because the configuration is set to IMPORT-BOOKMARKS:NO"
    fi
fi


if [ "$DEBUGW" == "1" ] ; then
      pid_to_kill=$(ps axu | grep zenity | grep wait | awk {'print $2'})
      echo wait_dialog 05 with PID $pid_to_kill will be killed
fi

end_wait_dialog

zenity --question --width=600 \
--text="Configure the additional software for the addon ?\nOnly answer to 'No' if the additional debian software packages are allready installed."  > /dev/null 2>&1

case $? in
         0)

         if [ $TERMINAL_VERBOSE == "1" ] ; then
            echo we do install the additional software
         fi

         sleep 13 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n\n    Update the debian packet-list and installing all the software.\n     This may need very long time to complete ! \n\n" > /dev/null 2>&1)

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
         sudo -S apt-get install -y html2text > /dev/null 2>&1 

         cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
         sudo -S apt-get install -y sshpass > /dev/null 2>&1
 
         cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
         sudo -S apt-get install -y yad > /dev/null 2>&1

         end_wait_dialog
         sleep 10 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n\nInstalling software is now complete.\n\n" > /dev/null 2>&1)
         ;;
         1) if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo nothing to install  ..
            fi
         ;;
esac


# if we don't have a persistent volume with dotfiles activated ....
# this next step make no sense ...
# But it is possible ... that system is allready freezed ....

if [ -f ~/Persistent/swtorcfg/freezing ] && [ ! -f ~/Persistent/swtorcfg/freezed.cgf ] ; then

    # apply all gui-tweaks over a script.

    cd ~/Persistent/scripts
    ./swtor-tweak-gui.sh

    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "gui-tweak is complete"
    fi

    # The question to freez or not  ...

    zenity --question --width=600 --text="Should this Tails OS be freezed ? It would be possible to make this final step.\n\nIn the case you are unhappy about the configuration please execute\nthe script called cli_unfreezing.sh in a Terminal and make a reboot.\n"  > /dev/null 2>&1

    case $? in
         0)
            ./cli_freezing.sh

            if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo systen freezed
            fi

         ;;
         1) if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo not freezing
            fi
         ;;
    esac
else
   if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo "freezing not possible in the current state of the persistent volume"
         echo "or this system is may allready in the state frezed "
   fi
fi


# Ok .. we are done here ...

echo 0 > ~/Persistent/swtor-addon-to-tails/setup

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo >&2 "setup.sh is now completed"
fi

sleep 15 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
--text="\n\nSetup is now complete. Congratulations ! \n\nThere are two ways possible to start this addon : \n\n * execute the command ./swtor-menu.sh over a Terminal\n   inside of the directory ~/Persistent/scripts\n\n * By clicking on the symbolic link 'swtor-menu.sh' on the Desktop\n\n" > /dev/null 2>&1)



# Delete the lock-file and all temporary files ...

rm ~/Persistent/swtor-addon-to-tails/tmp/password > /dev/null 2>&1
rmdir ~/Persistent/swtor-addon-to-tails/scripts/setup.lock > /dev/null 2>&1
rm -rf ~/Persistent/settings/1  > /dev/null 2>&1
rm -rf ~/Persistent/settings/2  > /dev/null 2>&1
rm -f ~/Persistent/swtor-addon-to-tails/scripts/scripts > /dev/null 2>&1


# Create symbolic link on desktop

if [ $GUI_LINKS == "1" ] ; then
    if [ ! -L ~/Desktop/swtor-menu.sh ] ; then
       ln -s ~/Persistent/scripts/swtor-menu.sh ~/Desktop/swtor-menu.sh
       if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo symlink on desktop created
       fi
    else
       if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo symlink on desktop allready exist
       fi
    fi
fi


if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo >&2 "removed acquired lock: $lockdir"
   echo >&2 "setup.sh was sucessfull exiting with return-code 0"
fi


# cleanup the mess with the wait dialog

swtor_cleanup

exit 0


