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


cd "${_TMP}"
for prefix in "${_FILES[@]}"; do
    echo "Downloading ${prefix}${_VERSION}.zip…"
    curl -sSLO --fail "https://github.com/be5invis/Iosevka/releases/download/v${_VERSION}/${prefix}${_VERSION}.zip"
done
cd -

echo "Extracting archives…"
unzip -u -d "${HOME}/.fonts" "${_TMP}/*.zip"

# update font cache
fc-cache -f -v
