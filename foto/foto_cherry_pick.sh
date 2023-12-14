#!/bin/sh

SRC="$1"
DST="$2"
SIZE="$3"

[ "$SRC" ] || exit 1
[ "$DST" ] || exit 2
[ "$SRC" == "$DST" ] && exit 3

cd "$SRC"
find . -type d -print0 | while read -d $'\0' DIR; do
    echo Processing: $DIR
    find "$DIR" -maxdepth 1 -type f -print0 | while read -d $'\0' FILE; do
        if [ "$(exiftool -rating "$FILE" 2>/dev/null | grep -v ": 0" | grep -c "Rating    ")" -eq 1 ]; then
            TARGET="$DST/$DIR"
            [ -d "$TARGET" ] || mkdir -p "$TARGET"
            TARGET=$(readlink -e "$TARGET")
            if [ "$SIZE" ]; then
                # Try to resize the pict, if fails proceed with copy
                echo convert "$FILE" -resize "$SIZE" -quality 50 "$TARGET/$(basename "$FILE")"
                convert "$FILE" -resize "$SIZE" -quality 50 "$TARGET/$(basename "$FILE")"
                if [ "$?" -eq 0 ]; then
                    exiftool -TagsFromFile "$FILE" '-all:all>all:all' -overwrite_original_in_place "$TARGET/$(basename "$FILE")"
                    DATE=`exiftool -t -s -d "%Y-%m-%d %H:%M:%S" -CreateDate "$i" | cut -f 2`
                    [ "$DATE" ] && touch -d "$DATE" "$i"
                    continue
                fi
            fi
            echo cp "'$FILE' '$TARGET'"
            cp "$FILE" "$TARGET"
        fi
    done
done
