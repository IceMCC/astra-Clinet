package astra.config;

/** Runtime configuration for Astra performance features. */
public final class AstraConfig {
    private PerformanceProfile profile = PerformanceProfile.BALANCED;
    private boolean entityCulling = true;
    private boolean particleReduction = false;
    private boolean animatedTextures = true;
    private boolean dynamicFps = true;
    private boolean fastMath = true;

    public PerformanceProfile getProfile() { return profile; }
    public void setProfile(PerformanceProfile profile) { this.profile = profile == null ? PerformanceProfile.BALANCED : profile; }
    public boolean isEntityCulling() { return entityCulling; }
    public boolean isParticleReduction() { return particleReduction; }
    public boolean isAnimatedTextures() { return animatedTextures; }
    public boolean isDynamicFps() { return dynamicFps; }
    public boolean isFastMath() { return fastMath; }

    public void setEntityCulling(boolean v) { entityCulling = v; }
    public void setParticleReduction(boolean v) { particleReduction = v; }
    public void setAnimatedTextures(boolean v) { animatedTextures = v; }
    public void setDynamicFps(boolean v) { dynamicFps = v; }
    public void setFastMath(boolean v) { fastMath = v; }

    public void applyProfile() {
        switch (profile) {
            case LOW, HIGH_FPS -> { entityCulling=true; particleReduction=true; animatedTextures=false; dynamicFps=true; fastMath=true; }
            case BALANCED -> { entityCulling=true; particleReduction=false; animatedTextures=true; dynamicFps=true; fastMath=true; }
            case CUSTOM -> { }
        }
    }
}
