#!/usr/bin/env bash

set -eo pipefail

_WORKDIR=$(mktemp -d)
declare -r _WORKDIR

_cleanup() {
    rm -rf "${_WORKDIR:?Empty _WORKDIR}"
}

trap _cleanup EXIT

_RG_TGZ=$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep -E -o 'https://github.com/BurntSushi/ripgrep/releases/download/.*x86_64-unknown-linux.*tar.gz')
if [[ -z "${_RG_TGZ}" ]]; then
    echo "[ !! ] Failed to find latest ripgrep release archive"
    exit 3
fi
cd "${_WORKDIR}"
wget -q "${_RG_TGZ}"
tar -xzf ./*.tar.gz
# copy binary
install -v ripgrep*/rg /usr/local/bin/
# copy man
install -v ripgrep*/rg.1 /usr/local/share/man/man1/
# copy completion
install -v ripgrep*/complete/rg.bash-completion /etc/bash_completion.d/
