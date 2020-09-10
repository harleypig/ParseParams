#!/usr/bin/env bats

load global

sourcedir="$(dirname $BATS_TEST_DIRNAME)"
testfile="$sourcedir/ParseParams"

nl=$'\n'

myexpected() {
  [[ $2 == "$3" ]] || {
    note "-- output differs for $1 --"
    note "expected : $2"
    note "actual   : $3"
    note '--'
    return 1
  }

  return 0
}

checkit() {
  success=0
  myexpected 'DEF_LINES' "$expected_def_lines" "$DEF_LINES"      || success=1
  myexpected 'POS_LINES' "$expected_pos_lines" "${POS_LINES[*]}" || success=1
  myexpected 'SHORTOPTS' "$expected_shortopts" "$SHORTOPTS"      || success=1
  myexpected 'LONGOPTS'  "$expected_longopts"  "$LONGOPTS"       || success=1
  return $success
}

##############################################################################
# Tests for __build_parms_info

#-----------------------------------------------------------------------------
@test 'no definition list' {
  source "$testfile"
  expected_out='No definitions were passed to _build_parms_info.'
  run _build_parms_info
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'empty definition list' {
  source "$testfile"
  expected_out='No definitions were passed to _build_parms_info.'
  run _build_parms_info ''
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'invalid require' {
  source "$testfile"
  shortopt="$(random_string 'alpha' 1)"
  badrequire="$(random_string)"
  defline="$shortopt,,,,$badrequire"
  expected_out="Only 'required', 'optional' or null is valid on definition line 0 ($defline)."
  run _build_parms_info "$defline"
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'invalid type' {
  source "$testfile"
  shortopt="$(random_string 'alpha' 1)"
  checktype="$(random_string)"
  defline="$shortopt,$checktype"
  expected_out="Invalid type (${checktype,,}) on definition line 0 ($defline)."
  run _build_parms_info "$defline"
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'too many options for positional' {
  source "$testfile"
  badoption="$(random_string)"
  defline="$POS_DEF|$badoption"
  expected_out="'$POS_DEF' must be the only option on definition line 0 ($defline)."
  run _build_parms_info "$defline"
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'too many options for positional (reversed)' {
  source "$testfile"
  shortopt="$(random_string)"
  defline="$shortopt|$POS_DEF"
  expected_out="'$POS_DEF' must be the only option on definition line 0 ($defline)."
  run _build_parms_info "$defline"
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'no variable with positional' {
  source "$testfile"
  defline="$POS_DEF"
  expected_out="Variable name is required when using position on definition line 0 ($defline)."
  run _build_parms_info "$defline"
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'invalid default varname' {
  source "$testfile"
  varname="$(random_string 'numeric' 1)$(random_string 8)"
  defline="$varname"
  expected_out="Invalid variable name ($varname) on definition line 0 ($defline)."
  run _build_parms_info "$varname"
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'invalid varname' {
  source "$testfile"
  varname="$(random_string 'numeric' 1)$(random_string 8)"
  defline="a,,$varname"
  expected_out="Invalid variable name ($varname) on definition line 0 ($defline)."
  run _build_parms_info "$defline"
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'repeated short option, same line' {
  source "$testfile"
  shortopt="$(random_string 'alpha' 1)"
  defline="$shortopt|$shortopt"
  expected_out="Repeated short option ($shortopt) on definition line 0 ($defline)."
  run _build_parms_info "$defline"
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'repeated short option, different lines' {
  source "$testfile"
  shortopt="$(random_string 'alpha' 1)"
  deflines="$shortopt$nl$shortopt"
  expected_out="Repeated short option ($shortopt) on definition line 1 ($shortopt)."
  run _build_parms_info "$deflines"
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'repeated long option, same line' {
  source "$testfile"
  longopt="$(random_string 'alpha' 8)"
  defline="$longopt|$longopt"
  expected_out="Repeated long option ($longopt) on definition line 0 ($defline)."
  run _build_parms_info "$defline"
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'repeated long option, different lines' {
  source "$testfile"
  longopt="$(random_string 'alpha' 8)"
  deflines="$longopt$nl$longopt"
  expected_out="Repeated long option ($longopt) on definition line 1 ($longopt)."
  run _build_parms_info "$deflines"
  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'basic short defaults' {
  source "$testfile"

  shortopt="$(random_string 'alpha' 1)"
  defline="$shortopt"

  expected_def_lines="$shortopt,string,$shortopt,,optional$nl"
  expected_pos_lines=''
  expected_shortopts="$shortopt:"
  expected_longopts=''

  _build_parms_info "$defline"

  checkit
}

#-----------------------------------------------------------------------------
@test 'basic long defaults' {
  source "$testfile"

  longopt="$(random_string 'alpha' 8)"
  defline="$longopt"

  expected_def_lines="$longopt,string,$longopt,,optional$nl"
  expected_pos_lines=''
  expected_shortopts=''
  expected_longopts="$longopt:"

  _build_parms_info "$defline"

  checkit
}

#-----------------------------------------------------------------------------
@test 'basic both defaults' {
  source "$testfile"

  shortopt="$(random_string 'alpha' 1)"
  longopt="$(random_string 'alpha' 8)"
  defline="$shortopt|$longopt"

  expected_def_lines="$defline,string,$longopt,,optional$nl"
  expected_pos_lines=''
  expected_shortopts="$shortopt:"
  expected_longopts="$longopt:"

  _build_parms_info "$defline"

  checkit
}

#-----------------------------------------------------------------------------
@test 'basic positional defaults' {
  source "$testfile"

  varname="$(random_string 8)"
  defline="#,,$varname"

  expected_def_lines=''
  expected_pos_lines="string,$varname"
  expected_shortopts=''
  expected_longopts=''

  _build_parms_info "$defline"

  checkit
}

#-----------------------------------------------------------------------------
@test 'both basic and positional defaults' {
  source "$testfile"

  varname="$(random_string 'alpha' 1)$(random_string 8)"
  defline="#,,$varname"

  expected_def_lines=''
  expected_pos_lines="string,$varname"
  expected_shortopts=''
  expected_longopts=''

  _build_parms_info "$defline"

  checkit
}

#-----------------------------------------------------------------------------
@test 'boolean type (no required field)' {
  source "$testfile"

  shortopt="$(random_string 'alpha' 1)"
  checktype='boolean'
  defline="$shortopt,$checktype"

  expected_def_lines="$shortopt,$checktype,$shortopt,,optional$nl"
  expected_pos_lines=''
  expected_shortopts="$shortopt"
  expected_longopts=''

  _build_parms_info "$defline"

  checkit
}

#-----------------------------------------------------------------------------
@test 'boolean type (required is forced to optional)' {
  source "$testfile"

  shortopt="$(random_string 'alpha' 1)"
  checktype='boolean'
  defline="$shortopt,$checktype,,,required"

  expected_def_lines="$shortopt,$checktype,$shortopt,,optional$nl"
  expected_pos_lines=''
  expected_shortopts="$shortopt"
  expected_longopts=''

  _build_parms_info "$defline"

  checkit
}

#-----------------------------------------------------------------------------
@test 'short defaults with required' {
  source "$testfile"

  shortopt="$(random_string 'alpha' 1)"
  defline="$shortopt,,,,required"

  expected_def_lines="$shortopt,string,$shortopt,,required$nl"
  expected_pos_lines=''
  expected_shortopts="$shortopt:"
  expected_longopts=''

  _build_parms_info "$defline"

  checkit
}

#-----------------------------------------------------------------------------
@test 'long defaults with required' {
  source "$testfile"

  longopt="$(random_string 'alpha' 1)$(random_string 8)"
  defline="$longopt,,,,required"

  expected_def_lines="$longopt,string,$longopt,,required$nl"
  expected_pos_lines=''
  expected_shortopts=''
  expected_longopts="$longopt:"

  _build_parms_info "$defline"

  checkit
}

#-----------------------------------------------------------------------------
@test 'both short and long defaults with required' {
  source "$testfile"

  shortopt="$(random_string 'alpha' 1)"
  longopt="$(random_string 'alpha' 1)$(random_string 8)"
  defline="$shortopt|$longopt,,,,required"

  expected_def_lines="$shortopt|$longopt,string,$longopt,,required$nl"
  expected_pos_lines=''
  expected_shortopts="$shortopt:"
  expected_longopts="$longopt:"

  _build_parms_info "$defline"

  checkit
}

#-----------------------------------------------------------------------------
@test 'short defaults with default' {
  source "$testfile"

  shortopt="$(random_string 'alpha' 1)"
  default="$(random_string)"
  defline="$shortopt,,,$default"

  expected_def_lines="$shortopt,string,$shortopt,$default,optional$nl"
  expected_pos_lines=''
  expected_shortopts="$shortopt:"
  expected_longopts=''

  _build_parms_info "$defline"

  checkit
}

#-----------------------------------------------------------------------------
@test 'long defaults with default' {
  source "$testfile"

  longopt="$(random_string 'alpha' 1)$(random_string 8)"
  default="$(random_string)"
  defline="$longopt,,,$default"

  expected_def_lines="$longopt,string,$longopt,$default,optional$nl"
  expected_pos_lines=''
  expected_shortopts=''
  expected_longopts="$longopt:"

  _build_parms_info "$defline"

  checkit
}

#-----------------------------------------------------------------------------
@test 'both short and long defaults with default' {
  source "$testfile"

  shortopt="$(random_string 'alpha' 1)"
  longopt="$(random_string 'alpha' 1)$(random_string 8)"
  default="$(random_string)"
  defline="$shortopt|$longopt,,,$default"

  expected_def_lines="$shortopt|$longopt,string,$longopt,$default,optional$nl"
  expected_pos_lines=''
  expected_shortopts="$shortopt:"
  expected_longopts="$longopt:"

  _build_parms_info "$defline"

  checkit
}

#-----------------------------------------------------------------------------
@test 'short option, type, var' {
  source "$testfile"

  shortopt="$(random_string 'alpha' 1)"
  checktype='char'
  varname="$(random_string 'alpha' 1)$(random_string 8)"
  defline="$shortopt,$checktype,$varname"

  expected_def_lines="$shortopt,$checktype,$varname,,optional$nl"
  expected_pos_lines=''
  expected_shortopts="$shortopt:"
  expected_longopts=''

  _build_parms_info "$defline"

  checkit
}

#-----------------------------------------------------------------------------
@test 'long option, type, var' {
  source "$testfile"

  longopt="$(random_string 'alpha' 1)$(random_string 8)"
  checktype='char'
  varname="$(random_string 'alpha' 1)$(random_string 8)"
  defline="$longopt,$checktype,$varname"

  expected_def_lines="$longopt,$checktype,$varname,,optional$nl"
  expected_pos_lines=''
  expected_shortopts=''
  expected_longopts="$longopt:"

  _build_parms_info "$defline"

  checkit
}

#-----------------------------------------------------------------------------
@test 'both option, type, var' {
  source "$testfile"

  shortopt="$(random_string 'alpha' 1)"
  longopt="$(random_string 'alpha' 1)$(random_string 8)"
  checktype='char'
  varname="$(random_string 'alpha' 1)$(random_string 8)"
  defline="$shortopt|$longopt,$checktype,$varname"

  expected_def_lines="$shortopt|$longopt,$checktype,$varname,,optional$nl"
  expected_pos_lines=''
  expected_shortopts="$shortopt:"
  expected_longopts="$longopt:"

  _build_parms_info "$defline"

  checkit
}

#-----------------------------------------------------------------------------
@test 'bad char default fails' {
  source "$testfile"

  shortopt="$(random_string 'alpha' 1)"
  checktype='char'
  varname="$(random_string 'alpha' 1)$(random_string 8)"
  checkvalue="$(random_string)"
  defline="$shortopt,$checktype,$varname,$checkvalue"

  expected_out="default value ($checkvalue) does not pass type check on definition line 0 ($defline)."

  run _build_parms_info "$defline"

  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'good char default succeeds' {
  source "$testfile"

  shortopt="$(random_string 'alpha' 1)"
  checktype='char'
  varname="$(random_string 'alpha' 1)$(random_string 8)"
  checkvalue="$(random_string 1)"
  defline="$shortopt,$checktype,$varname,$checkvalue"

  run _build_parms_info "$defline"

  assert_success
  assert_output ''
}

#-----------------------------------------------------------------------------
@test 'bad integer default fails' {
  source "$testfile"

  shortopt="$(random_string 'alpha' 1)"
  checktype='integer'
  varname="$(random_string 'alpha' 1)$(random_string 8)"
  checkvalue="$(random_string 5)"
  defline="$shortopt,$checktype,$varname,$checkvalue"

  expected_out="default value ($checkvalue) does not pass type check on definition line 0 ($defline)."

  run _build_parms_info "$defline"

  assert_failure
  assert_output "$expected_out"
}

#-----------------------------------------------------------------------------
@test 'good integer default succeeds' {
  source "$testfile"

  shortopt="$(random_string 'alpha' 1)"
  checktype='integer'
  varname="$(random_string 'alpha' 1)$(random_string 8)"
  checkvalue="$(random_string numeric 5)"
  defline="$shortopt,$checktype,$varname,$checkvalue"

  run _build_parms_info "$defline"

  assert_success
  assert_output ''
}
