# C++ WFS

This is a handwritten C++ code for Wave Field Synthesis in Syfala.

For additional information on WFS, you can refer to the README in `examples/faust/wfs`.

This application should be compiled with:

```
./syfala.tcl examples/cpp/wfs/wfs.cpp --arm-target examples/cpp/wfs/wfs-arm.cpp --board Z20 --tdm --ethernet --http --no-ethernet-output --multisample 16
```

It is currently configured to take 4 sources but tens of sources and hundreds of speakers can be potentially used.

The `interface` folder contains a processing application implementing an interface to control the system through OSC. It allows us to change the position of 4 sources in space. Processing must be installed on your system in order to run it.

`wfs-demo.cpp` contains "leftovers" of previous approaches that we took, just for the memo. For instance, we tried to implement delay lines using a modulo operation but this seemed to create problems with HLS. Similarly, we tried to shift the content of a buffer to implement a delay line but this seems to be slower than the approach taken in `wfs.cpp` where a ring buffer is implemented with a bit shift and a power of 2 buffer.
