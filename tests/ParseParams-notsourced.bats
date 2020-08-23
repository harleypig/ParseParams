#!/usr/bin/env bats

load global

ParseParams='./ParseParams'

#-----------------------------------------------------------------------------
@test 'must only be sourced' {
  run "$ParseParams"
  assert_failure
  assert_output 'ParseParams must only be sourced'
}

#-----------------------------------------------------------------------------
@test 'fail when getopts -T does not return 4' {
  MOCK=$(mock_create)
  MOCKPATH="${MOCK%/*}"
  MOCKFILE="${MOCK##*/}"
  MOCKCMD="$MOCKPATH/getopt"

  ln -sf "$MOCK" "$MOCKCMD"
  PATH="$MOCKPATH:$PATH"

  run source "$ParseParams"

  assert_failure
  assert_output "Unsupported version of getopt!"

  PATH="${PATH/$MOCKPATH:/}"
  unlink "$MOCKCMD"
}
