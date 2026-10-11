#!/usr/bin/env bash
# Usage: ./tests/run_smoke_tests.sh [--static] [--dist DIR]
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST="$ROOT_DIR/dist"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --static)
      DIST="$ROOT_DIR/dist-static"
      shift
      ;;
    --dist)
      DIST="$(cd "$2" && pwd)"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

BIN="$DIST/bin/sqlite3"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass() { echo "ok: $*"; }
fail() {
  echo "FAIL: $*" >&2
  exit 1
}

version="$("$BIN" --version)"
echo "$version" | grep -q '^3\.' || fail "sqlite3 --version: $version"
pass "$version"

out="$(printf 'create table t (a, b);\ninsert into t values (6, 7);\nselect a * b from t;\n' | "$BIN" "$TMP/test.db")"
[ "$out" = 42 ] || fail "query result: $out"
pass "creates a database and queries it"

out="$("$BIN" :memory: "select json_extract('{\"a\": [1, 2]}', '$.a[1]');")"
[ "$out" = 2 ] || fail "JSON function: $out"
out="$("$BIN" :memory: "create virtual table f using fts5 (x); insert into f values ('hello world'); select count(*) from f where f match 'hello';")"
[ "$out" = 1 ] || fail "FTS5: $out"
pass "JSON and FTS5 are built in"

if [ "$(uname -s)" = Linux ] && ! LC_ALL=C grep -a -q 'ld-musl' "$BIN"; then
  max="$(LC_ALL=C grep -aoh 'GLIBC_2\.[0-9]*' "$BIN" | sort -uV | tail -n 1)" || true
  if [ -n "$max" ]; then
    [ "$(printf '%s\n' "$max" GLIBC_2.17 | sort -V | tail -n 1)" = GLIBC_2.17 ] \
      || fail "needs $max, newer than GLIBC_2.17"
    pass "glibc floor ($max)"
  fi
fi

echo "all smoke tests passed"
