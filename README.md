# Galaxy Client

**Galaxy Client** is a performance-focused Eaglercraft-compatible client project by IceMCC.

## Current state

- Galaxy branding and performance framework are in the repository.
- The GitHub Actions pipeline compiles the Galaxy overlay against the community Eaglercraft 26.3 source tree.
- GitHub Pages publishes a launcher shell after a successful compile.
- The project does **not** include a proprietary Minecraft JAR or assets.

## Performance systems

- Sodium-style rendering optimization hooks
- Lithium-style game-loop optimization hooks
- ImmediatelyFast-style batching/UI optimization direction
- Entity culling decisions
- Particle reduction
- Animated-texture reduction
- Dynamic-FPS controls
- Fast-math toggle
- Low / Balanced / High-FPS presets

These are source-level integrations for a browser client; normal desktop Fabric mod JARs cannot simply be dropped into Eaglercraft.

## Building a playable browser client

A truly playable browser build requires an Eaglercraft-compatible source/input set that you are licensed to use. The repository intentionally does not redistribute a vanilla Minecraft JAR or proprietary assets.

The workflow currently proves the Galaxy source overlay can be compiled and publishes a Pages launcher shell. To turn that shell into the actual game, the generated standalone HTML/WebAssembly output from your licensed build must be published as the Pages site output.

## Repository layout

```
astra/
├── branding/
├── config/
├── integration/
├── performance/
└── ui/

tools/
└── apply-astra.sh

web/
└── index.html

.github/workflows/
├── build.yml
└── validate.yml
```

## Roadmap

- [x] Galaxy branding
- [x] Performance framework
- [x] Safe 26.x source overlay
- [x] Compile workflow
- [x] GitHub Pages launcher shell
- [ ] Verified playable WASM/HTML integration
- [ ] In-game Galaxy settings screen
- [ ] Verified renderer/entity culling hooks
- [ ] Final pinned Eaglercraft baseline
