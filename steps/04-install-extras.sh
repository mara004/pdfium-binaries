#!/bin/bash -eux

SOURCE="${PDFium_SOURCE_DIR:-pdfium}"
OS="${PDFium_TARGET_OS:?}"
CPU="${PDFium_TARGET_CPU:?}"

pushd "$SOURCE"

case "$OS" in
  linux)
    build/linux/sysroot_scripts/install-sysroot.py "--arch=$CPU"
    ;;

  android)
    sudo dpkg --add-architecture i386
    sudo apt-get update
    sudo apt-get remove -y --purge php7.4-common
    sudo dpkg --configure -a
    sudo apt --fix-broken install
    sudo apt install -y --allow-downgrades libpcre2-8-0=10.34-7
    sudo aptitude install -y libglib2.0-0:i386
    build/install-build-deps-android.sh
    gclient runhooks
    ;;
esac

popd
