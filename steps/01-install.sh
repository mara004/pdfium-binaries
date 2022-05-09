#!/bin/bash -eux

PATH_FILE=${GITHUB_PATH:-$PWD/.path}
ENV_FILE=${GITHUB_ENV:-.env}
TARGET_OS=${PDFium_TARGET_OS:?}
TARGET_LIBC=${PDFium_TARGET_LIBC:-default}
TARGET_CPU=${PDFium_TARGET_CPU:?}
CURRENT_CPU=${PDFium_CURRENT_CPU:-x64}

DepotTools_URL='https://chromium.googlesource.com/chromium/tools/depot_tools.git'
DepotTools_DIR="$PWD/depot_tools"
WindowsSDK_DIR="/c/Program Files (x86)/Windows Kits/10/bin/10.0.19041.0"

# Download depot_tools if not exists in this location
if [ ! -d "$DepotTools_DIR" ]; then
  git clone "$DepotTools_URL" "$DepotTools_DIR"
fi

echo "$DepotTools_DIR" >> "$PATH_FILE"

case "$TARGET_OS-$TARGET_LIBC-$TARGET_CPU" in
  android-*)
    sudo apt-get update
    sudo apt-get install -y aptitude
    sudo aptitude install -y libglib2.0-dev
    sudo aptitude install -y libglib2.0-0:i386
    ;;

  win-*)
    echo "$WindowsSDK_DIR/$CURRENT_CPU" >> "$PATH_FILE"
    ;;

  linux-default-arm)
    sudo apt-get update
    sudo apt-get install -y g++-arm-linux-gnueabihf
    ;;

  linux-default-arm64)
    sudo apt-get update
    sudo apt-get install -y g++-aarch64-linux-gnu
    ;;

  linux-default-x86)
    sudo apt-get update
    sudo apt-get install -y g++-multilib
    ;;

  linux-musl-x86)
    curl -L https://musl.cc/i686-linux-musl-cross.tgz | tar xz
    echo "$PWD/i686-linux-musl-cross/bin" >> "$PATH_FILE"
    ;;

  linux-musl-x64)
    curl -L https://musl.cc/x86_64-linux-musl-cross.tgz | tar xz
    echo "$PWD/x86_64-linux-musl-cross/bin" >> "$PATH_FILE"
    ;;

  wasm-*)
    git clone https://github.com/emscripten-core/emsdk.git
    pushd emsdk
    ./emsdk install 2.0.24
    ./emsdk activate 2.0.24
    echo "$PWD/upstream/emscripten" >> "$PATH_FILE"
    echo "$PWD/upstream/bin" >> "$PATH_FILE"
    popd
    ;;

esac

if [ "$TARGET_LIBC" == "musl" ]; then
  sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 10
  sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 10
fi