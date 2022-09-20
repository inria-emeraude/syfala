### multiN script

this script allows a Faust DSP file written with an 'N' compile-time variable to be run multiple times with different N values through Vitis HLS. Then, the script collects useful data from the HLS report and concatenates all results in a 'latency' file and a 'utilization' file. 

#### usage

```shell
$ ./multiN.tcl <filename> <board> <N list>
# examples:
$ ./multiN.tcl bellN Z10 6 8 16 32 64
$ ./multiN.tcl vbapN Z20 2 4 8 16 32 64 128
$ ./multiN.tcl firN GENESYS 50 100 200
$ ./multiN.tcl lmsN Z10 30 60 120
```

*Latency* and *Utilization* outputs are written in the *report-outputs*/ directory when script has finished.

#### csv file

The script will also insert the collected results in the *output.csv* file, with the following format:

| File  | Board   | N    | Max cycles | Max latency (usec) | Memory reads | Memory writes | IP/App file generation time (in milliseconds) | High-level synthesis time (in seconds) | BRAM (%) | DSP (%) | FF (%) | LUT (%) | LUT (N) |
| ----- | ------- | ---- | ---------- | ------------------ | ------------ | ------------- | --------------------------------------------- | -------------------------------------- | -------- | ------- | ------ | ------- | ------- |
| echoN | Z10     | 2    | 302        | 2.458              | 4            | 2             | 108                                           | 31                                     | 6        | 10      | 7      | 31      | 6109    |
| echoN | GENESYS | 2    | 270        | 2.197              | 4            | 2             | 104                                           | 27                                     | 1        | 2       | 1      | 6       | 5022    |
