
# we calculate the md5 01 of the backup-file

checksumm1=$(cat $file1)
checksumm2=$(md5sum $file2 |  awk  {'print $1'})

echo stored-----md5 01: $checksumm1
echo calculated-md5 01: $checksumm2


if [ $checksumm1 == $checksumm2 ] ; then
   echo checksumm 01 is correct
else
   echo warning : calculated checksum 01 and the stored checksumm do not match !!!!!!!
   exit 1
fi

# we need to know the generated filenames inside the backup

bfile2=$(tar -tvf $file2 | grep tar.gz | awk  {'print $6'} | xargs basename )
bfile1=$(tar -tvf $file2 | grep md5 | awk  {'print $6'} | xargs basename )

# we extract the unencrypted tar.gz right here (2 filenames)

tar xvzf $file2

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

echo stored-----md5 02: $checksumm1
echo calculated-md5 02: $checksumm2

if [ $checksumm1 == $checksumm2 ] ; then
   echo checksumm 02 is correct
else
   echo warning : calculated checksum 02 and the stored checksumm do not match !!!!!!!
   exit 1
fi

# Both provided md5 checksumms are correct ...we continue now

tar xvzf $file2

# we move the backup folder here to the root of ~/Persistent

backup_folder=$(find ./home | grep backup | head -1)

mv $backup_folder .

rm -rf ./home
rm -f $file1
rm -f $file2

# ok... we can copy back the data, but first we have to get the add-on itself

git clone https://github.com/swtor00/swtor-addon-to-tails





