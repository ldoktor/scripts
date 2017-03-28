#!/bin/bash
OLD_LINE="";
while :; do
    LINE=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -e "rate:" -e "to empty:"| xargs)
    [ "$LINE" != "$OLD_LINE" ] && echo $(date) $LINE; OLD_LINE="$LINE"
    sleep 10
done
