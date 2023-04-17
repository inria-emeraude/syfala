print_info "
-------------------
Usage:
-------------------
\$ syfala <command>
\$ syfala <options> myfaustprogram.dsp <steps> <parameters>

build examples:
---------------
\$ syfala examples/virtualAnalog.dsp
\$ syfala -c VHDL examples/phasor.dsp --export vanalog-vhdl-build
\$ syfala examples/virtualAnalog.dsp --board GENESYS --sample-rate 96000
\$ syfala examples/fm.dsp --hls --report
\$ syfala examples/fm.dsp --board Z20 --hls --export z20-fm-hls-build

-------------------------------------------------------------------------------
Commands
-------------------------------------------------------------------------------
      install: installs this script as a symlink in /usr/bin/
        clean: deletes current build directory
       import: <buildname> sets previously exported .zip build as the current build
       export: <buildname> exports current build as a .zip in the export/ directory
       report: prints HLS report of the current build
         demo: fully builds demo based on default example (virtualAnalog)
        flash: flashes current build onto target device
          gui: executes Faust-generated gui application
 open-project: opens the generated .xpr project with Vivado

command examples:
-----------------
\$ syfala demo
\$ syfala clean
\$ syfala export my-current-build
\$ syfala flash

-------------------------------------------------------------------------------
General Options
-------------------------------------------------------------------------------
           -x: <XILINX_ROOT_DIR>
-c --compiler: \[ HLS* | VHDL \] chooses between HLS & faust2vhdl
                for IP generation.
   --xversion: \[ 2020.2 | 2022.2 \] chooses Xilinx toolchain version
                (2020.2 and 2022.2 only supported for now)
      --reset: resets current build directory before building
               (careful! all files from previous build will be lost)
-------------------------------------------------------------------------------
Run steps
-------------------------------------------------------------------------------
        --all: runs all toolchain build steps (from --arch to --gui) (DEFAULT)
       --arch: uses Faust to generate ip/host .cpp files for HLS and
               Host application compilation
   --hls --ip: runs Vitis HLS on generated ip cpp file
    --project: generates Vivado project
--syn --synth: synthesizes full Vivado project
 --host --app: compiles Host Control Application (ARM)
        --gui: compiles Faust GUI controller
      --flash: flashes boot files on device
     --report: prints HLS report at the end of the run
     --export: <id> exports build to export/ directory at the end of the run

-------------------------------------------------------------------------------
Run parameters
-------------------------------------------------------------------------------
      --memory, -m: \[ DDR*|STATIC \]
       --board, -b: \[ Z10*|Z20|GENESYS \]
     --sample-rate: \[ 48000*|96000|192000|384000|768000 \]
    --sample-width: \[ 16|24*|32 \]
 --controller-type: \[ DEMO|PCB1*|PCB2|PCB3|PCB4 \]
      --ssm-volume: \[ FULL|HEADPHONE|DEFAULT* \]
       --ssm-speed: \[ FAST|DEFAULT* \]

'*' means default parameter value
" 0
