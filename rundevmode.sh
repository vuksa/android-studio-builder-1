#!/bin/bash
set -ex

: "${AOSP_ROOT:?Need to set AOSP root directory (e.g. 'export AOSP_ROOT=/home/open/projects/studio-master-dev')}"

GROUPNAME=`id -gn`
GROUPID=`id -g`
USERID=`id -u`
USERNAME=$USER
USERHOME=$HOME
MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "sh /aosp/builder/dev-local/setuplocaluser.sh $USERID $GROUPID $USERNAME $GROUPNAME" > $MYDIR/dev-local/setuplocaluserinvoker.sh

docker build --target builder-dev -t androidstudio-builder-dev:latest .

docker run -it --name rundevmode --rm \
    --mount type=bind,source=$AOSP_ROOT,target=/aosp/src \
    --mount type=bind,source=$MYDIR,target=/aosp/builder \
    --mount type=bind,source=$USERHOME/.cache/bazel,target=/home/${USERNAME}/.cache/bazel \
    --mount type=bind,source=$USERHOME/.m2,target=/home/${USERNAME}/.m2 \
    --mount type=bind,source=$USERHOME/.gradle,target=/home/${USERNAME}/.gradle \
    androidstudio-builder-dev:latest
#    `[ -d "/home/${USERNAME}/Android/Sdk" ] && echo "--mount type=bind,source=/home/${USERNAME}/Android/Sdk,target=/home/${USERNAME}/Android/Sdk"` \
