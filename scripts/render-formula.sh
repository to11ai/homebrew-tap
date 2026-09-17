#!/usr/bin/env bash
#
# Render Formula/to11.rb for one released CLI version.
#
# Checksums come from the release's own checksums.txt rather than being
# recomputed here, and each one is then checked against the bytes the archive
# actually contains — so a truncated or replaced upload fails here instead of
# at `brew install` on someone's machine.

set -euo pipefail

VERSION="${1:-}"

if [ -z "$VERSION" ]; then
  echo "usage: $0 <version>   e.g. $0 0.5.0" >&2
  exit 1
fi

# The version arrives from a repository_dispatch payload, so it is untrusted
# input that goes straight into a URL. Anything but a plain semver stops here.
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "version '$VERSION' must be <major>.<minor>.<patch>" >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="$REPO_ROOT/templates/to11.rb.tmpl"
OUTPUT="$REPO_ROOT/Formula/to11.rb"
BASE="https://github.com/to11ai/to11-cli/releases/download/v${VERSION}"

if command -v shasum >/dev/null 2>&1; then
  sha256() { shasum -a 256 "$1" | awk '{ print $1 }'; }
elif command -v sha256sum >/dev/null 2>&1; then
  sha256() { sha256sum "$1" | awk '{ print $1 }'; }
else
  echo "neither shasum nor sha256sum is available" >&2
  exit 1
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

curl -fsSL "${BASE}/checksums.txt" -o "$work/checksums.txt"

rendered="$(cat "$TEMPLATE")"
rendered="${rendered//@VERSION@/$VERSION}"

for platform in darwin_arm64 darwin_amd64 linux_arm64 linux_amd64; do
  archive="to11_${VERSION}_${platform}.tar.gz"

  declared="$(awk -v f="$archive" '$2 == f { print $1 }' "$work/checksums.txt")"
  if [ -z "$declared" ]; then
    echo "checksums.txt for v${VERSION} has no entry for ${archive}:" >&2
    cat "$work/checksums.txt" >&2
    exit 1
  fi

  curl -fsSL "${BASE}/${archive}" -o "$work/$archive"
  actual="$(sha256 "$work/$archive")"
  if [ "$actual" != "$declared" ]; then
    echo "${archive}: checksums.txt declares ${declared} but the archive hashes to ${actual}" >&2
    exit 1
  fi

  key="SHA256_$(printf '%s' "$platform" | tr '[:lower:]' '[:upper:]')"
  rendered="${rendered//@${key}@/$declared}"
done

# A leftover placeholder means the template grew a field the loop above does
# not fill. Catch it here rather than committing a formula brew cannot read.
if printf '%s\n' "$rendered" | grep -q '@[A-Z0-9_]\{1,\}@'; then
  echo "unsubstituted placeholder left in the rendered formula:" >&2
  printf '%s\n' "$rendered" | grep -n '@[A-Z0-9_]\{1,\}@' >&2
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"
printf '%s\n' "$rendered" >"$OUTPUT"
echo "rendered $OUTPUT for ${VERSION}"
