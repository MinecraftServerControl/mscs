#!/bin/sh

# Use an isolated directory so getEnabledWorlds/getDisabledWorlds only see our
# test worlds, not every directory in /tmp.
_orig_worlds_location="$WORLDS_LOCATION"
WORLDS_LOCATION=/tmp/mscs-lifecycletest
rm -rf "$WORLDS_LOCATION"
mkdir -p "$WORLDS_LOCATION"

_lc_world="lc-testworld"
_sprops="$WORLDS_LOCATION/$_lc_world/server.properties"
_mprops="$WORLDS_LOCATION/$_lc_world/mscs.properties"

# createWorld creates the world directory
createWorld "$_lc_world" 25565 ""
if [ ! -d "$WORLDS_LOCATION/$_lc_world" ]; then
  terr "createWorld: world directory not created"
fi

# createWorld writes correct values to server.properties
for _kv in "server-port=25565" "enable-query=true" "query.port=25565" "level-name=$_lc_world"; do
  if ! grep -qs "^$_kv" "$_sprops"; then
    terr "createWorld: server.properties missing '$_kv'"
  fi
done

# createWorld enables the world in mscs.properties
if ! grep -qs "^mscs-enabled=true" "$_mprops"; then
  terr "createWorld: mscs.properties missing mscs-enabled=true"
fi

# getEnabledWorlds includes the new world
_worlds=$(getEnabledWorlds)
if ! listContains "$_lc_world" "$_worlds"; then
  terr "getEnabledWorlds: expected '$_lc_world' in '$_worlds'"
fi

# isWorldEnabled returns success for an enabled world
if ! isWorldEnabled "$_lc_world"; then
  terr "isWorldEnabled: expected true for '$_lc_world'"
fi

# disableWorld sets mscs-enabled=false
disableWorld "$_lc_world"
if ! grep -qs "^mscs-enabled=false" "$_mprops"; then
  terr "disableWorld: mscs.properties missing mscs-enabled=false"
fi

# isWorldEnabled returns failure after disableWorld
if isWorldEnabled "$_lc_world"; then
  terr "isWorldEnabled: expected false after disableWorld"
fi

# isWorldDisabled returns success after disableWorld
if ! isWorldDisabled "$_lc_world"; then
  terr "isWorldDisabled: expected true after disableWorld"
fi

# getDisabledWorlds includes the world; getEnabledWorlds does not
_disabled=$(getDisabledWorlds)
_enabled=$(getEnabledWorlds)
if ! listContains "$_lc_world" "$_disabled"; then
  terr "getDisabledWorlds: expected '$_lc_world' in '$_disabled'"
fi
if listContains "$_lc_world" "$_enabled"; then
  terr "getEnabledWorlds: expected '$_lc_world' absent from '$_enabled'"
fi

# enableWorld restores the world to enabled
enableWorld "$_lc_world"
if ! isWorldEnabled "$_lc_world"; then
  terr "isWorldEnabled: expected true after enableWorld"
fi

# deleteWorld removes the world directory
deleteWorld "$_lc_world"
if [ -d "$WORLDS_LOCATION/$_lc_world" ]; then
  terr "deleteWorld: world directory still exists"
fi

# clean up
rm -rf "$WORLDS_LOCATION"
WORLDS_LOCATION="$_orig_worlds_location"
