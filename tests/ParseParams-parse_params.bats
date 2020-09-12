#!/usr/bin/env bats

load global

sourcedir="$(dirname $BATS_TEST_DIRNAME)"
testfile="$sourcedir/ParseParams"

# ??? eval set -- \"\$ARGS\"

##############################################################################
# Tests for parse_param

#-----------------------------------------------------------------------------
@test 'no parms fails' {
  expected_output='No definitions were passed to parse_params.'
  source "$testfile"
  run parse_params
  assert_failure
  assert_output "$expected_output"
}

#-----------------------------------------------------------------------------
@test 'no arguments fails' {
  expected_output='no parms to check'
  source "$testfile"
  run parse_params 'a'
  assert_failure
  assert_output "$expected_output"
}

#-----------------------------------------------------------------------------
@test 'empty arguments succeeds' {
  source "$testfile"
  run parse_params 'a' ''
  assert_success
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'no arguments in \$@ fails' {
  expected_output='no parms to check'
  source "$testfile"
  run parse_params 'a' "$@"
  assert_failure
  assert_output "$expected_output"
}

#-----------------------------------------------------------------------------
@test 'empty argument for required parm in \$@ fails' {
  source "$testfile"
  option="$(random_string 'alpha' 1)$(random_string 8)"
  defline="$option,,,,required"
  expected_output="'--$option' requires a value."
  eval set -- "-$option"
  run parse_params "$defline" "$@"
  assert_failure
  assert_output "$expected_output"
}

#-----------------------------------------------------------------------------
@test 'empty argument for required parm in passed in values fails' {
  source "$testfile"
  option="$(random_string 'alpha' 1)$(random_string 8)"
  defline="$option,,,,required"
  expected_output="'--$option' requires a value."
  run parse_params "$defline" "-$option"
  assert_failure
  assert_output "$expected_output"
}

#-----------------------------------------------------------------------------
@test 'invalid option fails' {
  source "$testfile"
  option="$(random_string 'alpha' 1)$(random_string 8)"
  invalid="$(random_string 'alpha' 1)$(random_string 8)"
  defline="$option,,,,required"
  expected_output="'-$invalid' is an unknown option."
  run parse_params "$defline" "-$invalid"
  assert_failure
  assert_output "$expected_output"
}

#-----------------------------------------------------------------------------
@test 'boolean option not in passed values is 1' {
  source "$testfile"
  option="$(random_string 'alpha' 1)"
  defline="$option,boolean"
  parse_params "$defline" ''
  [[ $? == 0 ]]
  [[ ${!option} -eq 1 ]]
}

#-----------------------------------------------------------------------------
@test 'boolean option passed in values is 0' {
  source "$testfile"
  option="$(random_string 'alpha' 1)"
  defline="$option,boolean"
  parse_params "$defline" "-$option"
  [[ $? == 0 ]]
  [[ ${!option} -eq 0 ]]
}

#-----------------------------------------------------------------------------
@test 'string option passed in matches (spaces)' {
  source "$testfile"
  option="$(random_string 'alpha' 1)"
  value="$(random_string 12)"
  defline="$option,,,,required"
  eval set -- "-$option $value"
  DEBUG=1
  parse_params "$defline" "-$option" "$value"
  [[ $? == 0 ]]
  [[ ${!option} == "$value" ]]
}
