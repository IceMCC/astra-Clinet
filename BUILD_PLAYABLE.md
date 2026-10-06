# Building a playable Galaxy Client

Galaxy Client now applies its performance hooks directly to the Eaglercraft 26.x source tree.

## 1. Prepare the source

From this repository:

```bash
chmod +x tools/prepare-playable.sh
./tools/prepare-playable.sh eaglercraft
```

This applies:

- Galaxy bootstrap
- particle admission cap
- animated-texture gate
- entity distance culling
- existing Eaglercraft frustum culling remains enabled

## 2. Build the browser client

The community Eaglercraft project requires its own standalone HTML build process and licensed Minecraft input. Java compilation alone does **not** create a playable browser client.

Use the Eaglercraft project's documented standalone CLI/patcher flow after preparing the source. Keep any official Minecraft input files local and only use them when you have the right to do so.

The Eaglercraft build guide documents the expected Java/Node tooling, memory requirements, standalone HTML build, and the resulting `target_teavm_wasm_gc/build/web` directory.

## 3. Test locally

If the multi-file browser output exists:

```bash
python3 -m http.server 8000 --directory eaglercraft/target_teavm_wasm_gc/build/web
```

Then open `http://localhost:8000/`.

Do not open the HTML directly with `file://`; WebAssembly/resource loading normally needs an HTTP server.

## Important

Galaxy Client does not include proprietary Minecraft JARs or assets. The repository contains the Galaxy source overlay and build integration only.
