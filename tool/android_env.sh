#!/usr/bin/env bash
# Source this before cross-compiling the Rust crate for Android.
#
#   source tool/android_env.sh
#   cargo build --lib --target aarch64-linux-android
#
# Mirrors Sage's own CI: NDK r26d, bindgen-cli on PATH, aws-lc-rs/bindgen.
# minSdk 24 (matches android/build.gradle).

set -u

ANDROID_API="${ANDROID_API:-24}"
NDK_VERSION="${NDK_VERSION:-26.3.11579264}" # r26d
NDK="${ANDROID_NDK_HOME:-$HOME/Library/Android/sdk/ndk/$NDK_VERSION}"

if [ ! -d "$NDK" ]; then
  echo "Android NDK not found at $NDK" >&2
  return 1 2>/dev/null || exit 1
fi

HOST_TAG="darwin-x86_64" # NDK ships only this prebuilt dir, runs fine on Apple Silicon
NDK_BIN="$NDK/toolchains/llvm/prebuilt/$HOST_TAG/bin"

export ANDROID_NDK_HOME="$NDK"
export ANDROID_NDK="$NDK"
export ANDROID_NDK_ROOT="$NDK"
export NDK_HOME="$NDK"
export PATH="$NDK_BIN:$HOME/.cargo/bin:$PATH"

# AWS-LC's bundled CMake declares cmake_minimum_required < 3.5; CMake 4 needs this.
export CMAKE_POLICY_VERSION_MINIMUM="${CMAKE_POLICY_VERSION_MINIMUM:-3.5}"

# Per-target C toolchain for the `cc`/`cmake` build scripts (aws-lc-sys, ring,
# libsqlite3, blst...). Underscore form so `export` is valid in zsh/bash; the
# `cc` crate normalizes the triple to this form.
for triple in aarch64_linux_android x86_64_linux_android i686_linux_android; do
  case "$triple" in
    aarch64_linux_android)  clang="aarch64-linux-android${ANDROID_API}-clang" ;;
    x86_64_linux_android)   clang="x86_64-linux-android${ANDROID_API}-clang" ;;
    i686_linux_android)     clang="i686-linux-android${ANDROID_API}-clang" ;;
  esac
  export "CC_${triple}=$NDK_BIN/$clang"
  export "CXX_${triple}=$NDK_BIN/${clang}++"
  export "AR_${triple}=$NDK_BIN/llvm-ar"
  export "RANLIB_${triple}=$NDK_BIN/llvm-ranlib"
done

# armv7 has a different clang prefix (armv7a-...-eabi).
export "CC_armv7_linux_androideabi=$NDK_BIN/armv7a-linux-androideabi${ANDROID_API}-clang"
export "CXX_armv7_linux_androideabi=$NDK_BIN/armv7a-linux-androideabi${ANDROID_API}-clang++"
export "AR_armv7_linux_androideabi=$NDK_BIN/llvm-ar"
export "RANLIB_armv7_linux_androideabi=$NDK_BIN/llvm-ranlib"

# aws-lc-sys runs `bindgen` (libclang) directly — it does NOT go through the
# `cc` crate, so it never gets the Android --target/--sysroot and fails with
# "stdlib.h file not found". bindgen reads BINDGEN_EXTRA_CLANG_ARGS_<target>
# (underscore form is recognized and shell-exportable). Give it the NDK sysroot
# and target per ABI so it parses AWS-LC's headers for Android, not the host.
# This is also why Cargokit/Gradle builds need this script sourced first.
SYSROOT="$NDK/toolchains/llvm/prebuilt/$HOST_TAG/sysroot"
export "BINDGEN_EXTRA_CLANG_ARGS_aarch64_linux_android=--sysroot=$SYSROOT --target=aarch64-linux-android${ANDROID_API}"
export "BINDGEN_EXTRA_CLANG_ARGS_x86_64_linux_android=--sysroot=$SYSROOT --target=x86_64-linux-android${ANDROID_API}"
export "BINDGEN_EXTRA_CLANG_ARGS_i686_linux_android=--sysroot=$SYSROOT --target=i686-linux-android${ANDROID_API}"
export "BINDGEN_EXTRA_CLANG_ARGS_armv7_linux_androideabi=--sysroot=$SYSROOT --target=armv7a-linux-androideabi${ANDROID_API}"

# Cargo linkers.
export CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER="$NDK_BIN/aarch64-linux-android${ANDROID_API}-clang"
export CARGO_TARGET_ARMV7_LINUX_ANDROIDEABI_LINKER="$NDK_BIN/armv7a-linux-androideabi${ANDROID_API}-clang"
export CARGO_TARGET_X86_64_LINUX_ANDROID_LINKER="$NDK_BIN/x86_64-linux-android${ANDROID_API}-clang"
export CARGO_TARGET_I686_LINUX_ANDROID_LINKER="$NDK_BIN/i686-linux-android${ANDROID_API}-clang"

# Google Play 16 KB page-size requirement (effective 2025-11-01 for apps targeting
# Android 15+): all .so files on 64-bit ABIs must have LOAD segments aligned to
# 16384. Rust's Android linker still defaults to 4 KB, so libsage_flutter_binding.so
# fails the check; pass -Wl,-z,max-page-size=16384 via RUSTFLAGS. Cargokit reads
# CARGO_ENCODED_RUSTFLAGS and appends its libgcc workaround (US=0x1f separator),
# so injecting it here propagates to every consumer of the binding.
RUSTFLAGS_16K=$'-C\x1flink-arg=-Wl,-z,max-page-size=16384'
if [ -n "${CARGO_ENCODED_RUSTFLAGS:-}" ]; then
  export CARGO_ENCODED_RUSTFLAGS="${CARGO_ENCODED_RUSTFLAGS}"$'\x1f'"${RUSTFLAGS_16K}"
else
  export CARGO_ENCODED_RUSTFLAGS="${RUSTFLAGS_16K}"
fi

echo "Android env ready: NDK=$NDK API=$ANDROID_API"
set +u
