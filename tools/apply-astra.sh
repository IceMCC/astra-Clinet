#!/usr/bin/env bash
set -euo pipefail

PROJECT="${1:-}"
if [[ -z "$PROJECT" || ! -d "$PROJECT/game/src/main/java/net/minecraft/client" ]]; then
  echo "Usage: $0 <eaglercraft-project>"
  exit 2
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$PROJECT/game/src/main/java"
mkdir -p "$DEST/astra"
cp -R "$ROOT/astra/." "$DEST/astra/"

BOOT="$PROJECT/game/src/main/java/net/minecraft/client/ClientBootstrap.java"
MARKER="/* ASTRA_CLIENT_BOOTSTRAP */"

if ! grep -q "$MARKER" "$BOOT"; then
  python3 - "$BOOT" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
s = p.read_text()
needle = "import net.minecraft.client.color.item.ItemTintSources;"
s = s.replace(needle, needle + "\nimport astra.integration.AstraBootstrap;")
needle2 = "         isBootstrapped = true;"
s = s.replace(needle2, needle2 + "\n         /* ASTRA_CLIENT_BOOTSTRAP */\n         AstraBootstrap.initialize();", 1)
p.write_text(s)
PY
fi

echo "Astra Client overlay applied to: $PROJECT"
