#!/usr/bin/env bats

load global

sourcedir="$(dirname $BATS_TEST_DIRNAME)"
testfile="$sourcedir/ParseParams"

source "$ParseParams"

#-----------------------------------------------------------------------------
@test 'fail when no definitions passed' {
  run parse_params

  assert_failure
  assert_output 'No definitions were passed to parse_params.'
}
