#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/global.bash"

# Export note function in test to make it available to external scripts.
# export -f note

sourcedir="$(dirname $BATS_TEST_DIRNAME)"
testfile="$sourcedir/tools"

##############################################################################
# Tests for is_integer

#-----------------------------------------------------------------------------
@test 'is_integer returns 1' {
  source "$testfile"
  run is_integer
  assert_failure
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'is_integer \"\" returns 1' {
  source "$testfile"
  run is_integer ''
  assert_failure
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'is_integer \"ab\" returns 1' {
  source "$testfile"
  run is_integer 'ab'
  assert_failure
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'is_integer \"1\" returns 0' {
  source "$testfile"
  run is_integer '1'
  assert_success
  assert_output ''
}
