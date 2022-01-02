#!/bin/bash
#########################################################
# SCRIPT  : pfssh-interactive.sh                        #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.25 or higher                        #
# TASKS   : run a ssh command with multipe options      #
#           almost the same like fullssh.sh with the    #
#           only difference that the password will be   #
#           given over sshpass.                         #
#                                                       #
# VERSION : 0.60                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 31-12-21                                    #
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
       echo >&2 "pfssh.sh exiting with error-code 1"
    fi
    exit 1
fi

# If there was error in the last connection, we kill the file

rm /home/amnesia/Persistent/scripts/state/error > /dev/null 2>&1



# Test needet parameters for this script

if [ -f /home/amnesia/Persistent/swtorcfg/pfssh.arg ]
   then

   arg1=$(cat /home/amnesia/Persistent/swtorcfg/pfssh.arg  | awk '{print $1}')
   arg2=$(cat /home/amnesia/Persistent/swtorcfg/pfssh.arg  | awk '{print $2}')
   arg3=$(cat /home/amnesia/Persistent/swtorcfg/pfssh.arg  | awk '{print $3}')
   arg4=$(cat /home/amnesia/Persistent/swtorcfg/pfssh.arg  | awk '{print $4}')
   arg5=$(cat /home/amnesia/Persistent/swtorcfg/pfssh.arg  | awk '{print $5}')
   arg6=$(cat /home/amnesia/Persistent/swtorcfg/pfssh.arg  | awk '{print $6}')
   arg7=$(cat /home/amnesia/Persistent/swtorcfg/pfssh.arg  | awk '{print $7}')
   arg8=$(cat /home/amnesia/Persistent/swtorcfg/pfssh.arg  | awk '{print $8}')
   arg9=$(cat /home/amnesia/Persistent/swtorcfg/pfssh.arg  | awk '{print $9}')

else
    swtor_missing_arg
    exit 1
fi

if [ -f /home/amnesia/Persistent/swtorcfg/ssh-interactive.arg ] ; then

   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo We found a password-file that should contain the password to the host
   fi
  password=$(cat ~/Persistent/swtorcfg/ssh-interactive.arg)
else
    swtor_missing_password
    exit 1
fi

if [ $arg1 != "pfssh.sh" ] ; then
   swtor_wrong_script
   exit 1
fi

if [ $arg3 != "Compress" ] ; then
   chain="-vv -E /home/amnesia/Persistent/swtorcfg/log/ssh-command.log -o ServerAliveInterval=10 -"
else
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

# LocalPort

chain+=" -D "
chain+=$arg7

if [ $arg8 == "noshell" ] ; then
    chain+=" -N"
else
   zenity --info --width=600  --title="Information" \
   --text="\n\n    pfssh.sh mode only support 'noshell' in ssh command  !           \n\n"  > /dev/null 2>&1
   exit 1
fi

chain+=" "
chain+=$arg9

# is allready a ssh deamon running ?

ssh_pid=$(ps axu | grep ServerAliveInterval  | grep ssh  | awk '{print $2}')

if [ -z "$ssh_pid" ] ; then 

      if [ $TERMINAL_VERBOSE == "1" ] ; then  
         echo starting ssh command
         echo $chain
      fi

      # We start the ssh-process and send it directly into the background

      sshpass -p $password ssh $chain  &

      show_wait_dialog && sleep 4

      # we loook on the process table after the time out for ssh expires ...

      sleep $TIMEOUT_SSH

      ssh_pid=$(ps axu | grep ServerAliveInterval  | grep sshpass  |awk '{print $2}')
      echo $ssh_pid  > ~/Persistent/swtor-addon-to-tails/tmp/watchdog_pid
      echo $$        > ~/Persistent/swtor-addon-to-tails/tmp/script_connect

      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo PID of encrypted ssh channel is $ssh_pid
      fi

      if [ -z "$ssh_pid" ] ; then
         if [ $TERMINAL_VERBOSE == "1" ] ; then
            echo "ssh connection was not made"
            echo "the provided password maybe was wrong"
            echo "or the ssh-login is expired by date"
         fi
         echo 1 > /home/amnesia/Persistent/scripts/state/error
         end_wait_dialog && sleep 1
         swtor_ssh_failure
         exit 1
      fi

      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo ssh command succesfull executed
      fi

      echo 1 > /home/amnesia/Persistent/scripts/state/online

      if [ -f /home/amnesia/Persistent/scripts/state/offline ] ; then
         rm  /home/amnesia/Persistent/scripts/state/offline
      fi

      end_wait_dialog && sleep 1
      swtor_ssh_success

      # Here we signal the watchdog script to terminate the current connection

      echo $ssh_pid   > ~/Persistent/swtor-addon-to-tails/tmp/close__request
      echo $arg9     >> ~/Persistent/swtor-addon-to-tails/tmp/close__request

fi


swtor_cleanup
exit 0


