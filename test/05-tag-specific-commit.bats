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

@test "create new patch version on specific commit" {
  run ${GTV} init

  run date > file
  run ${GIT} add *
  run ${GIT} commit -m "commit to be tagged"
  TAGGED_COMMIT=$(${GIT} rev-parse --verify HEAD)

  run date > file2
  run ${GIT} add *
  run ${GIT} commit -m "commit stays untagged"
  UNTAGGED_COMMIT=$(${GIT} rev-parse --verify HEAD)

  run ${GTV} new patch ${TAGGED_COMMIT}

  run ${GIT} rev-list -n 1 v0.0.1
  [ "$output" != "$UNTAGGED_COMMIT" ]
  [ "$output" = "$TAGGED_COMMIT" ]
}

@test "create new minor version on specific commit" {
  run ${GTV} init

  run date > file
  run ${GIT} add *
  run ${GIT} commit -m "commit to be tagged"
  TAGGED_COMMIT=$(${GIT} rev-parse --verify HEAD)

  run date > file2
  run ${GIT} add *
  run ${GIT} commit -m "commit stays untagged"
  UNTAGGED_COMMIT=$(${GIT} rev-parse --verify HEAD)

  run ${GTV} new minor ${TAGGED_COMMIT}

  run ${GIT} rev-list -n 1 v0.1.0
  [ "$output" != "$UNTAGGED_COMMIT" ]
  [ "$output" = "$TAGGED_COMMIT" ]
}

@test "create new major version on specific commit" {
  run ${GTV} init

  run date > file
  run ${GIT} add *
  run ${GIT} commit -m "commit to be tagged"
  TAGGED_COMMIT=$(${GIT} rev-parse --verify HEAD)

  run date > file2
  run ${GIT} add *
  run ${GIT} commit -m "commit stays untagged"
  UNTAGGED_COMMIT=$(${GIT} rev-parse --verify HEAD)

  run ${GTV} new major ${TAGGED_COMMIT}

  run ${GIT} rev-list -n 1 v1.0.0
  [ "$output" != "$UNTAGGED_COMMIT" ]
  [ "$output" = "$TAGGED_COMMIT" ]
}

@test "set new specific version on specific commit" {
  run ${GTV} init

  run date > file
  run ${GIT} add *
  run ${GIT} commit -m "commit to be tagged"
  TAGGED_COMMIT=$(${GIT} rev-parse --verify HEAD)

  run date > file2
  run ${GIT} add *
  run ${GIT} commit -m "commit stays untagged"
  UNTAGGED_COMMIT=$(${GIT} rev-parse --verify HEAD)

  run ${GTV} set 1.2.3 ${TAGGED_COMMIT}

  run ${GIT} rev-list -n 1 v1.2.3
  [ "$output" != "$UNTAGGED_COMMIT" ]
  [ "$output" = "$TAGGED_COMMIT" ]
}
