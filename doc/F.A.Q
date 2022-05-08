Is this addon a little helper to use a VPN within Tails ?
----------------------------------------------------------
No. We only use SSH to communicate with ohers Servers.  
Only SSH is used to create a local SOCK5 Server on Tails.
There is no VPN involved. Some idiots from redit/tails forum
may should read this file to know the difference between a real 
VPN and a local socks5 proxy. 

Do you provide a free SSH account with this Add-on ? 
----------------------------------------------------
No ... You have to create your own personal SSH-Accounts.
There are plenty of options to create a free ssh-account.


I would like to test this addon only, what SSH-Provider should I choose ?
-------------------------------------------------------------------------

For a simple and cheap and easy way to create a SSH-Account I would say here ... 

https://www.dewassh.net/server/SSH 

They provide a SSH account for free (at least for 3 Days) that is made in less than one minute.
The list of countrys to create the wished SSH account is wide. Create your own account for free and create
the file ~/Persistent/swtorssh.cfg and fill it like this little example below.

pfssh.sh     passwd Compress 4 2 143 9999   noshell LIiS-dewassh.net@us.serverkit.me   xxxxx           xxxxxx  USA          3-Day-account 

This is only a example. You have to fill it with you own data fron dewassh.net.(The username / server and port)
And please do not try to connect to the remote host over my script, until the remote host has been added 
into your own known_hosts file. Therefore open a Terminal and let this happen by connecting once.


I would like to backup my persistent Data to a foreign host over SSH. What do I need for this  ? 
-------------------------------------------------------------------------------------------------

- A full featured mode SSH account (fullssh.sh) and a password less login. 
- rsync on the remote SSH-host
- A login with password for backup is not supported.
- You can still make unencrypted Backups of your persistent Volume with the add-on
  but not transfer the backup to a other host.
- You can still encrypt the backukup and use your on tool to encrypt.

Please be warned by me. There are Countrys on this world,that can demand
by law to force every passwword for a found encrypted stick or HD. 
In England and the USA it is common law to demand all password or keys.

So ... Copy the backup to a other country. Far a way froum your own country.

He, with 20GB space you could store plenty of Tails-Images ?

But be sure, you can restore back the files.


   
What fullshell provider do you recommand as the author of this addon ? 
----------------------------------------------------------------------

My favorite is clear : https://www.freeshell.de

In Germany all data-connections are stored for about 10 Weeks. 
Write a postcard to Germany and you have full featured Shell acount with 
20GB of HD space. This one is the best of all free shell-providers.

Little Note : If you are living in Germany, it may would be wise to 
store your backup in Switzerland. 

Are there any backdoors inside the add-on ? 
--------------------------------------------
No. It is only pure shell-code (scripts) that is clear written and 
there a no backdoors inside the scripts or the 2 provided profiles 
for chromium.


Is it possible to replace the file ~/Persistent/settings/tmp.tar.gz with my own chromium profiles ?
---------------------------------------------------------------------------------------------------- 

Yes ... of course but be warned. If you replace the provided tmp.tar.gz 
with your own version created, on every update over git your own settings are 
overwritten. I do try to implement this feature. Just in case you aren't trusting my predefined profiles. 
 


I would like to use my own Desktop-Wallpaper as a Background in freezed-mode.Is this possible ?
--------------------------------------------------------------------------------------------- 

Replace the predefined file 'swtor-desktop-freezed.jpeg' inside the doc directory with your own
Desktop-Wallpaper.Of couse you should do this , prior to freezing the system.



Is there a other way to install the add-on instead of git ? 
----------------------------------------------------------- 

Simply No. 


Could the add-on read my data ? 
--------------------------------
Yes,but only to create a backup of the persistent Volume.
My addon is not spying on anything from you.  


For what reason do we need a Repair-Stick after after the Backup was made ? 
----------------------------------------------------------------------------

If your SSH-provider do not allow password logins and  a ssh-login only with keys
is possible. Without the right keys to store back to ~/.ssh you wouldn't have any
chance to get copy back the backup you made. Also a empty known_hosts file from a
new tails maybe also a problem for some users.In any case that you backup to a remote host, 
please do copy the files from  ~/Persistent/personal-files/tails-repair-disk 
to a seperate stick and place this stick on a very secure place.   

You may have a secound Tails with persistent Volume, you could copy the 
files to this secound system ? 

Backup Tails stick ONE and transfer the backup to Tailstick TWO.
After the exchange over stick ... you do securly format that stick that 
nobody can read the data left on device.
 

Is the backup of Persistence (since Tails 4.25) better than your backup ? 
-------------------------------------------------------------------------

I guess No because I don't need a secound stick with the same equal size to copy.
I only backup all files from the Persistent volume. The transfer to a foreign
host is also not included in the Tails backup solution.
But every user has to make this decission for himself.

- The backup integrated into Tails is a online-backup
  to a other USB Stick
- The backup is fast and works perfect but you could copy 
  the persistent Volume of Tails 4.25 to a empty persistent 
  of Tails 4.23 as a example,that could lead to a internal problem.

- The backup integrated into the addon works as a offline-backup. 
- The backup itself is protected against manipulations with a md5 checksum.
- You can copy the files to any location as long this location 
  is secure. You may use a secound Tails with persistent volume 
  to copy the backup to this other system. 


Why is a administation password needet on every startup ? 
--------------------------------------------------------

Wihtout a password you can not change the firewall to 
accept a local socks5 proxy. You need also the password 
to install the software during setup.sh and if you would
like to backup persistent volume.


Why do I have to close all programs prior to backup ? 
-----------------------------------------------------

A locked file (by a Programm) can not be transfered. 
Depending on your own personal configuration of the 
Persistence Volume,you have to close.
 
- TOR Browser 
- Electrum Bitcoin Wallet 
- Thunderbird
- Pidgin
- Cleopatra  

After upgrading Tails, the system is not longer freezed.
What should I do ?
--------------------------------------------------------
There a 2 ways possible to freez it again. 

1. Open a terminal in the script folder and execute exactly in 
   this order 
   ./cli_tweak.sh 
   ./cli_freezing.sh 


2.) Open a Terminal in the script folder and execute.

    ./swtor-mennu.sh 

    Open menu "Utilitys & Help" -> Freezing the current state 


I can't start swtor-menu.sh because lockfile allready exists ?
-----------------------------------------------------------------
Open a terminal in the script folder and execute
  
./cli_delete_lockfile.sh  

And the lockfile error-message is gone.  


Are you involved in any way by "Anomymous" ? 
--------------------------------------------

No I'm not a member of Anoymous in any kind but I like 
theyr behavior AND fight for a free and unccensored internet.

We are Anonymous! 
We are Legion ! 
We do not forgive ! 
We do not forget ! 
Expect Us !   

I have sometimes the message "Internet not ready ... " on startup ?
-------------------------------------------------------------------

Increase the the Value inside swtor.cfg
from TIMEOUT-TB:10 to TIMEOUT-TB:15 


I upgraded from Tail 4.29 to Tails 5.0 and now the addon isn't working anymore ?
---------------------------------------------------------------------------------
Yes. I know about this issue. You have to upgrade to the vesion 5.0 $
Open a terminal in the script folder and execute

./cli_update.sh 

After version 0.81 is installed, it works again.


My specific question isn't found here. What should I do ? 
---------------------------------------------------------

Write me a email to swtor00@protonmail.com 

Today .. On 31/12/21 I have received my first first feature 
request from user I don't know in person. It was easy to inplement 
and the user hjhj65 don't need to change size of 
the renote Xclock after every update. Thanks hjhj65 
 


 
 


  
 


 


