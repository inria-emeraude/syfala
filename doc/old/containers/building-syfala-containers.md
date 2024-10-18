# Building Xilinx containers

### Installing buildah

- Archlinux: `yay -S buildah`
- Ubuntu: `sudo apt install buildah`

If shell shows these kind of errors: 

```shell
WARN[0000] Reading allowed ID mappings: reading subuid mappings for user "user" and subgid mappings for group "user": no subuid ranges found for user "user" in /etc/subuid
WARN[0000] Found no UID ranges set aside for user "user" in /etc/subuid.
WARN[0000] Found no GID ranges set aside for user "user" in /etc/subgid.
```

do this:

```shell
$ sudo echo "user:10000:65536" >> /etc/subuid
$ sudo echo "user:10000:65536" >> /etc/subgid
```

### Building image & container

```shell
 $ cd xilinx-ubuntu1804
 $ buildah build -f Containerfile -t xilinx-ubuntu1804
 $ buildah from --name xilinx-ubuntu1804-container xilinx-ubuntu1804 
```

### Running container to install the Xilinx toolchain

```bash
$ xhost +local:
$ buildah run --user=syfala --network=host --env DISPLAY=$DISPLAY -v /path/to/Xilinx/installer:/home/syfala -v /tmp/.X11-unix:/tmp/.X11-unix:z -v /dev/dri:/dev/dri:z xilinx-ubuntu1804-container bash
```

Once inside the container:

```shell
# sudo password is 'syfala'
$ xhost +
$ sudo chmod a+x /Xilinx/Xilinx_Unified_2022.2_1014_8888_Lin64.bin
$ ./Xilinx/Xilinx_Unified_2022.2_1014_8888_Lin64.bin
```

The installer window should now appear, you can proceed with the installation.

### Updating & exporting OCI image

Once the installation finished:

```shell
# this may take a while, given the final size of the container
# you need to have more than 100Gb available on your disk as well...
$ buildah commit xilinx-ubuntu1804-container xilinx-ubuntu1804:2022-2
# export image in oci format
$ buildah push --format oci xilinx-ubuntu1804:2022-2 oci:/your/path/xilinx-ubuntu1804-2022-2-oci
```

### Exporting .tar file of image

```shell
$ podman save -o x2022-ubuntu1804.tar localhost/ubuntu1804:2022-2
```

