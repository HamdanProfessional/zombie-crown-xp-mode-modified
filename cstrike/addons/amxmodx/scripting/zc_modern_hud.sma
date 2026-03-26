/************************************************************************************\
		   ========================================
	       * || Zombie Crown XP Mode - Modern HUD || *
	       * || Message Queue & Priority System || *
		   ========================================
\************************************************************************************/

#include <amxmodx>
#include <amxmisc>
#include <dhudmessage>
#include <fakemeta>
#include <zombiecrown>

#define PLUGIN_VERSION "1.0.0"
#define PLUGIN_AUTHOR "Zombie Crown Dev Team"
#define PLUGIN_NAME "ZC Modern HUD"

// Task IDs
enum {
    TASK_HUD = 2000,
    TASK_MSGPROCESS = 3000
}

// Message priority levels
enum HUDMessagePriority {
    HUD_PRIORITY_CRITICAL = 0,  // Level up, achievement unlocked
    HUD_PRIORITY_HIGH,          // Challenge progress
    HUD_PRIORITY_NORMAL,        // Regular stats
    HUD_PRIORITY_LOW            // Debug info
}

// HUD Message queue structure
enum HUDMessage {
    HUD_MSG_TYPE[32],
    HUD_MSG_TEXT[512],
    HUD_MSG_PRIORITY,
    HUD_MSG_DURATION,
    Float:HUD_MSG_X,
    Float:HUD_MSG_Y,
    HUD_MSG_COLOR[3],
    HUD_MSG_TIMESTAMP,
    HUD_MSG_CHANNEL
}

// HUD Element configuration
enum HUDElement {
    HUD_ELEM_NAME[32],
    HUD_ELEM_ENABLED,
    Float:HUD_ELEM_X,
    Float:HUD_ELEM_Y,
    HUD_ELEM_COLOR[3],
    HUD_ELEM_CHANNEL,
    Float:HUD_ELEM_UPDATE_INTERVAL,
    HUD_ELEM_LAST_UPDATE
}

// Predefined HUD elements
enum {
    HUD_ELEM_STATUS_BAR = 0,
    HUD_ELEM_CURRENCY_BAR,
    HUD_ELEM_CHALLENGE_TRACKER,
    HUD_ELEM_PRESTIGE_BADGE,
    HUD_ELEM_MAX
}

new const g_hudElementNames[HUD_ELEM_MAX][] = {
    "status_bar",
    "currency_bar",
    "challenge_tracker",
    "prestige_badge"
}

// Message queue
new Array:g_hudMessageQueue[33]
new g_messageQueueSize[33]

// HUD elements
new Array:g_hudElements
new g_hudElementCount = 0

// Sync objects for different HUD channels
new g_hudSyncObjects[4]

// Configuration
new g_pcvarEnabled
new g_pcvarUpdateInterval
new g_pcvarMessageQueueSize

// HUD element CVARs
new g_pcvarStatusBarEnabled
new g_pcvarStatusBarX
new g_pcvarStatusBarY
new g_pcvarStatusBarColor[3]

new g_pcvarCurrencyBarEnabled
new g_pcvarCurrencyBarX
new g_pcvarCurrencyBarY
new g_pcvarCurrencyBarColor[3]

new g_pcvarChallengeTrackerEnabled
new g_pcvarChallengeTrackerX
new g_pcvarChallengeTrackerY
new g_pcvarChallengeTrackerColor[3]

new g_pcvarPrestigeBadgeEnabled
new g_pcvarPrestigeBadgeX
new g_pcvarPrestigeBadgeY

// Notification CVARs
new g_pcvarAchievementDuration
new g_pcvarPrestigeDuration
new g_pcvarChallengeDuration

// Display tasks
new g_hudUpdateTaskIds[33]
new g_messageProcessTaskIds[33]

// Forwards
new g_fwHUDElementUpdated
new g_ret

public plugin_init() {
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

    // Main CVARs
    g_pcvarEnabled = register_cvar("zc_hud_enabled", "1")
    g_pcvarUpdateInterval = register_cvar("zc_hud_update_interval", "1.0")
    g_pcvarMessageQueueSize = register_cvar("zc_hud_message_queue_size", "10")

    // HUD element CVARs
    g_pcvarStatusBarEnabled = register_cvar("zc_hud_status_enabled", "1")
    g_pcvarStatusBarX = register_cvar("zc_hud_status_x", "-1.0")
    g_pcvarStatusBarY = register_cvar("zc_hud_status_y", "0.91")

    g_pcvarCurrencyBarEnabled = register_cvar("zc_hud_currency_enabled", "1")
    g_pcvarCurrencyBarX = register_cvar("zc_hud_currency_x", "-1.0")
    g_pcvarCurrencyBarY = register_cvar("zc_hud_currency_y", "0.93")

    g_pcvarChallengeTrackerEnabled = register_cvar("zc_hud_challenge_enabled", "1")
    g_pcvarChallengeTrackerX = register_cvar("zc_hud_challenge_x", "0.02")
    g_pcvarChallengeTrackerY = register_cvar("zc_hud_challenge_y", "0.30")

    g_pcvarPrestigeBadgeEnabled = register_cvar("zc_hud_prestige_enabled", "1")
    g_pcvarPrestigeBadgeX = register_cvar("zc_hud_prestige_x", "0.02")
    g_pcvarPrestigeBadgeY = register_cvar("zc_hud_prestige_y", "0.02")

    // Notification CVARs
    g_pcvarAchievementDuration = register_cvar("zc_hud_achievement_duration", "5.0")
    g_pcvarPrestigeDuration = register_cvar("zc_hud_prestige_duration", "8.0")
    g_pcvarChallengeDuration = register_cvar("zc_hud_challenge_duration", "3.0")

    // Commands
    register_clcmd("say /hud", "CmdHUDMenu")
    register_clcmd("say_team /hud", "CmdHUDMenu")
    register_concmd("zc_debug_hud", "CmdDebugHUD", ADMIN_CFG, "Toggle HUD debug mode")

    // Create sync objects
    for (new i = 0; i < 4; i++) {
        g_hudSyncObjects[i] = CreateHudSyncObj()
    }

    // Initialize HUD elements
    InitializeHUDElements()

    // Create forward
    g_fwHUDElementUpdated = CreateMultiForward("zc_hud_element_updated", ET_IGNORE, FP_CELL, FP_STRING, FP_STRING)

    // Load configuration
    LoadHUDConfiguration()
}

public plugin_end() {
    // Clean up arrays
    for (new i = 1; i <= 32; i++) {
        if (g_hudMessageQueue[i]) {
            ArrayDestroy(g_hudMessageQueue[i])
        }
    }

    if (g_hudElements) {
        ArrayDestroy(g_hudElements)
    }
}

InitializeHUDElements() {
    g_hudElements = ArrayCreate(HUDElement)

    // Create default HUD elements
    new element[HUDElement]

    // Status bar
    copy(element[HUD_ELEM_NAME], charsmax(element[HUD_ELEM_NAME]), "status_bar")
    element[HUD_ELEM_ENABLED] = get_pcvar_num(g_pcvarStatusBarEnabled)
    element[HUD_ELEM_X] = get_pcvar_float(g_pcvarStatusBarX)
    element[HUD_ELEM_Y] = get_pcvar_float(g_pcvarStatusBarY)
    element[HUD_ELEM_CHANNEL] = 0
    element[HUD_ELEM_UPDATE_INTERVAL] = get_pcvar_float(g_pcvarUpdateInterval)
    element[HUD_ELEM_LAST_UPDATE] = 0
    ArrayPushArray(g_hudElements, element)
    g_hudElementCount++

    // Currency bar
    copy(element[HUD_ELEM_NAME], charsmax(element[HUD_ELEM_NAME]), "currency_bar")
    element[HUD_ELEM_ENABLED] = get_pcvar_num(g_pcvarCurrencyBarEnabled)
    element[HUD_ELEM_X] = get_pcvar_float(g_pcvarCurrencyBarX)
    element[HUD_ELEM_Y] = get_pcvar_float(g_pcvarCurrencyBarY)
    element[HUD_ELEM_CHANNEL] = 1
    element[HUD_ELEM_UPDATE_INTERVAL] = get_pcvar_float(g_pcvarUpdateInterval)
    element[HUD_ELEM_LAST_UPDATE] = 0
    ArrayPushArray(g_hudElements, element)
    g_hudElementCount++

    // Challenge tracker
    copy(element[HUD_ELEM_NAME], charsmax(element[HUD_ELEM_NAME]), "challenge_tracker")
    element[HUD_ELEM_ENABLED] = get_pcvar_num(g_pcvarChallengeTrackerEnabled)
    element[HUD_ELEM_X] = get_pcvar_float(g_pcvarChallengeTrackerX)
    element[HUD_ELEM_Y] = get_pcvar_float(g_pcvarChallengeTrackerY)
    element[HUD_ELEM_CHANNEL] = 2
    element[HUD_ELEM_UPDATE_INTERVAL] = get_pcvar_float(g_pcvarUpdateInterval)
    element[HUD_ELEM_LAST_UPDATE] = 0
    ArrayPushArray(g_hudElements, element)
    g_hudElementCount++

    // Prestige badge
    copy(element[HUD_ELEM_NAME], charsmax(element[HUD_ELEM_NAME]), "prestige_badge")
    element[HUD_ELEM_ENABLED] = get_pcvar_num(g_pcvarPrestigeBadgeEnabled)
    element[HUD_ELEM_X] = get_pcvar_float(g_pcvarPrestigeBadgeX)
    element[HUD_ELEM_Y] = get_pcvar_float(g_pcvarPrestigeBadgeY)
    element[HUD_ELEM_CHANNEL] = 3
    element[HUD_ELEM_UPDATE_INTERVAL] = get_pcvar_float(g_pcvarUpdateInterval)
    element[HUD_ELEM_LAST_UPDATE] = 0
    ArrayPushArray(g_hudElements, element)
    g_hudElementCount++
}

LoadHUDConfiguration() {
    // Load from zc_hud.ini if it exists
    new configFile[128]
    get_configsdir(configFile, charsmax(configFile))
    add(configFile, charsmax(configFile), "/zombie_crown/zc_hud.ini")

    if (file_exists(configFile)) {
        // Parse configuration file
        new file = fopen(configFile, "r")
        if (file) {
            new line[512], section[64]
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

                // Parse key=value
                new key[64], value[512]
                strtok(line, key, charsmax(key), value, charsmax(value), '=')
                trim(key)
                trim(value)

                // Apply settings
                if (equal(key, "ENABLED")) {
                    new enabled = str_to_num(value)
                    set_pcvar_num(g_pcvarEnabled, enabled)
                }
                // Add more configuration options as needed
            }
            fclose(file)
        }
    }
}

public client_putinserver(id) {
    // Create message queue for player
    g_hudMessageQueue[id] = ArrayCreate(HUDMessage)
    g_messageQueueSize[id] = 0

    // Start HUD update task
    if (get_pcvar_num(g_pcvarEnabled)) {
        new Float:interval = get_pcvar_float(g_pcvarUpdateInterval)
        g_hudUpdateTaskIds[id] = set_task(interval, "UpdatePlayerHUD", id + TASK_HUD, _, _, "b")

        // Start message processing task
        g_messageProcessTaskIds[id] = set_task(0.5, "ProcessMessageQueue", id + TASK_MSGPROCESS, _, _, "b")
    }
}

public client_disconnect(id) {
    // Remove tasks
    if (task_exists(id + TASK_HUD)) {
        remove_task(id + TASK_HUD)
    }
    if (task_exists(id + TASK_MSGPROCESS)) {
        remove_task(id + TASK_MSGPROCESS)
    }

    // Destroy message queue
    if (g_hudMessageQueue[id]) {
        ArrayDestroy(g_hudMessageQueue[id])
        g_hudMessageQueue[id] = Invalid_Array
        g_messageQueueSize[id] = 0
    }
}

// ============================================================================
// HUD UPDATE FUNCTIONS
// ============================================================================

public UpdatePlayerHUD(taskId) {
    new id = taskId - TASK_HUD

    if (!is_user_connected(id)) return
    if (!get_pcvar_num(g_pcvarEnabled)) return

    new currentTime = get_systime()

    // Update each HUD element
    for (new i = 0; i < g_hudElementCount; i++) {
        new element[HUDElement]
        ArrayGetArray(g_hudElements, i, element)

        if (!element[HUD_ELEM_ENABLED]) continue

        // Check if element needs update
        if (currentTime - element[HUD_ELEM_LAST_UPDATE] < floatround(element[HUD_ELEM_UPDATE_INTERVAL])) {
            continue
        }

        // Update element
        new text[512]
        if (GetElementText(id, element[HUD_ELEM_NAME], text, charsmax(text))) {
            // Display HUD message
            set_hudmessage(255, 209, 23,
                element[HUD_ELEM_X],
                element[HUD_ELEM_Y],
                0,
                0.0,
                element[HUD_ELEM_UPDATE_INTERVAL],
                0.0,
                0.1,
                element[HUD_ELEM_CHANNEL]
            )
            ShowSyncHudMsg(id, g_hudSyncObjects[element[HUD_ELEM_CHANNEL]], "%s", text)

            // Update last update time
            element[HUD_ELEM_LAST_UPDATE] = currentTime
            ArraySetArray(g_hudElements, i, element)

            // Call forward
            ExecuteForward(g_fwHUDElementUpdated, g_ret, id, element[HUD_ELEM_NAME], text)
        }
    }
}

GetElementText(id, const elementName[], text[], len) {
    if (equal(elementName, "status_bar")) {
        return GetStatusBarText(id, text, len)
    } else if (equal(elementName, "currency_bar")) {
        return GetCurrencyBarText(id, text, len)
    } else if (equal(elementName, "challenge_tracker")) {
        return GetChallengeTrackerText(id, text, len)
    } else if (equal(elementName, "prestige_badge")) {
        return GetPrestigeBadgeText(id, text, len)
    }

    return false
}

GetStatusBarText(id, text[], len) {
    if (!is_user_alive(id)) {
        // Show spectating info
        new target = pev(id, pev_iuser2)
        if (target > 0 && target <= 32 && is_user_alive(target)) {
            formatex(text, len, "Spectating: %n^nHealth: %d | Armor: %d | Level: %d",
                target, get_user_health(target), get_user_armor(target), zp_get_user_level(target))
            return true
        }
        return false
    }

    // Build status bar text
    new health = get_user_health(id)
    new armor = get_user_armor(id)
    new level = zp_get_user_level(id)
    new xp = zp_get_user_xp(id)
    new power = zp_get_user_power(id)

    // Get class name
    new className[64]
    if (zp_get_user_zombie(id)) {
        new classId = zp_get_user_zombie_class(id)
        if (classId >= 0) {
            zp_get_user_zclassname(classId, className, charsmax(className))
        } else {
            copy(className, charsmax(className), "None")
        }
    } else {
        new classId = zp_get_user_human_class(id)
        if (classId >= 0) {
            zp_get_user_hclassname(classId, className, charsmax(className))
        } else {
            copy(className, charsmax(className), "Human")
        }
    }

    formatex(text, len, "HP: %d | AP: %d | %s | Lvl: %d^nXP: %d | Power: %d%%",
        health, armor, className, level, xp, power)

    return true
}

GetCurrencyBarText(id, text[], len) {
    new points = zp_get_user_points(id)
    new coins = zp_get_user_coins(id)
    new packs = zp_get_user_ammo_packs(id)
    new level = zp_get_user_level(id)

    formatex(text, len, "Lvl: %d | XP: %d | Points: %d | Coins: %d | Packs: %d",
        level, zp_get_user_xp(id), points, coins, packs)

    return true
}

GetChallengeTrackerText(id, text[], len) {
    // Get daily challenge progress
    // This will be implemented when daily challenges system is added
    // For now, show placeholder
    text[0] = 0
    return false
}

GetPrestigeBadgeText(id, text[], len) {
    // Get prestige level from profile system
    // This requires native from zc_player_profiles
    // For now, show placeholder
    text[0] = 0
    return false
}

// ============================================================================
// MESSAGE QUEUE SYSTEM
// ============================================================================

public ProcessMessageQueue(taskId) {
    new id = taskId - TASK_MSGPROCESS

    if (!is_user_connected(id)) return
    if (!get_pcvar_num(g_pcvarEnabled)) return
    if (g_messageQueueSize[id] == 0) return

    new currentTime = get_systime()
    new maxMessages = get_pcvar_num(g_pcvarMessageQueueSize)

    // Process messages based on priority
    new processedCount = 0
    new index = 0

    while (index < g_messageQueueSize[id] && processedCount < maxMessages) {
        new message[HUDMessage]
        ArrayGetArray(g_hudMessageQueue[id], index, message)

        // Check if message expired
        if (currentTime - message[HUD_MSG_TIMESTAMP] > floatround(message[HUD_MSG_DURATION])) {
            ArrayDeleteItem(g_hudMessageQueue[id], index)
            g_messageQueueSize[id]--
            continue
        }

        // Display message
        DisplayHUDMessage(id, message)

        // Remove message after display
        ArrayDeleteItem(g_hudMessageQueue[id], index)
        g_messageQueueSize[id]--
        processedCount++
    }
}

DisplayHUDMessage(id, message[HUDMessage]) {
    // Use dhudmessage for critical messages
    if (message[HUD_MSG_PRIORITY] == HUD_PRIORITY_CRITICAL) {
        set_dhudmessage(255, 215, 0,
            message[HUD_MSG_X],
            message[HUD_MSG_Y],
            0,
            0.0,
            message[HUD_MSG_DURATION],
            0.5,
            1.5
        )
        show_dhudmessage(id, "%s", message[HUD_MSG_TEXT])
    } else {
        // Use regular HUD for other messages
        set_hudmessage(255, 255, 255,
            message[HUD_MSG_X],
            message[HUD_MSG_Y],
            0,
            0.0,
            message[HUD_MSG_DURATION],
            0.0,
            0.1,
            message[HUD_MSG_CHANNEL]
        )
        ShowSyncHudMsg(id, g_hudSyncObjects[message[HUD_MSG_CHANNEL]], "%s", message[HUD_MSG_TEXT])
    }
}

// ============================================================================
// PUBLIC API - Functions for other plugins
// ============================================================================

public plugin_natives() {
    register_native("zc_hud_show_message", "NativeShowMessage")
    register_native("zc_hud_queue_message", "NativeQueueMessage")
    register_native("zc_hud_update_element", "NativeUpdateElement")
    register_native("zc_hud_set_element_visibility", "NativeSetElementVisibility")
    register_native("zc_hud_is_enabled", "NativeIsEnabled")
    register_native("zc_hud_show_achievement", "NativeShowAchievement")
    register_native("zc_hud_show_prestige", "NativeShowPrestige")
    register_native("zc_hud_show_challenge", "NativeShowChallenge")
}

public NativeShowMessage(plugin, params) {
    new id = get_param(1)
    new message[512]
    get_string(2, message, charsmax(message))
    new priority = get_param(3)
    new Float:duration = Float:get_param(4)

    if (id < 1 || id > 32) return 0
    if (!get_pcvar_num(g_pcvarEnabled)) return 0

    // Show immediately
    new msg[HUDMessage]
    copy(msg[HUD_MSG_TYPE], charsmax(msg[HUD_MSG_TYPE]), "immediate")
    copy(msg[HUD_MSG_TEXT], charsmax(msg[HUD_MSG_TEXT]), message)
    msg[HUD_MSG_PRIORITY] = clamp(priority, HUD_PRIORITY_CRITICAL, HUD_PRIORITY_LOW)
    msg[HUD_MSG_DURATION] = duration
    msg[HUD_MSG_X] = -1.0
    msg[HUD_MSG_Y] = 0.30
    msg[HUD_MSG_TIMESTAMP] = get_systime()
    msg[HUD_MSG_CHANNEL] = 0

    DisplayHUDMessage(id, msg)

    return 1
}

public NativeQueueMessage(plugin, params) {
    new id = get_param(1)
    new message[512]
    get_string(2, message, charsmax(message))
    new priority = get_param(3)
    new Float:duration = Float:get_param(4)

    if (id < 1 || id > 32) return 0
    if (!get_pcvar_num(g_pcvarEnabled)) return 0

    // Check queue size limit
    new maxQueue = get_pcvar_num(g_pcvarMessageQueueSize)
    if (g_messageQueueSize[id] >= maxQueue) {
        // Remove oldest low priority message
        for (new i = 0; i < g_messageQueueSize[id]; i++) {
            new msg[HUDMessage]
            ArrayGetArray(g_hudMessageQueue[id], i, msg)
            if (msg[HUD_MSG_PRIORITY] == HUD_PRIORITY_LOW) {
                ArrayDeleteItem(g_hudMessageQueue[id], i)
                g_messageQueueSize[id]--
                break
            }
        }
    }

    // Add message to queue
    new msg[HUDMessage]
    copy(msg[HUD_MSG_TYPE], charsmax(msg[HUD_MSG_TYPE]), "queued")
    copy(msg[HUD_MSG_TEXT], charsmax(msg[HUD_MSG_TEXT]), message)
    msg[HUD_MSG_PRIORITY] = clamp(priority, HUD_PRIORITY_CRITICAL, HUD_PRIORITY_LOW)
    msg[HUD_MSG_DURATION] = duration
    msg[HUD_MSG_X] = -1.0
    msg[HUD_MSG_Y] = 0.30
    msg[HUD_MSG_TIMESTAMP] = get_systime()
    msg[HUD_MSG_CHANNEL] = 0

    ArrayPushArray(g_hudMessageQueue[id], msg)
    g_messageQueueSize[id]++

    return 1
}

public NativeUpdateElement(plugin, params) {
    new id = get_param(1)
    new elementName[32]
    get_string(2, elementName, charsmax(elementName))
    new text[512]
    get_string(3, text, charsmax(text))

    if (id < 1 || id > 32) return 0
    if (!get_pcvar_num(g_pcvarEnabled)) return 0

    // Find element and update it
    for (new i = 0; i < g_hudElementCount; i++) {
        new element[HUDElement]
        ArrayGetArray(g_hudElements, i, element)

        if (equal(element[HUD_ELEM_NAME], elementName)) {
            if (!element[HUD_ELEM_ENABLED]) return 0

            // Display updated text
            set_hudmessage(255, 255, 255,
                element[HUD_ELEM_X],
                element[HUD_ELEM_Y],
                0,
                0.0,
                element[HUD_ELEM_UPDATE_INTERVAL],
                0.0,
                0.1,
                element[HUD_ELEM_CHANNEL]
            )
            ShowSyncHudMsg(id, g_hudSyncObjects[element[HUD_ELEM_CHANNEL]], "%s", text)

            // Call forward
            ExecuteForward(g_fwHUDElementUpdated, g_ret, id, elementName, text)

            return 1
        }
    }

    return 0
}

public NativeSetElementVisibility(plugin, params) {
    new elementName[32]
    get_string(1, elementName, charsmax(elementName))
    new visible = get_param(2)

    // Find element and update visibility
    for (new i = 0; i < g_hudElementCount; i++) {
        new element[HUDElement]
        ArrayGetArray(g_hudElements, i, element)

        if (equal(element[HUD_ELEM_NAME], elementName)) {
            element[HUD_ELEM_ENABLED] = visible
            ArraySetArray(g_hudElements, i, element)
            return 1
        }
    }

    return 0
}

public NativeIsEnabled(plugin, params) {
    return get_pcvar_num(g_pcvarEnabled)
}

// Notification helpers
public NativeShowAchievement(plugin, params) {
    new id = get_param(1)
    new achievementName[128]
    get_string(2, achievementName, charsmax(achievementName))
    new description[256]
    get_string(3, description, charsmax(description))
    new rewardAmount = get_param(4)
    new rewardType[32]
    get_string(5, rewardType, charsmax(rewardType))

    if (id < 1 || id > 32) return 0
    if (!get_pcvar_num(g_pcvarEnabled)) return 0

    new message[512]
    formatex(message, charsmax(message), "Achievement Unlocked!^n%s^n%s^n+%d %s",
        achievementName, description, rewardAmount, rewardType)

    new Float:duration = get_pcvar_float(g_pcvarAchievementDuration)

    // Queue as critical priority message
    new msg[HUDMessage]
    copy(msg[HUD_MSG_TYPE], charsmax(msg[HUD_MSG_TYPE]), "achievement")
    copy(msg[HUD_MSG_TEXT], charsmax(msg[HUD_MSG_TEXT]), message)
    msg[HUD_MSG_PRIORITY] = HUD_PRIORITY_CRITICAL
    msg[HUD_MSG_DURATION] = duration
    msg[HUD_MSG_X] = -1.0
    msg[HUD_MSG_Y] = 0.25
    msg[HUD_MSG_TIMESTAMP] = get_systime()
    msg[HUD_MSG_CHANNEL] = 0

    ArrayPushArray(g_hudMessageQueue[id], msg)
    g_messageQueueSize[id]++

    return 1
}

public NativeShowPrestige(plugin, params) {
    new id = get_param(1)
    new prestigeLevel = get_param(2)

    if (id < 1 || id > 32) return 0
    if (!get_pcvar_num(g_pcvarEnabled)) return 0

    new message[256]
    formatex(message, charsmax(message), "PRESTIGE LEVEL UP!^n^nYou are now Prestige %d^n+ Bonuses Unlocked!", prestigeLevel)

    new Float:duration = get_pcvar_float(g_pcvarPrestigeDuration)

    // Show immediately with gold color
    set_dhudmessage(255, 215, 0, -1.0, 0.25, 0, 0.0, duration, 0.5, 2.0)
    show_dhudmessage(id, "%s", message)

    return 1
}

public NativeShowChallenge(plugin, params) {
    new id = get_param(1)
    new challengeName[128]
    get_string(2, challengeName, charsmax(challengeName))
    new progress = get_param(3)
    new target = get_param(4)
    new rewardAmount = get_param(5)
    new rewardType[32]
    get_string(6, rewardType, charsmax(rewardType))

    if (id < 1 || id > 32) return 0
    if (!get_pcvar_num(g_pcvarEnabled)) return 0

    new message[512]
    formatex(message, charsmax(message), "Challenge Progress: %s^n%d/%d^n+%d %s when complete",
        challengeName, progress, target, rewardAmount, rewardType)

    new Float:duration = get_pcvar_float(g_pcvarChallengeDuration)

    // Queue as high priority message
    new msg[HUDMessage]
    copy(msg[HUD_MSG_TYPE], charsmax(msg[HUD_MSG_TYPE]), "challenge")
    copy(msg[HUD_MSG_TEXT], charsmax(msg[HUD_MSG_TEXT]), message)
    msg[HUD_MSG_PRIORITY] = HUD_PRIORITY_HIGH
    msg[HUD_MSG_DURATION] = duration
    msg[HUD_MSG_X] = -1.0
    msg[HUD_MSG_Y] = 0.35
    msg[HUD_MSG_TIMESTAMP] = get_systime()
    msg[HUD_MSG_CHANNEL] = 2

    ArrayPushArray(g_hudMessageQueue[id], msg)
    g_messageQueueSize[id]++

    return 1
}

// ============================================================================
// PLAYER COMMANDS
// ============================================================================

public CmdHUDMenu(id) {
    if (!get_pcvar_num(g_pcvarEnabled)) {
        client_print(id, print_chat, "[ZC] Modern HUD is currently disabled.")
        return PLUGIN_HANDLED
    }

    new menu = menu_create("Modern HUD Settings", "HUDMenuHandler")

    new item[128]

    formatex(item, charsmax(item), "Status Bar: %s",
        get_pcvar_num(g_pcvarStatusBarEnabled) ? "\yEnabled" : "\rDisabled")
    menu_additem(menu, item, "1")

    formatex(item, charsmax(item), "Currency Bar: %s",
        get_pcvar_num(g_pcvarCurrencyBarEnabled) ? "\yEnabled" : "\rDisabled")
    menu_additem(menu, item, "2")

    formatex(item, charsmax(item), "Challenge Tracker: %s",
        get_pcvar_num(g_pcvarChallengeTrackerEnabled) ? "\yEnabled" : "\rDisabled")
    menu_additem(menu, item, "3")

    formatex(item, charsmax(item), "Prestige Badge: %s",
        get_pcvar_num(g_pcvarPrestigeBadgeEnabled) ? "\yEnabled" : "\rDisabled")
    menu_additem(menu, item, "4")

    menu_display(id, menu)

    return PLUGIN_HANDLED
}

public HUDMenuHandler(id, menu, item) {
    if (item == MENU_EXIT) {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    new access, callback, info[4]
    menu_item_getinfo(menu, item, access, info, charsmax(info), _, _, callback)

    new choice = str_to_num(info)

    switch (choice) {
        case 1: {
            new enabled = !get_pcvar_num(g_pcvarStatusBarEnabled)
            set_pcvar_num(g_pcvarStatusBarEnabled, enabled)
            client_print(id, print_chat, "[ZC] Status Bar %s", enabled ? "enabled" : "disabled")
        }
        case 2: {
            new enabled = !get_pcvar_num(g_pcvarCurrencyBarEnabled)
            set_pcvar_num(g_pcvarCurrencyBarEnabled, enabled)
            client_print(id, print_chat, "[ZC] Currency Bar %s", enabled ? "enabled" : "disabled")
        }
        case 3: {
            new enabled = !get_pcvar_num(g_pcvarChallengeTrackerEnabled)
            set_pcvar_num(g_pcvarChallengeTrackerEnabled, enabled)
            client_print(id, print_chat, "[ZC] Challenge Tracker %s", enabled ? "enabled" : "disabled")
        }
        case 4: {
            new enabled = !get_pcvar_num(g_pcvarPrestigeBadgeEnabled)
            set_pcvar_num(g_pcvarPrestigeBadgeEnabled, enabled)
            client_print(id, print_chat, "[ZC] Prestige Badge %s", enabled ? "enabled" : "disabled")
        }
    }

    // Update HUD elements
    for (new i = 0; i < g_hudElementCount; i++) {
        new element[HUDElement]
        ArrayGetArray(g_hudElements, i, element)

        switch (choice) {
            case 1: if (equal(element[HUD_ELEM_NAME], "status_bar")) element[HUD_ELEM_ENABLED] = get_pcvar_num(g_pcvarStatusBarEnabled)
            case 2: if (equal(element[HUD_ELEM_NAME], "currency_bar")) element[HUD_ELEM_ENABLED] = get_pcvar_num(g_pcvarCurrencyBarEnabled)
            case 3: if (equal(element[HUD_ELEM_NAME], "challenge_tracker")) element[HUD_ELEM_ENABLED] = get_pcvar_num(g_pcvarChallengeTrackerEnabled)
            case 4: if (equal(element[HUD_ELEM_NAME], "prestige_badge")) element[HUD_ELEM_ENABLED] = get_pcvar_num(g_pcvarPrestigeBadgeEnabled)
        }

        ArraySetArray(g_hudElements, i, element)
    }

    menu_destroy(menu)
    CmdHUDMenu(id) // Show menu again

    return PLUGIN_HANDLED
}

public CmdDebugHUD(id, level, cid) {
    if (!cmd_access(id, level, cid, 1)) return PLUGIN_HANDLED

    new enabled = !get_pcvar_num(g_pcvarEnabled)
    set_pcvar_num(g_pcvarEnabled, enabled)

    console_print(id, "[ZC HUD] Modern HUD %s", enabled ? "ENABLED" : "DISABLED")
    client_print(0, print_chat, "[ZC] Modern HUD has been %s by an admin.", enabled ? "enabled" : "disabled")

    return PLUGIN_HANDLED
}
