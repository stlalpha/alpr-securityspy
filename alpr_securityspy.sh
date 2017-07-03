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


DAEMON=0
PLATECOUNT=0
INTERVAL=5



 usage()
{
    echo "OpenALPR / SecuritySpy Example Integration"
    echo "https://github.com/stlalpha/alpr-securityspy"
    echo ""
    echo "./$0"
    echo "\t-h --help"
    echo "\t--daemon"
    echo ""
}

while [ "$1" != "" ]; do
    PARAM=$(echo $1 | awk -F= '{print $1}')
    VALUE=$(echo $1 | awk -F= '{print $2}')
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --daemon)
            DAEMON=1
            ;;
        --interval)
            INTERVAL=${VALUE}
            ;;
        --platemap)

#platemap file is a simple textfile format is
#
#Name_PlateNumber e.g., Jimmy_IJD865

			PLATEMAPFILE=${VALUE}
			DRIVERS=$(cat "${PLATEMAPFILE}")
			;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done



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
	PLATES=$(for i in *.jpg ; do alpr --topn 1 "${i}" 2>/dev/null | grep -v plate | awk '{print $2}'; done | sort -u)
	
	if [ -z "${PLATES}" ] ; then
		exit 1
	fi
}


search_array() {
	local x
	for x in "${@:2}"; do [[ "$x" == "$1" ]] && return 0; done
	return 1
}

acquire_plate_state()
{
		for i in "${PLATES[@]}"; do 
		if [ "${DAEMON}" = 0 ] ; then
		echo "${TIME_STAMP} ${i}" >> plate_log.txt 
	fi
		echo "${i}" >> plate_state.txt 
		cat plate_state.txt | uniq > plate_state_sorting.txt 
		mv plate_state_sorting.txt plate_state.txt && ((PLATECOUNT++)) ; 
		done 

}


acquire_drivers()
{
		for i in $"{PLATES[@]}"; do 
		if [ "${DAEMON}" = 0 ] ; then
		echo "${TIME_STAMP} ${i}" >> plate_log.txt 
	fi
		echo "${i}" >> plate_state.txt 
		cat plate_state.txt | uniq > plate_state_sorting.txt 
		mv plate_state_sorting.txt plate_state.txt && ((PLATECOUNT++)) ; 
		done 

}



TIME_STAMP=$(date +%m-%d-%Y-%H:%M)


check_alpr



#if DAEMON=1 then just keep cycling acquiring the plates every 5 seconds
#and update the state table only (not the log)

if [ "${DAEMON}" = 1 ] ; then
	while true ; do
		acquire_plates
		acquire_plate_state
		sleep "${INTERVAL}"
	done

else

	acquire_plates
	acquire_plate_state
fi


#STATE logic - license plate mapping to human
#

for i in ${DRIVERS} ; do
	echo "$(echo ${i} | awk -F_ '{print $1}')" = $(whereitis $(echo ${i} | awk -F_ '{print $2}'))
	export $(echo "${i}" | awk -F_ '{print $1}')=$(whereitis $(echo ${i} | awk -F_ '{print $2}'))
done



