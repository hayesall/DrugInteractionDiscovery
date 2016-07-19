#!/bin/bash
QUE=$1
KEY=mIN5BAt8Q4kciIz367SmtW9t6aWsj0oF6bafJBOd
URL3=https://api.fda.gov/drug/label.json?api_key=$KEY\&search=generic_name:$QUE\&limit=1
URL4=https://api.fda.gov/drug/label.json?api_key=$KEY\&search=brand_name:$QUE\&limit=1
STATE=3
#STATE variable determines the state of the script: 3 for generic_name (default), 2 for brand_name, 1 if it doesn't exist

if [[ -z "$QUE" ]]; then
    echo " "
    echo " "
    echo Searching openFDA without a drug name is dangerous, please specify\:
    echo \ \ \ \ \$ druginteractioncount generic-name
    echo " "
    echo " "
    exit 0
else
    DRUG="`wget --no-check-certificate -q -O - $URL3`"
fi

#We want to get an idea of how many pages there are that satisfy our query.
#First we need to get this number (which will be our endpoint).
TOTAL=0
TOTAL="`echo "$DRUG" | grep '"total": ' | cut -d ' ' -f 8`"

#Check to see if we need to flip the state (if TOTAL still equals 0)
if [[ -z "$TOTAL" ]]; then
STATE=2
DRUG="`wget --no-check-certificate -q -O - $URL4`"
TOTAL="`echo "$DRUG" | grep '"total": ' | cut -d ' ' -f 8`"
fi

#If TOTAL still doesn't exist, the drug does not exist
if [[ -z "$TOTAL" ]]; then
STATE=1
fi

if [[ $TOTAL -gt 1000 ]]; then
touch drugInteractionsFolder/WARNINGS.txt
echo " "
echo "WARNING! $QUE has $TOTAL pages, capping at 1000."
echo " "
echo "WARNING! $QUE has $TOTAL pages, capping at 1000." >> drugInteractionsFolder/WARNINGS.txt
echo " "
TOTAL=1000
fi

#There is one problem: 0-indexing, we have to subtract 1 from TOTAL
REALTOTAL=$[TOTAL-1]

FILENAME=drugInteractionsFolder/$QUE-data.txt
STARTTIME=$(date '+%s')
sleep 1

SKIP=0
function pullgeneric {
    until [ $SKIP -gt $REALTOTAL ]; do
          ELAPSED=$[$(date '+%s')-STARTTIME]
          SPEED=$((SKIP / ELAPSED))
          echo Progress: $SKIP / $TOTAL " | " Elapsed seconds: $ELAPSED " | " Checking: $QUE [generic] " | " Editing: $FILENAME
          URL5="`echo $URL3`"\&skip=$SKIP
          DRUG="`wget --no-check-certificate -q -O - $URL5`"
if [ $SPEED -ge 4 ]; then #make sure we stay under 240 articles per minute
sleep 1
fi
echo $URL5 >> $FILENAME
echo Page $SKIP of $TOTAL >> $FILENAME
echo "$DRUG" | grep -A 1 '"generic_name"' >> $FILENAME
echo "$DRUG" | grep -A 1 '"brand_name"' >> $FILENAME
echo " " >> $FILENAME
echo "$DRUG" | grep -A 1 '"drug_interactions":' >> $FILENAME
echo "$DRUG" | grep -A 1 '"adverse_reactions":' >> $FILENAME
echo "$DRUG" | grep -A 1 '"warnings_and_cautions":' >> $FILENAME
echo " " >> $FILENAME
echo " " >> $FILENAME
echo "--------------------------------------------------------------------------------------------------------------------" >> $FILENAME
let SKIP+=1
done
}


function pullbrandname {
touch drugInteractionsFolder/BRANDNAMEDRUGS.txt
echo "$QUE" >> drugInteractionsFolder/BRANDNAMEDRUGS.txt
}

if [ $STATE = 3 ]; then
touch $FILENAME
echo Results will be output to file: $FILENAME
echo " "
echo $TOTAL articles in query
echo " "
pullgeneric
elif [ $STATE = 2 ]; then
echo " "
echo $QUE is a brand name, storing in BRANDNAMEDRUGS.txt
echo " "
pullbrandname
else
echo " "
echo $QUE is unknown, storing in UNKNOWNDRUGS.txt
echo " "
touch drugInteractionsFolder/UNKNOWNDRUGS.txt
echo "$QUE" >> drugInteractionsFolder/UNKNOWNDRUGS.txt
fi

touch drugInteractionsFolder/LOG.txt
echo "FINISHED PULLING $TOTAL articles for $QUE at" $('date') >> drugInteractionsFolder/LOG.txt
