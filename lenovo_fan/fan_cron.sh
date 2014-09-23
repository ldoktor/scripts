#!/bin/bash
#TEMP=`cat /proc/acpi/ibm/thermal | cut -f2 | cut -d' ' -f1`
TEMP=`cat /sys/class/thermal/thermal_zone0/temp`
if [ $TEMP -gt 85000 ]; then
    echo level full-speed > /proc/acpi/ibm/fan
#elif [ $TEMP -gt 65000 ]; then
#    echo level auto > /proc/acpi/ibm/fan
#else
#    echo level 0 > /proc/acpi/ibm/fan
#fi
else
    echo level auto > /proc/acpi/ibm/fan
fi
