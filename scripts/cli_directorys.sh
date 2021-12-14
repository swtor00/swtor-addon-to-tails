if [ ! -L ~/Persistent/settings ] ; then
   ln -s ~/Persistent/swtor-addon-to-tails/settings ~/Persistent/settings > /dev/null 2>&1
   echo "creating symlink ~/Persistent/settings"
else
   echo "symlink ~/Persistent/settings was allready made"
fi

if [ ! -L ~/Persistent/scripts ] ; then
   ln -s ~/Persistent/swtor-addon-to-tails/scripts  ~/Persistent/scripts > /dev/null 2>&1
   echo "creating symlink ~/Persistent/scripts"
else
   echo "symlink ~/Persistent/scripts was allready made"
fi

if [ ! -L ~/Persistent/swtorcfg ] ; then
   ln -s ~/Persistent/swtor-addon-to-tails/swtorcfg ~/Persistent/swtorcfg > /dev/null 2>&1
   echo "creating symlink ~/Persistent/swtorcfg"
else
   echo "symlink ~/Persistent/swtorcfg was allready made"
fi

if [ ! -L ~/Persistent/doc ] ; then
   ln -s ~/Persistent/swtor-addon-to-tails/doc ~/Persistent/doc > /dev/null 2>&1
   echo "creating symlink ~/Persistent/doc"
else
   echo "symlink ~/Persistent/doc was allready made"
fi

if [ ! -d ~/Persistent/swtor-addon-to-tails/swtorcfg/log ] ; then
   mkdir -p ~/Persistent/swtor-addon-to-tails/swtorcfg/log
   echo "directory ~/Persistent/swtor-addon-to-tails/swtorcfg/log created"
else
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "directory ~/Persistent/swtor-addon-to-tails/swtorcfg/log was allready made"
   fi
fi

if [ ! -d ~/Persistent/personal-files ] ; then
   mkdir -p ~/Persistent/personal-files 
   mkdir -p ~/Persistent/personal-files/tails-repair-disk
   echo "directory ~/Persistent/personal-files created"
   echo "directory ~/Persistent/personal-files created/tails-repair-disk"
else
   if [ $TERMINAL_VERBOSE == "1" ] ; then
      echo "directory ~/Persistent/personal-files was allready made"
   fi
fi


