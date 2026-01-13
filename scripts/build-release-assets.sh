#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir"

if ! command -v npm >/dev/null 2>&1; then
  echo "npm is required to build release assets." >&2
  exit 1
fi

rm -rf dist ralph.tar.gz ralph.zip

npm ci --omit=dev

mkdir -p dist/ralph
rsync -a \
  --exclude '.git' \
  --exclude '.github' \
  --exclude 'dist' \
  --exclude 'tests' \
  bin \
  .agents \
  skills \
  node_modules \
  package.json \
  package-lock.json \
  README.md \
  dist/ralph/

tar -czf ralph.tar.gz -C dist ralph
(cd dist && zip -r ../ralph.zip ralph)

echo "Built ralph.tar.gz and ralph.zip"
