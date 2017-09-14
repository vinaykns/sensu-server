#!/bin/bash

set -e

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

#target=

count=$(ping -c 1 10.13.37.83 | grep icmp* | wc -l)

if [ $count -eq 0 ]
then
    echo "Sensu Server is Not Alive"
    exit $STATE_CRITICAL
else
    echo "Sensu Server is Alive"
    exit $STATE_OK
fi

