

cd ~/Persistent/

files=$(ls -al * | wc -l)   

if [ $files == "9" ] ; then
   if [ $CLI_OUT == "1" ] ; then
      echo "Persistent check for empty folder: done"
   fi
else
    if [ $CLI_OUT == "1" ] ; then
        echo "Persistent is not empty"
    fi
    zenity --error --width=600 \
    --text="\n\n        Persistent folder is not empty !    \n\n"\
    > /dev/null 2>&1 
    exit 1
fi

# We need to test, that we are able to download
# the addon over internet, after checking the backup
# with the provided md5 checksumm

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

cp id_rsa ~/.ssh > /dev/null 2>&1
cp id_rsa.pub ~/.ssh > /dev/null 2>&1
cp known_hosts ~/.ssh > /dev/null 2>&1
chmod 600 ~/.ssh/id_rsa > /dev/null 2>&1
chmod 644 ~/.ssh/*.pub > /dev/null 2>&1
ssh-add > /dev/null 2>&1

if [ $CLI_OUT == "1" ] ; then
   echo "Copy key files temporary to folder ~./ssh"
fi


