# Images and containers storage (linux)

The Syfala images are huge (currently 75GB) because they include the vivado/vitis toolchain.

Docker and Buildah/Podman put images and containers filesystem layers, and other stuff (like images build cache) in various places, mostly in `/var` or in the user's home for Buildah/Podman in rootless mode (which is the default). If you install a development system from scratch and you are aware of that, you can arrange your partitioning to provision enough space in these locations, but it's not always doable nor practical. Also you may use a development system which was not partitioned with this goal in mind (and it may be a pain to re-partition it). Thus you may end up with not enough space for your images and containers.

A solution is to configure Docker and Buildah/Podman to use a particular location for storage, that you know is large enough. It can be an additional hard disk (or part of) that you dedicate for this task (Eg. you can install an additional hard disk in your system, with a dedicated partition for all containers stuff).

Once you know where you want to store everything related to containers, here's how to configure Docker and Buildah/Podman:

## Prepare storage directory

* Let's say you choose to put everything related to containers in the directory `/containers`

* `mkdir /containers`

* `chmod 755 /containers`

* if this directory is a mount point, mount it now (and add the appropriate mount line in `/etc/fstab`) (it can be an encrypted filesystem if needed)

## Docker

* stop the docker daemon: `systemctl stop docker.service`

* if needed remove everything from `/var/lib/docker` (or maybe you can move the content later to the new location, i did not tested it)

* `mkdir /containers/docker`

* `chmod 710 /containers/docker`

* add the following line to the docker configuration file `/etc/docker/daemon.json` (beware, this is strict json, any missing or inappropriate character (Eg. comma) will prevent docker to start):

  `"data-root": "/containers/docker"`

* restart docker: `systemctl start docker.service`

## Buildah/Podman

* if needed add `<YOUR_USENAME>:10000:65536` in `/etc/subuid` and `/etc/subgid` for rootless mode

* if needed remove everything from `/var/lib/containers/` and `$HOME/.local/share/containers` (or maybe you can move the content later to the new location, i did not tested it)

* `mkdir /containers/storage /containers/rootless /containers/tmp`

* `chmod 700 /containers/storage`

* `chmod 1777 /containers/rootless /containers/tmp`

* put the following lines in `/etc/containers/storage.conf` (create it if needed):

```
[storage]
driver = "overlay"
runroot = "/containers/tmp"
graphroot = "/containers/storage"
rootless_storage_path = "/containers/rootless/$USER/storage"
[storage.options]
additionalimagestores = [
]
pull_options = {enable_partial_images = "false", use_hard_links = "false", ostree_repos=""}
[storage.options.overlay]
mountopt = "nodev"
[storage.options.thinpool]
```

* put the following lines in `$HOME/.config/containers/storage.conf` (create it if needed):

```
[storage]
driver = "overlay"
runroot = "/containers/tmp/$USER"
graphroot = "/containers/rootless/$USER/storage"
rootless_storage_path = "/containers/rootless/$USER/storage"
[storage.options]
additionalimagestores = [
]
pull_options = {enable_partial_images = "false", use_hard_links = "false", ostree_repos=""}
[storage.options.overlay]
mountopt = "nodev"
[storage.options.thinpool]
```

* Unfortunately, although we configured the rootless `runroot`, there is still one location that we cannot control from Buildah/Podman configuration files, the temporary storage location which is used in particular when copying filesystem layers from the temporary containers used to build images to the images storage, at each build step. Buildah uses `/var/tmp` as default. It means that even with this configuration, container builds will fail if `/var/tmp` is too small for intermediate filesystem layers (which is likely for vivado/vitis installation step). To force Buildah/Podman to use a dedicated storage location for this temporary storage, we must force TMP_DIR when building an image (this is the way it is done in the build makefile):

```
export TMPDIR="`buildah info | jq -r .store.RunRoot`" && mkdir -p "$TMPDIR" && buildah build [...]
```


