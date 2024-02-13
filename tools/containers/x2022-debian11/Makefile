IMAGE ?= x2022debian11
CONTAINER ?= syfala_cont
TMP_NAME := $(shell uuidgen)
TMP_CONTAINER ?= syfala_cont_$(TMP_NAME)
NOCACHE ?=
NOCACHE_OPT = $(if $(NOCACHE),--no-cache,)
SHARED_FOLDER = $(CONTAINER).shared_folder
TMP_SHARED_FOLDER = $(TMP_CONTAINER).shared_folder
PODMAN = podman --runtime=crun
SSH_AUTH_SOCK_OPT := $(if $(SSH_AUTH_SOCK),--ssh default=$(SSH_AUTH_SOCK),)
PULSESERVERSTRING != pactl info 2>/dev/null | sed -n 's/Server String: \(.*\)/\1/p'
PULSEOPT := $(if $(PULSESERVERSTRING),-v$(PULSESERVERSTRING):/run/user/0/pulse/native --env PULSE_SERVER=unix:/var/run/user/0/pulse/native,)
DEVICEOPT := $(if $(wildcard /dev/ttyUSB0), --device=/dev/ttyUSB0,) $(if $(wildcard /dev/ttyUSB1), --device=/dev/ttyUSB1,)

docker-image:
	DOCKER_BUILDKIT=1 docker build $(NOCACHE_OPT) --progress=plain $(SSH_AUTH_SOCK_OPT) --network=host -t $(IMAGE) .

buildah-image:
	export TMPDIR="`buildah info | jq -r .store.RunRoot`" && mkdir -p "$$TMPDIR" && buildah bud  $(NOCACHE_OPT) --layers $(SSH_AUTH_SOCK_OPT) -f Dockerfile -t $(IMAGE)

xilinx-token:
	./Xilinx_Unified_2022.2_1014_8888_Lin64/xsetup --batch AuthTokenGen
	mv -f ~/.Xilinx/wi_authentication_key .

xilinx-installers:
	./build-installers "$(INSTALLERS_DIR)"

clean-xilinx-installers:
	rm -rf Xilinx_Unified_2022.2_1014_8888_Lin64 Xilinx_Vivado_Vitis_Update_2022.2.1_1208_2036 Xilinx_Vivado_Vitis_Update_2022.2.2_0221_2201

prepare-run:
	xhost +local:root || true
	mkdir -p $(SHARED_FOLDER)

prepare-keep-run: prepare-run
	mkdir -p "$(SHARED_FOLDER)"

prepare-tmp-run: prepare-run
	mkdir -p "$(TMP_SHARED_FOLDER)"

docker-run-keep: prepare-keep-run
	docker start -ai $(CONTAINER) 2>/dev/null || docker run --name $(CONTAINER) -ti --privileged --env DISPLAY -v /dev/bus/usb:/dev/bus/usb $(PULSEOPT) $(DEVICEOPT) -v "$(shell realpath $(SHARED_FOLDER))":"/root/$(SHARED_FOLDER)" -v "$$SSH_AUTH_SOCK:/ssh.socket" -e "SSH_AUTH_SOCK=/ssh.socket" --network=host $(IMAGE)

docker-run-once: prepare-tmp-run
	docker run --rm --name $(TMP_CONTAINER) -ti --privileged --env DISPLAY -v /dev/bus/usb:/dev/bus/usb $(PULSEOPT) $(DEVICEOPT) -v "$(shell realpath $(TMP_SHARED_FOLDER))":"/root/$(TMP_SHARED_FOLDER)" -v "$$SSH_AUTH_SOCK:/ssh.socket" -e "SSH_AUTH_SOCK=/ssh.socket" --network=host $(IMAGE)
	rmdir "$(TMP_SHARED_FOLDER)" 2>/dev/null || true

podman-run-keep: prepare-keep-run
	$(PODMAN) start -ai $(CONTAINER) 2>/dev/null || $(PODMAN) run --name $(CONTAINER) -ti --env DISPLAY -v /dev/bus/usb:/dev/bus/usb $(PULSEOPT) --group-add=keep-groups $(DEVICEOPT) -v "$(shell realpath $(SHARED_FOLDER))":"/root/$(SHARED_FOLDER)" -v "$$SSH_AUTH_SOCK:/ssh.socket" -e "SSH_AUTH_SOCK=/ssh.socket" --network=host $(IMAGE)

podman-run-once: prepare-tmp-run
	$(PODMAN) run --rm --name $(TMP_CONTAINER) -ti --env DISPLAY -v /dev/bus/usb:/dev/bus/usb $(PULSEOPT) --group-add=keep-groups $(DEVICEOPT) -v "$(shell realpath $(TMP_SHARED_FOLDER))":"/root/$(TMP_SHARED_FOLDER)" -v "$$SSH_AUTH_SOCK:/ssh.socket" -e "SSH_AUTH_SOCK=/ssh.socket" --network=host $(IMAGE)
	rmdir "$(TMP_SHARED_FOLDER)" 2>/dev/null || true
