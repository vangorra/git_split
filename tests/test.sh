#!/bin/bash

function cleanup() {
	echo "Cleaning up."
	#rm -rf "$TMP_DIR"
}

function expectIsDirectory() {
	expectExists "$1"

	if [[ ! -d "$1" ]] ; then
		echo "Expected '$1' to be a directory."
		cleanup
		exit 1
	fi
}

function expectIsFile() {
	expectExists "$1"

	if [[ ! -f "$1" ]] ; then
		echo "Expected '$1' to be a file."
		cleanup
		exit 1
	fi
}

function expectExists() {
	if [[ ! -e "$1" ]] ; then
		echo "Expected '$1' to exist."
		cleanup
		exit 1
	fi
}


function expectFileContains() {
	FILE_PATH=$1
	SEARCH_STR=$2

	expectIsFile "$FILE_PATH"

	if [[ $(grep -c "$SEARCH_STR" "$FILE_PATH") != "1" ]] ; then
		echo "Expected '$FILE_PATH' to contain '$SEARCH_STR'. It really contains '"`cat "$FILE_PATH"`"'";
		cleanup
		exit 1
	fi
}

function expectSuccessfulExit() {
	if [[ "$?" != "0" ]] ; then
		echo "The last command finished with exit code '$?'";
		cleanup
		exit 1
	fi
}

function echoAndRun() { echo ""; echo "> $@"; "$@" ; }

SELF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TMP_DIR=$(mktemp -d /tmp/git_split_test.XXXXXX)
expectSuccessfulExit

GIT_SPLIT_PATH="$SELF_DIR/../git_split.sh"


echo "Using tmp dir: $TMP_DIR"

SOURCE_DIR="$TMP_DIR/source"
DEST_DIR="$TMP_DIR/dest"

# create source files.
echo "Generating source files and directory tree."
mkdir -p "$SOURCE_DIR"
for level0 in `seq 0 5` ; do
	# create the dir
	mkdir -p "$SOURCE_DIR/$level0"
	
	# create the files
	for i in `seq 0 5` ; do
		echo "$level0/FILE$level0-$i.txt" > "$SOURCE_DIR/$level0/FILE$level0-$i.txt"
	done

	for level1 in `seq 0 5` ; do
		# create the dir
		mkdir -p "$SOURCE_DIR/$level0/$level0-$level1"
		
		# create the files
		for i in `seq 0 5` ; do
			echo "$level0/$level0-$level1/FILE$level0-$level1-$i.txt" > "$SOURCE_DIR/$level0/$level0-$level1/FILE$level0-$level1-$i.txt"
		done
	done
done

# create the source repo.
echo "Creating source git repo."
cd "$SOURCE_DIR"
echoAndRun git init
expectSuccessfulExit
echoAndRun git add .
expectSuccessfulExit
echoAndRun git commit -m "Initial commit"
expectSuccessfulExit
echoAndRun git checkout -b "SourceBranch1"
expectSuccessfulExit

# make the dest repo
echo "Creating dest git repo."
echoAndRun mkdir -p "$DEST_DIR"
expectSuccessfulExit
echoAndRun cd "$DEST_DIR"
expectSuccessfulExit
echoAndRun git init
expectSuccessfulExit

# run git split.
echo ""
echo "Running..."
echoAndRun "$GIT_SPLIT_PATH" "$SOURCE_DIR" "SourceBranch1" "1" "$DEST_DIR"
expectSuccessfulExit

cd "$DEST_DIR"
echoAndRun git checkout "SourceBranch1"
expectSuccessfulExit

expectFileContains "$DEST_DIR/FILE1-0.txt" "1/FILE1-0.txt"
expectFileContains "$DEST_DIR/FILE1-1.txt" "1/FILE1-1.txt"
expectFileContains "$DEST_DIR/FILE1-2.txt" "1/FILE1-2.txt"
expectFileContains "$DEST_DIR/FILE1-3.txt" "1/FILE1-3.txt"
expectFileContains "$DEST_DIR/FILE1-4.txt" "1/FILE1-4.txt"
expectFileContains "$DEST_DIR/FILE1-5.txt" "1/FILE1-5.txt"

expectIsDirectory "$DEST_DIR/1-0"
expectFileContains "$DEST_DIR/1-0/FILE1-0-0.txt" "1/1-0/FILE1-0-0.txt"
expectFileContains "$DEST_DIR/1-0/FILE1-0-1.txt" "1/1-0/FILE1-0-1.txt"
expectFileContains "$DEST_DIR/1-0/FILE1-0-2.txt" "1/1-0/FILE1-0-2.txt"
expectFileContains "$DEST_DIR/1-0/FILE1-0-3.txt" "1/1-0/FILE1-0-3.txt"
expectFileContains "$DEST_DIR/1-0/FILE1-0-4.txt" "1/1-0/FILE1-0-4.txt"
expectFileContains "$DEST_DIR/1-0/FILE1-0-5.txt" "1/1-0/FILE1-0-5.txt"

expectIsDirectory "$DEST_DIR/1-1"
expectFileContains "$DEST_DIR/1-1/FILE1-1-0.txt" "1/1-1/FILE1-1-0.txt"
expectFileContains "$DEST_DIR/1-1/FILE1-1-1.txt" "1/1-1/FILE1-1-1.txt"
expectFileContains "$DEST_DIR/1-1/FILE1-1-2.txt" "1/1-1/FILE1-1-2.txt"
expectFileContains "$DEST_DIR/1-1/FILE1-1-3.txt" "1/1-1/FILE1-1-3.txt"
expectFileContains "$DEST_DIR/1-1/FILE1-1-4.txt" "1/1-1/FILE1-1-4.txt"
expectFileContains "$DEST_DIR/1-1/FILE1-1-5.txt" "1/1-1/FILE1-1-5.txt"

expectIsDirectory "$DEST_DIR/1-2"
expectFileContains "$DEST_DIR/1-2/FILE1-2-0.txt" "1/1-2/FILE1-2-0.txt"
expectFileContains "$DEST_DIR/1-2/FILE1-2-1.txt" "1/1-2/FILE1-2-1.txt"
expectFileContains "$DEST_DIR/1-2/FILE1-2-2.txt" "1/1-2/FILE1-2-2.txt"
expectFileContains "$DEST_DIR/1-2/FILE1-2-3.txt" "1/1-2/FILE1-2-3.txt"
expectFileContains "$DEST_DIR/1-2/FILE1-2-4.txt" "1/1-2/FILE1-2-4.txt"
expectFileContains "$DEST_DIR/1-2/FILE1-2-5.txt" "1/1-2/FILE1-2-5.txt"

cleanup
exit 0