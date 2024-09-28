#!/bin/bash
#########################################################
# SCRIPT  : swtor-init.sh                               #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 6.7 or higher                         #
#                                                       #
# VERSION : 0.83                                        #
# STATE   : BETA                                        #
#                                                       #
#                                                       #
# DATE    : 26-09-2024                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################


if grep -q "IMPORT-BOOKMARKS:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
   export IMPORT_BOOKMAKRS="1"
else
   export IMPORT_BOOKMAKRS="0"
fi

if grep -q "GUI-LINKS:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
   export GUI_LINKS="1"
else
   export GUI_LINKS="0"
fi

if grep -q "CHECK-UPDATE:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
   export CHECK_UPDATE="1"
else
   export CHECK_UPDATE="0"
fi

if grep -q "BACKUP-FIXED-PROFILE:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
   export BACKUP_FIXED_PROFILE="1"
else
   export BACKUP_FIXED_PROFILE="0"
fi

if grep -q "BACKUP_APT_LIST:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
     export BACKUP_APT_LIST="1"
else
     export BACKUP_APT_LIST="0"
fi

if grep -q "TERMINAL-VERBOSE:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
     export TERMINAL_VERBOSE="1"
else
     export TERMINAL_VERBOSE="0"
fi

if grep -q "BROWSER-SOCKS5:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
     export BROWSER_SOCKS5="1"
else
     export BROWSER_SOCKS5="0"
fi

if grep -q "BYPASS-SOFTWARE-CHECK:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
     export BYPASS="1"
else
     export BYPASS="0"
fi

if grep -q "CHECK-EMPTY-SSH:NO" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
     export CHECK_SSH="0"
else
     export CHECK_SSH="1"
fi

if grep -q "AUTOCLOSE-BROWSER:YES" ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg ; then
     export AUTOCLOSE_BROWSER="1"
else
     export AUTOCLOSE_BROWSER="0"
fi


export TIMEOUT_TB=$(grep TIMEOUT-TB ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg | sed 's/[A-Z:-]//g')
export TIMEOUT_SSH=$(grep TIMEOUT-SSH ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg | sed 's/[A-Z:-]//g')
export XCLOCK_SIZE=$(grep XCLOCK-SIZE ~/Persistent/swtor-addon-to-tails/swtorcfg/swtor.cfg | sed 's/[A-Z:-]//g')

export  DEBUGW="0"


source ~/Persistent/scripts/swtor-global.sh
global_init
if [ $? -eq 0 ] ; then
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "global_init() done"
    fi
else
    if [ $TERMINAL_VERBOSE == "1" ] ; then
       echo >&2 "failure during initialisation of global-init() !"
       echo >&2 "swtor-init.sh exiting with error-code 1"
    fi
    exit 1
fi

# Creating the lockdirectory ....

lockdir=~/Persistent/scripts/init.lock
if mkdir "$lockdir" > /dev/null 2>&1
   then
       # the directory did not exist, but was created successfully

       if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo >&2 "successfully acquired lock: $lockdir"
       fi

else

       # failed to create the directory, presumably because it already exists

       if [ $TERMINAL_VERBOSE == "1" ] ; then
          echo >&2 "cannot acquire lock, giving up on $lockdir"
          echo >&2 "swtor-menu.sh exiting with error-code 1"
       fi
       zenity --error --width=600 --text="Lockdirectory for initialisation can not be created !"
       exit 1
fi



# If we don't have a password on startup .... we do exit right now

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo Password test
fi

echo _123UUU__ | sudo -S /bin/bash > test_admin 2>&1

if grep -q "provided" test_admin ; then
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo password asked
   fi
else
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo no password set
   fi
   rm test_admin > /dev/null 2>&1
   rmdir $lockdir 2>&1 >/dev/null
   exit 1
fi

if [ $TERMINAL_VERBOSE == "1" ] ; then
   echo test for password is done
fi

auto_init=1
connect=0
while [ $auto_init -gt 0 ]; do

      sleep 1

      curl --socks5 127.0.0.1:9050 -m 2 https://tails.net/home/index.en.html > /dev/null 2>&1

      if [ $? -eq 0 ] ; then
         if [ $TERMINAL_VERBOSE == "1" ] ; then
            echo tor is ready !
         fi
         connect=1
         auto_init=0
      else
         if [ $TERMINAL_VERBOSE == "1" ] ; then
            echo tor is not ready !
         fi
         ((auto_init++))
      fi

      if [ $TERMINAL_VERBOSE == "1" ] ; then
         echo $auto_init
      fi

      # We await for about 5 min.to a valid connection ....
      # After this time, we close the script !!!!

      if [ $auto_init -eq 300 ]; then
         auto_init=0
         connect=0
      fi
done

if [ $connect == "1" ] ; then

   # We kill the connection Window ......

   ps_to_kill=$(ps axu | grep amnesia | grep "/usr/bin/python3 /usr/lib/python3/dist-packages/tca/application.py" | awk {'print $2'})
   kill -9 $ps_to_kill 2>&1 >/dev/null

   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo connection window kiled !!!
   fi

else
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo timeout readched and no connection was made !
   fi
fi


# remove lockdir ...

rmdir $lockdir 2>&1 >/dev/null

exit 0

