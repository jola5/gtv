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
  echo -e "\n"
  git log --pretty=oneline --decorate --all --graph --abbrev-commit
  echo -e "\n"
  echo "$TEST_DIR"
  rm -rf $TEST_DIR
}

@test "create new patch versions on branches with differing minor versions" {
  ${GTV} init

  git checkout -b branch_one master
  date >> file
  git add *
  git commit -m "commit on branch one"
  ${GTV} new patch
  run ${GTV}
  [ "$output" = "0.0.1" ]

  git checkout -b branch_two master
  date >> file
  git add *
  git commit -m "commit on branch two"
  ${GTV} new minor
  ${GTV} new patch
  run ${GTV}
  [ "$output" = "0.1.1" ]

  git checkout branch_one
  date >> file
  git add *
  git commit -m "commit on branch one"
  ${GTV} new patch
  run ${GTV}
  [ "$output" = "0.0.2" ]
}

@test "create new patch versions on branches with differing major versions" {
  ${GTV} init

  git checkout -b branch_one master
  date >> file
  git add *
  git commit -m "commit on branch one"
  ${GTV} new patch
  run ${GTV}
  [ "$output" = "0.0.1" ]

  git checkout -b branch_two master
  date >> file
  git add *
  git commit -m "commit on branch two"
  ${GTV} new major
  ${GTV} new patch
  run ${GTV}
  [ "$output" = "1.0.1" ]

  git checkout branch_one
  date >> file
  git add *
  git commit -m "commit on branch one"
  ${GTV} new patch
  run ${GTV}
  [ "$output" = "0.0.2" ]
}

@test "create new minor versions on branches with differing major versions" {
  ${GTV} init

  git checkout -b branch_one master
  date >> file
  git add *
  git commit -m "commit on branch one"
  ${GTV} new minor
  run ${GTV}
  [ "$output" = "0.1.0" ]

  git checkout -b branch_two master
  date >> file
  git add *
  git commit -m "commit on branch two"
  ${GTV} new major
  ${GTV} new minor
  run ${GTV}
  [ "$output" = "1.1.0" ]

  git checkout branch_one
  date >> file
  git add *
  git commit -m "commit on branch one"
  ${GTV} new minor
  run ${GTV}
  [ "$output" = "0.2.0" ]
}

@test "create new patch versions on branches without differing major and minor versions" {
  ${GTV} init

  git checkout -b branch_one master
  date >> file
  git add *
  git commit -m "commit on branch one"
  ${GTV} new patch
  run ${GTV}
  [ "$output" = "0.0.1" ]

  git checkout -b branch_two master
  date >> file
  git add *
  git commit -m "commit on branch two"
  ${GTV} new patch
  run ${GTV}
  [ "$output" = "0.0.2" ]
}

@test "create new minor versions on branches without differing major and patch versions" {
  ${GTV} init

  git checkout -b branch_one master
  date >> file
  git add *
  git commit -m "commit on branch one"
  ${GTV} new minor
  run ${GTV}
  [ "$output" = "0.1.0" ]

  git checkout -b branch_two master
  date >> file
  git add *
  git commit -m "commit on branch two"
  ${GTV} new minor
  run ${GTV}
  [ "$output" = "0.2.0" ]
}

@test "create new major versions on branches without differing minor and patch versions" {
  ${GTV} init

  git checkout -b branch_one master
  date >> file
  git add *
  git commit -m "commit on branch one"
  ${GTV} new major
  run ${GTV}
  [ "$output" = "1.0.0" ]

  git checkout -b branch_two master
  date >> file
  git add *
  git commit -m "commit on branch two"
  ${GTV} new major
  run ${GTV}
  [ "$output" = "2.0.0" ]
}
