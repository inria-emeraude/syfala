
source source/bd/modules/base_design.tcl
source source/bd/modules/syfala_ip.tcl
# include syfala_ip before i2s_transceiver (see requirement at the beginning of i2s_transceiver.tcl)
# maybe do a function to handle that (with warning messsage?)
source source/bd/modules/transceiver_i2s.tcl
# include onesample or multisample after i2s_transceiver (see requirement at the beginning of i2s_transceiver.tcl)
source source/bd/modules/multisample_bd.tcl
# idéalement, renomer multisample_bd en multisample une fois que ce fichier sera supprimé
source source/bd/modules/spi.tcl
