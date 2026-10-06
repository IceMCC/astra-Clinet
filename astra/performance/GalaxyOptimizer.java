package astra.performance;

import astra.config.AstraConfig;

/** Browser-safe optimization decisions for Eaglercraft hot paths. */
public final class GalaxyOptimizer {
    private final AstraConfig config;
    public GalaxyOptimizer(AstraConfig config) { this.config = config; }
    public boolean skipAnimatedTextureTick() { return !config.isAnimatedTextures(); }
    public boolean skipParticleSpawn() { return config.isParticleReduction(); }
    public boolean cullEntity() { return config.isEntityCulling(); }
    public boolean allowBackgroundTick() { return !config.isDynamicFps(); }
    public boolean useFastMath() { return config.isFastMath(); }
}
