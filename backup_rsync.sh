[ "$1" ] || { echo "Please specify target location as first argument"; exit -1; }
TARGET="$1"
RSYNC="rsync -amrh --stats --delete-after"
# Use --ignore-errors to delete files when errors occur

run() {
    echo -e "\e[92m"
    echo "==============================================================="
    echo $*
    echo "==============================================================="
    echo -e "\e[0m"
    $*
}


run $RSYNC "/home/medic/Foto" "$TARGET"
run $RSYNC "/home/medic/ownCloud" "$TARGET"
run $RSYNC "/home/medic/Docs" "$TARGET/ldoktor"
run $RSYNC "/home/medic/Work" "$TARGET/ldoktor"
# Treating only hidden files from home is a bit harder...
run echo $RSYNC HIDDEN FILES OF HOME
find /home/medic -maxdepth 1 -name '.*' -printf %P\\0 | $RSYNC --files-from=- --from0 /home/medic "$TARGET/ldoktor/"
sync
