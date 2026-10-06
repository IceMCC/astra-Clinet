package astra.integration;

import astra.branding.ClientInfo;
import astra.config.AstraConfig;
import astra.config.PerformanceProfile;
import astra.performance.PerformanceController;

/** Galaxy Client runtime bootstrap. */
public final class AstraBootstrap {
    private static final AstraConfig CONFIG = new AstraConfig();
    private static final PerformanceController PERFORMANCE = new PerformanceController(CONFIG);
    private static volatile boolean initialized;

    private AstraBootstrap() {}

    public static void initialize() {
        if (initialized) return;
        synchronized (AstraBootstrap.class) {
            if (initialized) return;
            PERFORMANCE.setProfile(PerformanceProfile.HIGH_FPS);
            initialized = true;
        }
    }

    public static String clientName() { return ClientInfo.NAME; }
    public static String version() { return ClientInfo.VERSION; }
    public static PerformanceController performance() { return PERFORMANCE; }
    public static AstraConfig config() { return CONFIG; }
}
