OS    | Build Status
------|-----------
Linux | [![Build Status](https://travis-ci.org/vangorra/git_split.svg?branch=master)](https://travis-ci.org/vangorra/git_split)
OSX   | [![Build Status](https://travis-ci.org/vangorra/git_split.svg?branch=master)](https://travis-ci.org/vangorra/git_split)
Windows | [![Build status](https://ci.appveyor.com/api/projects/status/0yt4c98hjpw02i61?svg=true)](https://ci.appveyor.com/project/vangorra/git-split)

![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)

# git_split.sh

This script will take an existing directory in your git repository and turn that directory into an independent repository of its own. Along the way, it will copy over the entire change history for the directory you provided.
Inspiration for this script came from https://help.github.com/articles/splitting-a-subfolder-out-into-a-new-repository/. This script really just automates the process. Let me know if you find this script useful. I'm also totally open contributors.

## Installation
Drop it into a appropriate bin directory. Or run it locally.

## Usage
```
./git_split.sh <src_repo> <src_branch> <relative_dir_path> <dest_repo>
        src_repo  - The source repo to pull from.
        src_branch - The branch of the source repo to pull from. (usually master)
        relative_dir_path   - Relative path of the directory in the source repo to split.
        dest_repo - The repo to push to.
```

## Examples
So you've been using git and storing multiple projects in the same repo. You repo looks something like this.
* myrepo
  * /ProjectA
    * Makefile
    * README
    * src
      * file1
      * file2
  * /ProjectB
    * Makefile
    * README
    * src
      * fileA
      * fileB

### Copy over the master branch.
``` sh
> mkdir ProjectARepo
> git init ProjectARepo

# copy over the master branch
> ./git_split myrepo master ProjectA ProjectARepo
```

## Notes
* git_split does not make any modifications to your original repo. It simply copies the history from one repo to another.
* You can copy more than 1 branch into a destination directory by running it multiple times.

## Compatibility
* Linux
* OSX
* Windows (with cygwin)

## Requirements
* git
* standard *nix commands
