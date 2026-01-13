#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir"

rm -rf dist ralph.tar.gz ralph.zip
mkdir -p dist/ralph

rsync -a \
  --exclude '.git' \
  --exclude '.github' \
  --exclude 'dist' \
  --exclude 'node_modules' \
  --exclude 'tests' \
  bin \
  .agents \
  skills \
  README.md \
  dist/ralph/

tar -czf ralph.tar.gz -C dist ralph
(cd dist && zip -r ../ralph.zip ralph)

echo "Built ralph.tar.gz and ralph.zip"
