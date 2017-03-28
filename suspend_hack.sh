# Disable all wakeups but LID
for DEVICE in `cat /proc/acpi/wakeup | grep enabled | c -f1 | grep -v LID`; do
    echo $DEVICE; echo $DEVICE > /proc/acpi/wakeup
done
