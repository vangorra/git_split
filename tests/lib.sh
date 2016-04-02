function makeTempDir() {
	mktemp -d /tmp/git_split_test.XXXXXX
}

export -f makeTempDir

function cleanup() {
	echo "Cleaning up."
	rm -rf "/tmp/git_split_test.*"
}

export -f cleanup

function expectIsDirectory() {
	expectExists "$1"

	if [[ ! -d "$1" ]] ; then
		echo "Expected '$1' to be a directory."
		cleanup
		exit 1
	fi
}

export -f expectIsDirectory

function expectIsFile() {
	expectExists "$1"

	if [[ ! -f "$1" ]] ; then
		echo "Expected '$1' to be a file."
		cleanup
		exit 1
	fi
}

export -f expectIsFile

function expectExists() {
	if [[ ! -e "$1" ]] ; then
		echo "Expected '$1' to exist."
		cleanup
		exit 1
	fi
}

export -f expectExists

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

export -f expectFileContains

function expectSuccessfulExit() {
	if [[ "$?" != "0" ]] ; then
		echo "The last command finished with exit code '$?'";
		cleanup
		exit 1
	fi
}

export -f expectSuccessfulExit

function echoAndRun() { 
	echo ""; echo "> $@"; "$@" ; 
}

expect -f echoAndRun

function initTestSourceRepo() {
	SOURCE_DIR="$1"
	
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
	echoAndRun git checkout -b "SourceBranch1"
	expectSuccessfulExit
	echoAndRun git checkout master
	expectSuccessfulExit
}

export -f initTestSourceRepo