# Modal Reverb

Modal reverbs are computationally expensive, but not so much on an FPGA... `modal-reverb.cpp` should be compiled with the following options:

```
./syfala.tcl examples/cpp/modes/modal-reverb.cpp --multisample 32 --board Z20
```

It takes an audio input (by default from the SSM codec on the Zybo board), sends it to a stereo modal reverb implemented with biquad filters in parallel and sends the result to the default stereo output of the system.

`coefs.h` is generated using `matlab/ir2modes-good.m` which takes an impulse response as an output and produces biquad coefficients in return. To do so, it relies on Orchi Das' amazing library <https://github.com/orchidas/Modal-estimation/tree/main>.

With the current configuration, about 5000 modes (2500 for each hear) are synthesized but the current code can synthesized up to 10000 modes on a Zybo Z20.

The other files in the `matlab` folder are just here for fun...
