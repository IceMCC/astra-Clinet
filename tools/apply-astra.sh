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

python3 - "$DEST/net/minecraft/client/particle/ParticleEngine.java" "$DEST/net/minecraft/client/renderer/texture/TextureManager.java" "$DEST/net/minecraft/client/renderer/entity/EntityRenderDispatcher.java" "$MODE" <<'PY'
from pathlib import Path
import sys

particles, textures, entities = map(Path, sys.argv[1:4])
mode = sys.argv[4] if len(sys.argv) > 4 else ""

def add_import(text, import_line):
    if import_line in text:
        return text
    lines = text.splitlines()
    package_end = next((i for i, line in enumerate(lines) if line.startswith("package ")), -1)
    if package_end < 0:
        return text
    idx = package_end + 1
    while idx < len(lines) and (lines[idx].startswith("import ") or not lines[idx].strip()):
        idx += 1
    lines.insert(idx, import_line)
    return "\n".join(lines) + ("\n" if text.endswith("\n") else "")

def patch(path, import_line, old, new, marker):
    if not path.exists():
        print(f"Galaxy: optional hook target missing: {path}")
        return
    s = path.read_text()
    s = add_import(s, import_line)
    if marker not in s and old in s:
        s = s.replace(old, new, 1)
        path.write_text(s)
        print(f"Galaxy: patched {path}")
    elif marker in s:
        print(f"Galaxy: already patched {path}")
    else:
        print(f"Galaxy: source pattern not found in {path}; leaving it unchanged")

# Real particle admission gate.
patch(
    particles,
    "import astra.integration.AstraHooks;",
    """   public @Nullable Particle createParticle(
      final ParticleOptions options, final double x, final double y, final double z, final double xa, final double ya, final double za
   ) {
      Particle particle = this.makeParticle(options, x, y, z, xa, ya, za);""",
    """   public @Nullable Particle createParticle(
      final ParticleOptions options, final double x, final double y, final double z, final double xa, final double ya, final double za
   ) {
      if (!AstraHooks.allowParticle(this.getParticleCount())) {
         return null;
      }
      Particle particle = this.makeParticle(options, x, y, z, xa, ya, za);""",
    "GALAXY_PARTICLE_GATE",
)

# Animated texture tick gate.
patch(
    textures,
    "import astra.integration.AstraHooks;",
    """   public void tick() {
      for (TickableTexture tickableTexture : this.tickableTextures) {""",
    """   public void tick() {
      if (!AstraHooks.shouldTickTextures()) {
         return;
      } /* GALAXY_TEXTURE_TICK_GATE */
      for (TickableTexture tickableTexture : this.tickableTextures) {""",
    "GALAXY_TEXTURE_TICK_GATE",
)

# Distance gate layered before the existing frustum/render checks.
patch(
    entities,
    "import astra.integration.AstraHooks;",
    """   public <E extends Entity> boolean shouldRender(final E entity, final Frustum culler, final double camX, final double camY, final double camZ) {
      EntityRenderer<? super E, ?> renderer = this.getRenderer(entity);""",
    """   public <E extends Entity> boolean shouldRender(final E entity, final Frustum culler, final double camX, final double camY, final double camZ) {
      final double dx = entity.getX() - camX;
      final double dy = entity.getY() - camY;
      final double dz = entity.getZ() - camZ;
      if (!AstraHooks.shouldRenderEntity(entity, dx * dx + dy * dy + dz * dz)) {
         return false;
      } /* GALAXY_ENTITY_DISTANCE_CULL */
      EntityRenderer<? super E, ?> renderer = this.getRenderer(entity);""",
    "GALAXY_ENTITY_DISTANCE_CULL",
)
PY

# Bootstrap is optional because community Eagler trees may use a different entry point.
if [[ "$MODE" != "--no-bootstrap" ]]; then
  BOOT="$(find "$DEST" -type f -name 'ClientBootstrap.java' -print -quit || true)"
  if [[ -n "$BOOT" ]]; then
    python3 - "$BOOT" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
s = p.read_text()
if "import astra.integration.AstraBootstrap;" not in s:
    lines = s.splitlines()
    package_end = next((i for i, line in enumerate(lines) if line.startswith("package ")), -1)
    idx = package_end + 1
    while idx < len(lines) and (lines[idx].startswith("import ") or not lines[idx].strip()):
        idx += 1
    lines.insert(idx, "import astra.integration.AstraBootstrap;")
    s = "\n".join(lines) + ("\n" if s.endswith("\n") else "")
needle = "isBootstrapped = true;"
if "GALAXY_CLIENT_BOOTSTRAP" not in s and needle in s:
    s = s.replace(needle, needle + "\n         /* GALAXY_CLIENT_BOOTSTRAP */\n         AstraBootstrap.initialize();", 1)
    p.write_text(s)
PY
  else
    echo "Galaxy: no ClientBootstrap.java found; performance hooks still applied."
  fi
fi

echo "Galaxy Client overlay copied and runtime performance hooks applied."
