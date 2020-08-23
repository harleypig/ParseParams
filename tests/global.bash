#!/bin/bash

#-----------------------------------------------------------------------------
# Print notes in a TAP acceptable way.

note() {
  for line in "$@"; do
    printf '# %s\n' "$line" >&3
  done
}

#-----------------------------------------------------------------------------
# Generate random string

random_string() { tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 32 | head -n 1; }

#-----------------------------------------------------------------------------
# Load helpers

HELPERS_DIR="$HOME/.bats-helpers"
[[ -d $HELPERS_DIR ]] || {
  note "Helpers directory ($HELPERS_DIR) does not exist, failing all tests."
  exit 1
}

readarray -t HELPERS < <(find "$HOME"/.bats-helpers/*/src -iname '*.bash')

[[ ${#HELPERS[@]} -eq 0 ]] && {
  note "No helpers found, failing all tests."
  exit 1
}

for helper in "${HELPERS[@]}"; do
  source "$helper"
done

unset HELPERS_DIR HELPERS

#-----------------------------------------------------------------------------
# Use test_setup and test_setup_file for your own test file specific needs.

test_setup_file() { return 0; }
#test_setup() { return 0; }

setup_file() {
  note "--- Test file: $(basename "$BATS_TEST_FILENAME")"
  test_setup_file
}

#setup() {
#  # setup tempdir's
#  test_setup
#}
