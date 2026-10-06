# Astra Client

**Astra Client** is a performance-focused Eaglercraft client project by IceMCC.

> Status: **development / source integration stage**

## What is being built

Astra is designed around an Eaglercraft-compatible source pipeline instead of copying desktop Fabric/Forge JARs into a browser client.

Planned performance systems:

- Sodium-style rendering optimizations
- Lithium-style game-loop optimizations
- ImmediatelyFast-style batching/UI optimizations
- Entity and block culling
- Memory/resource optimizations
- Dynamic FPS / browser visibility handling
- Low-end, Balanced and High-FPS presets
- Astra settings and branding
- JavaScript/WASM browser builds

## Repository layout

```
astra/
├── branding/
├── config/
├── performance/
└── README.md

docs/
└── ARCHITECTURE.md

.github/
└── workflows/
    └── validate.yml
```

## Important

The actual Minecraft/Eaglercraft integration needs a pinned Eaglercraft 26.x baseline. Community 26.x workspaces are not interchangeable, so Astra will pin one verified baseline before source patches are added.

## Legal/build note

Astra does not redistribute proprietary Minecraft assets or a vanilla Minecraft JAR. The build pipeline will use the appropriate user-supplied/licensed game input where required.

## Roadmap

- [x] Astra project structure
- [x] Performance configuration model
- [x] Performance controller
- [x] Branding metadata
- [x] GitHub validation workflow
- [ ] Pin Eaglercraft 26.x baseline
- [ ] Integrate rendering hooks
- [ ] Integrate culling
- [ ] Integrate browser dynamic-FPS hooks
- [ ] Add Astra settings screen
- [ ] Build browser/WASM artifacts
