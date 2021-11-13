#!/bin/bash
#########################################################
# SCRIPT  : selector.sh                                 #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.24 or higher                        #
# TASKS   : select ssh-server to use                    #
#                                                       #
# VERSION : 0.60                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 01-05-2020                                  #
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


# Check for the main configuration file for this addon

if [ ! -f /home/amnesia/Persistent/swtorcfg/swtorssh.cfg ] ; then
   zenity --info --width=600 title="Information" --text="\n\nConfiguration file ~/Persistent/swtorcfg/swtorssh.cfg was not found ! \n\n"  > /dev/null 2>&1
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "configuration file ~/Persistent/swtorcfg/swtorssh.cfg was not found !"
   fi
   exit 1
fi


ssh_pid=$(ps axu | grep ServerAliveInterval  | grep ssh  | awk '{print $2}')
if [ -z "$ssh_pid" ]
then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "no currently used ssh-connection was found."
   fi
else
    zenity --info --width=600 title="Information" --text="\n\nThere is allready a active connection ! Pleaase close the other connection first.\n\n"  > /dev/null 2>&1
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "we found a active comnnection.this connection needs to be closed."
    fi
    exit 1
fi


cd /home/amnesia/Persistent/scripts/

# Cleanup old files

rm -rf /home/amnesia/Persistent/swtorcfg/*.arg > /dev/null 2>&1
rm -rf /home/amnesia/Persistent/swtorcfg/log/*.* > /dev/null 2>&1

# Extract the default directorys 1 & 2

cd ~/Persistent/settings

tar xzf tmp.tar.gz > /dev/null 2>&1
cd ~/Persistent/scripts

account=$(zenity --width=800 --height=400 --list --title "Please select the desired ssh-connection" \
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
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "no selection for a ssh-server was made"
    fi
    exit 1
fi


# Right now, we have to decide what kind of connection we would like to use

tmp=$(echo $account | tr "|" " ")
arg1=$(echo $tmp | awk '{print $1}')
arg2=$(echo $tmp | awk '{print $2}')
arg3=$(echo $tmp | awk '{print $3}')

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
