while [ -e /tmp/a ]; do :; done; mencoder -tv driver=v4l2:device=/dev/video1:width=720:height=576:norm=PAL -ovc x264 -x264encopts threads=4:bitrate=1200:subq=2:frameref=4:8x8dct -oac mp3lame -lameopts cbr:br=128 -o test.avi tv:// -nosound -mc 0 -vf harddup

while [ -e /tmp/a ]; do :; done; arecord -f cd -t raw | oggenc - -r -o out.ogg
