

# we calculate the md5 01 of the backup-file

checksumm1=$(cat $file1)
checksumm2=$(md5sum $file2 |  awk  {'print $1'})

if [ $CLI_OUT == "1" ] ; then
   echo stored-----md5 01: $checksumm1
   echo calculated-md5 01: $checksumm2
fi

if [ $checksumm1 == $checksumm2 ] ; then
   if [ $CLI_OUT == "1" ] ; then
      echo checksumm 01 is correct
   fi
   sleep 5 |tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n       [ Checksumm 01 is correct ]           \n") & > /dev/null 2>&1
else
   if [ $CLI_OUT == "1" ] ; then
      echo "warning : calculated checksum 01 and the stored checksumm do not match !!!!!!!"
      echo "this tails backup is not valid !!!!"
   fi 
   zenity --error --width=600 \
   --text="\n\n             Checksumm 01 is not correct. This Backup is not valid !       \n\n"\
   > /dev/null 2>&1
   exit 1
fi


# we need to know the generated filenames inside the backup

bfile2=$(tar -tvf $file2 | grep tar.gz | awk  {'print $6'} | xargs basename )
bfile1=$(tar -tvf $file2 | grep md5 | awk  {'print $6'} | xargs basename )

# we extract the unencrypted tar.gz right here (2 filenames)

if [ $CLI_OUT == "1" ] ; then
   echo "extracting backup file "$file2 ": please wait !"
fi 

tar xzf $file2 > /dev/null 2>&1

if [ $? -eq 0 ] ; then
   if [ $CLI_OUT == "1" ] ; then
      echo "extracting backup file "$file2" : done"
   fi
else
   if [ $CLI_OUT == "1" ] ; then
      echo "extracting backup file " $file2 " : failure !"
   fi 
   zenity --error --width=600 \
   --text="\n\n            Error on extracting tar file : '$file2' !       \n\n"\
   > /dev/null 2>&1
   exit 1
fi

mfile1=$(find ./home | grep $bfile1)
mfile2=$(find ./home | grep $bfile2)

mv $mfile1 .
if [ $? -eq 0 ] ; then
   if [ $CLI_OUT == "1" ] ; then
      echo "moving "$mfile1" to ~/Persistent/ done"
   fi
else 
   if [ $CLI_OUT == "1" ] ; then
      echo "moving "$mfile1" to ~/Persistent error"
   fi
   zenity --error --width=600 \
   --text="\n\n            Error on moving file : '$mfile1' !       \n\n"\
   > /dev/null 2>&1
   exit 1
fi 


mv $mfile2 .
if [ $? -eq 0 ] ; then
   if [ $CLI_OUT == "1" ] ; then
      echo "moving "$mfile2" to ~/Persistent/ done"
   fi
else
   if [ $CLI_OUT == "1" ] ; then
      echo "moving "$mfile1" to ~/Persistent error"
   fi
   zenity --error --width=600 \
   --text="\n\n            Error on moving file : '$mfile2' !       \n\n"\
   > /dev/null 2>&1
fi 

rm -rf ./home > /dev/null 2>&1
rm $file1 > /dev/null 2>&1
rm $file2 > /dev/null 2>&1

file1=$(ls -al | grep md5check | awk  {'print $9'})
file2=$(ls -al | grep tar.gz | awk  {'print $9'})

# we calculate the md5 02 of the backup-file that we extracted above

checksumm1=$(cat $file1)
checksumm2=$(md5sum $file2 |  awk  {'print $1'})

if [ $CLI_OUT == "1" ] ; then
   echo stored-----md5 02: $checksumm1
   echo calculated-md5 02: $checksumm2
fi

if [ $checksumm1 == $checksumm2 ] ; then
   if [ $CLI_OUT == "1" ] ; then
      echo checksumm 02 is correct
   fi
   sleep 5 |tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n       [ Checksumm 02 is correct ]           \n") & > /dev/null 2>&1
else
   if [ $CLI_OUT == "1" ] ; then
      echo "warning : calculated checksum 02 and the stored checksumm do not match !!!!!!!"
      echo "this tails backup is not valid !!!!"
   fi 
   zenity --error --width=600 \
   --text="\n\n             Checksumm 02 is not correct. This Backup is not valid !       \n\n"\
   > /dev/null 2>&1
   exit 1
fi


# Both provided md5 checksumms are correct ...we continue now
 
if [ $CLI_OUT == "1" ] ; then
   echo "extracting backup file " $file2 " : please wait !"
fi 

tar xzf $file2 > /dev/null 2>&1

if [ $? -eq 0 ] ; then
   if [ $CLI_OUT == "1" ] ; then
      echo "extracting backup file " $file2 " : done"
   fi
else
   if [ $CLI_OUT == "1" ] ; then
      echo "extracting backup file " $file2 " : failure !"
   fi
   zenity --error --width=600 \
   --text="\n\n            Error on extracting tar file : '$file2' !       \n\n"\
   > /dev/null 2>&1
   exit 1
fi



# we move the backup folder here to the root of ~/Persistent

backup_folder=$(find ./home | grep backup | head -1)
mv $backup_folder . > /dev/null 2>&1
rm -rf ./home > /dev/null 2>&1
rm -f $file1 > /dev/null 2>&1
rm -f $file2 > /dev/null 2>&1

# We have to get the add-on itself


if [ $CLI_OUT == "1" ] ; then
   echo "download add-on from github.com : Please wait !"
fi

if [ $CLI_OUT == "1" ] ; then
   echo downloading addon
fi

sleep 7 |tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n       [ Downloading the Addon.Please wait ]           \n") & > /dev/null 2>&1

git clone https://github.com/swtor00/swtor-addon-to-tails > /dev/null 2>&1

if [ $? -eq 0 ] ; then
   if [ $CLI_OUT == "1" ] ; then
      echo "download add-on from github.com : done"
   fi
   sleep 5 |tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n       [ Download is finisehd ]           \n") & > /dev/null 2>&1
else
   if [ $CLI_OUT == "1" ] ; then
      echo "download add-on from github.com : failure ... We try a secound time to download"
   fi
   git clone https://github.com/swtor00/swtor-addon-to-tails > /dev/null 2>&1
   if [ $? -eq 0 ] ; then
      if [ $CLI_OUT == "1" ] ; then
         echo "download add-on from github.com : done"
      fi
      sleep 5 |tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n       [ Download is finisehd ]           \n") & > /dev/null 2>&1
   else
      if [ $CLI_OUT == "1" ] ; then
         echo "download add-on from github.com : failure"
      fi

      # It is not possible to download .. even after the secound possbile try do download it ... we do quit here ...

      zenity --error --width=600 \
      --text="\n\n         Error on downloading for the addon from github !       \n\n"\
      > /dev/null 2>&1
      exit 1
   fi
fi


# We move to the next level 

if [ $CLI_OUT == "1" ] ; then
   echo delete all restore-files from directory ~/Persistent
fi 

rm -rf ~/Persistent/*.tar.gz > /dev/null 2>&1
rm -rf ~/Persistent/*.md5 > /dev/null 2>&1


# Our fist step is to create all directorys

cd ~/Persistent/swtor-addon-to-tails/scripts

if [ $CLI_OUT == "1" ] ; then
   echo "Creating directorys : cli_directorys.sh"
fi 

./cli_directorys.sh > /dev/null 2>&1

if [ $CLI_OUT == "1" ] ; then
   echo "Creating directorys : done "
fi

cp ~/Persistent/backup/swtorcfg/*.cfg ~/Persistent/swtorcfg

cd ~/Persistent/swtorcfg

rm  swtor.cfg > /dev/null 2>&1

# all the remaining not deleted cfg files are user defined files
# restored from this backup

# Ok ... we do copy back swtor.cfg from github

cd ~/Persistent/scripts

./cli_update.sh > /dev/null 2>&1

# This update was only made to be sure, we have the default configuration
# file swtor.cfg

# Now we start setup.sh that is triggered to be in restore-mode

./setup.sh restore-mode
if [ $? -eq 0 ] ; then
   rm ~/Persistent/persistence.conf > /dev/null 2>&1
   rm -rf ~/Persistent/backup > /dev/null 2>&1

   cd ~/Persistent/swtor-addon-to-tails/tmp
  
   rm password > /dev/null 2>&1
   rm w-end > /dev/null 2>&1

   # We are ready here to start again 
   # we delete also this file ... the last remaining part of restore.sh 
   
   rm ~/Persistent/restore.sh > /dev/null 2>&1

else

   # We are not ready ...  
   exit 1

fi


