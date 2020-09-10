#!/usr/bin/env bats

load global

sourcedir="$(dirname $BATS_TEST_DIRNAME)"
testfile="$sourcedir/ParseParams"

#-----------------------------------------------------------------------------
@test 'must only be sourced' {
  run "$testfile"
  assert_failure
  assert_output 'ParseParams must only be sourced'
}

#-----------------------------------------------------------------------------
@test 'fail when getopts -T does not return 4' {
  skip 'b0rked'
  MOCK=$(mock_create)
  MOCKPATH="${MOCK%/*}"
  MOCKFILE="${MOCK##*/}"
  MOCKCMD="$MOCKPATH/getopt"

  ln -sf "$MOCK" "$MOCKCMD"
  PATH="$MOCKPATH:$PATH"

  run source "$testfile"

  assert_failure
  assert_output "Unsupported version of getopt!"

  PATH="${PATH/$MOCKPATH:/}"
  unlink "$MOCKCMD"
}
