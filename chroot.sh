pacman --noconfirm --needed -S dialog
passwd

TZuser=$(cat tzfinal.tmp)
rm tzfinal.tmp

ln -sf /usr/share/zoneinfo/$TZuser /etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US ISO-8859-1" >> /etc/locale.gen
locale-gen

dialog  --infobox "Installing bootloader and other important utils" 4 40
pacman --noconfirm --needed -S zsh iw wpa_supplicant grub efibootmgr intel-ucode dosfstools os-prober ntfs-3g exfat-utils networkmanager network-manager-applet gnome-keyring
pacman --noconfirm --needed -S git pulseaudio pulseaudio-alsa pamixer ponymix alsa-utils ttf-dejavu xorg-server xorg-xset xorg-xinit unrar unzip w3m wget feh gvim mesa

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Archlinux
sed -i 's/^GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="acpi_osi='\''!Windows 2012'\''"/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

chsh -s /bin/zsh
sed -i 's/bash/zsh/' /etc/default/useradd

name=$(dialog --no-cancel --inputbox "Enter a username for the user account." 10 60 3>&1 1>&2 2>&3 3>&1)

re="^[a-z_][a-z0-9_-]*$"
while ! [[ "${name}" =~ ${re} ]]; do
	name=$(dialog --no-cancel --inputbox "Username not valid. Give a username beginning with a letter, with only lowercase letters, - and _." 10 60 3>&1 1>&2 2>&3 3>&1)
done

pass1=$(dialog --no-cancel --passwordbox "Enter a password for that user." 10 60 3>&1 1>&2 2>&3 3>&1)
pass2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)

while [ $pass1 != $pass2 ]
do
	pass1=$(dialog --no-cancel --passwordbox "Passwords do not match.\n\nEnter password again." 10 60 3>&1 1>&2 2>&3 3>&1)
	pass2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)
	unset pass2
done

dialog --infobox "Adding user \"$name\"..." 4 50
useradd -m -g users -G wheel -s /bin/zsh $name
echo "$name:$pass1" | chpasswd  
