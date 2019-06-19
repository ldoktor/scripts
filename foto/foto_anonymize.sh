[ -z "$*" ] && { echo Specify at least on file; exit -1 }
exiftool -all= $*
