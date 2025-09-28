Is it possible to play DRM content with Chromium ? 
--------------------------------------------------

With a standard installation with Debian it is not possible
to play drm content with chromium.


How do I upgrade from Version 6.19 to Version 7.00 ?
----------------------------------------------------

Prior to install Tails 7.0 we have to unfreeze the current system
6.19 Open a terminal inside the script folder.

./cli_unfreezing.sh

First download and install Tails 7.0 on a other USB 
disk. Then create a new empty persistent Volume.
Please activate the same options for the persistent volume 
like you did it with 6.X 
Restart the new Tails 7.0 with a network-connection and 
open a terminal : 

sudo /bin/bash 
Type the correct password

apt-get update 
apt-get install chromium 
apt-get install chromium-sandbox
apt-get install sshpass

Please restart Tails 7.0 now.

Insert the old system with 6.19 in a other free usb 
slot and open the persistent volume. 

1.) Copy all ssh-keys files to  /home/amnesia/.ssh
2.) Copy all bookmarks files to /home/amnesia/.mozilla/firefox/bookmarks
3.) copy all persistent files to /home/amnesia/persistent 

It should work now ....

Is this addon a little helper to use a VPN within Tails ?
----------------------------------------------------------
No. We only use SSH to communicate with others Servers.  
Only SSH is used to create a local SOCK5 Server on Tails.
There is no VPN involved. Some idiots from the redit/tails forum
may should read this file to know the big difference between a real 
VPN and a local socks5 proxy. 

Is it possible to use this addon without a persistent Volume ? 
--------------------------------------------------------------
No. You need a USB device and a persistent volume to run it. 
If you like it, you can run the medium without the persistent 
volume. 

Do you provide a free SSH account with this Add-on ? 
----------------------------------------------------
No ... You have to create your own personal SSH-Accounts.
There are plenty of options to create a free ssh-account.

I would like to test this addon only, what SSH-Provider should I choose ?
-------------------------------------------------------------------------

For a simple and cheap and easy way to create a SSH-Account I would say here ... 
Here are coming 2 samples of URL that provide SSH-Accounts for free.

https://www.xshellz.com/
https://www.dewassh.net/server/SSH 

They provide a SSH account for free (at least for 3 up to 10 Days) that is made in less than one minute.
The list of Countrys to create the wished SSH account is wide. Create your own account for free and create
the file ~/Persistent/swtorssh.cfg and fill it like in this 2 little examples below.

ON dewassh Host a valid entry would like this :

pfssh.sh     passwd Compress 4 2 143 9999   noshell LIiS-dewassh.net@us.serverkit.me   xxxxx           xxxxxx  USA          3-Day-account 

If you create a 10 day account with https://www.xshellz.com/ your entry could look this: 

fullssh.sh   passwd Compress 4 2 22  9999   noshell blabla@shell.xshellz.com	       xxxxx           xxxxxx  Canada 	    xshell-com
fullssh.sh   ssh-id Compress 4 2 22  9999   noshell blabla@shell.xshellz.com	       xxxxx           xxxxxx  Canada 	    xshell-com

This are only 3 examples. You have to fill it with you own data from the URL.
And please do not try to connect to the remote host over my script, until the remote host has been added 
into your own known_hosts file. Therefore open a Terminal and let this happen by connecting once.


I would like to backup my persistent Data from this addon to a foreign host over SSH. What do I need for this  ? 
-----------------------------------------------------------------------------------------------------------------

- A full featured mode SSH account (fullssh.sh) and a password less login. 
- rsync on the remote SSH-host. You may have to install rsync first if it is not installed.
- A login with password for the backup is not supported yet.
- You can still make a unencrypted Backups of your persistent Volume with the add-on
  but not transfer the backup to a other host.
- You can still encrypt the backup and use your on own way to encrypt it.

Please be warned by me. There are several Country on this world,that can demand
by law to force every password for a found encrypted stick or HD. 
In England and the USA it is common law to demand all password or keys.
So don't store the crpyted files inside your home !!!!!!

So ... Copy the backup to a other country. Far a way from your own country.

With 20GB of free space in German you could store plenty of Tails-Images ?

But be sure, you can restore back the files.

It would be wise to test it !!!!!

   
What fullshell provider do you recommand as the author of this addon ? 
----------------------------------------------------------------------

My favorite is clear : https://www.freeshell.de

Note : Since September 2024 the creator of this famous Website 
has disabled TCP forwarding over SSH for various reasons. 
I hope this feature is enabled soon again.Some stupid 
hackers used his server to attacking others system ....

In Germany all data-connections are stored for about 10 Weeks. 
Write a postcard to Germany and you have a full featured Shell account with 
20GB of HD space. This one is the best of all free shell-providers.

Little Note : If you are living in Germany, it may would be wise to 
store your backup in a other Country than Germany. 

Are there any backdoors inside the add-on ? 
--------------------------------------------
No. It is only pure shell-code (scripts) that is clear written and 
there a no backdoors inside the scripts or the 3 provided profiles 
for chromium.


Is it possible to replace the file ~/Persistent/settings/tmp.tar.gz with my own chromium profiles ?
---------------------------------------------------------------------------------------------------- 

Yes ... of course but be warned. If you replace the provided tmp.tar.gz 
with your own version created, on every update over git your own settings are 
overwritten. I do try to implement this feature. Just in case you aren't trusting my predefined profiles. 
 

I would like to use my own Desktop-Wallpaper as a Background in freezed-mode.Is this possible ?
--------------------------------------------------------------------------------------------- 

Replace the predefined file 'swtor-desktop-freezed.jpeg' inside the doc directory with your own
Desktop-Wallpaper.Of course you should do this , prior to freezing the system.
And the new Desktop-Wallpaper has also to be name 'swtor-desktop-freezed.jpeg'


Is there a other way to install the add-on instead of git ? 
----------------------------------------------------------- 

Simply No. 


Could the add-on read my data ? 
--------------------------------
Yes,but only to create a backup of the persistent Volume.
To be more specific .... Only files from the addon !
My addon is not spying on anything from you.  
My addon only reads the own data .... no other files !


For what reason do we need a Repair-Stick after after the Backup was made ? 
----------------------------------------------------------------------------

If your SSH-provider do not allow password logins and a ssh-login is only possible with keys,
it is important to save the used rsa key. 
Without the right keys to store back to ~/.ssh you wouldn't have any
chance to get copy back the backup you made. Also a empty known_hosts file from a
new tails maybe also a problem for some users.In any case that you backup to a remote host, 
please do copy the files from  ~/Persistent/personal-files/tails-repair-disk 
to a own stick and place this stick on a very secure place.   

You may have a other Tails with a persistent Volume, you could copy the 
files to this system ? 

Backup Tails ONE and transfer the backup to Tails TWO.
After the exchange over stick ... you can do  format that stick ONE that 
nobody can read the data left on device.
 

Is the backup of Persistence (since Tails 4.25) better than your backup ? 
-------------------------------------------------------------------------

Note : The current backup of Tails including the persistent volume has never been 
       so easy than with Tails 6.x or higher .... 

To be honest, the current Tails backup (6.8.1) is very easy to make and you 
just need a other USB drive. But there a maybe still a few reasons, to make 
a backup of your persistent volume over ssh.
 
- The backup itself is protected against manipulations with a md5 checksum.
- You can copy the files to any location as long this location 
  is secure. You may use a other Tails with persistent volume 
  to copy the backup to this other system. 

But be warned : 
The Backup will only backup all settings from activated
Persistent options including the following folders

- personal-files 
- swtorcfg 
- Tor-Browser 

The remaining files from the addon are not saved !
All files from the addon itself are not inside the backup.
This files will be fresh installed from github over
git.


Why is a administation password needet on every startup ? 
--------------------------------------------------------

Without a password you can not change the firewall to 
accept a local socks5 proxy on 127.0.0.1. You need also the password 
to install the software during setup.sh and if you would
like to backup persistent volume.


Why do I have to close all programs prior to backup ? 
-----------------------------------------------------

A locked file (by a Programm) can not be overwritten ! 
Depending on your own personal configuration of the 
Persistence Volume,you have to close.
 
- TOR Browser 
- Electrum Bitcoin Wallet 
- Thunderbird
- Pidgin
- Cleopatra  

After upgrading Tails, the system is not longer freezed.
What should I do now ?
--------------------------------------------------------
There a 2 ways possible to refreez it again. 

1. Open a terminal in the script folder and execute exactly in 
   this order this 2 shell-scripts.
   
   ./cli_tweak.sh 
   ./cli_freezing.sh 
   
Warning : The shell script cli_tweak.sh is only a template 
that can be customized if you wish it. 
Of course can you set all your personal settings by Hand and 
freez it again !


2.) Open a Terminal in the script folder and execute.

    ./swtor-menu.sh 

    Open menu "Utilitys & Help" -> Freezing the current state 

I can't start swtor-menu.sh because lockfile allready exists ?
-----------------------------------------------------------------
Open a terminal in the script folder and execute
  
./cli_delete_lockfile.sh  

And the lockfile error-message is gone.  


Are you involved in any way by "Anomymous" ? 
--------------------------------------------

No I'm not a member of Anoymous in any kind but I like 
the behavior AND fight for a free and uncensored internet.

We are Anonymous! 
We are Legion ! 
We do not forgive ! 
We do not forget ! 
Expect Us !   

Are you involved in any way by "Tails" ?
--------------------------------------------

No I'm just a user of Tails. I am using Tails since over 2014.


I have sometimes the message "Internet not ready ... " on startup ?
-------------------------------------------------------------------

Increase the the Value inside swtor.cfg
from TIMEOUT-TB:10 to TIMEOUT-TB:15 


I upgraded from Tail 4.29 to Tails 5.0 and now the addon isn't working anymore ?
---------------------------------------------------------------------------------
Yes. I know about this issue. You have to upgrade to the Version 5.0 
Open a terminal in the script folder and execute

./cli_update.sh 

After version 0.81 is installed, it works again.


Can the chromium browser be used without proxy ?
-------------------------------------------------
No ... 


My specific question isn't found here. What should I do ? 
---------------------------------------------------------

Write me a email to swtor00@protonmail.com 

Today .. On 31/12/21 I have received my first first feature 
request from user I don't know in person. It was very easy to fix it 
and the user hjhj65 don't need to change size of 
the renote Xclock after every update. Thanks hjhj65 
 


 
 
 


  
 


 


