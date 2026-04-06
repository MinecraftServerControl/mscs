#!/bin/sh

_paper_test_location=/tmp/mscs-papertest
mkdir -p "$_paper_test_location"
_orig_paper_project_json="${PAPER_PROJECT_JSON}"
_orig_location="${LOCATION}"
PAPER_PROJECT_JSON="$_paper_test_location/paper_project.json"
LOCATION="$_paper_test_location"

# Fixture: project JSON with mixed releases and pre-releases across two families
cat > "$PAPER_PROJECT_JSON" << 'EOF'
{
  "versions": {
    "1.20": ["1.20.4", "1.20.2"],
    "1.21": ["1.21.4", "1.21.1", "1.21-pre2", "1.21-rc1"]
  }
}
EOF

# getCurrentPaperVersion returns the latest non-pre-release from the latest family
got=$(getCurrentPaperVersion)
want="1.21.4"
if [ "$got" != "$want" ]; then
  terr "getCurrentPaperVersion: got '$got' want '$want'"
fi

# getCurrentPaperVersion skips pre-releases even when they appear before a release
cat > "$PAPER_PROJECT_JSON" << 'EOF'
{
  "versions": {
    "1.21": ["1.21-rc2", "1.21.4", "1.21.1"]
  }
}
EOF
got=$(getCurrentPaperVersion)
want="1.21.4"
if [ "$got" != "$want" ]; then
  terr "getCurrentPaperVersion pre-release-first: got '$got' want '$want'"
fi

# Fixture: builds JSON with STABLE and BETA channels
cat > "$_paper_test_location/paper_builds_1.21.4.json" << 'EOF'
[
  {
    "channel": "BETA",
    "downloads": {
      "server:default": {
        "url": "https://test.example.com/paper-1.21.4-101.jar",
        "checksums": { "sha256": "betachecksum123" }
      }
    }
  },
  {
    "channel": "STABLE",
    "downloads": {
      "server:default": {
        "url": "https://test.example.com/paper-1.21.4-100.jar",
        "checksums": { "sha256": "stablechecksum456" }
      }
    }
  }
]
EOF

# getPaperServerURL returns the URL for the STABLE channel (default)
(
  getServerVersion() { printf "1.21.4"; }
  > "$propfile"
  got=$(getPaperServerURL "$testworld")
  want="https://test.example.com/paper-1.21.4-100.jar"
  if [ "$got" != "$want" ]; then
    terr "getPaperServerURL STABLE: got '$got' want '$want'"
  fi
)

# getPaperServerURL returns the URL for the BETA channel when configured
(
  getServerVersion() { printf "1.21.4"; }
  printf "mscs-paper-channel=BETA\n" > "$propfile"
  got=$(getPaperServerURL "$testworld")
  want="https://test.example.com/paper-1.21.4-101.jar"
  if [ "$got" != "$want" ]; then
    terr "getPaperServerURL BETA: got '$got' want '$want'"
  fi
)

# getPaperServerChecksum returns the SHA256 for the STABLE channel
(
  getServerVersion() { printf "1.21.4"; }
  > "$propfile"
  got=$(getPaperServerChecksum "$testworld")
  want="stablechecksum456"
  if [ "$got" != "$want" ]; then
    terr "getPaperServerChecksum STABLE: got '$got' want '$want'"
  fi
)

# getCurrentPaperVersion skips a version family that has no STABLE builds
cat > "$PAPER_PROJECT_JSON" << 'EOF'
{
  "versions": {
    "26.1": ["26.1.1"],
    "1.21": ["1.21.11", "1.21.10"]
  }
}
EOF
cat > "$_paper_test_location/paper_builds_26.1.1.json" << 'EOF'
[{"channel": "ALPHA", "downloads": {"server:default": {"url": "https://test.example.com/paper-26.1.1-1.jar", "checksums": {"sha256": "alphachecksum"}}}}]
EOF
cat > "$_paper_test_location/paper_builds_1.21.11.json" << 'EOF'
[{"channel": "STABLE", "downloads": {"server:default": {"url": "https://test.example.com/paper-1.21.11-128.jar", "checksums": {"sha256": "stablechecksum"}}}}]
EOF
got=$(getCurrentPaperVersion)
want="1.21.11"
if [ "$got" != "$want" ]; then
  terr "getCurrentPaperVersion alpha-family: got '$got' want '$want'"
fi

# clean up
> "$propfile"
rm -rf "$_paper_test_location"
PAPER_PROJECT_JSON="$_orig_paper_project_json"
LOCATION="$_orig_location"
