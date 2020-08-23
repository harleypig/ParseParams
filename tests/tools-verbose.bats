#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/global.bash"

# Export note function in test to make it available to external scripts.
# export -f note

sourcedir="$(dirname $BATS_TEST_DIRNAME)"
testfile="$sourcedir/tools"

##############################################################################
# Tests for verbose

#-----------------------------------------------------------------------------
@test 'no verbose prints nothing' {
  source "$testfile"
  run verbose 'nada-verbose'
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'verbose prints something' {
  source "$testfile"
  export VERBOSE=1
  msg=$(random_string)
  run verbose "$msg"
  assert_output "$msg"
}
