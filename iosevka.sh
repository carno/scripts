#!/usr/bin/env bash

set -euo pipefail

declare -r _VERSION="${1:?Missing Iosevka version}"
declare -a _FILES=("ttc-iosevka-" "ttf-iosevka-" "ttf-iosevka-term-")
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
unzip -o -u "${_TMP}/*.zip" -d "${HOME}/.fonts"

# update font cache
fc-cache -f -v
