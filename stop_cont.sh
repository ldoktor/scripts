#!/bin/bash
PROGRAMS="firefox java plugin-container qemu qemu-kvm gnome-software empathy empathy-chat skype"
if [ -f /tmp/stop_cont ]; then
    for PROGRAM in $PROGRAMS; do
        killall -SIGCONT $PROGRAM &>/dev/null
    done
    sudo modprobe e1000e
    echo "RESUMED"
    rm /tmp/stop_cont
    notify-send --hint int:transient:1 "Processes RESUMED"
else
    for PROGRAM in $PROGRAMS; do
        killall -SIGSTOP $PROGRAM &>/dev/null
    done
    sudo rmmod e1000e
    echo "STOPPED"
    touch /tmp/stop_cont
    notify-send --hint int:transient:1 "Processes STOPPED"
fi
