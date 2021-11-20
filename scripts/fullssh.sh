#!/bin/bash
#########################################################
# SCRIPT  : fullssh.sh                                  #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.24  or higher                       #
# TASKS   : run a ssh command with multipe options      #
#                                                       #
# VERSION : 0.60                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 17-11-2021                                  #
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

export TIMEOUT_TB=$(grep TIMEOUT-TB ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg | sed 's/[A-Z:-]//g')
export TIMEOUT_SSH=$(grep TIMEOUT-SSH ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg | sed 's/[A-Z:-]//g')

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


# Test needet parameters for this script

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
    zenity --info  --text="File fullssh.arg do not exist !"  > /dev/null 2>&1
    exit 1
fi

if [ $arg1 != "fullssh.sh" ] ; then
   zenity --info --width=600 --text="Wrong script definition inside fullssh.arg !"  > /dev/null 2>&1
   exit 1
fi

if [ $arg3 != "Compress" ] ; then
   chain="-v -E /home/amensia/Persistent/swtorcfg/log/ssh-command.log -o ServerAliveInterval=10 -"
else
   chain="-v -E /home/amnesia/Persistent/swtorcfg/log/ssh-command.log -o ServerAliveInterval=10 -C"
fi

if [ $arg4 == "4" ] ; then
    chain+="4"
fi

if [ $arg4 == "6" ] ; then
    zenity --info --width=600 --text="IP V6 can not be used !"  > /dev/null 2>&1
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

if [ $arg8 == "NoShell" ]
   then
    chain+=" -N "
fi


if [ $arg8 == "clock" ]
   then
   chain+=" -X "
fi


chain+=$arg9


if [ $arg8 == "clock" ]
   then
   xhost +
   chain+=" xclock -geometry 150x150+85+5"
fi

# is allready a ssh deamon running ?

ssh_pid=$(ps axu | grep ServerAliveInterval  | grep ssh  | awk '{print $2}')

if [ -z "$ssh_pid" ]
then
      echo starting ssh command
      echo $chain
      ssh $chain &

      show_wait_dialog && sleep 4

      # we loook on the processes after the time out for ssh expires ...

      sleep $TIMEOUT_SSH

      ssh_pid=$(ps axu | grep ServerAliveInterval  | grep ssh  |awk '{print $2}')
      echo PID of encrypted ssh channel is $ssh_pid

      if [ -z "$ssh_pid" ] ; then
          end_wait_dialog && sleep 1  
          zenity --info --width=600  --title="Information" --text="\n\nThe desired SSH connection could not be made ! \nPlease have a closer look to the log-files inside of ~/Persistent/swtorcfg/log ! \n\n"
          exit 1
      fi

      echo ssh command succesfull executed
      echo 1 > /home/amnesia/Persistent/scripts/state/online

      if [ -f /home/amnesia/Persistent/scripts/state/offline ]
         then
         rm  /home/amnesia/Persistent/scripts/state/offline
      fi

      end_wait_dialog && sleep 1
      zenity --info  --width=600 --title="Information" --text="\n\nThe selected SSH connection is now active. \nTo close this connection, please press the 'OK' button on this window ! \n\n"
      sleep 1

      ssh_pid=$(ps axu | grep ServerAliveInterval | grep ssh | awk '{print $2}')

      kill -9 $ssh_pid

      if [ $arg8 == "clock" ]
         then
         xhost -
      fi

      rm  /home/amnesia/Persistent/scripts/state/online

      /home/amnesia/Persistent/scripts/cleanup.sh

      echo 1 > /home/amnesia/Persistent/scripts/state/offline
else
      echo cancel ...
      sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="Connection allready estabishled !" > /dev/null 2>&1)
      exit 1
fi

swtor_cleanup
exit 0


