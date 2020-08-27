#!/bin/bash
#Adjust path to match your system using 'whereis carton'
CARTON_EXEC=/usr/bin/carton
EASYPING_PATH=/path/to/EasyPing
cd $EASYPING_PATH
$CARTON_EXEC exec "$EASYPING_PATH/easyping.pl $1 $2"