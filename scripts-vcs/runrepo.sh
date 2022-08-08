#!/bin/sh
set -ex

# <<>><<EDIT_HERE>><<>>
TAG="studio-2022.1.1-canary"

: "${AOSP_SRC_ROOT:?Need to set AOSP root directory (e.g. 'export AOSP_SRC_ROOT=/aosp/src')}"
CFG_ROOT_DIR="$( cd "$( dirname "$0" )/.." >/dev/null 2>&1 && pwd )"

rm -rf $AOSP_SRC_ROOT/.repo/repo

REPO_TOOL=$AOSP_SRC_ROOT/repo
curl -fsSL https://storage.googleapis.com/git-repo-downloads/repo > "$REPO_TOOL"
chmod a+x "$REPO_TOOL"
REPO=$REPO_TOOL

cd $AOSP_SRC_ROOT

$REPO forall -vc "git checkout . ; git clean -fd; git reset --hard" || true

$REPO init -u  https://android.googlesource.com/platform/manifest -b $TAG < /dev/null
$REPO ${EXTRA_REPO_FLAGS} sync -c -j4

if [ ! -e "$AOSP_SRC_ROOT/prebuilts/studio/sdk/linux" ]; then
  ln -s $BUILD_ANDROID_SDK_HOME $AOSP_SRC_ROOT/prebuilts/studio/sdk/linux
elif [ `stat -c "%d.%i" -L "$BUILD_ANDROID_SDK_HOME"` != `stat -c "%d.%i" -L "$AOSP_SRC_ROOT/prebuilts/studio/sdk/linux"` ]; then
  echo "'$AOSP_SRC_ROOT/prebuilts/studio/sdk/linux' is not a symlink, and \$BUILD_ANDROID_SDK_HOME ($BUILD_ANDROID_SDK_HOME) is pointing to something different"
  false
fi
