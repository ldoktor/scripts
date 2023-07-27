#!/bin/bash
# Resize pictures rated 0 (or not rated) to $2 and use jpegoptim on them

SRC="$1"
SIZE="$2"
QUALITY="$3"

[ "$SRC" ] || exit 1
[ "$SIZE" ] || SIZE=2048
[ "$QUALITY" ] || QUALITY=80

SKIP_RATED=0
SKIP_NO_SIZE=0
SKIP_NOJPG=0
OPTIMIZED=0
RESIZED=0

SIZE_BEFORE=$(du -hs "$SRC")

pushd "$SRC"
find . -type d -print0 | while read -d $'\0' DIR; do
    echo -n "Processing: $DIR "
    find "$DIR" -maxdepth 1 -type f -print0 | while read -d $'\0' FILE; do
        if ! file "$FILE" | grep "JPEG image data" &>/dev/null; then
            #echo "  SkipNotJPG $FILE"
            SKIP_NOJPG=$((SKIP_NOJPG+1))
            continue
        fi
        RATING=$(exiftool -rating "$FILE" 2>/dev/null)
        if echo "$RATING" | grep -q "Rating    " && echo "$RATING" | grep -q -v "  : 0"; then
            #echo "  SkipRated $FILE"
            SKIP_RATED=$((SKIP_RATED+1))
        else
            H=$(identify -format "%h\n" "$FILE")
            HR=$?
            W=$(identify -format "%w\n" "$FILE")
            WR=$?
            if [ "$HR" -ne 0 ] || [ "$WR" -ne 0 ]; then
                #echo "  SkipNoSize $FILE"
                SKIP_NO_SIZE=$((SKIP_NO_SIZE+1))
                continue
            fi
            if [ "$H" -gt 2048 ] || [ "$W" -gt 2048 ]; then
                #echo "  Resizing $FILE"
                RESIZED=$((RESIZED+1))
                convert "$FILE" -resize "$SIZE" -quality "100" "$FILE" >/dev/null
            else
                #echo "  Optimizing $FILE"
                OPTIMIZED=$((OPTIMIZED+1))
            fi
            jpegoptim -m "$QUALITY" "$FILE" >/dev/null
        fi
        echo -ne "\r"
        echo -n "Processing: $DIR Optim:$OPTIMIZED Res:$RESIZED sRated: $SKIP_RATED sNoSize:$SKIP_NO_SIZE sNotJPG:$SKIP_NOJPG"
    done
    echo
    touch "$DIR/.resized_rating0"
done
popd

echo
echo "Size before $SIZE_BEFORE"
echo "Size after $(du -hs "$SRC")"
