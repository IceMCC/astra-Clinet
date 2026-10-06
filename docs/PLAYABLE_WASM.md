# Building the playable Galaxy Client WASM build

Galaxy's repository contains the performance source overlay and the WASM-GC build automation. The upstream Eaglercraft 26.x build requires a legitimately obtained Minecraft 26.2 input and its supplied patch/build tooling; this repository does not contain proprietary Minecraft source or assets.

## 1. Prepare the Eaglercraft project

Use the supported Eaglercraft 26.x workspace and provide your legitimate Minecraft 26.2 input through its documented patcher/source-generation process.

## 2. Apply Galaxy

From the Galaxy repository:

```bash
chmod +x tools/apply-astra.sh
./tools/apply-astra.sh /path/to/eaglercraft-project
```

## 3. Compile and link WASM-GC

With Java 25 and the required build memory available:

```bash
cd /path/to/eaglercraft-project
./gradlew :game:compileJava --console=plain --no-daemon
./gradlew :target_teavm_wasm_gc:generateWasmGC --console=plain --no-daemon
```

The raw browser output is produced under:

```
target_teavm_wasm_gc/build/web/
```

The upstream guide documents this WASM-GC target and raw web output. Do not use `--skip-build` after changing Galaxy source.

## 4. Test locally

```bash
python3 -m http.server 8000 --directory target_teavm_wasm_gc/build/web
```

Then open `http://localhost:8000/` in a browser with WebAssembly GC support.

## 5. GitHub Actions

The Galaxy workflow already:
- checks out the pinned Eaglercraft baseline
- applies the Galaxy performance overlay
- compiles the game
- invokes `generateWasmGC`
- packages the generated web/WASM files
- uploads a `galaxy-client-wasm` artifact

The workflow cannot manufacture the required proprietary Minecraft input. For a complete playable build, that input must be supplied through a build environment where you have the right to use it.
