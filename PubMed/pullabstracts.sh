#!/bin/bash

export PERL5LIB=$PERL5LIB:/u/hayesall/REU/PMDataDump/Generated/perlscripts

# To run this function, you need a list of drugs named STABLE.txt
# Currently this is in testing mode, to turn it off, comment the function
# call out.

function shrink1 {
    tail -n +2 "$FILE1" > drugs1.tmp && mv drugs1.tmp "$FILE1"
    cp $STABLE $FILE2
}

function shrink2 {
    tail -n +2 "$FILE2" > drugs2.tmp && mv drugs2.tmp "$FILE2"
}

function newline {
    echo " "
}

function testing {
    rm -f LOG.txt
    cp STABLE.txt drugs1.txt
    cp STABLE.txt drugs2.txt
    rm -f Abstracts/*    
}

testing #this is the testing function call, comment it out to prevent resets

FILE1=drugs1.txt
FILE2=drugs2.txt
STABLE=STABLE.txt
BEGIN=`wc --lines drugs1.txt | cut -d ' ' -f 1`

while [ $(wc --bytes $FILE1 | cut -d ' ' -f 1) -gt 0 ]; do
    DRUG1=`head -n 1 "$FILE1"`
    DRUG2=`head -n 1 "$FILE2"`
    until [ $DRUG1 = $DRUG2 ]; do
	DRUG1=`head -n 1 "$FILE1"`
	DRUG2=`head -n 1 "$FILE2"`
	TEST=`perl pmsearch -c -t 800 -d 50 $DRUG1 $DRUG2`
	echo Found $TEST for $DRUG1 and $DRUG2 " | " Progress: $[$BEGIN-`wc --lines drugs1.txt | cut -d ' ' -f 1`] / $BEGIN
	if [ $TEST -gt 0 ]; then
	    if [ $DRUG1 = $DRUG2 ]; then
		shrink2
	    else
		FILENAME=$DRUG1-$DRUG2.txt
		echo Creating $FILENAME && echo Creating $FILENAME, found $TEST results. >> LOG.txt
		perl pmsearch -t 3650 -d 20 $DRUG1 $DRUG2 | perl pmid2text -a -i > Abstracts/$FILENAME
		shrink2
	    fi
	else
	    shrink2
	fi
    done
    shrink1
done
exit
