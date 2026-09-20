#!/usr/bin/env bash
# Export Crystal Lane for Godot 4.3 Web (HTML5) into build/web/.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

GODOT_BIN="${GODOT_BIN:-}"
if [[ -z "$GODOT_BIN" ]]; then
  for candidate in \
    /tmp/godot/Godot_v4.3-stable_linux.x86_64 \
    "$(command -v godot4 || true)" \
    "$(command -v godot || true)"; do
    if [[ -n "$candidate" && -x "$candidate" ]]; then
      GODOT_BIN="$candidate"
      break
    fi
  done
fi

if [[ -z "${GODOT_BIN}" || ! -x "$GODOT_BIN" ]]; then
  echo "Godot 4.3 binary not found. Set GODOT_BIN to the Godot 4.3 executable." >&2
  exit 1
fi

TEMPLATES_DIR="${GODOT_TEMPLATES_DIR:-$HOME/.local/share/godot/export_templates/4.3.stable}"
NEED_TEMPLATE="$TEMPLATES_DIR/web_nothreads_release.zip"
if [[ ! -f "$NEED_TEMPLATE" ]]; then
  echo "Missing Web export template: $NEED_TEMPLATE" >&2
  echo "Install Godot 4.3 export templates, or run:" >&2
  echo "  curl -L -o /tmp/Godot_v4.3-stable_export_templates.tpz \\" >&2
  echo "    https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_export_templates.tpz" >&2
  echo "  mkdir -p \"$TEMPLATES_DIR\"" >&2
  echo "  unzip -j /tmp/Godot_v4.3-stable_export_templates.tpz 'templates/version.txt' 'templates/web_*.zip' -d \"$TEMPLATES_DIR\"" >&2
  exit 1
fi

mkdir -p "$ROOT/build/web"
echo "Exporting Crystal Lane (Web, single-thread) with $GODOT_BIN"
"$GODOT_BIN" --headless --path "$ROOT" --export-release "Web" "$ROOT/build/web/index.html"

echo "Wrote $ROOT/build/web/"
ls -lh "$ROOT/build/web"

if [[ "${1:-}" == "--serve" ]]; then
  PORT="${PORT:-43180}"
  echo "Serving at http://127.0.0.1:${PORT}/"
  exec python3 "$ROOT/scripts/serve_web.py" --port "$PORT" --root "$ROOT/build/web"
fi
