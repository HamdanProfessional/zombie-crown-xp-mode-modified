/************************************************************************************\
		   ========================================
	       * || Zombie Crown XP Mode - Player Profiles || *
	       * || Persistent SQL-based Player Data System || *
		   ========================================
\************************************************************************************/

#include <amxmodx>
#include <amxmisc>
#include <sqlx>
#include <zombiecrown>

// Task IDs
enum {
    TASK_SAVE = 1000
}

#define PLUGIN_VERSION "1.0.0"
#define PLUGIN_AUTHOR "Zombie Crown Dev Team"
#define PLUGIN_NAME "ZC Player Profiles"

// Database connection
new Handle:g_dbTuple;
new Handle:g_dbConnection;

// Player profile data
enum PlayerProfileData {
    PROFILE_LOADED,
    PROFILE_DATABASE_ID,
    PROFILE_STEAM_ID[32],
    PROFILE_NAME[64],
    PROFILE_LEVEL,
    PROFILE_XP,
    PROFILE_POINTS,
    PROFILE_COINS,
    PROFILE_PACKS,
    PROFILE_PLAYTIME,
    PROFILE_FIRST_SEEN[32],
    PROFILE_LAST_SEEN[32],
    PROFILE_PRESTIGE_LEVEL,
    PROFILE_PRESTIGE_POINTS,
    PROFILE_PREF_ZOMBIE_CLASS,
    PROFILE_PREF_HUMAN_CLASS
}

new g_playerProfiles[33][PlayerProfileData];

// Statistics data
enum PlayerStats {
    STATS_TOTAL_KILLS,
    STATS_ZOMBIE_KILLS,
    STATS_HUMAN_KILLS,
    STATS_NEMESIS_KILLS,
    STATS_SURVIVOR_KILLS,
    STATS_TOTAL_DEATHS,
    STATS_DEATHS_AS_ZOMBIE,
    STATS_DEATHS_AS_HUMAN,
    STATS_TOTAL_INFECTIONS,
    STATS_FIRST_ZOMBIE_KILLS,
    STATS_LAST_HUMAN_KILLS,
    STATS_ROUNDS_PLAYED,
    STATS_ROUNDS_WON,
    STATS_ROUNDS_AS_ZOMBIE,
    STATS_ROUNDS_AS_HUMAN
}

new g_playerStats[33][PlayerStats];

// Session tracking
new g_sessionStart[33];
new g_sessionPlaytime[33];

// Configuration
new g_pcvarSaveInterval;
new g_pcvarTrackPlaytime;
new g_pcvarUseSteamID;

// Save task
new g_saveTaskIds[33];

// Forwards
new g_fwProfileLoaded;
new g_fwProfileSaved;
new g_fwStatChanged;
new g_ret;

public plugin_init() {
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

    // Configuration CVARs
    g_pcvarSaveInterval = register_cvar("zc_profile_save_interval", "300") // 5 minutes
    g_pcvarTrackPlaytime = register_cvar("zc_profile_track_playtime", "1")
    g_pcvarUseSteamID = register_cvar("zc_profile_use_steamid", "1")

    // Admin commands
    register_concmd("zc_reload_profile", "CmdReloadProfile", ADMIN_CFG, "<player> - Reload player profile from database")
    register_concmd("zc_save_profile", "CmdSaveProfile", ADMIN_CFG, "<player> - Force save player profile")
    register_concmd("zc_reset_stats", "CmdResetStats", ADMIN_RCON, "<player> - Reset player statistics")
    register_concmd("zc_show_stats", "CmdShowStats", ADMIN_CFG, "<player> - Show player stats in console")

    // Initialize database
    InitializeDatabase()

    // Create forwards
    g_fwProfileLoaded = CreateMultiForward("zc_profile_loaded", ET_IGNORE, FP_CELL)
    g_fwProfileSaved = CreateMultiForward("zc_profile_saved", ET_IGNORE, FP_CELL)
    g_fwStatChanged = CreateMultiForward("zc_player_stat_changed", ET_IGNORE, FP_CELL, FP_STRING, FP_CELL, FP_CELL)
}

public plugin_end() {
    // Free database tuple
    if (g_dbTuple) {
        SQL_FreeHandle(g_dbTuple)
    }
}

InitializeDatabase() {
    // Get database info from cvars or use default SQLite
    new host[64], user[64], pass[64], db[64]
    get_cvar_string("amx_sql_host", host, charsmax(host))
    get_cvar_string("amx_sql_user", user, charsmax(user))
    get_cvar_string("amx_sql_pass", pass, charsmax(pass))
    get_cvar_string("amx_sql_db", db, charsmax(db))

    // Create database tuple
    g_dbTuple = SQL_MakeDbTuple(host, user, pass, db)

    // Test connection and create tables
    new query[2048]
    copy(query, charsmax(query), "CREATE TABLE IF NOT EXISTS `zc_players` (")
    add(query, charsmax(query), "`player_id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,")
    add(query, charsmax(query), "`steam_id` VARCHAR(32) UNIQUE NOT NULL,")
    add(query, charsmax(query), "`player_name` VARCHAR(64) NOT NULL,")
    add(query, charsmax(query), "`level` INT DEFAULT 1,")
    add(query, charsmax(query), "`xp` INT DEFAULT 0,")
    add(query, charsmax(query), "`points` INT DEFAULT 0,")
    add(query, charsmax(query), "`coins` INT DEFAULT 50,")
    add(query, charsmax(query), "`ammopacks` INT DEFAULT 0,")
    add(query, charsmax(query), "`total_playtime` INT DEFAULT 0,")
    add(query, charsmax(query), "`first_seen` DATETIME DEFAULT CURRENT_TIMESTAMP,")
    add(query, charsmax(query), "`last_seen` DATETIME DEFAULT CURRENT_TIMESTAMP,")
    add(query, charsmax(query), "`prestige_level` INT DEFAULT 0,")
    add(query, charsmax(query), "`prestige_points` INT DEFAULT 0,")
    add(query, charsmax(query), "`preferred_zombie_class` INT DEFAULT -1,")
    add(query, charsmax(query), "`preferred_human_class` INT DEFAULT -1,")
    add(query, charsmax(query), "INDEX idx_steam (steam_id),")
    add(query, charsmax(query), "INDEX idx_level (level),")
    add(query, charsmax(query), "INDEX idx_prestige (prestige_level));")

    SQL_ThreadQuery(g_dbTuple, "HandleTableCreate", query)

    // Create player_stats table
    copy(query, charsmax(query), "CREATE TABLE IF NOT EXISTS `zc_player_stats` (")
    add(query, charsmax(query), "`stat_id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,")
    add(query, charsmax(query), "`player_id` INT NOT NULL,")
    add(query, charsmax(query), "`total_kills` INT DEFAULT 0,")
    add(query, charsmax(query), "`zombie_kills` INT DEFAULT 0,")
    add(query, charsmax(query), "`human_kills` INT DEFAULT 0,")
    add(query, charsmax(query), "`nemesis_kills` INT DEFAULT 0,")
    add(query, charsmax(query), "`survivor_kills` INT DEFAULT 0,")
    add(query, charsmax(query), "`total_deaths` INT DEFAULT 0,")
    add(query, charsmax(query), "`deaths_as_zombie` INT DEFAULT 0,")
    add(query, charsmax(query), "`deaths_as_human` INT DEFAULT 0,")
    add(query, charsmax(query), "`total_infections` INT DEFAULT 0,")
    add(query, charsmax(query), "`first_zombie_kills` INT DEFAULT 0,")
    add(query, charsmax(query), "`last_human_kills` INT DEFAULT 0,")
    add(query, charsmax(query), "`rounds_played` INT DEFAULT 0,")
    add(query, charsmax(query), "`rounds_won` INT DEFAULT 0,")
    add(query, charsmax(query), "`rounds_as_zombie` INT DEFAULT 0,")
    add(query, charsmax(query), "`rounds_as_human` INT DEFAULT 0,")
    add(query, charsmax(query), "FOREIGN KEY (player_id) REFERENCES zc_players(player_id) ON DELETE CASCADE,")
    add(query, charsmax(query), "UNIQUE KEY unique_player (player_id);")

    SQL_ThreadQuery(g_dbTuple, "HandleTableCreate", query)
}

public HandleTableCreate(failState, Handle:query, error[], errnum, data[], size) {
    if (failState) {
        log_amx("[ZC Profiles] Failed to create table: %s", error)
        return
    }
    log_amx("[ZC Profiles] Database table created/verified successfully")
}

public client_putinserver(id) {
    // Reset profile data
    ResetProfile(id)

    // Load player profile
    LoadPlayerProfile(id)

    // Start session tracking
    if (get_pcvar_num(g_pcvarTrackPlaytime)) {
        g_sessionStart[id] = get_systime()
        g_sessionPlaytime[id] = 0
    }

    // Set up periodic save task
    new saveInterval = get_pcvar_num(g_pcvarSaveInterval)
    if (saveInterval > 0) {
        g_saveTaskIds[id] = set_task(float(saveInterval), "PeriodicSave", id + TASK_SAVE, _, _, "b")
    }
}

public client_disconnect(id) {
    // Save profile before disconnect
    SavePlayerProfile(id)

    // End session tracking
    if (get_pcvar_num(g_pcvarTrackPlaytime) && g_sessionStart[id] > 0) {
        new sessionTime = get_systime() - g_sessionStart[id]
        UpdatePlaytime(id, sessionTime)
    }

    // Remove save task
    if (task_exists(id + TASK_SAVE)) {
        remove_task(id + TASK_SAVE)
    }
}

LoadPlayerProfile(id) {
    if (!is_user_connected(id)) return

    // Get player identifier
    new identifier[32]
    if (get_pcvar_num(g_pcvarUseSteamID)) {
        get_user_authid(id, identifier, charsmax(identifier))
    } else {
        get_user_name(id, identifier, charsmax(identifier))
    }

    // Copy identifier to profile
    copy(g_playerProfiles[id][PROFILE_STEAM_ID], charsmax(g_playerProfiles[][PROFILE_STEAM_ID]), identifier)
    get_user_name(id, g_playerProfiles[id][PROFILE_NAME], charsmax(g_playerProfiles[][PROFILE_NAME]))

    // Load from database
    new query[512]
    if (get_pcvar_num(g_pcvarUseSteamID)) {
        formatex(query, charsmax(query),
            "SELECT p.*, s.* FROM zc_players p LEFT JOIN zc_player_stats s ON p.player_id = s.player_id WHERE p.steam_id = '%s'",
            identifier)
    } else {
        formatex(query, charsmax(query),
            "SELECT p.*, s.* FROM zc_players p LEFT JOIN zc_player_stats s ON p.player_id = s.player_id WHERE p.player_name = '%s'",
            identifier)
    }

    new data[2]
    data[0] = id
    SQL_ThreadQuery(g_dbTuple, "HandleProfileLoad", query, data, sizeof(data))
}

public HandleProfileLoad(failState, Handle:query, error[], errnum, data[], size) {
    new id = data[0]

    if (failState != TQUERY_SUCCESS) {
        log_amx("[ZC Profiles] Failed to load profile for player %d: %s", id, error)
        // Create new profile on load failure
        CreateNewProfile(id)
        return
    }

    if (SQL_NumResults(query) > 0) {
        // Load existing profile
        g_playerProfiles[id][PROFILE_DATABASE_ID] = SQL_ReadResult(query, 0)
        SQL_ReadResult(query, 4, g_playerProfiles[id][PROFILE_NAME], charsmax(g_playerProfiles[][PROFILE_NAME]))
        g_playerProfiles[id][PROFILE_LEVEL] = SQL_ReadResult(query, 5)
        g_playerProfiles[id][PROFILE_XP] = SQL_ReadResult(query, 6)
        g_playerProfiles[id][PROFILE_POINTS] = SQL_ReadResult(query, 7)
        g_playerProfiles[id][PROFILE_COINS] = SQL_ReadResult(query, 8)
        g_playerProfiles[id][PROFILE_PACKS] = SQL_ReadResult(query, 9)
        g_playerProfiles[id][PROFILE_PLAYTIME] = SQL_ReadResult(query, 10)
        SQL_ReadResult(query, 11, g_playerProfiles[id][PROFILE_FIRST_SEEN], charsmax(g_playerProfiles[][PROFILE_FIRST_SEEN]))
        SQL_ReadResult(query, 12, g_playerProfiles[id][PROFILE_LAST_SEEN], charsmax(g_playerProfiles[][PROFILE_LAST_SEEN]))
        g_playerProfiles[id][PROFILE_PRESTIGE_LEVEL] = SQL_ReadResult(query, 13)
        g_playerProfiles[id][PROFILE_PRESTIGE_POINTS] = SQL_ReadResult(query, 14)
        g_playerProfiles[id][PROFILE_PREF_ZOMBIE_CLASS] = SQL_ReadResult(query, 15)
        g_playerProfiles[id][PROFILE_PREF_HUMAN_CLASS] = SQL_ReadResult(query, 16)

        // Load statistics (columns 17-30)
        if (SQL_FieldNameToNum(query, "total_kills") >= 0) {
            g_playerStats[id][STATS_TOTAL_KILLS] = SQL_ReadResult(query, 17)
            g_playerStats[id][STATS_ZOMBIE_KILLS] = SQL_ReadResult(query, 18)
            g_playerStats[id][STATS_HUMAN_KILLS] = SQL_ReadResult(query, 19)
            g_playerStats[id][STATS_NEMESIS_KILLS] = SQL_ReadResult(query, 20)
            g_playerStats[id][STATS_SURVIVOR_KILLS] = SQL_ReadResult(query, 21)
            g_playerStats[id][STATS_TOTAL_DEATHS] = SQL_ReadResult(query, 22)
            g_playerStats[id][STATS_DEATHS_AS_ZOMBIE] = SQL_ReadResult(query, 23)
            g_playerStats[id][STATS_DEATHS_AS_HUMAN] = SQL_ReadResult(query, 24)
            g_playerStats[id][STATS_TOTAL_INFECTIONS] = SQL_ReadResult(query, 25)
            g_playerStats[id][STATS_FIRST_ZOMBIE_KILLS] = SQL_ReadResult(query, 26)
            g_playerStats[id][STATS_LAST_HUMAN_KILLS] = SQL_ReadResult(query, 27)
            g_playerStats[id][STATS_ROUNDS_PLAYED] = SQL_ReadResult(query, 28)
            g_playerStats[id][STATS_ROUNDS_WON] = SQL_ReadResult(query, 29)
            g_playerStats[id][STATS_ROUNDS_AS_ZOMBIE] = SQL_ReadResult(query, 30)
            g_playerStats[id][STATS_ROUNDS_AS_HUMAN] = SQL_ReadResult(query, 31)
        }

        g_playerProfiles[id][PROFILE_LOADED] = true
        log_amx("[ZC Profiles] Loaded profile for %s (Level: %d, XP: %d)", g_playerProfiles[id][PROFILE_NAME], g_playerProfiles[id][PROFILE_LEVEL], g_playerProfiles[id][PROFILE_XP])
    } else {
        // Create new profile
        CreateNewProfile(id)
    }

    // Call forward
    ExecuteForward(g_fwProfileLoaded, g_ret, id)
}

CreateNewProfile(id) {
    // Get player name and identifier
    new playerName[64], identifier[32]
    get_user_name(id, playerName, charsmax(playerName))

    if (get_pcvar_num(g_pcvarUseSteamID)) {
        get_user_authid(id, identifier, charsmax(identifier))
    } else {
        copy(identifier, charsmax(identifier), playerName)
    }

    // Set default values
    g_playerProfiles[id][PROFILE_LEVEL] = 1
    g_playerProfiles[id][PROFILE_XP] = 0
    g_playerProfiles[id][PROFILE_POINTS] = 0
    g_playerProfiles[id][PROFILE_COINS] = 50
    g_playerProfiles[id][PROFILE_PACKS] = 0
    g_playerProfiles[id][PROFILE_PLAYTIME] = 0
    g_playerProfiles[id][PROFILE_PRESTIGE_LEVEL] = 0
    g_playerProfiles[id][PROFILE_PRESTIGE_POINTS] = 0
    g_playerProfiles[id][PROFILE_PREF_ZOMBIE_CLASS] = -1
    g_playerProfiles[id][PROFILE_PREF_HUMAN_CLASS] = -1
    copy(g_playerProfiles[id][PROFILE_NAME], charsmax(g_playerProfiles[][PROFILE_NAME]), playerName)

    // Insert into database
    new query[512]
    formatex(query, charsmax(query),
        "INSERT INTO zc_players (steam_id, player_name, level, xp, points, coins, ammopacks) VALUES ('%s', '%s', 1, 0, 0, 50, 0)",
        identifier, playerName)

    new data[2]
    data[0] = id
    SQL_ThreadQuery(g_dbTuple, "HandleNewProfileCreate", query, data, sizeof(data))
}

public HandleNewProfileCreate(failState, Handle:query, error[], errnum, data[], size) {
    new id = data[0]

    if (failState != TQUERY_SUCCESS) {
        log_amx("[ZC Profiles] Failed to create new profile for player %d: %s", id, error)
        return
    }

    // Get the insert ID
    g_playerProfiles[id][PROFILE_DATABASE_ID] = SQL_GetInsertId(query)
    g_playerProfiles[id][PROFILE_LOADED] = true

    // Create stats record
    new statsQuery[128]
    formatex(statsQuery, charsmax(statsQuery),
        "INSERT INTO zc_player_stats (player_id) VALUES (%d)",
        g_playerProfiles[id][PROFILE_DATABASE_ID])
    SQL_ThreadQuery(g_dbTuple, "HandleStatsCreate", statsQuery)

    log_amx("[ZC Profiles] Created new profile for %s (ID: %d)", g_playerProfiles[id][PROFILE_NAME], g_playerProfiles[id][PROFILE_DATABASE_ID])
}

public HandleStatsCreate(failState, Handle:query, error[], errnum, data[], size) {
    if (failState != TQUERY_SUCCESS) {
        log_amx("[ZC Profiles] Failed to create stats record: %s", error)
    }
}

SavePlayerProfile(id) {
    if (!g_playerProfiles[id][PROFILE_LOADED]) return

    new identifier[32], playerName[64]
    get_user_name(id, playerName, charsmax(playerName))

    if (get_pcvar_num(g_pcvarUseSteamID)) {
        get_user_authid(id, identifier, charsmax(identifier))
    } else {
        copy(identifier, charsmax(identifier), playerName)
    }

    // Build query to update player data
    new query[1024]
    formatex(query, charsmax(query), "UPDATE zc_players SET player_name = '%s', level = %d, xp = %d, points = %d, coins = %d, ammopacks = %d, total_playtime = %d, last_seen = NOW(), prestige_level = %d, prestige_points = %d, preferred_zombie_class = %d, preferred_human_class = %d WHERE player_id = %d",
        playerName,
        g_playerProfiles[id][PROFILE_LEVEL],
        g_playerProfiles[id][PROFILE_XP],
        g_playerProfiles[id][PROFILE_POINTS],
        g_playerProfiles[id][PROFILE_COINS],
        g_playerProfiles[id][PROFILE_PACKS],
        g_playerProfiles[id][PROFILE_PLAYTIME],
        g_playerProfiles[id][PROFILE_PRESTIGE_LEVEL],
        g_playerProfiles[id][PROFILE_PRESTIGE_POINTS],
        g_playerProfiles[id][PROFILE_PREF_ZOMBIE_CLASS],
        g_playerProfiles[id][PROFILE_PREF_HUMAN_CLASS],
        g_playerProfiles[id][PROFILE_DATABASE_ID])

    new data[2]
    data[0] = id
    SQL_ThreadQuery(g_dbTuple, "HandleProfileSave", query, data, sizeof(data))

    // Save statistics
    SavePlayerStats(id)
}

public HandleProfileSave(failState, Handle:query, error[], errnum, data[], size) {
    new id = data[0]

    if (failState != TQUERY_SUCCESS) {
        log_amx("[ZC Profiles] Failed to save profile for player %d: %s", id, error)
        return
    }

    // Call forward
    ExecuteForward(g_fwProfileSaved, g_ret, id)
}

SavePlayerStats(id) {
    if (!g_playerProfiles[id][PROFILE_LOADED]) return

    new query[1024]
    formatex(query, charsmax(query), "UPDATE zc_player_stats SET total_kills = %d, zombie_kills = %d, human_kills = %d, nemesis_kills = %d, survivor_kills = %d, total_deaths = %d, deaths_as_zombie = %d, deaths_as_human = %d, total_infections = %d, first_zombie_kills = %d, last_human_kills = %d, rounds_played = %d, rounds_won = %d, rounds_as_zombie = %d, rounds_as_human = %d WHERE player_id = %d",
        g_playerStats[id][STATS_TOTAL_KILLS],
        g_playerStats[id][STATS_ZOMBIE_KILLS],
        g_playerStats[id][STATS_HUMAN_KILLS],
        g_playerStats[id][STATS_NEMESIS_KILLS],
        g_playerStats[id][STATS_SURVIVOR_KILLS],
        g_playerStats[id][STATS_TOTAL_DEATHS],
        g_playerStats[id][STATS_DEATHS_AS_ZOMBIE],
        g_playerStats[id][STATS_DEATHS_AS_HUMAN],
        g_playerStats[id][STATS_TOTAL_INFECTIONS],
        g_playerStats[id][STATS_FIRST_ZOMBIE_KILLS],
        g_playerStats[id][STATS_LAST_HUMAN_KILLS],
        g_playerStats[id][STATS_ROUNDS_PLAYED],
        g_playerStats[id][STATS_ROUNDS_WON],
        g_playerStats[id][STATS_ROUNDS_AS_ZOMBIE],
        g_playerStats[id][STATS_ROUNDS_AS_HUMAN],
        g_playerProfiles[id][PROFILE_DATABASE_ID])

    SQL_ThreadQuery(g_dbTuple, "HandleStatsSave", query)
}

public HandleStatsSave(failState, Handle:query, error[], errnum, data[], size) {
    if (failState != TQUERY_SUCCESS) {
        log_amx("[ZC Profiles] Failed to save stats: %s", error)
    }
}

public PeriodicSave(taskId) {
    new id = taskId - TASK_SAVE
    SavePlayerProfile(id)
}

ResetProfile(id) {
    g_playerProfiles[id][PROFILE_LOADED] = false
    g_playerProfiles[id][PROFILE_DATABASE_ID] = 0
    g_playerProfiles[id][PROFILE_STEAM_ID][0] = 0
    g_playerProfiles[id][PROFILE_NAME][0] = 0
    g_playerProfiles[id][PROFILE_LEVEL] = 1
    g_playerProfiles[id][PROFILE_XP] = 0
    g_playerProfiles[id][PROFILE_POINTS] = 0
    g_playerProfiles[id][PROFILE_COINS] = 50
    g_playerProfiles[id][PROFILE_PACKS] = 0
    g_playerProfiles[id][PROFILE_PLAYTIME] = 0
    g_playerProfiles[id][PROFILE_PRESTIGE_LEVEL] = 0
    g_playerProfiles[id][PROFILE_PRESTIGE_POINTS] = 0
    g_playerProfiles[id][PROFILE_PREF_ZOMBIE_CLASS] = -1
    g_playerProfiles[id][PROFILE_PREF_HUMAN_CLASS] = -1

    for (new i = 0; i < PlayerStats; i++) {
        g_playerStats[id][i] = 0
    }
}

// ============================================================================
// PUBLIC API - Functions for other plugins to use
// ============================================================================

// Get player database ID
public plugin_natives() {
    register_native("zc_get_user_database_id", "NativeGetDatabaseId")
    register_native("zc_get_user_playtime", "NativeGetPlaytime")
    register_native("zc_get_user_stat", "NativeGetStat")
    register_native("zc_set_user_stat", "NativeSetStat")
    register_native("zc_update_user_stat", "NativeUpdateStat")
    register_native("zc_update_player_kills", "NativeUpdateKills")
    register_native("zc_update_player_deaths", "NativeUpdateDeaths")
    register_native("zc_update_player_infections", "NativeUpdateInfections")
    register_native("zc_update_player_round", "NativeUpdateRound")
}

public NativeGetDatabaseId(plugin, params) {
    new id = get_param(1)
    if (id < 1 || id > 32) return 0
    return g_playerProfiles[id][PROFILE_DATABASE_ID]
}

public NativeGetPlaytime(plugin, params) {
    new id = get_param(1)
    if (id < 1 || id > 32) return 0
    return g_playerProfiles[id][PROFILE_PLAYTIME]
}

public NativeGetStat(plugin, params) {
    new id = get_param(1)
    new statName[32]
    get_string(2, statName, charsmax(statName))

    if (id < 1 || id > 32) return 0

    if (equal(statName, "total_kills")) return g_playerStats[id][STATS_TOTAL_KILLS]
    if (equal(statName, "zombie_kills")) return g_playerStats[id][STATS_ZOMBIE_KILLS]
    if (equal(statName, "human_kills")) return g_playerStats[id][STATS_HUMAN_KILLS]
    if (equal(statName, "nemesis_kills")) return g_playerStats[id][STATS_NEMESIS_KILLS]
    if (equal(statName, "survivor_kills")) return g_playerStats[id][STATS_SURVIVOR_KILLS]
    if (equal(statName, "total_deaths")) return g_playerStats[id][STATS_TOTAL_DEATHS]
    if (equal(statName, "deaths_as_zombie")) return g_playerStats[id][STATS_DEATHS_AS_ZOMBIE]
    if (equal(statName, "deaths_as_human")) return g_playerStats[id][STATS_DEATHS_AS_HUMAN]
    if (equal(statName, "total_infections")) return g_playerStats[id][STATS_TOTAL_INFECTIONS]
    if (equal(statName, "first_zombie_kills")) return g_playerStats[id][STATS_FIRST_ZOMBIE_KILLS]
    if (equal(statName, "last_human_kills")) return g_playerStats[id][STATS_LAST_HUMAN_KILLS]
    if (equal(statName, "rounds_played")) return g_playerStats[id][STATS_ROUNDS_PLAYED]
    if (equal(statName, "rounds_won")) return g_playerStats[id][STATS_ROUNDS_WON]
    if (equal(statName, "rounds_as_zombie")) return g_playerStats[id][STATS_ROUNDS_AS_ZOMBIE]
    if (equal(statName, "rounds_as_human")) return g_playerStats[id][STATS_ROUNDS_AS_HUMAN]

    return 0
}

public NativeSetStat(plugin, params) {
    new id = get_param(1)
    new statName[32]
    get_string(2, statName, charsmax(statName))
    new value = get_param(3)

    if (id < 1 || id > 32) return 0

    new oldValue = 0

    if (equal(statName, "total_kills")) {
        oldValue = g_playerStats[id][STATS_TOTAL_KILLS]
        g_playerStats[id][STATS_TOTAL_KILLS] = value
    } else if (equal(statName, "zombie_kills")) {
        oldValue = g_playerStats[id][STATS_ZOMBIE_KILLS]
        g_playerStats[id][STATS_ZOMBIE_KILLS] = value
    } else if (equal(statName, "human_kills")) {
        oldValue = g_playerStats[id][STATS_HUMAN_KILLS]
        g_playerStats[id][STATS_HUMAN_KILLS] = value
    }
    // ... add more stat types as needed

    // Call forward
    ExecuteForward(g_fwStatChanged, g_ret, id, statName, oldValue, value)

    return 1
}

public NativeUpdateStat(plugin, params) {
    new id = get_param(1)
    new statName[32]
    get_string(2, statName, charsmax(statName))
    new amount = get_param(3)

    if (id < 1 || id > 32) return 0

    new oldValue = 0, newValue = 0

    if (equal(statName, "total_kills")) {
        oldValue = g_playerStats[id][STATS_TOTAL_KILLS]
        g_playerStats[id][STATS_TOTAL_KILLS] += amount
        newValue = g_playerStats[id][STATS_TOTAL_KILLS]
    } else if (equal(statName, "zombie_kills")) {
        oldValue = g_playerStats[id][STATS_ZOMBIE_KILLS]
        g_playerStats[id][STATS_ZOMBIE_KILLS] += amount
        newValue = g_playerStats[id][STATS_ZOMBIE_KILLS]
    } else if (equal(statName, "human_kills")) {
        oldValue = g_playerStats[id][STATS_HUMAN_KILLS]
        g_playerStats[id][STATS_HUMAN_KILLS] += amount
        newValue = g_playerStats[id][STATS_HUMAN_KILLS]
    } else if (equal(statName, "total_deaths")) {
        oldValue = g_playerStats[id][STATS_TOTAL_DEATHS]
        g_playerStats[id][STATS_TOTAL_DEATHS] += amount
        newValue = g_playerStats[id][STATS_TOTAL_DEATHS]
    } else if (equal(statName, "total_infections")) {
        oldValue = g_playerStats[id][STATS_TOTAL_INFECTIONS]
        g_playerStats[id][STATS_TOTAL_INFECTIONS] += amount
        newValue = g_playerStats[id][STATS_TOTAL_INFECTIONS]
    } else if (equal(statName, "rounds_played")) {
        oldValue = g_playerStats[id][STATS_ROUNDS_PLAYED]
        g_playerStats[id][STATS_ROUNDS_PLAYED] += amount
        newValue = g_playerStats[id][STATS_ROUNDS_PLAYED]
    } else if (equal(statName, "rounds_won")) {
        oldValue = g_playerStats[id][STATS_ROUNDS_WON]
        g_playerStats[id][STATS_ROUNDS_WON] += amount
        newValue = g_playerStats[id][STATS_ROUNDS_WON]
    }

    // Call forward
    ExecuteForward(g_fwStatChanged, g_ret, id, statName, oldValue, newValue)

    return 1
}

public NativeUpdateKills(plugin, params) {
    new attacker = get_param(1)
    new victim = get_param(2)

    if (attacker < 1 || attacker > 32 || victim < 1 || victim > 32) return 0
    if (attacker == victim) return 0 // Suicide doesn't count

    // Update attacker's kills
    g_playerStats[attacker][STATS_TOTAL_KILLS]++

    if (zp_get_user_zombie(victim)) {
        g_playerStats[attacker][STATS_ZOMBIE_KILLS]++
        if (zp_get_user_nemesis(victim)) {
            g_playerStats[attacker][STATS_NEMESIS_KILLS]++
        }
    } else {
        g_playerStats[attacker][STATS_HUMAN_KILLS]++
        if (zp_get_user_survivor(victim)) {
            g_playerStats[attacker][STATS_SURVIVOR_KILLS]++
        }
    }

    // Update victim's deaths
    g_playerStats[victim][STATS_TOTAL_DEATHS]++

    if (zp_get_user_zombie(victim)) {
        g_playerStats[victim][STATS_DEATHS_AS_ZOMBIE]++
    } else {
        g_playerStats[victim][STATS_DEATHS_AS_HUMAN]++
    }

    // Update special kills
    if (zp_get_user_first_zombie(victim)) {
        g_playerStats[attacker][STATS_FIRST_ZOMBIE_KILLS]++
    }
    if (zp_get_user_last_human(victim)) {
        g_playerStats[attacker][STATS_LAST_HUMAN_KILLS]++
    }

    return 1
}

public NativeUpdateDeaths(plugin, params) {
    new victim = get_param(1)

    if (victim < 1 || victim > 32) return 0

    g_playerStats[victim][STATS_TOTAL_DEATHS]++

    if (zp_get_user_zombie(victim)) {
        g_playerStats[victim][STATS_DEATHS_AS_ZOMBIE]++
    } else {
        g_playerStats[victim][STATS_DEATHS_AS_HUMAN]++
    }

    return 1
}

public NativeUpdateInfections(plugin, params) {
    new id = get_param(1)
    new amount = get_param(2)

    if (id < 1 || id > 32) return 0

    g_playerStats[id][STATS_TOTAL_INFECTIONS] += amount

    return 1
}

public NativeUpdateRound(plugin, params) {
    new id = get_param(1)
    new won = get_param(2)

    if (id < 1 || id > 32) return 0

    g_playerStats[id][STATS_ROUNDS_PLAYED]++

    if (won) {
        g_playerStats[id][STATS_ROUNDS_WON]++
    }

    if (zp_get_user_zombie(id)) {
        g_playerStats[id][STATS_ROUNDS_AS_ZOMBIE]++
    } else {
        g_playerStats[id][STATS_ROUNDS_AS_HUMAN]++
    }

    return 1
}

// ============================================================================
// ADMIN COMMANDS
// ============================================================================

public CmdReloadProfile(id, level, cid) {
    if (!cmd_access(id, level, cid, 2)) return PLUGIN_HANDLED

    new target[32]
    read_argv(1, target, charsmax(target))

    new player = cmd_target(id, target, CMDTARGET_ALLOW_SELF)
    if (!player) {
        console_print(id, "[ZC Profiles] Player not found: %s", target)
        return PLUGIN_HANDLED
    }

    // Save current profile first
    SavePlayerProfile(player)

    // Reset and reload
    ResetProfile(player)
    LoadPlayerProfile(player)

    console_print(id, "[ZC Profiles] Reloaded profile for %s", g_playerProfiles[player][PROFILE_NAME])
    client_print(player, print_chat, "[ZC] Your profile has been reloaded by an admin.")

    return PLUGIN_HANDLED
}

public CmdSaveProfile(id, level, cid) {
    if (!cmd_access(id, level, cid, 2)) return PLUGIN_HANDLED

    new target[32]
    read_argv(1, target, charsmax(target))

    new player = cmd_target(id, target, CMDTARGET_ALLOW_SELF)
    if (!player) {
        console_print(id, "[ZC Profiles] Player not found: %s", target)
        return PLUGIN_HANDLED
    }

    SavePlayerProfile(player)

    console_print(id, "[ZC Profiles] Saved profile for %s", g_playerProfiles[player][PROFILE_NAME])
    client_print(player, print_chat, "[ZC] Your profile has been saved by an admin.")

    return PLUGIN_HANDLED
}

public CmdResetStats(id, level, cid) {
    if (!cmd_access(id, level, cid, 2)) return PLUGIN_HANDLED

    new target[32]
    read_argv(1, target, charsmax(target))

    new player = cmd_target(id, target, CMDTARGET_ALLOW_SELF)
    if (!player) {
        console_print(id, "[ZC Profiles] Player not found: %s", target)
        return PLUGIN_HANDLED
    }

    // Reset all stats
    for (new i = 0; i < PlayerStats; i++) {
        g_playerStats[player][i] = 0
    }

    SavePlayerStats(player)

    new playerName[32]
    get_user_name(player, playerName, charsmax(playerName))

    console_print(id, "[ZC Profiles] Reset statistics for %s", playerName)
    client_print(player, print_chat, "[ZC] Your statistics have been reset by an admin.")

    log_amx("[ZC Profiles] Admin %d reset statistics for player %s", id, playerName)

    return PLUGIN_HANDLED
}

public CmdShowStats(id, level, cid) {
    if (!cmd_access(id, level, cid, 2)) return PLUGIN_HANDLED

    new target[32]
    read_argv(1, target, charsmax(target))

    new player = cmd_target(id, target, CMDTARGET_ALLOW_SELF)
    if (!player) {
        console_print(id, "[ZC Profiles] Player not found: %s", target)
        return PLUGIN_HANDLED
    }

    console_print(id, "")
    console_print(id, "========== ZC Player Statistics ==========")
    console_print(id, "Player: %s", g_playerProfiles[player][PROFILE_NAME])
    console_print(id, "Level: %d | XP: %d | Points: %d | Coins: %d | Packs: %d",
        g_playerProfiles[player][PROFILE_LEVEL],
        g_playerProfiles[player][PROFILE_XP],
        g_playerProfiles[player][PROFILE_POINTS],
        g_playerProfiles[player][PROFILE_COINS],
        g_playerProfiles[player][PROFILE_PACKS])
    console_print(id, "Prestige: Level %d | Points: %d",
        g_playerProfiles[player][PROFILE_PRESTIGE_LEVEL],
        g_playerProfiles[player][PROFILE_PRESTIGE_POINTS])
    console_print(id, "")
    console_print(id, "--- Kills ---")
    console_print(id, "Total Kills: %d | Zombie Kills: %d | Human Kills: %d",
        g_playerStats[player][STATS_TOTAL_KILLS],
        g_playerStats[player][STATS_ZOMBIE_KILLS],
        g_playerStats[player][STATS_HUMAN_KILLS])
    console_print(id, "Nemesis Kills: %d | Survivor Kills: %d",
        g_playerStats[player][STATS_NEMESIS_KILLS],
        g_playerStats[player][STATS_SURVIVOR_KILLS])
    console_print(id, "")
    console_print(id, "--- Deaths/Infections ---")
    console_print(id, "Total Deaths: %d | As Zombie: %d | As Human: %d",
        g_playerStats[player][STATS_TOTAL_DEATHS],
        g_playerStats[player][STATS_DEATHS_AS_ZOMBIE],
        g_playerStats[player][STATS_DEATHS_AS_HUMAN])
    console_print(id, "Total Infections: %d", g_playerStats[player][STATS_TOTAL_INFECTIONS])
    console_print(id, "")
    console_print(id, "--- Rounds ---")
    console_print(id, "Rounds Played: %d | Rounds Won: %d",
        g_playerStats[player][STATS_ROUNDS_PLAYED],
        g_playerStats[player][STATS_ROUNDS_WON])
    console_print(id, "As Zombie: %d | As Human: %d",
        g_playerStats[player][STATS_ROUNDS_AS_ZOMBIE],
        g_playerStats[player][STATS_ROUNDS_AS_HUMAN])
    console_print(id, "==========================================")
    console_print(id, "")

    return PLUGIN_HANDLED
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

UpdatePlaytime(id, time) {
    g_playerProfiles[id][PROFILE_PLAYTIME] += time
    g_sessionPlaytime[id] += time
}
