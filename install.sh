#!/usr/bin/env bash
set -euo pipefail

REPO="${RALPH_REPO:-JCaraballo113/ralph-cli}"
VERSION="${RALPH_VERSION:-latest}"
PREFIX="${RALPH_PREFIX:-$HOME/.local}"
INSTALL_DIR="${RALPH_INSTALL_DIR:-$PREFIX/share/ralph}"
BIN_DIR="${RALPH_BIN_DIR:-$PREFIX/bin}"

if [ "$VERSION" != "latest" ]; then
  case "$VERSION" in
    v*) ;;
    *) VERSION="v$VERSION" ;;
  esac
  TARBALL_URL="https://github.com/$REPO/releases/download/$VERSION/ralph.tar.gz"
else
  TARBALL_URL="https://github.com/$REPO/releases/latest/download/ralph.tar.gz"
fi

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js is required. Install Node.js and re-run."
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required. Install curl and re-run."
  exit 1
fi

if ! command -v tar >/dev/null 2>&1; then
  echo "tar is required. Install tar and re-run."
  exit 1
fi

tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

echo "Downloading $TARBALL_URL"
curl -fsSL "$TARBALL_URL" -o "$tmp_dir/ralph.tar.gz"
tar -xzf "$tmp_dir/ralph.tar.gz" -C "$tmp_dir"

mkdir -p "$(dirname "$INSTALL_DIR")"
rm -rf "$INSTALL_DIR"
mv "$tmp_dir/ralph" "$INSTALL_DIR"

mkdir -p "$BIN_DIR"
ln -sf "$INSTALL_DIR/bin/ralph" "$BIN_DIR/ralph"
chmod +x "$INSTALL_DIR/bin/ralph"

if ! echo ":$PATH:" | grep -q ":$BIN_DIR:"; then
  if [ -n "${RALPH_NO_MODIFY_PATH:-}" ]; then
    echo "Add $BIN_DIR to your PATH to run ralph."
  else
    shell_name="$(basename "${SHELL:-}")"
    rc_file=""
    case "$shell_name" in
      bash) rc_file="$HOME/.bashrc" ;;
      zsh) rc_file="$HOME/.zshrc" ;;
      fish) rc_file="$HOME/.config/fish/config.fish" ;;
      *) rc_file="$HOME/.profile" ;;
    esac

    if [ "$shell_name" = "fish" ]; then
      line="set -gx PATH \"$BIN_DIR\" \$PATH"
    else
      line="export PATH=\"$BIN_DIR:\$PATH\""
    fi

    if [ ! -f "$rc_file" ] || ! grep -q "$BIN_DIR" "$rc_file"; then
      printf '\n# Added by ralph installer\n%s\n' "$line" >> "$rc_file"
      echo "Added $BIN_DIR to PATH in $rc_file. Restart your shell."
    fi
  fi
fi

echo "Installed ralph to $INSTALL_DIR"
echo "Run: ralph --help"
