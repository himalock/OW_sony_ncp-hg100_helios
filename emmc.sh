#!/bin/sh

. /lib/functions.sh

emmc_get_active_part() {
	local rootfs
	local root

	if read cmdline < /proc/cmdline; then
		case "$cmdline" in
			*rootfsname=*)
				rootfs="${cmdline##*rootfsname=}"
				rootfs="${rootfsname%% *}"
			;;
			*root=*)
				root="${cmdline##*root=}"
				root="${root%% *}"
			;;
		esac
		echo $rootfs
	fi
}

do_flash_partition() {
	local bin=$1
	local mmcblk=$2

	if [ -e "$mmcblk" ]; then
		#dd bs=4K if=/dev/zero of=${mmcblk}
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
	local kernel_dev="/dev/mmcblk0p14"
	local rootfs_dev="/dev/mmcblk0p16"
	local board=$(board_name)
	local rootfs="$(emmc_get_active_part)"

	case "$board" in
		sony,ncp-hg100)
			case "${rootfs}" in
				"rootfs"|\
				"")
					echo change boot partition set 1
					echo -en '\x01' | dd of=/dev/mmcblk0p2 bs=1 count=1 seek=28
					echo -en '\x01' | dd of=/dev/mmcblk0p2 bs=1 count=1 seek=48
					echo -en '\x01' | dd of=/dev/mmcblk0p2 bs=1 count=1 seek=68
					echo -en '\x01' | dd of=/dev/mmcblk0p2 bs=1 count=1 seek=88
					echo -en '\x01' | dd of=/dev/mmcblk0p2 bs=1 count=1 seek=108
				;;
				*)
					echo no change boot partition settings
				;;
			esac
			;;
		*)
			return 1
		;;
	esac

	do_emmc_upgrade_tar $tar_file $kernel_dev $rootfs_dev

	return 0
}
