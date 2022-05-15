#!/usr/bin/env bash

set -euo pipefail

declare -r _VERSION="${1:?Missing Iosevka version}"
declare -a _FILES=("ttf-iosevka-term-")
_TMP=$(mktemp -d)
declare -r _TMP

function _cleanup() {
    rm -rf "${_TMP}"
}

trap _cleanup EXIT

for prefix in "${_FILES[@]}"; do
    echo "Downloading ${prefix}${_VERSION}.zip…"
    curl -sSLO --fail --output-dir "${_TMP}" "https://github.com/be5invis/Iosevka/releases/download/v${_VERSION}/${prefix}${_VERSION}.zip"
done

echo "Extracting archives…"
unzip -o -u "${_TMP}/*.zip" "iosevka-term-medium*.ttf" -d "${_TMP}/in"
mkdir -p "${_TMP}/out"

echo "Patching with nerdfonts…"
set +e
docker run \
    --user "$(id -u):$(id -g)" \
    --volume "${_TMP}/in":/in \
    --volume "${_TMP}/out":/out \
    --rm \
    nerdfonts/patcher --complete --careful --no-progressbars --quiet
set -e

echo "Removing old fonts…"
# shellcheck disable=SC2086
rm -rf ${HOME}/.fonts/[iI]osevka*

echo "Copying patched fonts…"
# shellcheck disable=SC2086
cp -v ${_TMP}/out/* "${HOME}/.fonts/"

echo "Refreshing font cache…"
fc-cache -f -v
