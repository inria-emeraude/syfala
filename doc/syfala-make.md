

### Tests

| Board | Target | HLS source                          | ARM source | Platform  | Multisample | Audio backend(s) | Build status | Audio status | Full command                                                 |
| ----- | ------ | ----------------------------------- | ---------- | --------- | ----------- | ---------------- | ------------ | ------------ | ------------------------------------------------------------ |
| Zybo  | faust  | examples/faust/bypass.dsp           | faust std  | baremetal | 0           | std              | N/A          | N/A          | `syfala examples/faust/bypass.dsp`                           |
| Zybo  | faust  | examples/faust/bypass.dsp           | faust std  | baremetal | 0           | sigma-delta      | N/A          | N/A          | `syfala examples/faust/bypass.dsp --sigma-delta`             |
| Zybo  | faust  | examples/faust/bypass.dsp           | faust std  | baremetal | 0           | TDM              | N/A          | N/A          | `syfala examples/faust/bypass.dsp --tdm`                     |
| Zybo  | faust  | examples/faust/bypass.dsp           | faust std  | baremetal | 16          | std              | N/A          | N/A          | `syfala examples/faust/bypass.dsp --multisample 16`          |
| Zybo  | faust  | examples/faust/bypass.dsp           | faust std  | baremetal | 16          | sigma-delta      | N/A          | N/A          | `syfala examples/faust/bypass.dsp --multisample 16 --sigma-delta` |
| Zybo  | faust  | examples/faust/bypass.dsp           | faust std  | baremetal | 16          | TDM              | N/A          | N/A          | `syfala examples/faust/bypass.dsp --multisample 16 --tdm`    |
| Zybo  | faust  | examples/faust/bypass.dsp           | faust std  | **linux** | 0           | std              | N/A          | N/A          | `syfala examples/faust/bypass.dsp --linux`                   |
| Zybo  | faust  | examples/faust/bypass.dsp           | faust std  | **linux** | 0           | sigma-delta      | N/A          | N/A          | `syfala examples/faust/bypass.dsp --linux --sigma-delta`     |
| Zybo  | faust  | examples/faust/bypass.dsp           | faust std  | **linux** | 0           | TDM              | N/A          | N/A          | `syfala examples/faust/bypass.dsp --linux --tdm`             |
| Zybo  | faust  | examples/faust/bypass.dsp           | faust std  | **linux** | 16          | std              | N/A          | N/A          | `syfala examples/faust/bypass.dsp --linux --multisample 16`  |
| Zybo  | faust  | examples/faust/bypass.dsp           | faust std  | **linux** | 16          | sigma-delta      | N/A          | N/A          | `syfala examples/faust/bypass.dsp --linux --multisample 16 --sigma-delta` |
| Zybo  | faust  | examples/faust/bypass.dsp           | faust std  | **linux** | 16          | TDM              | N/A          | N/A          | `syfala examples/faust/bypass.dsp --linux --multisample 16 --tdm` |
| Zybo  | faust  | examples/faust/bypass.dsp           | faust std  | **linux** | 0           | ethernet std     | N/A          | N/A          | `syfala examples/faust/bypass.dsp --ethernet`                |
| Zybo  | faust  | examples/faust/bypass.dsp           | faust std  | **linux** | 0           | ethernet tdm     | N/A          | N/A          | `syfala examples/faust/bypass.dsp --ethernet --tdm`          |
|       |        |                                     |            |           |             |                  |              |              |                                                              |
| Zybo  | cpp    | examples/cpp/bypass.cpp             | cpp std    | baremetal | 0           | std              | N/A          | N/A          | `syfala examples/cpp/bypass.cpp`                             |
| Zybo  | cpp    | examples/cpp/bypass.cpp             | cpp std    | baremetal | 0           | sigma-delta      | N/A          | N/A          | `syfala examples/cpp/bypass.cpp ---sigma-delta`              |
| Zybo  | cpp    | examples/cpp/bypass.cpp             | cpp std    | baremetal | 0           | TDM              | N/A          | N/A          | `syfala examples/cpp/bypass.cpp --tdm`                       |
| Zybo  | cpp    | examples/cpp/bypass_multisample.cpp | cpp std    | baremetal | 16          | std              | N/A          | N/A          | `syfala examples/cpp/bypass_multisample.cpp --multisample 16` |
| Zybo  | cpp    | examples/cpp/bypass_multisample.cpp | cpp std    | baremetal | 16          | sigma-delta      | N/A          | N/A          | `syfala examples/cpp/bypass_multisample.cpp --multisample 16 --sigma-delta` |
| Zybo  | cpp    | examples/cpp/bypass_multisample.cpp | cpp std    | baremetal | 16          | TDM              | N/A          | N/A          | `syfala examples/cpp/bypass_multisample.cpp --multisample 16 --tdm` |
| Zybo  | cpp    | examples/cpp/bypass.cpp             | cpp std    | **linux** | 0           | std              | N/A          | N/A          | `syfala examples/cpp/bypass.cpp --linux`                     |
| Zybo  | cpp    | examples/cpp/bypass.cpp             | cpp std    | **linux** | 0           | sigma-delta      | N/A          | N/A          | `syfala examples/cpp/bypass.cpp --linux --sigma-delta`       |
| Zybo  | cpp    | examples/cpp/bypass.cpp             | cpp std    | **linux** | 0           | TDM              | N/A          | N/A          | `syfala examples/cpp/bypass.cpp --linux --tdm`               |
| Zybo  | cpp    | examples/cpp/bypass_multisample.cpp | cpp std    | **linux** | 16          | std              | N/A          | N/A          | `syfala examples/cpp/bypass_multisample.cpp --linux --multisample 16` |
| Zybo  | cpp    | examples/cpp/bypass_multisample.cpp | cpp std    | **linux** | 16          | sigma-delta      | N/A          | N/A          | `syfala examples/cpp/bypass_multisample.cpp --linux --multisample 16 --sigma-delta` |
| Zybo  | cpp    | examples/cpp/bypass_multisample.cpp | cpp std    | **linux** | 16          | TDM              | N/A          | N/A          | `syfala examples/cpp/bypass_multisample.cpp`                 |
| Zybo  | cpp    | examples/cpp/bypass.cpp             | cpp std    | **linux** | 0           | ethernet std     | N/A          | N/A          | `syfala examples/cpp/bypass.cpp --ethernet`                  |
| Zybo  | cpp    | examples/cpp/bypass.cpp             | cpp std    | **linux** | 0           | ethernet tdm     | N/A          | N/A          | `syfala examples/cpp/bypass.cpp --ethernet --tdm`            |

### Build targets

#### Main targets

| Target | Dependencies                      |
| ------ | --------------------------------- |
| `all`  | `hw sw`                           |
| `sw`   | `hw` `(linux)` si `LINUX == TRUE` |
| `hw`   | see below                         |

#### hw targets

| Target            | Dependencies      |
| ----------------- | ----------------- |
| `hw`              | `bitstream`       |
| `bitstream`       | `synth`           |
| `synth`           | `project`         |
| `project`         | `hls`             |
| `hls`             | `hls-target-file` |
| `hls-target-file` |                   |

#### linux

| Target       | Dependencies                                             |
| ------------ | -------------------------------------------------------- |
| `linux`      | `linux-boot` `linux-root`                                |
| `linux-boot` | `uboot` `kernel` `device-tree` `bootscript` `bootstream` |
| `linux-root` | ...                                                      |



### Variables (options)

#### 1. XILINX-related options

| Variable          | Values           | Default  | Description              |
| ----------------- | ---------------- | -------- | ------------------------ |
| `XILINX_ROOT_DIR` | path             |          | variable d'environnement |
| `XILINX_VERSION`  | `2020.2, 2022.2` | `2022.2` |                          |

#### 2. TARGET

| Variable | Values        | Default | Description |
| -------- | ------------- | ------- | ----------- |
| `TARGET` | `faust` `cpp` | `faust` |             |

#### 2.1 TARGET - faust

| Variable              | Values   | Default                                 | Description |
| :-------------------- | :------- | :-------------------------------------- | :---------- |
| `FAUST`               | path     | `faust`                                 |             |
| `FAUST_MCD`           | `0 .. N` | `16`                                    |             |
| `FAUST_DSP_TARGET`    | path     | `examples/bypass.dsp`                   |             |
| `FAUST_HLS_ARCH_FILE` | path     | `source/rtl/hls/faust_dsp_template.cpp` |             |
| `FAUST_ARM_ARCH_FILE` | path     | `include/syfala/arm/faust/control.hpp`  |             |

#### 2.2 TARGET - cpp

| Variable           | Values | Default                        | Description |
| ------------------ | ------ | ------------------------------ | ----------- |
| `HLS_CPP_SOURCE`   | path   | `source/rtl/hls/bypass.cpp`    |             |
| `HOST_MAIN_SOURCE` | path   | `source/arm/baremetal/arm.cpp` |             |
| `INPUTS`           | number | 0                              |             |
| `OUTPUTS`          | number | 0                              |             |

#### 3. BOARD target

| Variable                | Values                | Default                                  | Description |
| ----------------------- | --------------------- | ---------------------------------------- | ----------- |
| `BOARD`                 | `Z10` `Z20` `GENESYS` | `Z20`                                    |             |
| `BOARD_CONSTRAINT_FILE` | path                  | `source/constraints/zybo.xdc` (for zybo) |             |

#### 4. Runtime parameters

| Variable          | Values                                   | Default | Description              |
| ----------------- | ---------------------------------------- | ------- | ------------------------ |
| `SAMPLE_RATE`     | `24000 48000 96000 192000 384000 768000` | `48000` |                          |
| `SAMPLE_WIDTH`    | `16` `24` `32`                           | `24`    |                          |
| `MULTISAMPLE`     | `0 .. N[power of two]`                   | `0`     | note: `0` means 1 sample |
| `MEMORY_TARGET`   | `STATIC` `DDR`                           | `DDR`   |                          |
| `CONTROLLER_TYPE` | `DEMO PCB1 PCB2 PCB3 PCB4`               | `PCB1`  |                          |
| `CTRL_MIDI`       | `TRUE FALSE`                             | `FALSE` | not implemented          |
| `CTRL_OSC`        | `TRUE FALSE`                             | `FALSE` | not implemented          |
| `CTRL_HTTP`       | `TRUE FALSE`                             | `FALSE` | not implemented          |

#### 5. Advanced build options

| Variable                          | Values       | Default                           | Description |
| --------------------------------- | ------------ | --------------------------------- | ----------- |
| `LINUX`                           | `TRUE FALSE` | `FALSE`                           |             |
| `CONFIG_EXPERIMENTAL_TDM`         | `TRUE FALSE` | `FALSE`                           |             |
| `CONFIG_EXPERIMENTAL_SIGMA_DELTA` | `TRUE FALSE` | `FALSE`                           |             |
| `CONFIG_EXPERIMENTAL_ETHERNET`    | `TRUE FALSE` | `FALSE`                           |             |
| `PREPROCESSOR_HLS`                | `TRUE FALSE` | depends on other variables        |             |
| `PREPROCESSOR_I2S`                | `TRUE FALSE` | depends on other variables        |             |
| `I2S_SOURCE`                      | path         | `source/rtl/i2s/i2s_template.vhd` |             |
| `BD_TARGET`                       | path         | `source/bd/standard.tcl`          |             |