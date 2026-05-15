# swtor-addon-to-tails

**A privacy addon for [Tails OS](https://tails.net) that routes Chromium through an SSH tunnel.**

> Version 0.91 · Build 20587 · License: GPL 2  
> Status: BETA · Author: swtor00@protonmail.com  
> Requires: **Tails 7.0 or higher**

---

## What does this addon do?

Tails comes with the Tor Browser for anonymous browsing. This addon adds a second option: it establishes an SSH connection to a remote server of your choice, creates a local SOCKS5 proxy on port 9999, and launches Chromium through that tunnel.

This is **not a VPN**. No VPN software is involved. The tunnel is a standard SSH SOCKS5 proxy.

```
Your Tails  →  SSH tunnel (port 9999)  →  Your SSH server  →  Internet
```

Three Chromium browser profiles are available:

| Profile | Description |
|---|---|
| Normal | Your personal browsing profile |
| Anonymous | Incognito mode, no persistent data |
| Fixed | A custom profile you create yourself |

---

## Requirements

- A USB drive with Tails 7.0 or higher installed
- A persistent volume on that USB drive with these options activated:
  - **SSH** (openssh-client)
  - **Additional Software**
  - **Dotfiles** (recommended — required for autostart)
- At least one SSH account on a remote server
- An internet connection at startup (Tor must be running)
- The Tails administration password must be set at the greeter screen

---

## Installation

Open a terminal in your Persistent folder and run:

```bash
cd ~/Persistent
git clone https://github.com/swtor00/swtor-addon-to-tails
cd swtor-addon-to-tails/scripts
./cli_directorys.sh
./swtor-setup.sh
```

`swtor-setup.sh` will guide you through the first-time configuration interactively. It installs the required software packages (chromium, chromium-sandbox, sshpass) and creates the necessary symlinks.

> **Note:** The setup script can only be run once per persistent volume. If you need to run it again, see the F.A.Q.

---

## Configuration

All settings live in one file:

```
~/Persistent/swtorcfg/swtor.cfg
```

The most important options:

| Option | Default | Description |
|---|---|---|
| `GUI-LINKS:YES` | YES | Adds swtor entries to the Tails application menu |
| `BROWSER-SOCKS5:YES` | YES | Enables the Chromium browser via SOCKS5 |
| `TIMEOUT-TB:10` | 10 | Seconds to wait for a Tor connection on startup |
| `TIMEOUT-SSH:8` | 8 | Seconds to wait for an SSH connection to establish |
| `TERMINAL-VERBOSE:NO` | NO | Set to YES for debug output in the terminal |
| `AUTOCLOSE-BROWSER:YES` | YES | Close Chromium automatically when SSH disconnects |
| `XCLOCK-SIZE:180` | 180 | Size in pixels of the remote X11 clock window |
| `BACKUP-FIXED-PROFILE:NO` | NO | Include the fixed browser profile in backups |
| `BACKUP-APT-LIST:NO` | NO | Include apt cache in backups (~500 MB extra) |
| `CHECK-EMPTY-SSH:NO` | NO | Warn on startup if ~/.ssh is empty |

---

## SSH Server Configuration

Your SSH servers are defined in:

```
~/Persistent/swtorcfg/swtorssh.cfg
```

Each line defines one connection. The format is:

```
<script>  <auth>  <compress>  <ipv>  <ssh-ver>  <port>  <local-port>  <mode>  <user@host>  <res>  <backup>  <country>  <description>
```

**Example — key-based full SSH connection:**
```
fullssh.sh  ssh-id  Compress  4  2  22  9999  noshell  user@myserver.com  xxxxx  xxxxxx  Germany  my-server
```

**Example — password-based connection:**
```
fullssh.sh  passwd  Compress  4  2  22  9999  noshell  user@myserver.com  xxxxx  xxxxxx  Canada  cheap-vps
```

**Connection modes:**

| Script | Auth | Description |
|---|---|---|
| `fullssh.sh` | `ssh-id` | SSH key — recommended |
| `fullssh.sh` | `passwd` | Password login |
| `fullssh-interactive.sh` | `passwd` | Password login, entered interactively |
| `chainssh.sh` | `ssh-id` | Two-hop chain through two servers |
| `pfssh-interactive.sh` | `passwd` | Port forwarding with password |

---

## Daily Use

Every time you boot Tails, run the scripts in this order:

```
swtor-init  →  swtor-menu
```

If Dotfiles are activated and the system is frozen, `swtor-init` starts automatically after login.

From `swtor-menu` you can:
- Select an SSH server and connect
- Launch a browser profile
- Access tools and utilities (backup, update, freeze/unfreeze)

---

## Backup and Restore

The addon can back up your entire Persistent volume. You have three options:

1. **Unencrypted** — saved locally to `~/Persistent/personal-files/tails-repair-disk`
2. **Encrypted with GPG** — saved locally
3. **Encrypted with GPG + transferred to your SSH backup server** — the safest option

Every backup includes an MD5 checksum to verify integrity. To restore, copy the repair-disk folder to a new Tails USB, open a terminal, and run `restore.sh`.

> **Warning:** Always test your restore before you need it.  
> **Warning:** In some countries (UK, USA and others) authorities can legally compel you to hand over encryption passwords. Store your backup somewhere safe, ideally in another country.

---

## Freezing the System

"Freezing" means saving your current desktop settings (wallpaper, terminal colours, GNOME configuration) persistently via the Dotfiles option, so they survive a reboot.

```bash
# Freeze
cd ~/Persistent/scripts
./cli_tweak.sh
./cli_freezing.sh
# Then reboot Tails

# Unfreeze
./cli_unfreezing.sh
# Then reboot Tails
```

Or use the menu: **swtor-menu → Utilities & Help → Freezing / Unfreezing**

---

## Updating the Addon

```bash
cd ~/Persistent/scripts
./cli_update.sh
```

Or use the menu: **swtor-menu → Utilities & Help → Check for updates on github**

> **Warning:** Updating overwrites `swtor.cfg` and all scripts. Back up any local changes first.

---

## Troubleshooting

**"Lockfile already exists" error:**
```bash
cd ~/Persistent/scripts
./cli_remove_lockdir.sh
```

**"Internet not ready" on startup:**  
Increase `TIMEOUT-TB` in `swtor.cfg` from 10 to 15 or higher.

**SSH connection fails:**  
Check the log files in `~/Persistent/swtorcfg/log/`. Set `TERMINAL-VERBOSE:YES` in `swtor.cfg` for detailed output.

**After upgrading Tails, the system is no longer frozen:**  
Run `cli_tweak.sh` followed by `cli_freezing.sh`, then reboot.

**DRM content does not play in Chromium:**  
```bash
cd ~/Persistent/scripts
./cli_get_chrome.sh
```
This downloads Google Chrome and installs the Widevine DRM library.

Note: On a fresh installation this step is not necessary. The
`WidevineCdm/` directory is already included in the git repository.
`swtor-init.sh` copies it automatically to `/usr/lib/chromium/` on
every startup. Run `cli_get_chrome.sh` only to update Widevine to
a newer version.

---

## Project Structure

```
swtor-addon-to-tails/
├── bookmarks/          Firefox/Tor Browser bookmark files
├── deb/                Debian packages adding entries to the Tails menu
├── doc/                Documentation, F.A.Q., configuration reference (PDF)
├── scripts/            All shell scripts and Python wrappers
│   │
│   │   — Entry points —
│   ├── swtor-init.sh           Startup initialisation (run once per session)
│   ├── swtor-menu.sh           Main menu
│   ├── swtor-setup.sh          First-time setup (Python wrapper → setup.sh)
│   ├── swtor-tools.sh          Utilities & Help submenu
│   ├── swtor-about             GTK "About" dialog (Python)
│   │
│   │   — Core —
│   ├── swtor-global.sh         Shared functions library (sourced by all scripts)
│   ├── setup.sh                First-time setup logic
│   ├── selector.sh             SSH server selection dialog
│   ├── ssh-selector.sh         Python wrapper → selector.sh
│   │
│   │   — SSH connection scripts —
│   ├── fullssh.sh              SSH tunnel, key-based authentication
│   ├── fullssh-interactive.sh  SSH tunnel, password authentication
│   ├── chainssh.sh             Two-hop SSH chain, key-based
│   ├── pfssh-interactive.sh    Port forwarding, password authentication
│   │
│   │   — Python wrappers (called by selector.sh) —
│   ├── 1.sh                    Wrapper → fullssh.sh
│   ├── 2.sh                    Wrapper → fullssh-interactive.sh
│   ├── 3.sh                    Wrapper → chainssh.sh
│   ├── 4.sh                    Wrapper → pfssh-interactive.sh
│   │
│   │   — Browser launchers —
│   ├── browser_normal.sh       Chromium: Normal profile via SOCKS5
│   ├── browser_anonymous.sh    Chromium: Anonymous/incognito profile via SOCKS5
│   ├── browser_fix.sh          Chromium: Fixed/personal profile via SOCKS5
│   │
│   │   — Backup and restore —
│   ├── create_image.sh         Creates a backup of the Persistent volume
│   ├── restore.sh              Restore entry point (header only, completed dynamically)
│   ├── restore_p21.sh          Restore part 2 template: unencrypted local backup
│   ├── restore_p22.sh          Restore part 2 template: encrypted remote backup
│   ├── restore_part3.sh        Restore part 3: extraction and checksum verification
│   ├── restore_part4.sh        Restore part 4: decryption and final extraction
│   │
│   │   — CLI utilities —
│   ├── cli_directorys.sh       Creates required symlinks in ~/Persistent
│   ├── cli_freezing.sh         Freezes the current desktop state via Dotfiles
│   ├── cli_unfreezing.sh       Unfreezes the system
│   ├── cli_tweak.sh            Applies GNOME settings (dark mode, terminal colours, privacy)
│   ├── cli_update.sh           Updates the addon via git pull
│   ├── cli_install.sh          Installs required software packages manually
│   ├── cli_get_chrome.sh       Downloads Google Chrome (for Widevine DRM support)
│   ├── cli_create_fixed_profile.sh  Creates the fixed Chromium browser profile
│   ├── cli_remove_lockdir.sh   Removes stale lock files
│   ├── cli_startover.sh        Factory reset template (commands are commented out)
│   │
│   │   — Background processes —
│   ├── watchdog.sh             Monitors the SSH connection in the background
│   ├── wait.sh                 Manages the "Please wait" dialog
│   ├── pwait1.sh               Python wrapper → pwait2.sh
│   ├── pwait2.sh               Displays the zenity progress dialog
│   │
│   │   — Other —
│   ├── testroot.sh             Verifies the Tails administration password
│   ├── update.sh               Interactive update with confirmation dialog
│   ├── tag-release.sh          Git tagging helper for releases
│   └── state/offline           State flag file (online/offline)
├── settings/           Chromium browser profile templates
├── swtorcfg/           Configuration files (swtor.cfg, swtorssh.cfg)
└── tmp/                Temporary runtime files (not backed up)
```

---

## F.A.Q.

See [`doc/F.A.Q`](doc/F.A.Q) for the full list of frequently asked questions.

---

## Are there backdoors in this addon?

No. The addon consists entirely of shell scripts that you can read and verify yourself. The Chromium profiles provided are approximately 10 MB in size. The addon does not access any files outside of its own directory and your Persistent volume.

---

## License

GNU General Public License Version 2. See [LICENSE](LICENSE).
