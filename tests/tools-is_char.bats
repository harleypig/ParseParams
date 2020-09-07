#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/global.bash"

# Export note function in test to make it available to external scripts.
# export -f note

sourcedir="$(dirname $BATS_TEST_DIRNAME)"
testfile="$sourcedir/tools"

##############################################################################
# Tests for is_char

#-----------------------------------------------------------------------------
@test 'is_char returns 1' {
  source "$testfile"
  run is_char
  assert_failure
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'is_char \"\" returns 1' {
  source "$testfile"
  run is_char ''
  assert_failure
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'is_char \"ab\" returns 1' {
  source "$testfile"
  run is_char 'ab'
  assert_failure
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'is_char \"a\" returns 0' {
  source "$testfile"
  run is_char 'a'
  assert_success
  assert_output ''
}
