#!/bin/bash

#This is a script to make installing Arch Linux easier for me.
#Feel free to use it however this is provided without any warrenties

pacman -Sy
pacman -S --noconfirm dialog || { echo "Error at script start: Are you sure you're running this as the root user? Are you sure you have an internet connection?"; exit; }
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'


dialog --defaultno --title "Partition/Mount HD" --yesno "Have you partitioned and mounted all your filesystems?.\n\nPress No if you haven't otherwise press Yes to continue"  10 60 ||  exit

dialog --no-cancel --inputbox "Enter a name for your computer." 10 60 2> comp

dialog --defaultno --title "Time Zone select" --yesno "Do you want use the default time zone(America/Chicago)?.\n\nPress no for select your own time zone"  10 60 && echo "America/Chicago" > tz.tmp || tzselect > tz.tmp

timedatectl set-ntp true

dialog --infobox "Updating mirrorlist, this may take a while..." 4 40
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist.backup
rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

dialog --infobox "Installing System..." 4 40
pacstrap /mnt base
dialog --infobox "Done" 4 40

dialog --infobox "Generating fstab..." 4 40
genfstab -U /mnt >> /mnt/etc/fstab
cat tz.tmp > /mnt/tzfinal.tmp
rm tz.tmp

dialog --infobox "Generating lang and host file..." 4 40
hostname=$(cat comp)
cat comp > /mnt/etc/hostname && rm comp

echo -e "127.0.0.1\tlocalhost\n::1\tlocalhost\n127.0.1.1\t""$hostname"".localdomain ""$hostname" > /mnt/etc/hosts

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /mnt/etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf

dialog --infobox "Chroot into system, setup clock, and install bootloader..." 4 40
cp chroot.sh /mnt/chroot.sh && arch-chroot /mnt bash chroot.sh && rm /mnt/chroot.sh

dialog --infobox "Done!" 4 40
mount -R /mnt

dialog --defaultno --title "Final Q" --yesno "Reboot computer?"  5 30 && reboot
clear
