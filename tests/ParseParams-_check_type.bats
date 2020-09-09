#!/usr/bin/env bats

load global

sourcedir="$(dirname $BATS_TEST_DIRNAME)"
testfile="$sourcedir/ParseParams"

##############################################################################
# Tests for _check_type

#-----------------------------------------------------------------------------
@test '[null]' {
  expected_out='must pass variable name and type name to _check_type'
  source "$testfile"
  run _check_type
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'one parm' {
  expected_out='must pass variable name and type name to _check_type'
  source "$testfile"
  run _check_type 'one'
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'too many parms' {
  expected_out='must pass variable name and type name to _check_type'
  source "$testfile"
  run _check_type 'one' 'two' 'three'
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test '\"\" \"\"' {
  expected_out='cannot pass empty values to _check_type'
  source "$testfile"
  run _check_type '' ''
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test '\"abc\" \"\"' {
  expected_out='cannot pass empty values to _check_type'
  source "$testfile"
  run _check_type 'gigglesnort' ''
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test '\"\" \"abc\"' {
  expected_out='cannot pass empty values to _check_type'
  source "$testfile"
  run _check_type '' 'gigglesnort'
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'boolean \"\"' {
  expected_out="Invalid type (boolean is handled differently)"
  source "$testfile"
  run _check_type 'boolean' 'two'
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'typenotinarray \"\"' {
  badtype="$(random_string)"
  expected_out="Invalid type (${badtype,,}), it must exist and not be null or empty"
  source "$testfile"
  run _check_type "$badtype" 'gigglesnort'
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'typenullinarray \"\"' {
  badtype="$(random_string)"
  expected_out="Invalid type (${badtype,,}), it must exist and not be null or empty"
  source "$testfile"
  TYPES["$badtype"]=
  run _check_type "$badtype" 'gigglesnort'
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'typeemptyinarray \"\"' {
  badtype="$(random_string)"
  expected_out="Invalid type (${badtype,,}), it must exist and not be null or empty"
  source "$testfile"
  TYPES["$badtype"]=''
  run _check_type "$badtype" 'gigglesnort'
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'string \"\"' {
  source "$testfile"
  badstring=
  run _check_type 'string' "badstring"
  assert_failure
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'string \"abc\"' {
  source "$testfile"
  badstring="$(random_string)"
  run _check_type 'string' "badstring"
  assert_success
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'char \"\"' {
  source "$testfile"
  badstring=
  run _check_type 'char' "badstring"
  assert_failure
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'char \"ab\"' {
  source "$testfile"
  badstring="$(random_string)"
  run _check_type 'char' "badstring"
  assert_failure
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'char \"a\"' {
  source "$testfile"
  badstring="$(random_string 1)"
  run _check_type 'char' "badstring"
  assert_success
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'nosuchfunc \"value\"' {
  nosuchfunc="$(random_string)"
  expected_out="$nosuchfunc does not appear to be a command or function"
  source "$testfile"
  TYPES['customfunc']="$nosuchfunc"
  run _check_type 'customfunc' 'gigglesnort'
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'customfunc \"value\" fail' {
  mycustomfunc() { false; }
  source "$testfile"
  TYPES['customfunc']='mycustomfunc'
  run _check_type 'customfunc' 'gigglesnort'
  assert_failure
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'customfunc \"value\" success' {
  mycustomfunc() { true; }
  source "$testfile"
  TYPES['customfunc']='mycustomfunc'
  run _check_type 'customfunc' 'gigglesnort'
  assert_success
  assert_output ''
}
