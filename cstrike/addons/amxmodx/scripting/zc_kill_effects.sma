/************************************************************************************\
		   ========================================
	       * || Zombie Crown XP Mode - Kill Effects || *
	       * || Visual Effects on Kill || *
		   ========================================
\************************************************************************************/

#include <amxmodx>
#include <amxmisc>
#include <xs>
#include <hamsandwich>
#include <zombiecrown>

// Fade constants
#define FFADE_IN 0x0000

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

#define PLUGIN_VERSION "1.0.0"
#define PLUGIN_AUTHOR "Zombie Crown Dev Team"
#define PLUGIN_NAME "ZC Kill Effects"

// Effect types
enum EffectType {
    EFFECT_SCREEN_FADE = 0,
    EFFECT_SCREEN_SHAKE,
    EFFECT_SPRITE_BURST,
    EFFECT_BEAM_RING,
    EFFECT_PARTICLE_TRAIL,
    EFFECT_LIGHTNING,
    EFFECT_COMBO
}

// Kill effect data
enum KillEffect {
    EFFECT_ID,
    EFFECT_KEY[64],
    EFFECT_NAME[64],
    EFFECT_TYPE,
    EFFECT_DATA[512],  // JSON-encoded parameters
    EFFECT_UNLOCK_TYPE[16],  // achievement, prestige, coins, default
    EFFECT_UNLOCK_REQUIREMENT,
    EFFECT_IS_DEFAULT
}

// Player equipped effects
new g_playerEquippedEffect[33]
new Array:g_playerUnlockedEffects[33]

// Effects list
new Array:g_killEffects
new g_effectCount = 0

// Default effect ID
new g_defaultEffectId = -1

// Configuration
new g_pcvarEnabled
new g_pcvarEffectInterval
new g_pcvarDefaultEffect

// Sprites
new g_beamSprite
new g_glowSprite
new g_flareSprite
new g_shockwaveSprite

// Forwards
new g_fwEffectUnlocked
new g_ret

public plugin_init() {
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

    // Configuration CVARs
    g_pcvarEnabled = register_cvar("zc_kill_effects_enabled", "1")
    g_pcvarEffectInterval = register_cvar("zc_kill_effects_interval", "0.1")  // Minimum time between effects
    g_pcvarDefaultEffect = register_cvar("zc_kill_effects_default", "default")

    // Player commands
    register_clcmd("say /kill_effects", "CmdKillEffectsMenu")
    register_clcmd("say_team /kill_effects", "CmdKillEffectsMenu")
    register_clcmd("say /keffects", "CmdKillEffectsMenu")
    register_clcmd("say_team /keffects", "CmdKillEffectsMenu")

    // Admin commands
    register_concmd("zc_unlock_kill_effect", "CmdUnlockKillEffect", ADMIN_CFG, "<player> <effect_id> - Unlock kill effect for player")
    register_concmd("zc_set_kill_effect", "CmdSetKillEffect", ADMIN_CFG, "<player> <effect_id> - Set player's equipped kill effect")

    // Initialize effects array
    g_killEffects = ArrayCreate(KillEffect)

    // Initialize player unlocked effects arrays
    for (new i = 0; i < 33; i++) {
        g_playerUnlockedEffects[i] = Invalid_Array
        g_playerEquippedEffect[i] = -1
    }

    // Load effects
    LoadKillEffects()

    // Hook into player death
    RegisterHam(Ham_Killed, "player", "fw_PlayerKilled_Post", 1)  // Post, so other plugins can handle first

    // Create forward
    g_fwEffectUnlocked = CreateMultiForward("zc_kill_effect_unlocked", ET_IGNORE, FP_CELL, FP_CELL)

    log_amx("[ZC Kill Effects] Loaded %d effects", g_effectCount)
}

public plugin_precache() {
    // Precache existing sprites with fallbacks
    // Try to precache beam sprites, use alternatives if missing
    if (file_exists("sprites/zbeam/beam.spr")) {
        g_beamSprite = precache_model("sprites/zbeam/beam.spr")
    } else {
        // Use flare as fallback beam sprite
        g_beamSprite = precache_model("sprites/flare6.spr")
        log_amx("[ZC Kill Effects] zbeam/beam.spr not found, using flare6.spr")
    }

    // Other effect sprites
    if (file_exists("sprites/glow.spr")) {
        g_glowSprite = precache_model("sprites/glow.spr")
    } else {
        g_glowSprite = precache_model("sprites/flares/gflare.spr")
    }

    if (file_exists("sprites/flare6.spr")) {
        g_flareSprite = precache_model("sprites/flare6.spr")
    } else {
        g_flareSprite = precache_model("sprites/flare1.spr")
    }

    if (file_exists("sprites/ef_shockwave.spr")) {
        g_shockwaveSprite = precache_model("sprites/ef_shockwave.spr")
    } else {
        g_shockwaveSprite = precache_model("sprites/explode1.spr")
    }

    log_amx("[ZC Kill Effects] Sprites precached successfully")
}

public plugin_end() {
    if (g_killEffects) {
        ArrayDestroy(g_killEffects)
    }

    for (new i = 0; i < 33; i++) {
        if (g_playerUnlockedEffects[i] != Invalid_Array) {
            ArrayDestroy(g_playerUnlockedEffects[i])
        }
    }
}

LoadKillEffects() {
    // Load from configuration file
    new configFile[128]
    get_configsdir(configFile, charsmax(configFile))
    add(configFile, charsmax(configFile), "/zombie_crown/zc_effects.ini")

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
                    ParseKillEffect(key, data)
                }
            }
            fclose(file)
        }
    }

    // Create default effects if none loaded
    if (g_effectCount == 0) {
        CreateDefaultEffects()
    }
}

ParseKillEffect(const key[], const data[]) {
    new effect[KillEffect]

    copy(effect[EFFECT_KEY], charsmax(effect[EFFECT_KEY]), key)

    // Parse format: "Name|type|data|unlock_type|unlock_req|is_default"
    new parsed[6][256]
    explode(data, parsed, charsmax(parsed), charsmax(parsed), "|")

    copy(effect[EFFECT_NAME], charsmax(effect[EFFECT_NAME]), parsed[0])

    new typeStr[32]
    copy(typeStr, charsmax(typeStr), parsed[1])

    if (equal(typeStr, "screen_fade")) effect[EFFECT_TYPE] = EFFECT_SCREEN_FADE
    else if (equal(typeStr, "screen_shake")) effect[EFFECT_TYPE] = EFFECT_SCREEN_SHAKE
    else if (equal(typeStr, "sprite_burst")) effect[EFFECT_TYPE] = EFFECT_SPRITE_BURST
    else if (equal(typeStr, "beam_ring")) effect[EFFECT_TYPE] = EFFECT_BEAM_RING
    else if (equal(typeStr, "particle_trail")) effect[EFFECT_TYPE] = EFFECT_PARTICLE_TRAIL
    else if (equal(typeStr, "lightning")) effect[EFFECT_TYPE] = EFFECT_LIGHTNING
    else if (equal(typeStr, "combo")) effect[EFFECT_TYPE] = EFFECT_COMBO

    copy(effect[EFFECT_DATA], charsmax(effect[EFFECT_DATA]), parsed[2])
    copy(effect[EFFECT_UNLOCK_TYPE], charsmax(effect[EFFECT_UNLOCK_TYPE]), parsed[3])
    effect[EFFECT_UNLOCK_REQUIREMENT] = str_to_num(parsed[4])
    effect[EFFECT_IS_DEFAULT] = str_to_num(parsed[5])

    effect[EFFECT_ID] = g_effectCount
    ArrayPushArray(g_killEffects, effect)
    g_effectCount++

    if (effect[EFFECT_IS_DEFAULT]) {
        g_defaultEffectId = effect[EFFECT_ID]
    }
}

CreateDefaultEffects() {
    log_amx("[ZC Kill Effects] Creating default effects...")

    new effect[KillEffect]

    // Default effect - simple screen fade
    effect[EFFECT_ID] = g_effectCount
    copy(effect[EFFECT_KEY], charsmax(effect[EFFECT_KEY]), "default")
    copy(effect[EFFECT_NAME], charsmax(effect[EFFECT_NAME]), "Default")
    effect[EFFECT_TYPE] = EFFECT_SCREEN_FADE
    copy(effect[EFFECT_DATA], charsmax(effect[EFFECT_DATA]), "{color:[255,0,0],alpha:100,duration:0.5}")
    copy(effect[EFFECT_UNLOCK_TYPE], charsmax(effect[EFFECT_UNLOCK_TYPE]), "default")
    effect[EFFECT_UNLOCK_REQUIREMENT] = 0
    effect[EFFECT_IS_DEFAULT] = 1
    ArrayPushArray(g_killEffects, effect)
    g_effectCount++
    g_defaultEffectId = effect[EFFECT_ID]

    // Blood bath - sprite burst
    effect[EFFECT_ID] = g_effectCount
    copy(effect[EFFECT_KEY], charsmax(effect[EFFECT_KEY]), "blood_bath")
    copy(effect[EFFECT_NAME], charsmax(effect[EFFECT_NAME]), "Blood Bath")
    effect[EFFECT_TYPE] = EFFECT_SPRITE_BURST
    copy(effect[EFFECT_DATA], charsmax(effect[EFFECT_DATA]), "{sprite:sprites/blood.spr,count:20,radius:80,life:10}")
    copy(effect[EFFECT_UNLOCK_TYPE], charsmax(effect[EFFECT_UNLOCK_TYPE]), "achievement")
    effect[EFFECT_UNLOCK_REQUIREMENT] = 150
    effect[EFFECT_IS_DEFAULT] = 0
    ArrayPushArray(g_killEffects, effect)
    g_effectCount++

    // Fire burst - screen fade + shake
    effect[EFFECT_ID] = g_effectCount
    copy(effect[EFFECT_KEY], charsmax(effect[EFFECT_KEY]), "fire_burst")
    copy(effect[EFFECT_NAME], charsmax(effect[EFFECT_NAME]), "Fire Burst")
    effect[EFFECT_TYPE] = EFFECT_COMBO
    copy(effect[EFFECT_DATA], charsmax(effect[EFFECT_DATA]), "{effects:[screen_fade,screen_shake],color:[255,100,0],alpha:150,duration:1.0,shake:1}")
    copy(effect[EFFECT_UNLOCK_TYPE], charsmax(effect[EFFECT_UNLOCK_TYPE]), "achievement")
    effect[EFFECT_UNLOCK_REQUIREMENT] = 200
    effect[EFFECT_IS_DEFAULT] = 0
    ArrayPushArray(g_killEffects, effect)
    g_effectCount++

    log_amx("[ZC Kill Effects] Created %d default effects", g_effectCount)
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
    // Create unlocked effects array
    if (g_playerUnlockedEffects[id] != Invalid_Array) {
        ArrayDestroy(g_playerUnlockedEffects[id])
    }
    g_playerUnlockedEffects[id] = ArrayCreate()

    // Reset equipped effect
    g_playerEquippedEffect[id] = g_defaultEffectId

    // Unlock default effect
    UnlockEffect(id, g_defaultEffectId)
}

public client_disconnect(id) {
    if (g_playerUnlockedEffects[id] != Invalid_Array) {
        ArrayDestroy(g_playerUnlockedEffects[id])
        g_playerUnlockedEffects[id] = Invalid_Array
    }
    g_playerEquippedEffect[id] = -1
}

// ============================================================================
// GAME EVENT HOOKS
// ============================================================================

public fw_PlayerKilled_Post(victim, attacker) {
    if (!get_pcvar_num(g_pcvarEnabled)) return HAM_IGNORED
    if (!is_user_valid_connected(attacker)) return HAM_IGNORED
    if (attacker == victim) return HAM_IGNORED

    // Get equipped effect
    new effectId = g_playerEquippedEffect[attacker]
    if (effectId == -1) effectId = g_defaultEffectId

    new effect[KillEffect]
    for (new i = 0; i < g_effectCount; i++) {
        ArrayGetArray(g_killEffects, i, effect)
        if (effect[EFFECT_ID] == effectId) break
    }

    // Apply effect
    ApplyKillEffect(attacker, victim, effect)

    return HAM_IGNORED
}

ApplyKillEffect(attacker, victim, effect[KillEffect]) {
    switch (effect[EFFECT_TYPE]) {
        case EFFECT_SCREEN_FADE:
            ApplyScreenFadeEffect(victim, effect[EFFECT_DATA])

        case EFFECT_SCREEN_SHAKE:
            ApplyScreenShakeEffect(victim, effect[EFFECT_DATA])

        case EFFECT_SPRITE_BURST:
            ApplySpriteBurstEffect(victim, effect[EFFECT_DATA])

        case EFFECT_BEAM_RING:
            ApplyBeamRingEffect(victim, effect[EFFECT_DATA])

        case EFFECT_PARTICLE_TRAIL:
            ApplyParticleTrailEffect(attacker, victim, effect[EFFECT_DATA])

        case EFFECT_LIGHTNING:
            ApplyLightningEffect(attacker, victim, effect[EFFECT_DATA])

        case EFFECT_COMBO:
            ApplyComboEffect(attacker, victim, effect[EFFECT_DATA])
    }
}

ApplyScreenFadeEffect(victim, const data[]) {
    new color[3], alpha, Float:duration
    ParseFadeData(data, color, alpha, duration)

    message_begin(MSG_ONE, get_user_msgid("ScreenFade"), _, victim)
    write_short(floatround(duration * 1000))
    write_short(floatround(duration * 500))
    write_short(FFADE_IN)
    write_byte(color[0])
    write_byte(color[1])
    write_byte(color[2])
    write_byte(alpha)
    message_end()
}

ApplyScreenShakeEffect(victim, const data[]) {
    new Float:duration
    ParseShakeData(data, duration)

    message_begin(MSG_ONE, get_user_msgid("ScreenShake"), _, victim)
    write_short(floatround(4096.0 * duration, floatround_round))
    write_short(floatround(4096.0 * duration, floatround_round))
    write_short(1<<13)
    message_end()
}

ApplySpriteBurstEffect(victim, const data[]) {
    new sprite[64], count, radius, life
    ParseSpriteData(data, sprite, charsmax(sprite), count, radius, life)

    new origin[3]
    get_user_origin(victim, origin)

    for (new i = 0; i < count; i++) {
        message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
        write_byte(TE_SPRITE)
        write_coord(origin[0] + random_num(-radius, radius))
        write_coord(origin[1] + random_num(-radius, radius))
        write_coord(origin[2] + random_num(0, radius/2))
        write_short(precache_model(sprite))
        write_byte(random_num(5, 15))
        write_byte(life)
        message_end()
    }
}

ApplyBeamRingEffect(victim, const data[]) {
    new color[3], radius, width, Float:lifetime
    ParseBeamData(data, color, radius, width, lifetime)

    new origin[3]
    get_user_origin(victim, origin)

    message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
    write_byte(TE_BEAMTORUS)
    write_coord(origin[0])
    write_coord(origin[1])
    write_coord(origin[2])
    write_coord(origin[0])
    write_coord(origin[1])
    write_coord(origin[2] + 20)
    write_short(g_beamSprite)
    write_byte(0)  // startframe
    write_byte(0)  // framerate
    write_byte(floatround(lifetime * 10))  // life
    write_byte(width)  // width
    write_byte(0)  // noise
    write_byte(color[0])  // r
    write_byte(color[1])  // g
    write_byte(color[2])  // b
    write_byte(255)  // brightness
    write_byte(0)  // speed
    message_end()
}

ApplyParticleTrailEffect(attacker, victim, const data[]) {
    new sprite[64], color[3], count
    ParseParticleData(data, sprite, charsmax(sprite), color, count)

    new start[3], end[3]
    get_user_origin(attacker, start)
    get_user_origin(victim, end)

    for (new i = 0; i < count; i++) {
        new progress = float(i) / float(count)
        new pos[3]
        pos[0] = start[0] + floatround((end[0] - start[0]) * progress)
        pos[1] = start[1] + floatround((end[1] - start[1]) * progress)
        pos[2] = start[2] + floatround((end[2] - start[2]) * progress)

        message_begin(MSG_PVS, SVC_TEMPENTITY, pos)
        write_byte(TE_SPRITE)
        write_coord(pos[0])
        write_coord(pos[1])
        write_coord(pos[2])
        write_short(precache_model(sprite))
        write_byte(random_num(3, 8))
        write_byte(random_num(5, 10))
        message_end()
    }
}

ApplyLightningEffect(attacker, victim, const data[]) {
    new color[3], segments, radius
    ParseLightningData(data, color, segments, radius)

    new start[3], end[3]
    get_user_origin(attacker, start)
    get_user_origin(victim, end)

    message_begin(MSG_PVS, SVC_TEMPENTITY, start)
    write_byte(TE_BEAMPOINTS)
    write_coord(start[0])
    write_coord(start[1])
    write_coord(start[2])
    write_coord(end[0])
    write_coord(end[1])
    write_coord(end[2])
    write_short(g_beamSprite)
    write_byte(0)  // startframe
    write_byte(0)  // framerate
    write_byte(10)  // life
    write_byte(20)  // width
    write_byte(0)  // noise
    write_byte(color[0])  // r
    write_byte(color[1])  // g
    write_byte(color[2])  // b
    write_byte(255)  // brightness
    write_byte(10)  // speed
    message_end()
}

ApplyComboEffect(attacker, victim, const data[]) {
    // Parse combo effects
    // Format: {effects:[effect1,effect2],...}
    new effectsList[10][64]
    new count = ParseComboEffects(data, effectsList, charsmax(effectsList))

    for (new i = 0; i < count; i++) {
        // Apply each effect in the combo
        if (equal(effectsList[i], "screen_fade")) {
            ApplyScreenFadeEffect(victim, data)
        } else if (equal(effectsList[i], "screen_shake")) {
            ApplyScreenShakeEffect(victim, data)
        } else if (equal(effectsList[i], "sprite_burst")) {
            ApplySpriteBurstEffect(victim, data)
        }
    }
}

// ============================================================================
// DATA PARSING HELPERS
// ============================================================================

ParseFadeData(const data[], color[3], &alpha, &Float:duration) {
    // Default values
    color = {255, 0, 0}
    alpha = 100
    duration = 0.5

    // Parse JSON-like data
    new temp[64]

    if (contain(data, "color") != -1) {
        // Extract color array [r,g,b]
        new start = contain(data, "[") + 1
        new end = contain(data, "]")
        if (start > 0 && end > start) {
            new colorStr[32]
            formatex(colorStr, charsmax(colorStr), "%s", data[start])
            colorStr[end - start] = 0

            new r[8], g[8], b[8]
            if (parse(colorStr, r, charsmax(r), g, charsmax(g), b) == 3) {
                color[0] = str_to_num(r)
                color[1] = str_to_num(g)
                color[2] = str_to_num(b)
            }
        }
    }

    if (contain(data, "alpha") != -1) {
        new start = contain(data, "alpha:") + 7
        new end = contain(data[start], ",")
        if (end == -1) end = contain(data[start], "}")
        if (end > 0) {
            new alphaStr[16]
            formatex(alphaStr, charsmax(alphaStr), "%s", data[start])
            alphaStr[end] = 0
            alpha = str_to_num(alphaStr)
        }
    }

    if (contain(data, "duration") != -1) {
        new start = contain(data, "duration:") + 9
        new end = contain(data[start], ",")
        if (end == -1) end = contain(data[start], "}")
        if (end > 0) {
            new durationStr[16]
            formatex(durationStr, charsmax(durationStr), "%s", data[start])
            durationStr[end] = 0
            duration = str_to_float(durationStr)
        }
    }
}

ParseShakeData(const data[], &Float:duration) {
    duration = 1.0

    if (contain(data, "duration") != -1) {
        new start = contain(data, "duration:") + 9
        new end = contain(data[start], ",")
        if (end == -1) end = contain(data[start], "}")
        if (end > 0) {
            new durationStr[16]
            formatex(durationStr, charsmax(durationStr), "%s", data[start])
            durationStr[end] = 0
            duration = str_to_float(durationStr)
        }
    }
}

ParseSpriteData(const data[], sprite[], len, &count, &radius, &life) {
    copy(sprite, len, "sprites/flare6.spr")
    count = 20
    radius = 80
    life = 10

    // Parse parameters from data
    if (contain(data, "sprite") != -1) {
        new start = contain(data, "sprite:") + 8
        new end = contain(data[start], ",")
        if (end == -1) end = contain(data[start], "}")
        if (end > 0) {
            formatex(sprite, len, "%s", data[start])
            sprite[end] = 0
            // Remove quotes
            remove_quotes(sprite)
        }
    }

    if (contain(data, "count") != -1) {
        new start = contain(data, "count:") + 6
        new end = contain(data[start], ",")
        if (end == -1) end = contain(data[start], "}")
        if (end > 0) {
            new countStr[8]
            formatex(countStr, charsmax(countStr), "%s", data[start])
            countStr[end] = 0
            count = str_to_num(countStr)
        }
    }

    if (contain(data, "radius") != -1) {
        new start = contain(data, "radius:") + 7
        new end = contain(data[start], ",")
        if (end == -1) end = contain(data[start], "}")
        if (end > 0) {
            new radiusStr[8]
            formatex(radiusStr, charsmax(radiusStr), "%s", data[start])
            radiusStr[end] = 0
            radius = str_to_num(radiusStr)
        }
    }

    if (contain(data, "life") != -1) {
        new start = contain(data, "life:") + 5
        new end = contain(data[start], ",")
        if (end == -1) end = contain(data[start], "}")
        if (end > 0) {
            new lifeStr[8]
            formatex(lifeStr, charsmax(lifeStr), "%s", data[start])
            lifeStr[end] = 0
            life = str_to_num(lifeStr)
        }
    }
}

ParseBeamData(const data[], color[3], &radius, &width, &Float:lifetime) {
    color = {0, 255, 255}
    radius = 100
    width = 10
    lifetime = 0.5

    // Similar parsing as above
    if (contain(data, "color") != -1) {
        // Extract color
        new start = contain(data, "[") + 1
        new end = contain(data, "]")
        if (start > 0 && end > start) {
            new colorStr[32]
            formatex(colorStr, charsmax(colorStr), "%s", data[start])
            colorStr[end - start] = 0

            new r[8], g[8], b[8]
            if (parse(colorStr, r, charsmax(r), g, charsmax(g), b) == 3) {
                color[0] = str_to_num(r)
                color[1] = str_to_num(g)
                color[2] = str_to_num(b)
            }
        }
    }

    if (contain(data, "radius") != -1) {
        new start = contain(data, "radius:") + 7
        new end = contain(data[start], ",")
        if (end == -1) end = contain(data[start], "}")
        if (end > 0) {
            new radiusStr[8]
            formatex(radiusStr, charsmax(radiusStr), "%s", data[start])
            radiusStr[end] = 0
            radius = str_to_num(radiusStr)
        }
    }

    if (contain(data, "width") != -1) {
        new start = contain(data, "width:") + 6
        new end = contain(data[start], ",")
        if (end == -1) end = contain(data[start], "}")
        if (end > 0) {
            new widthStr[8]
            formatex(widthStr, charsmax(widthStr), "%s", data[start])
            widthStr[end] = 0
            width = str_to_num(widthStr)
        }
    }

    if (contain(data, "lifetime") != -1) {
        new start = contain(data, "lifetime:") + 9
        new end = contain(data[start], ",")
        if (end == -1) end = contain(data[start], "}")
        if (end > 0) {
            new lifetimeStr[16]
            formatex(lifetimeStr, charsmax(lifetimeStr), "%s", data[start])
            lifetimeStr[end] = 0
            lifetime = str_to_float(lifetimeStr)
        }
    }
}

ParseParticleData(const data[], sprite[], len, color[3], &count) {
    copy(sprite, len, "sprites/flare6.spr")
    color = {255, 100, 0}
    count = 50

    // Similar parsing
}

ParseLightningData(const data[], color[3], &segments, &radius) {
    color = {255, 255, 255}
    segments = 10
    radius = 100

    // Similar parsing
}

ParseComboEffects(const data[], effects[][], maxEffects) {
    // Parse effects array from combo data
    // Format: {effects:[screen_fade,screen_shake],...}
    new count = 0

    if (contain(data, "effects") != -1) {
        new start = contain(data, "[") + 1
        new end = contain(data[start], "]")
        if (start > 0 && end > start) {
            new effectsStr[256]
            formatex(effectsStr, charsmax(effectsStr), "%s", data[start])
            effectsStr[end - start] = 0

            // Parse comma-separated effects
            count = explode(effectsStr, effects, maxEffects, maxEffects, ",")
        }
    }

    return count
}

// ============================================================================
// PLAYER COMMANDS
// ============================================================================

public CmdKillEffectsMenu(id) {
    if (!get_pcvar_num(g_pcvarEnabled)) {
        client_print(id, print_chat, "[ZC] Kill effects are currently disabled.")
        return PLUGIN_HANDLED
    }

    new menu = menu_create("Kill Effects", "KillEffectsMenuHandler")

    // Add equipped info
    new info[128]
    new currentEffect = g_playerEquippedEffect[id]
    if (currentEffect == -1) currentEffect = g_defaultEffectId

    new effect[KillEffect]
    for (new i = 0; i < g_effectCount; i++) {
        ArrayGetArray(g_killEffects, i, effect)
        if (effect[EFFECT_ID] == currentEffect) {
            formatex(info, charsmax(info), "\yCurrently Equipped: \r%s", effect[EFFECT_NAME])
            menu_addtext(menu, info, false)
            break
        }
    }

    menu_addblank(menu, false)

    // Add all effects
    for (new i = 0; i < g_effectCount; i++) {
        ArrayGetArray(g_killEffects, i, effect)

        new unlocked = IsEffectUnlocked(id, effect[EFFECT_ID])
        new equipped = (currentEffect == effect[EFFECT_ID])

        new item[256]
        if (equipped) {
            formatex(item, charsmax(item), "\y%s \r[EQUIPPED]", effect[EFFECT_NAME])
        } else if (unlocked) {
            formatex(item, charsmax(item), "\w%s", effect[EFFECT_NAME])
        } else {
            // Check unlock requirements
            new canUnlock = CanUnlockEffect(id, effect)
            if (canUnlock) {
                formatex(item, charsmax(item), "\d%s \y[LOCKED - Click to Unlock]", effect[EFFECT_NAME])
            } else {
                formatex(item, charsmax(item), "\d%s \r[LOCKED]", effect[EFFECT_NAME])
            }
        }

        new infoStr[8]
        num_to_str(effect[EFFECT_ID], infoStr, charsmax(infoStr))
        menu_additem(menu, item, infoStr, (unlocked && !equipped) ? ITEMDRAW_ENABLED : ITEMDRAW_DISABLED)
    }

    menu_display(id, menu)

    return PLUGIN_HANDLED
}

public KillEffectsMenuHandler(id, menu, item) {
    if (item == MENU_EXIT) {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    new access, callback, info[8]
    menu_item_getinfo(menu, item, access, info, charsmax(info), _, _, callback)

    new effectId = str_to_num(info)

    // Equip effect
    if (IsEffectUnlocked(id, effectId)) {
        g_playerEquippedEffect[id] = effectId

        new effect[KillEffect]
        for (new i = 0; i < g_effectCount; i++) {
            ArrayGetArray(g_killEffects, i, effect)
            if (effect[EFFECT_ID] == effectId) {
                client_print(id, print_chat, "[ZC] Equipped kill effect: %s", effect[EFFECT_NAME])
                break
            }
        }
    } else {
        // Try to unlock
        TryUnlockEffect(id, effectId)
    }

    menu_destroy(menu)
    CmdKillEffectsMenu(id) // Show menu again

    return PLUGIN_HANDLED
}

IsEffectUnlocked(id, effectId) {
    new size = ArraySize(g_playerUnlockedEffects[id])
    for (new i = 0; i < size; i++) {
        new unlockedId = ArrayGetCell(g_playerUnlockedEffects[id], i)
        if (unlockedId == effectId) return true
    }
    return false
}

CanUnlockEffect(id, effect[KillEffect]) {
    if (equal(effect[EFFECT_UNLOCK_TYPE], "default")) return true

    if (equal(effect[EFFECT_UNLOCK_TYPE], "achievement")) {
        // Check if achievement is unlocked
        if (is_native_valid("zc_is_achievement_unlocked")) {
            return zc_is_achievement_unlocked(id, effect[EFFECT_UNLOCK_REQUIREMENT])
        }
    } else if (equal(effect[EFFECT_UNLOCK_TYPE], "prestige")) {
        // Check prestige level (requires zc_prestige plugin)
        return false // Prestige system will handle this
    } else if (equal(effect[EFFECT_UNLOCK_TYPE], "coins")) {
        // Check if player has enough coins (placeholder)
        return false // Coin system will be integrated
    }

    return false
}

TryUnlockEffect(id, effectId) {
    new effect[KillEffect]
    for (new i = 0; i < g_effectCount; i++) {
        ArrayGetArray(g_killEffects, i, effect)
        if (effect[EFFECT_ID] == effectId) break
    }

    if (equal(effect[EFFECT_UNLOCK_TYPE], "coins")) {
        // Purchase with coins (placeholder for now)
        client_print(id, print_chat, "[ZC] Coin purchases will be implemented when coin system is integrated")
        return
    }

    // Effect is locked
    client_print(id, print_chat, "[ZC] This effect is locked. Complete the requirement to unlock it.")
}

UnlockEffect(id, effectId) {
    if (IsEffectUnlocked(id, effectId)) return

    ArrayPushCell(g_playerUnlockedEffects[id], effectId)

    // Call forward
    ExecuteForward(g_fwEffectUnlocked, g_ret, id, effectId)
}

// ============================================================================
// ADMIN COMMANDS
// ============================================================================

public CmdUnlockKillEffect(id, level, cid) {
    if (!cmd_access(id, level, cid, 3)) return PLUGIN_HANDLED

    new target[32], effectStr[8]
    read_argv(1, target, charsmax(target))
    read_argv(2, effectStr, charsmax(effectStr))

    new player = cmd_target(id, target, CMDTARGET_ALLOW_SELF)
    if (!player) {
        console_print(id, "[ZC Kill Effects] Player not found: %s", target)
        return PLUGIN_HANDLED
    }

    new effectId = str_to_num(effectStr)
    if (effectId < 0 || effectId >= g_effectCount) {
        console_print(id, "[ZC Kill Effects] Invalid effect ID: %d", effectId)
        return PLUGIN_HANDLED
    }

    UnlockEffect(player, effectId)

    new playerName[32]
    get_user_name(player, playerName, charsmax(playerName))

    console_print(id, "[ZC Kill Effects] Unlocked effect %d for %s", effectId, playerName)
    client_print(player, print_chat, "[ZC] An admin has unlocked a kill effect for you!")

    return PLUGIN_HANDLED
}

public CmdSetKillEffect(id, level, cid) {
    if (!cmd_access(id, level, cid, 3)) return PLUGIN_HANDLED

    new target[32], effectStr[8]
    read_argv(1, target, charsmax(target))
    read_argv(2, effectStr, charsmax(effectStr))

    new player = cmd_target(id, target, CMDTARGET_ALLOW_SELF)
    if (!player) {
        console_print(id, "[ZC Kill Effects] Player not found: %s", target)
        return PLUGIN_HANDLED
    }

    new effectId = str_to_num(effectStr)
    if (effectId < -1 || effectId >= g_effectCount) {
        console_print(id, "[ZC Kill Effects] Invalid effect ID: %d", effectId)
        return PLUGIN_HANDLED
    }

    g_playerEquippedEffect[player] = effectId

    new playerName[32]
    get_user_name(player, playerName, charsmax(playerName))

    console_print(id, "[ZC Kill Effects] Set %s's equipped effect to %d", playerName, effectId)
    client_print(player, print_chat, "[ZC] An admin has changed your equipped kill effect.")

    return PLUGIN_HANDLED
}

// ============================================================================
// PUBLIC API
// ============================================================================

public plugin_natives() {
    register_native("zc_get_player_kill_effect", "NativeGetPlayerKillEffect")
    register_native("zc_set_player_kill_effect", "NativeSetPlayerKillEffect")
    register_native("zc_is_kill_effect_unlocked", "NativeIsKillEffectUnlocked")
    register_native("zc_unlock_kill_effect", "NativeUnlockKillEffect")
    register_native("zc_register_custom_kill_effect", "NativeRegisterCustomKillEffect")
}

public NativeGetPlayerKillEffect(plugin, params) {
    new id = get_param(1)
    if (id < 1 || id > 32) return -1
    return g_playerEquippedEffect[id]
}

public NativeSetPlayerKillEffect(plugin, params) {
    new id = get_param(1)
    new effectId = get_param(2)

    if (id < 1 || id > 32) return 0
    if (effectId < -1 || effectId >= g_effectCount) return 0

    if (!IsEffectUnlocked(id, effectId)) return 0

    g_playerEquippedEffect[id] = effectId
    return 1
}

public NativeIsKillEffectUnlocked(plugin, params) {
    new id = get_param(1)
    new effectId = get_param(2)

    if (id < 1 || id > 32) return 0
    if (effectId < 0 || effectId >= g_effectCount) return 0

    return IsEffectUnlocked(id, effectId) ? 1 : 0
}

public NativeUnlockKillEffect(plugin, params) {
    new id = get_param(1)
    new effectId = get_param(2)

    if (id < 1 || id > 32) return 0
    if (effectId < 0 || effectId >= g_effectCount) return 0

    UnlockEffect(id, effectId)
    return 1
}

public NativeRegisterCustomKillEffect(plugin, params) {
    new key[64], name[64], typeStr[32], data[512]
    get_string(1, key, charsmax(key))
    get_string(2, name, charsmax(name))
    get_string(3, typeStr, charsmax(typeStr))
    get_string(4, data, charsmax(data))

    new effect[KillEffect]
    effect[EFFECT_ID] = g_effectCount
    copy(effect[EFFECT_KEY], charsmax(effect[EFFECT_KEY]), key)
    copy(effect[EFFECT_NAME], charsmax(effect[EFFECT_NAME]), name)

    if (equal(typeStr, "screen_fade")) effect[EFFECT_TYPE] = EFFECT_SCREEN_FADE
    else if (equal(typeStr, "screen_shake")) effect[EFFECT_TYPE] = EFFECT_SCREEN_SHAKE
    else if (equal(typeStr, "sprite_burst")) effect[EFFECT_TYPE] = EFFECT_SPRITE_BURST
    else if (equal(typeStr, "beam_ring")) effect[EFFECT_TYPE] = EFFECT_BEAM_RING
    else if (equal(typeStr, "particle_trail")) effect[EFFECT_TYPE] = EFFECT_PARTICLE_TRAIL
    else if (equal(typeStr, "lightning")) effect[EFFECT_TYPE] = EFFECT_LIGHTNING
    else if (equal(typeStr, "combo")) effect[EFFECT_TYPE] = EFFECT_COMBO

    copy(effect[EFFECT_DATA], charsmax(effect[EFFECT_DATA]), data)
    copy(effect[EFFECT_UNLOCK_TYPE], charsmax(effect[EFFECT_UNLOCK_TYPE]), "custom")
    effect[EFFECT_UNLOCK_REQUIREMENT] = 0
    effect[EFFECT_IS_DEFAULT] = 0

    ArrayPushArray(g_killEffects, effect)
    g_effectCount++

    return effect[EFFECT_ID]
}
