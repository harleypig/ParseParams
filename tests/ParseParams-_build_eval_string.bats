#!/usr/bin/env bats

load global

sourcedir="$(dirname $BATS_TEST_DIRNAME)"
testfile="$sourcedir/ParseParams"

##############################################################################
# Tests for __build_eval_string

#-----------------------------------------------------------------------------
@test 'dump' {
  skip 'not dumping'
  source "$testfile"
  _normalize_definitions '
a,string,bcd,firstdefault
efg,char,h,s
i|jkl,integer,mno,5,required
p,boolean,q
o|two|three,string
#,,rst
#,,uvw'

  run _build_eval_string
  assert_success
  assert_output ''
}
