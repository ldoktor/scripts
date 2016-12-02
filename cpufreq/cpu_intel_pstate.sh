if [ $# -ne 1 ] || [ $1 -ne $1 ] 2>/dev/null; then
    echo "Usage: $0 MAX_SPEED_PERCENTAGE"
    echo "  MAX_SPEED_PERCENTAGE 0-100 or >100 for turbo boost"
    exit 1
fi
if [ $1 -le 100 ]; then
    echo $1 | sudo tee /sys/devices/system/cpu/intel_pstate/max_perf_pct
    echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
else
    echo 100 | sudo tee /sys/devices/system/cpu/intel_pstate/max_perf_pct
    echo 0 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
fi
notify-send --hint int:transient:1 "CPU speed set to $1"
