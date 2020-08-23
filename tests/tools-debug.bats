#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/global.bash"

# Export note function in test to make it available to external scripts.
# export -f note

sourcedir="$(dirname $BATS_TEST_DIRNAME)"
testfile="$sourcedir/tools"

##############################################################################
# Tests for debug

#-----------------------------------------------------------------------------
@test 'no debug prints nothing' {
  source "$testfile"
  run debug 'nada-debug'
  assert_success
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'debug prints something' {
  source "$testfile"
  export DEBUG=1
  msg=$(random_string)
  expected_output="[il][test_functions.bash:run:038] $msg"
  run debug "$msg"
  assert_success
  assert_output "$expected_output"
}

#-----------------------------------------------------------------------------
@test 'debug nothing returns something' {
  export DEBUG=1
  printf -v expected_output '%s ' '[il][test-tools-debug:018]'
  run "$BATS_TEST_DIRNAME/bin/test-tools-debug" "$sourcedir"
  assert_success
  assert_output "$expected_output"
}

#-----------------------------------------------------------------------------
@test 'debug something returns same thing' {
  export DEBUG=1
  msg=$(random_string)
  printf -v expected_output '%s %s' '[il][test-tools-debug:018]' "$msg"
  run "$BATS_TEST_DIRNAME/bin/test-tools-debug" "$sourcedir" "$msg"
  assert_success
  assert_output "$expected_output"
}

#-----------------------------------------------------------------------------
@test 'multiline debug prints' {
  export DEBUG=1
  printf -v msg '%s\n%s' "$(random_string)" "$(random_string)"
  printf -v expected_output '%s %s' '[il][test-tools-debug:018]' "$msg"
  run "$BATS_TEST_DIRNAME/bin/test-tools-debug" "$sourcedir" "$msg"
  assert_success
  assert_output "$expected_output"
}

#-----------------------------------------------------------------------------
@test 'multi parameters debug prints' {
  export DEBUG=1

  msg1="$(random_string)"
  msg2="$(random_string)"
  msg3="$(random_string)"

  printf -v msg '%s\n' "$msg1" "$msg2"
  msg+="$msg3"

  run "$BATS_TEST_DIRNAME/bin/test-tools-debug" "$sourcedir" "$msg"
  assert_output "$msg>>>"
}
