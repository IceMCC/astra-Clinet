# Astra build tools

Apply Astra to an Eaglercraft workspace:

    ./tools/apply-astra.sh /path/to/eaglercraft-26.3

The script copies Astra source into the game's Java source tree and adds one
bootstrap call to ClientBootstrap.

The upstream Eaglercraft workspace is intentionally not vendored here. The
Astra repository stays focused on Astra code and does not redistribute game
inputs or assets.

After applying the overlay, compile the game with the upstream workspace's
normal Gradle task.
