#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/global.bash"

# Export note function in test to make it available to external scripts.
# export -f note

sourcedir="$(dirname $BATS_TEST_DIRNAME)"
testfile="$sourcedir/tools"

##############################################################################
# Tests for is_executable

#-----------------------------------------------------------------------------
@test 'is_executable returns 1' {
  source "$testfile"
  run is_executable
  assert_failure
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'is_executable \"\" returns 1' {
  source "$testfile"
  run is_executable ''
  assert_failure
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'is_executable \"nosuchfile\" returns 1' {
  nosuchfile="$(random_string)"
  source "$testfile"
  run is_executable "$nosuchfile"
  assert_failure
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'is_executable \"nonexecfileexists\" returns 1' {
  nonexecfileexists="$(mktemp)"
  source "$testfile"
  run is_executable "$nonexecfileexists"
  assert_failure
  assert_output ''
  rm "$nonexecfileexists"
}

#-----------------------------------------------------------------------------
@test 'is_executable \"execfileexists\" returns 0' {
  execfileexists="$(mktemp)"
  chmod 0700 "$execfileexists"
  source "$testfile"
  run is_executable "$execfileexists"
  assert_success
  assert_output ''
  rm "$execfileexists"
}
