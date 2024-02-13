source scripts/sylib.tcl
namespace import Syfala::*

set CONFIG  [lindex $::argv 0]
set BOARD   [lindex $::argv 1]
set TARGET  [lindex $::argv 2]

print_info "$TARGET"

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
    set os "standalone"
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
platform create -name $PLATFORM_NAME                        \
    -hw $::Syfala::BUILD_DIR/hw_export/main_wrapper.xsa     \
    -arch $arch                                             \
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
set drivers_path $::Syfala::BUILD_APPLICATION_DIR/$PLATFORM_NAME/hw/drivers/syfala_v1_0/src

switch $CONFIG {
    minimal {
        set sources [list                                               \
            $TARGET                                                     \
            $::Syfala::SOURCE_DIR/arm/baremetal/modules/audio.cpp       \
            $::Syfala::SOURCE_DIR/arm/baremetal/modules/gpio.cpp        \
            $::Syfala::SOURCE_DIR/arm/baremetal/modules/uart.cpp        \
            $::Syfala::SOURCE_DIR/arm/baremetal/modules/ip.cpp          \
        ]
        app config -name $APPLICATION_NAME -add include-path $drivers_path
        importsources -name $APPLICATION_NAME -path $drivers_path
        importsources -name $APPLICATION_NAME -path $::Syfala::SOURCE_DIR/arm/codecs
    }
    faust2vhdl {
        set sources [list                                               \
            $TARGET                                                     \
            $::Syfala::SOURCE_DIR/arm/baremetal/modules/audio.cpp       \
            $::Syfala::SOURCE_DIR/arm/baremetal/modules/gpio.cpp        \
            $::Syfala::SOURCE_DIR/arm/baremetal/modules/uart.cpp        \
        ]
    }
    std {
    # with HLS, we need to import the /hw/drivers for the IP
    # but obviously, this is not necessary for the faust2vhdl IP
        set sources [list                                               \
            $TARGET                                                     \
            $::Syfala::SOURCE_DIR/arm/baremetal/modules/audio.cpp       \
            $::Syfala::SOURCE_DIR/arm/baremetal/modules/gpio.cpp        \
            $::Syfala::SOURCE_DIR/arm/baremetal/modules/ip.cpp          \
            $::Syfala::SOURCE_DIR/arm/baremetal/modules/memory.cpp      \
            $::Syfala::SOURCE_DIR/arm/baremetal/modules/spi.cpp         \
            $::Syfala::SOURCE_DIR/arm/baremetal/modules/uart.cpp        \
            $::Syfala::SOURCE_DIR/arm/baremetal/modules/tui.cpp        \
        ]
        importsources -name $APPLICATION_NAME -path $::Syfala::SOURCE_DIR/arm/faust
        app config -name $APPLICATION_NAME -add include-path $drivers_path
        importsources -name $APPLICATION_NAME -path $drivers_path
        importsources -name $APPLICATION_NAME -path $::Syfala::SOURCE_DIR/arm/codecs
    }
}


foreach src $sources {
    importsources -name $APPLICATION_NAME \
                  -path $src
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
