#!/bin/bash

INPUTFILE=drugslist.txt
OUTPUTFILE=checkup.txt
START=0

function checkfile {
    while [ $(wc --bytes $INPUTFILE | cut -d ' ' -f 1) -gt 0 ]; do
	DRUGNAME=`head -n 1 $INPUTFILE`
	TEST=`grep $DRUGNAME' ' drugInteractionsFolder/LOG.txt`
	echo Progress: $START " / " $TOTAL "  |  " $DRUGNAME
	if [[ -z $TEST ]]; then
	    echo $TEST
	    echo "$DRUGNAME" >> $OUTPUTFILE
	fi
	tail -n +2 $INPUTFILE > drugslist.tmp && mv drugslist.tmp $INPUTFILE
	let START+=1
    done
}

#MAIN
bash builddruglist.sh     # Download a fresh copy of drugslist.txt
TOTAL=$(wc --lines $INPUTFILE | cut -d ' ' -f 1) # Set total (for printing)
touch $OUTPUTFILE         # Create checkup.txt to pass information into
checkfile                 # Check LOG.txt for missing drugs
mv $OUTPUTFILE $INPUTFILE # Update drugslist.txt
