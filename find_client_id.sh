#!/bin/bash

DLOG="/var/log/safesquid/native/safesquid.log"

ID=$1
LOG=$2

[ "x$2" == "x" ] && LOG="${DLOG}"

[ "x$LOG" == "x" ] && echo "LOG file not specified" && exit 1

[ ! -f $LOG ] && echo "$LOG not found" && exit 1

Z="\[$ID\]";
A='^.* ';
B=$Z; 
C='(.*(|\r\n))*(?<!\r)$';
X=$A$B$C; 

pcregrep -M -o -e "$X" $LOG

exit $?
