#!/bin/bash -x

set -e

echo '----------Start populate.sh script.------------'

GCCPATH=/opt/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabihf/bin

print_usage() {
        echo "Usage: $0 /path_to_busybox /path_to_kernel"
}

if [ $# -ne 2 ]; then
    echo "Error: Too few arguments" >&2
    print_usage
    exit 1
fi

bbpath=$1
kpath=$2

export ARCH=arm
export PATH=$GCCPATH:$PATH
export CROSS_COMPILE="ccache arm-linux-gnueabihf-"


if [ ! -d $1 ]; then 
	echo "Error. Cannot find $1"
	exit 11
fi

if [ ! -d $2 ]; then 
	echo "Error. Canno find $2"
	exit 12
fi

if [ -d $bbpath/_install ]; then
	rm -rf $bbpath/_install
fi

mkdir -p $bbpath/_install/{boot,dev,etc\/init.d,lib,proc,root,sys\/kernel\/debug,tmp}

fillrcs(){
cat > $bbpath/_install/etc/init.d/rcS <<'EOF'
#!/bin/sh
mount -t sysfs none /sys
mount -t proc none /proc
mount -t debugfs none /sys/kernel/debug
echo /sbin/mdev > /proc/sys/kernel/hotplug
mdev -s
EOF
}

if [ ! -f $bbpath/_install/etc/init.d/rcS ]; then 
	touch $bbpath/_install/etc/init.d/rcS
	chmod +x $bbpath/_install/etc/init.d/rcS
	fillrcs
fi

ln -s $bbpath/_install/bin/busybox $bbpath/_install/init

###########################################################

if [ -f $kpath/arch/arm/boot/zImage ]; then
	cp $kpath/arch/arm/boot/zImage $bbpath/_install/boot
else 
	echo 'Error. Cannot find zImage.'
	exit 13
fi

if [ -f $kpath/arch/arm/boot/dts/am335x-boneblack.dtb ]; then
	cp $kpath/arch/arm/boot/dts/am335x-boneblack.dtb $bbpath/_install/boot
else 
	echo 'Error. Cannot find .dtb-file.'
	exit 14
fi

if [ -f $kpath/System.map ]; then
	cp $kpath/System.map $bbpath/_install/boot
else 
	echo 'Error. Cannot find System.map.'
	exit 15
fi

#!!!+ cp linux/.config ./config
#!!!  cp: cannot stat 'linux/.config': No such file or directory


if [ ! -f $kpath/.config ]; then
	echo "Error. Cannot find $kpath/.config"
	exit 16
else 
	cp $kpath/.config $bbpath/_install/boot/config
fi

###########################################################

cd $kpath
export INSTALL_MOD_PATH=$bbpath/_install
#export ARCH=arm ----- Already exported
make modules_install
cd - &>/dev/null

###########################################################

cd $bbpath/_install/lib
libc_dir=$(${CROSS_COMPILE}gcc -print-sysroot)/lib
cp -a $libc_dir/*.so* .
cd - &>/dev/null

###########################################################

echo '$MODALIAS=.* root:root 660 @modprobe "$MODALIAS"' > $bbpath/_install/etc/mdev.conf
echo 'root:x:0:' > $bbpath/_install/etc/group
echo 'root:x:0:0:root:/root:/bin/sh' > $bbpath/_install/etc/passwd
echo 'root::10933:0:99999:7:::' > $bbpath/_install/etc/shadow

echo "nameserver 8.8.8.8" > $bbpath/_install/etc/resolv.conf

echo
echo '----------End populate.sh script.------------'
