#!/bin/bash

set -e

WORKSPACE=$(dirname "$(readlink -f "$0")")
GTV=${WORKSPACE}/src/git-tag-version
BUILD_DIR=${WORKSPACE}/build
TEST_DIR=${WORKSPACE}/test
TEST_RESULTS=${BUILD_DIR}/test.results
cd "${WORKSPACE}"

function cmd_help {
  echo "$0 COMMAND

COMMAND
  help    print this help text
  test    run tests, returns 0 on success, test results in \"TEST_RESULTS\"
  tag     create a new patch version
  build   create a release artifact in \"${BUILD_DIR}/git-tag-version\"
"
}

function cmd_clean {
  echo -e "\n## Cleaning up"
  rm -rfv "${BUILD_DIR}"
}

function cmd_test {
  echo -e "\n## Executing tests"
  mkdir -p "${WORKSPACE}/build"
  # make bats available and execute tests
  git clone https://github.com/sstephenson/bats.git &> /dev/null || : # do not abort if clone exists
  PATH=$PATH:${WORKSPACE}/bats/bin
  date > "${TEST_RESULTS}"

  target=$1
  if [ -z "$target" ]; then
    target="*"
  fi
  env GTV="${GTV}" bats ${TEST_DIR}/${target}.bats | tee "${TEST_RESULTS}"
  echo "Test results saved to ${TEST_RESULTS}"
}

function cmd_validate {
  echo -e "\n## Validating files"

  bash -n "${GTV}"
  if travis &> /dev/null; then
    travis lint "${WORKSPACE}/.travis.yml"
  fi

  # we don't fail on static analysis findings, we fix them best as we can
  set +e
  if shellcheck -V &> /dev/null; then
    shellcheck "${GTV}"
  fi
  set -e
}

function cmd_tag {
  echo -e "\n## Tagging version"
  ${GTV} new patch --strict
}

# build the gtv release artifact, expects version string number as first argument, auto generates it otherwise
function cmd_build {
  echo -e "\n## Building artifact"
  mkdir -p "${WORKSPACE}/build"
  cp -f "${WORKSPACE}/src/git-tag-version" "${BUILD_DIR}/"

  if [ -n "$1" ]; then
    VERSION=$1
  else
    VERSION="$(bash "${WORKSPACE}/src/git-tag-version")"
  fi
  sed -e "s/^\(GTV_VERSION=\).*$/\1\"$VERSION\"/g" -i "${BUILD_DIR}/git-tag-version"
  echo "Version $VERSION"
  echo "Provided at ${BUILD_DIR}/git-tag-version"
}

case "$1" in
  "clean")
    cmd_clean
    ;;
  "validate")
    cmd_validate
    ;;
  "test")
    cmd_test "$2"
    ;;
  "tag")
    cmd_tag
    ;;
  "build")
    cmd_build "$2"
    ;;
  "help")
    cmd_help
    ;;
  *)
    cmd_clean
    cmd_validate
    cmd_test
    cmd_build "$2"
    ;;
esac
