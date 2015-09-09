if [ $# -ne 1 ]; then
    echo "Usage: $0 MAX_SPEED_PERCENTAGE"
    exit 1
fi
echo $1 | sudo tee /sys/devices/system/cpu/intel_pstate/max_perf_pct
