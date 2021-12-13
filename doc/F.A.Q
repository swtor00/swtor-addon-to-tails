Is this addon a little helper to use a VPN within Tails ?
----------------------------------------------------------
No. We only use SSH to communicate with ohers Servers.  
Only SSH is used to create a local SOCK5 Server on Tails.


Do you provide a free SSH account with this Add-on ? 
----------------------------------------------------
No ... You have to create your own personal SSH-Accounts. 


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
into your known_hosts file. Therefore open a Terminal and let this happen by connecting once.


I would like to backup my persistent Data to a foreign host over SSH. What do I need for this  ? 
-------------------------------------------------------------------------------------------------

- A full featured mode SSH account (fullssh.sh) and a password less login. 
- rsync on the remote SSH-host
- A login with password for backup is not supported.
- You can still make Backups of your persistent Volume with the add-on
  but not transfer the backup to a other host.


What fullshell provider do you recommand as the author of this addon ? 
----------------------------------------------------------------------

My favorite is clear : https://www.freeshell.de
Write a postcard to Germany and you have full featured Shell acount with 20GB.


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

Replace the file predefined 'swtor-desktop-freezed.jpeg' inside the doc directory with your own
Desktop-Wallpaper.Of couse you should do this , prior to freezing the system.



Is there a other way to install the add-on instead of git ? 
----------------------------------------------------------- 

Simply No. 


Could the add-on read my data ? 
--------------------------------
Yes but only to create a backup of the persistent Volume. 


For what reason do we need a Repair-Stick after after the Backup was made ? 
----------------------------------------------------------------------------

If your SSH-provider do not allow password logins .... only stored keys to login. 
Without the right keys to store back to ~/.ssh you wouldn't have a chance to get 
copy back the backup you made. Also a empty known_hosts from a new tails maybe 
also a problem. 


My specific question isn't found here. What should I do ? 
---------------------------------------------------------

Write me a email to swtor00@protonmail.com 


Could you addon read my data ? 
 


 
 


  
 


 


