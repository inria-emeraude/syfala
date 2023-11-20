### multiN2.tcl

```shell
$ cd tools/multiN
$ ./multiN2.tcl <target.cpp|target.dsp> 
				-b <Z10|Z20|GENESYS> 
				-N 2 4 6 8
				[--reset]
				[--mcd #]
				[--multisample #]		
                [--umo]
```

example:

```shell
$ cd tools/multiN
$ ./multiN2.tcl ../../examples/cpp/fir_multisample.cpp --board Z20 -N 4 8 16 --multisample 16 --reset
# '--reset' will overwrite all reports written in the '../../reports/fir_multisample' directory
```

#### Outputs:

```
../../reports/fir_multisample/performance.txt
../../reports/fir_multisample/latency.txt
../../reports/fir_multisample/resources.txt
../../reports/fir_multisample/fir_multisample.csv
```