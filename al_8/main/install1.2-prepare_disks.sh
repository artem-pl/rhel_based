#!/bin/bash
clear

#Check disk & chane FSTAB for /_data
if [ -L '/dev/disk/by-label/_data' ]
then
	echo 'Disk labeled as [/dev/disk/by-label/_data] found...'
	if ! grep -q '/_data' /etc/fstab
	then
		echo 'Addind [/dev/disk/by-label/_data] to fstab.'
		printf '/dev/disk/by-label/_data /_data auto nosuid,nodev,nofail,x-gvfs-show 0 0\n' >> /etc/fstab
	fi
else
	echo 'Partition labeled as [_data] not found...'
	read -p 'Continue ? [y/N]: ' -n 1 -r
	echo
	case $REPLY in 
		[yY] ) 
			echo 'Ok, we will proceed...'
			disk_sdb=( $(lsblk -o KNAME | grep 'sdb') )
			if [ ! -z "$disk_sdb" ]
			then
				read -p 'Disk [/dev/sdb] exist, want to use it for mapping [/_data] ? [Y/n]: ' -n 1 -r
				echo
				if [[ "$REPLY" =~ ^[yY]$ ]]; then
					disk_sdb1=( $(lsblk -o KNAME | grep 'sdb1') )
					disk_sdb2=( $(lsblk -o KNAME | grep 'sdb2') )
					if [ ! -z "$disk_sdb1" -a ! -z "$disk_sdb2" ]
					then
						echo 'Disk [sdb] has more than one partition...'
						echo 'Exiting...'; exit 1
					elif [ -z "$disk_sdb1" -a -z "$disk_sdb2" ]; then
						echo 'Disk [sdb] has no partition...'
						echo 'Create partition on [/dev/sdb]'
						parted -a optimal -s /dev/sdb mklabel GPT mkpart primary xfs 0% 100%
						sleep 5s
						mkfs.xfs /dev/sdb1
						sleep 5s
						xfs_admin -L _data /dev/sdb1
						echo 'Addind [/dev/disk/by-label/_data] to fstab.'
						printf '/dev/disk/by-label/_data /_data auto nosuid,nodev,nofail,x-gvfs-show 0 0\n' >> /etc/fstab
					else
						disk_sdb1_xfs=( $(lsblk -o KNAME,FSTYPE | grep -E 'sdb1.+xfs') )
						echo '...'
						if [ ! -z ${disk_sdb1_xfs+x} ]
						then
							echo 'Make label [_data] for partition [sdb1].'
							xfs_admin -L _data /dev/sdb1
							if ! grep -q '/_data' /etc/fstab
							then
								echo 'Addind [/dev/disk/by-label/_data] to fstab.'
								printf '/dev/disk/by-label/_data /_data auto nosuid,nodev,nofail,x-gvfs-show 0 0\n' >> /etc/fstab
							fi
						else
							echo 'Partition [sdb] is not XFS...'
							echo 'Exiting...'; exit 1
						fi
					fi
				fi
			else
				echo 'Disk [sdb] not found'
				echo 'Exiting...'; exit 1
			fi
		;;
		* )
			echo 'Break scrip!!!'
			echo 'Exiting...'; exit 1
		;;
	esac
fi

#Check disk & chane FSTAB for _storage
if [ -L '/dev/disk/by-label/_storage' ]
then
	echo 'Disk labeled as [/dev/disk/by-label/_storage] found...'
	if ! grep -q '/_stoeage' /etc/fstab
	then
		echo 'Addind [/dev/disk/by-label/_storage] to fstab.'
		printf '/dev/disk/by-label/_storage /_storage auto nosuid,nodev,nofail,x-gvfs-show 0 0\n' >> /etc/fstab
	fi
else
	echo 'Partition labeled as [_storage] not found...'
	read -p 'Continue ? [y/N]: ' -n 1 -r
	echo
	case $REPLY in 
		[yY] ) 
			echo 'Ok, we will proceed...'
			disk_sdc=( $(lsblk -o KNAME | grep 'sdc') )
			if [ ! -z "$disk_sdc" ]
			then
				read -p 'Disk [/dev/sdc] exist, want to use it for mapping [/_storage] ? [Y/n]: ' -n 1 -r
				echo
				if [[ "$REPLY" =~ ^[yY]$ ]]; then
					disk_sdc1=( $(lsblk -o KNAME | grep 'sdc1') )
					disk_sdc2=( $(lsblk -o KNAME | grep 'sdc2') )
					if [ ! -z "$disk_sdc1" -a ! -z "$disk_sdc2" ]
					then
						echo 'Disk [sdc] has more than one partition...'
						echo 'Exiting...'; exit 1
					elif [ -z "$disk_sdc1" -a -z "$disk_sdc2" ]; then
						echo 'Disk [sdc] has no partition...'
						echo 'Create partition on [/dev/sdc]'
						parted -a optimal -s /dev/sdc mklabel GPT mkpart primary xfs 0% 100%
						sleep 5s
						mkfs.xfs /dev/sdc1
						sleep 5s
						xfs_admin -L _storage /dev/sdc1
						echo 'Addind [/dev/disk/by-label/_storage] to fstab.'
						printf '/dev/disk/by-label/_storage /_storage auto nosuid,nodev,nofail,x-gvfs-show 0 0\n' >> /etc/fstab
					else
						disk_sdc1_xfs=( $(lsblk -o KNAME,FSTYPE | grep -E 'sdc1.+xfs') )
						if [ ! -z ${disk_sdc1_xfs+x} ]
						then
							echo 'Make label [_storage] for partition [sdc1].'
							xfs_admin -L _storage /dev/sdc1
							if ! grep -q '/_storage' /etc/fstab
							then
								echo 'Addind [/dev/disk/by-label/_storage] to fstab.'
								printf '/dev/disk/by-label/_storage /_storage auto nosuid,nodev,nofail,x-gvfs-show 0 0\n' >> /etc/fstab
							fi
						else
							echo 'Partition [sdc] is not XFS...'
							echo 'Exiting...'; exit 1
						fi
					fi
				fi
			else
				echo 'Disk [sdc] not found'
				echo 'Exiting...'; exit 1
			fi
		;;
		* )
			echo 'Break scrip!!!'
			echo 'Exiting...'; exit 1
		;;
	esac
fi

#Adding disk [_data] from FSTAB
if [ ! -d '/_data' ] ; then
	echo 'Make folder [/_data]...'
	mkdir /_data
fi
echo 'Change owner and permisions for [/_data]...'
chown root:root /_data
chmod 666 /_data

#Adding disk [_storage] from FSTAB
if [ ! -d '/_storage' ] ; then
	echo 'Make folder [/_storage]...'
	mkdir /_storage
fi
echo 'Change owner and permisions for [/_storage]...'
chown root:root /_storage
chmod 666 /_storage

#Mount by fstab
echo 'Mount new device by fstab...'
systemctl daemon-reload
sleep 15s
echo 'Mount ALL...'
mount -a
