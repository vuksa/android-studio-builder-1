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

# patch WORKSPACE
# patch tools/base/bazel/common.bazel.rc (in order to get rid of this patch one needs to find a way to install generic armeabi cross-compiler)
cd "${SRC}/tools/base"
git apply "${PATCHES}/tools.base.bazel.patch"

# remove pre-build ant action from idea
cd "${SRC}/tools/adt/idea"
git apply "${PATCHES}/tools.adt.idea.patch"

# patch external/grpc-grpc/src/core/lib/support/avl.c
# cd ${SRC}/external/grpc-grpc
# git apply ${PATCHES}/external.grpc-grpc.patch

## setup intellij-sdk (this can be replaced with IC-203 + a few libraries updated)
rm -rf "${SRC}/prebuilts/studio/intellij-sdk/AI-203/linux" || true
mkdir -p "${SRC}/prebuilts/studio/intellij-sdk/AI-203/linux"
cd "${SRC}/prebuilts/studio/intellij-sdk"
curl -L https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2020.3.1.22/android-studio-2020.3.1.22-linux.tar.gz > android-studio-2020.3.1.22-linux.tar.gz
echo "4adb7b9876ed7a59ae12de5cbfe7a402e1c07be915a4a516a32fef1d30b47276 android-studio-2020.3.1.22-linux.tar.gz" > android-studio-2020.3.1.22-linux.tar.gz.sha256
sha256sum -c android-studio-2020.3.1.22-linux.tar.gz.sha256
tar -xvf android-studio-2020.3.1.22-linux.tar.gz
mv "android-studio" "AI-203/linux/android-studio"
cp "${PATCHES}/prebuilts.studio.intellij-sdk.BUILD" "${SRC}/prebuilts/studio/intellij-sdk/BUILD"

# update kotlin compiler
cd "$SRC/prebuilts/tools/common/kotlin-plugin-ij"
rm -rf "$SRC/prebuilts/tools/common/kotlin-plugin-ij/Kotlin"
curl -L https://plugins.jetbrains.com/files/6954/133982/kotlin-plugin-202-1.5.30-release-412-IJ8194.7.zip > kotlin-plugin-202-1.5.30-release-412-IJ8194.7.zip
unzip kotlin-plugin-202-1.5.30-release-412-IJ8194.7.zip

