passwd

TZuser=$(cat tzfinal.tmp)

ln -sf /usr/share/zoneinfo/$TZuser /etc/localtime
hwclock --systohc

pacman --noconfirm --needed -S grub efibootmgr intel-ucode && grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Archlinux && grub-mkconfig -o /boot/grub/grub.cfg

