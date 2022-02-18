#!/bin/bash


echo "Construction d'un tableau LATEX et fichier CSV à partir des .rpt"
if [ "$#" != 1 ]; then 
    echo "usage:"
    echo "script-report-Utilization.bash NAME"
    echo "NAME is the name of the DSP file NAME.dsp " 
    echo "(e.g. script-report-Utilization.bash bell)"
    exit
else
    ACTION=$1
    echo "filtering on $1";

    echo "\begin{tabular}{|c||c|c|c|c|}" >report-$1.tex
    echo "" >report-$1.csv
    echo "Utilization (\%)      & BRAM 18K& DSP&   FF  &  LUT  " >>report-$1.tex
    echo "\\\\ \hline \hline " >>report-$1.tex
    echo "Version,N,BRAM,DSP,FF,LUT" >>report-$1.csv
    for i in *$1*.rpt;  do
	NUM=$( echo "$i" | cut -d'-' -f4 | cut -d"." -f1)
	VERSION=$( echo "$i" | cut -d'-' -f1)
	#sed: don't ask me...la version latex est buggée 
	less $i | grep "|Utilization (%)" | sed -e 's=|Utilization (%) =\\\\ \\hline \n'$VERSION,$NUM'=g' |   sed -e 's/|    0|/ /g' | sed -e 's/|/ \&/g' >>report-$1.tex
	echo "N=$NUM"
	less $i | grep "|Utilization (%)" | sed -e 's=|Utilization (%) ='$VERSION,$NUM'=g' |   sed -e 's/|    0|/ /g' | sed -e 's/|/, /g' >>report-$1.csv
    done
    echo "\end{tabular}" >>report-$1.tex
    echo "report-$1.tex generated" 
    echo "report-$1.csv generated" 
fi





