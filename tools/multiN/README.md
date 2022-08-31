### multiN script

this script allows a Faust DSP file written with an 'N' compile-time variable to be run multiple times with different N values through Vitis HLS. Then, the script collects useful data from the HLS report and concatenates all results in a single file. 

#### usage

```shell
$ ./multiN.tcl <filename> <N list>
# examples:
$ ./multiN.tcl bellN 6 8 16 32 64
$ ./multiN.tcl vbapN 2 4 8 16 32 64 128
```

In the examples above, `multiN.tcl` will call `bellN.tcl` or `vbapN.tcl` individual scripts with an `N-list` argument.