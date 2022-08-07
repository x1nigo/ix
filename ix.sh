#! /bin/sh

# Make sure that you have a working internet connection before you run this script!
# You must be root to make all of this stuff work.
# Also, make sure that you git clone this into your root folder (/root).

getwhiptail() {
	echo "
-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

Just making sure that everything is ready and
that 'whiptail' is installed on your system.

-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
"

	pacman -Sy --noconfirm --needed libnewt # show process
}

error() {
	echo "$1" && exit
}

prompt() {
	whiptail --title "IX Installation" --yesno "This script requires that you have a working internet connection and that you are currently logged in as root.\n
Do you fulfill these requirements?" 0 0

	beginprompt="$?"

	if [ $beginprompt = 0 ]; then
		echo 'begin' >/dev/null
	elif [ $beginprompt = 1 ]; then
		error
	fi
}

warning() {
	whiptail --title "IX Installation" --yes-button "Yep." --no-button "Nope." --yesno "WARNING: Use this script at your own peril.\n
Are you sure you want to continue?" 0 0

	accept="$?"

	if [ $accept = 0 ]; then
		echo "let's go" >/dev/null
	elif [ $accept = 1 ]; then
		error
	fi
}

openingmsg() {
	whiptail --title "IX Installation" \
		--msgbox "Welcome to IX! This should make your life easier by automating a post-Arch install for you." 0 0
}

closingmsg() {
	whiptail --title "IX Installation" --msgbox "Thank you for installing IX! You can now logout and log back in with your new username." 0 0
}

userinfo() {
	username=$(whiptail --title "IX Installation" --nocancel --inputbox "Please state your username." 0 0 3>&1 1>&2 2>&3 3>&1)
	password1=$(whiptail --title "IX Installation" --nocancel --passwordbox "Please input your password." 7 40 3>&1 1>&2 2>&3 3>&1)
	password2=$(whiptail --title "IX Installation" --nocancel --passwordbox "Retype your password to confirm." 7 40 3>&1 1>&2 2>&3 3>&1)

	if [ $password1 = $password2 ]; then
		echo "passwords match" >/dev/null
	else
		echo "passwords do not match" && error
	fi
}

adduser() {
	useradd -m $username -g wheel
	usermod -aG wheel $username
	echo $username:$password1 | chpasswd
}

permission() {
	echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheels-can-sudo
}

updatekeyring() {
	whiptail --title "IX Installation" --infobox "Updating archlinux keyring/s..." 7 60
	pacman --noconfirm --needed -Sy archlinux-keyring >/dev/null 2>&1
}

create_dirs() {
	sudo -u $username mkdir \
	/home/$username/.config \
	/home/$username/dls \
	/home/$username/dox \
	/home/$username/pix \
	/home/$username/mus \
	/home/$username/vids
}

getyay() {
	whiptail --title "IX Installation" --infobox "Manually installing \"yay\" to get AUR packages more easily." 8 60
	cd /home/$username/dox/ && sudo -u $username git clone https://aur.archlinux.org/yay.git >/dev/null 2>&1 &&
	cd yay && rm -r .git && sudo -u $username makepkg --noconfirm --needed -si >/dev/null 2>&1
}

installpkgs() {
	cd /home/$username/.config &&
	total=$(( $(wc -l < ~/ix/programs.csv) - 1 ))
	n=0
	while IFS="," read -r type program description
	do
		whiptail --title "IX Installation" --infobox "Installing program: $program ($n of $total). $description." 8 70
		case $type in
			A) n=$(( n + 1 )) && sudo -u $username yay --noconfirm --needed -S $program >/dev/null 2>&1 ;;
			G) n=$(( n + 1 )) && sudo -u $username git clone https://github.com/x1nigo/$program.git >/dev/null 2>&1 ;;
			*) n=$(( n + 1 )) && pacman --noconfirm --needed -S $program >/dev/null 2>&1 ;;
		esac
	done < ~/ix/programs.csv
}

movefiles() {
	cd unseenvillage &&
	shopt -s dotglob &&
	sudo -u $username mv .config/* /home/$username/.config/ && rm -r .config .git &&
	sudo -u $username mv * /home/$username/
}

updatedirs() {
	sudo -u $username xdg-user-dirs-update
}

updateudev() {
	kbd=$(ls /sys/class/leds | grep kbd_backlight)
	
	echo "RUN+=\"/bin/chgrp wheel /sys/class/backlight/intel_backlight/brightness\"
RUN+=\"/bin/chmod g+w /sys/class/backlight/intel_backlight/brightness\"" > /etc/udev/rules.d/backlight.rules &&
	echo "RUN+=\"/bin/chgrp wheel /sys/class/leds/$kbd/brightness\"
RUN+=\"/bin/chmod g+w /sys/class/leds/$kbd/brightness\"" > /etc/udev/rules.d/kbd_backlight.rules &&
	echo "Section \"InputClass\"
	Identifier \"touchpad\"
	Driver \"libinput\"
	MatchIsTouchpad \"on\"
		Option \"Tapping\" \"on\"
		Option \"NaturalScrolling\" \"on\"
EndSection" > /etc/X11/xorg.conf.d/30-touchpad.conf &&
}

compilesuckless() {
	whiptail --title "IX Installation" --infobox "Compiling Suckless Software..." 7 40
	cd /home/$username/.config/dwm && sudo -u $username sudo make clean install >/dev/null 2>&1
	cd ../st/ && sudo -u $username sudo make clean install >/dev/null 2>&1
	cd ../dmenu/ && sudo -u $username sudo make clean install >/dev/null 2>&1
	cd ../dwmblocks/ && sudo -u $username sudo make clean install >/dev/null 2>&1
}

installlf() {
	cd /home/$username/.config/lf/ &&
	sudo -u $username sudo mv lfrun /usr/bin/lfrun && sudo -u $username sudo chmod +x /usr/bin/lfrun &&
	sudo -u $username chmod +x /home/$username/.config/lf/cleaner /home/$username/.config/lf/preview
}

removebeep() {
	rmmod pcspkr 2>/dev/null
	echo "blacklist pcspkr" >/etc/modprobe.d/nobeep.conf
}

changeshell() {
	chsh -s /bin/zsh >/dev/null 2>&1 &&
	chsh -s /bin/zsh $username >/dev/null 2>&1
}

depower() {
	echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheels-can-sudo
}

### MAIN FUNCTION ###

# First things first (Update system and make sure whiptail is installed)
getwhiptail || error "Failed to update and install whiptail."

# Opening message
openingmsg || error "Failed to create opening message."

# Prompt
prompt || error "Failed to create prompt message."

# Warning
warning || error "Warning message failed."

# User information
userinfo || error "Failed to collect user info."

# Add user and password
adduser || error "Failed to add user and corresponding password."

# Change permissions
permission || error "Failed to give permissions for user."

# Update archlinux keyrings
updatekeyring || error "Arch linux keyring failed to update."

# Create home directories
create_dirs || error "Could not create home directories properly."

# Install yay
getyay || error "Installation of yay failed."

# Install packages (arch + AUR)
installpkgs || error "Could not install packages."

# Move files accordingly
movefiles || error "Failed to move files accordingly."

# Update directories
updatedirs || error "Could not update home directories with xdg-user-dirs-update."

# Update udev rules
updateudev || error "Could not update the udev rules."

# Compile every single one of them!
compilesuckless || error "Failed to compile all suckless software on system."

# Install lfimg for lf image previews
installlf || error "Failed to install lf properly."

# Make pacman pretty
sed -i 's/#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf &&
sed -i 's/#Color/Color/' /etc/pacman.conf &&
sed -i '/VerbosePkgLists/a ILoveCandy' /etc/pacman.conf || error "Failed to edit pacman.conf fully."

# Remove beep
removebeep || error "Failed to remove the beep sound."

# Remove unnecessary files and other cleaning
rm -r ~/ix/ /home/$username/.config/unseenvillage/ /home/$username/README.md &&
sudo -u $username mv /home/$username/go /home/$username/dox/ &&
sudo -u $username mkdir -p /home/$username/.config/mpd/playlists/ &&
sudo -u $username chmod +x $HOME/.local/bin/* $HOME/.local/bin/statusbar/* || error "Failed to remove unnecessary files and other cleaning."

# Change shell to zsh
changeshell || error "Could not change shell."

# Give user normal privileges again
depower || error "Could not bring back user from his God-like throne of sudo privilege."

# Exit message from author
closingmsg || error "Failed to accomplish closing message."

exit
