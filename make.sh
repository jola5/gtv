#!/bin/bash

set -e

WORKSPACE=$(dirname "$(readlink -f "$0")")
GTV=${WORKSPACE}/src/git-tag-version
BUILD_DIR=${WORKSPACE}/build
TEST_DIR=${WORKSPACE}/test
TEST_RESULTS=${BUILD_DIR}/test.results
cd "${WORKSPACE}"

function echoBold() {
  echo -e "\033[1m${1}\033[0m"
}

function echoYellow() {
  echo -e "\033[1;33m${1}\033[0m"
}

function cmd_help() {
  echo "$0 COMMAND

COMMAND
  clean           clean any existing build artifacts
  help            print this help text
  test [target]   run tests, returns 0 on success, test results in \"TEST_RESULTS\", for targets see \"${TEST_DIR}\"
  tag             create a new patch version
  build           create a release artifact in \"${BUILD_DIR}/git-tag-version\"
  git <version>   prepare build for the given git version, eg. \"2.14.1\" (used to test against different git versions)
"
}

function cmd_git() {
  if [ -z "${1}" ]; then
    return
  fi

  echoBold "\nPreparing for git v${1}"

  cd "${BUILD_DIR}"
  wget "https://github.com/git/git/archive/v${1}.tar.gz"
  tar -zxf "v${1}.tar.gz"
  rm -rf "v${1}.tar.gz"
  cd "git-${1}"
  make configure
  ./configure --prefix=/usr
  make
  export GIT="$(find ./ -maxdepth 1 -type f -executable -name 'git' | xargs readlink -f)"
  echo "Using GIT=${GIT}"
}

function cmd_clean() {
  echoBold "\nCleaning up"
  rm -rfv "${BUILD_DIR}"
}

function cmd_format() {
  echoBold "\nFormatting source files"
  mkdir -p "${WORKSPACE}/shfmt"
  # make shfmt available and format sources
  SHFMT_URL="https://github.com/mvdan/sh/releases/download/v1.3.1/shfmt_v1.3.1_linux_amd64"
  curl -sSL "${SHFMT_URL}" -o "${WORKSPACE}/shfmt/shfmt"
  chmod +x "${WORKSPACE}/shfmt/shfmt"
  PATH=$PATH:${WORKSPACE}/shfmt

  shfmt -i 2 -w ${GTV}
}

function cmd_test() {
  echoBold "\nExecuting tests"
  mkdir -p "${WORKSPACE}/build"
  # make bats available and execute tests
  git clone https://github.com/sstephenson/bats.git &>/dev/null || : # do not abort if clone exists
  PATH=$PATH:${WORKSPACE}/bats/bin
  date >"${TEST_RESULTS}"

  target=$1
  if [ -z "$target" ]; then
    target="*"
  fi

  # use default git if non specified by environment
  if [ ! -x "$GIT" ]; then
    GIT=$(which git)
  fi

  echo -e "\tGIT is ${GIT}, $(${GIT} --version)"
  echo -e "\tGTV is ${GTV}, $(${GIT} describe)\n"

  env GTV="${GTV}" GIT="${GIT}" bats ${TEST_DIR}/${target}.bats | tee "${TEST_RESULTS}"
  echo "Test results saved to ${TEST_RESULTS}"
}

function cmd_validate() {
  echoBold "\nValidating files"
  bash -n "${GTV}"
  if travis &>/dev/null; then
    travis lint "${WORKSPACE}/.travis.yml"
  else
    echoYellow "Skipping travis file validation"
  fi

  # we don't fail on static analysis findings, we fix them best as we can
  set +e
  if shellcheck -V &>/dev/null; then
    shellcheck "${GTV}"
  else
    echoYellow "Skipping static analysis with shellcheck"
  fi
  set -e
}

function cmd_tag() {
  echoBold "\nTagging version"
  ${GTV} new patch --strict
}

# build the gtv release artifact, expects version string number as first argument, auto generates it otherwise
function cmd_build() {
  echoBold "\nBuilding artifact"
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
  "git")
    cmd_git "$2"
    ;;
  "clean")
    cmd_clean
    ;;
  "format")
    cmd_format
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
    cmd_format
    cmd_validate
    cmd_test
    cmd_build "$2"
    ;;
esac
