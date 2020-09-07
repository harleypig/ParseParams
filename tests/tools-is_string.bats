#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/global.bash"

# Export note function in test to make it available to external scripts.
# export -f note

sourcedir="$(dirname $BATS_TEST_DIRNAME)"
testfile="$sourcedir/tools"

##############################################################################
# Tests for is_string

#-----------------------------------------------------------------------------
@test 'is_string returns 1' {
  source "$testfile"
  run is_string
  assert_failure
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'is_string \"\" returns 1' {
  source "$testfile"
  run is_string ''
  assert_failure
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'is_string \"ab\" returns 0' {
  source "$testfile"
  run is_string 'ab'
  assert_success
  assert_output ''
}
