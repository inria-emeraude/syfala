fatload ${devtype} ${devnum}:${distro_bootpart} 0x00200000 uImage;
fatload ${devtype} ${devnum}:${distro_bootpart} 0x00e00000 system.dtb;
fatload ${devtype} ${devnum}:${distro_bootpart} 0x4000000 system.bit
fpga loadb 0 0x4000000 ${filesize}
bootm 0x00200000 - 0x00e00000
exit;
