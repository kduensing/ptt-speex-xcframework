#!/bin/bash
# Builds Sources/CSpeex (vendored libspeex, matching the PTT firmware's
# encoder config exactly) into CSpeex.xcframework for iOS device + simulator.
#
# Uses raw clang/libtool/lipo instead of `xcodebuild archive` against an SPM
# scheme, since the exact archive product path for an SPM C-library target
# varies by Xcode version and wasn't something I could verify without a
# local macOS toolchain - individual clang/libtool/lipo steps are simpler
# to debug from CI logs alone if something goes wrong.
set -euo pipefail

SRC_DIR="Sources/CSpeex"
INCLUDE_DIR="$SRC_DIR/include"
BUILD_DIR="build"
DEFINES=(-DHAVE_CONFIG_H -DDISABLE_WARNINGS -DDISABLE_NOTIFICATIONS)
MIN_IOS_VERSION="17.0"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

c_files=("$SRC_DIR"/*.c)

# compile_slice <name> <sdk> <arch> <version-min-flag>
compile_slice() {
  local name="$1" sdk="$2" arch="$3" version_flag="$4"
  local obj_dir="$BUILD_DIR/obj-$name"
  mkdir -p "$obj_dir"
  local sysroot
  sysroot=$(xcrun --sdk "$sdk" --show-sdk-path)

  local objs=()
  for f in "${c_files[@]}"; do
    local base
    base=$(basename "$f" .c)
    local obj="$obj_dir/$base.o"
    xcrun --sdk "$sdk" clang \
      -arch "$arch" -isysroot "$sysroot" "$version_flag=$MIN_IOS_VERSION" \
      -I "$SRC_DIR" -I "$INCLUDE_DIR" \
      "${DEFINES[@]}" \
      -O2 -c "$f" -o "$obj"
    objs+=("$obj")
  done

  xcrun --sdk "$sdk" libtool -static -o "$BUILD_DIR/libCSpeex-$name.a" "${objs[@]}"
  echo "Built $BUILD_DIR/libCSpeex-$name.a"
}

compile_slice "device-arm64" iphoneos arm64 -mios-version-min
compile_slice "sim-arm64" iphonesimulator arm64 -mios-simulator-version-min
compile_slice "sim-x86_64" iphonesimulator x86_64 -mios-simulator-version-min

lipo -create \
  "$BUILD_DIR/libCSpeex-sim-arm64.a" "$BUILD_DIR/libCSpeex-sim-x86_64.a" \
  -output "$BUILD_DIR/libCSpeex-sim.a"

rm -rf "$BUILD_DIR/CSpeex.xcframework"
xcodebuild -create-xcframework \
  -library "$BUILD_DIR/libCSpeex-device-arm64.a" -headers "$INCLUDE_DIR" \
  -library "$BUILD_DIR/libCSpeex-sim.a" -headers "$INCLUDE_DIR" \
  -output "$BUILD_DIR/CSpeex.xcframework"

echo "Done: $BUILD_DIR/CSpeex.xcframework"
find "$BUILD_DIR/CSpeex.xcframework" -maxdepth 3
