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

@test "create new patch version with suffix" {
  SUFFIX=wohooSuffix
  run ${GTV} init
  run ${GTV} new patch --suffix=${SUFFIX}
  run ${GTV} show
  [ "$output" = "0.0.1-${SUFFIX}" ]
}

@test "create new minor version with suffix" {
  SUFFIX=wohooSuffix
  run ${GTV} init
  run ${GTV} new minor --suffix=${SUFFIX}
  run ${GTV} show
  [ "$output" = "0.1.0-${SUFFIX}" ]
}

@test "create new major version with suffix" {
  SUFFIX=wohooSuffix
  run ${GTV} init
  run ${GTV} new major --suffix=${SUFFIX}
  run ${GTV} show
  [ "$output" = "1.0.0-${SUFFIX}" ]
}

@test "set new specific version with suffix" {
  SUFFIX=wohooSuffix
  run ${GTV} init
  run ${GTV} set 1.2.3 --suffix=${SUFFIX}
  run ${GTV} show
  [ "$output" = "1.2.3-${SUFFIX}" ]
}

@test "create new patch version on existing tag with suffix" {
  SUFFIX=wohooSuffix
  run ${GTV} init
  run ${GTV} set 1.2.3 --suffix=${SUFFIX}
  run ${GTV} new patch
  run ${GTV} show
  [ "$output" = "1.2.4" ]
}

@test "create new minor version on existing tag with suffix" {
  SUFFIX=wohooSuffix
  run ${GTV} init
  run ${GTV} set 1.2.3 --suffix=${SUFFIX}
  run ${GTV} new minor
  run ${GTV} show
  [ "$output" = "1.3.0" ]
}

@test "create new major version on existing tag with suffix" {
  SUFFIX=wohooSuffix
  run ${GTV} init
  run ${GTV} set 1.2.3 --suffix=${SUFFIX}
  run ${GTV} new major
  run ${GTV} show
  [ "$output" = "2.0.0" ]
}

@test "set new specific version on existing tag with suffix" {
  SUFFIX=wohooSuffix
  run ${GTV} init
  run ${GTV} set 1.2.3 --suffix=${SUFFIX}
  run ${GTV} set 2.42.123
  run ${GTV} show
  [ "$output" = "2.42.123" ]
}

@test "set new specific version with suffix and custom delimiter" {
  SUFFIX=wohooSuffix
  DELIMITER='-+-'
  ${GIT} config gtv.suffix-delimiter ${DELIMITER}
  run ${GTV} init
  run ${GTV} set 1.2.3 --suffix=${SUFFIX}
  run ${GTV} show
  [ "$output" = "1.2.3${DELIMITER}${SUFFIX}" ]
}

@test "set new specific version that differs in suffix only" {
  SUFFIX=wohooSuffix
  DELIMITER='+'
  ${GIT} config gtv.suffix-delimiter ${DELIMITER}
  run ${GTV} init
  run ${GTV} set 1.2.3
  run ${GTV} set 1.2.3 --suffix=${SUFFIX} --non-strict
  run ${GTV} show
  [ "$output" = "1.2.3${DELIMITER}${SUFFIX}" ]
}
