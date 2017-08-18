#!/bin/bash

WORKSPACE=$(dirname "$(readlink -f "$0")")
GTV=${WORKSPACE}/src/git-tag-version
SOURCE_DIR=${WORKSPACE}/src
BUILD_DIR=${WORKSPACE}/build
TEST_DIR=${WORKSPACE}/test
TEST_RESULTS=${BUILD_DIR}/test.results
cd "${WORKSPACE}"

set -e

function echoBold() {
  echo -e "\033[1m${1}\033[0m"
}

function echoYellow() {
  echo -e "\033[1;33m${1}\033[0m"
}

function cmd_help() {
  echo "$0 COMMAND

COMMAND
  help            print this help text
  format          format the source files
  validate        valadite source and travis files
  clean           clean any existing build artifacts
  test [target]   run tests, returns 0 on success, test results in \"TEST_RESULTS\", for targets see \"${TEST_DIR}\"
  tag             create a new patch version
  build           create a release artifact in \"${BUILD_DIR}/git-tag-version\"
  git <version>   prepare build for the given git version, eg. \"2.14.1\" (used to test against different git versions)
"
}

function cmd_git() {
  if [ -z "${1}" ]; then
    echoBold "\nSystem default $(git --version)"
    export GIT=$(which git)
  else
    echoBold "\nPreparing for git v${1}"
    mkdir -p "${BUILD_DIR}"
    cd "${BUILD_DIR}"
    wget "https://github.com/git/git/archive/v${1}.tar.gz"
    tar -zxf "v${1}.tar.gz"
    rm -rf "v${1}.tar.gz"
    cd "git-${1}"
    make configure
    ./configure --prefix=/usr
    make
    export GIT="$(find ./ -maxdepth 1 -type f -executable -name 'git' | xargs readlink -f)"
  fi

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

  for sourcefile in $(find ${SOURCE_DIR} -type f | sort); do
    echo -e "\tFormatting '${sourcefile}'"
    shfmt -i 2 -w ${sourcefile}
  done
}

function cmd_test() {
  echoBold "\nExecuting tests"
  mkdir -p "${WORKSPACE}/build"
  # make bats available and execute tests
  git clone https://github.com/sstephenson/bats.git &>/dev/null || : # do not abort if clone exists
  PATH=$PATH:${WORKSPACE}/bats/bin
  date >"${TEST_RESULTS}"

  target=$1
  if [ -z "${target}" ]; then
    target="*"
  fi

  if [ -z "${GIT}" ]; then
    export GIT=$(which git)
  fi

  echo -e "\tGIT is ${GIT}, $(${GIT} --version)"
  echo -e "\tGTV is ${GTV}, $(${GIT} describe)\n"

  fail=0
  for testfile in $(find ${TEST_DIR} -type f -name "${target}" | sort); do
    echo -e "\n\tExecuting tests in '${testfile}'"
    if ! env GTV="${GTV}" GIT="${GIT}" bats "${testfile}"; then
      fail=1
    fi
  done

  [ $fail ]
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
    for sourcefile in $(find ${SOURCE_DIR} -type f | sort); do
      echo -e "\tValidating '${sourcefile}'"
      shellcheck "${sourcefile}"
    done
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

GIT_VERSION=${GIT_VERSION-""}
TEST_TARGET="*"

# get the optional arguments and handle bad arguments
if ! ARGS=$(getopt -o g:t: -l "git-version:,test-target:" -n "getopt.sh" -- "$@"); then
  exit 1
fi

eval set -- "$ARGS"

while true; do
  case "$1" in
    -g | --git-version)
      GIT_VERSION="$2"
      shift 2
      ;;
    -t | --test-target)
      TEST_TARGET="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
  esac
done

if [ $# -eq 0 ]; then
  cmd_clean
  cmd_git "${GIT_VERSION}"
  cmd_format
  cmd_validate
  ${BASHCOV} cmd_test "${TEST_TARGET}"
  cmd_build
else
  while test $# -gt 0; do
    case "$1" in
      "git")
        cmd_git "${GIT_VERSION}"
        shift 2
        ;;
      "clean")
        cmd_clean
        shift
        ;;
      "format")
        cmd_format
        shift
        ;;
      "validate")
        cmd_validate
        shift
        ;;
      "test")
        cmd_test "${TEST_TARGET}"
        shift 2
        ;;
      "tag")
        cmd_tag
        shift
        ;;
      "build")
        cmd_build "$2"
        shift
        ;;
      "help")
        cmd_help
        shift
        ;;
    esac
  done
fi
