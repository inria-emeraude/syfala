FROM debian:bullseye
WORKDIR /root
ENV DEBIAN_FRONTEND=noninteractive
ENV APT="apt-get -q -y"
RUN echo "deb http://deb.debian.org/debian bullseye main non-free contrib\ndeb http://deb.debian.org/debian-security bullseye-security main non-free contrib\ndeb http://deb.debian.org/debian bullseye-updates main non-free contrib\ndeb http://deb.debian.org/debian bullseye-backports main non-free contrib" > /etc/apt/sources.list
RUN ${APT} update && ${APT} dist-upgrade

RUN ${APT} install git libncurses5 libtinfo-dev build-essential default-jre pkg-config g++-multilib gtk+2.0 cmake locales python3 xz-utils zip
RUN ${APT} install libmicrohttpd-dev liblo-dev
RUN ${APT} install bison flex libssl-dev bc u-boot-tools cpio libyaml-dev curl kmod squashfs-tools qemu-user-static gcc-arm-none-eabi

RUN mkdir /root/.Xilinx
COPY Xilinx_Unified_2022.2_1014_8888_Lin64 /root/Xilinx_Unified_2022.2_1014_8888_Lin64
COPY install_config.txt /root/.Xilinx/
COPY wi_authentication_key /root/.Xilinx/
RUN ./Xilinx_Unified_2022.2_1014_8888_Lin64/xsetup --batch Install --agree XilinxEULA,3rdPartyEULA -c /root/.Xilinx/install_config.txt
ENV XILINX_ROOT_DIR=/tools/Xilinx
COPY Xilinx_Vivado_Vitis_Update_2022.2.1_1208_2036 /root/Xilinx_Vivado_Vitis_Update_2022.2.1_1208_2036
COPY Xilinx_Vivado_Vitis_Update_2022.2.2_0221_2201 /root/Xilinx_Vivado_Vitis_Update_2022.2.2_0221_2201
RUN ./Xilinx_Vivado_Vitis_Update_2022.2.1_1208_2036/xsetup --batch Update --agree XilinxEULA,3rdPartyEULA
RUN ./Xilinx_Vivado_Vitis_Update_2022.2.2_0221_2201/xsetup --batch Update --agree XilinxEULA,3rdPartyEULA

RUN ${APT} install locales
RUN sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/' /etc/locale.gen
RUN locale-gen

RUN ${APT} install udev wget unzip
RUN cd ${XILINX_ROOT_DIR}/Vivado/2022.2/data/xicom/cable_drivers/lin64/install_script/install_drivers && ./install_drivers
RUN wget https://github.com/Digilent/vivado-boards/archive/master.zip
RUN unzip master.zip
RUN cp -a /root/vivado-boards-master/new/board_files/* ${XILINX_ROOT_DIR}/Vivado/2022.2/data/xhub/boards/XilinxBoardStore/boards/Xilinx/

RUN rm -rf Xilinx_Unified_2022.2_1014_8888_Lin64 Xilinx_Unified_2022.2_1014_8888_Lin64.bin Xilinx_Vivado_Vitis_Update_2022.2.1_1208_2036 Xilinx_Vivado_Vitis_Update_2022.2.2_0221_2201 master.zip vivado-boards-master/

RUN git clone https://github.com/grame-cncm/faust.git
RUN cd faust && make -j $(getconf _NPROCESSORS_ONLN) && make install

RUN ${APT} install tcl sudo xvfb libasound2-dev
RUN mkdir -p -m 0700 ~/.ssh && ssh-keyscan gitlab.inria.fr >> ~/.ssh/known_hosts
#RUN --mount=type=ssh,required=true git clone git@gitlab.inria.fr:risset/syfala-project.git syfala
#RUN cd syfala && git checkout main-dev
#RUN sed -i 's/variable VERSION 2020.2/variable VERSION 2022.2/' syfala/syfala.tcl
#RUN cd syfala && ./syfala.tcl install
