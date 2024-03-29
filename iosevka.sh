#!/usr/bin/env bash

set -euo pipefail

declare -r _VERSION="${1:?Missing Iosevka version}"
declare -a _FILES=("PkgTTF-IosevkaTerm-")
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
unzip -o -u "${_TMP}/*.zip" IosevkaTerm-Regular.ttf IosevkaTerm-Italic.ttf IosevkaTerm-Bold.ttf -d "${_TMP}/in"
mkdir -p "${_TMP}/out"

echo "Patching with nerdfonts…"
set +e
docker run \
    --pull always \
    --user "$(id -u):$(id -g)" \
    --volume "${_TMP}/in":/in \
    --volume "${_TMP}/out":/out \
    --rm \
    nerdfonts/patcher --complete --quiet
set -e

echo "Checking docker run output…"
test -n "$(find "${_TMP}/out" -type f -name '*.ttf')"

echo "Removing old fonts…"
# shellcheck disable=SC2086
rm -rf ${HOME}/.fonts/[iI]osevka*

echo "Copying patched fonts…"
# shellcheck disable=SC2086
cp -v ${_TMP}/out/* "${HOME}/.fonts/"

echo "Refreshing font cache…"
fc-cache -f -v
