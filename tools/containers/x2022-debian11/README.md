# Syfala docker image

## Dependencies

- obviously: [docker](https://www.docker.com/) and/or [buildah](https://buildah.io/)/[podman](https://podman.io/)

- enough disk space in docker or podman/buildah storage (the image is 75.6GB large, additional space is probably needed for temporary files) (see [Images and containers storage](images-and-containers-storage.md) to configure an alternate storage)

- enough RAM to run vivado/xilinx. You should have at least 32GB of RAM, or at least RAM + swap should be at least 32GB (if it swaps, you'll likely experience some slowdowns). Experience has shown that some synthesis fail on a system with 16GB RAM and no swap.

- to build the image:

  - git/ssh access to [https://gitlab.inria.fr/risset/syfala-project](https://gitlab.inria.fr/risset/syfala-project) (you need to be member of the project to be able to see it and clone it)

  - for buildah/podman image building: [jq](https://jqlang.github.io/jq/)

- to run the image:

  - `crun` OCI runtime for being able to use podman and control access permissions to devices in `/dev`. The long explanation is that if your development host is running debian, `docker.io` depends on `runc`, the other OCI runtime, so if you install `podman` after docker, it will use `runc` unless you explicitely also install `crun`. The podman command line option `--group-add=keep-groups` will only be effective with `crun`, and we need this option to be effective if your user has permission to access `/dev/ttyUSB<X>` through membership of the `dialout` group (typical debian config) and you want to run the container rootless and give access to these devices in the container. Additionnaly, it seems that running the container in rootless mode with podman and option `--privileged` conflicts with some virtualbox usb devices (if virtualbox is installed. The error is: `Error: crun: error stating file /dev/vboxusb/[...]: Permission denied: OCI permission denied`) and prevents bind mounting of `/dev/ttyUSB<X>` in the container, so to avoid this conflict we need to run the container without `--privileged` (which is not needed anyway).

  - X11 server on the host, for the container to be able to have graphic output. Not yet tested with Wayland

  - Pulseaudio or pipewire on the host, for the container to be able to output sound

## Limitations

- In case you want to access a device from the container, you need to poweron the device before starting the container for the entries in `/dev/` to be correctly created in the container. Also, with podman, if you create the container with the device connected, the container will remember the device entries in `/dev` and will refuse to restart later if these entries are absent (so you'll have to destroy the container and recreate it to be able to run it, or start another container)

## Preparation

- Get a AMD/Xilinx account at [https://www.amd.com/en/registration/create-account.html](https://www.amd.com/en/registration/create-account.html)

### using Xilinx Vivado, Vitis, Vitis HLS 2022.2

- Get `Xilinx_Unified_2022.2_1014_8888_Lin64.bin`, `Xilinx_Vivado_Vitis_Update_2022.2.1_1208_2036.tar.gz`, `Xilinx_Vivado_Vitis_Update_2022.2.2_0221_2201.tar.gz` from [https://www.xilinx.com/support/download.html](https://www.xilinx.com/support/download.html) and put them in a directory of your choice, outside the Dockerfile directory. `Xilinx_Unified_2022.2_1014_8888_Lin64.bin` has a small bug related to /dev/tty access which prevents it to be used directly in the build process, and the updaters are too big to be conveniently included in the build environment (no web installer is provided for the updates). This is why a script will preprocess these installers and updates prior to image build. We'll later refer to the directory where you put these three files as the `INSTALLERS_DIR`

- If needed modify install_config.txt to customize xilinx installation (eg. to add some devices, change the Modules entry, and set the devices you want to add to 1 instead of 0)

## Build

- `make xilinx-installers INSTALLERS_DIR=<directory_where_you_downloaded_the_three_xilinx_packages>`: it will:

  - unpack the web installer in the Dockerfile directory (this step is done prior to build as it is broken when done in a rootless buildah context where `/dev/tty` access is limited).

  - generate small web updaters for `Xilinx_Vivado_Vitis_Update_2022.2.1_1208_2036.tar.gz` and `Xilinx_Vivado_Vitis_Update_2022.2.2_0221_2201.tar.gz` by removing their downloadable content

- `make xilinx-token`: it will generate an AMD/Xilinx auth token for the build process to be able to download xilinx install components (it will ask for your amd/xilinx login/password). There will be a message telling the expiration date of the token (it seems to be one week)

- Then, you can build either images (or even both):

    - For building the docker image: `make docker-image`. Takes around 1.25 hour, may depend on the build machine and the network bandwidth. The resulting image is 75.6GB large.

    - For building the buildah / podman image: `make buildah-image`. Same remarks

- the image is called `syfala-x2022debian11`

- there may be some rare transient network errors (xilinx server overloaded?) while generating the token or at the beginning of the xilinx installation steps. In this situations, simply retry.

## Use

- `make docker-run-once` / `make podman-run-once` to start a container which will be destroyed at exit. The container name will be randomly chosen

- `make docker-run-keep` / `make podman-run-keep` to start or restart a persistent container (by default, the container is named `syfala_cont`. You can change that name by passing option `CONTAINER=<container_name>` to `make docker-run-keep` / `make podman-run-keep`)

## Test

- to test syfala: start the container, and try: `syfala --reset -b Z20 ~/syfala/examples/virtualAnalog.dsp`

- to test graphic output: start the container, and try: `/tools/Xilinx/Vitis_HLS/2022.2/bin/vitis_hls`

- to test sound output: start the container, and try: `apt install pulseaudio-utils && paplay /usr/local/share/faust/smartKeyboard/android/app/oboe/samples/drumthumper/src/main/assets/RideCymbal.wav`. Sound output means that a sound played inside the container is heared on the host.

- to test flashing:

  - connect and power on a Z20 (Zybo Z7 Zynq 7020 dev board)

  - start the container.

  - `syfala --reset -b Z20 ~/syfala/examples/virtualAnalog.dsp`

  - `syfala flash`

  - `syfala gui`
