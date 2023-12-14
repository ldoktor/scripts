#!/bin/bash -e
REMOVE=0
if [ "$1" == "-r" ]; then
    REMOVE=1
    shift
fi
if [ "$#" -lt 2 ] || [ -e "${@: -1}" ]; then
    echo "Usage: $0 [-r] SOURCE_IMAGE [SOURCE_IMAGE ...] NON_EXISTING_DST_FILE_WITHOUT_EXT"
    exit -1
fi
convert $*-tmp.pdf
gs -q -sPAPERSIZE=letter -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dPrinted=false -dColorImageResolution=1200 -sOutputFile="${@: -1}".pdf "${@: -1}"-tmp.pdf && rm "${@: -1}"-tmp.pdf
if [ "$REMOVE" == 1 ]; then
    rm -f ${@:1:$#-1}
fi
