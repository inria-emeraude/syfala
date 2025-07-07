# Client for ethernet

## Compilation
you can either compile the client directly in the environment of the Alpine using chroot, or using the rust cross compilation toolchain:

### chroot

start the shell:
```bash
syfala linux chroot
```
in the chroot shell:
```bash
cargo --config 'net.git-fetch-with-cli = true' build
```

### cross compilation toolchain (Recommended)
install the rust toolchain
```
sudo apt install cargo
```
install the [cross compile](https://github.com/cross-rs/cross) toolchain
```bash
cargo install cross
```
build for the ARM using podman as backend
```bash
CROSS_CONTAINER_ENGINE=podman cross build
```

Using chroot generates much smaller binaries... Cross is much faster and does not increase the image size. 