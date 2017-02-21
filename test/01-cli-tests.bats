#!/usr/bin/env bats

function setup {
  export TEST_DIR=$(mktemp -d)
  cd $TEST_DIR

  git init
  date > file
  git add .
  git commit -m "initial"
}

function teardown {
  rm -rf $TEST_DIR
}

@test "help" {
  gtv help
}

@test "show uninitialized" {
  gtv show
  [ "$output" = "none" ]
}

@test "init" {
  gtv init
  [ "$output" = "0.0.0" ]
}

@test "patch" {
  gtv init
  gtv patch
  gtv show
  [ "$output" = "0.0.1" ]
}

@test "minor" {
  gtv init
  gtv minor
  gtv show
  [ "$output" = "0.1.0" ]
}

@test "major" {
  gtv init
  gtv major
  gtv show
  [ "$output" = "1.0.0" ]
}
