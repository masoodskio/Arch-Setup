pacman --noconfirm --needed -S dialog
passwd

TZuser=$(cat tzfinal.tmp)
rm tzfinal.tmp

ln -sf /usr/share/zoneinfo/$TZuser /etc/localtime
hwclock --systohc

dialog  --infobox "Installing bootloader and other important utils" 4 40
pacman --noconfirm --needed -S zsh grml-zsh-config iw wpa_supplicant grub efibootmgr intel-ucode dosfstools os-prober vim ntfs-3g

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Archlinux

sed -i 's/^GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="acpi_osi='\''!Windows 2012'\''"/' /etc/default/grub

grub-mkconfig -o /boot/grub/grub.cfg

chsh -s /bin/zsh
