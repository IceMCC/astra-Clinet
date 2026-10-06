# Astra Client Architecture

## Current stage

Astra now has real source code for configuration, performance profiles, a performance controller, and branding metadata.

## Integration rule

Astra will be integrated into an Eaglercraft 26.x workspace through source-level adapters and patches. Desktop Fabric/Forge JARs are not being blindly copied into the browser client.

## Planned modules

1. Rendering optimizations
2. Entity/block culling
3. Client tick optimizations
4. Browser dynamic FPS
5. Memory/resource optimizations
6. Astra settings UI
7. Browser/WASM build pipeline
8. Automated smoke tests

The Eaglercraft 26.x baseline will be pinned before Minecraft/Eaglercraft source patches are added.