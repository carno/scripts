#!/bin/bash
# Simple script to extract jpg thumbnails from Canon's CR2 files
# Author: <carnophage at dobramama dot pl>

DIR=$(pwd)

# Let's create a folder for the extracted files
if [ ! -d ${DIR}/thumb ]; then
    echo " [info] $DIR/thumb doesn't exist, creating a new one..."
    mkdir -p ${DIR}/thumb
else
    echo " [info] Folder ${DIR}/thumb already exists"
fi

# Let's extract the thumbnails and move them to the thumb folder
for i in $(find ${DIR} -type f -name "*.CR2"); do
    echo " [info] Working on: $(basename ${i})"
    dcraw -e "${i}"
    mv ${DIR}/$(basename ${i} .CR2).thumb.jpg ${DIR}/thumb/
done

exit 0
