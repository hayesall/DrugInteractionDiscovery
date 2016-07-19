#!/bin/bash

API=$1

STARTTIME=$(date '+%s')
TOTAL=0
LETTERS=abcdefghijklmnopqrstuvwxyz
CURRENT=0
FILENAME=drugslist.txt

function newline {
    echo " "
}

if [[ -z $API ]]; then
    SPECIALCHARACTERS=+AND+
    API=openFDA
elif [ $API = PubMed ]; then
    SPECIALCHARACTERS=+
elif [ $API = Web ]; then
    SPECIALCHARACTERS=_
elif [ $API = Unsafe ]; then #not implemented yet
    SPECIALCHARACTERS=+AND+
    API="openFDA (with unsafe characters)"
elif [ $API = openFDA ]; then
    SPECIALCHARACTERS=+AND+
else
    echo Invalid input. Please specify PubMed, Web, or openFDA.
    exit
fi

rm -f $FILENAME
echo Results will be output to file: $FILENAME && newline
touch $FILENAME
PREVIOUS=0

until [ $CURRENT = 26 ]; do
    CHECK=${LETTERS:$CURRENT:1}
    URL=http://www.rxlist.com/drugs/alpha_$CHECK.htm
    PREVIOUS=$TOTAL
    PAGE="`wget --no-check-certificate -q -O - $URL`"
    TOTAL=$[TOTAL+$(echo "$PAGE" | grep FDA | wc --lines | cut -d ' ' -f 1)]
    printf "%-11s | %-10s | %-10s" "Checking $CHECK" "Found $[TOTAL-$PREVIOUS]" "$TOTAL so far"
    newline
    echo "$PAGE" | grep FDA | grep -o -P '(?<=">).*(?=\ \()' | grep -E -v '\(|\%|\.|\,|\+|\-|\;|\)|\[|\]|\#|\&' | sed "s/ \+/$SPECIALCHARACTERS/g" | grep -v '+$' >> $FILENAME
    let CURRENT=$[CURRENT+1]
done
FINALWORDS=$(wc --lines $FILENAME | cut -d ' ' -f 1)

newline && echo Finished
echo Compiled $TOTAL drugs / $[$(date '+%s')-STARTTIME] seconds && newline
echo Formatted to work with the $API api.
echo In total there were $TOTAL
echo $[TOTAL-$FINALWORDS] were removed due to unsafe characters.
sort $FILENAME | uniq > $FILENAME-2
mv $FILENAME-2 $FILENAME
echo $[FINALWORDS-$(wc --lines $FILENAME | cut -d ' ' -f 1)] duplicates were removed.
echo There are $(wc --lines $FILENAME | cut -d ' ' -f 1) drugs listed in $FILENAME && newline && newline
