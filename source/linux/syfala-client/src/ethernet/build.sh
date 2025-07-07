#!/bin/bash
build="debug"
flag=""
# Iterate over command-line arguments
for arg in "$@"; do
    if [ "$arg" == "--release" ]; then
        build="release"
        flag="--release"
        echo "Building in release mode..."
        break
    fi
done

if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]]; then
  echo "Building on aarch64..."
	export CROSS_TARGET_ARM_UNKNOWN_LINUX_MUSLEABIHF_IMAGE=dscso/arm-unknown-linux-musleabihf
	export CROSS_TARGET_ARM_UNKNOWN_LINUX_MUSLEABIHF_IMAGE_TOOLCHAIN="aarch64-unknown-linux-gnu"
fi
rm -f ../target/arm-unknown-linux-musleabihf/$build/client
cross build --target arm-unknown-linux-musleabihf $flag

# catch compilation error
if [[ $? != 0 ]]; then
  echo "Compilation failed."
  exit 1
fi


if [[ $1 == "run" ]]; then
  IP=$2
  if [[ $IP == "" ]]; then
    echo "Please provide an IP address to run the client on."
    exit 1
  fi
  if [[ $SERVER == "" ]]; then
    echo "Remember to set SERVER environment variable."
  fi

ssh $IP /bin/sh -c 'killall client; killall -9 client; rm -f ~/client;'
scp ../target/arm-unknown-linux-musleabihf/$build/client $IP:~/client
ssh $IP /bin/sh -c "killall client; RUST_BACKTRACE='$RUST_BACKTRACE' ~/client --server $SERVER;"
fi