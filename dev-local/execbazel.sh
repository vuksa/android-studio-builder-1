#!/bin/sh
: "${AOSP_SRC_ROOT:?Need to set AOSP root directory (e.g. 'export AOSP_SRC_ROOT=/aosp/src')}"
/bin/su -c "cd $AOSP_SRC_ROOT && $AOSP_SRC_ROOT/tools/base/bazel/bazel $@" andrei