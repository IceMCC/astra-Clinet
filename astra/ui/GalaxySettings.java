package astra.ui;

import astra.config.AstraConfig;
import astra.config.PerformanceProfile;

/** UI-facing Galaxy settings model; no Minecraft GUI dependencies. */
public final class GalaxySettings {
    private final AstraConfig config;
    public GalaxySettings(AstraConfig config) { this.config = config; }

    public void setPreset(PerformanceProfile profile) {
        config.setProfile(profile);
        config.applyProfile();
    }

    public PerformanceProfile getPreset() { return config.getProfile(); }
    public int getRenderDistance() { return config.getRenderDistance(); }
    public int getMaxFps() { return config.getMaxFps(); }

    public void setEntityCulling(boolean value) { custom(); config.setEntityCulling(value); }
    public void setParticleReduction(boolean value) { custom(); config.setParticleReduction(value); }
    public void setAnimatedTextures(boolean value) { custom(); config.setAnimatedTextures(value); }
    public void setDynamicFps(boolean value) { custom(); config.setDynamicFps(value); }
    public void setFastMath(boolean value) { custom(); config.setFastMath(value); }
    public void setRenderDistance(int value) { custom(); config.setRenderDistance(value); }
    public void setMaxFps(int value) { custom(); config.setMaxFps(value); }

    private void custom() { config.setProfile(PerformanceProfile.CUSTOM); }
}
