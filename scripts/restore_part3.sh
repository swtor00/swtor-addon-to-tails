

if [ ! -f ~/Persistent/stage2 ] ; then

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
      rm $file1 > /dev/null 2>&1
      echo 1 > ~/Persistent/stage2
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
else 
   if [ $CLI_OUT == "1" ] ; then
       echo "check for stage2 passed : done"
   fi
fi


if [ ! -f ~/Persistent/stage3 ] ; then

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
      rm $file2 > /dev/null 2>&1
      echo 1 > ~/Persistent/stage3  
   else
      if [ $CLI_OUT == "1" ] ; then
         echo "extracting backup file " $file2 " : failure !"
      fi 
      zenity --error --width=600 \
      --text="\n\n            Error on extracting tar file : '$file2' !       \n\n"\
      > /dev/null 2>&1
      exit 1
   fi
else
   if [ $CLI_OUT == "1" ] ; then
       echo "check for stage3 passed : done"
   fi
fi


if [ ! -f ~/Persistent/stage4 ] ; then

   mfile1=$(find ./home | grep $bfile1)
   mfile2=$(find ./home | grep $bfile2)

   mv $mfile1 .
   if [ $? -eq 0 ] ; then
      if [ $CLI_OUT == "1" ] ; then
         echo "moving "$mfile1" to ~/Persistent/ done"
      fi
      echo 1 > ~/Persistent/stage4 
   else 
      if [ $CLI_OUT == "1" ] ; then
         echo "moving "$mfile1" to ~/Persistent error"
      fi
      zenity --error --width=600 \
      --text="\n\n            Error on moving file : '$mfile1' !       \n\n"\
      > /dev/null 2>&1
      exit 1
   fi
else
   if [ $CLI_OUT == "1" ] ; then
       echo "check for stage4 passed : done"
   fi
fi


if [ ! -f ~/Persistent/stage5 ] ; then
   mv $mfile2 .
   if [ $? -eq 0 ] ; then
      if [ $CLI_OUT == "1" ] ; then
         echo "moving "$mfile2" to ~/Persistent/ done"
      fi
      echo 1 > ~/Persistent/stage5  
   else
      if [ $CLI_OUT == "1" ] ; then
         echo "moving "$mfile1" to ~/Persistent error"
      fi
      zenity --error --width=600 \
      --text="\n\n            Error on moving file : '$mfile2' !       \n\n"\
      > /dev/null 2>&1
   fi
else
   if [ $CLI_OUT == "1" ] ; then
       echo "check for stage5 passed : done"
   fi
fi 


if [ ! -f ~/Persistent/stage6 ] ; then

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

   echo 1 > ~/Persistent/stage6

else
   if [ $CLI_OUT == "1" ] ; then
       echo "check for stage6 passed : done"
   fi
fi 


if [ ! -f ~/Persistent/stage7 ] ; then
   if [ $checksumm1 == $checksumm2 ] ; then
      if [ $CLI_OUT == "1" ] ; then
         echo checksumm 02 is correct
      fi
      sleep 7 |tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n       [ Checksumms 01 and 02 are correct ]           \n")  > /dev/null 2>&1
      echo 1 > ~/Persistent/stage7  
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
else
   if [ $CLI_OUT == "1" ] ; then
       echo "check for stage7 passed : done"
   fi
fi


if [ ! -f ~/Persistent/stage8 ] ; then

   # Both provided md5 checksumms are correct ...we continue now

   if [ $CLI_OUT == "1" ] ; then
      echo "extracting backup file " $file2 " : please wait !"
   fi

   tar xzf $file2 > /dev/null 2>&1
   if [ $? -eq 0 ] ; then
      if [ $CLI_OUT == "1" ] ; then
         echo "extracting backup file " $file2 " : done"
      fi
      echo 1 > ~/Persistent/stage8  
   else
      if [ $CLI_OUT == "1" ] ; then
         echo "extracting backup file " $file2 " : failure !"
      fi
      zenity --error --width=600 \
      --text="\n\n            Error on extracting tar file : '$file2' !       \n\n"\
      > /dev/null 2>&1
      exit 1
   fi
else
   if [ $CLI_OUT == "1" ] ; then
       echo "check for stage8 passed : done"
   fi
fi


if [ ! -f ~/Persistent/stage9 ] ; then
   backup_folder=$(find ./home | grep backup | head -1)
   mv $backup_folder . > /dev/null 2>&1
      if [ $? -eq 0 ] ; then
         echo 1 > ~/Persistent/stage9
      else
         if [ $CLI_OUT == "1" ] ; then
            echo "moving " $backup_folder " to ~/Persistent : failure !"
         fi
         zenity --error --width=600 \
         --text="\n\n            Error moving file : '$backup_folder' to ~/Persistent !       \n\n"\
         > /dev/null 2>&1
         exit 1
      fi
else
   if [ $CLI_OUT == "1" ] ; then
       echo "check for stage9 passed : done"
   fi
fi


if [ ! -f ~/Persistent/stage10 ] ; then  
   rm -rf ./home > /dev/null 2>&1
   rm -f $file1 > /dev/null 2>&1
   rm -f $file2 > /dev/null 2>&1
   echo 1 > ~/Persistent/stage10
else
   if [ $CLI_OUT == "1" ] ; then
       echo "check for stage10 passed : done"
   fi
fi

   
if [ ! -f ~/Persistent/stage11 ] ; then

   # We have to get the add-on itself

   if [ $CLI_OUT == "1" ] ; then
      echo "download add-on from github.com : Please wait !"
   fi

   sleep 1200 |tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n       [ Downloading the Addon.Please wait ]           \n") & > /dev/null 2>&1

   git clone https://github.com/swtor00/swtor-addon-to-tails > /dev/null 2>&1

   if [ $? -eq 0 ] ; then
      sleep 1
      killall zenity  > /dev/null 2>&1
      sleep 1   
      sleep 5 |tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n       [ Download is finisehd ]           \n")  > /dev/null 2>&1
      echo 1 > ~/Persistent/stage11       
   else

       if [ $CLI_OUT == "1" ] ; then
          echo "download add-on from github.com : failure ... We try a secound time to download"
       fi

       git clone https://github.com/swtor00/swtor-addon-to-tails > /dev/null 2>&1
       
       if [ $? -eq 0 ] ; then     killall zenity
          sleep 1
          killall zenity  > /dev/null 2>&1
          sleep 1  
          sleep 5 |tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n       [ Download is finisehd ]           \n") > \
          /dev/null 2>&1
          echo 1 > ~/Persistent/stage11  
       else
          if [ $CLI_OUT == "1" ] ; then
             echo "download add-on from github.com : failure"
          fi

          sleep 1 
          killall zenity  > /dev/null 2>&1
          sleep 1

          # It is not possible to download .. even after 1200 secounds ... we do quit here ...

          zenity --error --width=600 \
          --text="\n\n         Error on downloading for the addon from github !       \n\n" > /dev/null 2>&1
          exit 1
       fi   
   fi
else
   if [ $CLI_OUT == "1" ] ; then
       echo "check for stage11 passed : done"
   fi
fi


if [ ! -f ~/Persistent/stage12 ] ; then

   # We move to the next level 

   if [ $CLI_OUT == "1" ] ; then
      echo delete all restore-files from directory ~/Persistent
   fi 

   rm -rf ~/Persistent/*.tar.gz > /dev/null 2>&1
   rm -rf ~/Persistent/*.md5 > /dev/null 2>&1

   echo 1 > ~/Persistent/stage12  
else
   if [ $CLI_OUT == "1" ] ; then
      echo "check for stage12 passed : done"
   fi
fi 


if [ ! -f ~/Persistent/stage13 ] ; then

   # Our fist step is to create all directorys

   cd ~/Persistent/swtor-addon-to-tails/scripts

   if [ $CLI_OUT == "1" ] ; then
      echo "Creating directorys : cli_directorys.sh"
   fi 

   ./cli_directorys.sh > /dev/null 2>&1

   if [ $CLI_OUT == "1" ] ; then
      echo "Creating directorys : done "  
   fi

   echo 1 > ~/Persistent/stage13
else
   if [ $CLI_OUT == "1" ] ; then
      echo "check for stage13 passed : done"
   fi
fi


if [ ! -f ~/Persistent/stage14 ] ; then

   cp ~/Persistent/backup/swtorcfg/*.cfg ~/Persistent/swtorcfg > /dev/null 2>&1
   cd ~/Persistent/swtorcfg > /dev/null 2>&1
   rm  swtor.cfg > /dev/null 2>&1

   #  We do copy back swtor.cfg from github

   cd ~/Persistent/scripts

   ./cli_update.sh > /dev/null 2>&1

   echo 1 > ~/Persistent/stage14
else
   if [ $CLI_OUT == "1" ] ; then
      echo "check for stage14 passed : done"
   fi
fi

# Now we start setup.sh that is triggered to be in restore-mode

./setup.sh restore-mode
if [ $? -eq 0 ] ; then
   rm ~/Persistent/persistence.conf > /dev/null 2>&1
   rm -rf ~/Persistent/backup > /dev/null 2>&1
   rm -f ~/Persistent/stage* > /dev/null 2>&1

   cd ~/Persistent/swtor-addon-to-tails/tmp
  
   rm password > /dev/null 2>&1
   rm w-end > /dev/null 2>&1

   # We are ready here to start again 
   # we delete also this file ... the last remaining part of restore.sh 
   
   rm ~/Persistent/restore.sh > /dev/null 2>&1

   sleep 7 |tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n       [ Restore is fnished. PLeasse reboot Tails ]           \n")  > /dev/null 2>&1
   
   exit 0
else

   # We are not ready yet.Restore mode had a failure 
  
   exit 1

fi


