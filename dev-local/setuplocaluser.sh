#!/bin/sh
set -e

UID=$1
GID=$2
UNAME=$3
GNAME=$4

: "${AOSP_SRC_ROOT:?Need to set AOSP root directory (e.g. 'export AOSP_SRC_ROOT=/aosp/src')}"
echo $0
CFG_ROOT_DIR="$( cd "$( dirname "$0" )/.." >/dev/null 2>&1 && pwd )"

groupadd -g $GID $GNAME
useradd -u $UID -g $GID $UNAME
usermod --shell /bin/bash $UNAME
cd $AOSP_SRC_ROOT
cat $CFG_ROOT_DIR/dev-local/welcome-dev.txt
chown $UNAME /home/$UNAME
chmod 755 /home/$UNAME

echo "Configuring Android SDK"
if [ -d "$AOSP_SRC_ROOT/prebuilts/studio/sdk" ]; then
  if [ -e "$AOSP_SRC_ROOT/prebuilts/studio/sdk/linux" ]; then
    echo "Android SDK already configured at $AOSP_SRC_ROOT/prebuilts/studio/sdk/linux"
  else
    DIR="/home/$UNAME/Android/Sdk"
    if [ -d "$DIR" ]; then
      ### Take action if $DIR exists ###
      echo "Found Android SDK at ${DIR} ..."
      ln -s /home/$UNAME/Android/Sdk $AOSP_SRC_ROOT/prebuilts/studio/sdk/linux
    else
      echo "Using default Android SDK at $BUILD_ANDROID_SDK_HOME ..."
      ln -s $BUILD_ANDROID_SDK_HOME $AOSP_SRC_ROOT/prebuilts/studio/sdk/linux
      chown $UNAME $AOSP_SRC_ROOT/prebuilts/studio/sdk/linux/ndk-bundle/sysroot/usr/include
    fi
  fi
  echo
  ls -l $AOSP_SRC_ROOT/prebuilts/studio/sdk/linux
else
  echo "Skipping Android SDK configuration: no AOSP sources found at $AOSP_SRC_ROOT/prebuilts/studio/sdk"
  echo "You can setup sources with 'cd $AOSP_SRC_ROOT && sh /aosp/scripts-vcs/runrepo.sh'. Then restart this script to auto-configure Android SDK"
fi

usermod -a -G root $UNAME
usermod -a -G sudo $UNAME

chmod +x $CFG_ROOT_DIR/dev-local/execbazel.sh

echo "Use ^D to return to #"

su $UNAME || true
bash
