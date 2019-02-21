cd /sys/devices/system/cpu/
if [ $(cat cpu*/online | tail -n 1) == "1" ]; then
    for AAA in cpu*/online; do
        # we can ignore cpu0 as it won't be disabled...
        [ "$AAA" != cpu4/online ] && echo 0 | sudo tee $AAA
    done
    notify-send --hint int:transient:1 "CPUs 2+ disabled"
else
    for AAA in cpu*/online; do
        echo 1 | sudo tee $AAA
    done
    notify-send --hint int:transient:1 "All CPUs enabled"
fi
