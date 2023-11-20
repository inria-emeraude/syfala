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
mem_r=${11}
mem_w=${12}

sample_nb=${13}
if [ -z "$sample_nb" ]; then
sample_nb=1
fi;

onesample=$([ $sample_nb -gt 1 ]; echo $?) #return 0 if greater (inverted output)

HLS_IMPL_FILE="$project_directory/build/syfala_ip/syfala/impl/report/vhdl/export_impl.rpt"
HLS_SYN_FILE="$project_directory/build/syfala_ip/syfala/impl/report/vhdl/syfala_export.rpt" #Even if impl fail, this file contain syn results
HLS_SYN_FAILSAFE_FILE="$project_directory/build/syfala_ip/syfala/impl/vhdl/report/syfala_failfast_synth.rpt"


HLS_CSYNTH_FILE="$project_directory/build/syfala_ip/syfala/syn/report/syfala_csynth.rpt"
VIVADO_FILE_LUT="$project_directory/build/syfala_project/syfala_project.runs/impl_1/main_wrapper_utilization_placed.rpt"
VIVADO_FILE="$project_directory/build/syfala_project/syfala_project.runs/impl_1/main_wrapper_power_routed.rpt"

FILE_CHECKED_ARCH_EXIST="$project_directory/build/syfala_ip/syfala_ip.cpp"
FILE_CHECKED_IP_EXIST="$project_directory/build/syfala_ip/syfala/syfala.log"
FILE_CHECKED_IP_VALID="$project_directory/build/syfala_ip/syfala/impl/export.zip"
FILE_CHECKED_PROJECT_EXIST="$project_directory/build/syfala_project/syfala_project.xpr"
FILE_CHECKED_PROJECT_VALID="$project_directory/build/hw_export/main_wrapper.xsa"
FILE_CHECKED_APP_EXIST="$project_directory/build/syfala_application/platform" #check for the directory here
FILE_CHECKED_APP_VALID="$project_directory/build/sw_export/application.elf"
FILE_CHECKED_GUI_EXIST="$project_directory/build/gui" #check for the directory here
FILE_CHECKED_GUI_VALID="$project_directory/build/gui/faust-uart-control"

date=$(date +'%m/%d/%Y')

if [ -f $FILE_CHECKED_ARCH_EXIST ]; then
  arch_exist=1
else
  arch_exist=0
fi

if [ -f $FILE_CHECKED_IP_EXIST ]; then
    if [ -f $HLS_CSYNTH_FILE ]; then
        csynth_file_exist=1
    else
        csynth_file_exist=0
    fi
    if [ -f $HLS_IMPL_FILE ]; then #routed and implemented HLS
        impl_file_exist=1
    else
        impl_file_exist=0
    fi
    if [ -f $HLS_SYN_FILE ]; then #implemented HLS
        syn_file_exist=1
    else
        syn_file_exist=0
    fi
    if [ -f $FILE_CHECKED_IP_VALID ]; then
        ip_exist=2 #2: Success!
    else
        ip_exist=1 #1: failed
    fi
else
        ip_exist=0 #0: donesn't exist
fi

if [ -f $FILE_CHECKED_PROJECT_EXIST ]; then
    if [ -f $FILE_CHECKED_PROJECT_VALID ]; then
        project_exist=2 #2: Success!
    else
        project_exist=1 #1: failed
    fi
else
        project_exist=0 #0: donesn't exist
fi

if [ -d $FILE_CHECKED_APP_EXIST ]; then
    if [ -f $FILE_CHECKED_APP_VALID ]; then
        app_exist=2 #2: Success!
    else
        app_exist=1 #1: failed
    fi
else
        app_exist=0 #0: donesn't exist
fi


if [ -d $FILE_CHECKED_GUI_EXIST ]; then
    if [ -f $FILE_CHECKED_GUI_VALID ]; then
        gui_exist=2 #2: Success!
    else
        gui_exist=1 #1: failed
    fi
else
        gui_exist=0 #0: donesn't exist
fi
#---------------------------------------------------
if [[ $csynth_file_exist == "1" ]]
then
    hls_csynth_date=$(grep -m 1 "* Date:" $HLS_CSYNTH_FILE | cut -d: -f2-)

    MEGA="1000"
    ((periodeRefps=$MEGA*$MEGA*1000000/$sample_rate))
    clockString=$(grep -m 1 -A 2 "Clock" $HLS_CSYNTH_FILE | tail -n 1 | cut -d "|" -f3 | sed 's|[^0-9.]||g')
    clockps=$(awk '{print $1*$2}' <<<"${clockString} ${MEGA}")

    latencyCycles=$(grep -m 1 -A 3 "Latency (cycles)" $HLS_CSYNTH_FILE | tail -n 1 | cut -d "|" -f3)
    latencyTime=$(grep -m 1 -A 3 "Latency (cycles)" $HLS_CSYNTH_FILE | tail -n 1 | cut -d "|" -f5)

    ((latencyCyclesTot=$periodeRefps/$clockps))
    ((latencyCyclesPerSamples=$latencyCycles/$sample_nb))
    ((latencyCyclesPrct=$latencyCyclesPerSamples*100/$latencyCyclesTot))

    hls_csynth_bram_nb=$(grep -m 1 "Total" $HLS_CSYNTH_FILE | cut -d "|" -f3) #Get the third field of the line, separate by |
    hls_csynth_dsp_nb=$(grep -m 1 "Total" $HLS_CSYNTH_FILE | cut -d "|" -f4)
    hls_csynth_ff_nb=$(grep -m 1 "Total" $HLS_CSYNTH_FILE | cut -d "|" -f5)
    hls_csynth_lut_nb=$(grep -m 1 "Total" $HLS_CSYNTH_FILE | cut -d "|" -f6)

    hls_csynth_bram_prct=$(grep -m 1 "Utilization (%)" $HLS_CSYNTH_FILE | cut -d "|" -f3)
    hls_csynth_dsp_prct=$(grep -m 1 "Utilization (%)" $HLS_CSYNTH_FILE | cut -d "|" -f4)
    hls_csynth_ff_prct=$(grep -m 1 "Utilization (%)" $HLS_CSYNTH_FILE | cut -d "|" -f5)
    hls_csynth_lut_prct=$(grep -m 1 "Utilization (%)" $HLS_CSYNTH_FILE | cut -d "|" -f6)

    if [[ $impl_file_exist == "1" ]]; then #routed and implemented HLS
        hls_impl_date=$(grep -m 1 "* Date:" $HLS_IMPL_FILE | cut -d: -f2-)

        hls_impl_bram_nb=$(grep -m 1 "BRAM" $HLS_IMPL_FILE | rev | cut -d: -f1 | rev)
        hls_impl_dsp_nb=$(grep -m 1 "DSP" $HLS_IMPL_FILE | rev | cut -d: -f1 | rev)
        hls_impl_ff_nb=$(grep -m 1 "FF" $HLS_IMPL_FILE | rev | cut -d: -f1 | rev)
        hls_impl_lut_nb=$(grep -m 1 "LUT" $HLS_IMPL_FILE | rev | cut -d: -f1 | rev)

        hls_impl_bram_prct=$(grep -m 1 -A 12 "Place & Route Fail Fast" $HLS_IMPL_FILE | grep -m 1 "RAMB/FIFO " |  cut -d "|" -f4 | cut -d "." -f1)
        hls_impl_dsp_prct=$(grep -m 1 -A 12 "Place & Route Fail Fast" $HLS_IMPL_FILE | grep -m 1 "DSP " |  cut -d "|" -f4| cut -d "." -f1)
        hls_impl_ff_prct=$(grep -m 1 -A 12 "Place & Route Fail Fast" $HLS_IMPL_FILE | grep -m 1 "FD " |  cut -d "|" -f4| cut -d "." -f1)
        hls_impl_lut_prct=$(grep -m 1 -A 12 "Place & Route Fail Fast" $HLS_IMPL_FILE | grep -m 1 "LUT " |  cut -d "|" -f4| cut -d "." -f1)

        hls_impl_bram_guideline=$(grep -m 1 -A 12 "Place & Route Fail Fast" $HLS_IMPL_FILE | grep -m 1 "RAMB/FIFO " |  cut -d "|" -f3 )
        hls_impl_dsp_guideline=$(grep -m 1 -A 12 "Place & Route Fail Fast" $HLS_IMPL_FILE | grep -m 1 "DSP " |  cut -d "|" -f3)
        hls_impl_ff_guideline=$(grep -m 1 -A 12 "Place & Route Fail Fast" $HLS_IMPL_FILE | grep -m 1 "FD " |  cut -d "|" -f3)
        hls_impl_lut_guideline=$(grep -m 1 -A 12 "Place & Route Fail Fast" $HLS_IMPL_FILE | grep -m 1 "LUT " |  cut -d "|" -f3)

        hls_impl_bram_guideline_pass=$(grep -m 1 -A 12 "Place & Route Fail Fast" $HLS_IMPL_FILE | grep -m 1 "RAMB/FIFO " |  cut -d "|" -f5 )
        hls_impl_dsp_guideline_pass=$(grep -m 1 -A 12 "Place & Route Fail Fast" $HLS_IMPL_FILE | grep -m 1 "DSP " |  cut -d "|" -f5)
        hls_impl_ff_guideline_pass=$(grep -m 1 -A 12 "Place & Route Fail Fast" $HLS_IMPL_FILE | grep -m 1 "FD " |  cut -d "|" -f5)
        hls_impl_lut_guideline_pass=$(grep -m 1 -A 12 "Place & Route Fail Fast" $HLS_IMPL_FILE | grep -m 1 "LUT " |  cut -d "|" -f5)
    elif [[ $syn_file_exist == "1" ]]; then #implemented HLS
        hls_impl_date=$(grep -m 1 "date:" $HLS_SYN_FILE | cut -d: -f2-)

        hls_impl_bram_nb=$(grep -m 1 "BRAM" $HLS_SYN_FILE | rev | cut -d: -f1 | rev)
        hls_impl_dsp_nb=$(grep -m 1 "DSP" $HLS_SYN_FILE | rev | cut -d: -f1 | rev)
        hls_impl_ff_nb=$(grep -m 1 "FF" $HLS_SYN_FILE | rev | cut -d: -f1 | rev)
        hls_impl_lut_nb=$(grep -m 1 "LUT" $HLS_SYN_FILE | rev | cut -d: -f1 | rev)

        hls_impl_bram_prct=$( grep -m 1 "RAMB/FIFO " $HLS_SYN_FAILSAFE_FILE |  cut -d "|" -f4 | cut -d "." -f1)
        hls_impl_dsp_prct=$( grep -m 1 "DSP " $HLS_SYN_FAILSAFE_FILE |  cut -d "|" -f4| cut -d "." -f1)
        hls_impl_ff_prct=$( grep -m 1 "FD " $HLS_SYN_FAILSAFE_FILE |  cut -d "|" -f4| cut -d "." -f1)
        hls_impl_lut_prct=$( grep -m 1 "LUT " $HLS_SYN_FAILSAFE_FILE |  cut -d "|" -f4| cut -d "." -f1)

        hls_impl_bram_guideline=$( grep -m 1 "RAMB/FIFO " $HLS_SYN_FAILSAFE_FILE |  cut -d "|" -f3 )
        hls_impl_dsp_guideline=$( grep -m 1 "DSP " $HLS_SYN_FAILSAFE_FILE |  cut -d "|" -f3)
        hls_impl_ff_guideline=$( grep -m 1 "FD " $HLS_SYN_FAILSAFE_FILE |  cut -d "|" -f3)
        hls_impl_lut_guideline=$( grep -m 1 "LUT " $HLS_SYN_FAILSAFE_FILE |  cut -d "|" -f3)

        hls_impl_bram_guideline_pass=$( grep -m 1 "RAMB/FIFO " $HLS_SYN_FAILSAFE_FILE |  cut -d "|" -f5 )
        hls_impl_dsp_guideline_pass=$( grep -m 1 "DSP " $HLS_SYN_FAILSAFE_FILE |  cut -d "|" -f5)
        hls_impl_ff_guideline_pass=$( grep -m 1 "FD " $HLS_SYN_FAILSAFE_FILE |  cut -d "|" -f5)
        hls_impl_lut_guideline_pass=$( grep -m 1 "LUT " $HLS_SYN_FAILSAFE_FILE |  cut -d "|" -f5)
    fi

fi
if [[ $project_exist == "2" ]]
then
    project_date=$(grep -m 1 "Date" $VIVADO_FILE | cut -d: -f2-)

    vivado_lut_prct=$(grep -m 1 "LUTs" $VIVADO_FILE_LUT | rev | cut -d "|" -f2 | rev | cut -d "." -f1) #get last field to be compatible with 2020 and 2022
    vivado_ff_prct=$(grep -m 1 "Register" $VIVADO_FILE | cut -d "|" -f6 | cut -d "." -f1)
    vivado_bram_prct=$(grep -m 1 "Block RAM" $VIVADO_FILE | cut -d "|" -f6 | cut -d "." -f1)
    vivado_dsp_prct=$(grep -m 1 "DSPs" $VIVADO_FILE | cut -d "|" -f6 | cut -d "." -f1)

    vivado_lut_nb=$(grep -m 1 "LUTs" $VIVADO_FILE_LUT | cut -d "|" -f3)
    vivado_ff_nb=$(grep -m 1 "Register" $VIVADO_FILE | cut -d "|" -f4)
    vivado_bram_nb=$(grep -m 1 "Block RAM" $VIVADO_FILE | cut -d "|" -f4 | cut -d "." -f1)
    vivado_dsp_nb=$(grep -m 1 "DSPs" $VIVADO_FILE | cut -d "|" -f4)
fi

if [[ $app_exist == "2" ]]
then
    app_date=$(date -r "$project_directory/build/sw_export/application.elf" "+%b %d %H:%M:%S")
    app_max1787=$(grep -m 1 "MAX_EXTERNAL_1787" "$project_directory/build/include/syfala/arm/audio.hpp" | awk '{ print $NF }')
    app_baudrate=$(grep -m 1 "SYFALA_UART_BAUD_RATE" "$project_directory/build/include/syfala/config_arm.hpp" | awk '{ print $NF }')
    app_verbose=$(grep -m 1 "SYFALA_VERBOSE" "$project_directory/build/include/syfala/config_arm.hpp" | awk '{ print $NF }')
    app_iic_rate=$(grep -m 1 "IIC_SCLK_RATE" "$project_directory/build/include/syfala/arm/audio.hpp" | awk '{ print $NF }') #get last field of line (cut is tricky if there is only space or only tab as delimiter)

fi

if [[ $gui_exist == "2" ]]
then

    ADDBUTTON=$(grep -o "addButton" $project_directory/build/gui/faust-gui.cpp  | wc -l)
    ADDCHECKBOX=$(grep -o "addCheckButton" $project_directory/build/gui/faust-gui.cpp  | wc -l)
    ADDVERTICALSLIDER=$(grep -o "addVerticalSlider" $project_directory/build/gui/faust-gui.cpp  | wc -l)
    ADDHORIZONTALSLIDER=$(grep -o "addHorizontalSlider" $project_directory/build/gui/faust-gui.cpp  | wc -l)
    ADDNUMENTRY=$(grep -o "addNumEntry" $project_directory/build/gui/faust-gui.cpp  | wc -l)
    ADDVERTICALBARGRAPH=$(grep -o "addVerticalBargraph" $project_directory/build/gui/faust-gui.cpp  | wc -l)
    ADDHORIZONTALBARGRAPH=$(grep -o "addHorizontalBargraph" $project_directory/build/gui/faust-gui.cpp  | wc -l)

fi

#---------------------------------------------------


((height=($(tput lines))-3))
((width=($(tput cols))-3))
normWidth=$width #Modified width disible by 3
(( normWidth = normWidth/3, normWidth *= 3));
((bargraphWidth=($normWidth*2/5)-25))

need_height=35 #empirique

if [[ $width -lt 60 ]]
then
    printf "Window to small!\n"
    exit
fi
if [[ $height -lt 11 ]]
then
    printf "Window to small!\n"
    exit
fi

printBargraph=$(! [ $width -gt 110 ]; echo $?)
printCompact=$(! [ $width -lt 90 ]; echo $?)

#---------------------------------------------------

#Pin nb based on constraints files
if [[ $board == "GENESYS" ]]
then
#GENESYS
    JA=('W10' 'AA11' 'AB10' 'Y9' 'Y10' 'AA10' 'AB9' 'AA8')
    JB=('AE13' 'AG14' 'AH14' 'AG13' 'AE14' 'AF13' 'AE15' 'AH13')
    JC=('E13' 'G13' 'B13' 'D14' 'F13' 'C13' 'C14' 'A13')
    JD=('E15' 'A14' 'B15' 'F15' 'E14' 'B14' 'D15' 'A15')
    PMOD=('JD' 'JC' 'JB' 'JA')
else
#ZYBO Z10 and Z20
    JA=('N15' 'L14' 'K16' 'K14' 'N16' 'L15' 'J16' 'J14')
    JB=('V8' 'W8' 'U7' 'V7' 'Y7' 'Y6' 'V6' 'W6')
    JC=('V15' 'W15' 'T11' 'T10' 'W14' 'Y14' 'T12' 'U12')
    JD=('T14' 'T15' 'P14' 'R14' 'U14' 'U15' 'V17' 'V18')
    JE=('V12' 'W16' 'J15' 'H15' 'V13' 'U17' 'T17' 'Y17')
    PMOD=('JE' 'JD' 'JC' 'JB') #Change here if you want to print JA
fi

get_pin_name() {
name=$(grep -m 1 " $1 " "$project_directory/build/syfala_project/syfala_project.runs/impl_1/main_wrapper_io_placed.rpt" | cut -d "|" -f3 | tr -d '[:space:]') #Space around '$1' are mandatory, here to avoid to confuse E13 and AE13 for exemple
if [[ ${#name} -gt 0 ]]
then
    if [[ ${#name} -gt $(($2+2)) ]]
    then
    printf ${name:0:$2}"…\033[1C" #space at the end to compensate strange behavior withe ascii '...'
    else
    echo $name
    fi
else
echo "-"
fi
}


print_PMOD () {
textSize=$2
pinNbArray=$1[@]
cnt=0;
for pinNb in ${!pinNbArray}
do
    name[$cnt]=$(get_pin_name $pinNb $(($textSize-2)))
    cnt=$((cnt+1))
done
tput setab 7
tput setaf 0
printf "\033[$((${textSize}+1))C\33[1m  $1   \33[0m\033[1B\033[7D\
╔══╤══╗\033[1B\033[$((${textSize}+8))D\
%${textSize}s ║ 1│7 ║ %-${textSize}s\033[1B\033[$(((${textSize}*2)+9))D\
%${textSize}s ║ 2│8 ║ %-${textSize}s\033[1B\033[$(((${textSize}*2)+9))D\33[0m\
%${textSize}s ║ 3│9 ║ %-${textSize}s\033[1B\033[$(((${textSize}*2)+9))D\
%${textSize}s ║ 4│10║ %-${textSize}s\033[1B\033[$(((${textSize})+12))D\
GND ┇ 5│11┇ GND\033[1B\033[15D\
VCC ▌ 6│12▐ VCC\033[1B\033[15D\
    ▙▄▄█▄▄▟    \033[1B\033[15D\
 top       bot.  \n\n" ${name[0]} ${name[4]} ${name[1]} ${name[5]} ${name[2]} ${name[6]} ${name[3]} ${name[7]};
}

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
 if [ "$printBargraph" = 0 ] ; then
 printf "\033[%dC" $(($bargraphWidth/2)) #compensate if we don't print bargraph to keep centered
 fi
    tput setaf $3 ;\
    size=$4
    overflow=0
    if [[ $2 -gt 100 ]]
    then
        ((overflow=1+($2/100)*$size/20)) #arbitrary: each +100% overflow is a step of 5% of size +1%
       (( percent=$size))
    else
        ((percent=$2*$size/100))
    fi
    lineReturn=$(printf "\033[1B\033[%dD" $(($size+12))) #12=6 text box + 6 percent box
    printf "\e[1m%5s\e[0m " "$1"
    tput setaf $3 ;\

    if [ "$printBargraph" = 1 ] ; then
        i=0
        while [[ $i -lt $percent ]]
        do
            ((i = i + 1))
            printf '█%.0s' ; \
        done

        i=$percent
        if [[ -z "$6" ]] #NO background color
        then
            tput setaf 0 ;\
        fi
        while [[ $i -lt $size ]]
        do
            ((i = i + 1))
            printf '░%.0s' ; \
        done

        if [[ $overflow -gt 0 ]]
        then
        tput setaf 1 ;\
        printf '░%.0s' ; \
        i=1
        while [[ $i -lt $overflow ]]
        do
            ((i = i + 1))
            printf '█%.0s' ; \
        done
        else
        tput setaf $3 ;\
        fi
    fi
    printf " %3s%% " $2
    if  [ ! -z "$5" ]
    then
        printf "($5)"
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
if [ "$printCompact" = 1 ] ; then
   move_cursor_abs 5 2
else
   move_cursor_abs 3 $((($normWidth/6)))

fi
printf "\e[1m%s\e[0m" $dspFile


move_cursor_abs 2 $((($normWidth/3)+2))
printf "\
░█▀▄░█▀█░█▀█░█▀▄░█▀▄░\033[1B\033[21D\
░█▀▄░█░█░█▀█░█▀▄░█░█░\033[1B\033[21D\
░▀▀░░▀▀▀░▀░▀░▀░▀░▀▀░░\033[1B\033[21D\
"
if [ "$printCompact" = 1 ] ; then
   move_cursor_abs 5 $((($normWidth/3)+2))
else
   move_cursor_abs 3 $((($normWidth/2)+8))
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
print_hls_csynth () {
if [ "$printCompact" = 1 ] ; then
thisCaseHeight=19
secondPartLine=8
else
thisCaseHeight=12
secondPartLine=0
fi
init_height $(($thisCaseHeight+2))
move_cursor_abs 0 0
print_frame $thisCaseHeight $(($normWidth-1))

move_cursor_abs 6  $((($normWidth/8)-2))
echo $hls_csynth_date

move_cursor_abs 2 $((($normWidth/4)+4+$secondPartLine*2))
print_bargraph DSP $hls_csynth_dsp_prct 5 $bargraphWidth $hls_csynth_dsp_nb
move_cursor_abs 4 $((($normWidth/4)+4+$secondPartLine*2))
print_bargraph FF $hls_csynth_ff_prct 6 $bargraphWidth $hls_csynth_ff_nb
move_cursor_abs 6 $((($normWidth/4)+4+$secondPartLine*2))
print_bargraph LUT $hls_csynth_lut_prct 4 $bargraphWidth $hls_csynth_lut_nb
move_cursor_abs 8 $((($normWidth/4)+4+$secondPartLine*2))
print_bargraph BRAM $hls_csynth_bram_prct 3 $bargraphWidth $hls_csynth_bram_nb

move_cursor_abs $((1+$secondPartLine)) $((($normWidth-30)-($normWidth*1/10)))
printf "Latency"
move_cursor_abs $((2+$secondPartLine)) $((($normWidth-30)-($normWidth*1/10)))
if [ "$onesample" = 1 ] ; then
    printf "┎───────────\e[1m ONE SAMPLE \e[0m─────────────┒\033[1B\033[38D"
else
    printf "┎─────────\e[1m MULTISAMPLE=%3d \e[0m──────────┒\033[1B\033[38D" $sample_nb
fi
printf "┃\033[17C│\033[18C┃\033[1B\033[38D"
printf "┃\033[17C│\033[18C┃\033[1B\033[38D"
printf "┃\033[17C│\033[18C┃\033[1B\033[38D"
printf "┖────────────────────────────────────┚"

move_cursor_abs $((3+$secondPartLine)) $((($normWidth-28)-($normWidth*1/10)))
printf "\e[1mTot.\e[0m"
move_cursor_abs $((4+$secondPartLine)) $((($normWidth-28)-($normWidth*1/10)))
printf "%s Cycles" $latencyCycles
move_cursor_abs $((5+$secondPartLine)) $((($normWidth-28)-($normWidth*1/10)))
printf "%s" $latencyTime
move_cursor_abs $((3+$secondPartLine)) $((($normWidth-10)-($normWidth*1/10)))
if [ "$onesample" = 1 ] ; then
    printf "\e[1mMax.\e[0m"
    move_cursor_abs $((4+$secondPartLine)) $((($normWidth-10)-($normWidth*1/10)))
    printf "%s Cycles" $latencyCyclesTot
    move_cursor_abs $((5+$secondPartLine)) $((($normWidth-10)-($normWidth*1/10)))
    printf "%sus" $(awk '{print ($2*$2)/$1}' <<<"${sample_rate} ${MEGA}")
else
    printf "\e[1mPer Sample\e[0m"
    move_cursor_abs $((4+$secondPartLine)) $((($normWidth-10)-($normWidth*1/10)))
    printf "%s Cycles" $latencyCyclesPerSamples
    move_cursor_abs $((5+$secondPartLine)) $((($normWidth-10)-($normWidth*1/10)))
    printf "Max:%s Cyc." $latencyCyclesTot
fi
move_cursor_abs $((7+$secondPartLine))  $((($normWidth*5/6)-14))
print_bargraph "Lat." $latencyCyclesPrct 2 $(($bargraphWidth/2)) "" true


move_cursor_abs $((9+$secondPartLine/3))  $((($normWidth*5/6)-5-$secondPartLine*7))
printf "\e[1mMem. Access: \e[0m"
printf "R=$mem_r, W=$mem_w"

move_cursor_abs 3  $((($normWidth/8)-2))
printf "\
░█░█░█░░░█▀▀░\033[1B\033[13D\
░█▀█░█░░░▀▀█░\033[1B\033[13D\
░▀░▀░▀▀▀░▀▀▀░ \033[1mSYNTH\033[0m\033[2B\033[19D\
"


move_cursor_abs $(($thisCaseHeight-2)) $((($normWidth/2)-53))
tput setaf 1
printf "\e[1mThe HLS resources usage is approximate, please use --accurate-use option to get an accurate ressource usage.\e[0m "
move_cursor_abs $(($thisCaseHeight-1)) 0
}

#----------------------------------------------------------------------------
print_HLS_impl () {
thisCaseHeight=11
init_height $(($thisCaseHeight+2))
move_cursor_abs 0 0
print_frame $thisCaseHeight $(($normWidth-1))

move_cursor_abs 6  $((($normWidth/8)-2))
echo $hls_impl_date

move_cursor_abs 2 $((($normWidth/3)+5))
print_bargraph DSP $hls_impl_dsp_prct 5 $bargraphWidth $hls_impl_dsp_nb
move_cursor_abs 4 $((($normWidth/3)+5))
print_bargraph FF $hls_impl_ff_prct 6 $bargraphWidth $hls_impl_ff_nb
move_cursor_abs 6 $((($normWidth/3)+5))
print_bargraph LUT $hls_impl_lut_prct 4 $bargraphWidth $hls_impl_lut_nb
move_cursor_abs 8 $((($normWidth/3)+5))
print_bargraph BRAM $hls_impl_bram_prct 3 $bargraphWidth $hls_impl_bram_nb

move_cursor_abs 1 $((($normWidth*5/6)+($normWidth/20)-7))
tput setab 7
tput setaf 0
echo " GUIDELINE "

move_cursor_abs 2 $((($normWidth*5/6)+($normWidth/20)-6))
echo "$hls_impl_dsp_guideline"
move_cursor_abs 2 $((($normWidth*5/6)+($normWidth/20)-1))
printf "\33[1m$hls_impl_dsp_guideline_pass\033[0m"
move_cursor_abs 4 $((($normWidth*5/6)+($normWidth/20)-6))
echo "$hls_impl_ff_guideline"
move_cursor_abs 4 $((($normWidth*5/6)+($normWidth/20)-1))
printf "\33[1m$hls_impl_ff_guideline_pass\033[0m"
move_cursor_abs 6 $((($normWidth*5/6)+($normWidth/20)-6))
echo "$hls_impl_lut_guideline"
move_cursor_abs 6 $((($normWidth*5/6)+($normWidth/20)-1))
printf "\33[1m$hls_impl_lut_guideline_pass\033[0m"
move_cursor_abs 8 $((($normWidth*5/6)+($normWidth/20)-6))
echo "$hls_impl_bram_guideline"
move_cursor_abs 8 $((($normWidth*5/6)+($normWidth/20)-1))
printf "\33[1m$hls_impl_bram_guideline_pass\033[0m"

move_cursor_abs 3  $((($normWidth/8)-2))
printf "\
░█░█░█░░░█▀▀░\033[1B\033[13D\
░█▀█░█░░░▀▀█░\033[1B\033[13D\
░▀░▀░▀▀▀░▀▀▀░ \033[1mIMPL\033[0m\033[2B\033[18D\
"
move_cursor_abs 8  $((($normWidth/8)-2))
printf "\33[1mSynthesis: \33[0m"
if [[ $syn_file_exist == "1" ]]; then
    tput setaf 2
    printf "OK"
else
    tput setaf 1
    printf "FAILED !!"
fi
move_cursor_abs 9  $((($normWidth/8)-2))
printf "\33[1mImplementation: \33[0m"
if [[ $impl_file_exist == "1" ]]; then
    tput setaf 2
    printf "OK"
else
    tput setaf 1
    printf "FAILED !!"
fi

move_cursor_abs $(($thisCaseHeight-1)) 0
}
#------------------------------------------------------------------------

print_vivado () {
thisCaseHeight=11
init_height $thisCaseHeight
move_cursor_abs 0 0
print_frame $thisCaseHeight $(($normWidth-1))

move_cursor_abs 2 $((($normWidth/8)-2))
print_bargraph DSP $vivado_dsp_prct 5 $bargraphWidth $vivado_dsp_nb
move_cursor_abs 4 $((($normWidth/8)-2))
print_bargraph Reg $vivado_ff_prct 6 $bargraphWidth $vivado_ff_nb
move_cursor_abs 6 $((($normWidth/8)-2))
print_bargraph LUT $vivado_lut_prct 4 $bargraphWidth $vivado_lut_nb
move_cursor_abs 8 $((($normWidth/8)-2))
print_bargraph BRAM $vivado_bram_prct 3 $bargraphWidth $vivado_bram_nb
move_cursor_abs 3 $((($normWidth-24)-(($normWidth/8)-4)))
printf "\
░█░█░▀█▀░█░█░█▀█░█▀▄░█▀█░\033[1B\033[25D\
░▀▄▀░░█░░▀▄▀░█▀█░█░█░█░█░\033[1B\033[25D\
░░▀░░▀▀▀░░▀░░▀░▀░▀▀░░▀▀▀░\033[1B\033[25D\
"
move_cursor_abs 7 $((($normWidth-24)-(($normWidth/8)-4)))
echo $project_date

move_cursor_abs $(($thisCaseHeight-1)) 0

}

print_app () {

thisCaseHeight=6
init_height $thisCaseHeight
move_cursor_abs 0 0
print_frame $thisCaseHeight $(($normWidth-1))
move_cursor_abs 2 4
printf "\33[1m APPLICATION\33[0m"
move_cursor_abs 3 4
echo  $app_date
move_cursor_abs 1 $((($normWidth/5)))
printf "Verbose Level: %s" $app_verbose
move_cursor_abs 2 $((($normWidth/5)))
printf "IIC Clk (Hz): %s" $app_iic_rate
move_cursor_abs 3 $((($normWidth/5)))
printf "Max nb ADAU1787: %s" $app_max1787
move_cursor_abs 4 $((($normWidth/5)))
printf "Serial Baud Rate: %s" $app_baudrate
move_cursor_abs $(($thisCaseHeight-1)) 0



}
print_gui () {

thisCaseHeight=6
if [[ $app_exist != "2" ]]
then
    init_height $thisCaseHeight
fi
move_cursor_abs 0 $((($normWidth*2/3)-1))
print_frame $thisCaseHeight $(($normWidth/3))
move_cursor_abs 1 $((2+$normWidth*5/6))
printf "\33[1m GUI\33[0m"
move_cursor_abs 2 $((($normWidth*5/6)-10))
printf "Buttons: %s" $ADDBUTTON
move_cursor_abs 2 $((($normWidth*5/6)+2))
printf "Checkbox: %s" $ADDCHECKBOX
move_cursor_abs 3 $((($normWidth*5/6)-10))
printf "Sliders: %s" $(($ADDVERTICALSLIDER+$ADDHORIZONTALSLIDER))
move_cursor_abs 3 $((($normWidth*5/6)+2))
printf "Bargraphs: %s" $(($ADDVERTICALBARGRAPH+$ADDHORIZONTALBARGRAPH))
move_cursor_abs 4 $((($normWidth*5/6)-4))
printf "Num Entry: %s" $ADDNUMENTRY
move_cursor_abs $(($thisCaseHeight-1)) 0

}

print_pinout () {
thisCaseHeight=14
init_height $thisCaseHeight
print_frame $thisCaseHeight $(($normWidth-1))
PMOD_width=$((($normWidth/10)-2))

move_cursor_abs 2 1
print_PMOD ${PMOD[0]} $PMOD_width
move_cursor_abs 2 $((($normWidth)*1/4))
print_PMOD ${PMOD[1]} $PMOD_width
move_cursor_abs 2 $(((($normWidth)*2/4)))
print_PMOD ${PMOD[2]} $PMOD_width
move_cursor_abs 2 $(((($normWidth)*3/4)))
print_PMOD ${PMOD[3]} $PMOD_width
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
tput setaf 7
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

if [[ $ip_exist != "0" ]]
then
    if [[ $csynth_file_exist == "1" ]]; then
    print_hls_csynth
        if [[ $syn_file_exist == "1" ]]; then #routed and implemented HLS
            print_HLS_impl
        fi
    fi
    if  [[ $ip_exist == "1" ]]
    then
        print_error "HLS Export Failed! See syfala.log for more informations." 1
    fi
elif [[ $arch_exist == "1" ]] #only print this if the Arch is done to avoid multiple messages
then
    print_error "HLS not synthesized, please use the --ip option to build it." 3
fi

if [[ $project_exist == "2" ]]
then
print_vivado
elif  [[ $project_exist == "1" ]]
then
    print_error "vivado synthesis Failed! See syfala.log for more informations." 1
elif [[ $ip_exist == "2" ]] #only print this if the HLS is done to avoid multiple messages
then
    print_error "vivado not synthesized, please use the --project and --synth options to build it." 3
fi


if [[ $app_exist == "2" ]]
then
print_app
elif  [[ $app_exist == "1" ]]
then
    print_error "Application build Failed! See syfala.log for more informations." 1
elif [[ $project_exist == "2" ]] #only print this if vivado is done to avoid multiple messages
then
    print_error "Application not builded, please use the --app or --app-rebuild option to build it." 3
fi

if [[ $gui_exist == "2" ]]
then
print_gui
elif  [[ $gui_exist == "1" ]]
then
    print_error "GUI build Failed! See syfala.log for more informations." 1
elif [[ $app_exist == "2" ]] #only print this if the App is done to avoid multiple messages
then
    print_error "GUI not builded, please use the --gui option to build it." 3
fi

if [[ $app_exist == "2" ]]
then
if [[ $width -lt 100 ]]
then
    print_error "Extend window to show pinout." 0
else
    print_pinout
fi
fi


move_cursor_abs $thisCaseHeight 0
