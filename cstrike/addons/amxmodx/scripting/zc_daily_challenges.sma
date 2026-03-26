/************************************************************************************\
		   ========================================
	       * || Zombie Crown XP Mode - Daily Challenges || *
	       * || 3 Rotating Daily Quests with Rewards || *
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
    return true // Placeholder
}

// Forward variable
new g_ret

#define PLUGIN_VERSION "1.0.0"
#define PLUGIN_AUTHOR "Zombie Crown Dev Team"
#define PLUGIN_NAME "ZC Daily Challenges"

// Challenge difficulties
enum ChallengeDifficulty {
    CHALLENGE_EASY = 1,
    CHALLENGE_MEDIUM,
    CHALLENGE_HARD
}

// Challenge data
enum ChallengeData {
    CHALLENGE_ID,
    CHALLENGE_KEY[64],
    CHALLENGE_NAME[128],
    CHALLENGE_DESCRIPTION[256],
    CHALLENGE_TYPE[32],
    CHALLENGE_TARGET,
    CHALLENGE_DIFFICULTY,
    CHALLENGE_REWARD_TYPE[16],
    CHALLENGE_REWARD_AMOUNT,
    CHALLENGE_MIN_LEVEL
}

// Player challenge progress
enum PlayerChallenge {
    PCHALLENGE_TEMPLATE_ID,
    PCHALLENGE_PROGRESS,
    PCHALLENGE_COMPLETED,
    PCHALLENGE_DATE[16]  // YYYY-MM-DD format
}

// Challenge pool templates
new Array:g_challengeTemplates
new g_challengeTemplateCount = 0

// Player's current challenges (3 per player)
new g_playerChallenges[33][3][PlayerChallenge]

// Configuration
new g_pcvarEnabled
new g_pcvarChallengeCount
new g_pcvarResetTime

// Database
new Handle:g_dbTuple

// Forwards
new g_fwChallengeCompleted
new g_fwChallengeUpdated

public plugin_init() {
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

    // Configuration CVARs
    g_pcvarEnabled = register_cvar("zc_daily_challenges_enabled", "1")
    g_pcvarChallengeCount = register_cvar("zc_daily_challenges_count", "3")
    g_pcvarResetTime = register_cvar("zc_daily_challenges_reset_time", "00:00")

    // Player commands
    register_clcmd("say /challenges", "CmdChallengesMenu")
    register_clcmd("say_team /challenges", "CmdChallengesMenu")
    register_clcmd("say /daily", "CmdChallengesMenu")
    register_clcmd("say_team /daily", "CmdChallengesMenu")

    // Admin commands
    register_concmd("zc_reset_daily_challenges", "CmdResetDailyChallenges", ADMIN_CFG, "<player> - Reset player's daily challenges")
    register_concmd("zc_complete_challenge", "CmdCompleteChallenge", ADMIN_CFG, "<player> <index> - Complete challenge for player")
    register_concmd("zc_refresh_challenges", "CmdRefreshChallenges", ADMIN_CFG, "Refresh all challenges from database")

    // Initialize database
    InitializeDatabase()

    // Create templates array
    g_challengeTemplates = ArrayCreate(ChallengeData)

    // Load challenge templates
    LoadChallengeTemplates()

    // Create forwards
    g_fwChallengeCompleted = CreateMultiForward("zc_daily_challenge_completed", ET_IGNORE, FP_CELL, FP_CELL)
    g_fwChallengeUpdated = CreateMultiForward("zc_daily_challenge_updated", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL)

    // Set up daily reset check
    set_task(60.0, "CheckDailyReset", 12345, "", 0, "b")

    // Hook game events
    RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")

    log_amx("[ZC Daily Challenges] Loaded %d challenge templates", g_challengeTemplateCount)
}

public plugin_end() {
    if (g_challengeTemplates) {
        ArrayDestroy(g_challengeTemplates)
    }

    if (g_dbTuple) {
        SQL_FreeHandle(g_dbTuple)
    }
}

InitializeDatabase() {
    new host[64], user[64], pass[64], db[64]
    get_cvar_string("amx_sql_host", host, charsmax(host))
    get_cvar_string("amx_sql_user", user, charsmax(user))
    get_cvar_string("amx_sql_pass", pass, charsmax(pass))
    get_cvar_string("amx_sql_db", db, charsmax(db))

    g_dbTuple = SQL_MakeDbTuple(host, user, pass, db)

    // Create tables
    new query[1024]

    // Daily challenges table (templates)
    copy(query, charsmax(query), "CREATE TABLE IF NOT EXISTS `zc_daily_challenges` (")
    add(query, charsmax(query), "`challenge_id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,")
    add(query, charsmax(query), "`challenge_key` VARCHAR(64) UNIQUE NOT NULL,")
    add(query, charsmax(query), "`challenge_name` VARCHAR(128),")
    add(query, charsmax(query), "`description` VARCHAR(256),")
    add(query, charsmax(query), "`requirement_type` VARCHAR(32),")
    add(query, charsmax(query), "`requirement_value` INT,")
    add(query, charsmax(query), "`reward_type` VARCHAR(16),")
    add(query, charsmax(query), "`reward_amount` INT,")
    add(query, charsmax(query), "`difficulty` INT,")
    add(query, charsmax(query), "`min_level` INT DEFAULT 1);")

    SQL_ThreadQuery(g_dbTuple, "HandleTableCreate", query)

    // Player daily progress table
    copy(query, charsmax(query), "CREATE TABLE IF NOT EXISTS `zc_player_daily_progress` (")
    add(query, charsmax(query), "`id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,")
    add(query, charsmax(query), "`player_id` INT NOT NULL,")
    add(query, charsmax(query), "`challenge_date` DATE NOT NULL,")
    add(query, charsmax(query), "`challenge_id` INT NOT NULL,")
    add(query, charsmax(query), "`progress` INT DEFAULT 0,")
    add(query, charsmax(query), "`completed` BOOLEAN DEFAULT FALSE,")
    add(query, charsmax(query), "FOREIGN KEY (player_id) REFERENCES zc_players(player_id) ON DELETE CASCADE,")
    add(query, charsmax(query), "FOREIGN KEY (challenge_id) REFERENCES zc_daily_challenges(challenge_id),")
    add(query, charsmax(query), "UNIQUE KEY unique_player_date_challenge (player_id, challenge_date, challenge_id);")

    SQL_ThreadQuery(g_dbTuple, "HandleTableCreate", query)
}

public HandleTableCreate(failState, Handle:query, error[], errnum, data[], size) {
    if (failState) {
        log_amx("[ZC Daily Challenges] Failed to create table: %s", error)
    }
}

LoadChallengeTemplates() {
    // Load from configuration file
    new configFile[128]
    get_configsdir(configFile, charsmax(configFile))
    add(configFile, charsmax(configFile), "/zombie_crown/zc_challenges.ini")

    if (file_exists(configFile)) {
        new file = fopen(configFile, "r")
        if (file) {
            new line[1024]
            while (!feof(file)) {
                fgets(file, line, charsmax(line))
                trim(line)

                if (line[0] == ';' || line[0] == '/' || line[0] == 0) continue

                new key[64], data[512]
                strtok(line, key, charsmax(key), data, charsmax(data), '=')
                trim(key)
                trim(data)

                if (!equal(key, "") && !equal(data, "")) {
                    ParseChallengeTemplate(key, data)
                }
            }
            fclose(file)
        }
    }

    // Create default templates if none loaded
    if (g_challengeTemplateCount == 0) {
        CreateDefaultTemplates()
    }
}

ParseChallengeTemplate(const key[], const data[]) {
    new challenge[ChallengeData]

    copy(challenge[CHALLENGE_KEY], charsmax(challenge[CHALLENGE_KEY]), key)

    // Parse format: "Name|Description|type|target|difficulty|reward_type|reward_amount|min_level"
    new parsed[8][128]
    explode(data, parsed, charsmax(parsed), charsmax(parsed), "|")

    copy(challenge[CHALLENGE_NAME], charsmax(challenge[CHALLENGE_NAME]), parsed[0])
    copy(challenge[CHALLENGE_DESCRIPTION], charsmax(challenge[CHALLENGE_DESCRIPTION]), parsed[1])
    copy(challenge[CHALLENGE_TYPE], charsmax(challenge[CHALLENGE_TYPE]), parsed[2])
    challenge[CHALLENGE_TARGET] = str_to_num(parsed[3])
    challenge[CHALLENGE_DIFFICULTY] = str_to_num(parsed[4])
    copy(challenge[CHALLENGE_REWARD_TYPE], charsmax(challenge[CHALLENGE_REWARD_TYPE]), parsed[5])
    challenge[CHALLENGE_REWARD_AMOUNT] = str_to_num(parsed[6])
    challenge[CHALLENGE_MIN_LEVEL] = str_to_num(parsed[7])

    challenge[CHALLENGE_ID] = g_challengeTemplateCount
    ArrayPushArray(g_challengeTemplates, challenge)
    g_challengeTemplateCount++
}

CreateDefaultTemplates() {
    log_amx("[ZC Daily Challenges] Creating default templates...")

    new challenge[ChallengeData]

    // Easy challenges
    challenge[CHALLENGE_ID] = g_challengeTemplateCount
    copy(challenge[CHALLENGE_KEY], charsmax(challenge[CHALLENGE_KEY]), "KILL_10_ZOMBIES")
    copy(challenge[CHALLENGE_NAME], charsmax(challenge[CHALLENGE_NAME]), "Zombie Hunter")
    copy(challenge[CHALLENGE_DESCRIPTION], charsmax(challenge[CHALLENGE_DESCRIPTION]), "Kill 10 zombies")
    copy(challenge[CHALLENGE_TYPE], charsmax(challenge[CHALLENGE_TYPE]), "kill_zombies")
    challenge[CHALLENGE_TARGET] = 10
    challenge[CHALLENGE_DIFFICULTY] = CHALLENGE_EASY
    copy(challenge[CHALLENGE_REWARD_TYPE], charsmax(challenge[CHALLENGE_REWARD_TYPE]), "coins")
    challenge[CHALLENGE_REWARD_AMOUNT] = 50
    challenge[CHALLENGE_MIN_LEVEL] = 1
    ArrayPushArray(g_challengeTemplates, challenge)
    g_challengeTemplateCount++

    challenge[CHALLENGE_ID] = g_challengeTemplateCount
    copy(challenge[CHALLENGE_KEY], charsmax(challenge[CHALLENGE_KEY]), "INFECT_5_HUMANS")
    copy(challenge[CHALLENGE_NAME], charsmax(challenge[CHALLENGE_NAME]), "First Infections")
    copy(challenge[CHALLENGE_DESCRIPTION], charsmax(challenge[CHALLENGE_DESCRIPTION]), "Infect 5 humans")
    copy(challenge[CHALLENGE_TYPE], charsmax(challenge[CHALLENGE_TYPE]), "infect_humans")
    challenge[CHALLENGE_TARGET] = 5
    challenge[CHALLENGE_DIFFICULTY] = CHALLENGE_EASY
    copy(challenge[CHALLENGE_REWARD_TYPE], charsmax(challenge[CHALLENGE_REWARD_TYPE]), "points")
    challenge[CHALLENGE_REWARD_AMOUNT] = 100
    challenge[CHALLENGE_MIN_LEVEL] = 1
    ArrayPushArray(g_challengeTemplates, challenge)
    g_challengeTemplateCount++

    // Medium challenges
    challenge[CHALLENGE_ID] = g_challengeTemplateCount
    copy(challenge[CHALLENGE_KEY], charsmax(challenge[CHALLENGE_KEY]), "KILL_50_ZOMBIES")
    copy(challenge[CHALLENGE_NAME], charsmax(challenge[CHALLENGE_NAME]), "Zombie Slayer")
    copy(challenge[CHALLENGE_DESCRIPTION], charsmax(challenge[CHALLENGE_DESCRIPTION]), "Kill 50 zombies")
    copy(challenge[CHALLENGE_TYPE], charsmax(challenge[CHALLENGE_TYPE]), "kill_zombies")
    challenge[CHALLENGE_TARGET] = 50
    challenge[CHALLENGE_DIFFICULTY] = CHALLENGE_MEDIUM
    copy(challenge[CHALLENGE_REWARD_TYPE], charsmax(challenge[CHALLENGE_REWARD_TYPE]), "coins")
    challenge[CHALLENGE_REWARD_AMOUNT] = 150
    challenge[CHALLENGE_MIN_LEVEL] = 5
    ArrayPushArray(g_challengeTemplates, challenge)
    g_challengeTemplateCount++

    challenge[CHALLENGE_ID] = g_challengeTemplateCount
    copy(challenge[CHALLENGE_KEY], charsmax(challenge[CHALLENGE_KEY]), "WIN_1_ROUND")
    copy(challenge[CHALLENGE_NAME], charsmax(challenge[CHALLENGE_NAME]), "Victory")
    copy(challenge[CHALLENGE_DESCRIPTION], charsmax(challenge[CHALLENGE_DESCRIPTION]), "Win 1 round")
    copy(challenge[CHALLENGE_TYPE], charsmax(challenge[CHALLENGE_TYPE]), "win_round")
    challenge[CHALLENGE_TARGET] = 1
    challenge[CHALLENGE_DIFFICULTY] = CHALLENGE_MEDIUM
    copy(challenge[CHALLENGE_REWARD_TYPE], charsmax(challenge[CHALLENGE_REWARD_TYPE]), "xp")
    challenge[CHALLENGE_REWARD_AMOUNT] = 100
    challenge[CHALLENGE_MIN_LEVEL] = 5
    ArrayPushArray(g_challengeTemplates, challenge)
    g_challengeTemplateCount++

    // Hard challenges
    challenge[CHALLENGE_ID] = g_challengeTemplateCount
    copy(challenge[CHALLENGE_KEY], charsmax(challenge[CHALLENGE_KEY]), "KILL_200_ZOMBIES")
    copy(challenge[CHALLENGE_NAME], charsmax(challenge[CHALLENGE_NAME]), "Zombie Genocide")
    copy(challenge[CHALLENGE_DESCRIPTION], charsmax(challenge[CHALLENGE_DESCRIPTION]), "Kill 200 zombies")
    copy(challenge[CHALLENGE_TYPE], charsmax(challenge[CHALLENGE_TYPE]), "kill_zombies")
    challenge[CHALLENGE_TARGET] = 200
    challenge[CHALLENGE_DIFFICULTY] = CHALLENGE_HARD
    copy(challenge[CHALLENGE_REWARD_TYPE], charsmax(challenge[CHALLENGE_REWARD_TYPE]), "coins")
    challenge[CHALLENGE_REWARD_AMOUNT] = 500
    challenge[CHALLENGE_MIN_LEVEL] = 10
    ArrayPushArray(g_challengeTemplates, challenge)
    g_challengeTemplateCount++

    challenge[CHALLENGE_ID] = g_challengeTemplateCount
    copy(challenge[CHALLENGE_KEY], charsmax(challenge[CHALLENGE_KEY]), "INFECT_50_HUMANS")
    copy(challenge[CHALLENGE_NAME], charsmax(challenge[CHALLENGE_NAME]), "Viral Spread")
    copy(challenge[CHALLENGE_DESCRIPTION], charsmax(challenge[CHALLENGE_DESCRIPTION]), "Infect 50 humans")
    copy(challenge[CHALLENGE_TYPE], charsmax(challenge[CHALLENGE_TYPE]), "infect_humans")
    challenge[CHALLENGE_TARGET] = 50
    challenge[CHALLENGE_DIFFICULTY] = CHALLENGE_HARD
    copy(challenge[CHALLENGE_REWARD_TYPE], charsmax(challenge[CHALLENGE_REWARD_TYPE]), "points")
    challenge[CHALLENGE_REWARD_AMOUNT] = 1000
    challenge[CHALLENGE_MIN_LEVEL] = 10
    ArrayPushArray(g_challengeTemplates, challenge)
    g_challengeTemplateCount++

    log_amx("[ZC Daily Challenges] Created %d default templates", g_challengeTemplateCount)
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
    // Reset challenges
    for (new i = 0; i < 3; i++) {
        g_playerChallenges[id][i][PCHALLENGE_TEMPLATE_ID] = -1
        g_playerChallenges[id][i][PCHALLENGE_PROGRESS] = 0
        g_playerChallenges[id][i][PCHALLENGE_COMPLETED] = false
        g_playerChallenges[id][i][PCHALLENGE_DATE][0] = 0
    }

    // Load today's challenges
    set_task(1.0, "LoadDailyChallenges", id)
}

public LoadDailyChallenges(id) {
    if (!is_user_connected(id)) return

    new currentDate[16]
    GetDateFormat(currentDate, charsmax(currentDate))

    // Check if player already has challenges for today
    new hasChallenges = false
    for (new i = 0; i < 3; i++) {
        if (equal(g_playerChallenges[id][i][PCHALLENGE_DATE], currentDate)) {
            hasChallenges = true
            break
        }
    }

    if (hasChallenges) return

    // Generate new challenges for today
    GenerateDailyChallenges(id)
}

GenerateDailyChallenges(id) {
    new playerLevel = zp_get_user_level(id)
    new challengeCount = get_pcvar_num(g_pcvarChallengeCount)

    new currentDate[16]
    GetDateFormat(currentDate, charsmax(currentDate))

    // Select 1 easy, 1 medium, 1 hard challenge
    new selectedChallenges[3]

    for (new diff = CHALLENGE_EASY; diff <= CHALLENGE_HARD; diff++) {
        new selectedCount = 0

        // Get challenges of this difficulty
        new validChallenges[32]
        new validCount = 0

        for (new i = 0; i < g_challengeTemplateCount; i++) {
            new challenge[ChallengeData]
            ArrayGetArray(g_challengeTemplates, i, challenge)

            if (challenge[CHALLENGE_DIFFICULTY] == diff && challenge[CHALLENGE_MIN_LEVEL] <= playerLevel) {
                validChallenges[validCount] = i
                validCount++
            }
        }

        if (validCount > 0) {
            // Randomly select one
            new randomIndex = random(validCount)
            selectedChallenges[diff - 1] = validChallenges[randomIndex]
        }
    }

    // Initialize player challenges
    for (new i = 0; i < 3; i++) {
        if (selectedChallenges[i] >= 0) {
            g_playerChallenges[id][i][PCHALLENGE_TEMPLATE_ID] = selectedChallenges[i]
            g_playerChallenges[id][i][PCHALLENGE_PROGRESS] = 0
            g_playerChallenges[id][i][PCHALLENGE_COMPLETED] = false
            copy(g_playerChallenges[id][i][PCHALLENGE_DATE], 31, currentDate)

            // Save to database
            SaveDailyChallenge(id, selectedChallenges[i], currentDate)
        }
    }

    // Show notification
    ShowChallengesAssigned(id)
}

SaveDailyChallenge(id, templateId, const date[]) {
    if (!is_native_valid("zc_get_user_database_id")) return

    new playerId = zc_get_user_database_id(id)
    if (playerId <= 0) return

    new query[512]
    formatex(query, charsmax(query),
        "INSERT INTO zc_player_daily_progress (player_id, challenge_date, challenge_id, progress, completed) VALUES (%d, '%s', %d, 0, FALSE) ON DUPLICATE KEY UPDATE progress = 0, completed = FALSE",
        playerId, date, templateId)

    SQL_ThreadQuery(g_dbTuple, "HandleChallengeSave", query)
}

public HandleChallengeSave(failState, Handle:query, error[], errnum, data[], size) {
    if (failState) {
        log_amx("[ZC Daily Challenges] Failed to save challenge: %s", error)
    }
}

ShowChallengesAssigned(id) {
    set_dhudmessage(0, 255, 0, -1.0, 0.35, 0, 0.0, 8.0, 0.5, 1.5)
    show_dhudmessage(id, "New Daily Challenges Assigned!^nType /challenges to view")

    client_print(id, print_chat, "[ZC] New daily challenges assigned! Use /challenges or /daily to view them.")
}

public CheckDailyReset() {
    // Check if it's time to reset challenges
    new resetTime[8]
    get_pcvar_string(g_pcvarResetTime, resetTime, charsmax(resetTime))

    // Check if we need to reset for all players
    // This would typically be done at midnight server time
    // For now, challenges are generated per player when they connect
}

// ============================================================================
// GAME EVENT HOOKS
// ============================================================================

public fw_PlayerKilled(victim, attacker) {
    if (!get_pcvar_num(g_pcvarEnabled)) return HAM_IGNORED
    if (!is_user_valid_connected(attacker)) return HAM_IGNORED
    if (attacker == victim) return HAM_IGNORED

    new currentDate[16]
    GetDateFormat(currentDate, charsmax(currentDate))

    // Update challenge progress
    for (new i = 0; i < 3; i++) {
        if (!equal(g_playerChallenges[attacker][i][PCHALLENGE_DATE], currentDate)) continue
        if (g_playerChallenges[attacker][i][PCHALLENGE_COMPLETED]) continue

        new templateId = g_playerChallenges[attacker][i][PCHALLENGE_TEMPLATE_ID]
        if (templateId < 0) continue

        new challenge[ChallengeData]
        ArrayGetArray(g_challengeTemplates, templateId, challenge)

        // Check challenge type and update progress
        if (equal(challenge[CHALLENGE_TYPE], "kill_zombies")) {
            if (zp_get_user_zombie(victim)) {
                UpdateChallengeProgress(attacker, i, 1)
            }
        } else if (equal(challenge[CHALLENGE_TYPE], "kill_humans")) {
            if (!zp_get_user_zombie(victim)) {
                UpdateChallengeProgress(attacker, i, 1)
            }
        } else if (equal(challenge[CHALLENGE_TYPE], "infect_humans")) {
            if (!zp_get_user_zombie(victim) && zp_get_user_zombie(attacker)) {
                UpdateChallengeProgress(attacker, i, 1)
            }
        } else if (equal(challenge[CHALLENGE_TYPE], "kill_zombies_as_human")) {
            if (zp_get_user_zombie(victim) && !zp_get_user_zombie(attacker)) {
                UpdateChallengeProgress(attacker, i, 1)
            }
        } else if (equal(challenge[CHALLENGE_TYPE], "kill_nemesis")) {
            if (zp_get_user_nemesis(victim)) {
                UpdateChallengeProgress(attacker, i, 1)
            }
        } else if (equal(challenge[CHALLENGE_TYPE], "kill_survivor")) {
            if (zp_get_user_survivor(victim)) {
                UpdateChallengeProgress(attacker, i, 1)
            }
        }
    }

    return HAM_IGNORED
}

UpdateChallengeProgress(id, challengeIndex, amount) {
    new oldProgress = g_playerChallenges[id][challengeIndex][PCHALLENGE_PROGRESS]
    g_playerChallenges[id][challengeIndex][PCHALLENGE_PROGRESS] += amount

    new templateId = g_playerChallenges[id][challengeIndex][PCHALLENGE_TEMPLATE_ID]
    new challenge[ChallengeData]
    ArrayGetArray(g_challengeTemplates, templateId, challenge)

    new progress = g_playerChallenges[id][challengeIndex][PCHALLENGE_PROGRESS]
    new target = challenge[CHALLENGE_TARGET]

    if (progress >= target && !g_playerChallenges[id][challengeIndex][PCHALLENGE_COMPLETED]) {
        CompleteChallenge(id, challengeIndex)
    } else {
        // Show progress update
        ShowChallengeProgress(id, challengeIndex, progress, target)
    }

    // Call forward
    ExecuteForward(g_fwChallengeUpdated, g_ret, id, challengeIndex, progress)

    // Save to database
    SaveChallengeProgress(id, challengeIndex)
}

CompleteChallenge(id, challengeIndex) {
    g_playerChallenges[id][challengeIndex][PCHALLENGE_COMPLETED] = true

    new templateId = g_playerChallenges[id][challengeIndex][PCHALLENGE_TEMPLATE_ID]
    new challenge[ChallengeData]
    ArrayGetArray(g_challengeTemplates, templateId, challenge)

    // Give reward
    GiveChallengeReward(id, challenge)

    // Show completion notification
    ShowChallengeCompleted(id, challenge)

    // Log
    new playerName[32]
    get_user_name(id, playerName, charsmax(playerName))
    log_amx("[ZC Daily Challenges] %s completed challenge: %s", playerName, challenge[CHALLENGE_NAME])

    // Call forward
    ExecuteForward(g_fwChallengeCompleted, g_ret, id, challengeIndex)

    // Update database
    MarkChallengeCompleted(id, templateId)
}

GiveChallengeReward(id, challenge[ChallengeData]) {
    if (equal(challenge[CHALLENGE_REWARD_TYPE], "coins")) {
        new currentCoins = zp_get_user_coins(id)
        zp_set_user_coins(id, currentCoins + challenge[CHALLENGE_REWARD_AMOUNT])
    } else if (equal(challenge[CHALLENGE_REWARD_TYPE], "points")) {
        new currentPoints = zp_get_user_points(id)
        zp_set_user_points(id, currentPoints + challenge[CHALLENGE_REWARD_AMOUNT])
    } else if (equal(challenge[CHALLENGE_REWARD_TYPE], "xp")) {
        new currentXP = zp_get_user_xp(id)
        zp_set_user_xp(id, currentXP + challenge[CHALLENGE_REWARD_AMOUNT])
    } else if (equal(challenge[CHALLENGE_REWARD_TYPE], "packs")) {
        new currentPacks = zp_get_user_ammo_packs(id)
        zp_set_user_ammo_packs(id, currentPacks + challenge[CHALLENGE_REWARD_AMOUNT])
    }
}

ShowChallengeProgress(id, challengeIndex, progress, target) {
    if (is_native_valid("zc_hud_show_challenge")) {
        new templateId = g_playerChallenges[id][challengeIndex][PCHALLENGE_TEMPLATE_ID]
        new challenge[ChallengeData]
        ArrayGetArray(g_challengeTemplates, templateId, challenge)

        zc_hud_show_challenge(id, challenge[CHALLENGE_NAME], progress, target, challenge[CHALLENGE_REWARD_AMOUNT], challenge[CHALLENGE_REWARD_TYPE])
    }
}

ShowChallengeCompleted(id, challenge[ChallengeData]) {
    set_dhudmessage(0, 255, 0, -1.0, 0.30, 0, 0.0, 6.0, 0.5, 1.5)
    show_dhudmessage(id, "Daily Challenge Complete!^n%s^n+%d %s",
        challenge[CHALLENGE_NAME],
        challenge[CHALLENGE_REWARD_AMOUNT],
        challenge[CHALLENGE_REWARD_TYPE])
}

SaveChallengeProgress(id, challengeIndex) {
    // Save progress to database
    // This would be implemented with SQL queries
}

MarkChallengeCompleted(id, templateId) {
    if (!is_native_valid("zc_get_user_database_id")) return

    new playerId = zc_get_user_database_id(id)
    if (playerId <= 0) return

    new currentDate[16]
    GetDateFormat(currentDate, charsmax(currentDate))

    new query[256]
    formatex(query, charsmax(query),
        "UPDATE zc_player_daily_progress SET completed = TRUE, progress = requirement_value WHERE player_id = %d AND challenge_date = '%s' AND challenge_id = %d",
        playerId, currentDate, templateId)

    SQL_ThreadQuery(g_dbTuple, "HandleCompletionSave", query)
}

public HandleCompletionSave(failState, Handle:query, error[], errnum, data[], size) {
    if (failState) {
        log_amx("[ZC Daily Challenges] Failed to save completion: %s", error)
    }
}

// ============================================================================
// PLAYER COMMANDS
// ============================================================================

public CmdChallengesMenu(id) {
    if (!get_pcvar_num(g_pcvarEnabled)) {
        client_print(id, print_chat, "[ZC] Daily challenges are currently disabled.")
        return PLUGIN_HANDLED
    }

    new currentDate[16]
    GetDateFormat(currentDate, charsmax(currentDate))

    new menu = menu_create("Daily Challenges", "ChallengesMenuHandler")

    // Add date info
    new info[64]
    formatex(info, charsmax(info), "\yDate: \w%s", currentDate)
    menu_addtext(menu, info, false)
    menu_addblank(menu, false)

    // Add challenges
    for (new i = 0; i < 3; i++) {
        new templateId = g_playerChallenges[id][i][PCHALLENGE_TEMPLATE_ID]
        if (templateId < 0) continue

        new challenge[ChallengeData]
        ArrayGetArray(g_challengeTemplates, templateId, challenge)

        new progress = g_playerChallenges[id][i][PCHALLENGE_PROGRESS]
        new target = challenge[CHALLENGE_TARGET]
        new completed = g_playerChallenges[id][i][PCHALLENGE_COMPLETED]

        new difficultyColor[16]
        switch (challenge[CHALLENGE_DIFFICULTY]) {
            case CHALLENGE_EASY: copy(difficultyColor, charsmax(difficultyColor), "\y[EASY]\w")
            case CHALLENGE_MEDIUM: copy(difficultyColor, charsmax(difficultyColor), "\r[MEDIUM]\w")
            case CHALLENGE_HARD: copy(difficultyColor, charsmax(difficultyColor), "\r[HARD]\w")
        }

        new item[256]
        if (completed) {
            formatex(item, charsmax(item), "%s %s \y[COMPLETED]^n\d%s: %d/%d^n\yReward: %d %s",
                difficultyColor,
                challenge[CHALLENGE_NAME],
                challenge[CHALLENGE_DESCRIPTION],
                progress, target,
                challenge[CHALLENGE_REWARD_AMOUNT],
                challenge[CHALLENGE_REWARD_TYPE])
        } else {
            formatex(item, charsmax(item), "%s %s^n\d%s: \w%d/%d^n\yReward: %d %s",
                difficultyColor,
                challenge[CHALLENGE_NAME],
                challenge[CHALLENGE_DESCRIPTION],
                progress, target,
                challenge[CHALLENGE_REWARD_AMOUNT],
                challenge[CHALLENGE_REWARD_TYPE])
        }

        new infoStr[8]
        num_to_str(i, infoStr, charsmax(infoStr))
        menu_additem(menu, item, infoStr, completed ? ITEMDRAW_DISABLED : ITEMDRAW_ENABLED)
    }

    menu_display(id, menu)

    return PLUGIN_HANDLED
}

public ChallengesMenuHandler(id, menu, item) {
    if (item == MENU_EXIT) {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    new access, callback, info[8]
    menu_item_getinfo(menu, item, access, info, charsmax(info), _, _, callback)

    new challengeIndex = str_to_num(info)

    // Show challenge details
    ShowChallengeDetails(id, challengeIndex)

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

ShowChallengeDetails(id, challengeIndex) {
    new templateId = g_playerChallenges[id][challengeIndex][PCHALLENGE_TEMPLATE_ID]
    if (templateId < 0) return

    new challenge[ChallengeData]
    ArrayGetArray(g_challengeTemplates, templateId, challenge)

    new progress = g_playerChallenges[id][challengeIndex][PCHALLENGE_PROGRESS]
    new target = challenge[CHALLENGE_TARGET]
    new completed = g_playerChallenges[id][challengeIndex][PCHALLENGE_COMPLETED]

    new motd[512]
    copy(motd, charsmax(motd), "<html><head>")
    add(motd, charsmax(motd), "<style>")
    add(motd, charsmax(motd), "body { font-family: Arial; background: #1a1a2e; color: #eee; padding: 20px; text-align: center; }")
    add(motd, charsmax(motd), "h2 { color: #ffd700; }")
    add(motd, charsmax(motd), ".desc { color: #aaa; margin: 20px 0; }")
    add(motd, charsmax(motd), ".progress { font-size: 24px; color: #4ecdc4; margin: 20px 0; }")
    add(motd, charsmax(motd), ".reward { color: #00ff00; font-weight: bold; }")
    add(motd, charsmax(motd), ".completed { color: #00ff00; font-size: 18px; margin-top: 20px; }")
    add(motd, charsmax(motd), "</style></head><body>")
    formatex(motd, charsmax(motd), "%s<h2>%s</h2><p class='desc'>%s</p><p class='progress'>Progress: %d / %d</p><p class='reward'>Reward: +%d %s</p>%s</body></html>",
        motd,
        challenge[CHALLENGE_NAME],
        challenge[CHALLENGE_DESCRIPTION],
        progress, target,
        challenge[CHALLENGE_REWARD_AMOUNT],
        challenge[CHALLENGE_REWARD_TYPE],
        completed ? "<p class='completed'>COMPLETED!</p>" : "")

    show_motd(id, motd, challenge[CHALLENGE_NAME])
}

GetDateFormat(output[], len) {
    // Get current date in YYYY-MM-DD format
    new year, month, day
    date(year, month, day)

    formatex(output, len, "%04d-%02d-%02d", year + 1900, month, day)
}

// ============================================================================
// ADMIN COMMANDS
// ============================================================================

public CmdResetDailyChallenges(id, level, cid) {
    if (!cmd_access(id, level, cid, 2)) return PLUGIN_HANDLED

    new target[32]
    read_argv(1, target, charsmax(target))

    new player = cmd_target(id, target, CMDTARGET_ALLOW_SELF)
    if (!player) {
        console_print(id, "[ZC Daily Challenges] Player not found: %s", target)
        return PLUGIN_HANDLED
    }

    // Reset challenges
    for (new i = 0; i < 3; i++) {
        g_playerChallenges[player][i][PCHALLENGE_TEMPLATE_ID] = -1
        g_playerChallenges[player][i][PCHALLENGE_PROGRESS] = 0
        g_playerChallenges[player][i][PCHALLENGE_COMPLETED] = false
        g_playerChallenges[player][i][PCHALLENGE_DATE][0] = 0
    }

    // Generate new challenges
    GenerateDailyChallenges(player)

    new playerName[32]
    get_user_name(player, playerName, charsmax(playerName))

    console_print(id, "[ZC Daily Challenges] Reset challenges for %s", playerName)
    client_print(player, print_chat, "[ZC] Your daily challenges have been reset by an admin.")

    return PLUGIN_HANDLED
}

public CmdCompleteChallenge(id, level, cid) {
    if (!cmd_access(id, level, cid, 3)) return PLUGIN_HANDLED

    new target[32], indexStr[8]
    read_argv(1, target, charsmax(target))
    read_argv(2, indexStr, charsmax(indexStr))

    new player = cmd_target(id, target, CMDTARGET_ALLOW_SELF)
    if (!player) {
        console_print(id, "[ZC Daily Challenges] Player not found: %s", target)
        return PLUGIN_HANDLED
    }

    new challengeIndex = str_to_num(indexStr)
    if (challengeIndex < 0 || challengeIndex >= 3) {
        console_print(id, "[ZC Daily Challenges] Invalid challenge index: %d", challengeIndex)
        return PLUGIN_HANDLED
    }

    CompleteChallenge(player, challengeIndex)

    new playerName[32]
    get_user_name(player, playerName, charsmax(playerName))

    console_print(id, "[ZC Daily Challenges] Completed challenge %d for %s", challengeIndex, playerName)
    client_print(player, print_chat, "[ZC] An admin has completed a challenge for you!")

    return PLUGIN_HANDLED
}

public CmdRefreshChallenges(id, level, cid) {
    if (!cmd_access(id, level, cid, 1)) return PLUGIN_HANDLED

    // Reload challenge templates
    ArrayClear(g_challengeTemplates)
    g_challengeTemplateCount = 0
    LoadChallengeTemplates()

    console_print(id, "[ZC Daily Challenges] Refreshed challenge templates (%d loaded)", g_challengeTemplateCount)
    client_print(0, print_chat, "[ZC] Daily challenges have been refreshed by an admin.")

    return PLUGIN_HANDLED
}

// ============================================================================
// PUBLIC API
// ============================================================================

public plugin_natives() {
    register_native("zc_get_daily_challenge_progress", "NativeGetDailyChallengeProgress")
    register_native("zc_get_daily_challenge_count", "NativeGetDailyChallengeCount")
    register_native("zc_register_custom_challenge", "NativeRegisterCustomChallenge")
    register_native("zc_force_daily_complete", "NativeForceDailyComplete")
}

public NativeGetDailyChallengeProgress(plugin, params) {
    new id = get_param(1)
    new challengeIndex = get_param(2)

    if (id < 1 || id > 32) return 0
    if (challengeIndex < 0 || challengeIndex >= 3) return 0

    return g_playerChallenges[id][challengeIndex][PCHALLENGE_PROGRESS]
}

public NativeGetDailyChallengeCount(plugin, params) {
    return get_pcvar_num(g_pcvarChallengeCount)
}

public NativeRegisterCustomChallenge(plugin, params) {
    new key[64], name[128], desc[256], type[32]
    get_string(1, key, charsmax(key))
    get_string(2, name, charsmax(name))
    get_string(3, desc, charsmax(desc))
    get_string(4, type, charsmax(type))
    new target = get_param(5)
    new difficulty = get_param(6)
    new rewardType[16]
    get_string(7, rewardType, charsmax(rewardType))
    new rewardAmount = get_param(8)
    new minLevel = get_param(9)

    new challenge[ChallengeData]
    challenge[CHALLENGE_ID] = g_challengeTemplateCount
    copy(challenge[CHALLENGE_KEY], charsmax(challenge[CHALLENGE_KEY]), key)
    copy(challenge[CHALLENGE_NAME], charsmax(challenge[CHALLENGE_NAME]), name)
    copy(challenge[CHALLENGE_DESCRIPTION], charsmax(challenge[CHALLENGE_DESCRIPTION]), desc)
    copy(challenge[CHALLENGE_TYPE], charsmax(challenge[CHALLENGE_TYPE]), type)
    challenge[CHALLENGE_TARGET] = target
    challenge[CHALLENGE_DIFFICULTY] = difficulty
    copy(challenge[CHALLENGE_REWARD_TYPE], charsmax(challenge[CHALLENGE_REWARD_TYPE]), rewardType)
    challenge[CHALLENGE_REWARD_AMOUNT] = rewardAmount
    challenge[CHALLENGE_MIN_LEVEL] = minLevel

    ArrayPushArray(g_challengeTemplates, challenge)
    g_challengeTemplateCount++

    return challenge[CHALLENGE_ID]
}

public NativeForceDailyComplete(plugin, params) {
    new id = get_param(1)
    new challengeIndex = get_param(2)

    if (id < 1 || id > 32) return 0
    if (challengeIndex < 0 || challengeIndex >= 3) return 0

    CompleteChallenge(id, challengeIndex)
    return 1
}
