#!/bin/bash
#########################################################
# SCRIPT  : selector.sh                                 #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.11 or higher                        #
# TASKS   : select ssh-server to use                    #
#                                                       #
# VERSION : 0.50                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 02-01-2020                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################

# Check to see if TOR is allready runnig ....

curl --socks5 localhost:9050 --socks5-hostname localhost:9050 -s https://check.torproject.org/ | cat | grep -m 1 Congratulations
if [ $? -eq 0 ] ; then
   echo TOR is running and we can continue with the execution of the script ....
else
  sleep 4 | tee >(zenity --progress --pulsate --no-cancel --auto-close --text="TOR Network is not ready !" > /dev/null 2>&1)
  exit 1
fi


# if the .ssh directory is empty ....  We could assume the follwing.
# This tails never contacted any ssh-system -> No Keys -> No known_hosts
# Or the persistent option for ssh-client is not set properly...

if [ -z "$(ls -A /home/amnesia/.ssh )" ]; then
   zenity --info --width=600 --text="The directory /home/amnesia/.ssh is empty !"  > /dev/null 2>&1
   exit 1
else
   echo ssh directory contains data
fi


ssh_pid=$(ps axu | grep ServerAliveInterval  | grep ssh  | awk '{print $2}')
if [ -z "$ssh_pid" ]
then
    echo No active ssh-connection found.
else
    zenity --info --width=600 --text="There is allready a ssh-connection ! Pleaase close the other connection."  > /dev/null 2>&1
    exit 1
fi

cd /home/amnesia/Persistent/scripts/

if [ ! -f /home/amnesia/Persistent/swtorcfg/swtorssh.cfg ]
then
        zenity --info --width=600 --text="Configuration file ~/Persistent/swtorcfg/swtorssh.cfg was not found !"  > /dev/null 2>&1
        exit 1
fi

# Cleanup old files

rm -rf /home/amnesia/Persistent/swtorcfg/*.arg > /dev/null 2>&1
rm -rf /home/amnesia/Persistent/swtorcfg/log/*.* > /dev/null 2>&1


# Extract the default directorys 1 & 2

cd ~/Persistent/settings
tar xzf tmp.tar.gz
cd ~/Persistent/scripts

account=$(zenity --width=800 --height=400 --list --title "Please seleect the ssh-connection" \
          --column "Script" \
          --column "login with" \
          --column "Compress" \
          --column "IP" \
          --column "Version" \
          --column "Port" \
          --column "Local Port" \
          --column "Execute" \
          --column "ssh userlogin" \
          --column "res." \
          --column "Backup" \
          --column "Destination country" \
          --column "Addional description" \
          --hide-column=3,4,5,7,8,10,11 \
          --print-column=1,9,2 $(tr , \\n < ../swtorcfg/swtorssh.cfg))

selection=$(echo $account)
if [ "$selection" == "" ] ; then
    zenity --error --width=600 --text "No selection was made !"
    exit 1
fi

# Right now, we have to decide what kind of connection we would like to use

tmp=$(echo $account | tr "|" " ")
arg1=$(echo $tmp | awk '{print $1}')
arg2=$(echo $tmp | awk '{print $2}')
arg3=$(echo $tmp | awk '{print $3}')


# echo $arg1
# echo $arg2
# echo $arg3

if [ $arg1 == "fullssh.sh" ] ; then
   if [ $arg3 == "ssh-id" ] ; then
       grep fullssh.sh ~/Persistent/swtorcfg/swtorssh.cfg | grep $arg2 > ~/Persistent/swtorcfg/fullssh.arg

       # We start the little python-code to execute

        touch ~/Persistent/swtorcfg/log/ssh-command.log
       ./1.sh > ~/Persistent/swtorcfg/log/ssh-log.log 2>&1 &
   else
       password=$(zenity --entry --width=600 --text="Password for the ssh-connection ? " --title=Password --hide-text)
       echo $password > /home/amnesia/Persistent/swtorcfg/ssh-interactive.arg
       chmod 600 /home/amnesia/Persistent/swtorcfg/ssh-interactive.arg
       if [ "$password" == "" ] ; then
           zenity --error --width=600 --text "No password provided on the keyboard !"
           exit 1
       else
           echo ... we have a password
       fi

       grep fullssh.sh ~/Persistent/swtorcfg/swtorssh.cfg | grep $arg2 > ~/Persistent/swtorcfg/fullssh.arg

       # We start the little python-code to execute

        touch ~/Persistent/swtorcfg/log/ssh-command.log
       ./2.sh > ~/Persistent/swtorcfg/log/ssh-log.log 2>&1 &
   fi
fi


if [ $arg1 == "chainssh.sh" ] ; then

   if [ $arg3 == "ssh-id" ] ; then
       grep chainssh.sh ~/Persistent/swtorcfg/swtorssh.cfg | grep $arg2 > ~/Persistent/swtorcfg/chainssh.arg

       # We start the little python-code to execute

        touch ~/Persistent/swtorcfg/log/ssh-command.log
       ./3.sh > ~/Persistent/swtorcfg/log/ssh-log.log 2>&1 &
   else
       zenity --error --width=600 --text "Only ssh-id authentification ist valid in chaimode of swtor !"
       exit 1
   fi
fi


if [ $arg1 == "pfssh.sh" ] ; then
   if [ $arg3 == "passwd" ] ; then
       password=$(zenity --entry --width=600 --text="Password for the ssh-connection ? " --title=Password --hide-text)
       echo $password > /home/amnesia/Persistent/swtorcfg/ssh-interactive.arg
       chmod 600 /home/amnesia/Persistent/swtorcfg/ssh-interactive.arg
       if [ "$password" == "" ] ; then
           zenity --error --width=600 --text "No password provided on the keyboard !"
           exit 1
       else
           echo ... we have a password
       fi

       grep pfssh.sh ~/Persistent/swtorcfg/swtorssh.cfg | grep $arg2 > ~/Persistent/swtorcfg/pfssh.arg

       # We start the little python-code to execute

       touch ~/Persistent/swtorcfg/log/ssh-command.log
       ./4.sh > ~/Persistent/swtorcfg/log/ssh-log.log 2>&1 &
    else
       zenity --error --width=600 --text "The script pfssh.sh only supports password-logins !"
       exit
    fi
fi


sleep 2

exit 0
