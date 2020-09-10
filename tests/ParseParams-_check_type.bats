#!/usr/bin/env bats

load global

sourcedir="$(dirname $BATS_TEST_DIRNAME)"
testfile="$sourcedir/ParseParams"

##############################################################################
# Tests for _check_type

#-----------------------------------------------------------------------------
@test '[null] fails' {
  expected_out='must pass type name and value to _check_type'
  source "$testfile"
  run _check_type
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'one parm fails' {
  expected_out='must pass type name and value to _check_type'
  source "$testfile"
  run _check_type 'one'
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'too many parms fails' {
  expected_out='must pass type name and value to _check_type'
  source "$testfile"
  run _check_type 'one' 'two' 'three'
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test '\"\" \"\" fails' {
  expected_out='cannot pass empty type to _check_type'
  source "$testfile"
  run _check_type '' ''
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test '\"\" \"abc\" fails' {
  expected_out='cannot pass empty type to _check_type'
  source "$testfile"
  run _check_type '' 'gigglesnort'
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'boolean \"\" fails' {
  expected_out="Invalid type (boolean is handled differently)"
  source "$testfile"
  run _check_type 'boolean' ''
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'boolean \"abc\" fails' {
  expected_out="Invalid type (boolean is handled differently)"
  source "$testfile"
  run _check_type 'boolean' 'two'
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'typenotinarray \"\" fails' {
  badtype="$(random_string)"
  expected_out="Invalid type (${badtype,,}), it must exist and not be null or empty"
  source "$testfile"
  run _check_type "$badtype" 'gigglesnort'
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'typenullinarray \"\" fails' {
  badtype="$(random_string)"
  expected_out="Invalid type (${badtype,,}), it must exist and not be null or empty"
  source "$testfile"
  TYPES["$badtype"]=
  run _check_type "$badtype" 'gigglesnort'
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'typeemptyinarray \"\" fails' {
  badtype="$(random_string)"
  expected_out="Invalid type (${badtype,,}), it must exist and not be null or empty"
  source "$testfile"
  TYPES["$badtype"]=''
  run _check_type "$badtype" 'gigglesnort'
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'string \"\" fails' {
  source "$testfile"
  checkstring=
  run _check_type 'string' "$checkstring"
  assert_failure
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'string \"abc\" succeeds' {
  source "$testfile"
  checkstring="$(random_string)"
  run _check_type 'string' "$checkstring"
  assert_success
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'integer \"\" fails' {
  source "$testfile"
  checkstring=
  run _check_type 'integer' "$checkstring"
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'integer \"123\" succeeds' {
  source "$testfile"
  checkstring="$(random_string numeric 5)"
  run _check_type 'integer' "$checkstring"
  assert_success
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'char \"\" fails' {
  source "$testfile"
  checkstring=
  run _check_type 'char' "checkstring"
  assert_failure
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'char \"ab\" fails' {
  source "$testfile"
  checkstring="$(random_string)"
  run _check_type 'char' "checkstring"
  assert_failure
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'char \"a\" succeeds' {
  source "$testfile"
  checkstring="$(random_string 1)"
  run _check_type 'char' "$checkstring"
  assert_success
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'nosuchfunc \"value\" fails' {
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
