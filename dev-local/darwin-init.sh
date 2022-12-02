#!/bin/bash
set -ex

: "${AOSP_SRC_ROOT:?Need to set AOSP root directory (e.g. 'export AOSP_SRC_ROOT=/aosp/src')}"

if [ ! $UNAME_OUT == "Darwin" ]; then
    echo "Not using Darwin-based machine -- exiting"
    exit
fi
# Needed for the toolchains/clang.BUILD to find the include files
xcode-select --install || true
pushd $AOSP_SRC_ROOT
ln -sf $HOME/Library/Android/sdk $AOSP_SRC_ROOT
$HOME/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager --install "ndk;20.1.5948944" "platforms;android-32" "build-tools;30.0.3"
# Used to run patches
export REPO_TOOL="$AOSP_SRC_ROOT/repo"
