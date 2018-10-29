#!/bin/bash  -x
set -e
echo '----------Start ub.sh script.------------'
VER=v2018.05
GCCPATH=/opt/gcc-linaro-7.2.1-2017.11-x86_64_arm-eabi/bin

print_usage() {
        echo "Usage: $0 /path_to_u-boot"
}

if [ $# -ne 1 ]; then
    echo "Error: Too few arguments" >&2
    print_usage
    exit 1
fi

if [ ! -d $1 ]; then
	echo "Error. Cannot find $1"
	exit 2
fi

cd $1 &>/dev/null
ubpath=$1

echo 'Making it clean...'
#make mrproper
make distclean

isver=`git tag | grep $VER$`

if [ "$isver" = "$VER" ]; then
	echo "Checkout to $VER"
fi

git checkout $VER

export PATH=$GCCPATH:$PATH
#echo "\$PATH="$PATH
export CROSS_COMPILE='ccache arm-eabi-'
#echo "\$CROSS_COMPILE="$CROSS_COMPILE
export ARCH=arm
#echo "\$ARCH="$ARCH

make am335x_boneblack_defconfig

make -j4

echo '----------End ub.sh script.------------'
