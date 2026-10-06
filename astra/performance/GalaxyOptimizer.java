package astra.performance;

import astra.config.AstraConfig;

/**
 * Browser-safe hot-path decisions for Galaxy Client.
 * Call these from the corresponding renderer/game-loop hooks.
 */
public final class GalaxyOptimizer {
    private final AstraConfig config;

    public GalaxyOptimizer(AstraConfig config) {
        this.config = config;
    }

    public boolean skipAnimatedTextureTick() {
        return !config.isAnimatedTextures();
    }

    public boolean skipParticleSpawn() {
        return config.isParticleReduction();
    }

    public boolean cullEntity() {
        return config.isEntityCulling();
    }

    public boolean allowBackgroundTick() {
        return !config.isDynamicFps();
    }

    public boolean useFastMath() {
        return config.isFastMath();
    }

    public int renderDistance() {
        return config.getRenderDistance();
    }

    public int maxFps() {
        return config.getMaxFps();
    }

    /** Returns true when an FPS-limited/background loop should yield. */
    public boolean shouldYield(boolean documentHidden) {
        return config.isDynamicFps() && documentHidden;
    }

    /** Simple distance gate for callers that already have squared distance. */
    public boolean shouldCullByDistance(double distanceSquared, double maxDistance) {
        return config.isEntityCulling() && distanceSquared > maxDistance * maxDistance;
    }
}
