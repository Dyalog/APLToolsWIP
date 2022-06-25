#!/bin/bash

APLFIFO=/tmp/aplfifo

if [[ ! -p $APLFIFO ]]; then
 mkfifo /tmp/aplfifo
fi

tail -f /dev/null > /tmp/aplfifo &

cd /confreg

export MiServer=/confreg
ODBCINI=/odbc.ini /usr/bin/dyalog -ride -s /MiServer/miserver.dws 0</tmp/aplfifo
