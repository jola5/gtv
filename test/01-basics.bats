#!/usr/bin/env bats

# we rely on a environment variable to point us to our unit-under-test
# syntax see http://stackoverflow.com/a/307735
: "${GTV:?Need to set environment variable 'GTV' to absolute gtv script path}"
if [ ! -x "$GTV" ]; then
  echo "Environment variable 'GTV' needs to point to a executable gtv script with absolute path"
  exit 1
fi

: "${GIT:?Need to set environment variable 'GIT' to absolute git executable path}"
if [ ! -x "$GIT" ]; then
  echo "Environment variable 'GIT' needs to point to a git executable with absolute path"
  exit 1
fi

function setup {
  export TEST_DIR=$(mktemp -d)
  cd $TEST_DIR

  ${GIT} init
  # we need to provide a basic git configuration - on travis there is none
  ${GIT} config user.email "noreply@travis-ci.org"
  ${GIT} config user.name "travis build git user"

  date > file
  ${GIT} add .
  ${GIT} commit -m "initial"
}

function teardown {
  rm -rf $TEST_DIR
}

@test "help" {
  ${GTV} help
}

@test "show gtv information on uninitialized git repository" {
  run ${GTV} show
  [ "$status" -eq 1 ]
  [ "$output" = "none" ]
}

@test "initialize gtv on uninitialized git repository" {
  run ${GTV} init
  echo "status: $status"
  echo "output: $output"
  [ "$output" = "Initial version: 0.0.0" ]
}

@test "create new patch version" {
  run ${GTV} init
  run ${GTV} new patch
  run ${GTV} show
  [ "$output" = "0.0.1" ]
}

@test "create new minor version" {
  run ${GTV} init
  run ${GTV} new minor
  run ${GTV} show
  [ "$output" = "0.1.0" ]
}

@test "create new major version" {
  run ${GTV} init
  run ${GTV} new major
  run ${GTV} show
  [ "$output" = "1.0.0" ]
}

@test "set new specific version" {
  run ${GTV} init
  run ${GTV} set 1.2.3
  run ${GTV} show
  [ "$output" = "1.2.3" ]
}

@test "set specific non-strictly-increasing version fails" {
  run ${GTV} init
  run ${GTV} set 1.2.3
  run ${GTV} set 1.0.0
  echo "status: $status"
  [ "$status" = 1 ]
}

@test "set syntactically invalid specific version fails" {
  run ${GTV} init
  run ${GTV} set 1.2.3
  run ${GTV} set a.b3tete.te
  echo "status: $status"
  [ "$status" = 1 ]
}

@test "set specifc non-strictly-increasing version with force" {
  run ${GTV} init
  run ${GTV} set 1.2.3
  run ${GTV} set 1.0.0 --force
  [ "$status" = 0 ]
}
