


if [ ! -f ~/Persistent/stage1c ] ; then

   # we calculate the md5 01 of the backup-file from the remote host

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
      sleep 5 |tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n       [ Checksumm 01 is correct ]           \n") > /dev/null 2>&1 
      rm $file1
      echo 1 > ~/Persistent/stage1c
   else
       echo "warning : calculated checksum 01 and the stored checksumm do not match !!!!!!!"
       echo "this tails backup is not valid !!!!"
       zenity --error --width=600 \
       --text="\n\n             Checksumm 01 is not correct. This Backup is not valid !       \n\n"\
       > /dev/null 2>&1
       exit 1
   fi
else
   if [ $CLI_OUT == "1" ] ; then
       echo "check for stage1c passed : done"
   fi
fi


if [ ! -f ~/Persistent/stage1d ] ; then

   # Get the password for decrypting the tar,gz file.
   # 3 x times wrong and this script will be terminated with the error-code 1

   menu=1
   while [ $menu -gt 0 ]; do
         if [ "$menu" -ge "4" ] ; then
            sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
            --text="\n\n           You had your 3 chances to decrypt the file ! The restore is now canceled !       \n\n" > /dev/null 2>&1)
            exit 1
         fi

         decryption_password=$(zenity --entry --text="Please type the phrase for the file decrypting " --title="Decrypting-Phrase" --hide-text)

         if [ $? -eq 0 ] ; then
            echo -n $decryption_password > /dev/shm/password1
            gpg -q --batch --passphrase-file /dev/shm/password1 --decrypt $file2 > tails_image.tar.gz
            if [ $? -eq 0 ] ; then
               if [ $CLI_OUT == "1" ] ; then
                  echo "Decryption of file ["$file2"] : done"
               fi
               cd ~/Persistent
               rm $file2 > /dev/null 2>&1
               rm dev/shm/password1 > /dev/null 2>&1
               if [ $CLI_OUT == "1" ] ; then
                  echo "File "$file2" deleted"
               fi
               file2=tails_image.tar.gz
               echo 1 > ~/Persistent/stage1d
               break

               exit 1
            else
               if [ $CLI_OUT == "1" ] ; then
                  echo "Failure with decryption ..."
               fi
               sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \ --text="\n\n          Password for decrypting was wrong !       \n\n" > /dev/null 2>&1)
               ((menu++))
            fi

         else
            ((menu++))
         fi
   done
else
   if [ $CLI_OUT == "1" ] ; then
       echo "check for stage1d passed : done"
   fi
fi


if [ ! -f ~/Persistent/stage1e ] ; then

   # we need to know the generated filenames inside the backup

   bfile2=$(tar -tvf $file2 | grep tar.gz | awk  {'print $6'} | xargs basename )
   bfile1=$(tar -tvf $file2 | grep md5 | awk  {'print $6'} | xargs basename )

   if [ $CLI_OUT == "1" ] ; then
      echo $bfile2
      echo $bfile1
   fi

   # we extract the unencrypted tar.gz right here (2 filenames)

   if [ $CLI_OUT == "1" ] ; then
      echo "extracting backup file " $file2 " : please wait !"
   fi
   tar xvzf $file2 > /dev/null 2>&1

   if [ $? -eq 0 ] ; then
      if [ $CLI_OUT == "1" ] ; then
         echo "extracting backup file " $file2 " : done"
      fi
      rm $file2 > /dev/null 2>&1
      echo 1 > ~/Persistent/stage1e
   else
      if [ $CLI_OUT == "1" ] ; then
         echo "extracting backup file " $file2 " : failure !"
      fi
      exit 1
   fi
else
   if [ $CLI_OUT == "1" ] ; then
       echo "check for stage1e passed : done"
   fi
fi


if [ ! -f ~/Persistent/stage1f ] ; then

   # we calculate the md5 02 of the backup-file from the remote host

   checksumm1=$(cat $bfile1)
   checksumm2=$(md5sum $bfile2 |  awk  {'print $1'})

   if [ $CLI_OUT == "1" ] ; then
      echo stored-----md5 02: $checksumm1
      echo calculated-md5 02: $checksumm2
   fi

   if [ $checksumm1 == $checksumm2 ] ; then
      if [ $CLI_OUT == "1" ] ; then
         echo checksumm 02 is correct
      fi
      sleep 5 |tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n       [ Checksumm 02 is correct ]           \n") > /dev/null 2>&1 
      rm $bfile1 > /dev/null 2>&1
      echo 1 > ~/Persistent/stage1f
   else
       echo "warning : calculated checksum 02 and the stored checksumm do not match !!!!!!!"
       echo "this tails backup is not valid !!!!"
       zenity --error --width=600 \
       --text="\n\n             Checksumm 02 is not correct. This Backup is not valid !       \n\n"\
       > /dev/null 2>&1
       exit 1
   fi
else
   if [ $CLI_OUT == "1" ] ; then
       echo "check for stage1f passed : done"
   fi
fi


if [ ! -f ~/Persistent/stage1g ] ; then

   # we extract the unencrypted tar.gz right here (2 filenames)

   if [ $CLI_OUT == "1" ] ; then
      echo "extracting backup file " $bfile2 " : please wait !"
   fi

   tar xvzf $bfile2 > /dev/null 2>&1

   if [ $? -eq 0 ] ; then
      if [ $CLI_OUT == "1" ] ; then
         echo "extracting backup file " $bfile2 " : done"
      fi
      rm $bfile2 > /dev/null 2>&1
      echo 1 > ~/Persistent/stage1g
   else
      if [ $CLI_OUT == "1" ] ; then
         echo "extracting backup file " $bfile2 " : failure !"
      fi
      exit 1
   fi
else
   if [ $CLI_OUT == "1" ] ; then
       echo "check for stage1g passed : done"
   fi
fi


if [ ! -f ~/Persistent/stage1h ] ; then

   # We need to find the gz.tar and the last md5 checksumm 

   mfile1=$(find ./home | grep tar.gz)
   mfile2=$(find ./home | grep md5check)

   if [ $CLI_OUT == "1" ] ; then
      echo $mfile1
      echo $mfile2
   fi

   mv $mfile1 ~/Persistent > /dev/null 2>&1
   mv $mfile2 ~/Persistent > /dev/null 2>&1

   rm -rf ~/Persistent/home > /dev/null 2>&1

   echo 1 > ~/Persistent/stage1h
else
   if [ $CLI_OUT == "1" ] ; then
       echo "check for stage1h passed : done"
   fi
fi




if [ ! -f ~/Persistent/stage1i ] ; then

   cd ~/Persistent

   file1=$(ls -al | grep md5check    | awk  {'print $9'})
   file2=$(ls -al | grep tar.gz | awk  {'print $9'})
   if [ $CLI_OUT == "1" ] ; then
      echo $file1
      echo $file2
   fi
   echo 1 > ~/Persistent/stage1i
else
   if [ $CLI_OUT == "1" ] ; then
       echo "check for stage1i passed : done"
   fi
fi



if [ ! -f ~/Persistent/stage1j ] ; then

   cd ~/Persistent

   # we calculate the md5 03 of the backup-file from the remote host

   checksumm1=$(cat $file1)
   checksumm2=$(md5sum $file2 |  awk  {'print $1'})

   if [ $CLI_OUT == "1" ] ; then
      echo stored-----md5 03: $checksumm1
      echo calculated-md5 03: $checksumm2
   fi

   if [ $checksumm1 == $checksumm2 ] ; then
      if [ $CLI_OUT == "1" ] ; then
         echo checksumm 03 is correct
      fi
      sleep 5 |tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n       [ Checksumm 03 is correct ]           \n") > /dev/null 2>&1 
      rm $file1 > /dev/null 2>&1
      echo 1 > ~/Persistent/stage1j
   else
       echo "warning : calculated checksum 03 and the stored checksumm do not match !!!!!!!"
       echo "this tails backup is not valid !!!!"
       zenity --error --width=600 \
       --text="\n\n             Checksumm 03 is not correct. This Backup is not valid !       \n\n"\
       > /dev/null 2>&1
       exit 1
   fi
else
   if [ $CLI_OUT == "1" ] ; then
       echo "check for stage1j passed : done"
   fi
fi



if [ ! -f ~/Persistent/stage1k ] ; then
   if [ $CLI_OUT == "1" ] ; then
      echo "extracting backup file " $file2 " : please wait !"
   fi
   tar xvzf $file2 > /dev/null 2>&1

   if [ $? -eq 0 ] ; then
      if [ $CLI_OUT == "1" ] ; then
         echo "extracting backup file " $file2 " : done"
      fi
      rm $file2 > /dev/null 2>&1
      echo 1 > ~/Persistent/stage1k
   else
      if [ $CLI_OUT == "1" ] ; then
         echo "extracting backup file " $file2 " : failure !"
      fi
      exit 1
   fi
else
   if [ $CLI_OUT == "1" ] ; then
       echo "check for stage1k passed : done"
   fi
fi 



if [ ! -f ~/Persistent/stage1l ] ; then

   # we move the backup folder here to the root of ~/Persistent

   backup_folder=$(find ./home | grep backup | head -1)
   mv $backup_folder . > /dev/null 2>&1
   rm -rf ./home > /dev/null 2>&1
   rm -f $file2 > /dev/null 2>&1
   echo 1 > ~/Persistent/stage1l

else
   if [ $CLI_OUT == "1" ] ; then
       echo "check for stage1l passed : done"
   fi
fi 



if [ ! -f ~/Persistent/stage2 ] ; then

   # We have to get the add-on itself

   if [ $CLI_OUT == "1" ] ; then
      echo "download add-on from github.com : Please wait !"
   fi

   sleep 3600 |tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n       [ Downloading the Addon.Please wait ]           \n") & > /dev/null 2>&1 &

   git clone https://github.com/swtor00/swtor-addon-to-tails

   if [ $? -eq 0 ] ; then
      sleep 1
      killall -s SIGINT zenity > /dev/null 2>&1
      sleep 1
      sleep 5 |tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n       [ Download is finished ]           \n")  > /dev/null 2>&1
      echo 1 > ~/Persistent/stage2
   else
       if [ $CLI_OUT == "1" ] ; then
          echo "download add-on from github.com : failure ... We try a secound time to download"
       fi

       git clone https://github.com/swtor00/swtor-addon-to-tails

       if [ $? -eq 0 ] ; then     killall zenity
          sleep 1
          killall -s SIGINT zenity > /dev/null 2>&1
          sleep 1
          sleep 5 |tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n       [ Download is finished ]           \n") > \
          /dev/null 2>&1
          echo 1 > ~/Persistent/stage2
       else
          if [ $CLI_OUT == "1" ] ; then
             echo "download add-on from github.com : failure"
          fi

          sleep 1
          killall -s SIGINT zenity > /dev/null 2>&1
          sleep 1

          # It is not possible to download .. even after 3600 secounds ... we do quit here ...

          zenity --error --width=600 \
          --text="\n\n         Error on downloading for the addon from github !       \n\n" > /dev/null 2>&1
          exit 1
       fi
   fi
else
   if [ $CLI_OUT == "1" ] ; then
       echo "check for stage2 passed : done"
   fi
fi



if [ ! -f ~/Persistent/stage3 ] ; then

   # Our fist step is to create all directorys

   cd ~/Persistent/swtor-addon-to-tails/scripts

   if [ $CLI_OUT == "1" ] ; then
      echo "Creating directorys : cli_directorys.sh"
   fi

   ./cli_directorys.sh > /dev/null 2>&1

   if [ $CLI_OUT == "1" ] ; then
      echo "Creating directorys : done "
   fi
   
   echo 1 > ~/Persistent/stage3
else
   if [ $CLI_OUT == "1" ] ; then
      echo "check for stage3 passed : done"
   fi
fi


if [ ! -f ~/Persistent/stage4 ] ; then

   cp ~/Persistent/backup/swtorcfg/*.cfg ~/Persistent/swtorcfg > /dev/null 2>&1
   cd ~/Persistent/swtorcfg > /dev/null 2>&1
   rm  swtor.cfg > /dev/null 2>&1

   #  We do copy back swtor.cfg from github

   cd ~/Persistent/scripts

   ./cli_update.sh > /dev/null 2>&1

   echo 1 > ~/Persistent/stage4
else
   if [ $CLI_OUT == "1" ] ; then
      echo "check for stage4 passed : done"
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

   killall zenity > /dev/null 2>&1

   sleep 3

   sleep 7 |tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" --text="\n       [ Restore is now fnished. Please reboot Tails ]           \n")  > /dev/null 2>&1


   # We are ready here to start again
   # we delete also this file ... the last remaining part of restore.sh

   sleep 3

   rm ~/Persistent/restore.sh > /dev/null 2>&1
   exit 0

else

   # We are not ready yet.Restore mode had a failure

   exit 1

fi




