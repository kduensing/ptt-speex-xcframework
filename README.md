# ptt-speex-xcframework

Builds the vendored libspeex decoder (from the [PTT](https://gitlab.duensinglab.com/hermes1/ptt)
voice-memo wearable project) into `CSpeex.xcframework` via GitHub Actions'
free macOS runners.

**Why this exists**: Swift Playgrounds (used to build the PTT iOS app from
an iPad, with no Mac available) refuses to compile any local C source -
neither a standalone C target nor a mixed Swift/C target. A prebuilt
XCFramework sidesteps this: Playgrounds only needs to *link* a binary, not
compile C itself.

`Sources/CSpeex` is a copy of the PTT project's vendored Speex sources,
configured identically (`config.h`: fixed-point, wideband, no VBR - see
that project's `ios/README.md` for the full story) so the decoder's
bitstream matches the firmware's encoder exactly.

Every push to `main` runs `build_xcframework.sh` on a macOS runner and
uploads `CSpeex.xcframework.zip` as a workflow artifact (Actions tab -> a
run -> Artifacts). Download it, unzip, and drop `CSpeex.xcframework` into
the PTT iOS app's `PTT.swiftpm` package as a binary target dependency.
