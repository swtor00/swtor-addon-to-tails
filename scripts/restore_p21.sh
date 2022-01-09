


cd ~/Persistent/
files=$(ls -al * | wc -l)

if [ $files == "8" ] ; then
    echo "Persistent check for empty folder: done"
else
    echo "Persistent is not empty"
    exit 1
fi


# We need to test, that we are able to download
# the addon over internet, after checking the backup
# with the provided md5 checksumm

echo "testing internet-connection : Please wait !"
curl --socks5 localhost:9050 --socks5-hostname localhost:9050 -s https://check.torproject.org/ -m 10 | grep -m 1 Congratulations > /dev/null 2>&1

if [ $? -eq 0 ] ; then
   echo "testing internet-connection : done "
else
   echo "testing internet-connection : failure ... please activate a connection to the internet first !"
   echo "and restart this script with ./restore.sh from the persistent folder"
   exit 1
fi


