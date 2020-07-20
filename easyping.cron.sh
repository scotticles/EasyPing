#!/bin/bash
#Adjust path to match your system
#whereis carton
CARTON_EXEC=/usr/local/bin/carton
EASYPING_EXEC=/opt/EasyPing/
cd /opt/EasyPing
if [ $# -eq 0 ]; then
$CARTON_EXEC exec $EASYPING_EXEC -c
else
$CARTON_EXEC exec $EASYPING_EXEC -c -g $1
fi