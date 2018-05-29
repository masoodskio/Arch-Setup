passwd

TZuser=$(cat tzfinal.tmp)
rm tzfinal.tmp

ln -sf /usr/share/zoneinfo/$TZuser /etc/localtime
hwclock --systohc

dialog  --infobox "Installing bootloader" 4 40
pacman --noconfirm --needed -S iw wpa_supplicant dialog grub efibootmgr intel-ucode dosfstools os-prober && grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Archlinux && grub-mkconfig -o /boot/grub/grub.cfg

