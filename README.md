# Installation script for x1nigo (Ix)
This is my post-arch linux install script. This has saved me a lot of time
whenever I decide to reboot my entire setup/system.

## Requirements
- A freshly installed `arch linux` system.
- A working `internet connection`.
- Run this script as `root`.
- You need to have `git` installed so you can clone this
into your root directory.

```
git clone https://github.com/x1nigo/ix.git
cd ix
sh ix.sh
```
## What does it install?
Aside from the programs listed in `programs.csv`, Ix installs my configuration files and my other suckless software repositories:
- [unseenvillage](https://github.com/x1nigo/unseenvillage) &ndash; My dotfiles
- [dwm](https://github.com/x1nigo/dwm) &ndash; The window manager
- [st](https://github.com/x1nigo/st) &ndash; The terminal emulator
- [dmenu](https://github.com/x1nigo/dmenu) &ndash; The dynamic menu launcher
- [dwmblocks](https://github.com/x1nigo/dwmblocks) &ndash; The status bar

## Note
You can open the `programs.csv` file with your preferred editor, and see if you want to add/delete
any of the listed programs before the installation.

## References
- This was heavily inspired by https://github.com/LukeSmithxyz/LARBS. For the same reasons,
I got tired of re-installing my entire config every single time I had a fresh Arch install,
so I decided to automate it.
