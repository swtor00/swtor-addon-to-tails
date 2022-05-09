


zenity --question --width=600 \
--text="\n\n   Prior to restore a backup of the Persistent Volume, please close this programms first,\n   if any of them are open.\n\n   * Tor Browser\n   * Thunderbird\n   * Electrum Bitcoin Wallet \n   * Pidgin Internet Messanger\n   * Synaptic Package Manager\n\n If none of the above programms is open,please continue the restore by pressing 'Yes'.\n Otherwise press 'No' to cancel the restore.  \n\n"
case $? in
         0) if [ $CLI_OUT == "1" ] ; then
               echo restore started
            fi
         ;;
         1) if [ $CLI_OUT == "1" ] ; then
               echo restore not started
            fi
            exit 1
         ;;
esac

# We need to test, that we are able to download
# the addon over internet

if [ $CLI_OUT == "1" ] ; then
   echo "testing internet-connection : Please wait !"
fi

sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
--text="\n\n               Testing the Internet connection          \n\n" > /dev/null 2>&1)

curl --socks5 localhost:9050 --socks5-hostname localhost:9050 -s https://check.torproject.org/ -m 10 | grep -m 1 Congratulations > /dev/null 2>&1

if [ $? -eq 0 ] ; then
   if [ $CLI_OUT == "1" ] ; then
      echo "testing internet-connection : done "
   fi
   sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
   --text="\n\n               Testing the Internet connection over TOR was successful !          \n\n" > /dev/null 2>&1)
else
   if [ $CLI_OUT == "1" ] ; then
      echo "testing internet-connection : failure ... please activate a connection to the internet first !"
      echo "and restart this script with ./restore.sh from the persistent folder"
   fi
   zenity --error --width=600 \
   --text="\n\n               Internet not ready or no active connection found ! \nPlease make a connection to the Internet first and try it again ! \n\n"\
   > /dev/null 2>&1
   exit 1
fi


cd ~/Persistent/
files=$(ls -Al | wc -l)
if [ ! -f ~/Persistent/stage1 ] ; then
   if [ $files == "6" ] ; then
      if [ $CLI_OUT == "1" ] ; then
         echo "Persistent check for empty folder: done"
      fi
      echo 1 > ~/Persistent/stage1
   else
      if [ $CLI_OUT == "1" ] ; then
         echo "Persistent is not empty"
      fi
      zenity --error --width=600 \
      --text="\n\n  The persistent folder should contain only the following files and directorys: \n\n   - One directory 'Tor Browser'\n   - Two files with ssh-keys \n   - One file know_hosts\n   - One executeable script restore.sh\n\n"\ 
      > /dev/null 2>&1
      exit 1
   fi
else
   if [ $CLI_OUT == "1" ] ; then
       echo "check for stage1 passed : done"
   fi
fi

if [ ! -f ~/Persistent/stage1a ] ; then
   cp id_rsa ~/.ssh > /dev/null 2>&1
   cp id_rsa.pub ~/.ssh > /dev/null 2>&1
   cp known_hosts ~/.ssh > /dev/null 2>&1
   chmod 600 ~/.ssh/id_rsa > /dev/null 2>&1
   chmod 644 ~/.ssh/*.pub > /dev/null 2>&1
   ssh-add > /dev/null 2>&1
   echo 1 > ~/Persistent/stage1a

   # We can delete the keys now

   rm id_rsa  > /dev/null 2>&1
   rm id_rsa.pub > /dev/null 2>&1
   rm known_hosts > /dev/null 2>&1

   if [ $CLI_OUT == "1" ] ; then
      echo "Copy key files temporary to folder ~./ssh"
   fi
else
   if [ $CLI_OUT == "1" ] ; then
       echo "check for stage1a passed : done"
   fi
fi

