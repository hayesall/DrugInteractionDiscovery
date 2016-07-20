#!/bin/sh

INPUT=$1
cp $INPUT splittingthisfile.txt
FILETOSPLIT=splittingthisfile.txt
LISTLENGTH=4886 #might want to change this to "length of input"
NODES=72 #tweak this a bit, currently splits into 71 roughly equal parts
FINALNAME=check_

function newline {
    echo " "
}
#function to compute n(n-1)/2, not to be confused with n(n+1)/2. We need 0+1+2+3+4...+n instead of 1+2+3+4..+n
function gauss {
    N=$1
    expr $N \* $[N-1] / 2
}

function gaussdist {
    N1=$1
    N2=$2
    G1=`gauss $1`
    G2=`gauss $2`
    expr $[G2-$G1] 
}

function dividefile {
    mkdir Data/$NODE
    cp STABLE.txt Data/$NODE/STABLE.txt
    cp STABLE.txt Data/$NODE/drugs.txt
    COUNTER=0
    NEWFILE=Data/$NODE/$FINALNAME$NODE
    while [ $COUNTER -lt $COLUMNS ]; do
	head -n 1 $FILETOSPLIT >> $NEWFILE
	tail -n +2 $FILETOSPLIT > splittinginprogress.tmp && mv splittinginprogress.tmp $FILETOSPLIT
        let COUNTER+=1
    done
    #echo Creating $NEWFILE && newline
}

function splitcolumns {
    #Demonstrate the rough maximum:
    ROUGHMAX=`expr $LISTLENGTH \* $[LISTLENGTH-1] / 2 / $NODES`
    echo Trying with $NODES max possible nodes
    echo List contains $LISTLENGTH drugs to split between $NODES nodes, about $ROUGHMAX drugs per node.
    TOTAL=0
    MAX=0
    NODE=1
    START=$1
    NEXT=$2
    while [ $NEXT -le $LISTLENGTH ]; do
	DIST=`gaussdist $START $NEXT`
	if [ $DIST -gt $ROUGHMAX ]; then
	    DIST1=$[DIST-$ROUGHMAX]
	    DIST2=`gaussdist $START $[NEXT-1]`
	    DIST3=$[DIST2-$ROUGHMAX]
	    #echo DIST1 is $DIST1, DIST3 is $DIST3 " | " add to get is $[DIST1+$DIST3]
	    if [ $[DIST1+$DIST3] -gt 0 ]; then
		DIST=$DIST2
		NEXT=$[NEXT-1]
		COLUMNS=$[NEXT-$START+1]
		TOTAL=$[TOTAL+$COLUMNS]
		echo "$NODE) $START to $NEXT:" $DIST " | " $COLUMNS columns " | " $TOTAL so far
		dividefile
		START=$[NEXT+1]
		NODE=$[NODE+1]
		if [ $DIST -gt $MAX ]; then
		    MAX=$DIST
		fi
		#echo PATH1 CHOSEN && newline
	    else
		COLUMNS=$[NEXT-$START+1]
		TOTAL=$[TOTAL+$COLUMNS]
		echo "$NODE) $START to $NEXT:" $DIST " | " $COLUMNS columns " | " $TOTAL so far
		dividefile
		START=$[NEXT+1]
		NODE=$[NODE+1]
		if [ $DIST -gt $MAX ]; then
		    MAX=$DIST
		fi
		#echo PATH2 CHOSEN && newline
	    fi
	else
	    NEXT=$[NEXT+1]
	fi
    done
    COLUMNS=$[LISTLENGTH-$START+1]
    TOTAL=$[TOTAL+$COLUMNS]
    echo "$NODE) $START to $LISTLENGTH:" `gaussdist $START $LISTLENGTH` " | " $[LISTLENGTH-$START+1] columns " | " $TOTAL so far
    newline && newline
    echo Time estimate: $[MAX / 2 / 60 / 60] hours at 2 searches per second using $NODE nodes effectively out of $NODES possible && newline
}


if [[ -z $1 ]]; then
    echo no file specified && newline && newline
    exit
fi

#while [ $NODES -le 70 ]; do
#    splitcolumns 1 1
#    NODES=$[NODES+1]
#done

splitcolumns 1 1
mkdir Data/$NODE
cp STABLE.txt Data/$NODE/STABLE.txt
cp STABLE.txt Data/$NODE/drugs.txt
mv $FILETOSPLIT Data/$NODE/$FINALNAME$NODE
