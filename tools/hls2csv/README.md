# hls2csv

Simple utility to generate a .csv file from HLS report data.

## Installing

```shell
cd syfala-project
cargo install --path tools/hls2csv
cargo install mdtable-cli # for markdown-table generation (optional)
hls2csv --help
```

## Usage

```shell
Usage: hls2csv [OPTIONS] [COMMAND]

Commands:
  concat  Concatenate one or several .csv files into a single one
  help    Print this message or the help of the given subcommand(s)

Options:
  -p, --path <path/to/syfala/repository>  Sets input syfala directory
  -o, --output <path>                     Sets .csv file output path
  -l, --label <string>                    Sets a custom label for the report
  -m, --markdown                          Adds .md table generation with mdtable-cli
  -h, --help                              Print help
  -V, --version                           Print version

# Example:
# Run HLS on a Faust .dsp file:
cd syfala-project
./syfala.tcl examples/faust/virtualAnalog.dsp --hls --accurate-use 
# Extract report data to bypass.csv and bypass.md:
hls2csv -o bypass.csv --markdown --label "no-pragmas"
```

## Concatenating reports

```shell
Usage: hls2csv concat [OPTIONS] <List of .csv file paths>...

Arguments:
  <List of .csv file paths>...  Source .csv files to be concatenated

Options:
  -o, --output <path>  Sets .csv file output path
  -h, --help           Print help
  
# Example:
hls2csv results/*.csv -o results.csv
```

## Output format

| Experiment                                   | Date                 | Label                                                      | File              | Board            | Target      | Inputs                   | Outputs                   | Source                                                | DSP_PCT                         | FF_PCT                         | LUT_PCT                         | BRAM_PCT                         | LAT_PCT                       | DSP_N                | FF_N                | LUT_N                | BRAM_N                | LAT_N                          | UMO                                     | NSAMPLES         | SAMPLE_RATE                                   | SAMPLE_WIDTH                                   | FAUST_MCD                           | XVERSION                                               | SYVERSION                                    | SYBRANCH                                    | SYCOMMIT                                    | AUTHOR                                |
| -------------------------------------------- | -------------------- | ---------------------------------------------------------- | ----------------- | ---------------- | ----------- | ------------------------ | ------------------------- | ----------------------------------------------------- | ------------------------------- | ------------------------------ | ------------------------------- | -------------------------------- | ----------------------------- | -------------------- | ------------------- | -------------------- | --------------------- | ------------------------------ | --------------------------------------- | ---------------- | --------------------------------------------- | ---------------------------------------------- | ----------------------------------- | ------------------------------------------------------ | -------------------------------------------- | ------------------------------------------- | ------------------------------------------- | ------------------------------------- |
| *Index of the experiment* (unsigned integer) | *Date of the report* | *Custom label set (or not) with the `--label (-l) option`* | *DSP target file* | *Target board*   | *Faust/Cpp* | *Number of audio inputs* | *Number of audio outputs* | *Report source:  Estimation/Synthesis/Implementation* | *% of DSP resource utilization* | *% of FF resource utilization* | *% of LUT resource utilization* | *% of BRAM resource utilization* | *% of maximum sample latency* | *Number of DSP used* | *Number of FF used* | *Number of LUT used* | *Number of BRAM used* | *Number of computation cycles* | *--unsafe-math-optimizations directive* | *I/O Block size* | *Sample-rate constant of the current project* | *Sample-width constant of the current project* | *(Faust only) Max-copy-delay value* | *Xilinx toolchain version used to generate the report* | *Syfala version used to generate the report* | *Syfala branch used to generate the report* | *Syfala commit used to generate the report* | *Author (user@machine) of the report* |
| 0                                            | 13/03/2024/15:48:54  | "no-optimization"                                          | virtualAnalog.dsp | xc7z020-clg400-1 | Faust       | 0                        | 2                         | Implementation                                        | 15.91                           | 8.03                           | 15.12                           | 8.13                             | 17                            | 35                   | 8545                | 8043                 | 1                     | 464                            | false                                   | 1                | 48000                                         | 24                                             | 0                                   | 2022.2                                                 | 0.8.0                                        | dev/expe                                    | 1dc7ff1bd19daaaf68db58aad003ff64d87e9bba    | pierre-Latitude-7520                  |

## Status

- [x] Extracting latency data from HLS estimate report.
- [x] Extracting resources data from HLS estimate report.
- [x] Extracting resources data from HLS implementation report.
- [ ] Extracting resources data from HLS synthesis report.
- [x] Generating .csv file
    - [x] Append records instead of overwriting file
- [x] Latency %
- [x] Command-line arguments and options (using the `clap` crate)
    - [x] Adding `-p (--path) <syfala-project>` option
    - [x] Adding `-o (--output)` option
    - [x] Help & description
- [x] Add other useful data:
    - [x] File name (bypass.csv)
    - [x] Syfala version
    - [x] Syfala branch
    - [x] Syfala commit
    - [x] Report author
    - [x] Report date
    - [x] Board target
    - [x] Block size
    - [x] Sample rate
    - [x] Sample width
    - [x] unsafe-math-optimizations
    - [x] Faust mcd
    - [ ] Faust fpgamem
    - [x] Number of inputs 
    - [x] Number of outputs
- [x] Add markdown export option
- [ ] Documentation
- [ ] Tests
