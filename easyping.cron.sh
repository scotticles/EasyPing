#!/bin/bash
#Adjust path to match your system
#whereis carton
CARTON_EXEC=/usr/bin/carton
EASYPING_EXEC=/path/to/EasyPing/easyping.pl
if [ $# -eq 0 ]; then
$CARTON_EXEC exec $EASYPING_EXEC -c
else
$CARTON_EXEC exec $EASYPING_EXEC -c -g $1
fi
