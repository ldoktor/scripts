#!/bin/bash
[ "$1" ] || { echo "Please specify target location as first argument"; exit -1; }
TARGET="$1"
RSYNC="rsync -amrh --stats --delete-after"

run() {
    echo -e "\e[92m"
    echo "==============================================================="
    echo $*
    echo "==============================================================="
    echo -e "\e[0m"
    $*
}

for FOLDER in programs games; do
        run $RSYNC /home/medic/ownCloud/Kurzy/flashdisk/$FOLDER/ $TARGET/$FOLDER
done
