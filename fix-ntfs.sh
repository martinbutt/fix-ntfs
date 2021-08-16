#!/usr/bin/env bash

usage() {
cat << EOF
Usage: $(basename $0) <mount_source> <mount_target>

Options:
  <mount_source>  The device to fix, e.g. /dev/sda1
  <mount_target>  The directory to mount to, e.g. /mnt/my_drive
EOF
    exit
}

if ! command -v ntfsfix 2>&1 > /dev/null; then
	echo "ERROR: 'ntfsfix' not found in PATH"
	exit 1
fi

if ! command -v ntfs-3g 2>&1 > /dev/null; then
	echo "ERROR: 'ntfs-3g' not found in PATH"
	exit 1
fi

mount_source=${1}
mount_target=${2}

if [ -z "${mount_source}" ] || [ -z "${mount_source}" ]; then
	usage
fi

if ! ls "${mount_source}" 2>/dev/null > /dev/null; then
	echo "ERROR: Mount source not found '${mount_source}'";
	exit
fi

if [ ! -d "${mount_target}" ]; then
	echo "ERROR: Mount target not a directory '${mount_target}'";
	exit
fi

processes=$(lsof +f -- "${mount_target}" 2>/dev/null | tail -n +2)

while [ -n "${processes}" ]; do
	echo "$(echo "${processes}" | wc -l) processes preventing 'umount'"
	echo "${processes}"

	process=$(echo "${processes}" | tail -n 1)

	if [ -n "${process}" ]; then
		echo
		echo "Current process details:"
		echo "${process}"

		read -p "Kill it? [y/N] " -n1 kill_process

		if [ "${kill_process}" == "Y" ] || [ "${kill_process}" == "y" ]; then
			kill -9 $(echo ${process} | cut -d " " -f 2)
		else
			echo -e "\nManually exit processes and re-run"
			exit
		fi
	fi

	processes=$(lsof +f -- "${mount_target}" 2>/dev/null | tail -n +2)
done

sudo umount "${mount_source}"
sudo ntfsfix "${mount_source}"
sudo umount "${mount_source}"
sudo ntfs-3g -o recover,rw,umask=000,dmask=002,fmask=113,uid=1000,gid=1000 "${mount_source}" "${mount_target}"
sudo umount "${mount_target}"
sudo mount "${mount_source}" "${mount_target}"
