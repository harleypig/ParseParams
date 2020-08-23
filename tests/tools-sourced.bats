#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/global.bash"

# Export note function in test to make it available to external scripts.
# export -f note

sourcedir="$(dirname $BATS_TEST_DIRNAME)"
testfile="$sourcedir/tools"

##############################################################################
# Tests for sourced

#-----------------------------------------------------------------------------
@test 'tools must only be sourced' {
  run "$testfile"
  assert_failure
  assert_output 'tools must only be sourced'
}

#-----------------------------------------------------------------------------
@test 'tools sources without error' {
  run source "$testfile"
  assert_success
  assert_output ''
}
