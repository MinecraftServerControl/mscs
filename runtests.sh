#!/bin/sh
# do some unit testing

# print the error to stderr prefixed with caller info
terr () {
    echo "$caller:" $@ >&2
}

# get variable values and functions for testing
. ./msctl

# override some vars from msctl with values that allow testing


# funcs like getMSCSValue have local vars based on WORLDS_LOCATION.
WORLDS_LOCATION=/tmp
testworld="mscs-testdata"
# tests will write to this propfile to verify parsing etc.
propfile="$WORLDS_LOCATION/$testworld/mscs.properties"
mkdir -p $(dirname $propfile) || exit 1

# run the tests; no news is good news!
for t in tests/*; do
    caller=`basename "$t"`
    . "$t"
done
