#!/bin/bash

set -eo pipefail

declare -r ESSID=''
declare -r NFSDIR=''
declare -r NFSMOUNT=''
declare -r REPOSITORY=''
declare -r WHAT=''

_checkessid() {
    # check if connected to desired wifi network
    local current_essid=$(iwgetid --raw)
    if [[ "${current_essid}" == "${ESSID}" ]]; then
        return 0
    else
        return 1
    fi
}

_checkmount() {
    # check if nfs share is mounted
    if mount | grep -q ${NFSMOUNT}; then
        return 0
    else
        return 1
    fi
}

if ! _checkessid; then
    echo ">> Not @${ESSID}, aborting…" >&2
    exit 1
fi

if ! _checkmount; then
    echo ">> NFS not mounted, attempting to mount"
    mount -v "${NFSDIR}" "${NFSMOUNT}"
    if [[ $? -ne 0 ]]; then
        echo ">> Failed to mount ${NFSDIR}, aborting" >&2
        exit 1
    fi
else
    echo ">> ${NFSMOUNT} already mounted"
fi

echo ">> Creating new backup"
borg create -svx -C zlib "${REPOSITORY}"::{hostname}-{now:%Y-%m-%d_%H:%M:%S} \
    "${WHAT}" \
    --exclude-if-present .nobackup \
    --exclude "${WHAT}/.cache"

echo ">> Removing old backups"
borg prune -vs "${REPOSITORY}" --prefix '{hostname}-' --keep-hourly=23 --keep-daily=7 --keep-weekly=4 --keep-monthly=6

echo ">> Unmounting ${NFSMOUNT}"
sync && umount -v "${NFSMOUNT}"

exit 0
