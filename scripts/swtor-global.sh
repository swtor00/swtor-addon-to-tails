#/bin/bash
#########################################################
# SCRIPT  : swtor-global.sh                             #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.24 or higher                        #
#                                                       #
#                                                       #
# VERSION : 0.60                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 01-11-21                                    #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################



check_tor_network() {

# Check to see if the ONION Network is allready runnig ....

if [ $TERMINAL_VERBOSE == "1" ] ; then
     echo testing the internet-connection over the onion-network with TIMEOUT $TIMEOUT_TB
fi

curl --socks5 localhost:9050 --socks5-hostname localhost:9050 -s https://check.torproject.org/ -m $TIMEOUT_TB | grep -m 1 Congratulations > /dev/null 2>&1

if [ $? -eq 0 ] ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "TOR is up and running and we can continue with the execution of the script ...."
   fi
   sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
   --text="\n\n               Testing the Internet connection over TOR was successful !          \n\n" > /dev/null 2>&1)

else
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "TOR is not ready"
      echo >&2 "check_tor_network() exiting with error-code 1"
   fi
   zenity --error --width=600 \
   --text="\n\n               Internet not ready or no active connection found ! \nPlease make a connection to the Internet first and try it again ! \n\n"\
    > /dev/null 2>&1
   return 1
fi
return 0
}



test_ssh_persistent() {

if (! -f /Persistent/swtor-addon-to-tails/tmp/mounted )
    mount > /Persistent/swtor-addon-to-tails/tmp/mounted
else
   mount > /Persistent/swtor-addon-to-tails/tmp/mounted
fi

if grep -q "/home/amnesia/.ssh" /Persistent/swtor-addon-to-tails/tmp/mounted ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo we have .ssh mounted
    fi
else
   zenity --error --width=600 \
   --text="\n\n         This addon needs the ssh option inside of the persistent volume.\n         You have to set this option first ! \n\n" \
    > /dev/null 2>&1



    zenity --error --width=600 --text="\n\nThis addon needs the ssh option inside of the persistent volume.\nYou have to set this option first and restart Ta$
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "~/.ssh is not persistent !"
    fi
    exit 1
fi

}











export -f check_tor_network
export -f test_ssh_persistent

















