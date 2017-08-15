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

# TODO: replace git with ${GIT}

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

@test "create new patch version on existing tag with strict mode fails" {
  run ${GTV} init
  run ${GTV} set 1.0.0
  run ${GTV} --strict new patch
  echo "status: $status"
  [ "$status" = 1 ]
}

@test "create new minor version on existing tag with strict mode fails" {
  run ${GTV} init
  run ${GTV} set 1.0.0
  run ${GTV} -s new minor
  echo "status: $status"
  [ "$status" = 1 ]
}

@test "create new major version on existing tag with strict mode fails" {
  run ${GTV} init
  run ${GTV} set 1.0.0
  run ${GTV} --strict new major
  echo "status: $status"
  [ "$status" = 1 ]
}

@test "set specific version on existing tag with strict mode fails" {
  run ${GTV} init
  run ${GTV} set 1.0.0
  run ${GTV} --strict set 1.2.3
  echo "status: $status"
  [ "$status" = 1 ]
}

@test "set specific version on existing tag with strict mode enabled by git config fails" {
  git config gtv.strict-mode true
  run ${GTV} init
  run ${GTV} set 1.0.0
  run ${GTV} set 1.2.3
  echo "status: $status"
  [ "$status" = 1 ]
}

@test "set specific version on existing tag with strict mode enabled by git config but non-strict argument given" {
  git config gtv.strict-mode true
  run ${GTV} init
  run ${GTV} set 1.0.0
  run ${GTV} --non-strict set 1.2.3
  run ${GTV} show
  [ "$output" = "1.2.3" ]
}

@test "set specific version on existing tag with strict mode enabled by git config but short non-strict argument given" {
  git config gtv.strict-mode true
  run ${GTV} init
  run ${GTV} set 1.0.0
  run ${GTV} -n set 1.2.3
  run ${GTV} show
  [ "$output" = "1.2.3" ]
}

@test "set specific version on existing tag with strict mode disabled by git config but strict argument given fails" {
  git config gtv.strict-mode false
  run ${GTV} init
  run ${GTV} set 1.0.0
  run ${GTV} --strict set 1.2.3
  echo "status: $status"
  [ "$status" = 1 ]
}
