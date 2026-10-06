#!/usr/bin/env bash
set -euo pipefail

PROJECT="${1:-}"
MODE="${2:-}"

if [[ -z "$PROJECT" || ! -d "$PROJECT/game/src/main/java" ]]; then
  echo "Usage: $0 <eaglercraft-project> [--no-bootstrap]"
  exit 2
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$PROJECT/game/src/main/java"
mkdir -p "$DEST/astra"
cp -R "$ROOT/astra/." "$DEST/astra/"

if [[ "$MODE" == "--no-bootstrap" ]]; then
  echo "Galaxy source overlay copied; bootstrap patch skipped."
  exit 0
fi

BOOT="$(find "$DEST" -type f -name 'ClientBootstrap.java' -print -quit || true)"
if [[ -z "$BOOT" ]]; then
  echo "No ClientBootstrap.java found; leaving the source unpatched."
  exit 0
fi

MARKER="/* GALAXY_CLIENT_BOOTSTRAP */"
if grep -q "$MARKER" "$BOOT"; then
  echo "Galaxy bootstrap already applied."
  exit 0
fi

python3 - "$BOOT" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
s = p.read_text()
if "import astra.integration.AstraBootstrap;" not in s:
    lines = s.splitlines()
    idx = 0
    while idx < len(lines) and lines[idx].startswith("package "):
        idx += 1
    while idx < len(lines) and (lines[idx].startswith("import ") or not lines[idx].strip()):
        idx += 1
    lines.insert(idx, "import astra.integration.AstraBootstrap;")
    s = "\n".join(lines) + ("\n" if s.endswith("\n") else "")
needle = "isBootstrapped = true;"
if needle in s:
    s = s.replace(needle, needle + "\n         /* GALAXY_CLIENT_BOOTSTRAP */\n         AstraBootstrap.initialize();", 1)
p.write_text(s)
PY

echo "Galaxy Client overlay applied to: $PROJECT"
