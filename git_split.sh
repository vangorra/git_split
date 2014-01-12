#!/bin/bash
# Author: Robbie Van Gorkom
# Created: 2012-05-17
#
# This script will convert a directory in a git repository to a repository
# of it very own.
#

# set the variables.
SRC_REPO=$1
SRC_DIR=$2
OUTPUT_REPO=$3
TMP_DIR=$(mktemp -d git_split)

REPO_BASE=$TMP_DIR/repo_base;
REPO_TMP=$TMP_DIR/repo_tmp;

# function to cleanup with a message.
function cleanup() {
        rm -rf $TMP_DIR
}

# show the usage of this application
function usage() {
	echo -e ""
	echo -e "Usage: $0 <src_repo> <dir_path> <dest_repo>"
	echo -e "\tsrc_repo  - The source repo to pull from."
	echo -e "\tdir_path  - Path of the directory to split."
	echo -e "\tdest_repo - The repo to push to."
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

# if the source dir doesn't exist then exit
if [ ! -e "$REPO_BASE/$SRC_DIR" -o ! -d "$REPO_BASE/$SRC_DIR" ]
then
	cleanup
	echo "$REPO_BASE/$SRC_DIR doesn't exist or is not a directory."
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

# turn this repo into just the changes for the oldPath
git filter-branch --prune-empty --subdirectory-filter $SRC_DIR master

# push those changes to the new repo
git push $OUTPUT_REPO master

# cleanup temp files before exit
cleanup
