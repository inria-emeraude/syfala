
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

#set workspace
setws ./build/faust_v6_application

#Plateform
platform create -name {faust_v6_platform}\
    -hw {./build/hw_export/main_wrapper.xsa}\
    -fsbl-target {psu_cortexa53_0} 

platform write

#Domain
domain create -name {standalone_ps7_cortexa9_0} -display-name {standalone_ps7_cortexa9_0} -os {standalone} -proc {ps7_cortexa9_0} -runtime {cpp} -arch {32-bit} -support-app {hello_world}

platform generate -domains 
platform active {faust_v6_platform}
domain active {zynq_fsbl}
domain active {standalone_ps7_cortexa9_0}
platform generate -quick
platform generate

#App
app create -name faust_v6_app -platform faust_v6_platform -domain standalone_ps7_cortexa9_0 -template {Empty Application (C++)} -lang {c++}

app config -name faust_v6_app -add include-path ../src
app config -name faust_v6_app -add include-path /usr/local/include


app config -name faust_v6_app -add libraries {m}
app config -name faust_v6_app -add compiler-misc {-std=c++11}

importsources -name faust_v6_app -path ./src/app -linker-script
importsources -name faust_v6_app -path ./build/faust_v6_application/faust_v6_platform/hw/drivers/faust_v6_v1_0/src
importsources -name faust_v6_app -path ./build/faust_v6_application/generated_src
importsources -name faust_v6_app -path ./configFAUST.h

#app build -name faust_v6_SD
app build -name faust_v6_app


