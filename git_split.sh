#!/bin/bash
# Author: Robbie Van Gorkom
# Created: 2012-05-17
#
# This script will convert a directory in a git repository to a repository
# of it very own.
#

# set the variables.
SRC_REPO=$1
SRC_BRANCH=$2
SRC_DIR=$3
OUTPUT_REPO=$4
TMP_DIR=$(mktemp -d /tmp/git_split.XXXXXX)
SELF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Normalize the output repo path.
if [[ "$OUTPUT_REPO" != /* ]]; then
	echo "IS RELATIVE!!"
	OUTPUT_REPO="$( cd "$SELF_DIR/$OUTPUT_REPO" && pwd )"
fi

REPO_BASE=$TMP_DIR/repo_base;
REPO_TMP=$TMP_DIR/repo_tmp;

# function to cleanup with a message.
function cleanup() {
        rm -rf $TMP_DIR
}

# show the usage of this application
function usage() {
	echo -e ""
	echo -e "Usage: $0 <src_repo> <src_branch> <relative_dir_path> <dest_repo>"
	echo -e "\tsrc_repo   - The source repo to pull from."
	echo -e "\tsrc_branch - The branch of the source repo to pull from."
	echo -e "\trelative_dir_path   - Relative path of the directory in the source repo to split."
	echo -e "\tdest_repo  - The repo to push to."
	echo -e "Notes:"
	echo -e "	This script will not make any modifications to your original repo."
	echo -e "	If the dest repo specified in the map file doesn't exist, then this script will try to create it."
}

# cleans up when ctrl-c is pressed
function control_c {
	cleanup
}

# handle kill signals
trap control_c SIGINT

# check if help was requested
if [ $(echo " $*" | grep -ciE " [-]+(h|help)") -gt 0 ]
then
	cleanup
	usage
	exit
fi

if [[ -z "$SRC_REPO" ]] || [[ -z "$SRC_DIR" ]] || [[ -z "$OUTPUT_REPO" ]]; then
	usage
	exit
fi

# clone the repo
git clone $SRC_REPO $REPO_BASE;

# if the clone was not successful, then exit.
if [ $? -ne 0 ]
then
	cleanup 
	echo "Clone failed to run."
	usage
	exit 1
fi

echo "Creating Repo from $SRC_REPO $SRC_DIR for $OUTPUT_REPO"

# create the repo if it doesn't exist.
if [ ! -e "$OUTPUT_REPO" ]
then
	git init --bare --shared=group $OUTPUT_REPO

	# if we couldn't init the repo, then exit
	if [ $? -ne 0 ]
	then
		cleanup
		echo "Couldn't create output repository $OUTPUT_REPO"
		exit 1
	fi
fi

cd $REPO_BASE
git checkout $SRC_BRANCH

# if the source dir doesn't exist then exit
# check after checkout of branch in cases where SRC_DIR only exists on branch
if [ ! -e "$REPO_BASE/$SRC_DIR" -o ! -d "$REPO_BASE/$SRC_DIR" ]
then
	cleanup
	echo "$REPO_BASE/$SRC_DIR doesn't exist or is not a directory."
	exit 1
fi 

# turn this repo into just the changes for the oldPath
git filter-branch --prune-empty --subdirectory-filter $SRC_DIR $SRC_BRANCH

# push those changes to the new repo
git push $OUTPUT_REPO $SRC_BRANCH

# switched context of new repo to branch.  (output would default to master otherwise)
cd $OUTPUT_REPO
git checkout $SRC_BRANCH

# user still needs to push to remote to share the merged code
echo "run 'git push origin $SRC_BRANCH' to push the changes to the remote repository" 

# cleanup temp files before exit
cleanup
