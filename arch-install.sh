#!/bin/bash

#This script is desined to automate the installation of arch linux.
#This is provided without any warranties. Feel free to modify and redistrubute as you wish

#Defining functions
ready_to_install () 
{
	echo "First, we're going to verify internet connectivity"
	if check_internet_connected $1; 
		then 
		pacman -Sy;
		echo "Connected";
		if check_mountpoints $1;
			then
			echo "Partitions are mounted";
 			true;
		else
		       	echo "Your partitions aren't mounted. Please mount root to /mnt and boot to /mnt/boot";
			false;
		fi	
	else
		echo "You're not connected online, please connect to the internet and re-run this script";

 		false;
	fi
}

check_internet_connected () 
{
	wget -q --spider http://archlinux.org	
	[ $? -eq 0 ]
}

check_mountpoints ()
{
	if grep -qs '/mnt ' /proc/mounts; then
		if grep -qs '/mnt/boot ' /proc/mounts; then
			true
		else	
			echo "/mnt/boot is not mounted"
			false;
		fi

	else
		echo "/mnt is not mounted";
		false;
	fi
}

sort_mirrors () 
{
	pacman -S --noconfirm pacman-contrib;
	echo "Sorting Mirrors..."
	curl -s "https://www.archlinux.org/mirrorlist/?country=US&protocol=https&ip_version=4&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 5 -
	echo "Mirrors sorted";
	
}

install_arch () 
{
	PS3='Choose which kernel to install (Stable is recomended): '
	options=("Stable" "Hardened (linux-hardened)" "Longterm (linux-lts)" "ZEN (linux-zen)" "Quit")
		select opt in "${options[@]}"
		do
    			case $opt in
        			"Stable")
            				echo "You chose $opt";
					pacstrap /mnt base base-devel
					break;
			            	;;
				"Hardened (linux-hardened)")
            				echo "You chose $opt";
					pacstrap /mnt $(pacman -Sqg base base-devel | sed 's/^linux$/&-hardened/') 
            				break;
					;;
				"Longterm (linux-lts)")
            				echo "You chose $opt";
					pacstrap /mnt $(pacman -Sqg base  base-devel | sed 's/^linux$/&-lts/') 
            				break;
					;;
				"ZEN (linux-zen)")
					echo "You chose $opt";
					pacstrap /mnt $(pacman -Sqg base base-devel | sed 's/^linux$/&-zen/') 
					break;
					;;
        			"Quit")
            				break
            				;;
        			*) echo "invalid option $REPLY";;
    			esac
		done

		unset opt;
			
}


create_hostfile () {
	echo -e "Creating hostname file";
	if [ -e '/mnt/etc/hostname' ]; then
		rm /mnt/etc/hostname
	fi

	touch /mnt/etc/hostname;
        
	echo -n "Enter a hostname and press [Enter]: "
        read hostname

	echo -e $hostname> /mnt/etc/hostname

	echo -e "Hostname file created";

	echo -e "Updating hosts file"
	
	echo -e "127.0.0.1\tlocalhost\n::1\tlocalhost\n127.0.1.1\t""$hostname"".localdomain ""$hostname" > /mnt/etc/hosts

	echo -e "hosts file updated"
	unset hostname;
}

create_chroot () {

	echo -e "Setting up chroot settings";
	if [ -e '/mnt/chroot-config.sh' ]; then
		rm /mnt/chroot-config.sh
	fi

	touch /mnt/chroot-config.sh;
	
	echo -e ""> /mnt/chroot-config.sh

	echo -e "Chroot config created";
}

start_install () 
{
	echo -e "Welcome to Sofian's Arch Install, this automates the installation of Archlinux."
        echo -e "\nPlease make sure your partitions are mounted." 
	echo -e "\nNote: This assumes root is mounted /mnt and boot is mounted to /mnt/boot. Free free to mount any additional partitions." 
	echo -e "\nIf you need to make changes, feel free to edit this script."
	if ready_to_install $1;
	then
	        timedatectl set-ntp true;	
		echo "Ready!";
		#sort_mirrors;
		#install_arch;

		#genfstab -U /mnt >> /mnt/etc/fstab;
		create_hostfile;
		#create_chroot;
		#umount -R /mnt;
	else 
		echo "Not Ready";
		exit
	fi

}
#Invoking function
start_install
