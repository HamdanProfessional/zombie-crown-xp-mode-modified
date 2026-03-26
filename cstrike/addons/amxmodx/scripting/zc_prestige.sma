/************************************************************************************\
		   ========================================
	       * || Zombie Crown XP Mode - Prestige || *
	       * || Level Reset for Permanent Bonuses || *
		   ========================================
\************************************************************************************/

#include <amxmodx>
#include <amxmisc>
#include <dhudmessage>
#include <hamsandwich>
#include <xs>
#include <zombiecrown>

// Fade constants
#define FFADE_IN 0x0000

// Helper function
stock is_native_valid(const native_name[]) {
    return true // Placeholder - actual implementation would check native availability
}

#define PLUGIN_VERSION "1.0.0"
#define PLUGIN_AUTHOR "Zombie Crown Dev Team"
#define PLUGIN_NAME "ZC Prestige System"

// Prestige configuration
#define MAX_PRESTIGE 100
#define BASE_LEVEL_REQUIREMENT 160
#define LEVEL_INCREMENT 5

// Prestige perk types
enum PrestigePerkType {
    PERK_XP_BONUS = 0,
    PERK_COIN_BONUS,
    PERK_KILL_EFFECT,
    PERK_CLASS_ACCESS,
    PERK_TITLE,
    PERK_BADGE
}

// Prestige perk data
enum PrestigePerk {
    PERK_ID,
    PERK_NAME[64],
    PERK_DESCRIPTION[256],
    PERK_TYPE,
    PERK_VALUE_INT,
    Float:PERK_VALUE_FLOAT,
    PERK_VALUE_STRING[64],
    PERK_PRESTIGE_REQUIRED,
    PERK_COST
}

// Player prestige data
enum PlayerPrestige {
    PPRESTIGE_LEVEL,
    PPRESTIGE_POINTS,
    PPRESTIGE_XP_MULTIPLIER,
    PPRESTIGE_COIN_MULTIPLIER,
    PPRESTIGE_PERKS_COUNT
}

new g_playerPrestige[33][PlayerPrestige]
new g_playerUnlockedPerks[33][32]

// Prestige perks list
new Array:g_prestigePerks
new g_perkCount = 0

// Configuration
new g_pcvarEnabled
new g_pcvarMaxPrestige
new g_pcvarBaseLevel
new g_pcvarLevelIncrement

// XP and Coin multipliers per prestige level
new Float:g_xpMultiplier[MAX_PRESTIGE + 1]
new Float:g_coinMultiplier[MAX_PRESTIGE + 1]

// Forwards
new g_fwPlayerPrestiged
new g_fwPrestigePerkGranted
new g_ret

public plugin_init() {
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

    // Configuration CVARs
    g_pcvarEnabled = register_cvar("zc_prestige_enabled", "1")
    g_pcvarMaxPrestige = register_cvar("zc_prestige_max", "100")
    g_pcvarBaseLevel = register_cvar("zc_prestige_base_level", "160")
    g_pcvarLevelIncrement = register_cvar("zc_prestige_level_increment", "5")

    // Player commands
    register_clcmd("say /prestige", "CmdPrestigeMenu")
    register_clcmd("say_team /prestige", "CmdPrestigeMenu")
    register_clcmd("say /pshop", "CmdPrestigeShop")
    register_clcmd("say_team /pshop", "CmdPrestigeShop")

    // Admin commands
    register_concmd("zc_set_prestige", "CmdSetPrestige", ADMIN_CVAR, "<player> <level> - Set player prestige level")
    register_concmd("zc_add_prestige_points", "CmdAddPrestigePoints", ADMIN_CVAR, "<player> <amount> - Add prestige points")
    register_concmd("zc_reset_prestige", "CmdResetPrestige", ADMIN_RCON, "<player> - Reset player prestige")

    // Initialize multipliers
    InitializeMultipliers()

    // Create perks array
    g_prestigePerks = ArrayCreate(PrestigePerk)

    // Load perks
    LoadPrestigePerks()

    // Create forwards
    g_fwPlayerPrestiged = CreateMultiForward("zc_player_prestiged", ET_IGNORE, FP_CELL, FP_CELL)
    g_fwPrestigePerkGranted = CreateMultiForward("zc_prestige_perk_granted", ET_IGNORE, FP_CELL, FP_CELL)

    // Hook into level up event (if available)
    // This will be integrated through zc_mode.sma

    log_amx("[ZC Prestige] System initialized with %d perks", g_perkCount)
}

public plugin_end() {
    if (g_prestigePerks) {
        ArrayDestroy(g_prestigePerks)
    }
}

InitializeMultipliers() {
    // Initialize multipliers for each prestige level
    // Base: 1.0 (100%)
    // Each prestige adds bonuses
    for (new i = 0; i <= MAX_PRESTIGE; i++) {
        g_xpMultiplier[i] = 1.0 + (float(i) * 0.05) // 5% per prestige
        g_coinMultiplier[i] = 1.0 + (float(i) * 0.10) // 10% per prestige

        // Cap at reasonable values
        if (g_xpMultiplier[i] > 2.0) g_xpMultiplier[i] = 2.0 // Max 200% XP
        if (g_coinMultiplier[i] > 3.0) g_coinMultiplier[i] = 3.0 // Max 300% coins
    }
}

LoadPrestigePerks() {
    // Load from configuration file
    new configFile[128]
    get_configsdir(configFile, charsmax(configFile))
    add(configFile, charsmax(configFile), "/zombie_crown/zc_prestige.ini")

    if (file_exists(configFile)) {
        new file = fopen(configFile, "r")
        if (file) {
            new line[512], section[64]
            while (!feof(file)) {
                fgets(file, line, charsmax(line))
                trim(line)

                if (line[0] == ';' || line[0] == '/' || line[0] == 0) continue

                if (line[0] == '[') {
                    copy(section, charsmax(section), line)
                    continue
                }

                new key[64], data[256]
                strtok(line, key, charsmax(key), data, charsmax(data), '=')
                trim(key)
                trim(data)

                if (!equal(key, "") && !equal(data, "")) {
                    ParsePrestigePerk(key, data)
                }
            }
            fclose(file)
        }
    }

    // Create default perks if none loaded
    if (g_perkCount == 0) {
        CreateDefaultPerks()
    }
}

ParsePrestigePerk(const key[], const data[]) {
    new perk[PrestigePerk]

    copy(perk[PERK_NAME], charsmax(perk[PERK_NAME]), key)

    // Parse format: "Description|type|value|prestige_required|cost"
    new parsed[5][128]
    explode(data, parsed, charsmax(parsed), charsmax(parsed), "|")

    copy(perk[PERK_DESCRIPTION], charsmax(perk[PERK_DESCRIPTION]), parsed[0])

    new typeStr[32]
    copy(typeStr, charsmax(typeStr), parsed[1])

    if (equal(typeStr, "xp_bonus")) perk[PERK_TYPE] = PERK_XP_BONUS
    else if (equal(typeStr, "coin_bonus")) perk[PERK_TYPE] = PERK_COIN_BONUS
    else if (equal(typeStr, "kill_effect")) perk[PERK_TYPE] = PERK_KILL_EFFECT
    else if (equal(typeStr, "class_access")) perk[PERK_TYPE] = PERK_CLASS_ACCESS
    else if (equal(typeStr, "title")) perk[PERK_TYPE] = PERK_TITLE
    else if (equal(typeStr, "badge")) perk[PERK_TYPE] = PERK_BADGE

    perk[PERK_VALUE_INT] = str_to_num(parsed[2])
    perk[PERK_VALUE_FLOAT] = str_to_float(parsed[2])
    copy(perk[PERK_VALUE_STRING], charsmax(perk[PERK_VALUE_STRING]), parsed[2])
    perk[PERK_PRESTIGE_REQUIRED] = str_to_num(parsed[3])
    perk[PERK_COST] = str_to_num(parsed[4])

    perk[PERK_ID] = g_perkCount
    ArrayPushArray(g_prestigePerks, perk)
    g_perkCount++
}

CreateDefaultPerks() {
    log_amx("[ZC Prestige] Creating default perks...")

    new perk[PrestigePerk]

    // Prestige 1 - XP Boost
    perk[PERK_ID] = g_perkCount
    copy(perk[PERK_NAME], charsmax(perk[PERK_NAME]), "Expert Awareness")
    copy(perk[PERK_DESCRIPTION], charsmax(perk[PERK_DESCRIPTION]), "5% bonus XP per kill")
    perk[PERK_TYPE] = PERK_XP_BONUS
    perk[PERK_VALUE_INT] = 5
    perk[PERK_PRESTIGE_REQUIRED] = 1
    perk[PERK_COST] = 0
    ArrayPushArray(g_prestigePerks, perk)
    g_perkCount++

    // Prestige 1 - Coin Boost
    perk[PERK_ID] = g_perkCount
    copy(perk[PERK_NAME], charsmax(perk[PERK_NAME]), "Coin Magnet")
    copy(perk[PERK_DESCRIPTION], charsmax(perk[PERK_DESCRIPTION]), "10% bonus coins per kill")
    perk[PERK_TYPE] = PERK_COIN_BONUS
    perk[PERK_VALUE_INT] = 10
    perk[PERK_PRESTIGE_REQUIRED] = 1
    perk[PERK_COST] = 0
    ArrayPushArray(g_prestigePerks, perk)
    g_perkCount++

    // Prestige 5 - Fire Effect
    perk[PERK_ID] = g_perkCount
    copy(perk[PERK_NAME], charsmax(perk[PERK_NAME]), "Death Aura")
    copy(perk[PERK_DESCRIPTION], charsmax(perk[PERK_DESCRIPTION]), "Unlocked special fire kill effect")
    perk[PERK_TYPE] = PERK_KILL_EFFECT
    copy(perk[PERK_VALUE_STRING], charsmax(perk[PERK_VALUE_STRING]), "fire_aura")
    perk[PERK_PRESTIGE_REQUIRED] = 5
    perk[PERK_COST] = 500
    ArrayPushArray(g_prestigePerks, perk)
    g_perkCount++

    // Prestige 10 - Elite Class
    perk[PERK_ID] = g_perkCount
    copy(perk[PERK_NAME], charsmax(perk[PERK_NAME]), "Elite Access")
    copy(perk[PERK_DESCRIPTION], charsmax(perk[PERK_DESCRIPTION]), "Unlock elite zombie class")
    perk[PERK_TYPE] = PERK_CLASS_ACCESS
    copy(perk[PERK_VALUE_STRING], charsmax(perk[PERK_VALUE_STRING]), "elite_zombie")
    perk[PERK_PRESTIGE_REQUIRED] = 10
    perk[PERK_COST] = 2000
    ArrayPushArray(g_prestigePerks, perk)
    g_perkCount++

    log_amx("[ZC Prestige] Created %d default perks", g_perkCount)
}

explode(const input[], output[][], maxElements, maxLen, const delimiter[]) {
    new count = 0
    new pos = 0, len = strlen(input)

    while (pos < len && count < maxElements) {
        new end = contain(input[pos], delimiter)
        if (end == -1) end = len - pos

        formatex(output[count], maxLen, "%s", input[pos])
        copy(output[count], min(end + 1, maxLen), input[pos])
        output[count][min(end, maxLen - 1)] = 0

        pos += end + strlen(delimiter)
        count++
    }

    return count
}

public client_putinserver(id) {
    // Load player prestige data from profile system
    // For now, initialize defaults
    g_playerPrestige[id][PPRESTIGE_LEVEL] = 0
    g_playerPrestige[id][PPRESTIGE_POINTS] = 0
    g_playerPrestige[id][PPRESTIGE_XP_MULTIPLIER] = 100 // 1.00 = 100%
    g_playerPrestige[id][PPRESTIGE_COIN_MULTIPLIER] = 100

    // Clear unlocked perks
    for (new i = 0; i < 32; i++) {
        g_playerUnlockedPerks[id][i] = 0
    }

    // Load from profile if available
    if (is_native_valid("zc_get_user_database_id")) {
        // This will be handled by the profile system
        set_task(1.0, "LoadPlayerPrestige", id)
    }
}

public LoadPlayerPrestige(id) {
    // Get prestige from profile system
    // This would typically be done through profile natives
    // For now, we'll use a placeholder
}

// ============================================================================
// PLAYER COMMANDS
// ============================================================================

public CmdPrestigeMenu(id) {
    if (!get_pcvar_num(g_pcvarEnabled)) {
        client_print(id, print_chat, "[ZC] Prestige system is currently disabled.")
        return PLUGIN_HANDLED
    }

    new menu = menu_create("Prestige System", "PrestigeMenuHandler")

    // Current prestige info
    new info[256]
    new currentLevel = zp_get_user_level(id)
    new currentPrestige = g_playerPrestige[id][PPRESTIGE_LEVEL]
    new requiredLevel = GetRequiredLevelForPrestige(currentPrestige + 1)
    new canPrestige = (currentLevel >= requiredLevel && currentPrestige < get_pcvar_num(g_pcvarMaxPrestige))

    formatex(info, charsmax(info), "\yCurrent Prestige: \r%d\w^n\yPrestige Points: \r%d\w^n\yYour Level: \r%d / %d Required^n\yNext Prestige: \w%s",
        currentPrestige,
        g_playerPrestige[id][PPRESTIGE_POINTS],
        currentLevel, requiredLevel,
        canPrestige ? "\yReady!" : "\dNot Ready")
    menu_addtext(menu, info, false)

    menu_addblank(menu, false)

    // Prestige option
    new item[128]
    if (canPrestige) {
        formatex(item, charsmax(item), "\yPrestige Now!")
        menu_additem(menu, item, "1", 0)
    } else {
        formatex(item, charsmax(item), "\dPrestige Now! (Not Ready)")
        menu_additem(menu, item, "1", (1<<0)) // ITEMDRAW_DISABLED = (1<<0)
    }

    // Prestige shop
    formatex(item, charsmax(item), "Prestige Shop")
    menu_additem(menu, item, "2", 0)

    // View perks
    formatex(item, charsmax(item), "View Unlocked Perks")
    menu_additem(menu, item, "3", 0)

    // Multipliers
    formatex(item, charsmax(item), "Current Multipliers")
    menu_additem(menu, item, "4", 0)

    menu_display(id, menu)

    return PLUGIN_HANDLED
}

public PrestigeMenuHandler(id, menu, item) {
    if (item == MENU_EXIT) {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    new access, callback, info[8]
    menu_item_getinfo(menu, item, access, info, charsmax(info), _, _, callback)

    new choice = str_to_num(info)

    switch (choice) {
        case 1: CmdPrestigeNow(id)
        case 2: CmdPrestigeShop(id)
        case 3: ShowUnlockedPerks(id)
        case 4: ShowMultipliers(id)
    }

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

public CmdPrestigeNow(id) {
    if (!CanPlayerPrestige(id)) {
        new currentLevel = zp_get_user_level(id)
        new currentPrestige = g_playerPrestige[id][PPRESTIGE_LEVEL]
        new requiredLevel = GetRequiredLevelForPrestige(currentPrestige + 1)

        client_print(id, print_chat, "[ZC] You need to reach level %d to prestige!", requiredLevel)
        return PLUGIN_HANDLED
    }

    // Show confirmation dialog
    new menu = menu_create("Confirm Prestige", "PrestigeConfirmHandler")

    new info[256]
    formatex(info, charsmax(info), "\yAre you sure you want to prestige?^n^n\rWARNING: \wThis will:^n- Reset your level to 1^n- Reset your XP to 0^n- Keep your statistics^n- Unlock permanent bonuses^n^n\yCurrent Prestige: \r%d\w -> \y%d",
        g_playerPrestige[id][PPRESTIGE_LEVEL],
        g_playerPrestige[id][PPRESTIGE_LEVEL] + 1)

    menu_addtext(menu, info, false)

    menu_additem(menu, "Yes, prestige me!", "1")
    menu_additem(menu, "No, cancel", "2")

    menu_display(id, menu)

    return PLUGIN_HANDLED
}

public PrestigeConfirmHandler(id, menu, item) {
    if (item == MENU_EXIT || item == 1) {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    if (item == 0) {
        // Confirm prestige
        PerformPrestige(id)
    }

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

PerformPrestige(id) {
    new oldPrestige = g_playerPrestige[id][PPRESTIGE_LEVEL]
    new newPrestige = oldPrestige + 1

    // Reset level and XP
    zp_set_user_level(id, 1)
    zp_set_user_xp(id, 0)

    // Update prestige
    g_playerPrestige[id][PPRESTIGE_LEVEL] = newPrestige

    // Grant prestige points
    new prestigePoints = newPrestige * 100
    g_playerPrestige[id][PPRESTIGE_POINTS] += prestigePoints

    // Update multipliers
    g_playerPrestige[id][PPRESTIGE_XP_MULTIPLIER] = floatround(g_xpMultiplier[newPrestige] * 100)
    g_playerPrestige[id][PPRESTIGE_COIN_MULTIPLIER] = floatround(g_coinMultiplier[newPrestige] * 100)

    // Check for unlocked perks
    for (new i = 0; i < g_perkCount; i++) {
        new perk[PrestigePerk]
        ArrayGetArray(g_prestigePerks, i, perk)

        if (perk[PERK_PRESTIGE_REQUIRED] == newPrestige) {
            GrantPrestigePerk(id, perk)
        }
    }

    // Show notification
    ShowPrestigeNotification(id, newPrestige)

    // Create prestige effect
    CreatePrestigeEffect(id)

    // Log
    new playerName[32]
    get_user_name(id, playerName, charsmax(playerName))
    log_amx("[ZC Prestige] %s prestiged to level %d", playerName, newPrestige)

    // Call forward
    ExecuteForward(g_fwPlayerPrestiged, g_ret, id, newPrestige)

    // Save to profile
    if (is_native_valid("zc_set_user_stat")) {
        // This will be handled by profile system
    }

    client_print(id, print_chat, "[ZC] Congratulations! You are now Prestige %d!", newPrestige)
}

ShowPrestigeNotification(id, prestigeLevel) {
    if (is_native_valid("zc_hud_show_prestige")) {
        zc_hud_show_prestige(id, prestigeLevel)
    } else {
        // Fallback to dhudmessage
        set_dhudmessage(255, 215, 0, -1.0, 0.25, 0, 0.0, 8.0, 0.5, 2.0)
        show_dhudmessage(id, "PRESTIGE LEVEL UP!^n^nYou are now Prestige %d^n+ Bonuses Unlocked!", prestigeLevel)
    }
}

CreatePrestigeEffect(id) {
    // Screen fade to gold
    message_begin(MSG_ONE, get_user_msgid("ScreenFade"), _, id)
    write_short(10<<12)  // duration
    write_short(10<<12)  // hold time
    write_short(FFADE_IN)  // flags
    write_byte(255)  // R
    write_byte(215)  // G
    write_byte(0)    // B
    write_byte(200)  // Alpha
    message_end()

    // Create gold particles
    new origin[3]
    get_user_origin(id, origin)

    // Create sprite effect
    for (new i = 0; i < 50; i++) {
        message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
        write_byte(TE_SPRITE)
        write_coord(origin[0] + random_num(-100, 100))
        write_coord(origin[1] + random_num(-100, 100))
        write_coord(origin[2] + random_num(0, 100))
        write_short(precache_model("sprites/flare6.spr"))
        write_byte(random_num(5, 15))
        write_byte(150)
        message_end()
    }
}

CanPlayerPrestige(id) {
    new currentLevel = zp_get_user_level(id)
    new currentPrestige = g_playerPrestige[id][PPRESTIGE_LEVEL]
    new maxPrestige = get_pcvar_num(g_pcvarMaxPrestige)

    if (currentPrestige >= maxPrestige) return false

    new requiredLevel = GetRequiredLevelForPrestige(currentPrestige + 1)
    return (currentLevel >= requiredLevel)
}

GetRequiredLevelForPrestige(prestigeLevel) {
    new baseLevel = get_pcvar_num(g_pcvarBaseLevel)
    new increment = get_pcvar_num(g_pcvarLevelIncrement)

    return baseLevel + ((prestigeLevel - 1) * increment)
}

public CmdPrestigeShop(id) {
    new menu = menu_create("Prestige Shop", "PrestigeShopHandler")

    new info[128]
    formatex(info, charsmax(info), "\yYour Points: \r%d", g_playerPrestige[id][PPRESTIGE_POINTS])
    menu_addtext(menu, info, false)
    menu_addblank(menu, false)

    // Add available perks
    new addedCount = 0
    for (new i = 0; i < g_perkCount; i++) {
        new perk[PrestigePerk]
        ArrayGetArray(g_prestigePerks, i, perk)

        // Check if player meets prestige requirement
        if (g_playerPrestige[id][PPRESTIGE_LEVEL] < perk[PERK_PRESTIGE_REQUIRED]) continue

        // Check if already unlocked
        if (g_playerUnlockedPerks[id][i]) continue

        new item[256]
        formatex(item, charsmax(item), "\y%s^n\w%s^n\rCost: %d Points",
            perk[PERK_NAME],
            perk[PERK_DESCRIPTION],
            perk[PERK_COST])

        new info[8]
        num_to_str(i, info, charsmax(info))
        menu_additem(menu, item, info)
        addedCount++
    }

    if (addedCount == 0) {
        menu_addtext(menu, "\dNo perks available", false)
    }

    menu_display(id, menu)

    return PLUGIN_HANDLED
}

public PrestigeShopHandler(id, menu, item) {
    if (item == MENU_EXIT) {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    new access, callback, info[8]
    menu_item_getinfo(menu, item, access, info, charsmax(info), _, _, callback)

    new perkIndex = str_to_num(info)

    // Purchase perk
    PurchasePrestigePerk(id, perkIndex)

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

PurchasePrestigePerk(id, perkIndex) {
    new perk[PrestigePerk]
    ArrayGetArray(g_prestigePerks, perkIndex, perk)

    // Check cost
    if (g_playerPrestige[id][PPRESTIGE_POINTS] < perk[PERK_COST]) {
        client_print(id, print_chat, "[ZC] Not enough prestige points! Need %d, have %d",
            perk[PERK_COST], g_playerPrestige[id][PPRESTIGE_POINTS])
        return
    }

    // Deduct points
    g_playerPrestige[id][PPRESTIGE_POINTS] -= perk[PERK_COST]

    // Grant perk
    GrantPrestigePerk(id, perk)

    client_print(id, print_chat, "[ZC] Purchased: %s", perk[PERK_NAME])

    // Show shop again
    CmdPrestigeShop(id)
}

GrantPrestigePerk(id, perk[PrestigePerk]) {
    // Mark as unlocked
    g_playerUnlockedPerks[id][perk[PERK_ID]] = 1

    // Apply perk effect
    switch (perk[PERK_TYPE]) {
        case PERK_XP_BONUS: {
            // This is handled by the multiplier system
        }
        case PERK_COIN_BONUS: {
            // This is handled by the multiplier system
        }
        case PERK_KILL_EFFECT: {
            // Unlock kill effect - to be implemented with kill effects system
        }
        case PERK_CLASS_ACCESS: {
            // Unlock class - to be implemented
        }
        case PERK_TITLE: {
            // Grant title - to be implemented
        }
        case PERK_BADGE: {
            // Grant badge - to be implemented
        }
    }

    // Call forward
    ExecuteForward(g_fwPrestigePerkGranted, g_ret, id, perk[PERK_ID])
}

ShowUnlockedPerks(id) {
    new motd[1024]

    copy(motd, charsmax(motd), "<html><head>")
    add(motd, charsmax(motd), "<style>")
    add(motd, charsmax(motd), "body { font-family: Arial; background: #1a1a2e; color: #eee; padding: 20px; }")
    add(motd, charsmax(motd), "h2 { color: #ffd700; }")
    add(motd, charsmax(motd), ".perk { background: rgba(255,255,255,0.05); padding: 10px; margin: 10px 0; border-left: 3px solid #4ecdc4; }")
    add(motd, charsmax(motd), ".perk-name { color: #4ecdc4; font-weight: bold; }")
    add(motd, charsmax(motd), "</style></head><body>")
    add(motd, charsmax(motd), "<h2>Unlocked Prestige Perks</h2>")

    new count = 0
    for (new i = 0; i < g_perkCount; i++) {
        if (!g_playerUnlockedPerks[id][i]) continue

        new perk[PrestigePerk]
        ArrayGetArray(g_prestigePerks, i, perk)

        formatex(motd, charsmax(motd), "%s<div class='perk'><div class='perk-name'>%s</div><div>%s</div></div>",
            motd, perk[PERK_NAME], perk[PERK_DESCRIPTION])
        count++
    }

    if (count == 0) {
        formatex(motd, charsmax(motd), "%s<p>No perks unlocked yet.</p>", motd)
    }

    formatex(motd, charsmax(motd), "%s</body></html>", motd)

    show_motd(id, motd, "Unlocked Perks")
}

ShowMultipliers(id) {
    new currentPrestige = g_playerPrestige[id][PPRESTIGE_LEVEL]
    new Float:xpMult = g_xpMultiplier[currentPrestige]
    new Float:coinMult = g_coinMultiplier[currentPrestige]

    new motd[512]
    copy(motd, charsmax(motd), "<html><head>")
    add(motd, charsmax(motd), "<style>")
    add(motd, charsmax(motd), "body { font-family: Arial; background: #1a1a2e; color: #eee; padding: 20px; text-align: center; }")
    add(motd, charsmax(motd), "h2 { color: #ffd700; }")
    add(motd, charsmax(motd), ".mult { font-size: 24px; color: #4ecdc4; margin: 20px 0; }")
    add(motd, charsmax(motd), "</style></head><body>")
    formatex(motd, charsmax(motd), "%s<h2>Prestige %d Multipliers</h2><div class='mult'>XP: %d%%</div><div class='mult'>Coins: %d%%</div></body></html>",
        motd,
        currentPrestige,
        floatround(xpMult * 100),
        floatround(coinMult * 100))

    show_motd(id, motd, "Multipliers")
}

// ============================================================================
// ADMIN COMMANDS
// ============================================================================

public CmdSetPrestige(id, level, cid) {
    if (!cmd_access(id, level, cid, 3)) return PLUGIN_HANDLED

    new target[32], levelStr[8]
    read_argv(1, target, charsmax(target))
    read_argv(2, levelStr, charsmax(levelStr))

    new player = cmd_target(id, target, CMDTARGET_ALLOW_SELF)
    if (!player) {
        console_print(id, "[ZC Prestige] Player not found: %s", target)
        return PLUGIN_HANDLED
    }

    new newPrestige = str_to_num(levelStr)
    new maxPrestige = get_pcvar_num(g_pcvarMaxPrestige)

    if (newPrestige < 0 || newPrestige > maxPrestige) {
        console_print(id, "[ZC Prestige] Invalid prestige level: %d (0-%d)", newPrestige, maxPrestige)
        return PLUGIN_HANDLED
    }

    g_playerPrestige[player][PPRESTIGE_LEVEL] = newPrestige
    g_playerPrestige[player][PPRESTIGE_XP_MULTIPLIER] = floatround(g_xpMultiplier[newPrestige] * 100)
    g_playerPrestige[player][PPRESTIGE_COIN_MULTIPLIER] = floatround(g_coinMultiplier[newPrestige] * 100)

    new playerName[32]
    get_user_name(player, playerName, charsmax(playerName))

    console_print(id, "[ZC Prestige] Set %s's prestige to %d", playerName, newPrestige)
    client_print(player, print_chat, "[ZC] Your prestige has been set to %d by an admin.", newPrestige)

    return PLUGIN_HANDLED
}

public CmdAddPrestigePoints(id, level, cid) {
    if (!cmd_access(id, level, cid, 3)) return PLUGIN_HANDLED

    new target[32], amountStr[8]
    read_argv(1, target, charsmax(target))
    read_argv(2, amountStr, charsmax(amountStr))

    new player = cmd_target(id, target, CMDTARGET_ALLOW_SELF)
    if (!player) {
        console_print(id, "[ZC Prestige] Player not found: %s", target)
        return PLUGIN_HANDLED
    }

    new amount = str_to_num(amountStr)

    g_playerPrestige[player][PPRESTIGE_POINTS] += amount

    new playerName[32]
    get_user_name(player, playerName, charsmax(playerName))

    console_print(id, "[ZC Prestige] Added %d prestige points to %s", amount, playerName)
    client_print(player, print_chat, "[ZC] You received %d prestige points from an admin.", amount)

    return PLUGIN_HANDLED
}

public CmdResetPrestige(id, level, cid) {
    if (!cmd_access(id, level, cid, 2)) return PLUGIN_HANDLED

    new target[32]
    read_argv(1, target, charsmax(target))

    new player = cmd_target(id, target, CMDTARGET_ALLOW_SELF)
    if (!player) {
        console_print(id, "[ZC Prestige] Player not found: %s", target)
        return PLUGIN_HANDLED
    }

    g_playerPrestige[player][PPRESTIGE_LEVEL] = 0
    g_playerPrestige[player][PPRESTIGE_POINTS] = 0
    g_playerPrestige[player][PPRESTIGE_XP_MULTIPLIER] = 100
    g_playerPrestige[player][PPRESTIGE_COIN_MULTIPLIER] = 100

    for (new i = 0; i < 32; i++) {
        g_playerUnlockedPerks[player][i] = 0
    }

    new playerName[32]
    get_user_name(player, playerName, charsmax(playerName))

    console_print(id, "[ZC Prestige] Reset prestige for %s", playerName)
    client_print(player, print_chat, "[ZC] Your prestige has been reset by an admin.")

    return PLUGIN_HANDLED
}

// ============================================================================
// PUBLIC API
// ============================================================================

public plugin_natives() {
    register_native("zc_get_user_prestige", "NativeGetPrestige")
    register_native("zc_get_user_prestige_points", "NativeGetPrestigePoints")
    register_native("zc_can_prestige", "NativeCanPrestige")
    register_native("zc_prestige_player", "NativePrestigePlayer")
    register_native("zc_get_prestige_bonus", "NativeGetPrestigeBonus")
    register_native("zc_get_xp_multiplier", "NativeGetXPMultiplier")
    register_native("zc_get_coin_multiplier", "NativeGetCoinMultiplier")
}

public NativeGetPrestige(plugin, params) {
    new id = get_param(1)
    if (id < 1 || id > 32) return 0
    return g_playerPrestige[id][PPRESTIGE_LEVEL]
}

public NativeGetPrestigePoints(plugin, params) {
    new id = get_param(1)
    if (id < 1 || id > 32) return 0
    return g_playerPrestige[id][PPRESTIGE_POINTS]
}

public NativeCanPrestige(plugin, params) {
    new id = get_param(1)
    if (id < 1 || id > 32) return 0
    return CanPlayerPrestige(id) ? 1 : 0
}

public NativePrestigePlayer(plugin, params) {
    new id = get_param(1)
    if (id < 1 || id > 32) return 0

    if (!CanPlayerPrestige(id)) return 0

    PerformPrestige(id)
    return 1
}

public NativeGetPrestigeBonus(plugin, params) {
    new id = get_param(1)
    new bonusType[32]
    get_string(2, bonusType, charsmax(bonusType))

    if (id < 1 || id > 32) return 0

    new prestige = g_playerPrestige[id][PPRESTIGE_LEVEL]

    if (equal(bonusType, "xp_mult")) {
        return floatround(g_xpMultiplier[prestige] * 100)
    } else if (equal(bonusType, "coin_mult")) {
        return floatround(g_coinMultiplier[prestige] * 100)
    }

    return 100 // 1.0 = 100%
}

public NativeGetXPMultiplier(plugin, params) {
    new id = get_param(1)
    if (id < 1 || id > 32) return 100

    new prestige = g_playerPrestige[id][PPRESTIGE_LEVEL]
    return floatround(g_xpMultiplier[prestige] * 100)
}

public NativeGetCoinMultiplier(plugin, params) {
    new id = get_param(1)
    if (id < 1 || id > 32) return 100

    new prestige = g_playerPrestige[id][PPRESTIGE_LEVEL]
    return floatround(g_coinMultiplier[prestige] * 100)
}
