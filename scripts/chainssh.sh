#!/bin/bash
#########################################################
# SCRIPT  : chainssh.sh                                 #
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

# Test all needet parameters for this script

if [ -f /home/amnesia/Persistent/swtorcfg/chainssh.arg ]
   then

   arg1=$(cat /home/amnesia/Persistent/swtorcfg/chainssh.arg | awk '{print $1}')
   arg2=$(cat /home/amnesia/Persistent/swtorcfg/chainssh.arg | awk '{print $2}')
   arg3=$(cat /home/amnesia/Persistent/swtorcfg/chainssh.arg | awk '{print $3}')
   arg4=$(cat /home/amnesia/Persistent/swtorcfg/chainssh.arg | awk '{print $4}')
   arg5=$(cat /home/amnesia/Persistent/swtorcfg/chainssh.arg | awk '{print $5}')
   arg6=$(cat /home/amnesia/Persistent/swtorcfg/chainssh.arg | awk '{print $6}')
   arg7=$(cat /home/amnesia/Persistent/swtorcfg/chainssh.arg | awk '{print $7}')
   arg8=$(cat /home/amnesia/Persistent/swtorcfg/chainssh.arg | awk '{print $8}')
   arg9=$(cat /home/amnesia/Persistent/swtorcfg/chainssh.arg | awk '{print $9}')
   arg10=$(cat /home/amnesia/Persistent/swtorcfg/chainssh.arg | awk '{print $10}')
   arg13=$(cat /home/amnesia/Persistent/swtorcfg/chainssh.arg | awk '{print $13}')


else
    zenity --info  -width=600 --text="No arhuments supplied with chainssh.arg or this file do not exist !"  > /dev/null 2>&1
    exit 1
fi


if [ ! -f /home/amnesia/Persistent/swtorcfg/$arg13 ]
then
       zenity --info -width=600 --text="Chain-configuration file not found inside ~/Persistent/swtorcfg !"  > /dev/null 2>&1
       echo file $arg13 not found inside of ~/Persistent/swtorcfg
       exit 1
fi

if [ $arg1 != "chainssh.sh" ] ;
   then
   zenity --info -width=600 --text="Wrong script definition inside fullssh.arg !"  > /dev/null 2>&1
   exit 1
fi


if [ $arg3 != "Compress" ] ; then
   chain="-v -E /home/amnesia/Persistent/swtorcfg/log/ssh-command.log -o ServerAliveInterval=10 -At"
else
   chain="-v -E /home/amnesia/Persistent/swtorcfg/log/ssh-command.log -o ServerAliveInterval=10 -AtC"
fi

if [ $arg4 == "4" ] ; then
    chain+="4"
fi

if [ $arg4 == "6" ] ; then
    zenity --info -width=600 --text="IP V6 can not be used !"  > /dev/null 2>&1
    exit 1
fi

if [ $arg5 != "2" ] ; then
    chain+="1 "
else
    chain+="2 "
fi

# Remote Port

chain+="-p "
chain+=$arg6
port=$arg6

# LocalPort

chain+=" -L:"
chain+=$arg7
chain+=":localhost:$arg10"


if [ $arg8 != "chain" ] ; then
    echo wrong argument inside chainssh.arg
fi

chain+=" "
chain+=$arg9

command1+=$chain
command2=$(cat ~/Persistent/swtorcfg/$arg13)

# One thing is very important :
# In the case we would like to close the complete connection
# we have to send a kill -9 to the remote host1 or the local
# port 11000 remains closed for future connections

username=$(echo $arg9 | tr "@" " " | awk '{print $1}')
command3="sleep 2 |  pkill -u $username ssh"


# is allready a ssh deamon running ?

ssh_pid=$(ps axu | grep ServerAliveInterval  | grep ssh  | awk '{print $2}')

if [ -z "$ssh_pid" ]
   then
      echo starting ssh command
      echo $command1 $command2
      ssh $command1 \
          $command2 &

      # we loook on the processes

      sleep 5

      ssh_pid=$(ps axu | grep ServerAliveInterval  | grep ssh  |awk '{print $2}')
      echo PID of encrypted ssh channel is $ssh_pid

      if [ -z "$ssh_pid" ]
          then
          zenity --info -width=600 --text "ssh isn't active ! Script do exit now. "
          exit 1
      fi

      echo ssh command succesfull executed
      echo 1 > /home/amnesia/Persistent/scripts/state/online

      if [ -f /home/amnesia/Persistent/scripts/state/offline ]
         then
         rm  /home/amnesia/Persistent/scripts/state/offline
      fi

      zenity --info --width=600 --text "The encrypted ssh connection over the onion-network is now active.\nTo close this connection,please press the ok button on this window !"

      # over ssh we send a kill -9 signal to ssh host1 , to relase port 11000 on host1

      ssh -p $port $arg9 \
             $command3 &
      sleep 2

      ssh_pid=$(ps axu | grep ServerAliveInterval | grep ssh | awk '{print $2}')

      if [ -z "$ssh_pid" ]
         then
          echo local ssh daemon allready gone into the darkness
      else
          kill -9 $ssh_pid
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


