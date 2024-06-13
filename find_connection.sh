#!/bin/bash

WAIT="5s"
#CHECK="ESTABLISHED"
CHECK="CLOSE"

declare -gA IP
declare -gA LIVE


NETSTAT()
{
	netstat -antop | awk -v X=$CHECK '$0 ~ X {print $5}'	
	return;
}

GRAB_LIVE()
{
	unset LIVE
	declare -gA LIVE
	
	while read -a SOC 
	do
		x=${SOC[0]}			
		LIVE[${x}]=0
		[ -z ${IP[$x]} ] && let IP[$x]=0 
	done < <(NETSTAT)
}


CHECK_LIVE()
{
	for K in "${!IP[@]}"
	do 
		[ -z ${LIVE[$K]} ] && unset IP["${K}"] && continue;
		(( ++IP["${K}"] ))
	done 
}

SHOW_LIVE()
{
	for K in "${!IP[@]}"
	do 
		let J=${IP[$K]};
		printf "%3d %21s\n" ${J} "$K" 
	done | sort -nr
}

MAIN ()
{
	while (( 1 ))
	do	
		echo "--- ## ---"
		GRAB_LIVE
		CHECK_LIVE
		SHOW_LIVE
		printf "## %d %s ##\n" ${#IP[@]} "$CHECK" 
		sleep ${WAIT}
	done
}

MAIN




