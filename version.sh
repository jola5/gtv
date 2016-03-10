#!/bin/bash

#
#
# git tag versions
#
#

################################################################################

# display help
function help
{
  echo "usage: gtv [command] [-m|--message=<message>] [-s|--suffix=<suffix>]

Show current version number
  show

Display this help text
  help

Create a new git version number tag by simple increment. Add the optional
message as tag message. Add the optional suffix as a suffix to the tag name.
  new     <major|minor|patch> [-m|--message=<message>] [-s|--suffix=<suffix>]

Assign a specific git version number tag, must be increasing monotonic. Add the
optional message as tag message. Add the optional suffix as a suffix to the tag
name.
  set     <version> [-m|--message=<message>] [-s|--suffix=<suffix>]

Examples:
  # show current version, eg. 1.21.3
  gtv show
  # create a new tag with an increased minor version
  gtv new minor
  # show current version, eg. 1.22.0
  gtv show
  # assign an arbitrary but monotonic version number
  gtv set 1.22.1
  # show current version is the default command, eg. 1.22.1
  gtv
  # create a new tag with an increased major version and message
  gtv new major -m NEW
  # shows tag v2.0.0 with message \"NEW\"
  git show $(git describe)
  # create a new tag with an increased major version, message and tag suffix
  gtv new major -m ALPHA -s alpha
  # shows tag v3.0.0-alpha with message \"ALPHA\"
  git show $(git describe)
  # ERROR!!! Not a monotonic increaing number
  gtv set 1.0.0
"
}

# get latest version tag and print its name
function get-latest-tag-version
{
  TAG=$(git tag --list -n1 | grep -E "^v[0-9]+.[0-9]+.[0-9]+\s+version [0-9]+.[0-9]+.[0-9]+" | tail -n1 | cut -d" " -f1)
  echo "$TAG"
}

# print latest version number in a plain format, '1.2.3'
function show
{
  TAG=$(get-latest-tag-version)
  echo $TAG | tr -d 'v'
}

# print a new monotonic increasing version number based on the given version string
# argument 1: version type [major|minor|patch]
# argument 2: current version number string "major.minor.patch"
function new-version-string
{
  MAJOR=$(echo $2 | cut -d. -f1)
  MINOR=$(echo $2 | cut -d. -f2)
  PATCH=$(echo $2 | cut -d. -f3)

  case $1 in
    major)
    MAJOR=$((MAJOR+1))
    MINOR=0
    PATCH=0
    ;;
    minor)
    MINOR=$((MINOR+1))
    PATCH=0
    ;;
    patch)
    PATCH=$((PATCH+1))
    ;;
    *)
    echo "ERROR: Unsupported version type '$1', use major, minor or patch!"
    exit 1
    ;;
  esac

  echo "$MAJOR.$MINOR.$PATCH"
}

# create a new (monotonic increasing) version number tag
# argument 1: version type [major|minor|patch]
function tag-new-version
{
  CURRENT=$(get-latest-tag-version | tr -d 'v' )
  NEW=$(new-version-string $1 $CURRENT)
  echo "Current version:   $CURRENT"
  echo "New $1 version: $NEW"
  git tag -a "v$NEW$SUFFIX" -m "version $NEW: new $1" -m "$MESSAGE"
}

# create new version tag
# argument 1: version type [major|minor|patch]
function new
{
  # detect sub-command
  case $1 in
    major|minor|patch)
    tag-new-version $1
    ;;
    *)
    echo "ERROR: Unsupported version type '$1', use major, minor or patch!"
    exit 1
    ;;
  esac
}

# set specific version tag
# argument 1: version number string "major.minor.patch"
function set-version
{
  CURRENT=$(get-latest-tag-version)
  CURRENT_MAJOR=$(echo $CURRENT | cut -d. -f1)
  CURRENT_MINOR=$(echo $CURRENT | cut -d. -f2)
  CURRENT_PATCH=$(echo $CURRENT | cut -d. -f3)
  NEW_MAJOR=$(echo $1 | cut -d. -f1)
  NEW_MINOR=$(echo $1 | cut -d. -f2)
  NEW_PATCH=$(echo $1 | cut -d. -f3)

  if [ "$CURRENT_MAJOR" < "$NEW_MAJOR" ]; then
    echo "OK"
  else
    if [ "$CURRENT_MINOR" < "$NEW_MINOR" ]; then
      echo "OK"
    else
      if [ "$CURRENT_PATCH" < "$NEW_PATCH" ]; then
        echo "OK"
      else
        echo "ERROR: $1 is not a monotonic increasing version number."
        exit 1;
      fi
    fi
  fi

  echo "Create version $1"
}

################################################################################

# defaults for the optional arguments
MESSAGE=""
SUFFIX=""

# get the optional arguments
ARGS=$(getopt -o m:s: -l "message:,suffix:" -n "getopt.sh" -- "$@");

#Bad arguments
if [ $? -ne 0 ];
then
  exit 1
fi

eval set -- "$ARGS";

while true; do
  case "$1" in
    -m|--message)
      shift;
      if [ -n "$1" ]; then
        MESSAGE=$1
        shift;
      fi
      ;;
    -s|--suffix)
      shift;
      if [ -n "$1" ]; then
        SUFFIX=$1
        shift;
      fi
      ;;
    --)
      shift;
      break;
      ;;
  esac
done

# call the commands
case $1 in
    help)
    help
    ;;
    show)
    show
    ;;
    new)
    new $2
    ;;
    set)
    set-version $2
    ;;
    *)
    show
    ;;
esac
