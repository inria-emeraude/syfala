# Using syfala containers (with podman)

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
# import image (make sure you have 125+gb of space left on your machine)
$ podman load -i my-container-image.tar
```

### Running container

```shell
# first, allow X11 to share displays with local processes
$ xhost +local:
# check the name of your image (eg. localhost/syfala-x2022-debian11):
$ podman images
# spawn your container (this only needs to be done once, with the board's USB plugged in and powered up)
$ podman run -ti --privileged --name=syfala --group-add=keep-groups --network=host --env DISPLAY -v /tmp/.X11-unix -v /dev/dri -v /dev/bus/usb --device /dev/ttyUSB1 my-container-image /bin/bash 
# once inside the container, you'll have to run:
$ xhost +
# you can now open vitis_hls, vivado, etc.
```

### Respawning container

```shell
# Once you exit the container, you'll have to re-start it first:
$ podman start syfala
# Then, execute the command that you want:
$ podman exec -ti syfala /bin/bash
```

### Committing container to original image, and re-export

```shell
# If you want to report the changes you made in your container on to the original image:
$ podman commit syfala
# And re-export a .tar image:
$ podman save -o syfala-image.tar my-container-image
```

