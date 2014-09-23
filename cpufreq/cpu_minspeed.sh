#!/bin/bash
#sudo cpupower -c 0-3 frequency-set -f 12000000
sudo service ksm stop
sudo cpupower -c 0-3 frequency-set -d  1200000 -u 1200000 -g userspace
#echo 0 | sudo  tee /sys/devices/system/cpu/cpu1/online
echo 0 | sudo  tee /sys/devices/system/cpu/cpu2/online
echo 0 | sudo  tee /sys/devices/system/cpu/cpu3/online
