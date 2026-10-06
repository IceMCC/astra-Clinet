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

BOOT="$(find "$DEST" -type f -name 'ClientBootstrap.java' -print -quit || true)"
if [[ -z "$BOOT" ]]; then
  echo "No ClientBootstrap.java found; leaving the source unpatched."
  exit 0
fi

python3 - "$BOOT" "$DEST/net/minecraft/client/particle/ParticleEngine.java" "$DEST/net/minecraft/client/renderer/texture/TextureManager.java" "$DEST/net/minecraft/client/renderer/entity/EntityRenderDispatcher.java" "$MODE" <<'PY'
from pathlib import Path
import sys

boot, particles, textures, entities = map(Path, sys.argv[1:5])
mode = sys.argv[5] if len(sys.argv) > 5 else ""

def add_import(text, import_line):
    if import_line in text:
        return text
    lines = text.splitlines()
    package_end = 0
    while package_end < len(lines) and not lines[package_end].startswith("package "):
        package_end += 1
    idx = package_end + 1
    while idx < len(lines) and (lines[idx].startswith("import ") or not lines[idx].strip()):
        idx += 1
    lines.insert(idx, import_line)
    return "\n".join(lines) + ("\n" if text.endswith("\n") else "")

# 1) Bootstrap Galaxy once at the real client bootstrap point.
# --no-bootstrap skips only this entry-point patch; the performance hooks below still apply.
if mode != "--no-bootstrap":
    s = boot.read_text()
    s = add_import(s, "import astra.integration.AstraBootstrap;")
    needle = "isBootstrapped = true;"
    if "/* GALAXY_CLIENT_BOOTSTRAP */" not in s and needle in s:
        s = s.replace(
            needle,
            needle + "\n         /* GALAXY_CLIENT_BOOTSTRAP */\n         AstraBootstrap.initialize();",
            1,
        )
    boot.write_text(s)

# 2) Particle admission gate: avoid allocating new particles in the FPS preset.
if particles.exists():
    s = particles.read_text()
    s = add_import(s, "import astra.integration.AstraBootstrap;")
    old = """   public @Nullable Particle createParticle(
      final ParticleOptions options, final double x, final double y, final double z, final double xa, final double ya, final double za
   ) {
      Particle particle = this.makeParticle(options, x, y, z, xa, ya, za);"""
    new = """   public @Nullable Particle createParticle(
      final ParticleOptions options, final double x, final double y, final double z, final double xa, final double ya, final double za
   ) {
      if (AstraBootstrap.performance().reduceParticles()) {
         return null;
      }
      Particle particle = this.makeParticle(options, x, y, z, xa, ya, za);"""
    if "AstraBootstrap.performance().reduceParticles()" not in s and old in s:
        s = s.replace(old, new, 1)
    particles.write_text(s)

# 3) Animated-texture tick gate.
if textures.exists():
    s = textures.read_text()
    s = add_import(s, "import astra.integration.AstraBootstrap;")
    old = """   public void tick() {
      for (TickableTexture tickableTexture : this.tickableTextures) {"""
    new = """   public void tick() {
      if (AstraBootstrap.performance().animateTextures() == false) {
         return;
      }
      for (TickableTexture tickableTexture : this.tickableTextures) {"""
    if "AstraBootstrap.performance().animateTextures()" not in s and old in s:
        s = s.replace(old, new, 1)
    textures.write_text(s)

# 4) Entity distance gate in addition to the existing frustum/renderer culling.
if entities.exists():
    s = entities.read_text()
    s = add_import(s, "import astra.integration.AstraBootstrap;")
    old = """   public <E extends Entity> boolean shouldRender(final E entity, final Frustum culler, final double camX, final double camY, final double camZ) {
      EntityRenderer<? super E, ?> renderer = this.getRenderer(entity);
      return renderer.shouldRender(entity, culler, camX, camY, camZ);
   }"""
    new = """   public <E extends Entity> boolean shouldRender(final E entity, final Frustum culler, final double camX, final double camY, final double camZ) {
      if (AstraBootstrap.performance().shouldCullEntity(entity.getX(), entity.getY(), entity.getZ(), camX, camY, camZ)) {
         return false;
      }
      EntityRenderer<? super E, ?> renderer = this.getRenderer(entity);
      return renderer.shouldRender(entity, culler, camX, camY, camZ);
   }"""
    if "AstraBootstrap.performance().shouldCullEntity" not in s and old in s:
        s = s.replace(old, new, 1)
    entities.write_text(s)
PY

echo "Galaxy Client overlay copied and runtime performance hooks applied."
