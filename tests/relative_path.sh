#!/bin/bash

#init 
SELF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SELF_DIR/lib.sh"

GIT_SPLIT_PATH="$SELF_DIR/../git_split.sh"
TEMP_DIR=$(makeTempDir)

cd "$TEMP_DIR"
SOURCE_REPO="sourceRepo"
DEST_REPO="destRepo"

(initTestSourceRepo "sourceRepo")

git init "$DEST_REPO"

# run
echoAndRun "$GIT_SPLIT_PATH" "$SOURCE_REPO" "SourceBranch1" "1" "$DEST_REPO"
expectSuccessfulExit

# verify
expectIsDirectory "$DEST_REPO/1-0"
expectIsDirectory "$DEST_REPO/1-1"
expectIsDirectory "$DEST_REPO/1-2"
expectIsDirectory "$DEST_REPO/1-3"
expectIsDirectory "$DEST_REPO/1-4"
expectIsDirectory "$DEST_REPO/1-5"

expectIsFile "$DEST_REPO/FILE1-0.txt"
expectIsFile "$DEST_REPO/FILE1-1.txt"
expectIsFile "$DEST_REPO/FILE1-2.txt"
expectIsFile "$DEST_REPO/FILE1-3.txt"
expectIsFile "$DEST_REPO/FILE1-4.txt"
expectIsFile "$DEST_REPO/FILE1-5.txt"

expectFileContains "$DEST_REPO/FILE1-0.txt" "1/FILE1-0.txt"
expectFileContains "$DEST_REPO/FILE1-1.txt" "1/FILE1-1.txt"
expectFileContains "$DEST_REPO/FILE1-2.txt" "1/FILE1-2.txt"
expectFileContains "$DEST_REPO/FILE1-3.txt" "1/FILE1-3.txt"
expectFileContains "$DEST_REPO/FILE1-4.txt" "1/FILE1-4.txt"
expectFileContains "$DEST_REPO/FILE1-5.txt" "1/FILE1-5.txt"

cleanup