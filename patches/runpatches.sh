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
git apply "${PATCHES}/tools.base.bazel.patch"

# patch tools/adt/idea
cd "${SRC}/tools/adt/idea"
git apply "${PATCHES}/tools.adt.idea.patch"

## setup intellij-sdk (this can be replaced with IC-211 + a few libraries updated)
rm -rf "${SRC}/prebuilts/studio/intellij-sdk/AI-211/linux" || true
mkdir -p "${SRC}/prebuilts/studio/intellij-sdk/AI-211/linux"
cd "${SRC}/prebuilts/studio/intellij-sdk"
curl -L https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2021.1.1.22/android-studio-2021.1.1.22-linux.tar.gz > android-studio-2021.1.1.22-linux.tar.gz
echo "a9a5eaffe1873c684b99786db482d3b11fcbc003a773634f8e740c7bca148539 android-studio-2021.1.1.22-linux.tar.gz" > android-studio-2021.1.1.22-linux.tar.gz.sha256
sha256sum -c android-studio-2021.1.1.22-linux.tar.gz.sha256
tar -xvf android-studio-2021.1.1.22-linux.tar.gz
mv "android-studio" "AI-211/linux/android-studio"
cp "${PATCHES}/prebuilts.studio.intellij-sdk.BUILD" "${SRC}/prebuilts/studio/intellij-sdk/BUILD"


