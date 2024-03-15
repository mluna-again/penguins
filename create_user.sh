#! /usr/bin/env bash

: # bash 5+ required
# shellcheck disable=SC2120
die() { [ -n "$*" ] && tostderr "$*"; exit 1; }
info() { printf "%s\n" "$*"; }
tostderr() { tput setaf 1 && printf "%s@%s: %s\n" "$0" "${BASH_LINENO[-2]}" "$*" >&2; tput sgr0; }
assert_installed() { command -v "$1" &>/dev/null || die "$1 is not installed."; }

declare -A colors
declare username password email
declare hashed_password color

colors[blue]=1
colors[green]=2
colors[pink]=3
colors[black]=4
colors[red]=5
colors[orange]=6
colors[yellow]=7
colors[purple]=8
colors[brown]=9
colors[salmon]=10
colors[white]=16

default_values() {
  if [ -z "$username" ]; then
    die Missing username
  fi

  if [ -z "$password" ]; then
    die Missing password
  fi

  if [ -z "$email" ]; then
    email="mail@example.com"
  fi

  if [ -z "$color" ]; then
    color=1
  fi
}

usage() {
  cat - <<EOF
  Dependencies:
    - mycli (https://github.com/dbcli/mycli)

  Usage:

  # email is optional, defaults to mail@example.com
  ./create_user.sh -u <username> -p <password> [-e <email>] [-c <color>]

  Available colors:
    * blue
    * green
    * pink
    * black
    * red
    * orange
    * yellow
    * purple
    * brown
    * salmon
    * white
EOF
}

assert_installed mycli

opts=$(getopt "u:p:ec" "$*") || die
set -- $opts

while :; do
  case "$1" in
    -c)
      c=${colors[$2]}
      if [ -z "$c" ]; then
        die "Invalid color: $2"
      fi
      color="$c"
      shift
      ;;

    -u)
      username="$2"
      shift
      ;;

    -p)
      password="$2"
      shift
      ;;

    -e)
      email="$2"
      shift
      ;;

    --)
      shift
      break
      ;;

    *)
      shift
      ;;

  esac
done

default_values

hashed_password=$(./gocrypt "$password") || die

cat - <<EOF | mycli -D yukon -u root -h 127.0.0.1 || die
INSERT INTO users (username, password, email, color) VALUES ('$username', '$hashed_password', '$email', '$color');
EOF

info "User $username created :D"
