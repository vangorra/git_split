[![Build Status](https://travis-ci.org/vangorra/git_split.svg?branch=master)](https://travis-ci.org/vangorra/git_split)

# git_split.sh

## Description:
This script will take an existing directory in your git repository and turn that directory into an independent repository of its own. Along the way, it will presever all the change history.
Inspiration for this script came from https://help.github.com/articles/splitting-a-subfolder-out-into-a-new-repository/. This script really just automates the process.
let me know if you find this script useful. I'm also totally open contributors.

Installation:
Drop it into a appropriate bin directory. Or run it locally.


## Usage: 
```
./git_split.sh <src_repo> <src_branch> <relative_dir_path> <dest_repo>
        src_repo  - The source repo to pull from.
        src_branch - The branch of the source repo to pull from. (usually master)
        relative_dir_path   - Relative path of the directory in the source repo to split.
        dest_repo - The repo to push to.
```

## Notes:
* This script will not make any modifications to your original repo.
* If the dest repo specified in the map file doesn't exist, then this script will try to create it.

## Compatibility:
* Linux (Ubuntu so far)
* OSX (haven't tested it)
* Windows (haven't tested, but will probably work with cygwin)

## Requirements:
* git
* standard *nix commands
