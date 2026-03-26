/************************************************************************************\
		   ========================================
	       * || ZC Mode Integration - New Features || *
	       * || Bridges zc_mode.sma with new plugins || *
		   ========================================
\************************************************************************************/

// This file contains integration code for the new features
// Include this file in zc_mode.sma after the existing code

#if defined _zc_integration_included
  #endinput
#endif
#define _zc_integration_included

// ============================================================================
// NEW FEATURES INTEGRATION
// ============================================================================

// Check if the new feature plugins are loaded
new bool:g_bProfilesLoaded = false
new bool:g_bModernHUDLoaded = false
new bool:g_bAchievementsLoaded = false
new bool:g_bPrestigeLoaded = false
new bool:g_bKillEffectsLoaded = false
new bool:g_bDailyChallengesLoaded = false

// Prestige multipliers for each player
new Float:g_fPrestigeXPMultiplier[33] = {1.0, ...}
new Float:g_fPrestigeCoinMultiplier[33] = {1.0, ...}

// =======================================================================
// PLUGIN INITIALIZATION - Add to plugin_init()
// =======================================================================

// Add this to plugin_init() to check for loaded plugins
/*
public plugin_init()
{
    // ... existing code ...

    // Check for new feature plugins
    g_bProfilesLoaded = LibraryExists("zc_player_profiles_amxx")
    g_bModernHUDLoaded = LibraryExists("zc_modern_hud_amxx")
    g_bAchievementsLoaded = LibraryExists("zc_achievements_amxx")
    g_bPrestigeLoaded = LibraryExists("zc_prestige_amxx")
    g_bKillEffectsLoaded = LibraryExists("zc_kill_effects_amxx")
    g_bDailyChallengesLoaded = LibraryExists("zc_daily_challenges_amxx")

    log_amx("[ZC Integration] Features loaded: Profiles=%d HUD=%d Achievements=%d Prestige=%d KillEffects=%d Challenges=%d",
        g_bProfilesLoaded, g_bModernHUDLoaded, g_bAchievementsLoaded,
        g_bPrestigeLoaded, g_bKillEffectsLoaded, g_bDailyChallengesLoaded)
}
*/

// =======================================================================
// CLIENT PUTINSERVER MODIFICATIONS
// Add to the end of client_putinserver() function
// =======================================================================

/*
public client_putinserver(id)
{
    // ... existing code ...

    // NEW FEATURES: Load player data
    if (g_bProfilesLoaded && is_native_valid("zc_profile_loaded"))
    {
        // Profile loading happens automatically in zc_player_profiles plugin
    }

    // Initialize modern HUD (if available)
    if (g_bModernHUDLoaded && is_native_valid("zc_hud_is_enabled"))
    {
        // HUD initialization happens automatically
    }

    // Load daily challenges
    if (g_bDailyChallengesLoaded)
    {
        // Challenges loading happens automatically
    }

    // Initialize prestige multipliers
    if (g_bPrestigeLoaded)
    {
        g_fPrestigeXPMultiplier[id] = 1.0
        g_fPrestigeCoinMultiplier[id] = 1.0

        // Load prestige data if available
        if (is_native_valid("zc_get_user_prestige"))
        {
            new prestige = zc_get_user_prestige(id)
            g_fPrestigeXPMultiplier[id] = 1.0 + (float(prestige) * 0.05)
            g_fPrestigeCoinMultiplier[id] = 1.0 + (float(prestige) * 0.10)

            // Cap multipliers
            if (g_fPrestigeXPMultiplier[id] > 2.0) g_fPrestigeXPMultiplier[id] = 2.0
            if (g_fPrestigeCoinMultiplier[id] > 3.0) g_fPrestigeCoinMultiplier[id] = 3.0
        }
    }

    // Initialize kill effects
    if (g_bKillEffectsLoaded)
    {
        // Kill effects initialization happens automatically
    }
}
*/

// =======================================================================
// CLIENT DISCONNECT MODIFICATIONS
// Add to the beginning of client_disconnect() function
// =======================================================================

/*
public client_disconnect(id)
{
    // NEW FEATURES: Save player data
    if (g_bProfilesLoaded && is_native_valid("zc_profile_saved"))
    {
        // Profile saving happens automatically
    }

    // ... existing code ...
}
*/

// =======================================================================
// PLAYER KILLED MODIFICATIONS
// Add to fw_PlayerKilled() function after existing kill handling
// =======================================================================

/*
public fw_PlayerKilled(victim, attacker, shouldgib)
{
    // ... existing code ...

    // NEW FEATURES: Update statistics and check achievements
    if (is_user_valid_connected(attacker) && attacker != victim)
    {
        // Update player statistics
        if (g_bProfilesLoaded && is_native_valid("zc_update_player_kills"))
        {
            zc_update_player_kills(attacker, victim)
        }

        // Check achievements
        if (g_bAchievementsLoaded)
        {
            // Achievement checking happens automatically in zc_achievements plugin
        }

        // Update daily challenges
        if (g_bDailyChallengesLoaded)
        {
            // Challenge updates happen automatically in zc_daily_challenges plugin
        }

        // Apply kill effect
        if (g_bKillEffectsLoaded)
        {
            // Kill effects happen automatically in zc_kill_effects plugin
        }

        // Apply prestige multipliers to XP gain
        new Float:xpMultiplier = 1.0
        new Float:coinMultiplier = 1.0

        if (g_bPrestigeLoaded)
        {
            xpMultiplier = g_fPrestigeXPMultiplier[attacker]
            coinMultiplier = g_fPrestigeCoinMultiplier[attacker]
        }

        // Modify XP gain with prestige multiplier
        // This should be done where XP is added to g_xp[attacker]
        // Example:
        // if (g_zombie[victim] && !g_zombie[attacker])
        // {
        //     g_xp[attacker] += floatround(zc_xp_step[0] * xpMultiplier)
        // }

        // Modify coin gain with prestige multiplier
        // This should be done where coins are added
        // Example:
        // if (coins_to_add > 0)
        // {
        //     coins_to_add = floatround(coins_to_add * coinMultiplier)
        // }
    }

    // ... rest of existing code ...
}
*/

// =======================================================================
// SHOW HUD REPLACEMENT
// Replace the ShowHUD() function with this modernized version
// =======================================================================

/*
// MODIFIED ShowHUD - Uses modern HUD when available
public ShowHUD(taskid)
{
    static id
    id = ID_SHOWHUD;

    // Check if modern HUD is available and enabled
    if (g_bModernHUDLoaded && is_native_valid("zc_hud_is_enabled") && zc_hud_is_enabled())
    {
        // Modern HUD is handling display
        // The modern HUD plugin will handle everything
        return;
    }

    // Fall back to original HUD code
    // ... keep all the existing ShowHUD code ...
}
*/

// =======================================================================
// CUSTOM FUNCTIONS FOR INTEGRATION
// =======================================================================

/**
 * Applies prestige multipliers to XP gain
 *
 * @param id		Player index.
 * @param baseXP	Base XP to be modified.
 * @return		Modified XP with prestige bonus.
 */
stock ApplyPrestigeXPMultiplier(id, baseXP)
{
    if (!g_bPrestigeLoaded) return baseXP;

    new Float:multiplier = g_fPrestigeXPMultiplier[id];
    return floatround(baseXP * multiplier);
}

/**
 * Applies prestige multipliers to coin gain
 *
 * @param id		Player index.
 * @param baseCoins	Base coins to be modified.
 * @return		Modified coins with prestige bonus.
 */
stock ApplyPrestigeCoinMultiplier(id, baseCoins)
{
    if (!g_bPrestigeLoaded) return baseCoins;

    new Float:multiplier = g_fPrestigeCoinMultiplier[id];
    return floatround(baseCoins * multiplier);
}

/**
 * Gets player's current XP multiplier (from prestige)
 *
 * @param id		Player index.
 * @return		XP multiplier value (100 = 100%).
 */
stock GetPlayerXPMultiplier(id)
{
    if (!g_bPrestigeLoaded) return 100;

    if (is_native_valid("zc_get_xp_multiplier"))
    {
        return zc_get_xp_multiplier(id);
    }

    return floatround(g_fPrestigeXPMultiplier[id] * 100);
}

/**
 * Gets player's current Coin multiplier (from prestige)
 *
 * @param id		Player index.
 * @return		Coin multiplier value (100 = 100%).
 */
stock GetPlayerCoinMultiplier(id)
{
    if (!g_bPrestigeLoaded) return 100;

    if (is_native_valid("zc_get_coin_multiplier"))
    {
        return zc_get_coin_multiplier(id);
    }

    return floatround(g_fPrestigeCoinMultiplier[id] * 100);
}

/**
 * Updates player prestige multipliers
 * Call this when player prestiges
 *
 * @param id		Player index.
 */
stock UpdatePlayerPrestigeMultipliers(id)
{
    if (!g_bPrestigeLoaded) return;

    if (is_native_valid("zc_get_user_prestige"))
    {
        new prestige = zc_get_user_prestige(id);
        g_fPrestigeXPMultiplier[id] = 1.0 + (float(prestige) * 0.05);
        g_fPrestigeCoinMultiplier[id] = 1.0 + (float(prestige) * 0.10);

        // Cap multipliers
        if (g_fPrestigeXPMultiplier[id] > 2.0) g_fPrestigeXPMultiplier[id] = 2.0;
        if (g_fPrestigeCoinMultiplier[id] > 3.0) g_fPrestigeCoinMultiplier[id] = 3.0;
    }
}

// =======================================================================
// XP AND COIN MODIFICATION EXAMPLES
// =======================================================================

/*
   EXAMPLE: Modifying XP gain in your existing code

   // Find where XP is added to g_xp[attacker]
   // Example location (around line 3608-3617 in original code):
   if (g_zombie[victim] && !g_zombie[attacker])
   {
       g_xp[attacker] += zc_xp_step[0]

       // REPLACE WITH:
       new baseXP = zc_xp_step[0]
       new modifiedXP = ApplyPrestigeXPMultiplier(attacker, baseXP)
       g_xp[attacker] += modifiedXP
   }

   // For coin gains:
   if (coins_to_add > 0)
   {
       // REPLACE WITH:
       new modifiedCoins = ApplyPrestigeCoinMultiplier(id, coins_to_add)
       // Use modifiedCoins instead of coins_to_add
   }
*/

// =======================================================================
// FORWARDS REGISTRATION
// Add to plugin_init() after existing forward registrations
// =======================================================================

/*
new g_fwProfileLoaded
new g_fwProfileSaved
new g_fwAchievementUnlocked
new g_fwPlayerPrestiged
new g_fwDailyChallengeCompleted

// In plugin_init(), add:
g_fwProfileLoaded = CreateMultiForward("zc_profile_loaded", ET_IGNORE, FP_CELL)
g_fwProfileSaved = CreateMultiForward("zc_profile_saved", ET_IGNORE, FP_CELL)
g_fwAchievementUnlocked = CreateMultiForward("zc_achievement_unlocked", ET_IGNORE, FP_CELL, FP_CELL)
g_fwPlayerPrestiged = CreateMultiForward("zc_player_prestiged", ET_IGNORE, FP_CELL, FP_CELL)
g_fwDailyChallengeCompleted = CreateMultiForward("zc_daily_challenge_completed", ET_IGNORE, FP_CELL, FP_CELL)
*/

// =======================================================================
// NATIVE CHECKING
// =======================================================================

stock is_native_valid(const native_name[])
{
    // This function checks if a native from another plugin is available
    // Returns true if the native exists, false otherwise
    // Usage: if (is_native_valid("zc_get_user_prestige")) { ... }

    // This is a simplified version - actual implementation
    // would use the AMX Mod X native system
    return true; // Placeholder - would check actual native existence
}

stock LibraryExists(const library[])
{
    // Check if a plugin library is loaded
    // This is a simplified version
    new plugins[128]
    get_plugins(plugins, charsmax(plugins), "", "", sizeof(plugins), 0)

    for (new i = 0; i < sizeof(plugins); i++)
    {
        if (containi(plugins[i], library) != -1)
        {
            return true;
        }
    }

    return false;
}
