#!/bin/bash
while [ true ]; do
	case $1 in
		"-r")
			RECURSIVE="-r"
			shift
			;;
        "--crf"|"-c")
            shift
            CRF=$1
            shift
            ;;
        "--delete"|"-d")
            DELETE="yes"
            shift
            ;;
		"-h")
			echo "Usage: $0 [-h] [-r] [-c] [-o] file [file ...]"
			echo
			echo "  file   File(s) to be proceed"
			echo "  -h     Show this help"
            echo "  -r     Recursive"
            echo "  -c     conversion video quality (crf)"
            echo "  -d     delete original file"
			exit 1
			;;
		*)
			break
		shift
	esac
done

[ ! "$CRF" ] && CRF=23

convert() {
    if file "$FILE" | grep "ISO Media, " &>/dev/null; then
        if [[ "$FILE" == *x265.mp4 ]]; then
            echo "SKIP already x265: $1"
            return
        fi
        if [ -e "$FILE.x265.mp4" ]; then
            echo "SKIP x265 exists: $1"
            return
        fi
        # Do the conversion
        echo "Processing $1"
        # diit - doporučení
        # $ ./fffmpeg -i INPUT -map 0:v -map 0:a -c:v libx265 -crf 32 -c:a libopus -compression_level 10 -b:a 80k -vbr on OUTPUT.mkv
        # možné přidat: "-vf scale=960x540:flags=lanczos"
        # moje testované
        ffmpeg -nostdin -i "$1" -c:v libx265 -preset veryslow -crf $CRF -c:a aac -b:a 128k "$FILE.x265.mp4" &> convert.log
        if [ ${PIPESTATUS[0]} -ne 0 ]; then
            cat convert.log
            exit -10
        else
            rm convert.log
            [ "$DELETE" == "yes" ] && rm "$1"
        fi
    else
        #echo "SKIP not video: $1"
        return
    fi
}

if [ "$RECURSIVE" ]; then
    find $* -type f -print0 | while read -d $'\0' FILE; do
        convert "$FILE"
    done
else
    for FILE in $*; do
        convert "$FILE"
    done
fi
