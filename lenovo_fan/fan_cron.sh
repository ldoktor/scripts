#!/bin/bash
#TEMP=`cat /proc/acpi/ibm/thermal | cut -f2 | cut -d' ' -f1`
TEMP=`cat /sys/class/thermal/thermal_zone0/temp`
[ -f /tmp/temperature_offset ] && TEMP=$(expr $TEMP + $(cat /tmp/temperature_offset))
echo $TEMP
if [ $TEMP -gt 80000 ]; then
    echo level full-speed > /proc/acpi/ibm/fan
else
    echo level auto > /proc/acpi/ibm/fan
fi
#elif [ $TEMP -gt 70000 ]; then
#    echo level auto > /proc/acpi/ibm/fan
#elif [ $TEMP -gt 65000 ]; then
#    echo level 1 > /proc/acpi/ibm/fan
#elif [ $TEMP -lt 55000 ]; then
#    echo level 0 > /proc/acpi/ibm/fan
#fi
