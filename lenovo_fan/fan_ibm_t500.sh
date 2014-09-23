#!/bin/bash
while [ true ]; do
    if [ `cat /proc/acpi/thermal_zone/THM1/temperature | cut -d: -f2| cut -dC -f 1` -gt 80 ]; then
        echo "FULL"
        echo level full-speed > /proc/acpi/ibm/fan
    else
        echo "AUTO"; echo level auto > /proc/acpi/ibm/fan
    fi
    sleep 1m
done
