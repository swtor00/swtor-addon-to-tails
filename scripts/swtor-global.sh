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

if [ "$TERMINAL_VERBOSE" == "" ];then
   echo "this shell-script can not longer direct executed over the terminal."
   echo "you have to call this shell-script over swtor-menu.sh or swtor-setup.sh"
   exit 1
fi


global_init() {
  if [ $TERMINAL_VERBOSE == "1" ] ; then
     echo "starting initialisation global_init() "
  fi

  # We have to decide where all temp files are stored.

  if [ ! -d ~/Persistent/swtor-addon-to-tails/tmp ] ; then

      # We are runnig  this script from a restored-backup

      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo "setting temporary global_init to ~/Persistent/tmp"
      fi


      export global_standard="0"
      export global_tmp="/home/amnesia/Persistent/tmp"
  else
      # We are runnig this script under controll of the addon itself

      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo "setting temporary global_init to ~/Persistent/swtor-addon-to-tails/tmp"
      fi
      export global_standard="1"
      export global_tmp="/home/amnesia/Persistent/swtor-addon-to-tails/tmp"
  fi


  if [ $TERMINAL_VERBOSE == "1" ] ; then
     echo "initialisation complete global_init() "
  fi
  return 0
}



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

   if [ "$DEBUGW" == "1" ] ; then
      pid_to_kill=$(ps axu | grep zenity | grep wait | awk {'print $2'})
      echo wait_dialog 01 with PID $pid_to_kill will be killed
   fi

   # We have a open dialog to close

   end_wait_dialog

   sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
   --text="\n\n               Testing the Internet connection over TOR was successful !          \n\n" > /dev/null 2>&1)

   curl -socks5 localhost:9050 --socks5-hostname localhost:9050 -s https://github.com/swtor00/swtor-addon-to-tails/blob/master/tmp/tic_tac -m3  > /dev/null 2>&1

else
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo >&2 "TOR is not ready"
      echo >&2 "check_tor_network() exiting with error-code 1"
   fi

   if [ "$DEBUGW" == "1" ] ; then
      pid_to_kill=$(ps axu | grep zenity | grep wait | awk {'print $2'})
      echo wait_dialog 01 with PID $pid_to_kill will be killed
   fi

   # We have a open dialog to close

   end_wait_dialog

   zenity --error --width=600 \
   --text="\n\n               Internet not ready or no active connection found ! \nPlease make a connection to the Internet first and try it again ! \n\n"\
    > /dev/null 2>&1
   return 1
fi
return 0
}



test_ssh_persistent() {

cd ${global_tmp}
mount > mounted

if grep -q "/home/amnesia/.ssh" mounted ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "we have .ssh mounted"
    fi
else

   # We have a open dialog to close

   end_wait_dialog

   zenity --error --width=600 \
   --text="\n\n         This addon needs the ssh option inside of the persistent volume.\n         You have to set this option first ! \n\n" \
    > /dev/null 2>&1
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "~/.ssh is not persistent !"
    fi
    return 1
fi
rm mounted > /dev/null 2>&1
return 0
}



test_software_persistent() {

cd ${global_tmp}
mount > mounted

if grep -q "/var/cache/apt/archives" ~/Persistent/swtor-addon-to-tails/tmp/mounted ; then
     if [ $TERMINAL_VERBOSE == "1" ] ; then
        echo "we have additional software active"
     fi
else

   # We have a open dialog to close

   end_wait_dialog

   zenity --error --width=600 \
   --text="\n\n         This addon needs the additional software option inside of the persistent volume.\n         You have to set this option first ! \n\n" \
    > /dev/null 2>&1
    if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo "additional software is not active"
    fi
    return 1
fi
rm mounted > /dev/null 2>&1
return 0
}


test_password_greeting() {

cd ${global_tmp}

# on every startup of Tails we need a administration password, or the addon will not work properly

echo _123UUU__ | sudo -S /bin/bash > test_admin 2>&1

if grep -q "password is disabled" test_admin ; then

     rm test_admin > /dev/null 2>&1

     if [ "$DEBUGW" == "1" ] ; then
       pid_to_kill=$(ps axu | grep zenity | grep wait | awk {'print $2'})
       echo wait_dialog 03 with PID $pid_to_kill will be killed
     fi

     # We have a open dialog to close

     end_wait_dialog && sleep 1

     zenity --error --width=600 \
     --text="\n\n         This addon needs a administration password set on the greeter-screen.\n         You have to set this option first ! \n\n" \
    > /dev/null 2>&1

     if [ $TERMINAL_VERBOSE == "1" ] ; then
        echo >&2 "we don't have a password -> We have to restart Tails."
     fi
     return 1

else
    rm ~/Persistent/test_admin > /dev/null 2>&1
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "we have a administration password"
    fi

    if [ "$DEBUGW" == "1" ] ; then
       pid_to_kill=$(ps axu | grep zenity | grep wait | awk {'print $2'})
       echo wait_dialog 02 with PID $pid_to_kill will be killed
    fi

    # We have a open dialog to close

    end_wait_dialog && sleep 1

    sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
    --text="\n\n                 Tails is using a adminitration password !         \n\n" > /dev/null 2>&1)
fi

rm test_admin > /dev/null 2>&1
return 0
}



test_bookmarks_persistent() {

cd ${global_tmp}
mount > mounted

if [ $IMPORT_BOOKMAKRS == "1" ] ; then
     if grep -q "firefox/bookmarks" mounted ; then
        if [ $TERMINAL_VERBOSE == "1" ] ; then
            echo "we have bookmarks active and we can import them later"
        fi
     else
        rm mounted > /dev/null 2>&1

        # We have a open dialog to close

        end_wait_dialog

        zenity --error --width=600 \
        --text="\n\n         The import of bookmarks is not possible (swtor.cfg), as long the bookmarks\n         option is not set on the persistent volume.\n         You have to set this option first ! \n\n" \
        > /dev/null 2>&1

        if [ $TERMINAL_VERBOSE == "1" ] ; then
           echo >&2 "import of bookmarks not possible as long the option is not set in persistent "
        fi

        return 1
     fi
fi
rm mounted > /dev/null 2>&1
return 0
}




test_admin_password() {

cd ${global_tmp}

rm password > /dev/null 2>&1
rm password_correct > /dev/null 2>&1


if [ "$DEBUGW" == "1" ] ; then
       pid_to_kill=$(ps axu | grep zenity | grep wait | awk {'print $2'})
       echo wait_dialog 03 with PID $pid_to_kill will be killed
fi

# We have a open dialog to close

end_wait_dialog && sleep 1

menu=1
while [ $menu -gt 0 ]; do

      # We have 3 shoots to give the correct password or we have to restart the script ...

      password=$(zenity --entry --text="Please type the curent Tails administration-password ?" --title=Password --hide-text)
      echo $password > password

      if [ "$password" == "" ] ; then

         if [ "$menu" == "3" ] ; then
             menu=0
             zenity --error --width=400 --text "\n\nThe password was not correct for 3 times ! \n\n"
             break
         else
             zenity --error --width=400 --text "\n\nThe password was empty ! \n\n"
             if [ $TERMINAL_VERBOSE == "1" ] ; then
                echo >&2 "password was empty !"
             fi
         fi

      else
          # we have a password that isn't blank

          if [ "$global_standard" == "1" ] ; then
              /home/amnesia/Persistent/swtor-addon-to-tails/scripts/testroot.sh >/dev/null 2>&1
          else
              # Here we are running on restore mode

              echo ...
          fi

          # here comes the funny part

          if [ -s password_correct ] ; then
             if [ $TERMINAL_VERBOSE == "1" ] ; then
                  echo >&2 "the provided administration password was correct"
             fi

             sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
             --text="\n\n              the password was correct and we can continue now as expected !         \n\n" > /dev/null 2>&1)

             menu=0
             correct=1
             break
         else
             if [ "$menu" == "3" ] ; then
                  menu=0
                  zenity --error --width=400 --text "\n\nThe password was not correct for 3 times ! \n\n"
                  break
              else
                  if [ $TERMINAL_VERBOSE == "1" ] ; then
                  echo >&2 "password was not correct"
                  fi
                  zenity --error --width=400 --text "\n\nThis password was not correct ! \n\n"
             fi
         fi

       fi
      ((menu++))
done

if [ "$correct" == "" ] ; then
   rm password > /dev/null 2>&1
   rm password_correct > /dev/null 2>&1
   return 1
else
   rm password_correct > /dev/null 2>&1
fi

return 0
}



test_empty_ssh() {

if [ -z "$(ls -A /home/amnesia/.ssh )" ] ; then
   zenity --error --width=600 \
   --text="\n\n         The directory ~/.ssh is empty.\n         This addon needs a valid SSH-configuration.\n\n" \
    > /dev/null 2>&1
   return 1

else
    end_wait_dialog && sleep 1
    sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
    --text="\n\n                  testing the ssh directoy for user amnesia was successful !          \n\n" > /dev/null 2>&1)

fi
return 0
}


change_tails_firewall(){

cd ${global_tmp}

if [ $BROWSER_SOCKS5 == "1" ] ; then

   cat password | sudo -S iptables -I OUTPUT -o lo -p tcp --dport 9999 -j ACCEPT  > /dev/null 2>&1
   cat password | sudo -S apt autoremove --yes  > /dev/null 2>&1

   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "changing iptables firewall to accept socks5 connections over port 9999"
      echo "autoremove old unused packages"
   fi

   end_wait_dialog && sleep 6
   sleep 6 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
   --text="\n\n                 firewall changed to accept a local socks5 proxy on port 9999 !          \n\n" > /dev/null 2>&1)

else
    cat password | sudo -S apt autoremove --yes  > /dev/null 2>&1
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo "configuration says  BROWSER-SOCKS5:NO"
       echo "firewall wasn't changed because this configuraution"
       echo "autoremove old unused packages"
    fi
    return 1
fi

# we don't need the password anytime longer
# we can delete it now.

rm password > /dev/null 2>&1

return 0
}



test_for_yad() {

end_wait_dialog && sleep 1
# test for installed yad from persistent volume

if grep -q "status installed yad" /var/log/dpkg.log ; then
   sleep 3 | tee >(zenity --progress --pulsate --no-cancel --auto-close  --title="Information" \
   --text="\n\n  yad software is installed !   \n\n" > /dev/null 2>&1)
   return 0
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "yad is not installed .... "
    fi
    zenity --error --width=400 --text "\n\n yad software is not installed ! \n\n"
    return 1
fi
}



test_for_sshpass() {

# test for installed sshpass from persistent volume

if grep -q "status installed sshpass" /var/log/dpkg.log ; then
   sleep 3 | tee >(zenity --progress --pulsate --no-cancel --auto-close  --title="Information" \
   --text="\n\n  sshpass software is installed !   \n\n" > /dev/null 2>&1)
   return 0
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "sshpass is not installed .... "
    fi
    zenity --error --width=400 --text "\n\n sshpass software is not installed ! \n\n"
    return 1
fi
}



test_for_html2text() {

# test for installed html2text from persistent volume

if grep -q "status installed html2text" /var/log/dpkg.log ; then
   sleep 3 | tee >(zenity --progress --pulsate --no-cancel --auto-close  --title="Information" \
   --text="\n\n  html2text software is installed !   \n\n" > /dev/null 2>&1)
   return 0
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "html2text is not installed .... "
    fi
    zenity --error --width=400 --text "\n\n html2text software is not installed ! \n\n"
    return 1
fi
}



test_for_chromium() {

# test for installed chromium from persistent volume

if grep -q "status installed chromium" /var/log/dpkg.log ; then
   sleep 3 | tee >(zenity --progress --pulsate --no-cancel --auto-close  --title="Information" \
   --text="\n\n  chromium software is installed !   \n\n" > /dev/null 2>&1)
   return 0
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "chromium is not installed .... "
    fi
    zenity --error --width=400 --text "\n\n chromium software is not installed ! \n\n"
    return 1
fi
}




test_for_chromium-sandbox() {

# test for installed chromium-sandbox from persistent volume

if grep -q "status installed chromium-sandbox" /var/log/dpkg.log ; then
   sleep 3 | tee >(zenity --progress --pulsate --no-cancel --auto-close  --title="Information" \
   --text="\n\n  chromium-sandbox software is installed !   \n\n" > /dev/null 2>&1)
   return 0
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "chromium-sandbox is not installed .... "
    fi
    zenity --error --width=400 --text "\n\n chromium-sandbox software is not installed ! \n\n"
    return 1
fi
}


test_for_freezed() {

cd ${global_tmp}

sleep 3 | tee >(zenity --progress --pulsate --no-cancel --auto-close  --title="Information" \
--text="\n\n      testing if the current system is in state : freezed       \n\n" > /dev/null 2>&1)

if [ -f ~/Persistent/swtorcfg/freezed.cgf ] ; then

   # We compare the freezed system with the curently running Tails.
   # If the Tails OS has ben updated ... the compare of the 2 files will completly fail ...

   tails-version > current-system
   if diff -q ~/Persistent/swtorcfg/freezed.cgf ~/Persistent/swtor-addon-to-tails/tmp/current-system ; then

      # It seems all OK

      sleep 7 | tee >(zenity --progress --pulsate --no-cancel --auto-close  --title="Information" \
      --text="\n\n      this system is current in the state  : [freezed]\n      this Tails is the same as the freezed system        \n\n" > /dev/null 2>&1)

      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo >&2 "this addon was freezed with the same version of tails that is currently used .."
      fi
      return 0

   else

       zenity --question --width=600 \
       --text="\n\nWe found a real problen with the current configuration.\nThis system was freezed with a older version of Tails.\nWould you like to unfreeze here and make a reboot ?\n\nIf your answer is Yes please do close all your applications prior to press Yes" > /dev/null 2>&1

       case $? in
         0)
           if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo "reboot choosen ..."
           fi

         rm -rf /live/persistence/TailsData_unlocked/dotfiles/.config > /dev/null 2>&1
         rm -rf /live/persistence/TailsData_unlocked/dotfiles/Desktop > /dev/null 2>&1
         rm -rf /live/persistence/TailsData_unlocked/dotfiles/Pictures > /dev/null 2>&1

         rm ~/Persistent/swtorcfg/freezed.cgf > /dev/null 2>&1

         cat password | sudo -S shutdown -h

         ;;

         1) if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo "no reboot choosen ..."
            fi
            return 1
         ;;
       esac
    fi
else
    sleep 3 | tee >(zenity --progress --pulsate --no-cancel --auto-close  --title="Information" \
    --text="\n\n      this system is not in the state : freezed       \n\n" > /dev/null 2>&1)
    return 0
fi

return 0
}


show_wait_dialog() {

cd /home/amnesia/Persistent/swtor-addon-to-tails/scripts

if [ "$global_standard" == "1" ] ; then
   if [ -f ~/Persistent/swtor-addon-to-tails/tmp/w-end ] ; then
      rm ~/Persistent/swtor-addon-to-tails/tmp/w-end
   fi
   cd /home/amnesia/Persistent/swtor-addon-to-tails/scripts
else
   if [ -f ~/Persistent/tmp/w-end ] ; then
      rm ~/Persistent/tmp/w-end
   fi

   # we are in restore-mode

fi

./wait.sh > /dev/null 2>&1 &

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo >&2 "process wait.sh started "
fi


return 0
}



end_wait_dialog() {


cd ${global_tmp}

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo >&2 "Try to kill zenity wait_dialog ..."
fi

pid_to_kill=$(ps axu | grep zenity | grep wait | awk {'print $2'})

if [ "$pid_to_kill" == "" ] ; then
   echo 1 > w-end
   return 1
fi

kill -9 $pid_to_kill

# Wtith this file ... we signal the wait.sh process to be ending
# instantly or we have fluded process-table with process wait.sh

echo 1 > w-end
return 0
}




swtor_cleanup() {

cd ${global_tmp}

return 0
}

ssh_connection_status(){

cd ${global_tmp}

menu=1
while [ $menu -gt 0 ]; do
      sleep 1
      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo ... waiting for ssh deamon reaction file ...
      fi
      if [ -f ssh_state ]  ; then
         rm ssh_state > /dev/null
         if [ $TERMINAL_VERBOSE == "1" ] ; then
            echo we can go back to the main menu
            echo the connection was made or even not
         fi
         menu=0
         sleep 12
      else
         ((menu++))
      fi
done
exit 0
}


export -f global_init
export -f check_tor_network
export -f test_ssh_persistent
export -f test_software_persistent
export -f test_password_greeting
export -f test_bookmarks_persistent
export -f test_admin_password
export -f test_empty_ssh
export -f change_tails_firewall
export -f test_for_yad
export -f test_for_sshpass
export -f test_for_html2text
export -f test_for_chromium
export -f test_for_chromium-sandbox
export -f test_for_freezed
export -f show_wait_dialog
export -f end_wait_dialog
export -f swtor_cleanup
export -f ssh_connection_status




