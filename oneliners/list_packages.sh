#!/bin/bash

# List packages in the repositories given as $1
# e.g. bash list_packages.sh ftp.pl.*

sed '/^Package/!d; s/^Package: //' /var/lib/apt/lists/${1} | sort -u
