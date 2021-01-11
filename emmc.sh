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
	local kernel_dev
	local rootfs_dev
	local board=$(board_name)
	local rootfs="$(emmc_get_active_part)"

	case "$board" in
		sony,ncp-hg100)
			kernel_dev="/dev/mmcblk0p14"
			rootfs_dev="/dev/mmcblk0p16"
			case "${rootfs}" in
				"rootfs"|\
				"")
					local bootpart=`dd if=/dev/mmcblk0p2 bs=1 count=1 skip=108 2> /dev/null |hexdump -e '"%d"'`
					if [ ${bootpart} -eq 0 ]; then
						echo force change "BOOTCONFIG"
						echo -en '\x01' | dd of=/dev/mmcblk0p2 bs=1 count=1 seek=88
						echo -en '\x01' | dd of=/dev/mmcblk0p2 bs=1 count=1 seek=108
						echo -en '\x01' | dd of=/dev/mmcblk0p7 bs=1 count=1 seek=88
						echo -en '\x01' | dd of=/dev/mmcblk0p7 bs=1 count=1 seek=108
					fi
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