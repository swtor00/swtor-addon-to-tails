================================================================================
  swtor-addon-to-tails · Frequently Asked Questions
  Version 0.91 · Build 20587
================================================================================

This document answers the most common questions about the addon.
If your question is not listed here, write to: swtor00@protonmail.com

--------------------------------------------------------------------------------
TABLE OF CONTENTS
--------------------------------------------------------------------------------

  1.  GENERAL
  2.  REQUIREMENTS & COMPATIBILITY
  3.  INSTALLATION & FIRST SETUP
  4.  CONFIGURATION (swtor.cfg)
  5.  SSH CONNECTIONS & PROVIDERS
  6.  BROWSER
  7.  SECURITY & PRIVACY
  8.  BACKUP & RESTORE
  9.  FREEZING THE SYSTEM
  10. UPDATING THE ADDON
  11. TROUBLESHOOTING
  12. ABOUT THE PROJECT


================================================================================
  1. GENERAL
================================================================================

What does this addon actually do ?
-----------------------------------
This addon establishes an SSH connection to a remote server and creates a
local SOCKS5 proxy on port 9999 on your Tails machine. Chromium is then
launched and configured to route all traffic through this local proxy.

Crucially: the SSH connection itself is always routed through the Tor
network. Your real IP address is never exposed to the SSH server.
The only IP address the SSH server operator ever sees is the IP of the
Tor exit node.

  Your Tails  ->  Tor network  ->  Exit Node  ->  SSH tunnel  ->  Your SSH server  ->  Internet

The result: your web traffic exits via your SSH server, with two layers
of separation between you and the destination — Tor and the SSH tunnel.

Is this addon a VPN ?
----------------------
No. There is no VPN software involved at any point. The addon uses
standard SSH to create a SOCKS5 proxy. This is a fundamentally different
technology from a VPN.

A VPN encrypts all traffic at the network layer and routes it through
a VPN server. A SOCKS5 proxy is an application-layer proxy that only
the configured application (in this case Chromium) uses.

Anyone who tells you "SSH tunnel = VPN" does not understand networking.

What is the difference between this addon and the Tor Browser in Tails ?
-------------------------------------------------------------------------
The Tor Browser routes traffic through the Tor network (three anonymising
hops). This addon routes Chromium through the Tor network AND then through
your SSH server. Both tools use Tor — the difference is what happens after
the Tor exit node.

With the Tor Browser, the exit node connects directly to the destination.
With this addon, the exit node connects to your SSH server first, and the
SSH server then connects to the destination.

This means the destination website sees your SSH server's IP, not a known
Tor exit node IP. This is useful when a website blocks Tor exit nodes.

Tor Browser:  Tails -> Tor (3 hops) -> Exit Node -> Destination
This addon:   Tails -> Tor (3 hops) -> Exit Node -> SSH server -> Destination

Neither tool is strictly "better" — they serve different purposes.
This addon does not replace Tor. It extends it.

Is this addon free ?
---------------------
Yes. The addon is free and open source under the GNU General Public
License Version 2. The source code is entirely readable shell scripts
and Python.

Does the addon require payment ?
----------------------------------
No. The addon itself is free. You do however need an SSH account on a
remote server. SSH accounts can be free (see Section 5) or paid.

Can I use this addon on a regular Linux system instead of Tails ?
-----------------------------------------------------------------
No. The addon is specifically written for Tails and relies on the Tails
filesystem structure, the persistent volume, the Tor network for the
initial connection, and Tails-specific tools and paths. It will not
work on a standard Debian or Ubuntu system without significant modification.

Are you affiliated with the Tails project ?
--------------------------------------------
No. The author is an independent developer who has been using Tails since
2014. This addon is not endorsed or supported by the Tails project.

Are you affiliated with the Anonymous collective ?
---------------------------------------------------
No. The author is not a member of Anonymous in any formal way. The author
does however share the conviction that the internet should remain free
and uncensored.

  We are Anonymous.
  We are Legion.
  We do not forgive.
  We do not forget.
  Expect us.


================================================================================
  2. REQUIREMENTS & COMPATIBILITY
================================================================================

What are the system requirements ?
------------------------------------
- A USB drive with Tails 7.0 or higher installed
- A Persistent Volume on that USB drive with these options activated:
    * SSH (openssh-client)
    * Additional Software
    * Dotfiles (recommended — required for autostart)
- At least one SSH account on a remote server
- The Tails administration password must be set at the greeter screen
- An internet connection (Tor must be running before the addon starts)

Which version of Tails is supported ?
----------------------------------------
Tails 7.0 and higher. Older versions are no longer supported.
If you are still running Tails 6.x, see Section 2 (Upgrading).

Does the addon work with Tails on a DVD or live-boot without a USB stick ?
---------------------------------------------------------------------------
No. You need a USB drive with a Persistent Volume. A DVD or a system
booted from ISO without persistence cannot run this addon.

Do I need a Persistent Volume ?
---------------------------------
Yes. Without a Persistent Volume it is impossible to save your SSH
keys, your configuration, your browser profiles, and your bookmarks
between sessions. The addon will not work without one.

Does the addon work without setting an administration password at startup ?
---------------------------------------------------------------------------
No. The administration password is required to:
- Modify the firewall to allow the local SOCKS5 proxy on 127.0.0.1
- Install software packages during setup
- Create a backup of the Persistent Volume

Without a password set at the greeter screen, swtor-init.sh will abort
immediately with an error.

How do I upgrade from Tails 6.x to Tails 7.0 ?
-------------------------------------------------
Before doing anything, unfreeze your current system first:

  ./cli_unfreezing.sh

Then reboot.

Next, download Tails 7.0 and install it on a second USB drive. Create
a new empty Persistent Volume on it. Activate the same Persistent
options you had on your old system.

Restart Tails 7.0 with a network connection and open a terminal:

  sudo /bin/bash
  (enter your password)

  apt-get update
  apt-get install chromium
  apt-get install chromium-sandbox
  apt-get install sshpass

Restart Tails 7.0 again. Then insert your old USB drive and open its
Persistent Volume. Copy the following:

  1. All SSH key files    → /home/amnesia/.ssh
  2. All bookmark files  → /home/amnesia/.mozilla/firefox/bookmarks
  3. All Persistent files → /home/amnesia/Persistent

The addon should now work on Tails 7.0.


================================================================================
  3. INSTALLATION & FIRST SETUP
================================================================================

How do I install the addon for the first time ?
------------------------------------------------
Open a terminal in your Persistent folder and run:

  cd ~/Persistent
  git clone https://github.com/swtor00/swtor-addon-to-tails
  cd swtor-addon-to-tails/scripts
  ./cli_directorys.sh
  ./swtor-setup.sh

swtor-setup.sh will guide you interactively through the rest.

Is there another way to install the addon instead of using git ?
-----------------------------------------------------------------
No. Git is the only supported installation method. It allows you to
easily update the addon and ensures file integrity.

Can I run swtor-setup.sh more than once ?
------------------------------------------
swtor-setup.sh is designed to run only once on a clean system.
Running it again on an existing installation may overwrite your
configuration files. If you need to re-run setup after a problem,
back up your swtorssh.cfg and swtor.cfg first, then run it and
restore your files afterwards.

What does cli_directorys.sh do exactly ?
-----------------------------------------
It creates the required symlinks between the addon's script directory
and your Persistent folder. Without these symlinks the scripts
cannot find their configuration files and the installation is incomplete.

Always run cli_directorys.sh before swtor-setup.sh on a fresh installation.

What software packages does the addon install ?
------------------------------------------------
During setup, the following packages are installed:

  - chromium           The Chromium browser
  - chromium-sandbox   Required sandbox component for Chromium
  - sshpass            Allows passing SSH passwords non-interactively

These packages are installed via Additional Software so that they
survive reboots without requiring a reinstallation each time.

Do I need to add my SSH server to known_hosts before using the addon ?
-----------------------------------------------------------------------
Yes. Before using any SSH connection script for the first time, you must
connect to the remote host manually at least once so that its host key
is added to ~/.ssh/known_hosts.

Open a terminal and connect manually:

  ssh user@yourserver.com

Confirm the host key fingerprint and type "yes". After this, the
addon can connect without prompting.

How do I set up the application menu entries ?
------------------------------------------------
The addon can add three entries to the Tails application menu:
swtor-init, swtor-setup, and swtor-menu. Two Debian packages are
provided in the deb/ directory (debdir00 and debdir01). Install the
one that suits you:

  - debdir00: Opens the script in a new terminal window
  - debdir01: Runs the script silently without a terminal window

Install with:
  cd ~/Persistent/swtor-addon-to-tails/deb/debdir00
  sudo dpkg -i *.deb


================================================================================
  4. CONFIGURATION (swtor.cfg)
================================================================================

Where is the main configuration file ?
----------------------------------------
  ~/Persistent/swtorcfg/swtor.cfg

This file is created by swtor-setup.sh. Edit it with any text editor.

Where is the SSH server configuration file ?
---------------------------------------------
  ~/Persistent/swtorcfg/swtorssh.cfg

Each line in this file defines one SSH connection. See Section 5
for the format and examples.

What are the most important settings in swtor.cfg ?
----------------------------------------------------

  GUI-LINKS:YES           Adds entries to the Tails application menu.
                          Set to NO if you prefer to run scripts from terminal.

  BROWSER-SOCKS5:YES      Enables the Chromium browser via the SOCKS5 proxy.
                          Set to NO if you only want the SSH tunnel without
                          the browser.

  TIMEOUT-TB:10           How many seconds swtor-init.sh waits for a Tor
                          connection on startup before giving up. Increase
                          this if you frequently see "Internet not ready".
                          Recommended value on slow connections: 20 or higher.

  TIMEOUT-SSH:8           How many seconds the addon waits for an SSH
                          connection to establish. Increase on slow or
                          distant servers.

  TERMINAL-VERBOSE:NO     Set to YES to show detailed debug output in the
                          terminal. Useful for troubleshooting failed
                          connections.

  AUTOCLOSE-BROWSER:YES   Set to YES to close Chromium automatically when
                          the SSH connection drops. Recommended.

  XCLOCK-SIZE:180         Size in pixels of the remote X11 clock window
                          displayed when connected. Purely cosmetic.

  BACKUP-FIXED-PROFILE:NO Include the fixed Chromium profile in backups.
                          Enable this if you have customised the fixed
                          profile and want to preserve it.

  BACKUP-APT-LIST:NO      Include the apt package cache in backups.
                          This adds approximately 500 MB to the backup size.
                          Only enable if you know you need it.

  CHECK-EMPTY-SSH:NO      Show a warning on startup if ~/.ssh is empty.
                          Useful as a reminder if you have not yet copied
                          your SSH keys to the new system.

Can I change settings while the addon is running ?
---------------------------------------------------
Yes, but most settings are only read at startup or when a script is
launched. Changes to TIMEOUT-TB and TIMEOUT-SSH take effect the next
time you start swtor-init or connect to a server.

Changes to XCLOCK-SIZE take effect the next time you connect.
Changes to TERMINAL-VERBOSE take effect immediately on the next script run.


================================================================================
  5. SSH CONNECTIONS & PROVIDERS
================================================================================

What SSH connection modes are available ?
------------------------------------------

  fullssh.sh              SSH tunnel, key-based authentication (recommended)
  fullssh-interactive.sh  SSH tunnel, password entered interactively
  chainssh.sh             Two-hop SSH chain through two servers, key-based
  pfssh-interactive.sh    Port forwarding, password authentication

Key-based authentication is always recommended over password authentication.
It is both more secure and more reliable within the addon.

What is the format of swtorssh.cfg ?
--------------------------------------
Each line defines one server. The fields are separated by spaces or tabs:

  <script> <auth> <compress> <ip-version> <ssh-ver> <port> <local-port>
  <mode> <user@host> <res> <backup-flag> <country> <description>

Example — key-based full SSH connection:
  fullssh.sh  ssh-id  Compress  4  2  22  9999  noshell  user@myserver.com  xxxxx  xxxxxx  Germany  my-server

Example — password-based connection:
  fullssh.sh  passwd  Compress  4  2  22  9999  noshell  user@myserver.com  xxxxx  xxxxxx  Canada  cheap-vps

Example — non-standard port:
  fullssh.sh  ssh-id  Compress  4  2  2222  9999  noshell  user@myserver.com  xxxxx  xxxxxx  USA  port-2222

Example — two-hop chain:
  chainssh.sh  ssh-id  Compress  4  2  22  9999  noshell  user@hop1.com+user@hop2.com  xxxxx  xxxxxx  France  two-hop

Do I need to provide my own SSH account ?
------------------------------------------
Yes. The addon does not provide any SSH accounts. You need to create
your own. See the next question for free options.

What SSH provider do you recommend for testing ?
-------------------------------------------------
For a quick and free test account, the following providers offer
free SSH access (typically 3 to 10 days):

  https://www.xshellz.com/          10-day free shell accounts
  https://www.dewassh.net/           3-day free SSH accounts

Example entry for a dewassh account:
  pfssh.sh  passwd Compress 4 2 143 9999  noshell  LIiS-dewassh.net@us.serverkit.me  xxxxx  xxxxxx  USA  3-day-account

Example entry for xshellz (password):
  fullssh.sh  passwd Compress 4 2 22 9999  noshell  user@shell.xshellz.com  xxxxx  xxxxxx  Canada  xshell-passwd

Example entry for xshellz (key-based):
  fullssh.sh  ssh-id Compress 4 2 22 9999  noshell  user@shell.xshellz.com  xxxxx  xxxxxx  Canada  xshell-key

Note: Always add the server to your known_hosts file manually before
using it with the addon (see Installation section).

What paid SSH provider does the author recommend ?
---------------------------------------------------
The author's personal recommendation is:

  https://www.freeshell.de

This is a German provider offering full shell accounts with 40 GB of
disk space, reached by sending a postcard to Germany (truly).

Important note: Since September 2024 the operator has disabled TCP
port forwarding over SSH due to abuse by third parties. Check their
current status before signing up if SSH tunneling is your primary use case.

Important note for German residents: All data connections in Germany
are stored for approximately 10 weeks by law. If this concerns you,
choose a server in another country and store your backup there too.

Can I use multiple SSH servers in swtorssh.cfg ?
-------------------------------------------------
Yes. Add one line per server. When you start a connection via
swtor-menu, a selection dialog appears listing all configured servers.
You can switch between them freely.

Can I use IPv6 for SSH connections ?
--------------------------------------
No. Tails disables IPv6 completely for security and anonymity reasons.
All network traffic, including SSH connections, uses IPv4 exclusively.
The ip-version field in swtorssh.cfg must always be set to 4.

Can I use a non-standard SSH port ?
-------------------------------------
Yes. Set the port field in swtorssh.cfg to the port your server
uses (for example 443, 2222, or any other port).

What is a two-hop chain (chainssh.sh) and when would I use it ?
----------------------------------------------------------------
A two-hop chain connects through two SSH servers in sequence,
and like all connections in this addon, always routed through Tor first:

  Tails  ->  Tor (3 hops)  ->  Exit Node  ->  SSH Server A  ->  SSH Server B  ->  Internet

This adds an extra layer of separation on top of Tor. Server A sees only
the Tor exit node IP. Server B sees only Server A's IP address.
Neither server can identify you or trace the connection back to your
Tails machine.

Use this when you want an additional hop between yourself and the
exit point. Both servers must have your SSH key installed.

Note: There was a typo in chainssh.sh ($comnand1 instead of $command1)
that has been fixed in the current version.

What does "noshell" mean in the swtorssh.cfg format ?
------------------------------------------------------
"noshell" means that no interactive shell session is opened on the
remote server. The connection is used only to create the SOCKS5
tunnel (with -N flag in SSH). This is the correct and recommended
mode for all tunnel-only connections.


================================================================================
  6. BROWSER
================================================================================

Which browser does the addon use ?
------------------------------------
Chromium. Not Google Chrome, not Firefox, not the Tor Browser.
Chromium is the open-source base of Chrome without Google's
proprietary additions (though some Google services are still used).

What browser profiles are available ?
---------------------------------------
Three profiles are provided:

  Normal     Your personal browsing profile. Stores history, cookies,
             and saved passwords between sessions (within the Persistent Volume).

  Anonymous  A clean incognito-style profile. No history, no cookies,
             no saved data. Starts fresh every time.

  Fixed      A custom profile that you create yourself. Useful if you
             want a separate profile for specific tasks.

Can Chromium be used without the SOCKS5 proxy ?
------------------------------------------------
No. Chromium is always launched with the --proxy-server parameter
pointing to the local SOCKS5 proxy on port 9999. If no SSH connection
is active, the browser will show a connection error. This is intentional
— it prevents accidentally browsing without the tunnel.

Can I play DRM-protected content (Netflix, Disney+) in Chromium ?
------------------------------------------------------------------
Not with Chromium out of the box. Chromium on Debian does not include
the Widevine DRM library (libwidevinecdm.so). Only this single file
is needed — Google Chrome itself does not need to be installed.

The script cli_get_chrome.sh handles this automatically:

  cd ~/Persistent/scripts
  ./cli_get_chrome.sh

No administrator password or root access is required. The script runs
entirely as the normal Tails user.

What the script does step by step:
  1. Downloads the Google Chrome .deb package to
     ~/Persistent/swtor-addon-to-tails/deb/
  2. Extracts the package contents with dpkg-deb (no installation)
  3. Moves only libwidevinecdm.so to
     ~/Persistent/swtor-addon-to-tails/deb/
  4. Deletes all other extracted files (opt/, usr/, etc/) immediately
  5. Deletes the Chrome .deb package

Google Chrome is never installed on your system. After the script
completes, the only file remaining from the Chrome package is
libwidevinecdm.so in the deb/ directory.

Security note: Since Chrome 117, Google installs AI components
(including Gemini Nano) silently in the background via its Component
Updater. By extracting only libwidevinecdm.so and discarding everything
else, your system is never exposed to these components.

How does Chromium actually find the Widevine library ?
  cli_get_chrome.sh stores the complete WidevineCdm/ directory
  (including manifest.json and libwidevinecdm.so) in:

    ~/Persistent/swtor-addon-to-tails/deb/WidevineCdm/

  On every startup, swtor-init.sh copies this directory as root
  to the correct system location:

    /usr/lib/chromium/WidevineCdm/

  This copy step requires root access and happens automatically
  during initialisation — no manual action is needed.

Do I need to run cli_get_chrome.sh on a fresh installation ?
  No. The WidevineCdm/ directory is already included in the
  git repository. Every user who clones the addon already has
  Widevine available immediately — swtor-init.sh copies it to
  /usr/lib/chromium/ on the first startup automatically.

  cli_get_chrome.sh is only needed to update Widevine to a
  newer version when required.

Can I replace the default Chromium profiles with my own ?
-----------------------------------------------------------
Yes. The default profiles are stored in:

  ~/Persistent/settings/tmp.tar.gz

You can replace this file with your own archive. However, be aware
that running ./cli_update.sh will overwrite this file with the default
version from the repository. If you want to keep your custom profiles
permanently, you must re-apply them after every update.

The author plans to provide a dedicated mechanism for custom profiles
in a future version.

Can I use my own desktop wallpaper in frozen mode ?
----------------------------------------------------
Yes. Replace the file:

  ~/Persistent/swtor-addon-to-tails/doc/swtor-desktop-freezed.jpeg

with your own image. The new file must also be named exactly
"swtor-desktop-freezed.jpeg". Do this before running cli_freezing.sh.

Can I use a different browser instead of Chromium ?
----------------------------------------------------
The addon is designed specifically for Chromium. Using a different
browser would require modifications to the browser launcher scripts
(browser_normal.sh, browser_anonymous.sh, browser_fix.sh). The
SOCKS5 proxy itself (port 9999) works with any application that
supports SOCKS5 proxying, but only Chromium is configured and
tested by this addon.

What happens to Chromium when the SSH connection drops ?
---------------------------------------------------------
If AUTOCLOSE-BROWSER:YES is set in swtor.cfg (the default), the
watchdog process detects the dropped connection and closes Chromium
automatically. This prevents you from accidentally continuing to browse
after the tunnel has gone down.

If AUTOCLOSE-BROWSER:NO is set, Chromium remains open but will show
connection errors until the SSH session is re-established or the
browser is closed manually.

How do I create my own fixed Chromium profile ?
------------------------------------------------
Run:

  cd ~/Persistent/scripts
  ./cli_create_fixed_profile.sh

Or use the menu: swtor-menu → Utilities & Help → Create Fixed Profile


================================================================================
  7. SECURITY & PRIVACY
================================================================================

Are there any backdoors in the addon ?
----------------------------------------
No. The addon consists entirely of shell scripts (Bash) and a small
Python script for the About dialog. Every line of code can be read and
verified by anyone with a text editor.

The three Chromium profiles (approximately 10 MB in total) contain
only standard browser profile files. No binary executables, no
obfuscated code, no network callbacks to the author's systems.

If you do not trust the pre-configured Chromium profiles, replace
tmp.tar.gz with your own (see Browser section).

Can the addon read my personal files ?
----------------------------------------
The addon reads only files within its own directory and your
Persistent Volume during backup. It does not scan, transmit, or
log any other files on your system.

To be precise: the backup script (create_image.sh) reads files
from the Persistent Volume in order to create a backup image.
This is the only time the addon accesses your personal data,
and only with your explicit action.

Are my SSH passwords stored anywhere ?
----------------------------------------
When using password-based authentication, the password is stored
temporarily in a file under ~/Persistent/ during the connection
process and deleted immediately afterwards. It is never written
to a log file or transmitted anywhere except to your SSH server.

Key-based authentication (ssh-id) is strongly recommended. With
key-based auth, no password is ever stored or transmitted.

Are log files created ?
-------------------------
Yes. Connection logs are stored in:

  ~/Persistent/swtorcfg/log/

These logs are stored within your Persistent Volume and are not
transmitted anywhere. They are useful for troubleshooting failed
connections. Set TERMINAL-VERBOSE:YES in swtor.cfg for more detailed
log output.

What can my SSH provider see ?
--------------------------------
Your SSH provider can see:
- The IP address of the Tor exit node (never your real IP)
- The timing and volume of your traffic
- The unencrypted content of HTTP (non-HTTPS) connections
- DNS queries if your browser is not configured to use DNS over HTTPS

Your SSH provider cannot see:
- Your real IP address — it is hidden behind the Tor network at all times
- The content of HTTPS connections (encrypted end-to-end)
- Which Tails user is behind the exit node

This is a key architectural property of the addon: because all SSH
traffic is routed through Tor, the SSH server operator has no way to
identify or locate you, even if they are actively trying to do so.
The exit node is all they will ever see.

Is this setup suitable for high-risk situations ?
--------------------------------------------------
The addon adds a useful layer of separation between you and the
internet. However, it is not designed as a high-security anonymity
tool. For high-risk situations (journalists in danger, activists in
authoritarian countries), study the Tails documentation carefully
and consider whether the Tor Browser alone is more appropriate for
your threat model.

What is the repair stick and why do I need it ?
------------------------------------------------
After creating a backup, the addon stores important recovery files in:

  ~/Persistent/personal-files/tails-repair-disk

This folder contains your SSH keys and other files needed to restore
your backup. Without these, you cannot access an encrypted remote backup.

Copy this folder to a separate USB drive and store it securely — ideally
in a different physical location from your Tails USB and your backup.

If you are in a country where authorities can legally demand encryption
passwords (the UK, the USA, and others), consider storing your backup
in a different country.

Does the addon protect against a compromised Tails installation ?
-----------------------------------------------------------------
No. If your Tails installation itself is compromised, no addon can
provide meaningful protection. Always verify your Tails download and
use a clean, unmodified installation.


================================================================================
  8. BACKUP & RESTORE
================================================================================

What exactly does the backup include ?
----------------------------------------
The backup saves the following from your Persistent Volume:

  - personal-files        Your personal data folder
  - swtorcfg              All addon configuration files (including swtorssh.cfg)
  - Tor-Browser           Tor Browser profile and settings

The backup does NOT include:
  - The addon scripts themselves (they are re-installed from GitHub via git)
  - The apt package cache (unless BACKUP-APT-LIST:YES is set)
  - The fixed Chromium profile (unless BACKUP-FIXED-PROFILE:YES is set)
  - Temporary files from the tmp/ directory

What backup options are available ?
-------------------------------------
Three options:

  1. Unencrypted local backup
     Stored in ~/Persistent/personal-files/tails-repair-disk
     Simple but the data is readable by anyone who accesses your USB drive.

  2. Encrypted local backup (GPG)
     Stored in ~/Persistent/personal-files/tails-repair-disk
     Protected by your GPG passphrase.

  3. Encrypted remote backup (GPG + SSH transfer)
     Encrypted locally and then transferred to your SSH backup server
     via rsync. The safest option.

What do I need for a remote backup over SSH ?
----------------------------------------------
- A full-featured SSH account (fullssh.sh mode) with key-based login
- rsync installed on the remote server (check with: which rsync)
- Sufficient storage space on the remote server

Password-based login is not currently supported for remote backups.

How do I verify that my backup is intact ?
-------------------------------------------
Every backup includes an MD5 checksum file. The restore script verifies
this checksum automatically before restoring. If the checksum fails,
the restore is aborted.

Test your restore procedure on a spare system before you actually need it.
A backup you have never restored is a backup you cannot trust.

Why must I close all applications before making a backup ?
-----------------------------------------------------------
A file that is currently open and locked by a running program cannot
be safely copied. The backup may be incomplete or corrupted if you
attempt it while programs are running.

Close the following before starting a backup:

  - Tor Browser
  - Electrum Bitcoin Wallet
  - Thunderbird
  - Pidgin
  - Kleopatra / Cleopatra

How do I restore from a backup ?
----------------------------------
Copy the repair-disk folder to a new Tails USB drive with a
fresh Persistent Volume. Then open a terminal in the scripts
directory and run:

  ./restore.sh

Follow the on-screen instructions. The restore is multi-step and
guided.

Always test your restore on a spare system before relying on it.

Is the built-in Tails backup (since Tails 6.x) better than this addon's backup ?
---------------------------------------------------------------------------------
The built-in Tails backup (available since Tails 4.25, significantly
improved in Tails 6.x) is very easy to use and backs up the entire
Persistent Volume to another USB drive. For most users it is the
simpler and recommended first option.

This addon's backup offers some additional features:

  - MD5 checksum protection against data corruption
  - Remote storage via SSH (off-site backup)
  - GPG encryption of the backup archive
  - The ability to store the backup anywhere as a regular file

Both approaches can be used together. The Tails built-in backup handles
the full system image, this addon handles the SSH-based off-site copy.

Should I be concerned about encrypted data laws in my country ?
----------------------------------------------------------------
Yes. In several countries (including the United Kingdom and the United
States) authorities can legally demand that you hand over encryption
passwords or keys. Research the laws in your own country.

Practical advice:
- Store your encrypted backup on a server in a different country
- Do not keep the only copy of your decryption key on your Tails USB
- Use the repair stick and store it separately and securely


================================================================================
  9. FREEZING THE SYSTEM
================================================================================

What does "freezing" the system mean ?
----------------------------------------
Tails normally resets all settings on every reboot. "Freezing" means
saving your current desktop configuration (wallpaper, terminal colours,
GNOME settings, privacy settings) to the Persistent Volume via the
Dotfiles mechanism, so that they are restored automatically on every
boot.

After freezing, swtor-init.sh also starts automatically when you log in.

How do I freeze the system ?
------------------------------
  cd ~/Persistent/scripts
  ./cli_tweak.sh       (apply GNOME settings)
  ./cli_freezing.sh    (save them via Dotfiles)

Then reboot Tails.

Or via the menu: swtor-menu → Utilities & Help → Freezing the current state

Note: cli_tweak.sh applies a set of predefined settings (dark mode,
terminal colours, privacy settings). It can be customised to your
preferences before running. Alternatively, set your preferences manually
in GNOME before running cli_freezing.sh.

How do I unfreeze the system ?
--------------------------------
  cd ~/Persistent/scripts
  ./cli_unfreezing.sh

Then reboot Tails.

Or via the menu: swtor-menu → Utilities & Help → Unfreezing

Important: Always unfreeze before upgrading Tails to a new version.

After a Tails upgrade the system is no longer frozen. What should I do ?
-------------------------------------------------------------------------
This is expected behaviour. Tails upgrades reset the Dotfiles.
After the upgrade, simply freeze the system again:

  cd ~/Persistent/scripts
  ./cli_tweak.sh
  ./cli_freezing.sh

Then reboot. The freeze is restored.

Can I use my own desktop wallpaper in frozen mode ?
----------------------------------------------------
Yes. Replace the file:

  ~/Persistent/swtor-addon-to-tails/doc/swtor-desktop-freezed.jpeg

with your own image file. The new file must be named exactly
"swtor-desktop-freezed.jpeg". Do this before running cli_freezing.sh.

Does freezing survive a Tails USB clone ?
------------------------------------------
No. If you clone your Tails USB to a new USB drive, you will need
to freeze the new system separately. Copy your configuration files
first, then run cli_freezing.sh on the new system.


================================================================================
  10. UPDATING THE ADDON
================================================================================

How do I update the addon ?
-----------------------------
  cd ~/Persistent/scripts
  ./cli_update.sh

Or via the menu: swtor-menu → Utilities & Help → Check for updates on GitHub

What does the update overwrite ?
----------------------------------
The update (git pull) overwrites all script files and the default
Chromium profiles (settings/tmp.tar.gz).

Your configuration files are NOT overwritten:
  - ~/Persistent/swtorcfg/swtor.cfg
  - ~/Persistent/swtorcfg/swtorssh.cfg

If you have customised any of the scripts or the default profiles,
back them up before updating. The update will overwrite your changes.

Do I need to refreeze after an update ?
-----------------------------------------
No, not automatically. However, if the update changes the autostart
behaviour or the swtor-init script, it is advisable to unfreeze and
refreeze once to ensure the Dotfiles point to the correct version.

The CHANGES file or release notes will indicate if a refreeze is needed.

How often is the addon updated ?
----------------------------------
Updates are released as needed when bugs are fixed or new Tails versions
require changes. Check the CHANGES file for the full history.


================================================================================
  11. TROUBLESHOOTING
================================================================================

"Internet not ready" appears on startup. What does this mean ?
---------------------------------------------------------------
swtor-init.sh checks whether Tor has established a connection before
proceeding. If Tor is not ready within the configured timeout, this
message appears.

Solution: Increase the timeout in swtor.cfg:
  TIMEOUT-TB:10  →  TIMEOUT-TB:20  (or higher)

Also check that Tor is actually connecting. The Tor status icon in
the Tails taskbar should turn green before you run swtor-init.

The SSH connection fails immediately. What should I check ?
------------------------------------------------------------
1. Is the server added to ~/.ssh/known_hosts ? (Connect manually once first)
2. Is the SSH key copied to ~/.ssh ? (For key-based connections)
3. Is the username and hostname in swtorssh.cfg correct ?
4. Is the port in swtorssh.cfg correct ?
5. Set TERMINAL-VERBOSE:YES in swtor.cfg for detailed output
6. Check the log files in ~/Persistent/swtorcfg/log/

The SSH connection works but Chromium shows "ERR_PROXY_CONNECTION_FAILED".
---------------------------------------------------------------------------
The SOCKS5 proxy on port 9999 is not running. This means the SSH
tunnel was not successfully established even though the connection
appeared to succeed. Check the log files and try again. Set
TERMINAL-VERBOSE:YES for more detail.

"Lockfile already exists" — I cannot start swtor-menu.sh.
----------------------------------------------------------
A lock file from a previous session was not cleaned up. Remove it:

  cd ~/Persistent/scripts
  ./cli_remove_lockdir.sh

The error will be gone and swtor-menu.sh will start normally.

The watchdog is not detecting dropped connections.
--------------------------------------------------
Check that AUTOCLOSE-BROWSER:YES is set in swtor.cfg. Also check
that watchdog.sh started correctly by looking for its PID file in
the tmp/ directory during an active connection.

The system is frozen but settings are wrong after a reboot.
------------------------------------------------------------
The Dotfiles mechanism only saves what was present at the time of
cli_freezing.sh. If you changed settings after freezing, they will
not be preserved.

Solution: Unfreeze, make your changes, then refreeze:
  ./cli_unfreezing.sh  → reboot → make changes → ./cli_tweak.sh → ./cli_freezing.sh → reboot

DRM content does not play in Chromium.
----------------------------------------
Run:

  cd ~/Persistent/scripts
  ./cli_get_chrome.sh

No root or administrator password required. The script downloads the
Google Chrome package, extracts only libwidevinecdm.so into
~/Persistent/swtor-addon-to-tails/deb/, and immediately deletes the
Chrome package and all other extracted files. Google Chrome is never
installed on your system.

After running cli_get_chrome.sh, restart swtor-init.sh. It will
automatically copy the WidevineCdm/ directory to /usr/lib/chromium/
as root during initialisation. Then restart Chromium.

Note: On a fresh installation, cli_get_chrome.sh is not needed at all.
The WidevineCdm/ directory is already included in the git repository
and swtor-init.sh installs it automatically on first startup.

The addon worked on Tails 4.x but stopped working after upgrading.
-------------------------------------------------------------------
Run the update script first:
  cd ~/Persistent/scripts
  ./cli_update.sh

Each major Tails version may require a corresponding addon update.
Check the CHANGES file to see which addon version supports your
Tails version.

I accidentally ran setup.sh on an existing installation.
---------------------------------------------------------
If swtor.cfg or swtorssh.cfg were overwritten, restore them from
your backup (if available) or reconfigure them manually. Your SSH
keys in ~/.ssh are not touched by setup.sh and should still be intact.

Where are the log files ?
---------------------------
  ~/Persistent/swtorcfg/log/

For more detailed logs, set TERMINAL-VERBOSE:YES in swtor.cfg before
starting a connection.

Nothing works. Where do I start ?
-----------------------------------
Work through this checklist in order:

  1. Is the Tails administration password set at the greeter screen ?
  2. Is Tor connected ? (Green icon in taskbar)
  3. Is the Persistent Volume unlocked and mounted ?
  4. Did you run cli_directorys.sh on this installation ?
  5. Does swtorssh.cfg contain at least one valid entry ?
  6. Is the remote server reachable ? (Test with: ssh user@host in terminal)
  7. Set TERMINAL-VERBOSE:YES and try again — read the output carefully
  8. Check the log files in ~/Persistent/swtorcfg/log/

If none of this helps, send an email with your log output to:
  swtor00@protonmail.com


================================================================================
  12. ABOUT THE PROJECT
================================================================================

When was this addon first created ?
-------------------------------------
Development began in 2018. The full development history is documented
in the CHANGES file.

Why was this addon created ?
------------------------------
The author needed a reliable, scriptable way to route Chromium through
an SSH tunnel on Tails, with a clean menu interface, automated startup,
and backup functionality. No existing tool met all these requirements,
so the addon was written from scratch.

What is the future of this addon ?
------------------------------------
Planned improvements include:
  - Better support for custom Chromium profiles without overwrite on update
  - Additional SSH provider integration
  - Expanded documentation (the PDF manual is ongoing)

My specific question is not in this FAQ. What should I do ?
------------------------------------------------------------
Send an email to:

  swtor00@protonmail.com

Describe your issue clearly, include your Tails version, the addon
version (shown in swtor-about), and the relevant log output from
~/Persistent/swtorcfg/log/. Bug reports with log output are fixed
significantly faster than reports without.

User feedback is always appreciated. On 31/12/2021 the first feature
request was received from a user. It was implemented the same day.
Thank you hjhj65.

================================================================================
  END OF F.A.Q
================================================================================
