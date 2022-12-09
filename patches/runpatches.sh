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

IDEA_VER=AI-222
rm -rf "${SRC}/prebuilts/studio/intellij-sdk/$IDEA_VER/$OS" || true
mkdir -p "${SRC}/prebuilts/studio/intellij-sdk/$IDEA_VER/$OS"

# Keep fixed for now so we can download correctly
TEMP_DIR="/tmp"
ANDROID_STUDIO_VER="2022.2.1.7"

if [ $UNAME_OUT == "Darwin" ]; then
    # Assume M1 silicon for now
    ANDROID_STUDIO_GZ="android-studio-$ANDROID_STUDIO_VER-mac_arm.zip"
    ANDROID_STUDIO_FULL_PATH=$TEMP_DIR/$ANDROID_STUDIO_GZ
    echo "229790eda1b5d256a799eae036a6b5b0a1aaf670d4e24005f06ed5b9766830ae $ANDROID_STUDIO_FULL_PATH" > $ANDROID_STUDIO_FULL_PATH.sha256
else
    ANDROID_STUDIO_GZ="android-studio-$ANDROID_STUDIO_VER-$OS.tar.gz"
    ANDROID_STUDIO_FULL_PATH=$TEMP_DIR/$ANDROID_STUDIO_GZ
    echo "23b35df3646c3a2ae4a8fc7dcc0c980240110366292dc1b9bccd1ba56b825975 $ANDROID_STUDIO_FULL_PATH" > $ANDROID_STUDIO_FULL_PATH.sha256
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
    mv "Android Studio Preview.app" "$PREBUILTS_DIR/$IDEA_VER/darwin/android-studio"
fi

popd

cp "${PATCHES}/prebuilts.studio.intellij-sdk.BUILD" "${SRC}/prebuilts/studio/intellij-sdk/BUILD"

if [ $UNAME_OUT == "Darwin" ]; then
    perl -pi.bak -e "s/linux\/android-studio/darwin\/android-studio\/Contents/g" "${SRC}/prebuilts/studio/intellij-sdk/BUILD"
fi
