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
    if mountpoint -q ${NFSMOUNT}; then
        return 0
    else
        return 1
    fi
}


_finish() {
    # clean up
    # do not umount while borg is running
    while pgrep borg &>/dev/null; do
        sleep 3
    done
    if _checkmount; then
        echo ">> Unmouting ${NFSMOUNT}"
        umount -v -l "${NFSMOUNT}"
    fi
}

trap _finish EXIT

if ! _checkessid; then
    # not @home, abort
    echo ">> Not @home, aborting…" >&2
    exit 0
fi

if ! _checkmount; then
    echo ">> NFS not mounted, attempting to mount"
    mount -v -t nfs4 "${NFSDIR}" "${NFSMOUNT}"
    if [[ $? -ne 0 ]]; then
        echo ">> Failed to mount ${NFSDIR}, aborting" >&2
        exit 1
    fi
else
    echo ">> ${NFSMOUNT} already mounted"
fi

# create backup
echo ">> Creating new backup"
borg create -svx -C zlib --show-rc "${REPOSITORY}"::{hostname}-{now:%Y-%m-%d_%H:%M:%S} \
    "${WHAT}" \
    --exclude-if-present .nobackup \
    --exclude "${WHAT}/.adobe" \
    --exclude "${WHAT}/.cache" \
    --exclude "${WHAT}/.macromedia" \
    --exclude "${WHAT}/.thumbnails"

# remove old backups
echo ">> Removing old backups"
borg prune -sv --show-rc "${REPOSITORY}" --prefix '{hostname}-' --keep-hourly=12 --keep-daily=7 --keep-weekly=4 --keep-monthly=6

exit 0
