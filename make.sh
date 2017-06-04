#!/bin/bash

set -e

WORKSPACE=$(dirname $(readlink -f $0))
GTV=${WORKSPACE}/src/git-tag-version
TEST_RESULTS=${WORKSPACE}/build/test.results

cd ${WORKSPACE}

function cmd_help {
  echo "$0 COMMAND

COMMAND
  help    print this help text
  test    run tests, returns 0 on success, test results in \"TEST_RESULTS\"
  tag     create a new patch version (with strict mode)
  build   create a release artifact in \"${WORKSPACE}/build/git-tag-version\"
"
}

function cmd_test {
  echo -e "\n## Executing tests"
  # make bats available and execute tests
  git clone https://github.com/sstephenson/bats.git &> /dev/null || : # do not abort if clone exists
  PATH=$PATH:${WORKSPACE}/bats/bin
  env GTV="${GTV}" bats ${WORKSPACE}/test/*.bats | tee ${TEST_RESULTS}
  echo "Test results saved to ${TEST_RESULTS}"
}

function cmd_tag {
  echo -e "\n## Tagging version"
  ${GTV} new patch --strict
}

# build the gtv release artifact, expects version string number as first argument, auto generates it otherwise
function cmd_build {
  echo -e "\n## Building artifact"
  mkdir -p ${WORKSPACE}/build
  cp -f ${WORKSPACE}/src/git-tag-version ${WORKSPACE}/build/

  if [ -n "$1" ]; then
    VERSION=$1
  else
    SUFFIX="${TRAVIS_BUILD_NUMBER:-local}"
    VERSION="$(bash ${WORKSPACE}/src/git-tag-version)-${SUFFIX}"
  fi
  sed -e "s/^\(GTV_VERSION=\).*$/\1\"$VERSION\"/g" -i ${WORKSPACE}/build/git-tag-version
  echo "Version $VERSION"
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
    ;;
esac
