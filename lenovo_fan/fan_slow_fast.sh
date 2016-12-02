#!/bin/bash
# This switches to /tmp/temperature_offset temperature
TARGET="/tmp/temperature_offset"
if [ -f "$TARGET" ]; then
    rm $TARGET
    notify-send --hint int:transient:1 "Normal FAN speed"
else
    echo 30000 > $TARGET
    notify-send --hint int:transient:1 "Fast FAN speed"
fi
