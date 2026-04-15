#!/bin/sh

_vanilla_test_location=/tmp/mscs-vanillatest
_orig_versions_json="$VERSIONS_JSON"
VERSIONS_JSON="$_vanilla_test_location/version_manifest.json"
mkdir -p "$_vanilla_test_location"

cat > "$VERSIONS_JSON" << 'EOF'
{
  "latest": {"release": "1.21.4", "snapshot": "25w14a"},
  "versions": [
    {"id": "1.21.4", "releaseTime": "2024-12-03T10:00:00+00:00", "url": "https://example.com/1.21.4.json"},
    {"id": "25w14a", "releaseTime": "2025-04-02T10:00:00+00:00", "url": "https://example.com/25w14a.json"},
    {"id": "1.21.1", "releaseTime": "2024-08-08T10:00:00+00:00", "url": "https://example.com/1.21.1.json"}
  ]
}
EOF

# --- getCurrentMinecraftVersion ---

# returns the latest release version by default
: > "$propfile"
got=$(getCurrentMinecraftVersion "$testworld")
if [ "$got" != "1.21.4" ]; then
  terr "getCurrentMinecraftVersion release: got '$got' want '1.21.4'"
fi

# returns snapshot version when mscs-version-type=snapshot
printf "mscs-version-type=snapshot\n" > "$propfile"
got=$(getCurrentMinecraftVersion "$testworld")
if [ "$got" != "25w14a" ]; then
  terr "getCurrentMinecraftVersion snapshot: got '$got' want '25w14a'"
fi

# --- getMinecraftVersionReleaseTime ---

got=$(getMinecraftVersionReleaseTime "1.21.4")
if [ "$got" != "2024-12-03T10:00:00+00:00" ]; then
  terr "getMinecraftVersionReleaseTime 1.21.4: got '$got' want '2024-12-03T10:00:00+00:00'"
fi

got=$(getMinecraftVersionReleaseTime "1.21.1")
if [ "$got" != "2024-08-08T10:00:00+00:00" ]; then
  terr "getMinecraftVersionReleaseTime 1.21.1: got '$got' want '2024-08-08T10:00:00+00:00'"
fi

# --- getClientVersion ---

# returns current version by default when mscs-client-version is not set
(
  getCurrentMinecraftVersion() { printf "1.21.4"; }
  : > "$propfile"
  got=$(getClientVersion "$testworld")
  if [ "$got" != "1.21.4" ]; then
    terr "getClientVersion default: got '$got' want '1.21.4'"
  fi
)

# returns pinned version when mscs-client-version is set in propfile
(
  getCurrentMinecraftVersion() { printf "1.21.4"; }
  printf "mscs-client-version=1.20.4\n" > "$propfile"
  got=$(getClientVersion "$testworld")
  if [ "$got" != "1.20.4" ]; then
    terr "getClientVersion pinned: got '$got' want '1.20.4'"
  fi
)

# --- getClientJar ---

# returns VERSION.jar by default
(
  getCurrentMinecraftVersion() { printf "1.21.4"; }
  getClientVersion() { printf "1.21.4"; }
  : > "$propfile"
  got=$(getClientJar "$testworld")
  if [ "$got" != "1.21.4.jar" ]; then
    terr "getClientJar default: got '$got' want '1.21.4.jar'"
  fi
)

# returns custom jar when mscs-client-jar is configured
(
  getCurrentMinecraftVersion() { printf "1.21.4"; }
  getClientVersion() { printf "1.21.4"; }
  printf "mscs-client-jar=custom-client.jar\n" > "$propfile"
  got=$(getClientJar "$testworld")
  if [ "$got" != "custom-client.jar" ]; then
    terr "getClientJar custom: got '$got' want 'custom-client.jar'"
  fi
)

# --- getClientLocation ---

# returns path with version substituted (DEFAULT_CLIENT_LOCATION = $HOME/.minecraft/versions/$CLIENT_VERSION)
(
  getCurrentMinecraftVersion() { printf "1.21.4"; }
  getClientVersion() { printf "1.21.4"; }
  : > "$propfile"
  got=$(getClientLocation "$testworld")
  if ! printf "%s" "$got" | grep -qs "1.21.4"; then
    terr "getClientLocation default: '1.21.4' not found in '$got'"
  fi
)

# clean up
: > "$propfile"
rm -rf "$_vanilla_test_location"
VERSIONS_JSON="$_orig_versions_json"
