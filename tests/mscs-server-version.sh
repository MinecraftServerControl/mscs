#!/bin/sh

# start with clean propfile
> "$propfile"

# --- getServerJar ---

# vanilla type (default): returns minecraft_server.VERSION.jar
(
  getServerCurrentVersion() { printf "1.21.4"; }
  getServerVersion() { printf "1.21.4"; }
  > "$propfile"
  got=$(getServerJar "$testworld")
  want="minecraft_server.1.21.4.jar"
  if [ "$got" != "$want" ]; then
    terr "getServerJar vanilla: got '$got' want '$want'"
  fi
)

# papermc type: returns paper.VERSION.jar
(
  getServerCurrentVersion() { printf "1.21.4"; }
  getServerVersion() { printf "1.21.4"; }
  printf "mscs-server-type=papermc\n" > "$propfile"
  got=$(getServerJar "$testworld")
  want="paper.1.21.4.jar"
  if [ "$got" != "$want" ]; then
    terr "getServerJar papermc: got '$got' want '$want'"
  fi
)

# explicit mscs-server-jar overrides the type-based default
(
  getServerCurrentVersion() { printf "1.21.4"; }
  getServerVersion() { printf "1.21.4"; }
  printf "mscs-server-jar=custom.jar\n" > "$propfile"
  got=$(getServerJar "$testworld")
  want="custom.jar"
  if [ "$got" != "$want" ]; then
    terr "getServerJar custom: got '$got' want '$want'"
  fi
)

# --- getServerURL ---

# explicit mscs-server-url is returned verbatim
(
  getServerCurrentVersion() { printf "1.21.4"; }
  getServerVersion() { printf "1.21.4"; }
  printf "mscs-server-url=https://example.com/server.jar\n" > "$propfile"
  got=$(getServerURL "$testworld")
  want="https://example.com/server.jar"
  if [ "$got" != "$want" ]; then
    terr "getServerURL explicit: got '$got' want '$want'"
  fi
)

# papermc type with no URL delegates to getPaperServerURL
(
  getServerCurrentVersion() { printf "1.21.4"; }
  getServerVersion() { printf "1.21.4"; }
  getPaperServerURL() { printf "https://papermc.test/paper.jar"; }
  printf "mscs-server-type=papermc\n" > "$propfile"
  got=$(getServerURL "$testworld")
  want="https://papermc.test/paper.jar"
  if [ "$got" != "$want" ]; then
    terr "getServerURL papermc fallback: got '$got' want '$want'"
  fi
)

# vanilla type with no URL delegates to getMinecraftVersionDownloadURL
(
  getServerCurrentVersion() { printf "1.21.4"; }
  getServerVersion() { printf "1.21.4"; }
  getMinecraftVersionDownloadURL() { printf "https://mojang.test/server.jar"; }
  > "$propfile"
  got=$(getServerURL "$testworld")
  want="https://mojang.test/server.jar"
  if [ "$got" != "$want" ]; then
    terr "getServerURL vanilla fallback: got '$got' want '$want'"
  fi
)

# --- getServerCommand ---

# command contains the jar name, server location, and -jar flag
(
  getCurrentMinecraftVersion() { printf "1.21.4"; }
  getServerVersion() { printf "1.21.4"; }
  getServerJar() { printf "minecraft_server.1.21.4.jar"; }
  getServerLocation() { printf "/opt/mscs/server"; }
  > "$propfile"
  got=$(getServerCommand "$testworld")
  if ! printf "%s" "$got" | grep -qs "minecraft_server.1.21.4.jar"; then
    terr "getServerCommand missing jar in: $got"
  fi
  if ! printf "%s" "$got" | grep -qs "/opt/mscs/server"; then
    terr "getServerCommand missing location in: $got"
  fi
  if ! printf "%s" "$got" | grep -qs -- "-jar"; then
    terr "getServerCommand missing -jar flag in: $got"
  fi
)

# clean up
> "$propfile"
