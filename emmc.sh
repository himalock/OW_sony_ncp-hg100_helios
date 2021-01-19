#!/bin/sh

. /lib/functions.sh

get_active_part() {
	local rootfs

	if read cmdline < /proc/cmdline; then
		case "$cmdline" in
			*rootfsname=*)
				rootfs="${cmdline##*rootfsname=}"
				rootfs="${rootfsname%% *}"
			;;
		esac
		echo $rootfs
	fi
}

do_flash_partition() {
	local bin=$1
	local mmcblk=$2

	if [ -e "$mmcblk" ]; then
		echo dd bs=4K if=${bin} of=${mmcblk}
		dd bs=4K if=${bin} of=${mmcblk}
	fi
}

do_emmc_upgrade_tar() {
	local tar_file=$1
	local kernel_dev=$2
	local rootfs_dev=$3
	local kernel_bin=/tmp/kernel.bin
	local rootfs_bin=/tmp/rootfs.bin

	local board_dir=$(tar tf $tar_file | grep -m 1 '^sysupgrade-.*/$')
	board_dir=${board_dir%/}

	echo "flashing kernel to ${kernel_dev}"
	tar xf $tar_file ${board_dir}/kernel -O > $kernel_bin
	do_flash_partition $kernel_bin $kernel_dev

	echo "flashing rootfs to ${rootfs_dev}"
	tar xf $tar_file ${board_dir}/root -O > $rootfs_bin
	do_flash_partition $rootfs_bin $rootfs_dev

	echo upgrade complete!
	echo umount and rebooting...
	sync
	umount -a
	reboot -f
}

emmc_do_upgrade() {
	local tar_file=$1
	local kernel_dev=$(find_mmc_part kernel)
	local rootfs_dev=$(find_mmc_part rootfs)
	local board=$(board_name)
	local rootfs="$(get_active_part)"

	case "$board" in
		sony,ncp-hg100)
			kernel_dev=$(find_mmc_part 0:HLOS_1)
			rootfs_dev=$(find_mmc_part rootfs_1)

			local BOOTCONFIG=$(find_mmc_part 0:BOOTCONFIG)
			local BOOTCONFIG1=$(find_mmc_part 0:BOOTCONFIG1)
			local bootpart=$(dd if=${BOOTCONFIG} bs=1 count=1 skip=108 2> /dev/null |hexdump -e '"%d"')
			if [ ${bootpart} -eq 0 ]; then
				echo force change "BOOTCONFIG"
				echo -en '\x01' | dd of=${BOOTCONFIG} bs=1 count=1 seek=88 conv=notrunc
				echo -en '\x01' | dd of=${BOOTCONFIG} bs=1 count=1 seek=108 conv=notrunc
				echo -en '\x01' | dd of=${BOOTCONFIG1} bs=1 count=1 seek=88 conv=notrunc
				echo -en '\x01' | dd of=${BOOTCONFIG1} bs=1 count=1 seek=108 conv=notrunc
			else
				echo no change boot partition settings
			fi
		;;
		*)
			return 1
		;;
	esac

	do_emmc_upgrade_tar $tar_file $kernel_dev $rootfs_dev

	return 0
}
