#!/bin/sh

usage()
{
echo ""
echo "Usage: $0 filename"
echo "grady@stalpgo.com"
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
	PLATECOUNT=$(expr ${PLATECOUNT} + 1)
done



