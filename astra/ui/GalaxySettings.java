package astra.ui;

import astra.config.AstraConfig;
import astra.config.PerformanceProfile;

/** UI-facing Galaxy settings model. */
public final class GalaxySettings {
    private final AstraConfig config;
    public GalaxySettings(AstraConfig config) { this.config = config; }

    public void setPreset(PerformanceProfile profile) {
        config.setProfile(profile);
        config.applyProfile();
    }

    public PerformanceProfile getPreset() { return config.getProfile(); }
    public void setEntityCulling(boolean value) { config.setEntityCulling(value); }
    public void setParticleReduction(boolean value) { config.setParticleReduction(value); }
    public void setAnimatedTextures(boolean value) { config.setAnimatedTextures(value); }
    public void setDynamicFps(boolean value) { config.setDynamicFps(value); }
    public void setFastMath(boolean value) { config.setFastMath(value); }
}
