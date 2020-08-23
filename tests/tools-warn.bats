#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/global.bash"

# Export note function in test to make it available to external scripts.
# export -f note

sourcedir="$(dirname $BATS_TEST_DIRNAME)"
testfile="$sourcedir/tools"

##############################################################################
# Tests for warn

# warn
# warn 'msg'
# echo 'msg' | warn
# warn < file
# warn <<< $variable

#-----------------------------------------------------------------------------
@test 'warn returns 0' {
  source "$testfile"
  run warn
  assert_success
}

#-----------------------------------------------------------------------------
@test 'warn from parm prints nothing to stdout' {
  source "$testfile"
  run $(warn 'nada-warn-parms' 2> /dev/null)
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'warn from stdin prints nothing to stdout' {
  source "$testfile"
  run $(echo 'nada-warn-stdin' | warn 2> /dev/null)
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'single line parm warn prints to stderr' {
  source "$testfile"
  msg=$(random_string)

  # Move stdout to null and stderr to stdout so we can capture the output.
  run echo $(warn "$msg" 3>&1 1> /dev/null 2>&3-)
  assert_output "$msg"
}

#-----------------------------------------------------------------------------
@test 'single line stdin warn prints to stderr' {
  source "$testfile"
  msg=$(random_string)

  # Move stdout to null and stderr to stdout so we can capture the output.
  run echo $(echo "$msg" | warn 3>&1 1> /dev/null 2>&3-)
  assert_output "$msg"
}

#-----------------------------------------------------------------------------
@test 'multiline parm warn prints to stderr' {
  source "$testfile"
  printf -v msg '%s\n%s' "$(random_string)" "$(random_string)"
  run warn "$msg"
  assert_output "$msg"
}

#-----------------------------------------------------------------------------
@test 'multiline stdin warn prints to stderr' {
  source "$testfile"
  printf -v msg '%s\n%s' "$(random_string)" "$(random_string)"
  run echo "$(echo "$msg" | warn 2>&1)"
  assert_output "$msg"
}

#-----------------------------------------------------------------------------
@test 'multi parameters warn prints to stderr' {
  source "$testfile"

  msg1="$(random_string)"
  msg2="$(random_string)"
  msg3="$(random_string)"

  printf -v msg '%s\n' "$msg1" "$msg2"
  msg+="$msg3"

  # Move stdout to null and stderr to stdout so we can capture the output so
  # we can be sure everything is going to stderr.

  run echo "$(warn "$msg1" "$msg2" "$msg3" 3>&1 1> /dev/null 2>&3-)"
  assert_output "$msg"
}
