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
start_install () 
{
	if ready_to_install $1;
	then
	        timedatectl set-ntp true;	
		echo "Ready!";
		sort_mirrors;
	else 
		echo "Not Ready";
		exit
	fi

}
#Invoking function
start_install
