# Using syfala containers

### Installing podman

- Archlinux: `yay -S podman`
- Ubuntu: `sudo apt install podman`
- macOS: `brew install podman`

If shell shows these kind of errors: 

```shell
WARN[0000] Reading allowed ID mappings: reading subuid mappings for user "user" and subgid mappings for group "user": no subuid ranges found for user "user" in /etc/subuid
WARN[0000] Found no UID ranges set aside for user "user" in /etc/subuid.
WARN[0000] Found no GID ranges set aside for user "user" in /etc/subgid.
```

do this (replace `user` by your username):

```shell
$ sudo echo "user:10000:65536" >> /etc/subuid
$ sudo echo "user:10000:65536" >> /etc/subgid
```

### Importing image

The image is a directory with a specific structure, it is named `x2022-ubuntu1804` in our case.

```shell
$ cd /path/to/parent/directory/of/image
# import image (make sure you have 100+gb of space left on your machine)
$ podman load -i x2022-ubuntu1804.tar
```

### Running container

#### without display

```shell
$ podman run -ti --user=syfala --network=host -v /dev/bus/usb:/dev/bus/usb -v /dev/ttyUSB1:/dev/ttyUSB1:z x2022-ubuntu1804 /bin/bash 
```

#### with display (required for Vivado/Vitis GUI, and for the Faust UART GUI application):

```shell
# first, allow X11 to share displays with local processes
$ xhost +local:
$ podman run -ti --user=syfala --network=host --env DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:z -v /dev/dri:/dev/dri:z -v /dev/bus/usb:/dev/bus/usb -v /dev/ttyUSB1:/dev/ttyUSB1:z x2022-ubuntu1804 /bin/bash 
# once inside the container, you'll have to run:
$ xhost +
# you can now open vitis_hls, vivado, etc.
```

#### running with chroot permissions to build the alpine-linux rootfs

you'll just have to add `--privileged` to the `podman run [...]` command.

### Notes:

- `-ti` = `--tty + --interactive`
- `--user=syfala` - means you connect to the container as the user `syfala` (already registered), you can change that to `user=root` if needed.
- `--network=host` - not really sure yet why it's needed...
- `--env DISPLAY=$DISPLAY` - needed to share your X11 display ID
- `-v /tmp/.X11-unix:/tmp/.X11-unix:z` - needed to share your X11 display
- `-v /dev/dri:/dev/dri:z` - same
- `-v /dev/bus/usb:/dev/bus/usb` - needed in order to flash bitstream & application
- `-v /dev/ttyUSB1:/dev/ttyUSB1` - needed in order to use the Faust GUI-UART application 
- `x2022-ubuntu1804-ctn` - the name of the container you spawned from the image
- `bash` - it will open a bash session when accessing the container, you can replace that by any binary that you want to start

### TODOs:

- [ ] macOS support through VNC (or XQuartz ?)
- [ ] Windows support?

