#!/bin/bash

#up=A, down=B, forward=C, backward=D
project_directory=$1
compiler_version=$2
dspFile=$3
board=$4
sample_rate=$5
sample_width=$6
spi_controller=$7
volume=$8
num_inputs=$9
num_outputs=${10}

date=$(date +'%m/%d/%Y')

if [ -f "$project_directory/build/syfala_ip/syfala_ip.cpp" ]; then
  arch_exist=1
else
  arch_exist=0
fi

if [ -f "$project_directory/build/vitis_hls.log" ]; then
  ip_exist=$(grep -q "Generated output file" "$project_directory/build/vitis_hls.log" ; echo $?) #2: donesn't exist, 1: failed; 0: Success!
else
  ip_exist=2
fi

if [ -f "$project_directory/build/vivado.log" ]; then
  project_exist=$(grep -q "Successfully created Hardware Platform" "$project_directory/build/vivado.log" ; echo $?) #2: donesn't exist, 1: failed; 0: Success!
else
  project_exist=2
fi

if [ -d "$project_directory/build/syfala_application/platform" ]; then
    if [ -f "$project_directory/build/sw_export/application.elf" ]; then
        app_exist=0 #0: Success!
    else
        app_exist=1 #1: failed
    fi
else
        app_exist=2 #2: donesn't exist
fi

#---------------------------------------------------
if [[ $ip_exist == "0" ]]
then
ip_date=$(tail -1 "$project_directory/build/vitis_hls.log" |rev| cut -b8-23 | rev)


periode=21833
clock=$(grep -m 1 -A 2 "Clock" "$project_directory//build/syfala_ip/syfala/syn/report/syfala_csynth.rpt" | tail -n 1 | cut -d "|" -f3 | cut -d "." -f1)
((maxCycle=$periode/$clock))

latency=$(grep -m 1 -A 3 "Latency (cycles)" "$project_directory//build/syfala_ip/syfala/syn/report/syfala_csynth.rpt" | tail -n 1 | cut -d "|" -f3)
latencyUs=$(grep -m 1 -A 3 "Latency (cycles)" "$project_directory//build/syfala_ip/syfala/syn/report/syfala_csynth.rpt" | tail -n 1 | cut -d "|" -f5)

TTbram=$(grep -m 1 "Total" "$project_directory//build/syfala_ip/syfala/syn/report/syfala_csynth.rpt" | cut -d "|" -f3)
TTdsp=$(grep -m 1 "Total" "$project_directory//build/syfala_ip/syfala/syn/report/syfala_csynth.rpt" | cut -d "|" -f4)
TTff=$(grep -m 1 "Total" "$project_directory//build/syfala_ip/syfala/syn/report/syfala_csynth.rpt" | cut -d "|" -f5)
TTlut=$(grep -m 1 "Total" "$project_directory//build/syfala_ip/syfala/syn/report/syfala_csynth.rpt" | cut -d "|" -f6)

bram=$(grep -m 1 "Utilization (%)" "$project_directory//build/syfala_ip/syfala/syn/report/syfala_csynth.rpt" | cut -d "|" -f3)
dsp=$(grep -m 1 "Utilization (%)" "$project_directory//build/syfala_ip/syfala/syn/report/syfala_csynth.rpt" | cut -d "|" -f4)
ff=$(grep -m 1 "Utilization (%)" "$project_directory//build/syfala_ip/syfala/syn/report/syfala_csynth.rpt" | cut -d "|" -f5)
lut=$(grep -m 1 "Utilization (%)" "$project_directory//build/syfala_ip/syfala/syn/report/syfala_csynth.rpt" | cut -d "|" -f6)
fi
if [[ $project_exist == "0" ]]
then
project_date=$(tail -1 "$project_directory/build/vivado.log" |rev| cut -b8-23 | rev)
app_date=$(ls -l  --time-style locale "$project_directory/build/sw_export/application.elf" |rev| cut -b76-89 | rev)

Vlut=$(grep -m 1 "Slice LUTs" "$project_directory/build/syfala_project/syfala_project.runs/impl_1/main_wrapper_utilization_placed.rpt" | rev | cut -d "|" -f2 | rev | cut -d "." -f1) #get last field to be compatible with 2020 and 2022
Vreg=$(grep -m 1 "Register" "$project_directory//build/syfala_project/syfala_project.runs/impl_1/main_wrapper_power_routed.rpt" | cut -d "|" -f6 | cut -d "." -f1)
Vbram=$(grep -m 1 "Block RAM" "$project_directory//build/syfala_project/syfala_project.runs/impl_1/main_wrapper_power_routed.rpt" | cut -d "|" -f6 | cut -d "." -f1)
Vdsp=$(grep -m 1 "DSPs" "$project_directory//build/syfala_project/syfala_project.runs/impl_1/main_wrapper_power_routed.rpt" | cut -d "|" -f6 | cut -d "." -f1)

TTVlut=$(grep -m 1 "Slice LUTs" "$project_directory/build/syfala_project/syfala_project.runs/impl_1/main_wrapper_utilization_placed.rpt" | cut -d "|" -f3)
TTVreg=$(grep -m 1 "Register" "$project_directory//build/syfala_project/syfala_project.runs/impl_1/main_wrapper_power_routed.rpt" | cut -d "|" -f4)
TTVbram=$(grep -m 1 "Block RAM" "$project_directory//build/syfala_project/syfala_project.runs/impl_1/main_wrapper_power_routed.rpt" | cut -d "|" -f4 | cut -d "." -f1)
TTVdsp=$(grep -m 1 "DSPs" "$project_directory//build/syfala_project/syfala_project.runs/impl_1/main_wrapper_power_routed.rpt" | cut -d "|" -f4)
fi


move_cursor_abs () {
    #move cursor in absolute coordinate, with the 0,0 point bellow the line from where the commande is launched
    #$1=line, $2=col
    printf "\033[u"
    if [[ $1 -gt 0 ]]
    then
    printf "\033[%dB" $1
    fi
    if [[ $2 -gt 0 ]]
    then
    printf "\033[%dC" $2
    fi
}
print_bargraph () {
    tput setaf $3 ;\
    size=$4
    ((percent=$2*$size/100))

    lineReturn=$(printf "\033[1B\033[%dD" $(($size+12))) #12=6 text box + 6 percent box
    printf "\e[1m%5s\e[0m " "$1"
    tput setaf $3 ;\

    i=0
    while [[ $i -lt $percent ]]
    do
        ((i = i + 1))
        printf '█%.0s' ; \
    done

    i=$percent
    tput setaf 0 ;\
    while [[ $i -lt $size ]]
    do
        ((i = i + 1))
        printf '█%.0s' ; \
    done
    tput setaf $3 ;\
    printf " %3s%% " $2
    if [[ $5 -ne " " ]]
    then
        printf "(%s)" $5
    fi
    printf $lineReturn
   echo -en '\033[0m' # [0m - resets all attributes, colors, formatting, etc.

}


print_frame () {
    ((thisHeight=$1-1))
    thisWidth=$2
    lineReturn=$(printf "\033[1B\033[%dD\b\b" $thisWidth)
    printf "+\033[%dC+%s" $thisWidth $lineReturn; \

    for i in $( eval echo {2..$thisHeight} )
    do
        printf "|\033[%dC|%s" $thisWidth $lineReturn; \
    done
    printf "\033[1C" ; \
    for i in $( eval echo {1..$thisWidth} )
    do
        printf "%s\033[%dA\b%s\033[%dB" "-" $thisHeight "-" $thisHeight; \
    done
    printf "\033[%dD\b+\033[%dC+%s" $thisWidth $thisWidth $lineReturn; \
}

 # init GUI height
init_height () {
    for i in $( eval echo {1..$1} )
    do
        printf "\n"; \
    done
    printf "\033[%dA" $1
    printf "\033[s"
}


print_waiting () {
    i=1
    sp="/-\|"
    while [[ 1 ]]
    do
        printf "${sp:i++%${#sp}:1}"
        printf "\033[1D"
        sleep 0.4
    done
}


((height=($(tput lines))-3))
((width=($(tput cols))-3))
normWidth=$width #Modified width disible by 3
(( normWidth = normWidth/3, normWidth *= 3));
((bargraphWidth=($normWidth*2/5)-20))

need_height=35 #empirique

if [[ $width -lt 52 ]]
then
    printf "Window to small!\n"
    exit
fi
if [[ $height -lt 11 ]]
then
    printf "Window to small!\n"
    exit
fi

#------------------------------------------------------------------------------

print_title () {
thisCaseHeight=6
init_height $thisCaseHeight

move_cursor_abs 0 0
print_frame $thisCaseHeight $(($normWidth-1))

move_cursor_abs 1 $((($normWidth/2)-10))
printf "\
┏━┓╻ ╻┏━╸┏━┓╻  ┏━┓ \033[1B\033[19D\
┗━┓┗┳┛┣╸ ┣━┫┃  ┣━┫ \033[1B\033[19D\
┗━┛ ╹ ╹  ╹ ╹┗━╸╹ ╹ \033[1B\033[19D\
"
printf "Compiler"

move_cursor_abs 3 $(($normWidth-10))
printf "V%s" $compiler_version
move_cursor_abs 4 $(($normWidth-10))
printf "%s" $date

move_cursor_abs $(($thisCaseHeight-1)) 0
}

#------------------------------------------------------------------------------
print_board () {
thisCaseHeight=7
init_height $thisCaseHeight

move_cursor_abs 0 0
print_frame $thisCaseHeight $((( $normWidth/3)-1))
move_cursor_abs 0 $((($normWidth/3)))
print_frame $thisCaseHeight $((( $normWidth/3)-1))
move_cursor_abs 0 $((($normWidth*2/3)))
print_frame $thisCaseHeight $((($normWidth/3)-1))
move_cursor_abs 2 2
printf "\
░█▀▄░█▀▀░█▀█░\033[1B\033[13D\
░█░█░▀▀█░█▀▀░\033[1B\033[13D\
░▀▀░░▀▀▀░▀░░░\033[1B\033[13D\
"
if [[ $width -gt 90 ]]
then
   move_cursor_abs 3 $((($normWidth/6)+2))
else
   move_cursor_abs 5 2
fi
printf "\e[1m%s\e[0m" $dspFile


move_cursor_abs 2 $((($normWidth/3)+2))
printf "\
░█▀▄░█▀█░█▀█░█▀▄░█▀▄░\033[1B\033[21D\
░█▀▄░█░█░█▀█░█▀▄░█░█░\033[1B\033[21D\
░▀▀░░▀▀▀░▀░▀░▀░▀░▀▀░░\033[1B\033[21D\
"
if [[ $width -gt 90 ]]
then
   move_cursor_abs 3 $((($normWidth/2)+8))
else
   move_cursor_abs 5 $((($normWidth/3)+2))
fi
printf "\e[1m%s\e[0m" $board

move_cursor_abs 1 $((($normWidth*2/3)+4))
printf "\e[1mSample Rate = \e[0m"
printf "$sample_rate"
move_cursor_abs 2 $((($normWidth*2/3)+4))
printf "\e[1mSample Witdh = \e[0m"
printf "$sample_width"
move_cursor_abs 3 $((($normWidth*2/3)+4))
printf "\e[1mController = \e[0m"
printf "$spi_controller"
move_cursor_abs 4 $((($normWidth*2/3)+4))
printf "\e[1mVolume = \e[0m"
printf "$volume"
move_cursor_abs 5 $((($normWidth*2/3)+4))
printf "\e[1mIn = \e[0m"
printf "$num_inputs"
printf "\e[1m  Out = \e[0m"
printf "$num_outputs"

move_cursor_abs $(($thisCaseHeight-1)) 0
}

#----------------------------------------------------------------------------
print_HLS () {
thisCaseHeight=11
init_height $(($thisCaseHeight+2))

move_cursor_abs 2 $((($normWidth/4)+4))
print_bargraph DSP $dsp 5 $bargraphWidth $TTdsp
move_cursor_abs 4 $((($normWidth/4)+4))
print_bargraph FF $ff 6 $bargraphWidth $TTff
move_cursor_abs 6 $((($normWidth/4)+4))
print_bargraph LUT $lut 4 $bargraphWidth $TTlut
move_cursor_abs 8 $((($normWidth/4)+4))
print_bargraph BRAM $bram 3 $bargraphWidth $TTbram

move_cursor_abs 2 $((($normWidth*5/6)-3))
printf "\e[1mLatency\e[0m"
move_cursor_abs 3 $((($normWidth*5/6)-6))
printf "%s Cycles" $latency
move_cursor_abs 4 $((($normWidth*5/6)-6))
printf "%s" $latencyUs
move_cursor_abs 6  $((($normWidth*5/6)-6))
printf "Sample Time Use:"
if [[ $width -gt 90 ]]
then
move_cursor_abs 7 $((($normWidth*5/6)-($bargraphWidth/4)-8))
print_bargraph "" $(($latency*100/$maxCycle)) 7 $(($bargraphWidth/2)) " "
else
move_cursor_abs 7 $((($normWidth*5/6)-2))
printf "%d%%" $(($latency*100/$maxCycle))
fi

move_cursor_abs 0 0
print_frame $thisCaseHeight $(($normWidth-1))

move_cursor_abs 3  $((($normWidth/8)-2))
printf "\
░█░█░█░░░█▀▀░\033[1B\033[13D\
░█▀█░█░░░▀▀█░\033[1B\033[13D\
░▀░▀░▀▀▀░▀▀▀░\033[2B\033[13D\
"

echo $ip_date

move_cursor_abs $(($thisCaseHeight-1)) 0
}
#------------------------------------------------------------------------

print_vivado () {
thisCaseHeight=11
init_height $thisCaseHeight

move_cursor_abs 2 $((($normWidth/8)-2))
print_bargraph DSP $Vdsp 5 $bargraphWidth $TTVdsp
move_cursor_abs 4 $((($normWidth/8)-2))
print_bargraph Reg $Vreg 2 $bargraphWidth $TTVreg
move_cursor_abs 6 $((($normWidth/8)-2))
print_bargraph LUT $Vlut 4 $bargraphWidth $TTVlut
move_cursor_abs 8 $((($normWidth/8)-2))
print_bargraph BRAM $Vbram 3 $bargraphWidth $TTVbram



move_cursor_abs 0 0
print_frame $thisCaseHeight $(($normWidth-1))

move_cursor_abs 3 $((($normWidth-24)-(($normWidth/8)-4)))
printf "\
░█░█░▀█▀░█░█░█▀█░█▀▄░█▀█░\033[1B\033[25D\
░▀▄▀░░█░░▀▄▀░█▀█░█░█░█░█░\033[1B\033[25D\
░░▀░░▀▀▀░░▀░░▀░▀░▀▀░░▀▀▀░\033[1B\033[25D\
"
move_cursor_abs 7 $((($normWidth-24)-(($normWidth/8)-4)))
echo "Project:" $project_date
move_cursor_abs 8 $((($normWidth-24)-(($normWidth/8)-4)))
echo "App:" $app_date
move_cursor_abs $(($thisCaseHeight-1)) 0

}

print_error () {
thisCaseHeight=3
init_height $thisCaseHeight
move_cursor_abs 0 0
print_frame $thisCaseHeight $(($normWidth-1))
move_cursor_abs 1 1
tput setab $2
for i in $( eval echo {2..$normWidth} )
do
    printf " "; \
done
move_cursor_abs 1 1
tput setab $2
printf "\33[1m $1\33[0m"
move_cursor_abs $(($thisCaseHeight-1)) 0

}

print_title

if [[ $arch_exist == "1" ]]
then
    print_board
else
    print_error "Project clean!" 6
    move_cursor_abs $thisCaseHeight 0
    exit 0
fi

if [[ $ip_exist == "0" ]]
then
    print_HLS
elif  [[ $ip_exist == "1" ]]
then
    print_error "HLS Failed! See syfala.log for more informations." 1
else
    print_error "HLS not synthesized, please use the --ip option to build it." 3
fi

if [[ $project_exist == "0" ]]
then
print_vivado
elif  [[ $project_exist == "1" ]]
then
    print_error "Vivado synthesis Failed! See syfala.log for more informations." 1
else
    print_error "Vivado not synthesized, please use the --project and --synth options to build it." 3
fi
move_cursor_abs $thisCaseHeight 0

