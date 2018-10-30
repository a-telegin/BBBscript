#!/bin/bash -x

set -e

######################

#ubootpath=u-boot/
linuxpath=linux/
busyboxpath=busybox/

########################################

######################./ub.sh $ubootpath

./kern.sh $linuxpath

./bbox.sh $busyboxpath

./populate.sh $busyboxpath $linuxpath

./tcpdumpbuild.sh

./flash.sh

########################################

echo
echo 'Done.'
echo

