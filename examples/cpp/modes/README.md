# Basic Modal Model Based on Biquads

* `modes.m` is used to generate `coefs.h`
* `coefs.h` containes the poles (a-s) of the biaquads
* Currently, modes frequencies are:

```
nModes = 10000;
f = (1:nModes)*2+500;
```

which doesn't really make any sense: it's just for the sake of the example.

* The example should be compiled with:

```
./syfala.tcl examples/cpp/modes/modes_multisample.cpp --multisample 32 --board Z20
```

* 8000 synthesized modes seems to be a safe limit in the current scenario...
