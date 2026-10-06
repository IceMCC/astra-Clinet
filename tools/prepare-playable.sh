#!/usr/bin/env bash
set -euo pipefail

PROJECT="${1:-eaglercraft}"
if [[ ! -d "$PROJECT" ]]; then
  echo "Usage: $0 <eaglercraft-project>"
  exit 2
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "[Galaxy] Applying source hooks..."
"$ROOT/tools/apply-astra.sh" "$PROJECT"

echo "[Galaxy] Compiling game Java..."
(
  cd "$PROJECT"
  ./gradlew :game:compileJava --console=plain --no-daemon
)

WEB="$PROJECT/target_teavm_wasm_gc/build/web"
if [[ -d "$WEB" ]]; then
  echo "[Galaxy] Browser output directory found: $WEB"
else
  echo "[Galaxy] Java compilation succeeded."
  echo "[Galaxy] A playable HTML/WASM build still requires the Eaglercraft standalone CLI"
  echo "         and the official/licensed Minecraft input required by that build."
  echo "[Galaxy] See GUIDE.md in the Eaglercraft project for the standalone command."
fi
