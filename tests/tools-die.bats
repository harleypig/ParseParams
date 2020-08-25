#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/global.bash"

# Export note function in test to make it available to external scripts.
# export -f note

sourcedir="$(dirname $BATS_TEST_DIRNAME)"
testfile="$sourcedir/tools"

##############################################################################
# Tests for die

#ok 8 warn < file
#ok 10 warn <<< $variable

#-----------------------------------------------------------------------------
@test 'die exits 1' {
  source "$testfile"
  run die
  assert_failure 1
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'die exits 0' {
  source "$testfile"
  run die 0
  assert_success
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'die returns most recent exit code' {
  local -i number=$((2+RANDOM%10))
  run "$BATS_TEST_DIRNAME/bin/test-tools-die" "$sourcedir" 'mostrecent' $number
  assert_failure $number
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'die returns nothing on stdout' {
  source "$testfile"
  run $(die 'nada-die-parms' 2> /dev/null)
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'die prints to stderr' {
  source "$testfile"
  msg="$(random_string)"
  # Move stdout to null and stderr to stdout so we can capture only stderr.
  run echo $(die "$msg" 3>&1 1> /dev/null 2>&3-)
  assert_output "$msg"
}

#-----------------------------------------------------------------------------
@test 'die multi parms' {
  msg1=$(random_string)
  msg2=$(random_string)
  msg3=$(random_string)

  printf -v expected_output '%s\n' "$msg1" "$msg2"
  expected_output+="$msg3"

  run "$BATS_TEST_DIRNAME/bin/test-tools-die" "$sourcedir" "$msg1" "$msg2" "$msg3"

  assert_failure
  assert_output "$expected_output"
}

#-----------------------------------------------------------------------------
@test 'echo msg | die' {
  msg=$(random_string)
  run "$BATS_TEST_DIRNAME/bin/test-tools-die" "$sourcedir" 'pipe' "$msg"
  assert_failure
  assert_output "$msg"
}

#-----------------------------------------------------------------------------
@test 'die < file' {
  source "$testfile"
  msg=$(random_string)
  file=$(mktemp -p "$BATS_RUN_TMPDIR")
  echo "$msg" > "$file"
  run die < "$file"
  assert_failure
  assert_output "$msg"
}

#-----------------------------------------------------------------------------
@test 'die <<< \$variable' {
  source "$testfile"
  msg=$(random_string)
  run die <<< "$msg"
  assert_failure
  assert_output "$msg"
}
