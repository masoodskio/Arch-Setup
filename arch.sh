#!/bin/bash

#This is a script to make installing Arch Linux easier for me.
#Feel free to use it however this is provided without any warrenties

pacman -S --noconfirm dialog || { echo "Error at script start: Are you sure you're running this as the root user? Are you sure you have an internet connection?"; exit; }
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'


dialog --defaultno --title "Partition/Mount HD" --yesno "Have you partitioned and mounted all your filesystems?.\n\nPress No if you haven't otherwise press Yes to continue"  10 60 ||  exit

dialog --no-cancel --inputbox "Enter a name for your computer." 10 60 2> comp

dialog --defaultno --title "Time Zone select" --yesno "Do you want use the default time zone(America/Chicago)?.\n\nPress no for select your own time zone"  10 60 && echo "America/Chicago" > tz.tmp || tzselect > tz.tmp


timedatectl set-ntp true

dialog --infobox "Updating mirrorlist..." 4 40
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist.backup
rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist


pacstrap /mnt base base-devel


genfstab -U /mnt >> /mnt/etc/fstab
cat tz.tmp > /mnt/tzfinal.tmp
rm tz.tmp

hostname=$(cat comp)
cat comp > /mnt/etc/hostname && rm comp

echo -e "127.0.0.1\tlocalhost\n::1\tlocalhost\n127.0.1.1\t""$hostname"".localdomain ""$hostname" > hosts

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /mnt/etc/locale.gen
sed -i 's/^#en_US ISO-8859-1/en_US ISO-8859-1/' /mnt/etc/locale.gen

locale-gen

echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf

arch-chroot /mnt

passwd
TZuser=$(cat tzfinal.tmp)

ln -sf /usr/share/zoneinfo/$TZuser /etc/localtime
hwclock --systohc

pacman --noconfirm --needed -S grub efibootmgr intel-ucode && grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Archlinux && grub-mkconfig -o /boot/grub/grub.cfg

exit
mount -R /mnt

dialog --defaultno --title "Final Qs" --yesno "Eject CD/ROM (if any)?"  5 30 && eject
dialog --defaultno --title "Final Qs" --yesno "Reboot computer?"  5 30 && reboot
clear
