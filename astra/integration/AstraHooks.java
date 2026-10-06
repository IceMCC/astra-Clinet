package astra.integration;

import net.minecraft.world.entity.Entity;

/**
 * Small source-level bridge between Galaxy performance policy and the Eaglercraft
 * client. The hooks intentionally avoid desktop-only APIs so they remain TeaVM-safe.
 */
public final class AstraHooks {
    private static final int REDUCED_PARTICLE_CAP = 4096;

    private AstraHooks() {}

    public static void initialize() {
        AstraBootstrap.initialize();
    }

    public static boolean shouldTickTextures() {
        return AstraBootstrap.config().isAnimatedTextures();
    }

    public static boolean allowParticle(final int currentCount) {
        return !AstraBootstrap.config().isParticleReduction() || currentCount < REDUCED_PARTICLE_CAP;
    }

    public static boolean shouldRenderEntity(final Entity entity, final double distanceSquared) {
        if (entity == null) return true;
        if (!AstraBootstrap.config().isEntityCulling()) return true;
        final double maxBlocks = AstraBootstrap.config().getRenderDistance() * 16.0D;
        return distanceSquared <= maxBlocks * maxBlocks;
    }
}
