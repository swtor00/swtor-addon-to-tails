#!/bin/bash
#########################################################
# SCRIPT  : watchdog.sh                                 #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.25 or higher                        #
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

cd ~/Persistent/swtor-addon-to-tails/tmp

if [ $AUTOCLOSE_BROWSER="1" ] ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo AUTOCLOSE is set to be ON
  fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo AUTOCLOSE is set to be OFF
    fi
fi


menu=1
while [ $menu -gt 0 ]; do
      if [ -f /home/amnesia/Persistent/scripts/state/offline ]  ; then
         sleep 1
         if [ $TERMINAL_VERBOSE == "1" ] ; then
            echo watchdog state : offline
         fi
      fi

      if [ -f /home/amnesia/Persistent/scripts/state/online ]  ; then

         sleep 0.5

         ssh_pid=$(cat ~/Persistent/swtor-addon-to-tails/tmp/watchdog_pid)

         running=$(ps axu | awk {'print $2'} | grep $(echo $ssh_pid))

         if [ "$running" == "$ssh_pid" ] ; then
            if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo watchdog state : online  pid ssh $ssh_pid is running
            fi
         else

             # Our SSH conection to the remote System was terminated unexpected !!

             if [ $TERMINAL_VERBOSE == "1" ] ; then
                echo error : pid ssh [$ssh_pid] is not longer running !!!!
             fi

             # We have to close the active connection script and inform the user
             # about the termination.Only one connection script of the 4
             # possible scripts can be active at any time
             # fullssh.sh fullssh-interactive.sh pfss-interactive.sh chainssh.sh

             shellcode_pid=$(cat ~/Persistent/swtor-addon-to-tails/tmp/script_connect)


             # We have to close the zenity window that us shows we have a valid connection

             kill -9  $(ps axu | grep zenity | grep close | awk {'print $2'})

             # And as a final kill the connection-script itself

             kill -9 $shellcode_pid

             zenity --info --width=600 --title="Connection lost" \
             --text="\n\n   [  The active SSH-Connection was running and have ben terminated unexpected !  ]   \n\n   "

             sleep 0.7

             rm  /home/amnesia/Persistent/scripts/state/online > /dev/null  2>&1

             /home/amnesia/Persistent/scripts/cleanup.sh

             echo 1 > /home/amnesia/Persistent/scripts/state/offline

             rm ~/Persistent/swtor-addon-to-tails/tmp/close__request > /dev/null  2>&1

             xhost - > /dev/null  2>&1

             # And here comes the question ... to kill or not to kill
             # This is depending on the configuration file

             if [ $AUTOCLOSE_BROWSER="1" ] ; then
                kill -9 $(ps axu | grep chromium | grep settings | awk {'print $2'}) > /dev/null  2>&1
                kill -9 $(ps axu | grep chromium | grep personal-files | awk {'print $2'}) > /dev/null 2>&1
             fi

         fi


         if [ -f ~/Persistent/swtor-addon-to-tails/tmp/close__request ] ; then

            # Kill the SSH connection normal by the user  -> The users requested to terminate the
            # SSH-Connection  by pressing "OK" on the Connection Window

            kill -9 $ssh_pid

            rm  /home/amnesia/Persistent/scripts/state/online

            /home/amnesia/Persistent/scripts/cleanup.sh

            echo 1 > /home/amnesia/Persistent/scripts/state/offline

            rm ~/Persistent/swtor-addon-to-tails/tmp/close__request

            xhost - > /dev/null  2>&1

         fi
      fi
      ((menu++))
done

exit 0

