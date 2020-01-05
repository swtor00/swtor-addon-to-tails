#!/bin/bash
#########################################################
# SCRIPT  : fullssh.sh                                  #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.1.1 or higher                       #
# TASKS   : run a ssh command with multipe options      #
#                                                       #
# VERSION : 0.51                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 05-01-2020                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################

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

      # we loook on the processes

      sleep 4

      ssh_pid=$(ps axu | grep ServerAliveInterval  | grep ssh  |awk '{print $2}')
      echo PID of encrypted ssh channel is $ssh_pid

      if [ -z "$ssh_pid" ]
      then
          zenity --info --width=600 --text "ssh connection isn't active ! Script do exit now. Logs are inside of swtorcfg/log ! "
          exit 1
      fi

      echo ssh command succesfull executed
      echo 1 > /home/amnesia/Persistent/scripts/state/online

      if [ -f /home/amnesia/Persistent/scripts/state/offline ]
         then
         rm  /home/amnesia/Persistent/scripts/state/offline
      fi

      zenity --info  --width=600 --text "The encrypted ssh connection over the onion-network is now active.\nTo close this connection,please press the ok button on this window !"
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

exit 0


