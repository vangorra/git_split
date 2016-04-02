#!/bin/bash

#init 
SELF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SELF_DIR/lib.sh"

GIT_SPLIT_PATH="$SELF_DIR/../git_split.sh"
TEMP_DIR=$(makeTempDir)
SOURCE_REPO="$TEMP_DIR/sourceRepo"
DEST_REPO="$TEMP_DIR/destRepo"

initTestSourceRepo "$TEMP_DIR/sourceRepo"

touch "$DEST_REPO"

# run
echoAndRun "$GIT_SPLIT_PATH" "$SOURCE_DIR" "SourceBranch1" "1" "$DEST_REPO"
expectExitCode 10

cleanup