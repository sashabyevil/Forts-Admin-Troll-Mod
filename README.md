# Forts Admin Troll Mod

Lua mod for Forts. The lobby host (client index 0) presses `U` during a multiplayer battle to open the menu. Select a listed player to toggle a black screen on that player's game. Select the player again from the reopened menu to turn it off. Restarting the battle also clears all black screens.

The current Forts scripting API exposes client indexes and team IDs, but not player names, so entries are shown as `Player #N` with their team ID.

Install the mod folder in `Forts/users/<your-user-id>/mods/forts_admin/`, then enable it for the battle. All participants must have the mod enabled for the networked effect to work.