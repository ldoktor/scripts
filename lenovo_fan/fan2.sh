#!/bin/bash
#TEMP=`cat /proc/acpi/ibm/thermal | cut -f2 | cut -d' ' -f1`
STATE="NONE"
HYST=0
while :; do
    sleep 10
    TEMP=`cat /sys/class/thermal/thermal_zone0/temp`
    if [ $TEMP -gt 87000 ] && [ $STATE != "FULL" ]; then
        echo `date +%X` "FULL ${TEMP}C"
        echo level full-speed > /proc/acpi/ibm/fan
        STATE="FULL"
    elif [ $TEMP -gt 67000 ] && [ $STATE != "AUTO" ]; then
        echo `date +%X` "AUTO ${TEMP}C"
        echo level auto > /proc/acpi/ibm/fan
        STATE="AUTO"
        HYST=0
    elif [ $STATE != "STOP" ]; then
        if [ $HYST -le 2 ]; then
            let HYST++
            continue
        fi
        echo `date +%X` "STOP ${TEMP}C"
        echo level 0 > /proc/acpi/ibm/fan
        STATE="STOP"
    fi
done
