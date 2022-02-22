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
       fi
    else
       cp -r ~/Persistent/backup/personal-files/* ~/Persistent/personal-files/
       if [ $CLI_OUT == "1" ] ; then
          echo "Backup files ~/Persistent/personal-files restored"
       fi 
    fi

    # The above part was easy ... the restored files are independet from the version
    # of the running Tails-OS
    # Even the configuration files are not critical, as long we are using the same
    # Version of Tails.

    backup_version=$(cat ~/Persistent/backup/tails-backup-version)
    current_version=$(tails-version | head -n1 | awk {'print $1'})

    if [ $CLI_OUT == "1" ] ; then
       echo the backup-was made with version :$backup_version
       echo the current tails is :$current_version
    fi

    if [ "$backup_version" == "$current_version" ] ; then

        # If the backup contains bookmarks from Tor-Browser : we restore them back

        if [ -d ~/Persistent/backup/bookmarks ] ; then
        if mount | grep -q /home/amnesia/.mozilla/firefox/bookmarks ; then
           cp ~/Persistent/backup/bookmarks/places.sqlite ~/.mozilla/firefox/bookmarks
           if [ $CLI_OUT == "1" ] ; then 
              echo "Backup files bookmarks restored"
           fi
        else
           if [ $CLI_OUT == "1" ] ; then
              echo "Bookmarks not restored .... option is not active on this persistent volume"
           fi
        fi
        fi

        # If the backup contains gnupg : we restore them back

        if [ -d ~/Persistent/backup/gnupg ] ; then
        if mount | grep -q /home/amnesia/.gnupg ; then
           cp -r ~/Persistent/backup/gnupg/* ~/.gnupg/
           if [ $CLI_OUT == "1" ] ; then
              echo "Backup files gnupg restored"
           fi
        else
           if [ $CLI_OUT == "1" ] ; then
              echo "gnupg not restored .... option is not active on this persistent volume"
           fi  
        fi
        fi

        # If the backup contains thunderbird (Email) we restore them back

        if [ -d ~/Persistent/backup/thunderbird ] ; then
        if mount | grep -q home/amnesia/.thunderbird ; then
           cp -r ~/Persistent/backup/thunderbird/*  ~/.thunderbird
           if [ $CLI_OUT == "1" ] ; then
              echo "Backup files thunderbird restored"
           fi
        else
           if [ $CLI_OUT == "1" ] ; then
              echo "thunderbird not restored .... option is not active on this persistent volume"
           fi   
        fi
        fi


        # If the backup contains pidgin (Messanger) : we restore them back

        if [ -d ~/Persistent/backup/pidgin ] ; then
        if mount | grep -q /home/amnesia/.purple ; then
           cp -r ~/Persistent/backup/pidgin/* /home/amnesia/.purple
           if [ $CLI_OUT == "1" ] ; then
              echo "Backup files pidgin restored"
           fi
        else   
           echo "pidgin not restored .... option is not active on this persistent volume"
        fi
        fi

        # If the backup contains electrum bitcoin wallet : we restore them back

        if [ -d ~/Persistent/backup/electrum  ] ; then
        if mount | grep -q /home/amnesia/.electrum  ; then
           cp -r ~/Persistent/backup/electrum/*  /home/amnesia/.electrum
           if [ $CLI_OUT == "1" ] ; then
              echo "Backup files electrum restored"
           fi
        else
           if [ $CLI_OUT == "1" ] ; then 
              echo "electrum not restored .... option is not active on this persistent volume"
           fi
        fi
        fi

        # I don't know the exactly reason ... we copy back config from backup git
        # and we are able to make a git push without any password

        cp /home/amnesia/Persistent/backup/git/config ~/Persistent/swtor-addon-to-tails/.git

        # Even if we are in restore mode ... we need a administration password

        test_password_greeting
        if [ $? -eq 0 ] ; then
           if [ $CLI_OUT == "1" ] ; then
              echo "passwowrd is set" 
           fi

           sleep 1
        else
           echo "Error !!!! No Password set on the Greeting-Screen"
           echo
           echo "You have to start over again ... "
           echo "cd ~/Persistent/scripts"
           echo "./setup.sh restore-mode"
           echo
           exit 1
        fi

        test_admin_password
        if [ $? -eq 0 ] ; then
           if [ $CLI_OUT == "1" ] ; then
              echo "provided passwowrd is valid" 
           fi
           sleep 1
        else
           echo "password wrong or empty"
           echo
           echo "You have to start over again ... "
           echo "cd ~/Persistent/scripts"
           echo "./setup.sh restore-mode"
           echo
           exit 1
        fi

        # We need to know , what options are active inside of the persistent volume

        cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
        sudo -S cp /live/persistence/TailsData_unlocked/persistence.conf /home/amnesia/Persistent > /dev/null 2>&1

        cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
        sudo -S chmod 666 /home/amnesia/Persistent/persistence.conf > /dev/null 2>&1


        # Test mandatory option : ssh

        if grep -q openssh-client ~/Persistent/persistence.conf ; then
           if [ $CLI_OUT == "1" ] ; then
              echo >&2 "ssh settings are present on this persistent volume"
           fi
           cd ~/Persistent/backup/openssh-client
           cp id_rsa ~/.ssh
           cp id_rsa.pub ~/.ssh
           cp known_hosts ~/.ssh
           chmod 600 ~/.ssh/id_rsa
           chmod 644 ~/.ssh/*.pub
           ssh-add > /dev/null 2>&1
           if [ $CLI_OUT == "1" ] ; then
              echo "Backup files ~/.ssh restored"
           fi
        else
           echo "ssh-settings is not present on this persistent Volume"
           echo
           echo "You have to start over again ... "
           echo "Activate ssh-settings on this persistent Volume"
           echo "and restart Tails"
           echo
           echo "After booting : "
           echo "cd ~/Persistent/scripts"
           echo "./setup.sh restore-mode"
           exit 1
        fi

        # Mandatory : additional software part01

        if grep -q /var/cache/apt/archives  ~/Persistent/persistence.conf ; then
           if [ $CLI_OUT == "1" ] ; then 
              echo >&2 "additional-software part 01 is present on this persistent volume"
           fi  
        else
           echo "additional-software is not present on this persistent Volume"
           echo
           echo "You have to start over again ... "
           echo "Activate additional-software on this persistent Volume"
           echo "and restart Tails"
           echo
           echo "After booting : "
           echo "cd ~/Persistent/scripts"
           echo "./setup.sh restore-mode"
           exit 1
        fi

        # Mandatory : additional software part02

        if grep -q /var/lib/apt/lists ~/Persistent/persistence.conf ; then
           if [ $CLI_OUT == "1" ] ; then 
              echo >&2 "additional-software part 02 is present on this persistent volume"
           fi 
        else
           echo "additional-software is not present on this persistent Volume"
           echo
           echo "You have to start over again ... "
           echo "Activate additional-software on this persistent Volume"
           echo "and restart Tails"
           echo
           echo "After booting : "
           echo "cd ~/Persistent/scripts"
           echo "./setup.sh restore-mode"
           echo
           exit 1
        fi


        # If the backup contains network-connections : we restore them back

        if [ -d ~/Persistent/backup/nm-system-connections ] ; then
        if grep -q system-connection ~/Persistent/persistence.conf ; then

           cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
           sudo -S rsync -aqzh /home/amnesia/Persistent/backup/nm-system-connections /live/persistence/TailsData_unlocked/ > /dev/null 2>&1

           # Very important  here after the copy :
           # We need to change the owner and group to root:root for all the files or
           # the owner and group is amnesia:amnesia and this would not work on the next boot

           cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
           sudo -S  chown -R root:root /live/persistence/TailsData_unlocked/nm-system-connections > /dev/null 2>&1
           
           if [ $CLI_OUT == "1" ] ; then   
              echo "Backup files system-connection restored"
           fi 
        else
           if [ $CLI_OUT == "1" ] ; then  
              echo "system-connection not restored .... option is not active on this persistent volume"
           fi  
        fi
        fi

        # If the backup contains tca (TOR-Nodes configuration) : we restore them back

        if [ -d ~/Persistent/backup/tca  ] ; then
        if grep -q tca ~/Persistent/persistence.conf ; then

           cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
           sudo -S rsync -aqzh /home/amnesia/Persistent/backup/tca /live/persistence/TailsData_unlocked/ > /dev/null 2>&1

           # Very important  here after the copy :
           # We need to change the owner and group to root:root for all the files or
           # the owner and group is amnesia:amnesia

           cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
           sudo -S chown -R root:root /live/persistence/TailsData_unlocked/tca  > /dev/null 2>&1

           if [ $CLI_OUT == "1" ] ; then 
              echo "Backup files tca restored"
           fi
        else
           if [ $CLI_OUT == "1" ] ; then  
              echo "tca not restored .... option is not active on this persistent volume"
           fi
        fi
        fi

        # If the backup contains cups (Printing) : we restore them back

        if [ -d ~/Persistent/backup/cups-configuration ] ; then
        if grep -q cups-configuration ~/Persistent/persistence.conf ; then

           # The owner and groups of the cups configuration
           #
           # root root 6402 Dec  6 15:03 cupsd.conf
           # root root 2923 Nov 28  2020 cups-files.conf
           # root root 4096 Nov 28  2020 interfaces
           # root lp   4096 Nov 28  2020 ppd
           # root root  240 Dec  6 15:03 raw.convs
           # root root  211 Dec  6 15:03 raw.types
           # root root  142 Nov 28  2020 snmp.conf
           # root lp   4096 Nov 28  2020 ssl
           # root lp    694 Jan  8 12:08 subscriptions.conf
           # root lp    392 Jan  8 12:04 subscriptions.conf.O


           cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
           sudo -S rsync -aqzh /home/amnesia/Persistent/backup/cups-configuration /live/persistence/TailsData_unlocked/ > /dev/null 2>&1


           # Very important  here after the copy :
           # We need to change the owner and group to root:root for all the files or
           # the owner and group is amnesia:amnesia

           cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
           sudo -S chown -R root:root /live/persistence/TailsData_unlocked/cups-configuration > /dev/null 2>&1


           # special owner and group for ppd

           cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
           sudo -S chown -R root:lp /live/persistence/TailsData_unlocked/cups-configuration/ppd > /dev/null 2>&1

           # special owner and group for ssl

           cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
           sudo -S chown -R root:lp /live/persistence/TailsData_unlocked/cups-configuration/ssl > /dev/null 2>&1


           # special owner and group for subscriptions.conf

           cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
           sudo -S  chown -R root:lp /live/persistence/TailsData_unlocked/cups-configuration/subscriptions.conf > /dev/null 2>&1

           # Is this really needet ? We see
           # special owner and group for subscriptions.conf.0

           cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
           sudo -S  chown -R root:lp /live/persistence/TailsData_unlocked/cups-configuration/subscriptions.conf.0 > /dev/null 2>&1
           if [ $CLI_OUT == "1" ] ; then 
              echo "Backup files cups restored"
           fi
        else
           if [ $CLI_OUT == "1" ] ; then 
              echo "cups not restored .... option is not active on this persistent volume"
           fi
        fi
        fi


        # If the backup contains greeter-settings : we restore them back

        if [ -d ~/Persistent/backup/greeter-settings ] ; then
        if grep -q greeter-settings ~/Persistent/persistence.conf ; then

           # The owner and groups of the greeter-settings
           #
           # Debian-gdm Debian-gdm   37 Jan  7 21:48 tails.formats
           # Debian-gdm Debian-gdm   75 Jan  8 12:08 tails.keyboard
           # Debian-gdm Debian-gdm   41 Jan  7 21:48 tails.language
           # Debian-gdm Debian-gdm   28 Jan  7 21:48 tails.macspoof
           # Debian-gdm Debian-gdm   19 Jan  7 21:48 tails.network
           # Debian-gdm Debian-gdm  160 Jan  7 21:48 tails.password
           # Debian-gdm Debian-gdm   35 Jan  7 21:48 tails.unsafe-browser

           cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
           sudo -S rsync -aqzh /home/amnesia/Persistent/backup/greeter-settings /live/persistence/TailsData_unlocked/ > /dev/null 2>&1

           # Very important  here after the copy :
           # We need to change the owner and group to Debian-gdm:Debian-gdm for all the files or
           # the owner and group is amnesia:amnesia

           cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
           sudo -S chown -R Debian-gdm:Debian-gdm /live/persistence/TailsData_unlocked/greeter-settings > /dev/null 2>&1
            
           if [ $CLI_OUT == "1" ] ; then      
              echo "Backup files greeter-settings restored"
           fi
        else
           if [ $CLI_OUT == "1" ] ; then 
              echo "greeter-settings not restored .... option is not active on this persistent volume"
           fi 
        fi
        fi

        # We copy back the configuration for the additional-Software that is stored here
        #
        # tails-persistence-setup tails-persistence-setup     0 Jan  7 21:46 live-additional-software.conf
        #

        if [ $CLI_OUT == "1" ] ; then 
           echo "Execute command apt-get update. Please wait !!!! "
           echo "Please do not interrupt here .... This commands need a lot of time !!!"
        fi 

        # This could use a very long time 

        show_wait_dialog && sleep 2
       
        cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
        sudo -S cp ~/Persistent/backup/live-additional-software.conf /live/persistence/TailsData_unlocked/ > /dev/null 2>&1

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
          
 

        # We have a open dialog to close

        end_wait_dialog && sleep 1

        if [ $CLI_OUT == "1" ] ; then 
           echo "Backup files additional-software restored and software installed"
        fi

        # Do we have dotfiles inside the backup  ?

        if [ -d ~/Persistent/backup/dotfiles ] ; then
        if grep -q dotfiles  ~/Persistent/persistence.conf ; then

           # We don't restore back the files from dotfiles by now

           cd ~/Persistent/scripts

           # Was the system during Backup in the state freezed ?
           # If this is the case ... we are freezing this Tails as well again 

           echo 1 > ~/Persistent/swtorcfg/freezing

           if [ -f ~/Persistent/backup/swtorcfg/freezed.cgf ]  ; then
              ./cli_tweak.sh > /dev/null 2>&1
              ./cli_freezing.sh > /dev/null 2>&1
              if [ $CLI_OUT == "1" ] ; then
                 echo state : now this Tails is [freezed]
              fi
           else
              if [ $CLI_OUT == "1" ] ; then
                 echo state : not-freezed here because backup was not freezed
              fi  
           fi

        else
           echo 1 > ~/Persistent/swtorcfg/no-freezing
           if [ $CLI_OUT == "1" ] ; then
              echo "dotfiles not restored .... option is not active on this persistent volume"
           fi 
        fi
        fi
        echo 0 > ~/Persistent/swtor-addon-to-tails/setup
    else
        if [ $CLI_OUT == "1" ] ; then   
           echo The backup was made with a older version of Tails ..
        fi 
       
        # Because the backup was made with a older version of Tails ..
        # We have to ask on very restore .... 
 

    fi
    
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


