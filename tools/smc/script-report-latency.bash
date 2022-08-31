#!/bin/bash


echo "Construction d'un tableau latex à partir des .rpt"
if [ "$#" != 1 ]; then 
    echo "Donner en parametre le nom du DSP pour filtrer les resultat "
    exit
else
    ACTION=$1
    echo "filtering on $1";

    echo "\begin{tabular}{|c||c|} \hline" >report-latency-$1.tex
    echo "   Name   &Max latency  (cycles)   " >>report-latency-$1.tex
    echo "\\\\  \hline \hline  & " >>report-latency-$1.tex
    for i in *$1*.rpt;  do
	echo "\\\\ \hline $i &" >>report-latency-$1.tex
	#following command: don't ask me... It just work: extract max latency
	less $i |grep "     none" | grep -v "grp" | cut -d'|' -f3  >>report-latency-$1.tex 
    done
    echo "\\\\ \hline\end{tabular}" >>report-latency-$1.tex
    echo "report-latency-$1.tex generated" 
fi





