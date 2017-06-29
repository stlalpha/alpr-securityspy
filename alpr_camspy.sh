#!/bin/sh
#Quick and dirty openalpr (github.com/openalpr demo integration with cameraspy )
usage()
{
echo ""
echo "Usage: $0 filename"
echo "github.com/stlalpha"
echo ""
exit 1
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

#main

if [ $# -lt 1 ]; then
		usage
		exit 1
	fi

PLATECOUNT=0

acquire_plates ${IMAGEFILE}


for i in ${PLATES[@]}; do
	echo "Plate #${PLATECOUNT}"
	echo "Value is: ${i}"
	((PLATECOUNT++)

done

#action logic


search_array "7AB66Y" "${PLATES[@]}"
echo $?

#test
#test2