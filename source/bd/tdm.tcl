
source source/bd/modules/base_design.tcl
source source/bd/modules/syfala_ip.tcl
# include syfala_ip before tdm_transceiver (see requirement at the beginning of tdm_transceiver.tcl)
# maybe do a function to handle that (with warning messsage?)
source source/bd/modules/transceiver_tdm.tcl
source source/bd/modules/onesample.tcl
source source/bd/modules/spi.tcl
