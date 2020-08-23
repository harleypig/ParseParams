#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/global.bash"

# Export note function in test to make it available to external scripts.
# export -f note

sourcedir="$(dirname $BATS_TEST_DIRNAME)"
testfile="$sourcedir/tools"

##############################################################################
# Tests for die

#-----------------------------------------------------------------------------
@test 'die returns 1' {
  run "$BATS_TEST_DIRNAME/bin/test-tools-die" "$sourcedir"
  assert_failure 1
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'die returns 1 with msg' {
  msg="$(random_string)"
  run "$BATS_TEST_DIRNAME/bin/test-tools-die" "$sourcedir" "$msg"
  assert_failure 1
  assert_output "$msg"
}

#-----------------------------------------------------------------------------
@test 'die returns 0' {
  run "$BATS_TEST_DIRNAME/bin/test-tools-die" "$sourcedir" 0
  assert_success
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'die returns 0 with msg' {
  msg="$(random_string)"
  run "$BATS_TEST_DIRNAME/bin/test-tools-die" "$sourcedir" 0 "$msg"
  assert_success
  assert_output "$msg"
}

#-----------------------------------------------------------------------------
@test 'die returns most recent exit code' {
  local -i number=$((2+RANDOM%10))
  run "$BATS_TEST_DIRNAME/bin/test-tools-die" "$sourcedir" 'mostrecent' $number
  assert_failure $number
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'die returns random' {
  local -i number=$((2+RANDOM%10))
  run "$BATS_TEST_DIRNAME/bin/test-tools-die" "$sourcedir" $number
  fail=$((number++))
  assert_failure $fail
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'die returns random with msg' {
  local -i number=$((2+RANDOM%10))
  msg="$(random_string)"
  run "$BATS_TEST_DIRNAME/bin/test-tools-die" "$sourcedir" $number "$msg"
  fail=$((number++))
  assert_failure $fail
  assert_output "$msg"
}
