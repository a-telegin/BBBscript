#!/bin/bash -x

set -e

export PATH=/opt/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabihf/bin:$PATH
#
export CROSS_COMPILE="ccache arm-linux-gnueabihf-"
export ARCH=arm
#
###########################################################
libpcapbuild(){
if [ ! -d libpcap ]; then 
	echo 'Error cannot find libpcap'
	exit 20
fi

bbpath=/home/andrey/BBB/busybox

if [ ! -d $bbpath ]; then
	echo 'Error. Cannot find busybox.' 
	exit 21
fi

cd libpcap/

make distclean

VERL=libpcap-1.8.1

git tag | grep $VERL

git checkout $VERL

./configure --host=arm-linux-gnueabihf --with-pcap=linux

make -j4

if [ ! -f libpcap.a ]; then
	echo 'Error. Cannot find libpcap.a' 
	exit 22
fi

echo 'Done.'	
file libpcap.a

cd - &> /dev/null
}

##############################################################

t-dumpbuild(){

if [ ! -d tcpdump ]; then
	echo 'Error. Cannot find tcpdump.'
	exit 23
fi

cd tcpdump/
echo 'Making it clean...'
make distclean

VERT=tcpdump-4.9.2
bbpath=/home/andrey/BBB/busybox

git tag | grep $VERT
git checkout $VERT

export PREFIX=$bbpath/_install/usr
./configure --host=arm-linux-gnueabihf --prefix=$PREFIX

make -j4
if [ ! -f tcpdump ]; then
	echo 'Error. Cannot find tcpdump'
	exit 24
fi
file tcpdump
arm-linux-gnueabihf-readelf -d tcpdump | grep -i needed

echo "Tcpdump will be installed to $PREFIX/sbin"
make install

cd - &> /dev/null 

echo 'Done.'
}
############################################################
## entry point

libpcapbuild
t-dumpbuild





