#!/usr/bin/env bats

# we rely on a environment variable to point us to our unit-under-test
# syntax see http://stackoverflow.com/a/307735
: "${GTV:?Need to set environment variable 'GTV' to absolute gtv script path}"
if [ ! -x "$GTV" ]; then
  echo "Environment variable 'GTV' needs to point to a executable gtv script with absolute path"
  exit 1
fi

function setup {
  export TEST_DIR=$(mktemp -d)
  cd $TEST_DIR

  git init
  # we need to provide a basic git configuration - on travis there is none
  git config user.email "noreply@travis-ci.org"
  git config user.name "travis build git user"

  date > file
  git add .
  git commit -m "initial"
}

function teardown {
  rm -rf $TEST_DIR
}

@test "help" {
  ${GTV} help
}

@test "create new patch version with message" {
  EXPECTED="test tag wohooo"
  run ${GTV} init
  run ${GTV} new patch -m "${EXPECTED}"
  RESULT=$(git tag --list "v0.0.1" -n99 | tail -n1 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  [ "$RESULT" = "${EXPECTED}" ]
}

@test "create new minor version with message" {
  EXPECTED="test tag wohooo"
  run ${GTV} init
  run ${GTV} new minor -m "${EXPECTED}"
  RESULT=$(git tag --list "v0.1.0" -n99 | tail -n1 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  [ "$RESULT" = "${EXPECTED}" ]
}

@test "create new major version with message" {
  EXPECTED="test tag wohooo"
  run ${GTV} init
  run ${GTV} new major -m "${EXPECTED}"
  RESULT=$(git tag --list "v1.0.0" -n99 | tail -n1 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  [ "$RESULT" = "${EXPECTED}" ]
}

@test "set new specific version with message" {
  EXPECTED="test tag wohooo"
  run ${GTV} init
  run ${GTV} set 1.1.1 -m "${EXPECTED}"
  RESULT=$(git tag --list "v1.1.1" -n99 | tail -n1 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  [ "$RESULT" = "${EXPECTED}" ]
}
