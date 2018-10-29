#!/bin/bash -x

set -e

IMGSIZE=150000000

######################

#ubootpath=u-boot/
linuxpath=linux/
busyboxpath=busybox/

########################################

######################./ub.sh $ubootpath

./kern.sh $linuxpath

./bbox.sh $busyboxpath

./populate.sh $busyboxpath $linuxpath

########################################

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
else 
	make_ext4fs -L rootfs -l $IMGSIZE rootfs.ext4 _install
	ext2simg rootfs.ext4 rootfs.img
fi

cd - &>/dev/null
echo
echo 'Done.'
echo
