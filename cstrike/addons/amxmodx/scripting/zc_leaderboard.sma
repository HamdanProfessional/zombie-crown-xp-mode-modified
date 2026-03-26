/************************************************************************************\
		   ========================================
	       * || Zombie Crown XP Mode - Leaderboards || *
	       * || Ranked Player Statistics System || *
		   ========================================
\************************************************************************************/

#include <amxmodx>
#include <amxmisc>
#include <sqlx>
#include <zombiecrown>

#define PLUGIN_VERSION "1.0.0"
#define PLUGIN_AUTHOR "Zombie Crown Dev Team"
#define PLUGIN_NAME "ZC Leaderboards"

// Leaderboard types
enum LeaderboardType {
    LEADERBOARD_LEVEL = 0,
    LEADERBOARD_XP,
    LEADERBOARD_KILLS,
    LEADERBOARD_INFECTIONS,
    LEADERBOARD_PLAYTIME,
    LEADERBOARD_PRESTIGE,
    LEADERBOARD_COINS,
    LEADERBOARD_MAX
}

new const g_leaderboardNames[][32] = {
    "Highest Level",
    "Total XP",
    "Total Kills",
    "Total Infections",
    "Playtime",
    "Prestige Level",
    "Total Coins"
}

new const g_leaderboardColumns[][32] = {
    "level",
    "xp",
    "total_kills",
    "total_infections",
    "total_playtime",
    "prestige_level",
    "coins"
}

// Leaderboard entry
enum LeaderboardEntry {
    LB_RANK,
    LB_NAME[64],
    LB_VALUE,
    LB_STEAM_ID[32],
    LB_VALUE_FORMATTED[64]
}

// Cached leaderboard data
new Array:g_leaderboardCache[LeaderboardType]
new Float:g_lastLeaderboardUpdate[LeaderboardType]
new bool:g_cacheInitialized[LeaderboardType] = {false, ...}

// Configuration
new g_pcvarRefreshInterval
new g_pcvarCacheSize
new g_pcvarShowCountry

// Database tuple (shared with profiles)
new Handle:g_dbTuple

// Update task
new g_updateTask

// Forwards
new g_fwLeaderboardRefreshed
new g_ret

public plugin_init() {
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

    // Configuration CVARs
    g_pcvarRefreshInterval = register_cvar("zc_leaderboard_refresh_interval", "300") // 5 minutes
    g_pcvarCacheSize = register_cvar("zc_leaderboard_cache_size", "10") // Top 10
    g_pcvarShowCountry = register_cvar("zc_leaderboard_show_country", "1")

    // Player commands
    register_clcmd("say /top", "CmdTopMenu")
    register_clcmd("say_team /top", "CmdTopMenu")
    register_clcmd("say /rank", "CmdShowRank")
    register_clcmd("say_team /rank", "CmdShowRank")
    register_clcmd("say /leaderboard", "CmdTopMenu")
    register_clcmd("say_team /leaderboard", "CmdTopMenu")

    // Admin commands
    register_concmd("zc_refresh_leaderboard", "CmdRefreshLeaderboard", ADMIN_CFG, "<type> - Refresh specific leaderboard")
    register_concmd("zc_refresh_all_leaderboards", "CmdRefreshAllLeaderboards", ADMIN_CFG, "Refresh all leaderboards")

    // Initialize database connection (reuse from profiles)
    InitializeDatabase()

    // Create forwards
    g_fwLeaderboardRefreshed = CreateMultiForward("zc_leaderboard_refreshed", ET_IGNORE, FP_CELL)

    // Initialize cache arrays
    for (new i = 0; i < LeaderboardType; i++) {
        g_leaderboardCache[i] = Invalid_Array
    }

    // Create cache arrays
    for (new i = 0; i < LeaderboardType; i++) {
        g_leaderboardCache[i] = ArrayCreate(LeaderboardEntry)
    }

    // Initial cache refresh
    set_task(10.0, "InitialCacheRefresh")

    // Set up periodic refresh
    new Float:refreshInterval = get_pcvar_float(g_pcvarRefreshInterval)
    g_updateTask = set_task(refreshInterval, "PeriodicCacheRefresh", _, _, _, "b")
}

public plugin_end() {
    // Clean up arrays
    for (new i = 0; i < LeaderboardType; i++) {
        if (g_leaderboardCache[i] != Invalid_Array) {
            ArrayDestroy(g_leaderboardCache[i])
        }
    }

    // Free database tuple
    if (g_dbTuple) {
        SQL_FreeHandle(g_dbTuple)
    }
}

InitializeDatabase() {
    // Get database info from cvars
    new host[64], user[64], pass[64], db[64]
    get_cvar_string("amx_sql_host", host, charsmax(host))
    get_cvar_string("amx_sql_user", user, charsmax(user))
    get_cvar_string("amx_sql_pass", pass, charsmax(pass))
    get_cvar_string("amx_sql_db", db, charsmax(db))

    // Create database tuple
    g_dbTuple = SQL_MakeDbTuple(host, user, pass, db)
}

public InitialCacheRefresh() {
    // Refresh all leaderboards on plugin start
    for (new i = 0; i < LeaderboardType; i++) {
        RefreshLeaderboard(i)
    }

    log_amx("[ZC Leaderboards] Initial cache refresh complete")
}

public PeriodicCacheRefresh() {
    // Refresh all leaderboards periodically
    for (new i = 0; i < LeaderboardType; i++) {
        RefreshLeaderboard(i)
    }

    log_amx("[ZC Leaderboards] Periodic cache refresh complete")
}

RefreshLeaderboard(type) {
    if (type < 0 || type >= LeaderboardType) return

    new query[512]
    new cacheSize = get_pcvar_num(g_pcvarCacheSize)

    // Build query based on type
    switch (type) {
        case LEADERBOARD_LEVEL: {
            formatex(query, charsmax(query),
                "SELECT player_name, level, xp, steam_id FROM zc_players ORDER BY level DESC, xp DESC LIMIT %d",
                cacheSize)
        }
        case LEADERBOARD_XP: {
            formatex(query, charsmax(query),
                "SELECT player_name, xp, steam_id FROM zc_players ORDER BY xp DESC LIMIT %d",
                cacheSize)
        }
        case LEADERBOARD_KILLS, LEADERBOARD_INFECTIONS: {
            // Stats are in player_stats table
            new statColumn[32]
            copy(statColumn, charsmax(statColumn), g_leaderboardColumns[type])

            formatex(query, charsmax(query),
                "SELECT p.player_name, s.%s, p.steam_id FROM zc_players p JOIN zc_player_stats s ON p.player_id = s.player_id ORDER BY s.%s DESC LIMIT %d",
                statColumn, statColumn, cacheSize)
        }
        case LEADERBOARD_PLAYTIME: {
            formatex(query, charsmax(query),
                "SELECT player_name, total_playtime, steam_id FROM zc_players ORDER BY total_playtime DESC LIMIT %d",
                cacheSize)
        }
        case LEADERBOARD_PRESTIGE: {
            formatex(query, charsmax(query),
                "SELECT player_name, prestige_level, prestige_points, steam_id FROM zc_players ORDER BY prestige_level DESC, prestige_points DESC LIMIT %d",
                cacheSize)
        }
        case LEADERBOARD_COINS: {
            formatex(query, charsmax(query),
                "SELECT player_name, coins, steam_id FROM zc_players ORDER BY coins DESC LIMIT %d",
                cacheSize)
        }
    }

    new data[2]
    data[0] = type
    SQL_ThreadQuery(g_dbTuple, "HandleLeaderboardRefresh", query, data, sizeof(data))
}

public HandleLeaderboardRefresh(failState, Handle:query, error[], errnum, data[], size) {
    new type = data[0]

    if (failState != TQUERY_SUCCESS) {
        log_amx("[ZC Leaderboards] Failed to refresh %s leaderboard: %s", g_leaderboardNames[type], error)
        return
    }

    // Clear existing cache
    ArrayClear(g_leaderboardCache[type])

    // Load new data
    new rank = 1
    while (SQL_MoreResults(query)) {
        new entry[LeaderboardEntry]

        entry[LB_RANK] = rank

        // Get player name
        SQL_ReadResult(query, 0, entry[LB_NAME], charsmax(entry[LB_NAME]))

        // Get value based on type
        switch (type) {
            case LEADERBOARD_LEVEL: {
                entry[LB_VALUE] = SQL_ReadResult(query, 1)
                new xp = SQL_ReadResult(query, 2)
                formatex(entry[LB_VALUE_FORMATTED], charsmax(entry[LB_VALUE_FORMATTED]), "%d (XP: %d)", entry[LB_VALUE], xp)
            }
            case LEADERBOARD_XP: {
                entry[LB_VALUE] = SQL_ReadResult(query, 1)
                formatex(entry[LB_VALUE_FORMATTED], charsmax(entry[LB_VALUE_FORMATTED]), "%d", entry[LB_VALUE])
            }
            case LEADERBOARD_KILLS, LEADERBOARD_INFECTIONS: {
                entry[LB_VALUE] = SQL_ReadResult(query, 1)
                formatex(entry[LB_VALUE_FORMATTED], charsmax(entry[LB_VALUE_FORMATTED]), "%d", entry[LB_VALUE])
            }
            case LEADERBOARD_PLAYTIME: {
                entry[LB_VALUE] = SQL_ReadResult(query, 1)
                FormatPlaytime(entry[LB_VALUE], entry[LB_VALUE_FORMATTED], charsmax(entry[LB_VALUE_FORMATTED]))
            }
            case LEADERBOARD_PRESTIGE: {
                entry[LB_VALUE] = SQL_ReadResult(query, 1)
                new points = SQL_ReadResult(query, 2)
                formatex(entry[LB_VALUE_FORMATTED], charsmax(entry[LB_VALUE_FORMATTED]), "%d (Points: %d)", entry[LB_VALUE], points)
            }
            case LEADERBOARD_COINS: {
                entry[LB_VALUE] = SQL_ReadResult(query, 1)
                formatex(entry[LB_VALUE_FORMATTED], charsmax(entry[LB_VALUE_FORMATTED]), "%d", entry[LB_VALUE])
            }
        }

        // Get Steam ID
        if (type == LEADERBOARD_KILLS || type == LEADERBOARD_INFECTIONS) {
            SQL_ReadResult(query, 2, entry[LB_STEAM_ID], charsmax(entry[LB_STEAM_ID]))
        } else {
            SQL_ReadResult(query, 2, entry[LB_STEAM_ID], charsmax(entry[LB_STEAM_ID]))
        }

        ArrayPushArray(g_leaderboardCache[type], entry)
        rank++

        SQL_NextRow(query)
    }

    g_lastLeaderboardUpdate[type] = get_gametime()
    g_cacheInitialized[type] = true

    // Call forward
    ExecuteForward(g_fwLeaderboardRefreshed, g_ret, type)

    log_amx("[ZC Leaderboards] Refreshed %s leaderboard (%d entries)", g_leaderboardNames[type], rank - 1)
}

FormatPlaytime(seconds, output[], len) {
    new days = seconds / 86400
    new hours = (seconds % 86400) / 3600
    new mins = (seconds % 3600) / 60

    if (days > 0) {
        formatex(output, len, "%dd %dh %dm", days, hours, mins)
    } else if (hours > 0) {
        formatex(output, len, "%dh %dm", hours, mins)
    } else {
        formatex(output, len, "%dm", mins)
    }
}

// ============================================================================
// PLAYER COMMANDS
// ============================================================================

public CmdTopMenu(id) {
    new menu = menu_create("Leaderboards", "TopMenuHandler")

    for (new i = 0; i < LeaderboardType; i++) {
        new item[128]
        formatex(item, charsmax(item), "%s", g_leaderboardNames[i])
        menu_additem(menu, item)
    }

    menu_display(id, menu)

    return PLUGIN_HANDLED
}

public TopMenuHandler(id, menu, item) {
    if (item == MENU_EXIT) {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    // Show leaderboard for selected type
    ShowLeaderboard(id, item)

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

ShowLeaderboard(id, type) {
    if (type < 0 || type >= LeaderboardType) return

    // Check if cache is initialized
    if (!g_cacheInitialized[type]) {
        client_print(id, print_chat, "[ZC] Leaderboard is still loading. Please try again in a moment.")
        return
    }

    // Build MOTD
    new motd[2048], title[64]
    copy(title, charsmax(title), g_leaderboardNames[type])

    // HTML header with styling
    copy(motd, charsmax(motd), "<html><head>")
    add(motd, charsmax(motd), "<meta charset='UTF-8'>")
    add(motd, charsmax(motd), "<style>")
    add(motd, charsmax(motd), "body { font-family: 'Segoe UI', Arial, sans-serif; background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%); color: #eee; margin: 0; padding: 20px; }")
    add(motd, charsmax(motd), "h2 { text-align: center; color: #ffd700; text-shadow: 0 0 10px rgba(255, 215, 0, 0.5); margin-bottom: 20px; }")
    add(motd, charsmax(motd), "table { width: 100%; max-width: 800px; margin: 0 auto; border-collapse: collapse; background: rgba(255,255,255,0.05); border-radius: 10px; overflow: hidden; }")
    add(motd, charsmax(motd), "th { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #fff; padding: 15px; text-align: left; font-weight: bold; text-transform: uppercase; letter-spacing: 1px; }")
    add(motd, charsmax(motd), "td { padding: 12px 15px; border-bottom: 1px solid rgba(255,255,255,0.1); }")
    add(motd, charsmax(motd), "tr:hover { background: rgba(255,255,255,0.1); }")
    add(motd, charsmax(motd), "tr:last-child td { border-bottom: none; }")
    add(motd, charsmax(motd), ".rank1 { color: #ffd700; font-weight: bold; text-shadow: 0 0 5px rgba(255, 215, 0, 0.5); }")
    add(motd, charsmax(motd), ".rank2 { color: #c0c0c0; font-weight: bold; }")
    add(motd, charsmax(motd), ".rank3 { color: #cd7f32; font-weight: bold; }")
    add(motd, charsmax(motd), ".your-rank { background: rgba(0, 255, 0, 0.1); border-left: 3px solid #00ff00; }")
    add(motd, charsmax(motd), ".rank-num { width: 60px; text-align: center; font-weight: bold; }")
    add(motd, charsmax(motd), ".player-name { font-weight: 500; }")
    add(motd, charsmax(motd), ".value { text-align: right; color: #4ecdc4; font-weight: bold; }")
    add(motd, charsmax(motd), ".last-updated { text-align: center; margin-top: 20px; color: #888; font-size: 12px; }")
    add(motd, charsmax(motd), "</style></head><body>")

    // Add title
    formatex(motd, charsmax(motd), "%s<h2>%s</h2>", motd, title)

    // Add table header
    formatex(motd, charsmax(motd),
        "%s<table><tr><th class='rank-num'>Rank</th><th>Player</th><th class='value'>Value</th></tr>",
        motd)

    // Add leaderboard entries
    new size = ArraySize(g_leaderboardCache[type])
    for (new i = 0; i < size && i < 10; i++) {
        new entry[LeaderboardEntry]
        ArrayGetArray(g_leaderboardCache[type], i, entry)

        new rankClass[32]
        switch (i + 1) {
            case 1: copy(rankClass, charsmax(rankClass), "rank1")
            case 2: copy(rankClass, charsmax(rankClass), "rank2")
            case 3: copy(rankClass, charsmax(rankClass), "rank3")
            default: rankClass[0] = 0
        }

        formatex(motd, charsmax(motd),
            "%s<tr><td class='rank-num %s'>%d</td><td class='player-name'>%s</td><td class='value'>%s</td></tr>",
            motd, rankClass, i + 1, entry[LB_NAME], entry[LB_VALUE_FORMATTED])
    }

    // Add player's rank
    new playerRank = GetPlayerRank(id, type)
    if (playerRank > 0) {
        new playerName[64]
        get_user_name(id, playerName, charsmax(playerName))

        formatex(motd, charsmax(motd),
            "%s<tr class='your-rank'><td class='rank-num'>%d</td><td class='player-name'>%s (You)</td><td class='value'>%d</td></tr>",
            motd, playerRank, playerName, GetPlayerValue(id, type))
    }

    // Close table and add footer
    new lastUpdated[64]
    FormatLastUpdate(type, lastUpdated, charsmax(lastUpdated))

    formatex(motd, charsmax(motd),
        "%s</table><p class='last-updated'>Last updated: %s</p></body></html>",
        motd, lastUpdated)

    // Show MOTD
    show_motd(id, motd, title)
}

GetPlayerRank(id, type) {
    if (!is_user_connected(id)) return 0

    new steamId[32]
    get_user_authid(id, steamId, charsmax(steamId))

    new querySmall[512]

    // Build query to get player rank
    switch (type) {
        case LEADERBOARD_LEVEL: {
            formatex(querySmall, charsmax(querySmall), "SELECT COUNT(*) + 1 FROM zc_players WHERE (level > (SELECT level FROM zc_players WHERE steam_id = '%s')) OR (level = (SELECT level FROM zc_players WHERE steam_id = '%s') AND xp > (SELECT xp FROM zc_players WHERE steam_id = '%s'))", steamId, steamId, steamId)
        }
        case LEADERBOARD_XP: {
            formatex(querySmall, charsmax(querySmall), "SELECT COUNT(*) + 1 FROM zc_players WHERE xp > (SELECT xp FROM zc_players WHERE steam_id = '%s')", steamId)
        }
        case LEADERBOARD_KILLS, LEADERBOARD_INFECTIONS: {
            new statColumn[32]
            copy(statColumn, charsmax(statColumn), g_leaderboardColumns[type])
            formatex(querySmall, charsmax(querySmall), "SELECT COUNT(*) + 1 FROM zc_player_stats s JOIN zc_players p ON s.player_id = p.player_id WHERE s.%s > (SELECT s2.%s FROM zc_player_stats s2 JOIN zc_players p2 ON s2.player_id = p2.player_id WHERE p2.steam_id = '%s')", statColumn, statColumn, steamId)
        }
        case LEADERBOARD_PLAYTIME: {
            formatex(querySmall, charsmax(querySmall), "SELECT COUNT(*) + 1 FROM zc_players WHERE total_playtime > (SELECT total_playtime FROM zc_players WHERE steam_id = '%s')", steamId)
        }
        case LEADERBOARD_PRESTIGE: {
            formatex(querySmall, charsmax(querySmall), "SELECT COUNT(*) + 1 FROM zc_players WHERE (prestige_level > (SELECT prestige_level FROM zc_players WHERE steam_id = '%s')) OR (prestige_level = (SELECT prestige_level FROM zc_players WHERE steam_id = '%s') AND prestige_points > (SELECT prestige_points FROM zc_players WHERE steam_id = '%s'))", steamId, steamId, steamId)
        }
        case LEADERBOARD_COINS: {
            formatex(querySmall, charsmax(querySmall), "SELECT COUNT(*) + 1 FROM zc_players WHERE coins > (SELECT coins FROM zc_players WHERE steam_id = '%s')", steamId)
        }
    }

    // For now, return 0 as placeholder - actual implementation would use async query
    // TODO: Implement cached rank lookup or async query handling
    return 0
}

GetPlayerValue(id, type) {
    // This will be implemented using profile system natives
    // For now, return 0
    return 0
}

FormatLastUpdate(type, output[], len) {
    new Float:timeSinceUpdate = get_gametime() - g_lastLeaderboardUpdate[type]
    new mins = floatround(timeSinceUpdate / 60.0)

    if (mins < 1) {
        copy(output, len, "Just now")
    } else if (mins == 1) {
        copy(output, len, "1 minute ago")
    } else if (mins < 60) {
        formatex(output, len, "%d minutes ago", mins)
    } else {
        new hours = mins / 60
        if (hours == 1) {
            copy(output, len, "1 hour ago")
        } else {
            formatex(output, len, "%d hours ago", hours)
        }
    }
}

public CmdShowRank(id) {
    // Show player's rank on all leaderboards
    new motd[2048]

    copy(motd, charsmax(motd), "<html><head>")
    add(motd, charsmax(motd), "<meta charset='UTF-8'>")
    add(motd, charsmax(motd), "<style>")
    add(motd, charsmax(motd), "body { font-family: 'Segoe UI', Arial, sans-serif; background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%); color: #eee; margin: 0; padding: 20px; }")
    add(motd, charsmax(motd), "h2 { text-align: center; color: #ffd700; text-shadow: 0 0 10px rgba(255, 215, 0, 0.5); }")
    add(motd, charsmax(motd), "table { width: 100%; max-width: 600px; margin: 0 auto; border-collapse: collapse; background: rgba(255,255,255,0.05); border-radius: 10px; overflow: hidden; }")
    add(motd, charsmax(motd), "th { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #fff; padding: 15px; text-align: left; }")
    add(motd, charsmax(motd), "td { padding: 12px 15px; border-bottom: 1px solid rgba(255,255,255,0.1); }")
    add(motd, charsmax(motd), ".rank { text-align: center; font-weight: bold; color: #4ecdc4; }")
    add(motd, charsmax(motd), "</style></head><body>")

    new playerName[64]
    get_user_name(id, playerName, charsmax(playerName))

    formatex(motd, charsmax(motd), "%s<h2>Your Rankings</h2><table><tr><th>Category</th><th>Rank</th></tr>", motd)

    for (new i = 0; i < LeaderboardType; i++) {
        new rank = GetPlayerRank(id, i)
        formatex(motd, charsmax(motd),
            "%s<tr><td>%s</td><td class='rank'>#%d</td></tr>",
            motd, g_leaderboardNames[i], rank)
    }

    formatex(motd, charsmax(motd), "%s</table></body></html>", motd)

    show_motd(id, motd, "Your Rankings")

    return PLUGIN_HANDLED
}

// ============================================================================
// ADMIN COMMANDS
// ============================================================================

public CmdRefreshLeaderboard(id, level, cid) {
    if (!cmd_access(id, level, cid, 2)) return PLUGIN_HANDLED

    new typeStr[32]
    read_argv(1, typeStr, charsmax(typeStr))

    new type = -1
    for (new i = 0; i < LeaderboardType; i++) {
        if (containi(g_leaderboardNames[i], typeStr) != -1) {
            type = i
            break
        }
    }

    if (type < 0 || type >= LeaderboardType) {
        console_print(id, "[ZC Leaderboards] Invalid leaderboard type: %s", typeStr)
        console_print(id, "[ZC Leaderboards] Valid types: Level, XP, Kills, Infections, Playtime, Prestige, Coins")
        return PLUGIN_HANDLED
    }

    RefreshLeaderboard(type)

    console_print(id, "[ZC Leaderboards] Refreshed %s leaderboard", g_leaderboardNames[type])
    client_print(id, print_chat, "[ZC] %s leaderboard has been refreshed.", g_leaderboardNames[type])

    return PLUGIN_HANDLED
}

public CmdRefreshAllLeaderboards(id, level, cid) {
    if (!cmd_access(id, level, cid, 1)) return PLUGIN_HANDLED

    for (new i = 0; i < LeaderboardType; i++) {
        RefreshLeaderboard(i)
    }

    console_print(id, "[ZC Leaderboards] Refreshed all leaderboards")
    client_print(0, print_chat, "[ZC] All leaderboards have been refreshed by an admin.")

    return PLUGIN_HANDLED
}

// ============================================================================
// PUBLIC API
// ============================================================================

public plugin_natives() {
    register_native("zc_get_player_rank", "NativeGetPlayerRank")
    register_native("zc_get_leaderboard_entry", "NativeGetLeaderboardEntry")
    register_native("zc_refresh_leaderboard", "NativeRefreshLeaderboard")
    register_native("zc_get_leaderboard_count", "NativeGetLeaderboardCount")
}

public NativeGetPlayerRank(plugin, params) {
    new id = get_param(1)
    new type = get_param(2)

    if (id < 1 || id > 32) return 0
    if (type < 0 || type >= LeaderboardType) return 0

    return GetPlayerRank(id, type)
}

public NativeGetLeaderboardEntry(plugin, params) {
    new type = get_param(1)
    new rank = get_param(2)
    new name[64], len = get_param(3)

    if (type < 0 || type >= LeaderboardType) return 0
    if (rank < 1 || rank > ArraySize(g_leaderboardCache[type])) return 0

    new entry[LeaderboardEntry]
    ArrayGetArray(g_leaderboardCache[type], rank - 1, entry)

    set_string(3, entry[LB_NAME], len)
    return entry[LB_VALUE]
}

public NativeRefreshLeaderboard(plugin, params) {
    new type = get_param(1)

    if (type < 0 || type >= LeaderboardType) return 0

    RefreshLeaderboard(type)
    return 1
}

public NativeGetLeaderboardCount(plugin, params) {
    return LeaderboardType
}
