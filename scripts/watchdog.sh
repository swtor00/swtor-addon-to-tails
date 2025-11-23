#!/bin/bash
#########################################################
# SCRIPT  : watchdog.sh                                 #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 7.2 or higher                         #
#                                                       #
# VERSION : 0.90                                        #
# STATE   : Beta                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 15-11-2025                                  #
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

rm ~/Persistent/swtor-addon-to-tails/tmp/pid_loop > /dev/null 2>&1

menu=1
while [ $menu -gt 0 ]; do

      if [ -f /home/amnesia/Persistent/scripts/state/offline ]  ; then
         sleep 2
#        if [ $TERMINAL_VERBOSE == "1" ] ; then
#           echo watchdog state : offline
#        fi
      fi

      if [ -f /home/amnesia/Persistent/scripts/state/online ]  ; then

         sleep 0.7

         ssh_pid=$(cat ~/Persistent/swtor-addon-to-tails/tmp/watchdog_pid)
         running=$(ps axu | awk {'print $2'} | grep $(echo $ssh_pid))


         sleep 0.4
         echo $(date) running pid $running  controlled pid $ssh_pid >> ~/Persistent/swtor-addon-to-tails/tmp/pid_loop

         if [ "$running" == "$ssh_pid" ] ; then
            if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo watchdog state : online  pid ssh $ssh_pid is running
            fi
         else

             # prior to kill the complete SSH connection, we would like to be sure,
             # that the socks5 proxy isn't running longer
             # If curl returns a value 0 -> socks5 proxy is running
             # If curl returns a value !=0 -> socks5 proxy is not running -> We kill the connection

             curl --socks5 127.0.0.1:9999 -m 8 https://www.google.com  > /dev/null 2>&1

             if [ $? -eq 0 ] ; then
             #   if [ $TERMINAL_VERBOSE == "1" ] ; then
             #      echo watchdog state is wrong : online pid ssh $ssh_pid is still running
             #   fi
                echo
             else

                 # Our SSH conection to the remote System was terminated unexpected !!

                 #if [ $TERMINAL_VERBOSE == "1" ] ; then
                 #   echo error : pid ssh [$ssh_pid] is not longer running !!!!
                 #fi

                 # We have to close the active connection script and inform the user
                 # about the termination.Only one connection script of the 4
                 # possible scripts can be active at any time
                 # fullssh.sh fullssh-interactive.sh pfss-interactive.sh chainssh.sh

                 shellcode_pid=$(cat ~/Persistent/swtor-addon-to-tails/tmp/script_connect)

                 # We have to close the active window

                 kill -9  $(ps axu | grep zenity | grep close | awk {'print $2'})

                 # And as a final step we kill the SSH connection-script itself

                 kill -9 $shellcode_pid  > /dev/null 2>&1

                 zenity --info --width=600 --title="Connection lost" \
                 --text="\n\n   [  The active SSH-Connection was running and have ben terminated unexpected !  ]   \n\n   "


                 sleep 0.7

                 rm  /home/amnesia/Persistent/scripts/state/online > /dev/null  2>&1

                 /home/amnesia/Persistent/scripts/cleanup.sh

                 echo 1 > /home/amnesia/Persistent/scripts/state/offline

                 rm ~/Persistent/swtor-addon-to-tails/tmp/close__request > /dev/null  2>&1

                 xhost - > /dev/null  2>&1

                 rm ~/Persistent/swtor-addon-to-tails/tmp/pid_loop > /dev/null 2>&1

                 # And here comes the question ... to kill or not to kill
                 # This is depending on the configuration file

                 if [ $AUTOCLOSE_BROWSER="1" ] ; then

                    #if [ $TERMINAL_VERBOSE == "1" ] ; then
                    #   echo autoclose is activated !
                    #fi

                    kill -9 $(ps axu | grep chromium | grep settings | awk {'print $2'}) > /dev/null  2>&1
                    kill -9 $(ps axu | grep chromium | grep personal-files | awk {'print $2'}) > /dev/null 2>&1
                 else
                    if [ $TERMINAL_VERBOSE == "1" ] ; then
                       echo autoclose is not activated !
                    fi
                 fi
             fi
         fi


         if [ -f ~/Persistent/swtor-addon-to-tails/tmp/close__request ] ; then

            # Kill the SSH connection normal by the user  -> The users requested to terminate the
            # SSH-Connection  by pressing "Close SSH Connection" on the Connection Window

            kill -9 $ssh_pid

            rm  /home/amnesia/Persistent/scripts/state/online

            /home/amnesia/Persistent/scripts/cleanup.sh

            echo 1 > /home/amnesia/Persistent/scripts/state/offline

            rm ~/Persistent/swtor-addon-to-tails/tmp/close__request

            xhost - > /dev/null  2>&1

            rm ~/Persistent/swtor-addon-to-tails/tmp/pid_loop > /dev/null 2>&1
         fi
      fi
      ((menu++))
done

exit 0

