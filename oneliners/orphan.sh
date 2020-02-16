#!/bin/bash

# List packages that are not available in currently enabled repositories
# Note: packages installed manually with dpkg -i will also be listed

# apt-show-versions | awk '/No available version in archive/{print $1}'

apt list --installed | awk -F/ '/\[installed,local\]/{print $1}'
