#!/bin/bash
LOCATIONS=/run/media/medic/[0-9]*
for LOCATION in $LOCATIONS; do
    [ -d $LOCATION ] && rsync_course_flashdisc.sh $LOCATION &
done
wait
echo Finished with $?
echo $LOCATIONS
