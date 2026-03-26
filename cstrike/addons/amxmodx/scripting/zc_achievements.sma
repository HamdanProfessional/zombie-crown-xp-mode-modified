/************************************************************************************\
		   ========================================
	       * || Zombie Crown XP Mode - Achievements || *
	       * || 500+ Achievements with Rewards || *
		   ========================================
\************************************************************************************/

#include <amxmodx>
#include <amxmisc>
#include <sqlx>
#include <hamsandwich>
#include <dhudmessage>
#include <zombiecrown>

// Menu draw flags
#define ITEMDRAW_DISABLED (1<<0)
#define ITEMDRAW_ENABLED 0

// Helper functions
stock is_user_valid_connected(id) {
    return is_user_connected(id) && is_user_alive(id)
}

stock is_native_valid(const native_name[]) {
    return true // Placeholder - actual implementation would check native availability
}

#define PLUGIN_VERSION "1.0.0"
#define PLUGIN_AUTHOR "Zombie Crown Dev Team"
#define PLUGIN_NAME "ZC Achievements"

// Achievement categories
enum AchievementCategory {
    ACH_CAT_KILLS = 0,
    ACH_CAT_INFECTIONS,
    ACH_CAT_LEVEL,
    ACH_CAT_CLASS,
    ACH_CAT_SPECIAL,
    ACH_CAT_PRESTIGE,
    ACH_CAT_TIME,
    ACH_CAT_CHALLENGE,
    ACH_CAT_MAX
}

new const g_achievementCategoryNames[][32] = {
    "Kills",
    "Infections",
    "Level Milestones",
    "Class Specific",
    "Special Events",
    "Prestige",
    "Playtime",
    "Challenges"
}

// Achievement data
enum AchievementData {
    ACH_ID,
    ACH_KEY[64],
    ACH_NAME[128],
    ACH_DESCRIPTION[256],
    ACH_CATEGORY,
    ACH_REQUIREMENT_TYPE[32],
    ACH_REQUIREMENT_VALUE,
    ACH_REWARD_TYPE[16],
    ACH_REWARD_AMOUNT,
    ACH_ICON[64],
    ACH_IS_HIDDEN,
    ACH_SORT_ORDER
}

// Player achievement progress
enum PlayerAchievement {
    PACH_ACHIEVEMENT_ID,
    PACH_PROGRESS,
    PACH_COMPLETED,
    PACH_UNLOCK_TIMESTAMP
}

// Achievement event types
enum AchievementEvent {
    ACH_EVENT_KILL = 0,
    ACH_EVENT_INFECT,
    ACH_EVENT_LEVEL_UP,
    ACH_EVENT_PRESTIGE,
    ACH_EVENT_DAILY_COMPLETE,
    ACH_EVENT_CLASS_KILL,
    ACH_EVENT_PLAYTIME,
    ACH_EVENT_ROUND_WIN,
    ACH_EVENT_NEMESIS_KILL,
    ACH_EVENT_SURVIVOR_KILL,
    ACH_EVENT_FIRST_ZOMBIE_KILL,
    ACH_EVENT_LAST_HUMAN_KILL
}

// Achievement storage
new Array:g_achievementsList
new g_achievementCount = 0

// Player achievement data
new Array:g_playerAchievements[33]

// Configuration
new g_pcvarEnabled
new g_pcvarNotificationDuration
new g_pcvarAutoSaveProgress
new g_pcvarCheckFrequency

// Database
new Handle:g_dbTuple

// Event hooks
new g_fwKills
new g_fwInfections
new g_fwLevelUp

// Check throttle (only check every N kills to save performance)
new g_killCounter[33]

// Forwards
new g_fwAchievementUnlocked
new g_fwAchievementProgressUpdated
new g_ret

public plugin_init() {
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

    // Configuration CVARs
    g_pcvarEnabled = register_cvar("zc_achievements_enabled", "1")
    g_pcvarNotificationDuration = register_cvar("zc_achievements_notification_duration", "5.0")
    g_pcvarAutoSaveProgress = register_cvar("zc_achievements_auto_save", "1")
    g_pcvarCheckFrequency = register_cvar("zc_achievements_check_frequency", "5")

    // Player commands
    register_clcmd("say /achievements", "CmdAchievementsMenu")
    register_clcmd("say_team /achievements", "CmdAchievementsMenu")
    register_clcmd("say /ach", "CmdAchievementsMenu")
    register_clcmd("say_team /ach", "CmdAchievementsMenu")

    // Admin commands
    register_concmd("zc_list_achievements", "CmdListAchievements", ADMIN_CFG, "List all achievements")
    register_concmd("zc_unlock_achievement", "CmdUnlockAchievement", ADMIN_CFG, "<player> <achievement_id> - Unlock achievement for player")
    register_concmd("zc_reset_achievements", "CmdResetAchievements", ADMIN_RCON, "<player> - Reset player's achievements")

    // Initialize database
    InitializeDatabase()

    // Create achievement array
    g_achievementsList = ArrayCreate(AchievementData)

    // Create player achievement arrays
    for (new i = 0; i < 33; i++) {
        g_playerAchievements[i] = Invalid_Array
    }

    // Create forwards
    g_fwAchievementUnlocked = CreateMultiForward("zc_achievement_unlocked", ET_IGNORE, FP_CELL, FP_CELL)
    g_fwAchievementProgressUpdated = CreateMultiForward("zc_achievement_progress_updated", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL)

    // Load achievements from configuration
    LoadAchievements()

    // Hook game events
    RegisterHam(Ham_Killed, "player", "fw_PlayerKilled", 0)

    // Log startup
    log_amx("[ZC Achievements] Loaded %d achievements", g_achievementCount)
}

public plugin_end() {
    // Clean up arrays
    if (g_achievementsList) {
        ArrayDestroy(g_achievementsList)
    }

    for (new i = 0; i < 33; i++) {
        if (g_playerAchievements[i] != Invalid_Array) {
            ArrayDestroy(g_playerAchievements[i])
        }
    }
}

InitializeDatabase() {
    // Get database info
    new host[64], user[64], pass[64], db[64]
    get_cvar_string("amx_sql_host", host, charsmax(host))
    get_cvar_string("amx_sql_user", user, charsmax(user))
    get_cvar_string("amx_sql_pass", pass, charsmax(pass))
    get_cvar_string("amx_sql_db", db, charsmax(db))

    g_dbTuple = SQL_MakeDbTuple(host, user, pass, db)

    // Create tables
    new query[1024]

    // Achievements table
    copy(query, charsmax(query), "CREATE TABLE IF NOT EXISTS `zc_achievements` (")
    add(query, charsmax(query), "`achievement_id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,")
    add(query, charsmax(query), "`achievement_key` VARCHAR(64) UNIQUE NOT NULL,")
    add(query, charsmax(query), "`achievement_name` VARCHAR(128),")
    add(query, charsmax(query), "`description` VARCHAR(256),")
    add(query, charsmax(query), "`category` VARCHAR(32),")
    add(query, charsmax(query), "`requirement_type` VARCHAR(32),")
    add(query, charsmax(query), "`requirement_value` INT,")
    add(query, charsmax(query), "`reward_type` VARCHAR(16),")
    add(query, charsmax(query), "`reward_amount` INT,")
    add(query, charsmax(query), "`icon` VARCHAR(64),")
    add(query, charsmax(query), "`is_hidden` BOOLEAN DEFAULT FALSE,")
    add(query, charsmax(query), "`sort_order` INT DEFAULT 0);")

    SQL_ThreadQuery(g_dbTuple, "HandleTableCreate", query)

    // Player achievements table
    copy(query, charsmax(query), "CREATE TABLE IF NOT EXISTS `zc_player_achievements` (")
    add(query, charsmax(query), "`id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,")
    add(query, charsmax(query), "`player_id` INT NOT NULL,")
    add(query, charsmax(query), "`achievement_id` INT NOT NULL,")
    add(query, charsmax(query), "`progress` INT DEFAULT 0,")
    add(query, charsmax(query), "`completed` BOOLEAN DEFAULT FALSE,")
    add(query, charsmax(query), "`unlocked_at` DATETIME,")
    add(query, charsmax(query), "FOREIGN KEY (player_id) REFERENCES zc_players(player_id) ON DELETE CASCADE,")
    add(query, charsmax(query), "FOREIGN KEY (achievement_id) REFERENCES zc_achievements(achievement_id),")
    add(query, charsmax(query), "UNIQUE KEY unique_player_achievement (player_id, achievement_id);")

    SQL_ThreadQuery(g_dbTuple, "HandleTableCreate", query)
}

public HandleTableCreate(failState, Handle:query, error[], errnum, data[], size) {
    if (failState) {
        log_amx("[ZC Achievements] Failed to create table: %s", error)
    }
}

LoadAchievements() {
    // Load from configuration file
    new configFile[128]
    get_configsdir(configFile, charsmax(configFile))
    add(configFile, charsmax(configFile), "/zombie_crown/zc_achievements.ini")

    if (file_exists(configFile)) {
        new file = fopen(configFile, "r")
        if (file) {
            new line[1024], section[64]
            while (!feof(file)) {
                fgets(file, line, charsmax(line))
                trim(line)

                // Skip comments and empty lines
                if (line[0] == ';' || line[0] == '/' || line[0] == 0) continue

                // Section header
                if (line[0] == '[') {
                    copy(section, charsmax(section), line)
                    continue
                }

                // Parse achievement
                new key[64], data[512]
                strtok(line, key, charsmax(key), data, charsmax(data), '=')
                trim(key)
                trim(data)

                if (!equal(key, "") && !equal(data, "")) {
                    ParseAchievement(key, data, section)
                }
            }
            fclose(file)
        }
    }

    // If no achievements loaded, create default ones
    if (g_achievementCount == 0) {
        CreateDefaultAchievements()
    }
}

ParseAchievement(const key[], const data[], const category[]) {
    new ach[AchievementData]

    copy(ach[ACH_KEY], charsmax(ach[ACH_KEY]), key)

    // Parse data format: "Name|Description|req_type|req_value|reward_type|reward_amount|icon|hidden|sort"
    new parsed[10][256]
    explode(data, parsed, charsmax(parsed), charsmax(parsed), "|")

    copy(ach[ACH_NAME], charsmax(ach[ACH_NAME]), parsed[0])
    copy(ach[ACH_DESCRIPTION], charsmax(ach[ACH_DESCRIPTION]), parsed[1])
    copy(ach[ACH_REQUIREMENT_TYPE], charsmax(ach[ACH_REQUIREMENT_TYPE]), parsed[2])
    ach[ACH_REQUIREMENT_VALUE] = str_to_num(parsed[3])
    copy(ach[ACH_REWARD_TYPE], charsmax(ach[ACH_REWARD_TYPE]), parsed[4])
    ach[ACH_REWARD_AMOUNT] = str_to_num(parsed[5])
    copy(ach[ACH_ICON], charsmax(ach[ACH_ICON]), parsed[6])
    ach[ACH_IS_HIDDEN] = str_to_num(parsed[7])
    ach[ACH_SORT_ORDER] = str_to_num(parsed[8])

    // Determine category from section
    if (containi(category, "Kill") != -1) ach[ACH_CATEGORY] = ACH_CAT_KILLS
    else if (containi(category, "Infect") != -1) ach[ACH_CATEGORY] = ACH_CAT_INFECTIONS
    else if (containi(category, "Level") != -1) ach[ACH_CATEGORY] = ACH_CAT_LEVEL
    else if (containi(category, "Class") != -1) ach[ACH_CATEGORY] = ACH_CAT_CLASS
    else if (containi(category, "Special") != -1) ach[ACH_CATEGORY] = ACH_CAT_SPECIAL
    else if (containi(category, "Prestige") != -1) ach[ACH_CATEGORY] = ACH_CAT_PRESTIGE
    else if (containi(category, "Time") != -1) ach[ACH_CATEGORY] = ACH_CAT_TIME
    else if (containi(category, "Challenge") != -1) ach[ACH_CATEGORY] = ACH_CAT_CHALLENGE

    ach[ACH_ID] = g_achievementCount
    ArrayPushArray(g_achievementsList, ach)
    g_achievementCount++
}

CreateDefaultAchievements() {
    log_amx("[ZC Achievements] No achievements loaded, creating defaults...")

    // Create some basic default achievements
    new ach[AchievementData]

    // First kill
    ach[ACH_ID] = g_achievementCount
    copy(ach[ACH_KEY], charsmax(ach[ACH_KEY]), "FIRST_KILL")
    copy(ach[ACH_NAME], charsmax(ach[ACH_NAME]), "First Blood")
    copy(ach[ACH_DESCRIPTION], charsmax(ach[ACH_DESCRIPTION]), "Get your first kill")
    ach[ACH_CATEGORY] = ACH_CAT_KILLS
    copy(ach[ACH_REQUIREMENT_TYPE], charsmax(ach[ACH_REQUIREMENT_TYPE]), "kills")
    ach[ACH_REQUIREMENT_VALUE] = 1
    copy(ach[ACH_REWARD_TYPE], charsmax(ach[ACH_REWARD_TYPE]), "coins")
    ach[ACH_REWARD_AMOUNT] = 50
    copy(ach[ACH_ICON], charsmax(ach[ACH_ICON]), "achievement_first_blood")
    ach[ACH_IS_HIDDEN] = false
    ach[ACH_SORT_ORDER] = 1
    ArrayPushArray(g_achievementsList, ach)
    g_achievementCount++

    // 100 kills
    ach[ACH_ID] = g_achievementCount
    copy(ach[ACH_KEY], charsmax(ach[ACH_KEY]), "KILLS_100")
    copy(ach[ACH_NAME], charsmax(ach[ACH_NAME]), "Centurion")
    copy(ach[ACH_DESCRIPTION], charsmax(ach[ACH_DESCRIPTION]), "Kill 100 enemies")
    ach[ACH_CATEGORY] = ACH_CAT_KILLS
    copy(ach[ACH_REQUIREMENT_TYPE], charsmax(ach[ACH_REQUIREMENT_TYPE]), "kills")
    ach[ACH_REQUIREMENT_VALUE] = 100
    copy(ach[ACH_REWARD_TYPE], charsmax(ach[ACH_REWARD_TYPE]), "points")
    ach[ACH_REWARD_AMOUNT] = 500
    copy(ach[ACH_ICON], charsmax(ach[ACH_ICON]), "achievement_100")
    ach[ACH_IS_HIDDEN] = false
    ach[ACH_SORT_ORDER] = 2
    ArrayPushArray(g_achievementsList, ach)
    g_achievementCount++

    // First infection
    ach[ACH_ID] = g_achievementCount
    copy(ach[ACH_KEY], charsmax(ach[ACH_KEY]), "FIRST_INFECTION")
    copy(ach[ACH_NAME], charsmax(ach[ACH_NAME]), "Patient Zero")
    copy(ach[ACH_DESCRIPTION], charsmax(ach[ACH_DESCRIPTION]), "Infect your first human")
    ach[ACH_CATEGORY] = ACH_CAT_INFECTIONS
    copy(ach[ACH_REQUIREMENT_TYPE], charsmax(ach[ACH_REQUIREMENT_TYPE]), "infections")
    ach[ACH_REQUIREMENT_VALUE] = 1
    copy(ach[ACH_REWARD_TYPE], charsmax(ach[ACH_REWARD_TYPE]), "points")
    ach[ACH_REWARD_AMOUNT] = 100
    copy(ach[ACH_ICON], charsmax(ach[ACH_ICON]), "achievement_infect")
    ach[ACH_IS_HIDDEN] = false
    ach[ACH_SORT_ORDER] = 10
    ArrayPushArray(g_achievementsList, ach)
    g_achievementCount++

    // Level 10
    ach[ACH_ID] = g_achievementCount
    copy(ach[ACH_KEY], charsmax(ach[ACH_KEY]), "LEVEL_10")
    copy(ach[ACH_NAME], charsmax(ach[ACH_NAME]), "Rising Star")
    copy(ach[ACH_DESCRIPTION], charsmax(ach[ACH_DESCRIPTION]), "Reach level 10")
    ach[ACH_CATEGORY] = ACH_CAT_LEVEL
    copy(ach[ACH_REQUIREMENT_TYPE], charsmax(ach[ACH_REQUIREMENT_TYPE]), "level")
    ach[ACH_REQUIREMENT_VALUE] = 10
    copy(ach[ACH_REWARD_TYPE], charsmax(ach[ACH_REWARD_TYPE]), "xp")
    ach[ACH_REWARD_AMOUNT] = 1000
    copy(ach[ACH_ICON], charsmax(ach[ACH_ICON]), "achievement_level")
    ach[ACH_IS_HIDDEN] = false
    ach[ACH_SORT_ORDER] = 20
    ArrayPushArray(g_achievementsList, ach)
    g_achievementCount++

    log_amx("[ZC Achievements] Created %d default achievements", g_achievementCount)
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
    // Create player achievement array
    if (g_playerAchievements[id] != Invalid_Array) {
        ArrayDestroy(g_playerAchievements[id])
    }
    g_playerAchievements[id] = ArrayCreate(PlayerAchievement)

    // Reset kill counter
    g_killCounter[id] = 0

    // Load player's achievements from database
    LoadPlayerAchievements(id)
}

public client_disconnect(id) {
    // Save achievements if auto-save is enabled
    if (get_pcvar_num(g_pcvarAutoSaveProgress)) {
        SavePlayerAchievements(id)
    }

    // Clean up array
    if (g_playerAchievements[id] != Invalid_Array) {
        ArrayDestroy(g_playerAchievements[id])
        g_playerAchievements[id] = Invalid_Array
    }
}

LoadPlayerAchievements(id) {
    new steamId[32]
    get_user_authid(id, steamId, charsmax(steamId))

    new query[512]
    formatex(query, charsmax(query),
        "SELECT pa.achievement_id, pa.progress, pa.completed, pa.unlocked_at FROM zc_player_achievements pa JOIN zc_players p ON pa.player_id = p.player_id WHERE p.steam_id = '%s'",
        steamId)

    new data[2]
    data[0] = id
    SQL_ThreadQuery(g_dbTuple, "HandleAchievementsLoad", query, data, sizeof(data))
}

public HandleAchievementsLoad(failState, Handle:query, error[], errnum, data[], size) {
    new id = data[0]

    if (failState != TQUERY_SUCCESS) {
        log_amx("[ZC Achievements] Failed to load achievements for player %d: %s", id, error)
        return
    }

    while (SQL_MoreResults(query)) {
        new pach[PlayerAchievement]

        pach[PACH_ACHIEVEMENT_ID] = SQL_ReadResult(query, 0)
        pach[PACH_PROGRESS] = SQL_ReadResult(query, 1)
        pach[PACH_COMPLETED] = SQL_ReadResult(query, 2)

        ArrayPushArray(g_playerAchievements[id], pach)
        SQL_NextRow(query)
    }

    log_amx("[ZC Achievements] Loaded %d achievements for player %d", ArraySize(g_playerAchievements[id]), id)
}

SavePlayerAchievements(id) {
    if (!is_user_connected(id)) return

    new steamId[32]
    get_user_authid(id, steamId, charsmax(steamId))

    // Get player database ID from profile system
    // For now, we'll skip the save if we can't get the ID

    new size = ArraySize(g_playerAchievements[id])
    for (new i = 0; i < size; i++) {
        new pach[PlayerAchievement]
        ArrayGetArray(g_playerAchievements[id], i, pach)

        new query[512]
        if (pach[PACH_COMPLETED]) {
            // Update completed achievement
            formatex(query, charsmax(query),
                "UPDATE zc_player_achievements SET progress = %d, completed = 1, unlocked_at = NOW() WHERE player_id = (SELECT player_id FROM zc_players WHERE steam_id = '%s') AND achievement_id = %d",
                pach[PACH_PROGRESS], steamId, pach[PACH_ACHIEVEMENT_ID])
        } else {
            // Update progress
            formatex(query, charsmax(query),
                "UPDATE zc_player_achievements SET progress = %d WHERE player_id = (SELECT player_id FROM zc_players WHERE steam_id = '%s') AND achievement_id = %d",
                pach[PACH_PROGRESS], steamId, pach[PACH_ACHIEVEMENT_ID])
        }

        SQL_ThreadQuery(g_dbTuple, "HandleAchievementSave", query)
    }
}

public HandleAchievementSave(failState, Handle:query, error[], errnum, data[], size) {
    if (failState) {
        log_amx("[ZC Achievements] Failed to save achievement: %s", error)
    }
}

// ============================================================================
// GAME EVENT HOOKS
// ============================================================================

public fw_PlayerKilled(victim, attacker) {
    if (!get_pcvar_num(g_pcvarEnabled)) return HAM_IGNORED
    if (!is_user_valid_connected(attacker)) return HAM_IGNORED
    if (attacker == victim) return HAM_IGNORED // No suicide achievements

    // Increment kill counter for throttling
    g_killCounter[attacker]++
    new checkFrequency = get_pcvar_num(g_pcvarCheckFrequency)

    // Check kill-based achievements
    if (g_killCounter[attacker] >= checkFrequency) {
        g_killCounter[attacker] = 0
        CheckKillAchievements(attacker)
    }

    // Check special kill achievements (always check these)
    if (zp_get_user_nemesis(victim)) {
        CheckAchievementByType(attacker, "nemesis_kills", 1)
    }
    if (zp_get_user_survivor(victim)) {
        CheckAchievementByType(attacker, "survivor_kills", 1)
    }
    if (zp_get_user_first_zombie(victim)) {
        CheckAchievementByType(attacker, "first_zombie_kills", 1)
    }
    if (zp_get_user_last_human(victim)) {
        CheckAchievementByType(attacker, "last_human_kills", 1)
    }

    return HAM_IGNORED
}

CheckKillAchievements(id) {
    new totalKills = 0
    if (is_native_valid("zc_get_user_stat")) {
        totalKills = zc_get_user_stat(id, "total_kills")
    }

    CheckAchievementByType(id, "kills", totalKills)

    // Check zombie/human specific kills
    if (is_native_valid("zc_get_user_stat")) {
        new zombieKills = zc_get_user_stat(id, "zombie_kills")
        CheckAchievementByType(id, "zombie_kills", zombieKills)

        new humanKills = zc_get_user_stat(id, "human_kills")
        CheckAchievementByType(id, "human_kills", humanKills)
    }
}

CheckAchievementByType(id, const reqType[], currentValue) {
    for (new i = 0; i < g_achievementCount; i++) {
        new ach[AchievementData]
        ArrayGetArray(g_achievementsList, i, ach)

        if (!equal(ach[ACH_REQUIREMENT_TYPE], reqType)) continue

        // Check if already completed
        if (IsAchievementUnlocked(id, ach[ACH_ID])) continue

        // Check if requirement met
        if (currentValue >= ach[ACH_REQUIREMENT_VALUE]) {
            UnlockAchievement(id, ach[ACH_ID])
        } else {
            // Update progress
            UpdateAchievementProgress(id, ach[ACH_ID], currentValue)
        }
    }
}

IsAchievementUnlocked(id, achievementId) {
    new size = ArraySize(g_playerAchievements[id])
    for (new i = 0; i < size; i++) {
        new pach[PlayerAchievement]
        ArrayGetArray(g_playerAchievements[id], i, pach)

        if (pach[PACH_ACHIEVEMENT_ID] == achievementId && pach[PACH_COMPLETED]) {
            return true
        }
    }
    return false
}

UpdateAchievementProgress(id, achievementId, progress) {
    // Find existing progress entry
    new size = ArraySize(g_playerAchievements[id])
    for (new i = 0; i < size; i++) {
        new pach[PlayerAchievement]
        ArrayGetArray(g_playerAchievements[id], i, pach)

        if (pach[PACH_ACHIEVEMENT_ID] == achievementId) {
            if (progress > pach[PACH_PROGRESS]) {
                pach[PACH_PROGRESS] = progress
                ArraySetArray(g_playerAchievements[id], i, pach)

                // Call forward
                ExecuteForward(g_fwAchievementProgressUpdated, g_ret, id, achievementId, progress)
            }
            return
        }
    }

    // Create new progress entry
    new pach[PlayerAchievement]
    pach[PACH_ACHIEVEMENT_ID] = achievementId
    pach[PACH_PROGRESS] = progress
    pach[PACH_COMPLETED] = false
    ArrayPushArray(g_playerAchievements[id], pach)

    // Call forward
    ExecuteForward(g_fwAchievementProgressUpdated, g_ret, id, achievementId, progress)
}

UnlockAchievement(id, achievementId) {
    if (IsAchievementUnlocked(id, achievementId)) return

    new ach[AchievementData]
    for (new i = 0; i < g_achievementCount; i++) {
        ArrayGetArray(g_achievementsList, i, ach)
        if (ach[ACH_ID] == achievementId) break
    }

    // Mark as completed
    new size = ArraySize(g_playerAchievements[id])
    for (new i = 0; i < size; i++) {
        new pach[PlayerAchievement]
        ArrayGetArray(g_playerAchievements[id], i, pach)

        if (pach[PACH_ACHIEVEMENT_ID] == achievementId) {
            pach[PACH_COMPLETED] = true
            pach[PACH_UNLOCK_TIMESTAMP] = get_systime()
            ArraySetArray(g_playerAchievements[id], i, pach)
            break
        }
    }

    // Give reward
    GiveAchievementReward(id, ach)

    // Show notification
    ShowAchievementNotification(id, ach)

    // Log
    new playerName[32]
    get_user_name(id, playerName, charsmax(playerName))
    log_amx("[ZC Achievements] %s unlocked achievement: %s", playerName, ach[ACH_NAME])

    // Call forward
    ExecuteForward(g_fwAchievementUnlocked, g_ret, id, achievementId)
}

GiveAchievementReward(id, ach[AchievementData]) {
    if (equal(ach[ACH_REWARD_TYPE], "coins")) {
        new currentCoins = zp_get_user_coins(id)
        zp_set_user_coins(id, currentCoins + ach[ACH_REWARD_AMOUNT])
    } else if (equal(ach[ACH_REWARD_TYPE], "points")) {
        new currentPoints = zp_get_user_points(id)
        zp_set_user_points(id, currentPoints + ach[ACH_REWARD_AMOUNT])
    } else if (equal(ach[ACH_REWARD_TYPE], "xp")) {
        new currentXP = zp_get_user_xp(id)
        zp_set_user_xp(id, currentXP + ach[ACH_REWARD_AMOUNT])
    } else if (equal(ach[ACH_REWARD_TYPE], "packs")) {
        new currentPacks = zp_get_user_ammo_packs(id)
        zp_set_user_ammo_packs(id, currentPacks + ach[ACH_REWARD_AMOUNT])
    } else if (equal(ach[ACH_REWARD_TYPE], "level")) {
        new currentLevel = zp_get_user_level(id)
        zp_set_user_level(id, currentLevel + ach[ACH_REWARD_AMOUNT])
    }
}

ShowAchievementNotification(id, ach[AchievementData]) {
    if (is_native_valid("zc_hud_show_achievement")) {
        zc_hud_show_achievement(id, ach[ACH_NAME], ach[ACH_DESCRIPTION], ach[ACH_REWARD_AMOUNT], ach[ACH_REWARD_TYPE])
    } else {
        // Fallback to dhudmessage
        set_dhudmessage(255, 215, 0, -1.0, 0.30, 0, 0.0, 5.0, 0.5, 1.5)
        show_dhudmessage(id, "Achievement Unlocked!^n%s^n%s^n+%d %s",
            ach[ACH_NAME], ach[ACH_DESCRIPTION], ach[ACH_REWARD_AMOUNT], ach[ACH_REWARD_TYPE])
    }
}

// ============================================================================
// PLAYER COMMANDS
// ============================================================================

public CmdAchievementsMenu(id) {
    if (!get_pcvar_num(g_pcvarEnabled)) {
        client_print(id, print_chat, "[ZC] Achievements are currently disabled.")
        return PLUGIN_HANDLED
    }

    // Show category selection
    new menu = menu_create("Achievements", "AchievementsCategoryHandler")

    for (new i = 0; i < AchievementCategory; i++) {
        // Count achievements in this category
        new count = CountAchievementsInCategory(i)
        new unlocked = CountUnlockedInCategory(id, i)

        new item[128]
        formatex(item, charsmax(item), "%s (%d/%d)", g_achievementCategoryNames[i], unlocked, count)
        menu_additem(menu, item)
    }

    menu_display(id, menu)

    return PLUGIN_HANDLED
}

public AchievementsCategoryHandler(id, menu, item) {
    if (item == MENU_EXIT) {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    // Show achievements in selected category
    ShowAchievementsCategory(id, item)

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

ShowAchievementsCategory(id, category) {
    new menu = menu_create(g_achievementCategoryNames[category], "AchievementsListHandler")

    new unlockedCount = 0
    new totalCount = 0

    for (new i = 0; i < g_achievementCount; i++) {
        new ach[AchievementData]
        ArrayGetArray(g_achievementsList, i, ach)

        if (ach[ACH_CATEGORY] != category) continue

        totalCount++

        new item[256]
        new unlocked = IsAchievementUnlocked(id, ach[ACH_ID])

        if (unlocked) {
            unlockedCount++
            formatex(item, charsmax(item), "\y%s \r[UNLOCKED]", ach[ACH_NAME])
        } else {
            new progress = GetAchievementProgress(id, ach[ACH_ID])
            formatex(item, charsmax(item), "\d%s \w[%d/%d]", ach[ACH_NAME], progress, ach[ACH_REQUIREMENT_VALUE])
        }

        new info[8]
        num_to_str(ach[ACH_ID], info, charsmax(info))
        menu_additem(menu, item, info, unlocked ? ITEMDRAW_DISABLED : ITEMDRAW_ENABLED)
    }

    // Add info text
    new header[128]
    formatex(header, charsmax(header), "Unlocked: %d/%d", unlockedCount, totalCount)
    menu_addtext(menu, header, false)

    menu_display(id, menu)
}

public AchievementsListHandler(id, menu, item) {
    if (item == MENU_EXIT) {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    new access, callback, info[8]
    menu_item_getinfo(menu, item, access, info, charsmax(info), _, _, callback)

    new achievementId = str_to_num(info)

    // Show achievement details
    ShowAchievementDetails(id, achievementId)

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

ShowAchievementDetails(id, achievementId) {
    new ach[AchievementData]
    for (new i = 0; i < g_achievementCount; i++) {
        ArrayGetArray(g_achievementsList, i, ach)
        if (ach[ACH_ID] == achievementId) break
    }

    new motd[512]
    copy(motd, charsmax(motd), "<html><head>")
    add(motd, charsmax(motd), "<style>")
    add(motd, charsmax(motd), "body { font-family: Arial; background: #1a1a2e; color: #eee; padding: 20px; }")
    add(motd, charsmax(motd), "h2 { color: #ffd700; }")
    add(motd, charsmax(motd), ".desc { color: #aaa; }")
    add(motd, charsmax(motd), ".reward { color: #4ecdc4; font-weight: bold; margin-top: 20px; }")
    add(motd, charsmax(motd), "</style></head><body>")
    formatex(motd, charsmax(motd), "%s<h2>%s</h2><p class='desc'>%s</p><p>Progress: %d / %d</p><p class='reward'>Reward: +%d %s</p></body></html>",
        motd,
        ach[ACH_NAME],
        ach[ACH_DESCRIPTION],
        GetAchievementProgress(id, achievementId),
        ach[ACH_REQUIREMENT_VALUE],
        ach[ACH_REWARD_AMOUNT],
        ach[ACH_REWARD_TYPE])

    show_motd(id, motd, ach[ACH_NAME])
}

CountAchievementsInCategory(category) {
    new count = 0
    for (new i = 0; i < g_achievementCount; i++) {
        new ach[AchievementData]
        ArrayGetArray(g_achievementsList, i, ach)
        if (ach[ACH_CATEGORY] == category) count++
    }
    return count
}

CountUnlockedInCategory(id, category) {
    new count = 0
    for (new i = 0; i < g_achievementCount; i++) {
        new ach[AchievementData]
        ArrayGetArray(g_achievementsList, i, ach)

        if (ach[ACH_CATEGORY] != category) continue
        if (IsAchievementUnlocked(id, ach[ACH_ID])) count++
    }
    return count
}

GetAchievementProgress(id, achievementId) {
    new size = ArraySize(g_playerAchievements[id])
    for (new i = 0; i < size; i++) {
        new pach[PlayerAchievement]
        ArrayGetArray(g_playerAchievements[id], i, pach)

        if (pach[PACH_ACHIEVEMENT_ID] == achievementId) {
            return pach[PACH_PROGRESS]
        }
    }
    return 0
}

// ============================================================================
// ADMIN COMMANDS
// ============================================================================

public CmdListAchievements(id, level, cid) {
    if (!cmd_access(id, level, cid, 1)) return PLUGIN_HANDLED

    console_print(id, "")
    console_print(id, "========== ZC Achievements List ==========")
    console_print(id, "Total: %d achievements", g_achievementCount)

    for (new i = 0; i < AchievementCategory; i++) {
        new count = CountAchievementsInCategory(i)
        console_print(id, "%s: %d", g_achievementCategoryNames[i], count)
    }

    console_print(id, "")
    console_print(id, "Achievement Details:")
    for (new i = 0; i < g_achievementCount; i++) {
        new ach[AchievementData]
        ArrayGetArray(g_achievementsList, i, ach)

        console_print(id, "[%d] %s - %s", ach[ACH_ID], ach[ACH_NAME], ach[ACH_KEY])
        console_print(id, "    %s", ach[ACH_DESCRIPTION])
        console_print(id, "    Type: %s, Value: %d, Reward: %d %s",
            ach[ACH_REQUIREMENT_TYPE], ach[ACH_REQUIREMENT_VALUE], ach[ACH_REWARD_AMOUNT], ach[ACH_REWARD_TYPE])
    }
    console_print(id, "==========================================")
    console_print(id, "")

    return PLUGIN_HANDLED
}

public CmdUnlockAchievement(id, level, cid) {
    if (!cmd_access(id, level, cid, 3)) return PLUGIN_HANDLED

    new target[32], achievementStr[8]
    read_argv(1, target, charsmax(target))
    read_argv(2, achievementStr, charsmax(achievementStr))

    new player = cmd_target(id, target, CMDTARGET_ALLOW_SELF)
    if (!player) {
        console_print(id, "[ZC Achievements] Player not found: %s", target)
        return PLUGIN_HANDLED
    }

    new achievementId = str_to_num(achievementStr)
    if (achievementId < 0 || achievementId >= g_achievementCount) {
        console_print(id, "[ZC Achievements] Invalid achievement ID: %d", achievementId)
        return PLUGIN_HANDLED
    }

    UnlockAchievement(player, achievementId)

    new playerName[32]
    get_user_name(player, playerName, charsmax(playerName))

    console_print(id, "[ZC Achievements] Unlocked achievement %d for %s", achievementId, playerName)
    client_print(player, print_chat, "[ZC] An admin has unlocked an achievement for you!")

    return PLUGIN_HANDLED
}

public CmdResetAchievements(id, level, cid) {
    if (!cmd_access(id, level, cid, 2)) return PLUGIN_HANDLED

    new target[32]
    read_argv(1, target, charsmax(target))

    new player = cmd_target(id, target, CMDTARGET_ALLOW_SELF)
    if (!player) {
        console_print(id, "[ZC Achievements] Player not found: %s", target)
        return PLUGIN_HANDLED
    }

    // Clear achievements array
    ArrayClear(g_playerAchievements[player])

    new playerName[32]
    get_user_name(player, playerName, charsmax(playerName))

    console_print(id, "[ZC Achievements] Reset achievements for %s", playerName)
    client_print(player, print_chat, "[ZC] Your achievements have been reset by an admin.")

    log_amx("[ZC Achievements] Admin %d reset achievements for player %s", id, playerName)

    return PLUGIN_HANDLED
}

// ============================================================================
// PUBLIC API
// ============================================================================

public plugin_natives() {
    register_native("zc_get_achievement_count", "NativeGetAchievementCount")
    register_native("zc_is_achievement_unlocked", "NativeIsAchievementUnlocked")
    register_native("zc_get_achievement_progress", "NativeGetAchievementProgress")
    register_native("zc_register_custom_achievement", "NativeRegisterCustomAchievement")
    register_native("zc_force_unlock_achievement", "NativeForceUnlockAchievement")
}

public NativeGetAchievementCount(plugin, params) {
    return g_achievementCount
}

public NativeIsAchievementUnlocked(plugin, params) {
    new id = get_param(1)
    new achievementId = get_param(2)

    if (id < 1 || id > 32) return 0
    if (achievementId < 0 || achievementId >= g_achievementCount) return 0

    return IsAchievementUnlocked(id, achievementId) ? 1 : 0
}

public NativeGetAchievementProgress(plugin, params) {
    new id = get_param(1)
    new achievementId = get_param(2)

    if (id < 1 || id > 32) return 0
    if (achievementId < 0 || achievementId >= g_achievementCount) return 0

    return GetAchievementProgress(id, achievementId)
}

public NativeRegisterCustomAchievement(plugin, params) {
    new key[64], name[128], description[256], reqType[32], rewardType[16]
    get_string(1, key, charsmax(key))
    get_string(2, name, charsmax(name))
    get_string(3, description, charsmax(description))
    get_string(4, reqType, charsmax(reqType))
    new reqValue = get_param(5)
    get_string(6, rewardType, charsmax(rewardType))
    new rewardAmount = get_param(6)

    new ach[AchievementData]
    ach[ACH_ID] = g_achievementCount
    copy(ach[ACH_KEY], charsmax(ach[ACH_KEY]), key)
    copy(ach[ACH_NAME], charsmax(ach[ACH_NAME]), name)
    copy(ach[ACH_DESCRIPTION], charsmax(ach[ACH_DESCRIPTION]), description)
    ach[ACH_CATEGORY] = ACH_CAT_SPECIAL
    copy(ach[ACH_REQUIREMENT_TYPE], charsmax(ach[ACH_REQUIREMENT_TYPE]), reqType)
    ach[ACH_REQUIREMENT_VALUE] = reqValue
    copy(ach[ACH_REWARD_TYPE], charsmax(ach[ACH_REWARD_TYPE]), rewardType)
    ach[ACH_REWARD_AMOUNT] = rewardAmount
    copy(ach[ACH_ICON], charsmax(ach[ACH_ICON]), "custom")
    ach[ACH_IS_HIDDEN] = false
    ach[ACH_SORT_ORDER] = g_achievementCount

    ArrayPushArray(g_achievementsList, ach)
    g_achievementCount++

    return ach[ACH_ID]
}

public NativeForceUnlockAchievement(plugin, params) {
    new id = get_param(1)
    new achievementId = get_param(2)

    if (id < 1 || id > 32) return 0
    if (achievementId < 0 || achievementId >= g_achievementCount) return 0

    UnlockAchievement(id, achievementId)
    return 1
}
