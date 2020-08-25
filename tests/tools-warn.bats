#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/global.bash"

# Export note function in test to make it available to external scripts.
# export -f note

sourcedir="$(dirname $BATS_TEST_DIRNAME)"
testfile="$sourcedir/tools"
source "$testfile"

##############################################################################
# Tests for warn

#-----------------------------------------------------------------------------
@test 'warn returns 0' {
  run warn
  assert_success
}

#-----------------------------------------------------------------------------
@test 'warn prints nothing to stdout' {
  run $(warn 'nada-warn-parms' 2> /dev/null)
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'warn prints to stderr' {
  msg=$(random_string)
  # Move stdout to null and stderr to stdout so we can capture only stderr.
  run echo $(warn "$msg" 3>&1 1> /dev/null 2>&3-)
  assert_output "$msg"
}

#-----------------------------------------------------------------------------
@test 'warn multiline msg' {
  printf -v msg '%s\n%s' "$(random_string)" "$(random_string)"
  run warn "$msg"
  assert_output "$msg"
}

#-----------------------------------------------------------------------------
@test 'warn multi params' {
  msg1="$(random_string)"
  msg2="$(random_string)"
  msg3="$(random_string)"

  printf -v msg '%s\n' "$msg1" "$msg2"
  msg+="$msg3"

  run warn "$msg1" "$msg2" "$msg3"
  assert_output "$msg"
}

#-----------------------------------------------------------------------------
@test 'msg | warn' {
  msg=$(random_string)
  run echo $(echo "$msg" | warn 2>&1)
  assert_output "$msg"
}

#-----------------------------------------------------------------------------
@test 'multiline msg | warn' {
  printf -v msg '%s\n%s' "$(random_string)" "$(random_string)"
  msg+=$(random_string)
  run echo "$(echo "$msg" | warn 2>&1)"
  assert_output "$msg"
}

#-----------------------------------------------------------------------------
@test 'warn < file' {
  msg=$(random_string)
  file=$(mktemp -p "$BATS_RUN_TMPDIR")
  echo "$msg" > "$file"
  run warn < "$file"
  assert_output "$msg"
}

#-----------------------------------------------------------------------------
@test 'warn < multiline file' {
  file=$(mktemp -p "$BATS_RUN_TMPDIR")

  msg1="$(random_string)"
  msg2="$(random_string)"
  msg3="$(random_string)"

  printf -v msg '%s\n' "$msg1" "$msg2"
  msg+="$msg3"

  echo "$msg1" > "$file"
  echo "$msg2" >> "$file"
  echo "$msg3" >> "$file"

  run warn < "$file"
  assert_output "$msg"
}

#-----------------------------------------------------------------------------
@test 'warn <<< \$variable' {
  msg=$(random_string)
  run warn <<< "$msg"
  assert_output "$msg"
}
