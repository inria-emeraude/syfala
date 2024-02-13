#!/bin/bash


# printSyfalaGraph file windowStart windowFactor {markerStyle} {height} {width}
# exemple: printSyfalaGraph.sh "/home/maxime/syfala-project/outputSig.txt" 500 2


input=$1
windowStart=$2
windowFactor=$3
markerStyle=${4:-'A'}
height=${5:-$((($(tput lines))-3))}
width=${6:-$((($(tput cols))-3))}

regexIsNumber='^[0-9]+$'

range=1900000



i=1
header=$(sed "${i}q;d" $input)
#check empty line before header
while [ -z "$header" ];
do
  ((i=$i+1))
    header=$(sed "${i}q;d" $input)
done

arrHeader=(${header//;/ })
((numberGraph=(${#arrHeader[@]})-1))


#You have to uncomment that if you don't run this script from ./print_reports.sh ...
#for i in $( eval echo {1..$height} )
#do
#    printf "\n"; \
#done

# ... and comment this!
printf "\033[%dB" $(($height-1))


for i in $( eval echo {$windowStart..$(($windowStart+($width*$windowFactor)))} )
do
  line=$(sed "${i}q;d" $input)
  #echo $line
  arrIN=(${line//;/ })

  for j in $( eval echo {1..$numberGraph} )
  do
    normalizedValue=$(((${arrIN[j]}+$range)*$height/(2*$range)))
    printf "\033[%dA" $normalizedValue
    printf "\033[1;%dm$markerStyle" $((30+j))
    printf "\033[%dB" $normalizedValue
    printf "\033[1D"
  done
  if [[ $(($i%$windowFactor)) == 0 ]]
  then
    printf "\033[1C"
  fi

done

#Write legend at the end to simplify cursor position
printf "\033[%dA" $(($height-1))
printf "\033[%dD" $(($width/2))
tput setaf 7
for j in $( eval echo {1..$numberGraph} )
do
    printf " "
    tput setab $j
    printf " \033[1m%s " ${arrHeader[j]}
    tput setab 0
done
