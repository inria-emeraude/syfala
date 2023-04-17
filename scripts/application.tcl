source ../scripts/sylib.tcl
namespace import Syfala::*

set IP_VHDL [lindex $argv 0]
set BOARD   [lindex $argv 1]

switch $BOARD {
Z10 - Z20 {
    set arch "32-bit"
    set domain_name "standalone_ps7_cortexa9_0"
    set proc_name "ps7_cortexa9_0"
    set os "standalone"
}
GENESYS {
    set arch "64-bit"
    set domain_name "standalone_psu_cortexa53_0"
    set proc_name "psu_cortexa53_0"
}
default {
    print_error "Unsupported board model ($BOARD), aborting."
    exit 1
}
}
# Set workspace
setws $::Syfala::BUILD_APPLICATION_DIR

set PLATFORM_NAME     "platform"
set APPLICATION_NAME  "application"

# Create platform
platform create -name $PLATFORM_NAME        \
    -hw hw_export/main_wrapper.xsa          \
    -arch $arch                             \
    -fsbl-target "psu_cortexa53_0" ;
# always psu_cortexa53_0, even for Zybo. Don't understand why...

platform write

# Create domain
domain create -name $domain_name            \
              -display-name $domain_name    \
              -os $os                       \
              -proc $proc_name              \
              -runtime "cpp"                \
              -arch $arch                   \
              -support-app "hello_world"

# Generate platform
platform generate -domains 
platform active $PLATFORM_NAME

switch $BOARD {
Z10 - Z20 {
    domain active "zynq_fsbl"
}
GENESYS {
    domain active "zynqmp_fsbl"
    domain active "zynqmp_pmufw"
}
}

domain active $domain_name
platform generate -quick
platform generate

# Create application
app create -name $APPLICATION_NAME                  \
           -platform $PLATFORM_NAME                 \
           -os $os                                  \
           -domain $domain_name                     \
           -template "Empty Application (C++)"      \
           -lang "c++"

# Note: this implies that user has a faust installation
# in /usr/local/include, which is not good..
# but, then again, its waaay better than having to include /usr/include
# because that just doesn't work...
# what to do...?
app config -name $APPLICATION_NAME -add include-path "/usr/local/include"
app config -name $APPLICATION_NAME -add include-path $::Syfala::BUILD_INCLUDE_DIR
app config -name $APPLICATION_NAME -add libraries "m"
app config -name $APPLICATION_NAME -set compiler-optimization {Optimize most (-O3)}
app config -name $APPLICATION_NAME -add compiler-misc "-std=c++17"

set sources [list]

if $IP_VHDL {
    set sources [list   \
        arm_vhdl.cpp    \
        audio.cpp       \
        gpio.cpp        \
        uart.cpp        \
    ]
} else {
# with HLS, we need to import the /hw/drivers for the IP
# but obviously, this is not necessary for the faust2vhdl IP
    set sources [list   \
        arm.cpp         \
        audio.cpp       \
        gpio.cpp        \
        ip.cpp          \
        memory.cpp      \
        spi.cpp         \
        uart.cpp        \
    ]
    set drivers_path $::Syfala::BUILD_APPLICATION_DIR/$PLATFORM_NAME/hw/drivers/syfala_v1_0/src
    app config -name $APPLICATION_NAME -add include-path $drivers_path
    importsources -name $APPLICATION_NAME -path $drivers_path
    importsources -name $APPLICATION_NAME -path $::Syfala::SOURCE_DIR/arm/faust
    importsources -name $APPLICATION_NAME -path $::Syfala::SOURCE_DIR/arm/codecs
}

foreach src $sources {
    importsources -name $APPLICATION_NAME \
                  -path $::Syfala::SOURCE_DIR/arm/baremetal/$src
}

switch $BOARD {
Z10 - Z20 {
importsources -name $APPLICATION_NAME                                       \
              -path $::Syfala::SOURCE_DIR/arm/baremetal/linkers/zybo        \
              -linker-script
}
GENESYS {
importsources -name $APPLICATION_NAME                                       \
              -path $::Syfala::SOURCE_DIR/arm/baremetal/linkers/genesys     \
              -linker-script
}
}

app build -name $APPLICATION_NAME
