set -ex

: "${AOSP_SRC_ROOT:?Need to set AOSP root directory (e.g. 'export AOSP_SRC_ROOT=/aosp/src')}"
if hash $REPO_TOOL 2>/dev/null; then
  REPO=$REPO_TOOL
elif hash repo 2>/dev/null; then
  REPO=repo
fi

: "${REPO:?'repo' not found in PATH, neither in REPO_TOOL (e.g. 'export REPO_TOOL=/aosp/bin/repo')}"

CFG_ROOT_DIR="$( cd "$( dirname "$0" )/.." >/dev/null 2>&1 && pwd )"
PATCHES="$CFG_ROOT_DIR/patches"
SRC=$AOSP_SRC_ROOT

#
# Reset repo to well-known state before patching
#
cd "${SRC}"
#$REPO forall -vc "git reset --hard"  # This increases Docker image size by ~10G. Moved to runrepo.sh

#
# Patch the sources
#

# add tools/vendor/google/android-ndk & jvmti.h
mkdir -p "${SRC}/tools/vendor/google/android-ndk/includes"
cp "${PATCHES}/tools.vendor.google.android-ndk.BUILD" "${SRC}/tools/vendor/google/android-ndk/BUILD"
curl https://android.googlesource.com/platform/art/+/master/openjdkjvmti/include/jvmti.h?format=TEXT | base64 -d > "${SRC}/tools/vendor/google/android-ndk/includes/jvmti.h"

# patch tools/base
cd "${SRC}/tools/base"
git reset --hard
git apply "${PATCHES}/tools.base.bazel.patch"

# patch tools/adt/idea
cd "${SRC}/tools/adt/idea"
git reset --hard
git apply "${PATCHES}/tools.adt.idea.patch"

# patch external/grpc for Mac laptops
cd "${SRC}/external/grpc-grpc"
git reset --hard
git apply "${PATCHES}/external.grpc-grpc.patch"

## setup intellij-sdk (this can be replaced with IC-211 + a few libraries updated)
UNAME_OUT=$(uname)
if [ $UNAME_OUT == "Darwin" ]; then
    OS="darwin"
else
    OS="linux"
fi

IDEA_VER=AI-223
rm -rf "${SRC}/prebuilts/studio/intellij-sdk/$IDEA_VER/$OS" || true
mkdir -p "${SRC}/prebuilts/studio/intellij-sdk/$IDEA_VER/$OS"

# Keep fixed for now so we can download correctly
TEMP_DIR="/tmp"
ANDROID_STUDIO_VER="2022.3.1.18"

if [ $UNAME_OUT == "Darwin" ]; then
    # Assume M1 silicon for now
    ANDROID_STUDIO_GZ="android-studio-$ANDROID_STUDIO_VER-mac_arm.zip"
    ANDROID_STUDIO_FULL_PATH=$TEMP_DIR/$ANDROID_STUDIO_GZ
    echo "ae39502b86dcb004b7732a6639edc97a4bd501400118e9d0f3441d5079903cac $ANDROID_STUDIO_FULL_PATH" > $ANDROID_STUDIO_FULL_PATH.sha256
else
    ANDROID_STUDIO_GZ="android-studio-$ANDROID_STUDIO_VER-$OS.tar.gz"
    ANDROID_STUDIO_FULL_PATH=$TEMP_DIR/$ANDROID_STUDIO_GZ
    echo "24215e1324a6ac911810b2cc1afb2d735cf745dfbc06918a42b8d6fbc6bf7433 $ANDROID_STUDIO_FULL_PATH" > $ANDROID_STUDIO_FULL_PATH.sha256
fi

ANDROID_STUDIO_URL="https://redirector.gvt1.com/edgedl/android/studio/ide-zips/$ANDROID_STUDIO_VER/$ANDROID_STUDIO_GZ"

if ! sha256sum -c $ANDROID_STUDIO_FULL_PATH.sha256; then
    curl -L $ANDROID_STUDIO_URL > $ANDROID_STUDIO_FULL_PATH
    sha256sum -c $ANDROID_STUDIO_FULL_PATH.sha256
fi

pushd $(mktemp -d)
tar -xvf $ANDROID_STUDIO_FULL_PATH
PREBUILTS_DIR="${SRC}/prebuilts/studio/intellij-sdk"

if [ $UNAME_OUT == "Linux" ]; then
    mv "android-studio" "$PREBUILTS_DIR/$IDEA_VER/linux/android-studio"
else
    mv "Android Studio.app" "$PREBUILTS_DIR/$IDEA_VER/darwin/android-studio"
fi

popd

cp "${PATCHES}/prebuilts.studio.intellij-sdk.BUILD" "${SRC}/prebuilts/studio/intellij-sdk/BUILD"

if [ $UNAME_OUT == "Darwin" ]; then
    perl -pi.bak -e "s/linux\/android-studio/darwin\/android-studio\/Contents/g" "${SRC}/prebuilts/studio/intellij-sdk/BUILD"
fi
