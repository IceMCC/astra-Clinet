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

python3 - "$DEST/net/minecraft/client/particle/ParticleEngine.java" "$DEST/net/minecraft/client/renderer/texture/TextureManager.java" "$DEST/net/minecraft/client/renderer/entity/EntityRenderDispatcher.java" <<'PY'
from pathlib import Path
import sys

particles, textures, entities = map(Path, sys.argv[1:4])

def add_import(text, import_line):
    if import_line in text:
        return text
    lines = text.splitlines()
    package_end = next((i for i, line in enumerate(lines) if line.startswith("package ")), -1)
    if package_end < 0:
        raise SystemExit(f"Galaxy: cannot find package declaration for {import_line}")
    idx = package_end + 1
    while idx < len(lines) and (lines[idx].startswith("import ") or not lines[idx].strip()):
        idx += 1
    lines.insert(idx, import_line)
    return "\n".join(lines) + ("\n" if text.endswith("\n") else "")

def patch(path, import_line, old, new, marker):
    if not path.exists():
        raise SystemExit(f"Galaxy: required hook target missing: {path}")
    s = path.read_text()
    if marker in s:
        print(f"Galaxy: already patched {path}")
        return
    if old not in s:
        raise SystemExit(f"Galaxy: source pattern not found in {path}; baseline changed")
    s = add_import(s, import_line)
    s = s.replace(old, new, 1)
    path.write_text(s)
    print(f"Galaxy: patched {path}")

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
      } /* GALAXY_PARTICLE_GATE */
      Particle particle = this.makeParticle(options, x, y, z, xa, ya, za);""",
    "GALAXY_PARTICLE_GATE",
)

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

if [[ "$MODE" != "--no-bootstrap" ]]; then
  BOOT="$(find "$DEST" -type f -name 'ClientBootstrap.java' -print -quit || true)"
  if [[ -n "$BOOT" ]]; then
    python3 - "$BOOT" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
s = p.read_text()
if "GALAXY_CLIENT_BOOTSTRAP" in s:
    raise SystemExit(0)
if "isBootstrapped = true;" not in s:
    raise SystemExit(f"Galaxy: ClientBootstrap.java has no known bootstrap marker: {p}")
if "import astra.integration.AstraBootstrap;" not in s:
    lines = s.splitlines()
    package_end = next((i for i, line in enumerate(lines) if line.startswith("package ")), -1)
    if package_end < 0:
        raise SystemExit(f"Galaxy: cannot find package declaration in {p}")
    idx = package_end + 1
    while idx < len(lines) and (lines[idx].startswith("import ") or not lines[idx].strip()):
        idx += 1
    lines.insert(idx, "import astra.integration.AstraBootstrap;")
    s = "\n".join(lines) + ("\n" if s.endswith("\n") else "")
needle = "isBootstrapped = true;"
s = s.replace(needle, needle + "\n         /* GALAXY_CLIENT_BOOTSTRAP */\n         AstraBootstrap.initialize();", 1)
p.write_text(s)
PY
  else
    echo "Galaxy: no ClientBootstrap.java found; performance hooks still applied."
  fi
fi

echo "Galaxy Client overlay copied and runtime performance hooks applied."
