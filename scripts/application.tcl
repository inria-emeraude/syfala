
# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct /home/maxime/vitis_workspace/plateform_ddr_v6_1/platform.tcl
# 
# OR launch xsct and run below command.
# source /home/maxime/vitis_workspace/plateform_ddr_v6_1/platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.
#
# Doc: https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_2/ug1400-vitis-embedded.pdf
# Doc(old): https://www.xilinx.com/html_docs/xilinx2019_1/SDK_Doc/xsct/sdk/reference_xsct_sdk.html
# Doc(new): https://www.xilinx.com/html_docs/xilinx2020_2/vitis_doc/lnw1585821549819.html
############## File based on copie from vitis project plateform (path changed)
source ../scripts/sylib.tcl
namespace import Syfala::*

set CONFIG [lindex $argv 0]

set BOARD [lindex $argv 1]
if { $BOARD == "Z10" || $BOARD == "Z20" } {
  set arch "32-bit"
  set domain_name "standalone_ps7_cortexa9_0"
  set proc_name "ps7_cortexa9_0"
} elseif { $BOARD == "GENESYS" } {
  set arch "64-bit"
  set domain_name "standalone_psu_cortexa53_0"
  set proc_name "psu_cortexa53_0"
} else {
     print_error "Invalid Zybo version, aborting..."
     exit 2;
}



# Set workspace
setws $::Syfala::BUILD_APPLICATION_DIR

set PLATFORM_NAME     "platform"
set APPLICATION_NAME  "application"

# Create platform
platform create -name $PLATFORM_NAME	\
    -hw hw_export/main_wrapper.xsa	\
    -arch $arch\
    -fsbl-target "psu_cortexa53_0" ;#always psu_cortexa53_0, even for Zybo. Don't understand why...

platform write

# Create domain
domain create -name $domain_name            \
              -display-name $domain_name    \
              -os "standalone"              \
              -proc $proc_name              \
              -runtime "cpp"                \
              -arch $arch                   \
              -support-app "hello_world"


# Generate platform
platform generate -domains 
platform active $PLATFORM_NAME

if { $BOARD == "Z10" || $BOARD == "Z20" } {
  domain active {zynq_fsbl}
} elseif { $BOARD == "GENESYS" } {
  domain active {zynqmp_fsbl}
	domain active {zynqmp_pmufw}
} else {
	print_error "Invalid Zybo version, aborting..."
	exit 2;
}

domain active $domain_name
platform generate -quick
platform generate

# Create application
app create -name $APPLICATION_NAME -platform $PLATFORM_NAME     \
           -domain $domain_name                  								\
           -template "Empty Application (C++)"                  \
	   -lang "c++"

# Note: this implies that user has a faust installation
# in /usr/local/include, which is not good..
# but, then again, its waaay better than having to include /usr/include
# because that just doesn't work...
# what to do...?
app config -name $APPLICATION_NAME -add include-path "/usr/local/include"
app config -name $APPLICATION_NAME -add include-path $::Syfala::BUILD_INCLUDE_DIR
app config -name $APPLICATION_NAME -add libraries "m"
app config -name $APPLICATION_NAME -add compiler-misc "-std=c++14"

importsources -name $APPLICATION_NAME -path $::Syfala::SOURCE_DIR/arm

if { $BOARD == "Z10" || $BOARD == "Z20" } {
importsources -name $APPLICATION_NAME -path $::Syfala::SOURCE_DIR/arm/linkers/linker_zybo -linker-script
} elseif { $BOARD == "GENESYS" } {
importsources -name $APPLICATION_NAME -path $::Syfala::SOURCE_DIR/arm/linkers/linker_genesys -linker-script
} else {
	print_error "Invalid Zybo version, aborting..."
	exit 2;
}

importsources -name $APPLICATION_NAME -path $::Syfala::BUILD_APPLICATION_DIR/syfala_application.cpp

if { $CONFIG == 1 } {
    importsources -name $APPLICATION_NAME -path $::Syfala::BUILD_APPLICATION_DIR/$PLATFORM_NAME/hw/drivers/syfala_v1_0/src
}

#app build -name faust_v6_SD
app build -name $APPLICATION_NAME


