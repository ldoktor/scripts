#!/bin/bash
while [ true ]; do
    if [ `cat /proc/acpi/ibm/thermal | cut -f2 | cut -d' ' -f1` -gt 75 ]; then
        echo "FULL"
        echo level full-speed > /proc/acpi/ibm/fan
    else
        echo "AUTO"; echo level auto > /proc/acpi/ibm/fan
    fi
    sleep 1m
done
