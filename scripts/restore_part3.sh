

# we calculate the md5 01 of the backup-file

checksumm1=$(cat $file1)
checksumm2=$(md5sum $file2 |  awk  {'print $1'})

echo
echo stored-----md5 01: $checksumm1
echo calculated-md5 01: $checksumm2
echo

if [ $checksumm1 == $checksumm2 ] ; then
   echo checksumm 01 is correct
   echo
else
   echo warning : calculated checksum 01 and the stored checksumm do not match !!!!!!!
   echo this tails backup is not valid !!!!
   exit 1
fi

# we need to know the generated filenames inside the backup

bfile2=$(tar -tvf $file2 | grep tar.gz | awk  {'print $6'} | xargs basename )
bfile1=$(tar -tvf $file2 | grep md5 | awk  {'print $6'} | xargs basename )

# we extract the unencrypted tar.gz right here (2 filenames)

echo
echo "extracting backup file " $file2 " : please wait !"
echo
tar xvzf $file2

if [ $? -eq 0 ] ; then
   echo "extracting backup file " $file2 " : done"
   echo
else
   echo "extracting backup file " $file2 " : failure !"
   exit 1
fi

mfile1=$(find ./home | grep $bfile1)
mfile2=$(find ./home | grep $bfile2)

mv $mfile1 .
mv $mfile2 .

rm -rf ./home
rm $file1
rm $file2

file1=$(ls -al | grep md5check    | awk  {'print $9'})
file2=$(ls -al | grep tar.gz | awk  {'print $9'})

# we calculate the md5 02 of the backup-file that we extracted above

checksumm1=$(cat $file1)
checksumm2=$(md5sum $file2 |  awk  {'print $1'})

echo
echo stored-----md5 02: $checksumm1
echo calculated-md5 02: $checksumm2
echo

if [ $checksumm1 == $checksumm2 ] ; then
   echo checksumm 02 is correct
   echo
else
   echo warning : calculated checksum 02 and the stored checksumm do not match !!!!!!!
   echo this tails backup is not valid !!!!
   exit 1
fi

# Both provided md5 checksumms are correct ...we continue now

echo
echo "extracting backup file " $file2 " : please wait !"
echo
tar xvzf $file2

if [ $? -eq 0 ] ; then
   echo "extracting backup file " $file2 " : done"
   echo
else
   echo "extracting backup file " $file2 " : failure !"
   exit 1
fi



# we move the backup folder here to the root of ~/Persistent

backup_folder=$(find ./home | grep backup | head -1)

mv $backup_folder .

rm -rf ./home
rm -f $file1
rm -f $file2


# We have to get the add-on itself

echo
echo "download add-on from github.com : Please wait !"
echo

git clone https://github.com/swtor00/swtor-addon-to-tails

if [ $? -eq 0 ] ; then
   echo "download add-on from github.com : done"
   echo
else
   echo "download add-on from github.com : failure ... We try a secound time to download"
   git clone https://github.com/swtor00/swtor-addon-to-tails
   if [ $? -eq 0 ] ; then
      echo "download add-on from github.com : done"
      echo
   else 
      echo "download add-on from github.com : failure"
      exit 1
   fi
fi


# Our fist step is to create all directorys

cd ~/Persistent/swtor-addon-to-tails/scripts

echo
echo "Creating directorys : cli_directorys.sh"
echo

./cli_directorys.sh

echo
echo "Creating directorys : done "

cp ~/Persistent/backup/swtorcfg/*.cfg ~/Persistent/swtorcfg

cd ~/Persistent/swtorcfg

rm  swtor.cfg > /dev/null 2>&1

# all the remaining not deleted cfg files are user defined files 
# restored from this backup

# Ok ... we do copy back swtor.cfg from github

cd ~/Persistent/scripts

./cli_update.sh

# Now we start setup.sh that is triggered to be in restore-mode 

./setup.sh restore-mode








