#!/bin/bash

#
#
#
#
#

# display help
function help
{
  echo "usage: version [command]

Show current version number
  show

Display this help text
  help

Create a new version number by smiple increment
  new     <major|minor|patch>

Assign a specific version number, must be larger than the existing version
  set     <version>

Examples:
  version show # show current version, eg. 1.21.3
  version new minor # create a new tag with an increased minor version
  version show # show current version, eg. 1.22.0
  version set 1.22.1 # assign an arbitrary but monotonic version number
  version show # show current version, eg. 1.22.1
  version new major # create a new tag with an increased major version
  version show # show current version, eg. 2.0.0
"
}

# get latest version tag and return the version information
function getverison
{
  TAG=$(git describe --dirty --all --tags --match 'v*')
  echo "$TAG"
}

# get latest version tag and print the version number in a plain format, '1.2.3'
function show
{
}

# call the basic version commands
case $1 in
    help)
    help
    ;;
    show)
    show
    ;;
    new)
    new
    ;;
    set)
    set
    ;;
    *)
    help
    ;;
esac
