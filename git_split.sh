#!/bin/bash
# Author: Robbie Van Gorkom
# Created: 2012-05-17
#
# This script will convert a directory in a git repository to a repository
# of it's very own.
#

# set the variables.
SRC_REPO="$1"
SRC_BRANCH="$2"
SRC_DIR="$3"
OUTPUT_REPO="$4"
TMP_DIR=$(mktemp -d /tmp/git_split.XXXXXX)
SELF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CURRENT_DIR="$(pwd)"

EXIT_CODE_OUTPUT_REPO_NOT_DIRECTORY=10
EXIT_CODE_OUTPUT_DIR_NOT_A_REPO=11
EXIT_CODE_FAILED_TO_CLONE_SOURCE_REPO=12
EXIT_CODE_FAILED_TO_CREATE_OUTPUT_REPO=13
EXIT_CODE_SRC_DIR_DOESNT_EXIST=14
EXIT_CODE_FAILED_TO_CREATE_BRANCH_IN_OUTPUT_REPO=15
EXIT_CODE_FAILED_TO_PULL_INTO_OUTPUT_REPO=16
EXIT_CODE_FAILED_TO_PUSH_TO_OUTPUT_REPO=17

# Normalize the output repo path.
if [[ "$OUTPUT_REPO" != /* ]]; then
	OUTPUT_REPO="$( cd "$CURRENT_DIR/$OUTPUT_REPO" && pwd )"
fi

REPO_BASE="$TMP_DIR/repo_base";
REPO_TMP="$TMP_DIR/repo_tmp";
BARE_REPO="$TMP_DIR/bare";

# function to cleanup with a message.
function cleanup() {
        rm -rf "$TMP_DIR"
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
	echo -e "	If the dest repo doesn't exist, then this script will try to create it."
}

function checkErrorExit() {
	LAST_CODE=$?

	if [[ $LAST_CODE -eq 0 ]]; then
		return
	fi

	EXIT_CODE=$2

	if [[ -z ${EXIT_CODE+x} ]]; then
		EXIT_CODE=1
	fi

	cleanup
	echo "$1"
	exit $EXIT_CODE
}

# cleans up when ctrl-c is pressed
function control_c {
	cleanup
}

# handle kill signals
trap control_c SIGINT

# check if help was requested
if [[ $(echo " $*" | grep -ciE " [-]+(h|help)") -gt 0 ]]; then
	cleanup
	usage
	exit
fi

if [[ -z "$SRC_REPO" ]] || [[ -z "$SRC_DIR" ]] || [[ -z "$OUTPUT_REPO" ]]; then
	usage
	exit
fi

if [[ -e "$OUTPUT_REPO" ]] && [[ ! -d "$OUTPUT_REPO" ]]; then
	echo "'$OUTPUT_REPO' exists but is not a directory."
	exit $EXIT_CODE_OUTPUT_REPO_NOT_DIRECTORY
fi

if [[ -d "$OUTPUT_REPO" ]]; then
	cd "$OUTPUT_REPO"
	git branch 2> /dev/null
	checkErrorExit "'$OUTPUT_REPO' is not a git repository." $EXIT_CODE_OUTPUT_DIR_NOT_A_REPO
fi

# clone the repo
git clone "$SRC_REPO" "$REPO_BASE";

# if the clone was not successful, then exit.
checkErrorExit "Clone failed to run." $EXIT_CODE_FAILED_TO_CLONE_SOURCE_REPO

# create the output repo if it doesn't exist.
if [[ ! -e "$OUTPUT_REPO" ]]; then
	git init "$OUTPUT_REPO"

	# if we couldn't init the repo, then exit
	checkErrorExit "Couldn't create output repository '$OUTPUT_REPO'." $EXIT_CODE_FAILED_TO_CREATE_OUTPUT_REPO
fi

cd "$REPO_BASE"
git checkout "$SRC_BRANCH"

# if the source dir doesn't exist then exit
# check after checkout of branch in cases where SRC_DIR only exists on branch
if [[ ! -e "$REPO_BASE/$SRC_DIR" ]] || [[ ! -d "$REPO_BASE/$SRC_DIR" ]]; then
	checkErrorExit "'$REPO_BASE/$SRC_DIR' doesn't exist or is not a directory." $EXIT_CODE_SRC_DIR_DOESNT_EXIST
fi 

# turn this repo into just the changes for the oldPath
git filter-branch --prune-empty --subdirectory-filter "$SRC_DIR" "$SRC_BRANCH"

# output is a working tree repo, pull changes in from the bare repo.
if [[ -e "$OUTPUT_REPO/.git" ]]; then
	# create the internal bare repo.
	git init --bare --shared=group "$BARE_REPO"

	# push those changes to our bare repo.
	git push "$BARE_REPO" "$SRC_BRANCH"

	cd "$OUTPUT_REPO"

	git checkout -b "$SRC_BRANCH"
	checkErrorExit "Failed to checkout/create branch '$SRC_BRANCH' in '$OUTPUT_REPO'." $EXIT_CODE_FAILED_TO_CREATE_BRANCH_IN_OUTPUT_REPO

	git pull "$BARE_REPO" "$SRC_BRANCH"
	checkErrorExit "Failed to pull into '$OUTPUT_REPO' from '$BARE_REPO'." $EXIT_CODE_FAILED_TO_PULL_INTO_OUTPUT_REPO

# output is a bare repo. we can just push.
else
	git push "$OUTPUT_REPO" "$SRC_BRANCH"
	checkErrorExit "Failed to push to '$OUTPUT_REPO' '$SRC_BRANCH'." $EXIT_CODE_FAILED_TO_PUSH_TO_OUTPUT_REPO
fi

# cleanup temp files before exit
cleanup
