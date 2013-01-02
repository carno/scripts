#!/bin/bash

# Check if a package is available in debian experimental/backports repository

_PKG="$1"
if [ "$2" == "backports" ]; then
    _REPO='squeeze-backports'
else
    _REPO='experimental'
fi

echo "Searching for ${_PKG} in ${_REPO}"
curl --compressed -sS "http://packages.debian.org/${_REPO}/allpackages?format=txt.gz" | egrep ^"${_PKG}"
