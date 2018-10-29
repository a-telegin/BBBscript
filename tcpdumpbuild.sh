#!/bin/bash -x

set -e

if [ ! -d libpcap ]; then 
	echo 'Error cannot find libpcap'
	exit 20
else
	cd libpcap/
fi

export PATH=/opt/gcc-linaro-6.4.1-2017.11-x86_64_arm-linux-gnueabihf/bin:$PATH

make distclean

VERL=libpcap-1.8.1

git tag | grep $VERL

git checkout $VERL

./configure --host=arm-linux-gnueabihf --with-pcap=linux

make -j4

if [ ! -f libpcap.a ]; then
	echo 'Error. Cannot find libpcap.a' 
	exit 21
fi

echo 'Done.'	
file libpcap.a

cd - &> /dev/null

if [ ! -d tcpdump ]; then
	echo 'Error. Cannot find tcpdump.'
	exit 22
fi

cd tcpdump/


VERT=tcpdump-4.9.2
bbpath=../busybox

git tag | grep $VERT

if [ ! -d $bbpath ]; then
	echo 'Error. Cannot find busybox.' 
	exit 23
fi

export PREFIX=$bbpath/_install/usr
./configure --host=arm-linux-gnueabihf --prefix=$PREFIX

make -j4
if [ ! -f tcpdump]; then
	echo 'Error. Cannot find tcpdump'
	exit 24
fi
file tcpdump
arm-linux-gnueabihf-readelf -d tcpdump | grep -i needed

echo "Tcpdump will be installed to $PREFIX/sbin"
make install

cd - &> /dev/null 
echo 'Done.'






