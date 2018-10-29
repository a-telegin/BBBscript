#!/bin/bash -x
echo '----------Start bbox.sh script.------------'

set -e

VER=1_28_stable
GCCPATH=/opt/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabihf/bin

print_usage() {
        echo "Usage: $0 /path_to_busybox"
}

if [ $# -ne 1 ]; then
    echo "Error: Too few arguments" >&2
    print_usage
    exit 1
fi

#############################################################

if [ ! -d $1 ]; then
	echo "Error. Cannot find $1"
	exit 2
fi

#############################################################

export ARCH=arm
export PATH=$GCCPATH:$PATH
export CROSS_COMPILE="ccache arm-linux-gnueabihf-"

cd $1 &>/dev/null

echo 'Making it clean...'
#make mrproper
make distclean

if [ -d _install ]; then
	echo 'Deleting _install folder...'	
	rm -rf _install
fi

git checkout $VER

make defconfig

make -j4

make install

cd - &>/dev/null
echo
echo '----------End bbox.sh script.------------'
