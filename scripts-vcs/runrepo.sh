#!/bin/sh
set -ex

# <<>><<EDIT_HERE>><<>>
UNAME_OUT=$(uname)
if [ $UNAME_OUT == "Darwin" ]; then
    OS="darwin"
else
    OS="linux"
fi

TAG="studio-2022.2.1-canary7"

: "${AOSP_SRC_ROOT:?Need to set AOSP root directory (e.g. 'export AOSP_SRC_ROOT=/aosp/src')}"
CFG_ROOT_DIR="$( cd "$( dirname "$0" )/.." >/dev/null 2>&1 && pwd )"

rm -rf $AOSP_SRC_ROOT/.repo/repo

REPO_TOOL="$AOSP_SRC_ROOT/repo"
curl -fsSL https://storage.googleapis.com/git-repo-downloads/repo > "$REPO_TOOL"
chmod a+x "$REPO_TOOL"
if [[ $OS == "darwin" ]]; then
   perl -pi.bak -e "s/env python$/env python3/g" $REPO_TOOL
fi
REPO=$REPO_TOOL

cd $AOSP_SRC_ROOT

$REPO forall -vc "git checkout . ; git clean -fd; git reset --hard" || true

$REPO init -u https://android.googlesource.com/platform/manifest -b $TAG < /dev/null
$REPO ${EXTRA_REPO_FLAGS} sync -c -j4

PREBUILT_DIR="$AOSP_SRC_ROOT/prebuilts/studio/sdk/$OS"

if [ ! -e $PREBUILT_DIR ]; then
  ln -s $BUILD_ANDROID_SDK_HOME $PREBUILT_DIR
elif [ $OS == "darwin" ] && [ ! "$(stat -f "%HT" $PREBUILT_DIR)" == "Symbolic Link" ]; then
  echo "'$PREBUILT_DIR' is not a symlink'"
  false
elif [ $OS == "linux" ] && [ `stat -c "%d.%i" -L "$BUILD_ANDROID_SDK_HOME"` != `stat -c "%d.%i" -L "$PREBUILT_DIR"` ]; then
  echo "'$PREBUILT_DIR' is not a symlink, and \$BUILD_ANDROID_SDK_HOME ($BUILD_ANDROID_SDK_HOME) is pointing to something different"
fi
