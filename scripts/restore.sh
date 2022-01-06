#/bin/bash
#########################################################
# SCRIPT  : restore.sh                                  #
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
# DATE    : 03-01-2022                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################


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
   exit 1
fi


