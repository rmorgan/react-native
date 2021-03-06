#!/bin/bash

set -ex

SCRIPTS=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT=$(dirname $SCRIPTS)

cd $ROOT

function cleanup {
  EXIT_CODE=$?
  set +e

  if [ $EXIT_CODE -ne 0 ];
  then
    WATCHMAN_LOGS=/usr/local/Cellar/watchman/3.1/var/run/watchman/$USER.log
    [ -f $WATCHMAN_LOGS ] && cat $WATCHMAN_LOGS
  fi
  # kill whatever is occupying port 8081 
  lsof -i tcp:8081 | awk 'NR!=1 {print $2}' | xargs kill
}
trap cleanup EXIT

XCODE_PROJECT="Examples/UIExplorer/UIExplorer.xcodeproj"
XCODE_SCHEME="UIExplorer"
XCODE_SDK="iphonesimulator"
if [ -z "$XCODE_DESTINATION" ]; then
  XCODE_DESTINATION="platform=iOS Simulator,name=iPhone 5s,OS=9.3"
fi

# Support for environments without xcpretty installed
set +e
OUTPUT_TOOL=$(which xcpretty)
set -e

# TODO: We use xcodebuild because xctool would stall when collecting info about
# the tests before running them. Switch back when this issue with xctool has
# been resolved.
if [ -z "$OUTPUT_TOOL" ]; then
  xcodebuild \
    -project $XCODE_PROJECT \
    -scheme $XCODE_SCHEME \
    -sdk $XCODE_SDK \
    -destination "$XCODE_DESTINATION" \
    test
else
  xcodebuild \
    -project $XCODE_PROJECT \
    -scheme $XCODE_SCHEME \
    -sdk $XCODE_SDK \
    -destination "$XCODE_DESTINATION" \
    test | $OUTPUT_TOOL && exit ${PIPESTATUS[0]}
fi

