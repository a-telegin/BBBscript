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

./flash.sh

########################################

echo
echo 'Done.'
echo

