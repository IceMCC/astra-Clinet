package astra.performance;

import astra.config.AstraConfig;
import astra.config.PerformanceProfile;

/** Central entry point for Galaxy performance settings. */
public final class PerformanceController {
    private final AstraConfig config;
    public PerformanceController(AstraConfig config) { this.config = config; }
    public void setProfile(PerformanceProfile profile) { config.setProfile(profile); config.applyProfile(); }
    public boolean shouldCullEntities() { return config.isEntityCulling(); }
    public boolean shouldCullEntity(double entityX, double entityY, double entityZ, double cameraX, double cameraY, double cameraZ) {
        if (!config.isEntityCulling()) return false;
        double dx = entityX - cameraX;
        double dy = entityY - cameraY;
        double dz = entityZ - cameraZ;
        double max = Math.max(32.0, config.getRenderDistance() * 16.0);
        return dx * dx + dy * dy + dz * dz > max * max;
    }
    public boolean reduceParticles() { return config.isParticleReduction(); }
    public boolean animateTextures() { return config.isAnimatedTextures(); }
    public boolean useDynamicFps() { return config.isDynamicFps(); }
    public boolean useFastMath() { return config.isFastMath(); }
    public int renderDistance() { return config.getRenderDistance(); }
    public int maxFps() { return config.getMaxFps(); }
}
