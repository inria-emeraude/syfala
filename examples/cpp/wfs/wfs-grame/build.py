#!/usr/bin/python

import os
from sys import argv

def run_command(command: str) -> int:
    print(command)
    result_code = os.system(command)
    return result_code

if len(argv) < 2:
    print("Donner en argument : 'full', 'hls', 'arm', 'csim' pour compiler")
    exit(0)

command: str = ""

syfala_dir = "/home/benjamin/Dev/syfala-gitlab"
vitis_include_dir = "/home/benjamin/Xilinx/Vitis_HLS/2024.1/include"

if argv[1] == "full":

    print("building the HLS and ARM files")

    result = run_command("syfala wfs_hls.cpp --board Z20 --multisample 16 --arm-target barre_de_son_arm.cpp --linux --tdm --umo")
    run_command("pushd ../../../Dev/syfala-gitlab && make reports && popd")

    print("attempting to copy the build files to the sd card")
    run_command("sudo cp -r /home/benjamin/Dev/syfala-gitlab/build-linux/root/alpine-3.19.6/alpine-root/root/wfs_hls /run/media/benjamin/root/root/")

    # print("generating test wav file")
    # run_command("julia --startup-file=no wav_generation.jl")

    print("copying test wav file")
    run_command("sudo cp ../demo_romain.wav ../carlsagan.wav /run/media/benjamin/root/root/")

    run_command("sync")

elif argv[1] == "hls":
    run_command("syfala wfs_hls.cpp --hls --board Z20 --multisample 16 --umo")
    os.system("pushd ../../../Dev/syfala-gitlab/ && make reports && popd")

elif argv[1] == "arm":
    includes = " ".join([
        f"-I{syfala_dir}/include",
        f"-I{syfala_dir}/build/syfala_ip/syfala/impl/ip/drivers/syfala_v1_0/src",
        # f"-I{syfala_dir}/build-linux/root/alpine-3.19.6/alpine-root/usr/include",
    ])

    sources = " ".join([
        "barre_de_son_arm.cpp",
        f"{syfala_dir}/source/arm/linux/gpio.cpp",
        f"{syfala_dir}/source/arm/linux/audio.cpp",
        f"{syfala_dir}/source/arm/linux/audio.cpp",
        f"{syfala_dir}/source/arm/linux/memory.cpp"
    ])

    defines = " ".join([
        "-DSYFALA_CONTROL_BLOCK=0",
        "-DSYFALA_FAUST_TARGET=0",
    ])

    command = f"g++ -Wall -Wextra -std=c++14 -Wconversion -Wfloat-conversion -o arm_program {defines} {sources} {includes}"
    run_command(command)

elif argv[1] == "csim":
    command = f"g++ barre_de_son_csim.cpp -O3 -std=c++14 -o csim -I {vitis_include_dir} -I {syfala_dir}/include -D __CSIM__"
    run_command(command)

else:
    print("Donner en argument : 'full', 'hls', 'arm', 'csim' pour compiler")
    exit(0)

