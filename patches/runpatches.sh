set -ex

: "${AOSP_SRC_ROOT:?Need to set AOSP root directory (e.g. 'export AOSP_SRC_ROOT=/aosp/src')}"

if hash $REPO_TOOL 2>/dev/null; then
  REPO=$REPO_TOOL
elif hash repo 2>/dev/null; then
  REPO=repo
fi

: "${REPO:?'repo' not found in PATH, neither in REPO_TOOL (e.g. 'export REPO_TOOL=/aosp/bin/repo')}"

CFG_ROOT_DIR="$( cd "$( dirname "$0" )/.." >/dev/null 2>&1 && pwd )"
PATCHES=$CFG_ROOT_DIR/patches
SRC=$AOSP_SRC_ROOT

#
# Reset repo to well-known state before patching
#
cd ${SRC}
#$REPO forall -vc "git reset --hard"  # This increases Docker image size by ~10G. Moved to runrepo.sh

#
# Patch the sources
#

# add tools/vendor/google/android-ndk & jvmti.h
mkdir -p ${SRC}/tools/vendor/google/android-ndk/includes
cp ${PATCHES}/tools.vendor.google.android-ndk.BUILD ${SRC}/tools/vendor/google/android-ndk/BUILD
curl https://android.googlesource.com/platform/art/+/master/openjdkjvmti/include/jvmti.h?format=TEXT | base64 -d > ${SRC}/tools/vendor/google/android-ndk/includes/jvmti.h

# patch WORKSPACE
# patch tools/base/bazel/common.bazel.rc (in order to get rid of this patch one needs to find a way to install generic armeabi cross-compiler)
cd ${SRC}/tools/base
git apply ${PATCHES}/tools.base.bazel.patch

# remove pre-build ant action from idea
cd ${SRC}/tools/adt/idea
git apply ${PATCHES}/tools.adt.idea.patch

# remove google-app-indexing from idea
cd ${SRC}/tools/idea
git apply ${PATCHES}/tools.idea.patch

# patch external/grpc-grpc/src/core/lib/support/avl.c
# cd ${SRC}/external/grpc-grpc
# git apply ${PATCHES}/external.grpc-grpc.patch
