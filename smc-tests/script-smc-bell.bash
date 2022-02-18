#!/bin/bash

#indicate manually all the values of N that will be explored (e.g. VALUES=(20))
#VALUES=(1 2 3 4 5 6 8 10 15 20 25 30)
VALUES=(4 5 6 8 10)

# usage: ./script-smc-bell-6.1.bash build
#
# "build" should copy ${VERSION}-bell-root for each value (e.g. ${VERSION}-bell-root-20)
# and create the faust input corresponding N=value in directory "faust"
# (e.g. faust/bell-${VERSION}-20.dsp)
# the original faust program should be called faust/bellN.dsp and contain a "N"
#
# "clean" removes all the new directories built

# createFaust(val): creates the faust program with parameter N=val
function createFaust() {
    if [[ -e "faust/bellN.dsp" ]]; then
	NAME="faust/bellN.dsp"
	NEWNAME="faust/bell-${VERSION}-$1.dsp"
	cp "$NAME" "$NEWNAME"
	sed -i -e "s/N/"$1"/g" "$NEWNAME"  #replace N by a value
	echo "$NEWNAME"
    else
	echo "file not found"
    fi
}

#function createSyfala(val): creates the syfala directory for parameter  N=val 
function createSyfala() {
   if [[ -d "${VERSION}-bell-root" ]]; then
	NAME="${VERSION}-bell-root"
	NEWNAME="${VERSION}-bell-root-$1"
	cp -r "$NAME" "$NEWNAME"
	sed -i -e "s/NNNN/"-${VERSION}-$1"/g" "$NEWNAME/Makefile" 
	echo "$NEWNAME"
    else
	echo "directory not found"
    fi

}

# runSyfala(val): run the IP generation for parameter N=val and copy+rename
# resulting report.rpt 
function runSyfala() {
   if [[ -d "${VERSION}-bell-root-$1" ]]; then
       NAME="${VERSION}-bell-root-$1"
       echo "running HLS in directory $NAME"
       echo ""
       cd $NAME
       make ip >hls_log.log  2>&1 
       cd ..
       cp $NAME/build/faust_v6_ip/faust_v6/syn/report/faust_v6_csynth.rpt reports/$NAME.rpt
       echo $NAME
   else
       echo "directory ${VERSION}-bell-root-$1 not found"
   fi

}


if [ "$#" != 2 ]; then 
    echo "usage:"
    echo "script-smc.bash ACTION VERSION"
    echo "with ACTION=build or clean"
    echo "with VERSION=6.1 or v6.3"
    
    exit
else
    NBVALUES=${#VALUES[*]}
    echo "values of N:" ${VALUES[*]}
    ACTION=$1
    VERSION=$2
    if [ "$ACTION" == "build" ]; then
	echo "build";
	for ((i = 0 ; i < $NBVALUES ; i++)); do
	    NUM=${VALUES[i]}
	    echo "**********NUM=$NUM*********"
	    RES=$(createFaust "$NUM")
	    echo $RES generated
	    RES=$(createSyfala "$NUM")
	    echo $RES generated
	    RES=$(runSyfala "$NUM")
	    echo $RES.rpt generated
	done
    fi;
    if [ "$ACTION" == "clean" ]; then
	echo "rm -r ${VERSION}-bell-root-*";
	rm -r ${VERSION}-bell-root-*
	echo "rm  faust/bell-${VERSION}-*.dsp";
	rm  faust/bell-${VERSION}-*.dsp
    fi;
fi


