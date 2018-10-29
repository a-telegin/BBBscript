#!/bin/bash -x

set -e

echo '----------Start kern.sh script.------------'

GCCPATH=/opt/gcc-linaro-7.2.1-2017.11-x86_64_arm-eabi/bin
VER=linux-4.16.y

print_usage() {
        echo "Usage: $0 /path_to_linux"
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


cd $1 &>/dev/null
echo 'Making it clean...'
#make mrproper
make distclean

isver=`git branch -a | grep $VER`

#echo $isver

if [ -n "$isver" ]; then
	echo "Checkout to $VER"
fi

git checkout $VER

export PATH=$GCCPATH:$PATH
#echo "\$PATH="$PATH
export CROSS_COMPILE='ccache arm-eabi-'
#echo "\$CROSS_COMPILE="$CROSS_COMPILE
export ARCH=arm
#echo "\$ARCH="$ARCH

fillbbb() {
cat > $1/fragments/bbb.cfg <<'EOF'
# Use multi_v7_defconfig as a base for merge_config.sh
# --- USB ---
# Enable USB on BBB (AM335x)
CONFIG_AM335X_PHY_USB=y
CONFIG_NOP_USB_XCEIV=y
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y
CONFIG_USB_CONFIGFS=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
# For USB keyboard and mouse
CONFIG_USB_HID=y
CONFIG_USB_HIDDEV=y
CONFIG_USB_INVENTRA_DMA=y
CONFIG_USB_MUSB_AM35X=y
CONFIG_USB_MUSB_DSPS=y
CONFIG_USB_MUSB_HDRC=y
CONFIG_USB_MUSB_OMAP2PLUS=y
CONFIG_USB_MUSB_TUSB6010=y
CONFIG_USB_SERIAL_GENERIC=y
# For USB mass storage devices (like flash USB stick)
CONFIG_USB_TI_CPPI41_DMA=y
CONFIG_USB_TUSB_OMAP_DMA=y
CONFIG_USB_ULPI=y
CONFIG_USB_ULPI_BUS=y
# --- Networking ---
CONFIG_BRIDGE=y
# --- Device Tree Overlays (.dtbo support) ---
CONFIG_OF_OVERLAY=y
EOF
}

if [ ! -d fragments ]; then
	mkdir $1/fragments/
	touch $1/fragments/bbb.cfg
	fillbbb
fi

if [ -f $1/fragments/bbb.cfg ]; then
KCONFIG_CONFIG=$1/arch/arm/configs/bbb_defconfig $1/scripts/kconfig/merge_config.sh -m -r $1/arch/arm/configs/multi_v7_defconfig $1/fragments/bbb.cfg
fi

make bbb_defconfig

make -j4 zImage modules am335x-boneblack.dtb

echo '----------End kern.sh script.------------'
