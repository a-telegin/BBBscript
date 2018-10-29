#!/bin/bash -x

set -e

######################

busyboxpath=busybox/

######################

if [ ! -d $busyboxpath ]; then
	echo 'Error. Cannot find busybox.'
	exit 30
fi

cd $busyboxpath &>/dev/null

if [ -f rootfs.ext4 ]; then
	rm -f rootfs.ext4
fi

if [ -f rootfs.img ]; then
	rm -f rootfs.img
fi

if [ ! -d _install/ ]; then
	echo 'Error. Cannot find _install folder'
	exit 2;	
fi 

make_ext4fs -L rootfs -l $IMGSIZE rootfs.ext4 _install
ext2simg rootfs.ext4 rootfs.img

file rootfs.img

#### Sending 'reboot'
echo 'reboot' > /dev/ttyUSB0
sleep 5
#### Sending 'SPACE'
echo $'\x20' > /dev/ttyUSB0
sleep 1
#### Sending 'fastboot 0'
echo 'fastboot 0' > > /dev/ttyUSB0
sleep 4
fastboot devices
fastboot flash rootfs rootfs.img
sleep 10
echo $'\cC'
echo 'run bootcmd' > /dev/ttyUSB0

cd - &>/dev/null
