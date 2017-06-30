#!/bin/sh
#
#http://github.com/stlalpha/alpr-securityspy
#
#Quick and dirty openalpr (github.com/openalpr) demo integration for standalone use or with securityspy (http://bensoftware.com/securityspy/)
# 
#This script expects to be fired inside the directory that cameraspy is using to dump your movie and still capture jpegs into.
#Just fire this as an action after motion is detected wherever you want to monitor car presence.  I use this to fire inside my garage 
#to announce arrival and set state for the presence or absence of a vehicle.
#
#It creates two logfiles - plate_log.txt which is a log of the sighting and date/time-stamp as well as plate_state.txt which is the 
#current inventory of the viewing area of the camera based on its last motion capture.

usage()
{
echo ""
echo "Usage: $0 filename"
echo "github.com/stlalpha"
echo ""
exit 1
}


whereitis()
{
	grep  -c "$1" plate_state.txt 
}

check_alpr()
{
	ALPR_BIN=$(which alpr)

	if [ -z "${ALPR_BIN}" ] ; then
		echo "

		Please install alpr binaries using brew:
		
		$ brew tap homebrew/science
		
		$ brew install openalpr
		
		And then re-run the command
		"
		
		exit 1
	fi
}

acquire_plates()
{
	PLATES=$(for i in *.jpg ; do alpr --topn 1 "${i}" 2>/dev/null | grep -v plage | awk '{print $2}'; done | sort -u)
	
	if [ -z "${PLATES}" ] ; then
		exit 1
	fi
}


search_array() {
	local x
	for x in "${@:2}"; do [[ "$x" == "$1" ]] && return 0; done
	return 1
}


TIME_STAMP=$(date +%m-%d-%Y-%H:%M)

#main

check_alpr

#if [ $# -lt 1 ]; then
#		usage
#		exit 1
#	fi

PLATECOUNT=0

acquire_plates


for i in "${PLATES[@]}"; do 
	echo "${TIME_STAMP} ${i}" >> plate_log.txt 
	echo "${i}" >> plate_state.txt 
	cat plate_state.txt | uniq > plate_state_$$.txt 
	mv plate_state_$$.txt plate_state.txt && ((PLATECOUNT++)) ; 
done 
	


#STATE logic - license plate mapping to human

#DRIVER1 = LICENSEPLATENUMBER
DRIVER1=$(whereitis XXXYYY)
DRIVER2=$(whereitis YYYZZZ)

#DUMP PRESENCE STATE OF DRIVER PLATES - 1=PRESENT 0=ABSENT
echo DRIVER1 = "${DRIVER1}"
echo DRIVER2 = "${DRIVER2}"


#DRIVER1_ACTIONS

if [ "${DRIVER1}" = 1 ]; then
	echo "DRIVER1 IS IN THE HOUSE"
fi
 
