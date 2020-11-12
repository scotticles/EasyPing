#!/bin/bash
#Adjust path to match your system
#whereis carton
CARTON_EXEC=/usr/bin/carton
EASYPING_PATH=/easyping
cd $EASYPING_PATH
if [ $# -eq 0 ]; then
$CARTON_EXEC exec $EASYPING_PATH/easyping.pl -c
else
$CARTON_EXEC exec $EASYPING_PATH/easyping.pl -c -g $1
fi
