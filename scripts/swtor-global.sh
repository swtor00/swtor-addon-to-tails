#/bin/bash
#########################################################
# SCRIPT  : swtor-global.sh                             #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 4.25 or higher                        #
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

   end_wait_dialog && sleep 0.5

   sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
   --text="\n\n               Testing the Internet connection over TOR was successful !          \n\n" > /dev/null 2>&1)

   if [ -d ~/Persistent/swtor-addon-to-tails/.git ] ; then

      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo >&2 "Touching tic_tac on remote host."
         echo >&2 "if you don't like to touch this file ....you have to remove the git directory"
      fi
      curl -socks5 localhost:9050 --socks5-hostname localhost:9050 -s https://github.com/swtor00/swtor-addon-to-tails/blob/master/tmp/tic_tac -m3  > /dev/null 2>&1
   fi

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

   end_wait_dialog && sleep 0.5

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

   end_wait_dialog && sleep 0.5

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

   end_wait_dialog && sleep 0.5

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

     end_wait_dialog && sleep 0.5

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

    end_wait_dialog && sleep 0.5

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

        end_wait_dialog && sleep 0.5

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

end_wait_dialog && sleep 0.5

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
             --text="\n\n              The password was correct and we can continue now as expected !         \n\n" > /dev/null 2>&1)

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

   # We have a open dialog to close
   
   end_wait_dialog && sleep 0.5

   sleep 6 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
   --text="\n\n        [ Firewall changed to accept a local socks5 proxy ]       \n\n" > /dev/null 2>&1)

else
    cat password | sudo -S apt autoremove --yes  > /dev/null 2>&1

    # We have a open dialog to close
   
    end_wait_dialog && sleep 0.5

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

end_wait_dialog && sleep 0.5
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
--text="\n\n      Testing if the current system is in state : freezed       \n\n" > /dev/null 2>&1)

if [ -f ~/Persistent/swtorcfg/freezed.cgf ] ; then

   # We compare the freezed system with the curently running Tails.
   # If the Tails OS has ben updated ... the compare of the 2 files will completly fail ...

   tails-version > current-system
   if diff -q ~/Persistent/swtorcfg/freezed.cgf ~/Persistent/swtor-addon-to-tails/tmp/current-system ; then

      # It seems all OK

      sleep 7 | tee >(zenity --progress --pulsate --no-cancel --auto-close  --title="Information" \
      --text="\n\n        This system is current in the state  : [freezed]        \n\n" > /dev/null 2>&1)

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


         rmdir ~/Persistent/scripts/menu.lock 2>&1 >/dev/null
         cd ~/Persistent/swtor-addon-to-tails/tmp
         cat password | sudo -S shutdown -r now

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
sleep 0.1
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
         sleep 9
      else
         ((menu++))
      fi
done
exit 0
}


swtor_no_ipv6(){
zenity --info --width=600 --title="Information" \
 --text="\n\n    Tails only supports IP Version 4. IP Verion 6 isn't supported   \n\n"  > /dev/null 2>&1
return 0
}


swtor_ssh_failure(){

echo 1 > ~/Persistent/swtor-addon-to-tails/tmp/ssh_state
zenity --info --width=600  --title="Information" --text="\n\nThe desired SSH connection could not be made ! \nPlease have a closer look to the log-files inside of ~/Persistent/swtorcfg/log ! \n\n"
return 0
}


swtor_ssh_success(){

echo 1 > ~/Persistent/swtor-addon-to-tails/tmp/ssh_state
zenity --info  --width=600 --title="Information" --text="\n\nThe selected SSH connection is now active.\nYou can now start a predefined browser-profile from the main-menu.\n\nTo close this SSH connection, please press the 'OK' button on this window ! \n\n"
return 0
}

swtor_wrong_script() {
zenity --info --width=600  --title="Information" \
--text="\n\n    wrong script definition placed inside of fullssh.arg !           \n\n"  > /dev/null 2>&1
return 0
}

swtor_missing_arg() {
zenity --info --width=600  --title="Information" \
--text="\n\n     The argument file for this SSH-Connection is missing !           \n\n"  > /dev/null 2>&1
return 0
}

swtor_missing_password() {
zenity --info --width=600  --title="Information" \
--text="\n\n     The password file for this SSH-Connection is missing or empty !         \n\n"  > /dev/null 2>&1
return 0
}


swtor_update () {

if [ $CHECK_UPDATE == "1" ] ; then

   # Some maybe not so clever poeple may try to delete the .git directory from
   # the addon itself and the configuration saying explicit CHECK-UPDATE:YES  ...
   # This will not work for now or in the future !!!!!!!
   # This poeple should make a configuration change to CHECK-UPDATE:NO
   # We report back a failure ..... until the user change the configuration.

   if [ ! -d ~/Persistent/swtor-addon-to-tails/.git ] ; then
      zenity --error --width=400 --text "\n\n    Houston, we have a problem !  \n    The .git directory was removed ! \n\n"
      return 1
   fi


   sleep 3 | tee >(zenity --progress --pulsate --no-cancel --auto-close  --title="Information" \
   --text="\n\n      Checking for updates is active : 'yes'         \n\n" > /dev/null 2>&1)

   # If you don't like this behavior on startup, you should open the
   # configuration file ~/Persistent/swtorcfg/swtor.cfg and set the option
   # CHECK-UPDATE:YES to the value CHECK-UPDATE:NO
   # After this little change ... it will not longer look for a update on startup
   # of the addon.
   # The default configuration by downloading the addon from github is CHECK-UPDATE:NO

   # We contact github to see what version is stored over there ....

   show_wait_dialog && sleep 3.5


   cd ${global_tmp}

   wget -O REMOTE-VERSION https://raw.githubusercontent.com/swtor00/swtor-addon-to-tails/master/swtorcfg/swtor.cfg > /dev/null 2>&1

   end_wait_dialog && sleep 0.5

   REMOTE=$(grep "SWTOR-VERSION" REMOTE-VERSION | sed 's/[A-Z:-]//g')
   LOCAL=$(grep SWTOR-VERSION ~/Persistent/swtorcfg/swtor.cfg | sed 's/[A-Z:-]//g')

   # Comparing the remote and the local version of the scirpt..

   if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo REMOTE-VERSION [$REMOTE]
       echo LOCAL-VERSION [$LOCAL]
   fi

   if [ "$REMOTE" == "$LOCAL" ] ; then
      if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo "no updates found to install "
          echo "both version are equal  ... "
      fi
      sleep 3 | tee >(zenity --progress --pulsate --no-cancel --auto-close  --title="Information" \
      --text="\n\n      Checking for updates did not found a update to install !        \n\n" > /dev/null 2>&1)
      return 0
   else
      if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo "we found a difference ... "
      fi
      cd ~/Persistent/swtor-addon-to-tails/scripts
      ./update.sh
   fi

else
   sleep 3 | tee >(zenity --progress --pulsate --no-cancel --auto-close  --title="Information" \
   --text="\n\n      Checking for updates is active : 'no'         \n\n" > /dev/null 2>&1)
fi

return 0
}


swtor_clean_files() {

sleep 3 | tee >(zenity --progress --pulsate --no-cancel --auto-close  --title="Information" \
--text="\n\n        Cleanup old invalid log files and browser-files          \n\n" > /dev/null 2>&1)

# cleanup old connection-files file inside cfg directory

rm -rf /home/amnesia/Persistent/swtorcfg/*.arg > /dev/null 2>&1
rm -rf /home/amnesia/Persistent/swtorcfg/log/*.* > /dev/null 2>&1


# cleanup all browser-settings and extract all settings from tar file

if [ -d /home/amnesia/Persistent/settings/1  ] ; then
   rm -rf  ~/Persistent/settings/1 >/dev/null 2>&1
fi

if [ -d /home/amnesia/Persistent/settings/2  ] ; then
  rm -rf  ~/Persistent/settings/2 >/dev/null 2>&1
fi


# Test the state of the connection

if [ -f /home/amnesia/Persistent/scripts/state/online ] ; then
    cd /home/amnesia/Persistent/scripts/state
    rm online
fi


echo 1 > /home/amnesia/Persistent/scripts/state/offline
return 0
}


swtor_connected() {

# Check to see if the ONION Network is still runnig ....

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo testing the internet-connection over the onion-network with TIMEOUT $TIMEOUT_TB
fi

curl --socks5 localhost:9050 --socks5-hostname localhost:9050 -s https://check.torproject.org/ -m $TIMEOUT_TB | grep -m 1 Congratulations > /dev/null 2>&1

if [ $? -eq 0 ] ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "TOR is up and running and we can continue with the execution of the script ...."
   fi

   sleep 3 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
   --text="\n\n                 [ Connection check worked ]          \n\n" > /dev/null 2>&1)

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

swtor_no_connection() {
sleep 6 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
--text="\n\n             This is not possible without a active ssh connection !          \n\n" > /dev/null 2>&1)
sleep 0.5
}

swtor_close_first() {
sleep 6 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
--text="\n\n             Please close the current connection first !          \n\n" > /dev/null 2>&1)
sleep 0.5
}

swtor_ask_passphrase() {

menu=1
while [ $menu -gt 0 ]; do

# Pass 1

encryption_password=$(zenity --entry --text="Please type the phrase for the file encrypting " --title=Entry-1 --hide-text)

# We do not store this phrase on a volume, that could be recovered !

echo -n $encryption_password > /dev/shm/password1

# Pass 2

encryption_password=$(zenity --entry --text="Please retype the phrase for the file encrypting " --title=Entry-2 --hide-text)

# We do not store this phrase on a volume, that could be recovered !

echo -n  $encryption_password > /dev/shm/password2

if diff /dev/shm/password1 /dev/shm/password2 > /dev/null 2>&1 ; then

if [ $? -eq 0 ] ; then
    menu=0
    zenity --question --width=600 \
    --text="\n\nWould you like to encrypt the backup with the following passphrase : \n\n$(cat /dev/shm/password2)\n\nPlease be very carefull where to store this passphrase and don't try\nto make a photo with your Smartphone and store it in a cloud !\n\n\nIf you answer is "Yes" this passphrase will be used to encrypt.\nIf you answer "No" this backup will be canceled !!! " > /dev/null 2>&1
    case $? in
    0) if [ $TERMINAL_VERBOSE == "1" ] ; then
               echo "encryption with passphrase"
       fi
       return 0
    ;;
     1) if [ $TERMINAL_VERBOSE == "1" ] ; then
           echo "no encryption and cancel backup"
        fi
        return 1
    ;;
    esac
fi
fi

((menu++)) 

if [ "$menu" -ge "4" ] ; then 
   sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
   --text="\n\n           You had your chance to type it correct ! Backup is canceled !      \n\n" > /dev/null 2>&1)
   return 1 
else
   sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
   --text="\n\n           The two passphrases don't match. Please try it again !          \n\n" > /dev/null 2>&1)
fi

done
}


restore_bookmarks() {

# If the backup contains bookmarks from Tor-Browser : we restore them back

if [ -d ~/Persistent/backup/bookmarks ] ; then
   if mount | grep -q /home/amnesia/.mozilla/firefox/bookmarks ; then
      cp ~/Persistent/backup/bookmarks/places.sqlite ~/.mozilla/firefox/bookmarks
       if [ $CLI_OUT == "1" ] ; then 
          echo "Backup files bookmarks restored"
       fi
   else
       if [ $CLI_OUT == "1" ] ; then
          echo "Bookmarks not restored .... option is not active on this persistent volume"
       fi
   fi
fi
}


restore_gnupg() {

# If the backup contains gnupg : we restore them back

if [ -d ~/Persistent/backup/gnupg ] ; then
   if mount | grep -q /home/amnesia/.gnupg ; then
      cp -r ~/Persistent/backup/gnupg/* ~/.gnupg/
      if [ $CLI_OUT == "1" ] ; then
         echo "Backup files gnupg restored"
      fi
   else
      if [ $CLI_OUT == "1" ] ; then
         echo "gnupg not restored .... option is not active on this persistent volume"
      fi  
   fi
fi
}



restore_thunderbird() {

# If the backup contains thunderbird (Email) we restore them back

if [ -d ~/Persistent/backup/thunderbird ] ; then
   if mount | grep -q home/amnesia/.thunderbird ; then
      cp -r ~/Persistent/backup/thunderbird/*  ~/.thunderbird
      if [ $CLI_OUT == "1" ] ; then
         echo "Backup files thunderbird restored"
      fi
   else
      if [ $CLI_OUT == "1" ] ; then
         echo "thunderbird not restored .... option is not active on this persistent volume"
      fi
   fi
fi
}

restore_pidgin() {

# If the backup contains pidgin (Messanger) : we restore them back

if [ -d ~/Persistent/backup/pidgin ] ; then
   if mount | grep -q /home/amnesia/.purple ; then
      cp -r ~/Persistent/backup/pidgin/* /home/amnesia/.purple
      if [ $CLI_OUT == "1" ] ; then
         echo "Backup files pidgin restored"
      fi
   else
      if [ $CLI_OUT == "1" ] ; then
         echo "pidgin not restored .... option is not active on this persistent volume"
      fi
    fi
fi
}


restore_electrum() {

# If the backup contains electrum bitcoin wallet : we restore them back

if [ -d ~/Persistent/backup/electrum  ] ; then
   if mount | grep -q /home/amnesia/.electrum  ; then
      cp -r ~/Persistent/backup/electrum/*  /home/amnesia/.electrum
      if [ $CLI_OUT == "1" ] ; then
         echo "Backup files electrum restored"
      fi
   else
       if [ $CLI_OUT == "1" ] ; then
          echo "electrum not restored .... option is not active on this persistent volume"
       fi
   fi
fi
}



restore_git() {

# I don't know the exactly reason ... we copy back config from backup git
# and we are able to make a git push without any password

cp /home/amnesia/Persistent/backup/git/config ~/Persistent/swtor-addon-to-tails/.git

}



restore_ssh() {

cd ~/Persistent/backup/openssh-client

cp config ~/.ssh > /dev/null 2>&1
cp id_rsa ~/.ssh > /dev/null 2>&1
cp id_rsa.pub ~/.ssh > /dev/null 2>&1
cp known_hosts ~/.ssh > /dev/null 2>&1
chmod 600 ~/.ssh/id_rsa > /dev/null 2>&1
chmod 644 ~/.ssh/*.pub > /dev/null 2>&1

ssh-add > /dev/null 2>&1
if [ $CLI_OUT == "1" ] ; then
   echo "Backup files ~/.ssh restored"
fi
}


restore_network_connections() {

# If the backup contains network-connections : we restore them back

if [ -d ~/Persistent/backup/nm-system-connections ] ; then
   if grep -q system-connection ~/Persistent/persistence.conf ; then
      cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
      sudo -S rsync -aqzh /home/amnesia/Persistent/backup/nm-system-connections /live/persistence/TailsData_unlocked/ > /dev/null 2>&1

      # Very important  here after the copy :
      # We need to change the owner and group to root:root for all the files or
      # the owner and group is amnesia:amnesia and this would not work on the next boot

      cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
      sudo -S  chown -R root:root /live/persistence/TailsData_unlocked/nm-system-connections > /dev/null 2>&1

      if [ $CLI_OUT == "1" ] ; then
         echo "Backup files system-connection restored"
      fi
   else
      if [ $CLI_OUT == "1" ] ; then
         echo "system-connection not restored .... option is not active on this persistent volume"
      fi
   fi
fi
}



restore_tca() {

# If the backup contains tca (TOR-Nodes configuration) : we restore them back

if [ -d ~/Persistent/backup/tca  ] ; then
   if grep -q tca ~/Persistent/persistence.conf ; then

      cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
      sudo -S rsync -aqzh /home/amnesia/Persistent/backup/tca /live/persistence/TailsData_unlocked/ > /dev/null 2>&1

      # Very important  here after the copy :
      # We need to change the owner and group to root:root for all the files or
      # the owner and group is amnesia:amnesia

      cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
      sudo -S chown -R root:root /live/persistence/TailsData_unlocked/tca  > /dev/null 2>&1

      if [ $CLI_OUT == "1" ] ; then
         echo "Backup files tca restored"
      fi
   else
      if [ $CLI_OUT == "1" ] ; then
         echo "tca not restored .... option is not active on this persistent volume"
      fi
   fi
fi
}


restore_cups() {

# If the backup contains cups (Printing) : we restore them back

if [ -d ~/Persistent/backup/cups-configuration ] ; then
   if grep -q cups-configuration ~/Persistent/persistence.conf ; then

      # The owner and groups of the cups configuration
      #
      # root root 6402 Dec  6 15:03 cupsd.conf
      # root root 2923 Nov 28  2020 cups-files.conf
      # root root 4096 Nov 28  2020 interfaces
      # root lp   4096 Nov 28  2020 ppd
      # root root  240 Dec  6 15:03 raw.convs
      # root root  211 Dec  6 15:03 raw.types
      # root root  142 Nov 28  2020 snmp.conf
      # root lp   4096 Nov 28  2020 ssl
      # root lp    694 Jan  8 12:08 subscriptions.conf
      # root lp    392 Jan  8 12:04 subscriptions.conf.O

      cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
      sudo -S rsync -aqzh /home/amnesia/Persistent/backup/cups-configuration /live/persistence/TailsData_unlocked/ > /dev/null 2>&1

      # Very important  here after the copy :
      # We need to change the owner and group to root:root for all the files or
      # the owner and group is amnesia:amnesia

      cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
      sudo -S chown -R root:root /live/persistence/TailsData_unlocked/cups-configuration > /dev/null 2>&1

      # special owner and group for ppd

      cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
      sudo -S chown -R root:lp /live/persistence/TailsData_unlocked/cups-configuration/ppd > /dev/null 2>&1

      # special owner and group for ssl

      cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
      sudo -S chown -R root:lp /live/persistence/TailsData_unlocked/cups-configuration/ssl > /dev/null 2>&1


      # special owner and group for subscriptions.conf

      cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
      sudo -S  chown -R root:lp /live/persistence/TailsData_unlocked/cups-configuration/subscriptions.conf > /dev/null 2>&1

      # Is this really needet ? We see
      # special owner and group for subscriptions.conf.0

      cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
      sudo -S  chown -R root:lp /live/persistence/TailsData_unlocked/cups-configuration/subscriptions.conf.0 > /dev/null 2>&1

      if [ $CLI_OUT == "1" ] ; then 
         echo "Backup files cups restored"
      fi
   else
      if [ $CLI_OUT == "1" ] ; then 
         echo "cups not restored .... option is not active on this persistent volume"
      fi
   fi
fi
}


restore_greeter_screen() {

# If the backup contains greeter-settings : we restore them back

if [ -d ~/Persistent/backup/greeter-settings ] ; then
   if grep -q greeter-settings ~/Persistent/persistence.conf ; then

      # The owner and groups of the greeter-settings
      #
      # Debian-gdm Debian-gdm   37 Jan  7 21:48 tails.formats
      # Debian-gdm Debian-gdm   75 Jan  8 12:08 tails.keyboard
      # Debian-gdm Debian-gdm   41 Jan  7 21:48 tails.language
      # Debian-gdm Debian-gdm   28 Jan  7 21:48 tails.macspoof
      # Debian-gdm Debian-gdm   19 Jan  7 21:48 tails.network
      # Debian-gdm Debian-gdm  160 Jan  7 21:48 tails.password
      # Debian-gdm Debian-gdm   35 Jan  7 21:48 tails.unsafe-browser

      cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
      sudo -S rsync -aqzh /home/amnesia/Persistent/backup/greeter-settings /live/persistence/TailsData_unlocked/ > /dev/null 2>&1

      # Very important  here after the copy :
      # We need to change the owner and group to Debian-gdm:Debian-gdm for all the files or
      # the owner and group is amnesia:amnesia

      cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
      sudo -S chown -R Debian-gdm:Debian-gdm /live/persistence/TailsData_unlocked/greeter-settings > /dev/null 2>&1
            
      if [ $CLI_OUT == "1" ] ; then      
         echo "Backup files greeter-settings restored"
      fi
   else
      if [ $CLI_OUT == "1" ] ; then 
         echo "greeter-settings not restored .... option is not active on this persistent volume"
      fi 
   fi
fi
}
 


restore_software() {

# We copy back the configuration for the additional-Software that is stored here
#
# tails-persistence-setup tails-persistence-setup     0 Jan  7 21:46 live-additional-software.conf
#

if [ $CLI_OUT == "1" ] ; then 
   echo "Execute command apt-get update. Please wait !!!! "
   echo "Please do not interrupt here .... This commands need a lot of time !!!"
fi 
       
cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
sudo -S cp ~/Persistent/backup/live-additional-software.conf /live/persistence/TailsData_unlocked/ > /dev/null 2>&1

cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
sudo -S chown tails-persistence-setup:tails-persistence-setup /live/persistence/TailsData_unlocked/live-additional-software.conf > /dev/null 2>&1
        
cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
sudo -S apt-get update > /dev/null 2>&1 

cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
sudo -S apt-get install -y chromium > /dev/null 2>&1 

cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
sudo -S apt-get install -y chromium-sandbox > /dev/null 2>&1 

cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
sudo -S apt-get install -y html2text > /dev/null 2>&1 

cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
sudo -S apt-get install -y sshpass > /dev/null 2>&1
 
cat ~/Persistent/swtor-addon-to-tails/tmp/password | \
sudo -S apt-get install -y yad > /dev/null 2>&1 

if [ $CLI_OUT == "1" ] ; then 
   echo "Backup files additional-software restored and software installed"
fi
}



restore_dotfiles() {

# Do we have dotfiles inside the backup  ?

if [ -d ~/Persistent/backup/dotfiles ] ; then
   if grep -q dotfiles  ~/Persistent/persistence.conf ; then
      cd ~/Persistent/scripts

      # Was the system during Backup in the state freezed ?
      # If this is the case ... we are freezing this Tails as well again 

      echo 1 > ~/Persistent/swtorcfg/freezing

      if [ -f ~/Persistent/backup/swtorcfg/freezed.cgf ]  ; then
         ./cli_tweak.sh > /dev/null 2>&1
         ./cli_freezing.sh > /dev/null 2>&1
         if [ $CLI_OUT == "1" ] ; then
            echo state : now this Tails is [freezed]
         fi
      else
        if [ $CLI_OUT == "1" ] ; then
           echo state : not-freezed here because backup was not freezed
        fi  
      fi
   else
      echo 1 > ~/Persistent/swtorcfg/no-freezing
      if [ $CLI_OUT == "1" ] ; then
         echo "dotfiles not restored .... option is not active on this persistent volume"
      fi 
   fi
fi
}


restore_finish() {
echo 0 > ~/Persistent/swtor-addon-to-tails/setup
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
export -f swtor_no_ipv6
export -f swtor_ssh_failure
export -f swtor_ssh_success
export -f swtor_wrong_script
export -f swtor_missing_arg
export -f swtor_missing_password
export -f swtor_update
export -f swtor_clean_files
export -f swtor_connected
export -f swtor_close_first
export -f swtor_no_connection
export -f swtor_ask_passphrase
export -f restore_bookmarks
export -f restore_gnupg
export -f restore_thunderbird
export -f restore_pidgin
export -f restore_electrum
export -f restore_git
export -f restore_ssh
export -f restore_network_connections
export -f restore_tca
export -f restore_cups
export -f restore_greeter_screen
export -f restore_software
export -f restore_dotfiles
export -f restore_finish
 

