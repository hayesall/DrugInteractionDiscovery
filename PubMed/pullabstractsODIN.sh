#!/bin/sh

# Optimized for running on Indiana University's RI Odin Cluster
# Written by Alexander Hayes | ProHealth && STARAI | Dr. Sriraam Natarajan

export PERL5LIB=$PERL5LIB:perlscripts


# ---------------------- STAGE 1 ---------------------------- #
# ------------------- Synchronization ----------------------- #

# Elsewhere, we've generated a list of 71 nodes (71 because   #
# that is the largest number of nodes that can be alloted at  #
# once on Odin) in Data/[1..71], also creating a STABLE drugs #
# list and a drugs.txt that can be compared with.  We allo-   #
# cate nodes by running `srun -N 71 pullabstractsODIN.sh`     #
# but need to find out  which nodes  we're running on to en-  #
# sure that all lists are being iterated on simultaneously.   #

FINAL=ODINORDER.txt
LOG=DETERMINEORDER.txt

rm -f $FINAL
rm -f $LOG

function synchronize { 

    HOSTNUMBER=`hostname | grep -o -P '(?<=odin).*(?=.cs.indiana.edu)' | sed 's/^0*//'`
    echo $HOSTNUMBER
    sleep $HOSTNUMBER
    HOST=`hostname`

    echo "$HOST" >> $LOG
    OUTPUT=`wc --lines $LOG | cut -d 'L' -f 1 | cut -d 'D' -f 1`
    echo "$HOST$OUTPUT" >> $FINAL
}

sleep 5
synchronize
NUMBERSTRING=`grep $HOST $FINAL | cut -d 'u' -f 2`
NUMBER=$(($NUMBERSTRING * 1))
echo $HOST is at $NUMBER

# ---------------------- STAGE 2 ---------------------------- #
# --------------- Pulling the Abstracts --------------------- #

# The NUMBER we just created is now very important, it tells  #
# us the location of the file: Data/$NUMBER/check_$NUMBER     #

FILE1=Data/$NUMBER/check_$NUMBER  #formerly drugs1.txt
FILE2=Data/$NUMBER/drugs.txt      #formerly drugs2.txt
STABLE=Data/$NUMBER/STABLE.txt    #formerly STABLE.txt
BEGIN=`wc --lines $FILE1 | cut -d ' ' -f 1`

TEMP1=Data/$NUMBER/check_$NUMBER.tmp #formerly drugs1.tmp
TEMP2=Data/$NUMBER/drugs.tmp         #formerly drugs2.tmp


function shrink1 {
    tail -n +2 "$FILE1" > "$TEMP1" && mv "$TEMP1" "$FILE1"
    cp $STABLE $FILE2
}

function shrink2 {
    tail -n +2 "$FILE2" > "$TEMP2" && mv "$TEMP2" "$FILE2"
}

#commands for testing
#rm -f LOG.txt
#cp STABLE.txt drugs1.txt
#cp STABLE.txt drugs2.txt
#rm -f Abstracts/*
#

while [ $(wc --bytes $FILE1 | cut -d ' ' -f 1) -gt 0 ]; do
    DRUG1=`head -n 1 "$FILE1"`
    DRUG2=`head -n 1 "$FILE2"`
    until [ $DRUG1 = $DRUG2 ]; do
	DRUG1=`head -n 1 "$FILE1"`
	DRUG2=`head -n 1 "$FILE2"`
	TEST=`perl pmsearch -c -t 3650 -d 20 $DRUG1 $DRUG2`
	echo Found $TEST for $DRUG1 and $DRUG2 " | " Progress: $[$BEGIN-`wc --lines $FILE1 | cut -d ' ' -f 1`] / $BEGIN
	if [ $TEST -gt 0 ]; then
	    if [ $DRUG1 = $DRUG2 ]; then
		shrink2
	    else
		FILENAME=$DRUG1-$DRUG2.txt
		INITIAL="$(echo $FILENAME | head -c 1)" #store our file in the folder of the first letter
		echo Creating $FILENAME
		echo "Odin Node $NUMBER, Creating $FILENAME, found $TEST results, `date`" >> Abstracts/LOG.txt
		perl pmsearch -t 3650 -d 20 $DRUG1 $DRUG2 | perl pmid2text -a -i > Abstracts/$INITIAL/$FILENAME;
		shrink2
	    fi
	else
	    shrink2
	fi
    done
    shrink1
done
exit
