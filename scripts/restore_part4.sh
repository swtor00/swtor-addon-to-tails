

# we calculate the md5 01 of the backup-file

checksumm1=$(cat $file1)
checksumm2=$(md5sum $file2 |  awk  {'print $1'})

echo stored-----md5 01: $checksumm1
echo calculated-md5 01: $checksumm2

if [ $checksumm1 == $checksumm2 ] ; then
   echo checksumm 01 is correct
else
   echo "warning : calculated checksum 01 and the stored checksumm do not match !!!!!!!"
   echo "this tails backup is not valid !!!!"
   exit 1
fi

# we need to know the generated filenames inside the backup

bfile2=$(tar -tvf $file2 | grep tar.gz | awk  {'print $6'} | xargs basename )
bfile1=$(tar -tvf $file2 | grep md5 | awk  {'print $6'} | xargs basename )


# we extract the unencrypted tar.gz right here (2 filenames)

echo "extracting backup file " $file2 " : please wait !"
tar xzf $file2 > /dev/null 2>&1

if [ $? -eq 0 ] ; then
   echo "extracting backup file " $file2 " : done"
else
   echo "extracting backup file " $file2 " : failure !"
   exit 1
fi

mfile1=$(find ./home | grep $bfile1)
mfile2=$(find ./home | grep $bfile2)

mv $mfile1 .
mv $mfile2 .

rm -rf ./home > /dev/null 2>&1
rm $file1 > /dev/null 2>&1
rm $file2 > /dev/null 2>&1

file1=$(ls -al | grep md5check    | awk  {'print $9'})
file2=$(ls -al | grep tar.gz | awk  {'print $9'})

# Get the password for decrypting ...
# 3 x times wrong and this script will be terminated
# with the error-code 1

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
          rm tails_image_tar.gz > /dev/null 2>&1
          gpg --batch --passphrase-file /dev/shm/password1 --decrypt $file2 > tails_image.tar.gz > /dev/null 2>&1
          if [ $? -eq 0 ] ; then
             echo "Decryption of file ["$file2"] : done"
             rm $file2 > /dev/null 2>&1
             rm dev/shm/password1 > /dev/null 2>&1
             echo "File "$file2" deleted"
             file2=tails_image.tar.gz
             break
          else
              echo "Failure with decryption ..."
              sleep 5 | tee >(zenity --progress --pulsate --no-cancel --auto-close --title="Information" \
             --text="\n\n          Password for decrypting was wrong !       \n\n" > /dev/null 2>&1)
              ((menu++))
          fi

     else
         ((menu++))
     fi
done


# we calculate the md5 02 of the backup-file that we extracted above

checksumm1=$(cat $file1)
checksumm2=$(md5sum $file2 |  awk  {'print $1'})

echo stored-----md5 02: $checksumm1
echo calculated-md5 02: $checksumm2

if [ $checksumm1 == $checksumm2 ] ; then
   echo checksumm 02 is correct
else
   echo "warning : calculated checksum 02 and the stored checksumm do not match !!!!!!!"
   echo "this tails backup is not valid !!!!"
   exit 1
fi

# Both provided md5 checksumms are correct ...we continue now

echo "extracting backup file " $file2 " : please wait !"

tar xzf $file2 > /dev/null 2>&1

if [ $? -eq 0 ] ; then
   echo "extracting backup file " $file2 " : done"
else
   echo "extracting backup file " $file2 " : failure !"
   exit 1
fi



# we move the backup folder here to the root of ~/Persistent

backup_folder=$(find ./home | grep backup | head -1)
mv $backup_folder . > /dev/null 2>&1
rm -rf ./home > /dev/null 2>&1
rm -f $file1 > /dev/null 2>&1
rm -f $file2 > /dev/null 2>&1

# We have to get the add-on itself

echo "download add-on from github.com : Please wait !"

git clone https://github.com/swtor00/swtor-addon-to-tails > /dev/null 2>&1

if [ $? -eq 0 ] ; then
   echo "download add-on from github.com : done"
else
   echo "download add-on from github.com : failure ... We try a secound time to download"
   git clone https://github.com/swtor00/swtor-addon-to-tails > /dev/null 2>&1
   if [ $? -eq 0 ] ; then
      echo "download add-on from github.com : done"
   else
      echo "download add-on from github.com : failure"
      exit 1
   fi
fi

# Our fist step is to create all directorys

cd ~/Persistent/swtor-addon-to-tails/scripts

echo "Creating directorys : cli_directorys.sh"

./cli_directorys.sh > /dev/null 2>&1

echo "Creating directorys : done "

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

   rm ~/Persistent/id_rsa > /dev/null 2>&1
   rm ~/Persistent/id_rsa.pub > /dev/null 2>&1
   rm ~/Persistent/known_hosts > /dev/null 2>&1

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


