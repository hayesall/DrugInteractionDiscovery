#!/bin/bash
INPUT=$1

function titlescreen {
    clear
    echo " "
    echo " "
    echo "                                    RXDownloader written by Alexander L. Hayes"
    echo "                               Indiana University | STARAI | Dr. Sriraam Natarajan"
    echo "                                    Drug Names will be pulled from rxlist.com"
    echo "                                       Labeling information from openFDA"
    echo " "
    echo " "
    echo " "
    echo " "
    echo " "
    echo " "
    echo " "
    echo " "
    sleep 3
}

function fresh { # not to be confused with the 'fresh' from miniKanren
    rm -f drugInteractionsFolder/* #remove contents if any exist
    rmdir drugInteractionsFolder   #remove the folder completely
    mkdir drugInteractionsFolder   #make sure the folder exists
    rm -f drugslist.txt            #remove before creating a new one
    bash builddruglist.sh          #create drugslist.txt
}

function pulldata {
    while [ $(wc --bytes drugslist.txt | cut -d ' ' -f 1) -gt 0 ]; do #while bytes in drugslist.txt is greater than 0
	FIRSTLINE=$(head -n 1 drugslist.txt)
	bash fdainteractions.sh $FIRSTLINE #query the first line in openFDA
	tail -n +2 drugslist.txt > drugslisttmp.txt && mv drugslisttmp.txt drugslist.txt #remove first line
    done
}

echo " "
echo " "
echo " "
echo Welcome! You have selected rxdownloader,
echo running this will likely take some time,
echo would you like to continue? [Y/N]
read SELECTION

if [ $SELECTION = Y ]; then
    if [[ "$INPUT" = fresh ]]; then
	titlescreen
	fresh
	pulldata
    else
	titlescreen
	pulldata
    fi
else
    exit
fi
