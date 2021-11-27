I would like to test this addon only, what SSH-Provider should I choose ?

For a simple and cheap way to create a SSH-Account I would say here ... 

https://www.dewassh.net/server/SSH 

They provide a SSH account for free (at least for 3 Days) that is made in less than one minute.
The list of Countrys to create the account is wide. Create your own account for free and create
the file ~/Persistent/swtorssh.cfg and fill it like this little example below.

pfssh.sh     passwd Compress 4 2 143 9999   noshell LIiS-dewassh.net@us.serverkit.me   xxxxx           xxxxxx  USA          3-Day-account 

This is only a example. You have to fill it with you own data fron dewassh.net.(The username / server and port)


I would like to backup my persistent Data to a foreign host over SSH. What do I need for this  ? 

- A full featured mode SSH account (fullssh.sh) and a password less login. 
- A login with password for backup is not supported.


What fullshell provider do you recommand as the author of this addon ? 

My favorite is clear : https://www.freeshell.de

Write a postcard and you have full featured Shell acount with 20GB.


Are there any backdoors inside the add-on ? 

No. It is only shell-code (scripts) that is clear written and 
there a no backdoors in the scripts or the 2 provided profiles 
for chromium.


Is it possible to replace the file ~/Persistent/settings/tmp.tar.gz 
with my own chromium profiles ? 

Yes ... of course but be warned. If you replace the provided tmp.tar.gz 
with your own version createdm , on every update over git your own settings are 
overwritten. I do try to implement this feature. 
Just in case you aren't trusting my profiles. 
 





  
 


 


