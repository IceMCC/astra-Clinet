package astra.config;

/** Runtime configuration for Galaxy performance features. */
public final class AstraConfig {
    private PerformanceProfile profile = PerformanceProfile.HIGH_FPS;
    private boolean entityCulling = true;
    private boolean particleReduction = true;
    private boolean animatedTextures = true;
    private boolean dynamicFps = true;
    private boolean fastMath = true;
    private int renderDistance = 10;
    private int maxFps = 120;

    public PerformanceProfile getProfile() { return profile; }
    public void setProfile(PerformanceProfile profile) { this.profile = profile == null ? PerformanceProfile.BALANCED : profile; }
    public boolean isEntityCulling() { return entityCulling; }
    public boolean isParticleReduction() { return particleReduction; }
    public boolean isAnimatedTextures() { return animatedTextures; }
    public boolean isDynamicFps() { return dynamicFps; }
    public boolean isFastMath() { return fastMath; }
    public int getRenderDistance() { return renderDistance; }
    public int getMaxFps() { return maxFps; }

    public void setEntityCulling(boolean v) { entityCulling = v; }
    public void setParticleReduction(boolean v) { particleReduction = v; }
    public void setAnimatedTextures(boolean v) { animatedTextures = v; }
    public void setDynamicFps(boolean v) { dynamicFps = v; }
    public void setFastMath(boolean v) { fastMath = v; }
    public void setRenderDistance(int v) { renderDistance = clamp(v, 2, 32); }
    public void setMaxFps(int v) { maxFps = clamp(v, 30, 360); }

    public void applyProfile() {
        switch (profile) {
            case LOW -> { entityCulling=true; particleReduction=true; animatedTextures=false; dynamicFps=true; fastMath=true; renderDistance=6; maxFps=60; }
            case BALANCED -> { entityCulling=true; particleReduction=false; animatedTextures=true; dynamicFps=true; fastMath=true; renderDistance=10; maxFps=120; }
            case HIGH_FPS -> { entityCulling=true; particleReduction=true; animatedTextures=true; dynamicFps=true; fastMath=true; renderDistance=12; maxFps=240; }
            case CUSTOM -> { }
        }
    }

    private static int clamp(int value, int min, int max) {
        return Math.max(min, Math.min(max, value));
    }
}
