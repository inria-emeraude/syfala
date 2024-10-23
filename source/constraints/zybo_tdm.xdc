##Clock signal
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports { board_clk }]; #IO_L12P_T1_MRCC_35 Sch=sysclk
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { board_clk }];

##Switches
set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports { switches[0] }]; #IO_L19N_T3_VREF_35 Sch=sw[0]
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { switches[1] }]; #IO_L24P_T3_34 Sch=sw[1]
set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports { switches[2] }]; #IO_L24P_T3_34 Sch=sw[1]
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { switches[3] }]; #IO_L24P_T3_34 Sch=sw[1]

## Buttons
set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [get_ports { btn[0] }]; #IO_L12N_T1_MRCC_35 Sch=btn[0]
set_property -dict { PACKAGE_PIN P16   IOSTANDARD LVCMOS33 } [get_ports { btn[1] }]; #IO_L24N_T3_34 Sch=btn[1]
set_property -dict { PACKAGE_PIN K19   IOSTANDARD LVCMOS33 } [get_ports { btn[2] }]; #IO_L24N_T3_34 Sch=btn[1]
set_property -dict { PACKAGE_PIN Y16   IOSTANDARD LVCMOS33 } [get_ports { btn[3] }]; #IO_L24N_T3_34 Sch=btn[1]

# RGB LED 6
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { rgb_led[0] }]; #IO_L18P_T2_34 Sch=led6_r
set_property -dict { PACKAGE_PIN F17   IOSTANDARD LVCMOS33 } [get_ports { rgb_led[1] }]; #IO_L6N_T0_VREF_35 Sch=led6_g
set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { rgb_led[2] }]; #IO_L8P_T1_AD10P_35 Sch=led6_b

## LEDs
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { green_leds[0] }]; #IO_L23P_T3_35 Sch=led[0]
set_property -dict { PACKAGE_PIN M15   IOSTANDARD LVCMOS33 } [get_ports { green_leds[1] }]; #IO_L23N_T3_35 Sch=led[1]
set_property -dict { PACKAGE_PIN G14   IOSTANDARD LVCMOS33 } [get_ports { green_leds[2] }]; #IO_0_35 Sch=led[2]
set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports { green_leds[3] }]; #IO_L3N_T0_DQS_AD1N_35 Sch=led[3]

## Audio Codec
set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS33 } [get_ports { internal_codec_bclk }]; #IO_0_34 Sch=ac_bclk
set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { internal_codec_mclk }]; #IO_L19N_T3_VREF_34 Sch=ac_mclk
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { internal_codec_out_mute }]; #IO_L23N_T3_34 Sch=ac_muten
#set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { internal_codec_sd_tx }]; #IO_L20N_T3_34 Sch=ac_pbdat
set_property -dict { PACKAGE_PIN T19   IOSTANDARD LVCMOS33 } [get_ports { internal_codec_ws_tx }]; #IO_25_34 Sch=ac_pblrc
set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { internal_codec_sd_rx }]; #IO_L19P_T3_34 Sch=ac_recdat
set_property -dict { PACKAGE_PIN Y18   IOSTANDARD LVCMOS33 } [get_ports { internal_codec_ws_rx }]; #IO_L17P_T2_34 Sch=ac_reclrc
#set_property -dict { PACKAGE_PIN N18   IOSTANDARD LVCMOS33 } [get_ports { sclk }]; #IO_L13P_T2_MRCC_34 Sch=ac_scl
#set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { sdin }]; #IO_L23P_T3_34 Sch=ac_sda
set_property -dict { PACKAGE_PIN N18   IOSTANDARD LVCMOS33   PULLUP true } [get_ports { IIC_0_scl_io }]; #IO_L13P_T2_MRCC_34 Sch=ac_scl
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33   PULLUP true  } [get_ports { IIC_0_sda_io }]; #IO_L23P_T3_34 Sch=ac_sda

##Pmod Header JE 3.3V
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { spi_SS }]; #IO_L4P_T0_34 Sch=je[1]
set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports { spi_MOSI }]; #IO_L18N_T2_34 Sch=je[2]
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { spi_MISO }]; #IO_25_35 Sch=je[3]
set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { spi_clk }]; #IO_L19P_T3_35 Sch=je[4]
set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports { syfala_out_debug0  }]; #IO_L3N_T0_DQS_34 Sch=je[7]
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { syfala_out_debug1  }]; #IO_L9N_T1_DQS_34 Sch=je[8]
set_property -dict { PACKAGE_PIN T17   IOSTANDARD LVCMOS33 } [get_ports { syfala_out_debug2  }]; #IO_L20P_T3_34 Sch=je[9]
set_property -dict { PACKAGE_PIN Y17   IOSTANDARD LVCMOS33 } [get_ports { syfala_out_debug3 }]; #IO_L7N_T1_34 Sch=je[10]

##Pmod Header JD 3.3V

set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { port_sd_tx_3 }];
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports { port_sd_tx_2 }];
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { port_sd_tx_1 }];
set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33 } [get_ports { port_sd_tx_0 }];
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { port_tdm_ws }];
set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports { port_tdm_sclk }];
#set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports {  }];
#set_property -dict { PACKAGE_PIN V18   IOSTANDARD LVCMOS33 } [get_ports {  }];



##Pmod Header JC 3.3V
#set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33     } [get_ports { CODEC1_mclk }];
#set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33     } [get_ports { CODEC1_mclk_GND }];
#set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33     } [get_ports { CODEC1_ws }];
#set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33     } [get_ports { CODEC1_ws_GND }];
#set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33     } [get_ports { CODEC1_sd_rx }];
#set_property -dict { PACKAGE_PIN Y14   IOSTANDARD LVCMOS33     } [get_ports { CODEC2_sd_rx }];
#set_property -dict { PACKAGE_PIN T12   IOSTANDARD LVCMOS33     }  [get_ports { CODEC1_mclk }];
#set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33     }  [get_ports { CODEC1_mclk_GND }];

##Pmod Header JB (Zybo Z7-20 only) 3.3V
#set_property -dict { PACKAGE_PIN V8    IOSTANDARD LVCMOS33     } [get_ports { CODEC10_sd_rx }];
#set_property -dict { PACKAGE_PIN W8    IOSTANDARD LVCMOS33     } [get_ports { CODEC10_sd_tx }];
#set_property -dict { PACKAGE_PIN U7    IOSTANDARD LVCMOS33     } [get_ports { CODEC11_sd_rx }];
#set_property -dict { PACKAGE_PIN V7    IOSTANDARD LVCMOS33     } [get_ports { CODEC11_sd_tx }];
#set_property -dict { PACKAGE_PIN Y7    IOSTANDARD LVCMOS33     } [get_ports { CODEC12_sd_rx }];
#set_property -dict { PACKAGE_PIN Y6    IOSTANDARD LVCMOS33     } [get_ports { CODEC12_sd_tx }];
#set_property -dict { PACKAGE_PIN V6    IOSTANDARD LVCMOS33     } [get_ports { CODEC13_sd_rx }];
#set_property -dict { PACKAGE_PIN W6    IOSTANDARD LVCMOS33     } [get_ports { CODEC13_sd_tx }];


##Pmod Header JA (XADC) 3.3V
#set_property -dict { PACKAGE_PIN N15   IOSTANDARD LVCMOS33 } [get_ports { CODEC6_sd_rx }];
#set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS33 } [get_ports { CODEC6_sd_tx }];
#set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { CODEC7_sd_rx }];
#set_property -dict { PACKAGE_PIN K14   IOSTANDARD LVCMOS33 } [get_ports { CODEC7_sd_tx }];
#set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports { CODEC8_sd_rx }];
#set_property -dict { PACKAGE_PIN L15   IOSTANDARD LVCMOS33 } [get_ports { CODEC8_sd_tx }];
#set_property -dict { PACKAGE_PIN J16   IOSTANDARD LVCMOS33 } [get_ports { CODEC9_sd_rx }];
#set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports { CODEC9_sd_tx }];
