#!/bin/bash
PROGRAMS="firefox java plugin-container qemu qemu-kvm empathy empathy-chat pidgin"
if [ -f /tmp/stop_cont ]; then
    for PROGRAM in $PROGRAMS; do
        killall -SIGCONT $PROGRAM &>/dev/null
    done
    killall -SIGCONT "Web Content"  # firefox threads
    sudo modprobe e1000e
    # [ -e /tmp/stop_cont_pulseaudio ] && kill -SIGCONT $(cat /tmp/stop_cont_pulseaudio)
    #echo '3-5' |sudo tee /sys/bus/usb/drivers/usb/bind
    echo "RESUMED"
    rm /tmp/stop_cont
    notify-send --hint int:transient:1 "Processes RESUMED"
else
    for PROGRAM in $PROGRAMS; do
        killall -SIGSTOP $PROGRAM &>/dev/null
    done
    killall -SIGSTOP "Web Content"  # firefox threads
    sudo rmmod e1000e
    # pasuspender sleep 14d &
    # echo $! > /tmp/stop_cont_pulseaudio
    #echo '3-5' |sudo tee /sys/bus/usb/drivers/usb/unbind
    echo "STOPPED"
    touch /tmp/stop_cont
    notify-send --hint int:transient:1 "Processes STOPPED"
fi
