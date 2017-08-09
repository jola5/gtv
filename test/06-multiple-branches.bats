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

@test "create new patch versions on branches with differing minor versions" {
  run ${GTV} init

  run date > file
  run git add *
  run git commit -m "commit"
  run git checkout -b branch_one
  run date > file
  run git add *
  run git commit -m "commit on branch one"
  run ${GTV} new patch
  run ${GTV}
  [ "$output" = "0.1.0" ]

  run git check master
  run git checkout -b branch_two
  run date > file
  run git add *
  run git commit -m "commit on branch two"
  run ${GTV} new minor
  run ${GTV} new patch
  run ${GTV}
  [ "$output" = "1.1.0" ]

  run git checkout -b branch_one
  run date > file
  run git add *
  run git commit -m "commit on branch one"
  run ${GTV} new patch
  run ${GTV}
  [ "$output" = "0.2.0" ]
}

@test "create new patch versions on branches with differing major versions" {
  run ${GTV} init

  run date > file
  run git add *
  run git commit -m "commit"
  run git checkout -b branch_one
  run date > file
  run git add *
  run git commit -m "commit on branch one"
  run ${GTV} new patch
  run ${GTV}
  [ "$output" = "0.0.1" ]

  run git check master
  run git checkout -b branch_two
  run date > file
  run git add *
  run git commit -m "commit on branch two"
  run ${GTV} new major
  run ${GTV} new patch
  run ${GTV}
  [ "$output" = "1.0.1" ]

  run git checkout -b branch_one
  run date > file
  run git add *
  run git commit -m "commit on branch one"
  run ${GTV} new patch
  run ${GTV}
  [ "$output" = "0.0.2" ]
}

@test "create new minor versions on branches with differing major versions" {
  run ${GTV} init

  run date > file
  run git add *
  run git commit -m "commit"
  run git checkout -b branch_one
  run date > file
  run git add *
  run git commit -m "commit on branch one"
  run ${GTV} new minor
  run ${GTV}
  [ "$output" = "0.1.0" ]

  run git check master
  run git checkout -b branch_two
  run date > file
  run git add *
  run git commit -m "commit on branch two"
  run ${GTV} new major
  run ${GTV} new minor
  run ${GTV}
  [ "$output" = "1.1.0" ]

  run git checkout -b branch_one
  run date > file
  run git add *
  run git commit -m "commit on branch one"
  run ${GTV} new minor
  run ${GTV}
  [ "$output" = "0.2.0" ]
}
