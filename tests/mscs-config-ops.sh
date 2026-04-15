#!/bin/sh

_cfg=/tmp/mscs-configtest.properties

# clean start
rm -f "$_cfg"

# --- getValue ---

# key present returns value
printf "mykey=myvalue\n" > "$_cfg"
got=$(getValue "$_cfg" "mykey" "default")
if [ "$got" != "myvalue" ]; then
  terr "getValue key present: got '$got' want 'myvalue'"
fi

# key absent returns default
printf "otherkey=othervalue\n" > "$_cfg"
got=$(getValue "$_cfg" "mykey" "thedefault")
if [ "$got" != "thedefault" ]; then
  terr "getValue key absent: got '$got' want 'thedefault'"
fi

# file does not exist returns default
rm -f "$_cfg"
got=$(getValue "$_cfg" "mykey" "thedefault")
if [ "$got" != "thedefault" ]; then
  terr "getValue no file: got '$got' want 'thedefault'"
fi

# empty value returns default ([ -n "$KEY" ] && [ -n "$VALUE" ] requires both non-empty)
printf "mykey=\n" > "$_cfg"
got=$(getValue "$_cfg" "mykey" "thedefault")
if [ "$got" != "thedefault" ]; then
  terr "getValue empty value: got '$got' want 'thedefault'"
fi

# key matching is case-insensitive
printf "MYKEY=myvalue\n" > "$_cfg"
got=$(getValue "$_cfg" "mykey" "default")
if [ "$got" != "myvalue" ]; then
  terr "getValue case-insensitive: got '$got' want 'myvalue'"
fi

# hash comment lines are ignored
printf "# mykey=commented\n" > "$_cfg"
got=$(getValue "$_cfg" "mykey" "default")
if [ "$got" != "default" ]; then
  terr "getValue hash comment: got '$got' want 'default'"
fi

# semicolon comment lines are ignored
printf "; mykey=commented\n" > "$_cfg"
got=$(getValue "$_cfg" "mykey" "default")
if [ "$got" != "default" ]; then
  terr "getValue semicolon comment: got '$got' want 'default'"
fi

# double quotes are stripped from value
printf 'mykey="quoted-value"\n' > "$_cfg"
got=$(getValue "$_cfg" "mykey" "default")
if [ "$got" != "quoted-value" ]; then
  terr "getValue double-quote strip: got '$got' want 'quoted-value'"
fi

# single quotes are stripped from value
printf "mykey='quoted-value'\n" > "$_cfg"
got=$(getValue "$_cfg" "mykey" "default")
if [ "$got" != "quoted-value" ]; then
  terr "getValue single-quote strip: got '$got' want 'quoted-value'"
fi

# spaces around = are handled
printf "mykey = spaced-value\n" > "$_cfg"
got=$(getValue "$_cfg" "mykey" "default")
if [ "$got" != "spaced-value" ]; then
  terr "getValue spaces around =: got '$got' want 'spaced-value'"
fi

# default with leading hyphen is returned verbatim (printf -- prevents flag misinterpretation)
rm -f "$_cfg"
got=$(getValue "$_cfg" "mykey" "-Dfoo=bar")
if [ "$got" != "-Dfoo=bar" ]; then
  terr "getValue hyphen default: got '$got' want '-Dfoo=bar'"
fi

# --- setValue ---

# new key is appended to an empty file
: > "$_cfg"
setValue "$_cfg" "newkey" "newvalue"
if ! grep -qs "^newkey=newvalue$" "$_cfg"; then
  terr "setValue append: file contents: $(cat "$_cfg")"
fi

# existing key is updated in-place
printf "mykey=old\n" > "$_cfg"
setValue "$_cfg" "mykey" "new"
got=$(getValue "$_cfg" "mykey" "default")
if [ "$got" != "new" ]; then
  terr "setValue update: got '$got' want 'new'"
fi

# other keys are preserved when one key is updated
printf "key1=a\nkey2=b\n" > "$_cfg"
setValue "$_cfg" "key1" "x"
got=$(getValue "$_cfg" "key2" "default")
if [ "$got" != "b" ]; then
  terr "setValue preserves others: key2 got '$got' want 'b'"
fi

# file is created when it does not exist
rm -f "$_cfg"
setValue "$_cfg" "newkey" "newvalue"
if [ ! -f "$_cfg" ]; then
  terr "setValue creates file: file not found at $_cfg"
fi
got=$(getValue "$_cfg" "newkey" "default")
if [ "$got" != "newvalue" ]; then
  terr "setValue creates file value: got '$got' want 'newvalue'"
fi

# clean up
rm -f "$_cfg"
