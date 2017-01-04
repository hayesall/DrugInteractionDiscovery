#!/bin/bash

QUERY=$1
API_KEY=mIN5BAt8Q4kciIz367SmtW9t6aWsj0oF6bafJBOd

# This is the rewritten version of fdainteractions.sh, written during the ProHealth 2016 REU
# Usage:
#   $ bash fdainteractions.sh (replaced+AND+spaces+AND+drug)

GENERIC_URL=https://api.fda.gov/drug/label.json?api_key=$API_KEY\&search=generic_name:$QUERY\&limit=1
BRAND_URL=https://api.fda.gov/drug/label.json?api_key=$API_KEY\&search=brand_name:$QUERY\&limit=1

if [[ -z "$QUERY" ]]; then
    echo "Please specify a drug name."
else
    # Json output from the webpage is stored in a variable.
    DRUG=$(wget --no-check-certificate -q -O - $GENERIC_URL)
fi

if [[ ! -d drugInteractionsFolder ]]; then
    mkdir drugInteractionsFolder
fi

# Generic
STATE=3
# Brand Name
# STATE=2
# Does-not-exist
# STATE=1

# We need to know how many pages there are that satisfy our query.
# This number will be our endpoint.
TOTAL=0
TOTAL=$(echo "$DRUG" | grep "\"total\": " | cut -d ' ' -f 8)

# If total is still zero, we need to flip the state and check brand name drugs
# Notice we shadow the "DRUG" variable from earlier.

if [[ -z "$TOTAL" ]]; then
    STATE=2
    DRUG=$(wget --no-check-certificate -q -O - $BRAND_URL)
    TOTAL=$(echo "$DRUG" | grep "\"total\": " | cut -d ' ' -f 8)
fi

# If TOTAL still doesn't exist, the drug does not exist
if [[ -z "$TOTAL" ]]; then
    STATE=1
fi

# If TOTAL is greater than 1000, limit to 1000.
if [[ $TOTAL -gt 1000 ]]; then
    printf "\nWARNING! $QUERY has $TOTAL pages, capping at 1000.\n"
    echo "WARNING! $QUERY has $TOTAL pages, capping at 1000." >> drugInteractionsFolder/WARNINGS.txt
    TOTAL=1000
fi

# One last thing before we dive into the rest of the scraping: 0-indexing. Subtract 1 from TOTAL
REALTOTAL=$[TOTAL-1]

# Finally, let's scrape data

FILENAME=drugInteractionsFolder/$QUERY.txt
STARTTIME=$(date '+%s')
sleep 1

SKIP=0
function pullGeneric {
    until [ $SKIP -gt $REALTOTAL ]; do
	ELAPSED=$[$(date '+%s')-STARTTIME]
	SPEED=$((SKIP / ELAPSED))
	printf "\r$[$SKIP+1] / $TOTAL | $QUERY [generic] | Time: $ELAPSED"
	NEXT_URL="$GENERIC_URL&skip=$SKIP"
	DRUG=$(wget --no-check-certificate -q -O - $NEXT_URL)
	# Make sure we stay under 240 articles per minute
	if [ $SPEED -ge 4 ]; then
	    sleep 1
	fi
	echo $NEXT_URL >> $FILENAME
	echo Page $[SKIP+1] of $TOTAL >> $FILENAME
	echo "$DRUG" | grep -A 1 "\"generic_name\"" >> $FILENAME
	echo "$DRUG" | grep -A 1 "\"brand_name\"" >> $FILENAME
	echo "" >> $FILENAME
	echo "$DRUG" | grep -A 1 "\"drug_interactions\":" >> $FILENAME
	echo "$DRUG" | grep -A 1 "\"adverse_reactions\":" >> $FILENAME
	echo "$DRUG" | grep -A 1 "\"warnings_and_cautions\":" >> $FILENAME
	echo "" >> $FILENAME
	echo "------" >> $FILENAME
	let SKIP+=1
    done
}

function pullBrandName {
    # expand on this function in case there isn't a generic form
    echo "$QUERY" >> drugInteractionsFolder/BRANDNAMEDRUGS.txt
}

if [ $STATE = 3 ]; then
    echo Results will be output to file: $FILENAME
    echo $TOTAL articles in query
    echo " "
    pullGeneric
elif [ $STATE = 2 ]; then
    echo " "
    echo $QUERY is a brand name, storing in BRANDNAMEDRUGS.txt
    echo " "
    pullBrandName
else
    echo " "
    echo $QUERY is unknown, storing in UNKNOWNDRUGS.txt
    echo " "
    echo "$QUERY" >> drugInteractionsFolder/UNKNOWNDRUGS.txt
fi

echo "FINISHED PULLING $TOTAL articles for $QUERY at" $('date') >> drugInteractionsFolder/LOG.txt
echo " "
