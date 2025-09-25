#!/bin/bash
#########################################################
# SCRIPT  : fullssh.sh                                  #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 7.0 or higher                        #
# TASKS   : run a ssh command with multiple options     #
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



source ~/Persistent/scripts/swtor-global.sh
global_init
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "global_init() done"
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "failure during initialisation of global-init() !"
       echo >&2 "fullssh.sh exiting with error-code 1"
    fi
    exit 1
fi

# If there was error in the last connection, we kill the file

rm /home/amnesia/Persistent/scripts/state/error > /dev/null 2>&1


# Test parameters for this script

if [ -f /home/amnesia/Persistent/swtorcfg/fullssh.arg ]
   then

   arg1=$(cat /home/amnesia/Persistent/swtorcfg/fullssh.arg | awk '{print $1}')
   arg2=$(cat /home/amnesia/Persistent/swtorcfg/fullssh.arg | awk '{print $2}')
   arg3=$(cat /home/amnesia/Persistent/swtorcfg/fullssh.arg | awk '{print $3}')
   arg4=$(cat /home/amnesia/Persistent/swtorcfg/fullssh.arg | awk '{print $4}')
   arg5=$(cat /home/amnesia/Persistent/swtorcfg/fullssh.arg | awk '{print $5}')
   arg6=$(cat /home/amnesia/Persistent/swtorcfg/fullssh.arg | awk '{print $6}')
   arg7=$(cat /home/amnesia/Persistent/swtorcfg/fullssh.arg | awk '{print $7}')
   arg8=$(cat /home/amnesia/Persistent/swtorcfg/fullssh.arg | awk '{print $8}')
   arg9=$(cat /home/amnesia/Persistent/swtorcfg/fullssh.arg | awk '{print $9}')

else
    swtor_missing_arg
    exit 1
fi

if [ $arg1 != "fullssh.sh" ] ; then
   swtor_wrong_script
   exit 1
fi

if [ $arg3 != "Compress" ] ; then
   touch ~/Persistent/swtorcfg/log/ssh-command.log
   chain="-vv -E /home/amnesia/Persistent/swtorcfg/log/ssh-command.log -o ServerAliveInterval=10 -"
else
   touch ~/Persistent/swtorcfg/log/ssh-command.log
   chain="-vv -E /home/amnesia/Persistent/swtorcfg/log/ssh-command.log -o ServerAliveInterval=10 -C"
fi

if [ $arg4 == "4" ] ; then
    chain+="4"
fi

if [ $arg4 == "6" ] ; then
    swtor_no_ipv6
    exit 1
fi

if [ $arg5 != "2" ] ; then
    chain+="1 "
else
    chain+="2 "
fi

chain+="-p"
chain+=$arg6

# LocalPort :
# We have to decide here -> what we would like to to
# with this ssh connection
# -D 127.0.0.1:9999
#
# Create a local socks5 server and send
# all data to the remote server
#
# the other possible configuration is
# port redirection that would change the ssh-command
# from -D to -L
#
# -L 127.0.0.1:9999:172.29.255.1:8081
#
# Create a local socks5 server and
# redirect all traffic to a other
# socks5 server on the remote server
# on Port 8081
# As long you have a valid socks5 server
# connection on the remote server
# IP 172.29.255.1:8081
#
# It is not important -> how you create
# this second socks5 connection
# - with password
# - with keyy
# - with sshpass


chrlen=${#arg7}
if [ $chrlen -gt 6 ]; then
   chain+=" -L "
   chain+=$arg7
else
   chain+=" -D "
   chain+=$arg7
fi


if [ $arg8 == "noshell" ]
   then
    chain+=" -N "
    chain+=$arg9
fi


if [ $arg8 == "clock" ]
   then
   chain+=" -Y "
   chain+=$arg9
fi


if [ $arg8 == "clock" ]
   then
   xhost + > /dev/null
   chain+=" xclock -geometry "$XCLOCK_SIZE"x"$XCLOCK_SIZE"+85+5 &&  pkill ssh"
fi

# We define a new start option for the addon named clock1
# If we can start a simple X11 clock we can start any X11 program
# Note from 13/11/24
# Adding clock1 to start X11 session-messanger
# This feature remains hidden and undocumented until all tests are fine
# Note : All stored data for the session-messanger are stored on the
# remote host !!!!
# To send files to the remote server we have to use sshfs

if [ $arg8 == "clock1" ]
   then
   chain+=" -Y "
   chain+=$arg9
fi

if [ $arg8 == "clock1" ]
   then
   xhost + > /dev/null
   chain+=" session-desktop &&  pkill ssh"

   # We need to mount the remote user-directory over sshfs
   # or we can not send files over seesion

   ssh_mount="sshfs -p "
   ssh_mount+=$arg6
   ssh_mount+=" "
   ssh_mount+=$arg9
   ssh_mount+=": "
   ssh_mount+="/home/amnesia/Persistent/swtor-addon-to-tails/sshfs -o StrictHostKeyChecking=no"

   # script for mounting the remote fs

   echo $ssh_mount > ~/Persistent/swtor-addon-to-tails/tmp/sshfs-mount.sh
   chmod +x ~/Persistent/swtor-addon-to-tails/tmp/sshfs-mount.sh

   # script for umount the remote fs

   echo "umount /live/persistence/TailsData_unlocked/Persistent/swtor-addon-to-tails/sshfs" > ~/Persistent/swtor-addon-to-tails/tmp/sshfs-umount.sh
   chmod +x ~/Persistent/swtor-addon-to-tails/tmp/sshfs-umount.sh

fi


# is allready a ssh deamon running ?

ssh_pid=$(ps axu | grep ServerAliveInterval  | grep ssh  | awk '{print $2}')

if [ -z "$ssh_pid" ] ; then
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo starting ssh command
         echo $chain
      fi

      echo used command here
      echo ------------------------------------------
      echo ssh $chain
      echo arg1 [$arg1]
      echo arg2 [$arg2]
      echo arg3 [$arg3]
      echo arg4 [$arg4]
      echo arg5 [$arg5]
      echo arg6 [$arg6]
      echo arg7 [$arg7]
      echo arg8 [$arg8]
      echo arg9 [$arg9]
      echo ------------------------------------------

      # We start the ssh-process and send it directly into the background

      ssh $chain &

      show_wait_dialog && sleep 4

      # we loook on the current process table after the time out for ssh expires ...

      sleep $TIMEOUT_SSH

      ssh_pid=$(ps axu | grep ServerAliveInterval  | grep ssh  |awk '{print $2}')
      echo $ssh_pid  > ~/Persistent/swtor-addon-to-tails/tmp/watchdog_pid
      echo $$        > ~/Persistent/swtor-addon-to-tails/tmp/script_connect

      echo -------------------------
      echo we watch the following PID
      echo $ssh_pid
      echo -------------------------

      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo PID of encrypted ssh channel is $ssh_pid
      fi

      if [ -z "$ssh_pid" ] ; then
         if [ $TERMINAL_VERBOSE == "1" ] ; then
            echo "ssh connection was not made"
         fi
         echo 1 > /home/amnesia/Persistent/scripts/state/error
         end_wait_dialog && sleep 1
         swtor_ssh_failure
         exit 1
      fi

      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo ssh command succesfull executed
      fi

      # Do we need to mount the remote fs ?

      if [ -f ~/Persistent/swtor-addon-to-tails/tmp/sshfs-mount.sh ] ; then

         cd ~/Persistent/swtor-addon-to-tails/tmp
         ./sshfs-mount.sh

         # remove this script

         rm ~/Persistent/swtor-addon-to-tails/tmp/sshfs-mount.sh
      fi


      echo 1 > /home/amnesia/Persistent/scripts/state/online

      if [ -f /home/amnesia/Persistent/scripts/state/offline ] ; then
         rm  /home/amnesia/Persistent/scripts/state/offline
      fi

      end_wait_dialog && sleep 1
      swtor_ssh_success

      # Here we signal the watchdog script to terminate the current connection

      echo $ssh_pid  > ~/Persistent/swtor-addon-to-tails/tmp/close__request
      echo $arg9     >> ~/Persistent/swtor-addon-to-tails/tmp/close__request


      # In the case of clock -> xhost -

      if [ $arg8 == "clock" ] ; then
         xhost -
      fi

      # In the case of clock1 -> xhost -

      if [ $arg8 == "clock1" ] ; then
         xhost -

         cd ~/Persistent/swtor-addon-to-tails/tmp
         ./sshfs-umount.sh

         # remove this script

         rm ~/Persistent/swtor-addon-to-tails/tmp/sshfs-umount.sh

      fi

fi

swtor_cleanup
exit 0

