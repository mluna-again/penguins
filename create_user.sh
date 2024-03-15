#! /usr/bin/env bash

: # bash 5+ required
# shellcheck disable=SC2120
die() { [ -n "$*" ] && tostderr "$*"; exit 1; }
info() { printf "%s\n" "$*"; }
tostderr() { tput setaf 1 && printf "%s@%s: %s\n" "$0" "${BASH_LINENO[-2]}" "$*" >&2; tput sgr0; }
assert_installed() { command -v "$1" &>/dev/null || die "$1 is not installed."; }

usage() {
  cat - <<EOF
  Dependencies:
    - mycli (https://github.com/dbcli/mycli)

  Usage:

  # email is optional, defaults to mail@example.com
  ./create_user.sh <username> <password> [<email>]
EOF
}

if [ "$#" -lt 2 ]; then
  die "Missing username or password"
fi

declare username="$1" password="$2" email="${3:-mail@example.com}"
declare hashed_password

assert_installed mycli

hashed_password=$(./gocrypt "$password") || die

cat - <<EOF | mycli -D yukon -u root -h 127.0.0.1 || die
INSERT INTO users (username, password, email) VALUES ('$username', '$hashed_password', '$email');
EOF

info "User $username created :D"
