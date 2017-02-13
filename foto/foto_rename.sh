#!/bin/bash
while [ true ]; do
	case $1 in
		"-o")
			shift
			OFFSET=$1
			shift
			;;
		"-r")
			RECURSIVE="-r"
			shift
			;;
        "-s")
            shift
            SUFFIX="_$1"
            shift
            ;;
        "--resize"|"-R")
            shift
            RESIZE=$1
            shift
            ;;
		"-h")
			echo "Usage: $0 [-h] [-o] [-r] [-s] [-R] file [file ...]"
			echo
			echo "  file   File(s) to be proceed"
			echo "  -h     Show this help"
			echo "  -o     Image offset Y:M:D h:m:s"
            echo "  -r     Recursive"
            echo "  -s     Optional suffix after the name"
			exit 1
			;;
		*)
			break
		shift
	esac
done

#OFFSET='0:0:0 00:50:0'
#exiftool -AllDates+="$shift" -IFD1:ModifyDate+="$shift" -FileModifyDate+="$shift" -overwrite_original_in_place -r .
#exiftool '-FileName<CreateDate' -d IMG_%Y%m%d_%H%M%S_tata.%%e -overwrite_original_in_place -r .
[ "$OFFSET" ] && exiftool -AllDates+="$OFFSET" -IFD1:ModifyDate+="$OFFSET" -FileModifyDate+="$OFFSET" -overwrite_original_in_place -r $*
exiftool '-FileName<CreateDate' -d "IMG_%Y%m%d_%H%M%S%%-c${SUFFIX}.%%e" -overwrite_original_in_place $RECURSIVE $*
if [ $RESIZE ]; then
    IFS=`echo`
    if [ $RECURSIVE ]; then
        for FILE in `find $* -type f`; do
            convert "$FILE" -resize $RESIZE "$FILE"
        done
    else
        for FILE in $*; do
            [ -f "$FILE" ] && convert "$FILE" -resize "$RESIZE" "$FILE"
        done
    fi
    unset IFS
fi
