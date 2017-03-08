#!/bin/bash

set -e

WORKSPACE=$(dirname $(readlink -f $0))
GTV=${WORKSPACE}/src/git-tag-version

cd ${WORKSPACE}

function cmd_help {
  echo "$0 COMMAND

COMMAND
  help    print this help text
  test    run tests, returns 0 on success, test results in \"${WORKSPACE}/build/test.results\"
  tag     create a new patch version (TODO: preferably strict mode)
  build   create a release artifact in \"${WORKSPACE}/build/git-tag-version\"
"
}

function cmd_test {
  echo -e "\n## Executing tests"
  # make bats available and execute tests
  git clone https://github.com/sstephenson/bats.git &> /dev/null || : # do not abort if clone exists
  PATH=$PATH:${WORKSPACE}/bats/bin
  env GTV="${GTV}" bats ${WORKSPACE}/test/*.bats
}

function cmd_tag {
  echo -e "\n## Tagging version"
  ${GTV} new patch --strict
}

# build the gtv release artifact, expects version string number as first argument
function cmd_build {
  echo -e "\n## Building artifact"
  mkdir -p ${WORKSPACE}/build
  cp -f ${WORKSPACE}/src/git-tag-version ${WORKSPACE}/build/

  if [ -n "$1" ]; then
    sed -e "s/^\(GTV_VERSION=\).*$/\1\"$1\"/g" -i ${WORKSPACE}/build/git-tag-version
  fi
  echo "Version $1"
  echo "Provided at ${WORKSPACE}/build/git-tag-version"
}

case "$1" in
  "test")
    cmd_test
    ;;
  "tag")
    cmd_tag
    ;;
  "build")
    cmd_build $2
    ;;
  "help")
    cmd_help
    ;;
  *)
    cmd_test
    # cmd_tag
    cmd_build $1
    exit 1
    ;;
esac
