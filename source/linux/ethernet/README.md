# Client
The client is running on the ARM system of the FPGA. To compile the client, use the Makefile and compile with the ethernet flag.


# Server
To run the server, it needs a running [Pipewire](https://pipewire.org/)/[Jack](https://github.com/jackaudio/jack2) audio server on the system.


The latest Rust and Cargo versions should be installed.
The server can just be run by going into `source/ethernet/server` with:
```bash
cargo run -- --help
```
This will print the help dialog for the program.


The server will start and connect to either Pipewire or Jack. If you are using Pipewire and the server has difficulties finding Pipewire, use:

```bash
pw-jack cargo run
```

## shared
the shared directory contains code that is shared between server and client. It has to be present while compiling both
