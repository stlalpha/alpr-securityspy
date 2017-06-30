#!/bin/sh
#Quick and dirty openalpr (github.com/openalpr demo integration with cameraspy )
#github.com/stlalpha
#

usage()
{
echo ""
echo "Usage: $0 filename"
echo "github.com/stlalpha"
echo ""
exit 1
}

check_alpr()
{
	ALPR_BIN=$(which alpr)
	result=$?
	if [ -z ${ALPR_BIN} ] ; then
		echo "Please install alpr binaries using brew"
		exit 1
	fi
}

acquire_plates()
{
	PLATES=$(alpr --topn 1 ${IMAGEFILE} 2>/dev/null | grep -v plate | awk '{print $2}')

	if [ -z ${PLATES} ] ; then
		exit 1
	fi
}


search_array() {
	local x
	for x in "${@:2}"; do [[ "$x" == "$1" ]] && return 0; done
	return 1
}

IMAGEFILE=$1
TIME_STAMP=$(date +%m-%d-%Y-%H:%M)

#main


check_alpr

if [ $# -lt 1 ]; then
		usage
		exit 1
	fi

PLATECOUNT=0

acquire_plates ${IMAGEFILE}


for i in ${PLATES[@]}; do echo "${TIME_STAMP} ${i}" >> plate_log.txt && echo "${i}" >> plate_state.txt && cat plate_state.txt | uniq > plate_state_$$.txt && mv plate_state_$$.txt plate_state.txt && ((PLATECOUNT++)) ; done 
	




#search_array "7AB66Y" "${PLATES[@]}"
#echo $?
