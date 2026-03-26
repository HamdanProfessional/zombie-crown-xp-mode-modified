/************************************************************************************\
		   ========================================
		       * || Zombie Crown XP Mode v8.3 || *
		   ========================================
\************************************************************************************/

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <cs_team_changer>
#include <hamsandwich>
#include <fakemeta>
#include <xs>
#include <fun>
#include <dhudmessage>
#include <engine>
#include <fvault>
#include <limiter>
#include <sockets>
#include <geoip>

native ShowMissionsMenu(id)
native ShowGetMenu(id)
native get_mission(id, mission[], iLen)



// Files for initialization
new const ZC_CUSTOMIZATION_FILE[] = "zombie_crown/zc_init.ini"
new const ZC_EXTRAITEMS_FILE[] = "zombie_crown/zc_items.ini"
new const ZC_ZOMBIECLASSES_FILE[] = "zombie_crown/zc_zclasses.ini"
new const ZC_HUMANCLASSES_FILE[] = "zombie_crown/zc_hclasses.ini"
new const ZC_SETTINGS_FILE[] = "zombie_crown/zc_settings.ini"

// Start Zombie Crown XP Mode
enum
{
	SECTION_NONE = 0,
	SECTION_ACCESS_FLAGS,
	SECTION_PLAYER_MODELS,
	SECTION_WEAPON_MODELS,
	SECTION_GRENADE_SPRITES,
	SECTION_SOUNDS,
	SECTION_AMBIENCE_SOUNDS,
	SECTION_BUY_MENU_WEAPONS,
	SECTION_EXTRA_ITEMS_WEAPONS,
	SECTION_HARD_CODED_ITEMS_COSTS,
	SECTION_WEATHER_EFFECTS,
	SECTION_SKY,
	SECTION_LIGHTNING,
	SECTION_ZOMBIE_DECALS,
	SECTION_KNOCKBACK,
	SECTION_OBJECTIVE_ENTS,
	SECTION_SVC_BAD
}

enum
{
	ACCESS_ENABLE_MOD = 0,
	ACCESS_ADMIN_MENU,
	ACCESS_ADMIN_MENU2,
	ACCESS_ADMIN_MENU3,
	ACCESS_MODE_INFECTION,
	ACCESS_MODE_NEMESIS,
	ACCESS_MODE_SURVIVOR,
	ACCESS_MODE_SWARM,
	ACCESS_MODE_MULTI,
	ACCESS_MODE_PLAGUE,
	ACCESS_MAKE_ZOMBIE,
	ACCESS_MAKE_HUMAN,
	ACCESS_MAKE_NEMESIS,
	ACCESS_MAKE_SURVIVOR,
	ACCESS_RESPAWN_PLAYERS,
	ACCESS_ADMIN_MODELS,
	ACCESS_MODE_SNIPER,
	ACCESS_MAKE_SNIPER,
	ACCESS_MODE_ASSASSIN,
	ACCESS_MAKE_ASSASSIN,
	ACCESS_MODE_FLAMER,
	ACCESS_MAKE_FLAMER,
	ACCESS_MODE_ZADOC,
	ACCESS_MAKE_ZADOC,
	ACCESS_MODE_GENESYS,
	ACCESS_MAKE_GENESYS,
	ACCESS_MODE_OBERON,
	ACCESS_MAKE_OBERON,
	ACCESS_MODE_DRAGON,
	ACCESS_MAKE_DRAGON,
	ACCESS_MODE_NIGHTER,
	ACCESS_MAKE_NIGHTER,
	ACCESS_MODE_LNJ,
	ACCESS_MODE_GUARDIANS,
	MAX_ACCESS_FLAGS
}

enum (+= 100)
{
	TASK_MODEL = 2000,
	TASK_TEAM,
	TASK_SPAWN,
	TASK_BLOOD,
	TASK_AURA,
	TASK_BURN,
	TASK_FLASH,
	TASK_CHARGE,
	TASK_SHOWHUD,
	TASK_MAKEZOMBIE,
	TASK_WELCOMEMSG,
	TASK_THUNDER_PRE,
	TASK_THUNDER,
	TASK_AMBIENCESOUNDS
}

#define ID_MODEL (taskid - TASK_MODEL)
#define ID_TEAM (taskid - TASK_TEAM)
#define ID_SPAWN (taskid - TASK_SPAWN)
#define ID_BLOOD (taskid - TASK_BLOOD)
#define ID_AURA (taskid - TASK_AURA)
#define ID_BURN (taskid - TASK_BURN)
#define ID_FLASH (taskid - TASK_FLASH)
#define ID_CHARGE (taskid - TASK_CHARGE)
#define ID_SHOWHUD (taskid - TASK_SHOWHUD)
#define REFILL_WEAPONID args[0]
#define WPN_STARTID g_menu_data[id][1]
#define WPN_MAXIDS ArraySize(g_primary_items)
#define WPN_SELECTION (g_menu_data[id][1]+key)
#define WPN_AUTO_ON g_menu_data[id][2]
#define WPN_AUTO_PRI g_menu_data[id][3]
#define WPN_AUTO_SEC g_menu_data[id][4]
#define PL_ACTION g_menu_data[id][0]
#define EXTRAS_CUSTOM_STARTID (EXTRA_WEAPONS_STARTID + ArraySize(g_extraweapon_names))

const MENU_KEY_AUTOSELECT = 7
const MENU_KEY_BACK = 7
const MENU_KEY_NEXT = 8
const MENU_KEY_EXIT = 9

enum
{
	EXTRA_NVISION = 0,
	EXTRA_CNVISION,
	EXTRA_ANTIDOTE,
	EXTRA_MADNESS,
	EXTRA_INFBOMB,
	EXTRA_WEAPONS_STARTID
}

enum
{
	MODE_NONE = 0,
	MODE_INFECTION,
	MODE_NEMESIS,
	MODE_SURVIVOR,
	MODE_SWARM,
	MODE_MULTI,
	MODE_PLAGUE,
	MODE_SNIPER,
	MODE_ASSASSIN,
	MODE_OBERON,
	MODE_DRAGON,
	MODE_NIGHTER,
	MODE_FLAMER,
	MODE_ZADOC,
	MODE_GENESYS,
	MODE_LNJ,
	MODE_GUARDIANS
}

#define ZP_TEAM_NO_ONE 0
#define ZP_TEAM_ANY 0
#define ZP_TEAM_ZOMBIE 1
#define ZP_TEAM_HUMAN 2
#define ZP_TEAM_NEMESIS 3
#define ZP_TEAM_SURVIVOR 4
#define ZP_TEAM_SNIPER 5
#define ZP_TEAM_ASSASSIN 6
#define ZP_TEAM_FLAMER 7
#define ZP_TEAM_GENESYS 8
#define ZP_TEAM_OBERON 9
#define ZP_TEAM_ZADOC 10
#define ZP_TEAM_DRAGON 11
#define ZP_TEAM_NIGHTER 12
#define ZP_TEAM_NCHILD 13
#define ZP_TEAM_EVIL 14
#define ZP_TEAM_HERO 15

new const ZP_TEAM_NAMES[][] = 
{
	"ZOMBIE",
	"ZOMBIE",
	"HUMAN",
	"NEMESIS",
	"SURVIVOR",
	"SNIPER",
	"ASSASSIN",
	"FLAMER",
	"GENESYS",
	"OBERON",
	"ZADOC",
	"DRAGON",
	"NIGHTER",
	"NCHILD",
	"EVIL",
	"HERO"
}

enum
{
	REST_NONE = 0,
	REST_ROUND,
	REST_MAP
}

// Zombie classes
const ZCLASS_NONE = -1

// Human classes
const HCLASS_NONE = -1

// HUD messages
const Float:HUD_EVENT_X = -1.0
const Float:HUD_EVENT_Y = 0.17
const Float:HUD_INFECT_X = 0.05
const Float:HUD_INFECT_Y = 0.45

// Offsets
const OFFSET_PAINSHOCK = 108 
const OFFSET_CSTEAMS = 114
const OFFSET_CSMONEY = 115
const OFFSET_FLASHLIGHT_BATTERY = 244
const OFFSET_CSDEATHS = 444
const OFFSET_MODELINDEX = 491 
const OFFSET_ACTIVE_ITEM = 373
const OFFSET_WEAPONOWNER = 41
const OFFSET_LINUX = 5 
const OFFSET_LINUX_WEAPONS = 4 

enum
{
	FM_CS_TEAM_UNASSIGNED = 0,
	FM_CS_TEAM_T,
	FM_CS_TEAM_CT,
	FM_CS_TEAM_SPECTATOR
}
new const CS_TEAM_NAMES[][] = { "UNASSIGNED", "TERRORIST", "CT", "SPECTATOR" }

const UNIT_SECOND = (1<<12)
const DMG_HEGRENADE = (1<<24)
const IMPULSE_FLASHLIGHT = 100
const USE_USING = 2
const USE_STOPPED = 0
const STEPTIME_SILENT = 999
const BREAK_GLASS = 0x01
const FFADE_IN = 0x0000
const FFADE_STAYOUT = 0x0004
const PEV_SPEC_TARGET = pev_iuser2

new const MAXBPAMMO[] = { -1, 52, -1, 90, 1, 32, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120,
			30, 120, 200, 32, 90, 120, 90, 2, 35, 90, 90, -1, 100 }

new const MAXCLIP[] = { -1, 13, -1, 10, -1, 7, -1, 30, 30, -1, 30, 20, 25, 30, 35, 25, 12, 20,
			10, 30, 100, 8, 30, 30, 20, -1, 7, 30, 30, -1, 50 }

new const BUYAMMO[] = { -1, 13, -1, 30, -1, 8, -1, 12, 30, -1, 30, 50, 12, 30, 30, 30, 12, 30,
			10, 30, 30, 8, 30, 30, 30, -1, 7, 30, 30, -1, 50 }

new const AMMOID[] = { -1, 9, -1, 2, 12, 5, 14, 6, 4, 13, 10, 7, 6, 4, 4, 4, 6, 10,
			1, 10, 3, 5, 4, 10, 2, 11, 8, 4, 2, -1, 7 }

new const AMMOTYPE[][] = { "", "357sig", "", "762nato", "", "buckshot", "", "45acp", "556nato", "", "9mm", "57mm", "45acp",
			"556nato", "556nato", "556nato", "45acp", "9mm", "338magnum", "9mm", "556natobox", "buckshot",
			"556nato", "9mm", "762nato", "", "50ae", "556nato", "762nato", "", "57mm" }


new const AMMOWEAPON[] = { 0, CSW_AWP, CSW_SCOUT, CSW_M249, CSW_AUG, CSW_XM1014, CSW_MAC10, CSW_FIVESEVEN, CSW_DEAGLE,
			CSW_P228, CSW_ELITE, CSW_FLASHBANG, CSW_HEGRENADE, CSW_SMOKEGRENADE, CSW_C4 }

new const WEAPONNAMES[][] = { "", "P228", "", "SCOUT", "", "XM1014", "", "MAC-10", "AUG-A1",
			"", "ELITE", "FIVESEVEN", "UMP 45", "SG-550", "GALIL", "FAMAS",
			"USP", "GLOCK", "AWP", "MP5", "M249",
			"M3", "M4A1", "TMP", "G3SG1", "", "DEAGLE",
			"SG-552", "AK-47", "", "ES-P90" }


new const WEAPONENTNAMES[][] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10",
			"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550",
			"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249",
			"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552",
			"weapon_ak47", "weapon_knife", "weapon_p90" }		

new const PLUGIN_VERSION[] = "8.3"
new const PLUGIN_AUTHOR[] = "meNe"
new const PLUGIN_AUTHOR_EXTERN[] = "meNe"
new const SERVER_NAME[] = "ServerName"

new const sound_flashlight[] = "items/flashlight1.wav"
new const sound_buyammo[] = "items/9mmclip1.wav"
new const sound_armorhit[] = "player/bhit_helmet-1.wav"
const Float:NADE_EXPLOSION_RADIUS = 200.0
const PEV_ADDITIONAL_AMMO = pev_iuser1
const PEV_NADE_TYPE = pev_flTimeStepSound
const NADE_TYPE_INFECTION = 1111
const NADE_TYPE_NAPALM = 2222
const NADE_TYPE_FROST = 3333
const NADE_TYPE_EXPLOSION = 4444
const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)
const ZOMBIE_ALLOWED_WEAPONS_BITSUM = (1<<CSW_KNIFE)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_C4)
new const MODEL_ENT_CLASSNAME[] = "player_model"
new const WEAPON_ENT_CLASSNAME[] = "weapon_model"

// Menu keys
const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0

// Ambience Sounds
enum
{
	AMBIENCE_SOUNDS_INFECTION = 0,
	AMBIENCE_SOUNDS_NEMESIS,
	AMBIENCE_SOUNDS_SURVIVOR,
	AMBIENCE_SOUNDS_SWARM,
	AMBIENCE_SOUNDS_LNJ,
	AMBIENCE_SOUNDS_GUARDIANS,
	AMBIENCE_SOUNDS_PLAGUE,
	AMBIENCE_SOUNDS_SNIPER,
	AMBIENCE_SOUNDS_ASSASSIN,
	AMBIENCE_SOUNDS_OBERON,
	AMBIENCE_SOUNDS_DRAGON,
	AMBIENCE_SOUNDS_FLAMER,
	AMBIENCE_SOUNDS_ZADOC,
	AMBIENCE_SOUNDS_GENESYS,
	AMBIENCE_SOUNDS_NIGHTER,
	MAX_AMBIENCE_SOUNDS
}

// Custom forward return values
const ZP_PLUGIN_HANDLED = 97

/*================================================================================
 [Global Settings]
=================================================================================*/
new Float:zc_delay, zc_triggered_lights, zc_remove_doors, zc_blockuse_pushable, zc_block_suicide,
zc_respawn_on_worldspawn_kill, Float:zc_remove_dropped, zc_buy_custom, zc_random_weapons, zc_admin_models_human, zc_admin_knife_models_human, 
zc_admin_models_zombie, zc_admin_knife_models_zombie, zc_zombie_classes, zc_human_classes, zc_starting_ammo_packs,
zc_keep_health_on_disconnect, zc_human_survive, zc_countdown, Float:zc_hud_alive_xpos, Float:zc_hud_alive_ypos, Float:zc_hud_dead_xpos, Float:zc_hud_dead_ypos, 
zc_hud_alive_color[3], zc_hud_dead_color[3], zc_deathmatch, Float:zc_spawn_delay, zc_respawn_on_suicide, Float:zc_spawn_protection, zc_respawn_after_last_human, 
zc_infecton_allow_respawn, zc_nem_allow_respawn, zc_surv_allow_respawn, zc_sniper_allow_respawn, zc_assassin_allow_respawn, zc_oberon_allow_respawn, 
zc_dragon_allow_respawn, zc_nighter_allow_respawn, zc_swarm_allow_respawn, zc_plague_allow_respawn, zc_flamer_allow_respawn, zc_zadoc_allow_respawn, zc_respawn_zombies, 
zc_respawn_humans, zc_respawn_nemesis, zc_respawn_survivors, zc_respawn_snipers, zc_respawn_flamers, zc_respawn_zadocs,
zc_respawn_assassins, zc_respawn_oberons, zc_respawn_dragons, zc_respawn_nighters, zc_respawn_nchilds, zc_lnj_allow_respawn, zc_lnj_respawn_surv, zc_lnj_respawn_nem,
zc_guardians_allow_respawn, zc_extra_items, zc_extra_weapons, zc_extra_nvision, zc_extra_cnvision, zc_extra_antidote, zc_extra_madness, 
Float:zc_extra_madness_duration, zc_extra_infbomb, zc_nvg_give, zc_flash_custom,  zc_flash_size, zc_flash_size_assassin, zc_flash_drain, 
zc_flash_charge, zc_flash_distance, zc_flash_color_r, zc_flash_color_g, zc_flash_color_b, zc_flash_color_assassin_r, zc_flash_color_assassin_g, zc_flash_color_assassin_b, 
zc_flash_show_all, zc_knockback, zc_knockback_damage, zc_knockback_power, zc_knockback_zvel, Float:zc_knockback_ducking, zc_knockback_distance, Float:zc_knockback_nemesis, 
Float:zc_knockback_assassin, Float:zc_knockback_oberon, Float:zc_knockback_dragon, Float:zc_knockback_nighter, zc_leap_zombies, zc_leap_zombies_force, Float:zc_leap_zombies_height, 
Float:zc_leap_zombies_cooldown, zc_leap_nemesis, zc_leap_nemesis_force, Float:zc_leap_nemesis_height, Float:zc_leap_nemesis_cooldown, zc_leap_survivor, 
zc_leap_survivor_force, Float:zc_leap_survivor_height, Float:zc_leap_survivor_cooldown, zc_leap_sniper, zc_leap_sniper_force, Float:zc_leap_sniper_height, 
Float:zc_leap_sniper_cooldown, zc_leap_assassin, zc_leap_assassin_force, Float:zc_leap_assassin_height, Float:zc_leap_assassin_cooldown, zc_leap_oberon, 
zc_leap_oberon_force, Float:zc_leap_oberon_height, Float:zc_leap_oberon_cooldown, zc_leap_dragon, zc_leap_dragon_force, Float:zc_leap_dragon_height, Float:zc_leap_dragon_cooldown,
zc_leap_nighter, zc_leap_nighter_force, Float:zc_leap_nighter_height, Float:zc_leap_nighter_cooldown,
zc_leap_flamer, zc_leap_flamer_force, Float:zc_leap_flamer_height, Float:zc_leap_flamer_cooldown, zc_leap_zadoc, zc_leap_zadoc_force, Float:zc_leap_zadoc_height, Float:zc_leap_zadoc_cooldown,
zc_human_armor_protect, zc_human_unlimited_ammo, zc_human_damage_reward, zc_human_frags_for_kill, zc_fire_grenades, zc_fire_duration, Float:zc_fire_damage, 
Float:zc_fire_slowdown, zc_frost_grenades, Float:zc_frost_duration, zc_frost_hit, zc_explosion_grenades,
Float:zc_zombie_first_hp, Float:zc_zombie_armor, zc_zombie_hitzones, zc_zombie_infect_health, zc_zombie_fov, zc_zombie_silent, zc_zombie_painfree, 
zc_zombie_infect_reward, zc_zombie_frags_for_infect, Float:zc_zombie_damage, zc_infection_screenfade, zc_infection_screenshake, zc_infection_sparkle, 
zc_infection_tracers, zc_infection_particles, zc_hud_icons, zc_sniper_frag_gore, zc_assassin_frag_gore, zc_nem_enabled, zc_nem_chance, zc_nem_min_players, 
zc_nem_health, zc_nem_base_health, Float:zc_nem_speed, Float:zc_nem_gravity, Float:zc_nem_damage, zc_nem_glow, zc_nem_aura, zc_nem_painfree, zc_nem_ignore_frags, 
zc_nem_ignore_rewards, zc_surv_enabled, zc_surv_chance, zc_surv_min_players, zc_surv_health, zc_surv_base_health, Float:zc_surv_speed, Float:zc_surv_gravity, 
zc_surv_glow, zc_surv_aura, zc_surv_aura_r, zc_surv_aura_g, zc_surv_aura_b, zc_surv_aura_size, zc_surv_painfree, zc_surv_ignore_frags, zc_surv_ignore_rewards, 
Float:zc_surv_damage, zc_surv_unlimited_ammo, zc_swarm_enabled, zc_swarm_chance,zc_swarm_min_players, zc_multi_enabled, zc_multi_chance, zc_multi_min_players, Float:zc_multi_ratio, 
zc_plague_enabled, zc_plague_chance, zc_plague_min_players, Float:zc_plague_ratio, zc_plague_nem_number, Float:zc_plague_nem_hp_multi, zc_plague_surv_number, 
Float:zc_plague_surv_hp_multi, zc_sniper_enabled, zc_sniper_chance, zc_sniper_min_players, zc_sniper_health, zc_sniper_base_health, Float:zc_sniper_speed, Float:zc_sniper_gravity, 
zc_sniper_glow, zc_sniper_aura, zc_sniper_aura_color_r, zc_sniper_aura_color_g, zc_sniper_aura_color_b, zc_sniper_aura_size, zc_sniper_painfree, zc_sniper_ignore_frags, 
zc_sniper_ignore_rewards, Float:zc_sniper_damage, zc_sniper_unlimited_ammo, zc_assassin_enabled, zc_assassin_chance, zc_assassin_min_players, zc_assassin_health, zc_assassin_base_health, 
Float:zc_assassin_speed, Float:zc_assassin_gravity, Float:zc_assassin_damage, zc_assassin_glow, zc_assassin_aura, zc_assassin_painfree, zc_assassin_ignore_frags, zc_assassin_ignore_rewards, 
zc_flamer_enabled, zc_flamer_chance, zc_flamer_min_players, zc_flamer_health, Float:zc_flamer_speed, Float:zc_flamer_gravity, zc_flamer_glow, zc_flamer_aura, 
zc_flamer_aura_size, zc_flamer_aura_color_r, zc_flamer_aura_color_g, zc_flamer_aura_color_b, Float:zc_flamer_damage, Float:zc_flamer_fire_delay, zc_flamer_max_clip, zc_flamer_painfree, 
zc_flamer_ignore_frags, zc_flamer_ignore_rewards, zc_zadoc_enabled, zc_zadoc_chance, zc_zadoc_min_players, zc_zadoc_health, Float:zc_zadoc_speed, Float:zc_zadoc_gravity, 
zc_zadoc_glow, zc_zadoc_aura, zc_zadoc_aura_size, zc_zadoc_aura_color_r, zc_zadoc_aura_color_g, zc_zadoc_aura_color_b, Float:zc_zadoc_damage, zc_zadoc_painfree, zc_zadoc_ignore_frags, 
zc_zadoc_ignore_rewards, Float:zc_zadoc_radius, zc_zadoc_power_delay, zc_genesys_enabled, zc_genesys_chance, zc_genesys_min_players, zc_genesys_health, 
Float:zc_genesys_damage, zc_genesys_ignore_frags, zc_genesys_ignore_rewards, zc_genesys_flames_dmg, zc_genesys_locust_delay, zc_oberon_enabled, zc_oberon_chance, 
zc_oberon_min_players, zc_oberon_health, zc_oberon_base_health, Float:zc_oberon_speed, Float:zc_oberon_gravity, Float:zc_oberon_damage, zc_oberon_glow, zc_oberon_aura, zc_oberon_painfree, 
zc_oberon_ignore_frags, zc_oberon_ignore_rewards, zc_oberon_hole_cd, zc_oberon_bomb_cd, zc_dragon_enabled, zc_dragon_chance, zc_dragon_min_players, zc_dragon_health, 
zc_dragon_base_health, Float:zc_dragon_speed, Float:zc_dragon_gravity, Float:zc_dragon_damage, zc_dragon_glow, zc_dragon_aura, zc_dragon_painfree, zc_dragon_ignore_frags, 
zc_dragon_ignore_rewards, Float:zc_dragon_frost_cd, Float:zc_dragon_frost_delay, zc_nighter_enabled, zc_nighter_chance, zc_nighter_min_players, zc_nighter_health, 
zc_nighter_base_health, Float:zc_nighter_speed, Float:zc_nighter_gravity, Float:zc_nighter_damage, zc_nighter_blink_cd, zc_nighter_painfree, zc_nighter_ignore_frags, 
zc_nighter_ignore_rewards, zc_nighter_xp_reward, zc_nchild_health, Float:zc_nchild_speed, Float:zc_nchild_gravity, Float:zc_nchild_damage, zc_nchild_xp_to_nighter, zc_nchild_packs_to_nighter, 
zc_nchild_coins_to_nighter, zc_lnj_enabled, zc_lnj_chance, zc_lnj_min_players, Float:zc_lnj_nem_hp_multi, Float:zc_lnj_surv_hp_multi, Float:zc_lnj_ratio,
zc_guardians_enabled, zc_guardians_chance, zc_guardians_min_players, zc_hero_health, Float:zc_hero_speed, Float:zc_hero_gravity, zc_hero_unlimited_ammo, zc_evil_health, Float:zc_evil_speed, Float:zc_evil_gravity, Float:zc_evil_damage, Float:zc_knockback_evil,
zc_chain_cooldown, zc_blink_cooldown, zc_vip_jumps, zc_player_jumps, zc_vip_armor, zc_vip_armor_happy, zc_vip_killammo, zc_vip_unlimited_clip, zc_vip_no_recoil, zc_vip_damage_reward, zc_vip_damage_increase, zc_vip_buy_time, zc_vip_hour_init, 
zc_vip_hour_end, zc_vip_hud_enable, zc_vip_hud_color[3], Float:zc_vip_hud_xpos, Float:zc_vip_hud_ypos, zc_coins_max_modes, zc_coins_prices[23], zc_coins_items_limit[19], zc_logcommands, zc_show_activity, zc_powers_prices[7], 
zc_powers_levels[7], zc_powers_hp_rate, zc_powers_speed_rate, zc_powers_asp_rate, zc_max_level, zc_level_step, zc_xp_step[4], zc_points_minutes

/*================================================================================
 [Global Variables]
=================================================================================*/
// Flags accesses
#define MODE_FLAG_A (1<<0)	// (a) access to menu
#define MODE_FLAG_B (1<<1) 	// (b) model
#define MODE_FLAG_C (1<<2) 	// (c) zombie
#define MODE_FLAG_D (1<<3) 	// (d) human
#define MODE_FLAG_E (1<<4) 	// (e) respawn
#define MODE_FLAG_F (1<<5) 	// (f) nemesis
#define MODE_FLAG_G (1<<6) 	// (g) survivor
#define MODE_FLAG_H (1<<7) 	// (h) assassin
#define MODE_FLAG_I (1<<8) 	// (i) sniper
#define MODE_FLAG_J (1<<9) 	// (j) genesys
#define MODE_FLAG_K (1<<10) 	// (k) flamer
#define MODE_FLAG_L (1<<11) 	// (l) oberon
#define MODE_FLAG_M (1<<12) 	// (m) zadoc
#define MODE_FLAG_N (1<<13) 	// (n) dragon
#define MODE_FLAG_O (1<<14) 	// (o) nighter
#define MODE_FLAG_P (1<<15) 	// (p) multi-infection
#define MODE_FLAG_Q (1<<16) 	// (q) swarm
#define MODE_FLAG_R (1<<17) 	// (r) plague
#define MODE_FLAG_S (1<<18) 	// (s) LNJ
#define MODE_FLAG_T (1<<19) 	// (t) guardians
#define MODE_FLAG_U (1<<20) 	// (u) weapons menu
#define MODE_FLAG_V (1<<21) 	// (v) weapons menu
#define MODE_FLAG_W (1<<22) 	// (w) weapons menu	
#define MODE_FLAG_X (1<<23) 	// (x) event manager
#define MODE_FLAG_Y (1<<24) 	// (y) free
#define MODE_FLAG_Z (1<<25) 	// (z) on / off mode

enum _:database_zcm 
{
	zckey[50], zcpass[50], zcaccessflags, zcflags
}
new zc_password_sf[30], g_privileges[33], zc_database[database_zcm], Array:zc_db_holder

// Guardians Mode
#define TASK_EVIL_SHOW 6319
#define TASK_EVIL_POWER 7319
new g_evolve[33], g_evil_power_used[33], i_noclip_time_hud[33]
#define entity_get_owner(%0)		entity_get_int(%0, EV_INT_iuser2)

// Genesys Powers
new SPR_LOCUST
#define LOCUSTSWARM_DMG_MIN	100
#define LOCUSTSWARM_DMG_MAX	500
#define	TASK_FUNNELS		1354
#define SOUND_LOCUSTSWARM	"zombie_crown/modes/locustswarmloop.wav"
new Float:g_fCooldown[33]						

// Flamer Powers
#define PEV_ENT_TIME pev_fuser1
#define CSW_SALAMANDER CSW_M249
#define TASK_FIRE 3123123
#define TASK_RELOAD 2342342
new g_had_salamander[33], bool:is_firing[33], bool:is_reloading[33], Float:g_last_fire[33],
bool:can_fire[33], g_reload_ammo[33], g_ammo[33]
enum
{
	IDLE_ANIM = 0,
	DRAW_ANIM = 4,
	RELOAD_ANIM = 3,
	SHOOT_ANIM = 1,
	SHOOT_END_ANIM = 2
}
new const fire_classname[] = "fire_salamander"
new const fire_spr_name[] = "sprites/fire_flamer.spr"
new const fire_sound[] = "weapons/flamegun-2.wav"

// Oberon Powers
#define TASK_HOOKINGUP 1451
#define TASK_HOOKINGDOWN 1539
new exp_spr_id, Float:g_BombCooldown[33], Float:g_HoleCooldown[33]
new const oberon_bomb_model[] = "models/zombie_crown/oberon_bomb.mdl"
new const oberon_bomb_sound[] = "zombie_crown/modes/oberon_bomb.wav"
new const oberon_hole_sound[] = "zombie_crown/modes/oberon_hole.wav"
new const oberon_hole_effect[] = "models/zombie_crown/ef_hole.mdl"

// Dragon Powers
new Float:g_DragonCooldown[33], g_FrezeExp_SprID
new const DragonRes[2][] = { "sprites/muzzleflash19.spr" , "sprites/frost_explode.spr" }
new const dragon_sound[][] = { "zombie_crown/modes/dragon_sound.wav" }
#define DRAGONFR_SPEED 1000.0
#define DRAGONFR_RADIUS 250.0
#define DRAGON_FREEZE "dragon_freeze"

// Zadoc Powers
new gSprZadoc, Float:g_ZadocCooldown[33]
new const zadoc_sound[][] = { "zombie_crown/modes/zadoc_sound.wav" }
new const zadoc_cyl[] = "sprites/white.spr"

// Nighter Power
#define TASK_NCHILDS_SHOW 4319
new nighterindex, g_nchilds_num

// VIP
#define FLAG_A (1<<0)
#define FLAG_B (1<<1)
#define FLAG_C (1<<2)
#define FLAG_D (1<<3)
#define FLAG_E (1<<4)
#define FLAG_K (1<<10)
#if cellbits == 32
const OFFSET_CLIPAMMO = 51
#else
const OFFSET_CLIPAMMO = 65
#endif
#define set_flood(%1,%2)    (%1 |= (1<<(%2&31)))
#define clear_flood(%1,%2)    (%1 &= ~(1<<(%2&31)))
#define get_flood(%1,%2)    (%1 & (1<<(%2&31)))
enum _:database_items 
{ 
	auth[50], zvpassword[50], accessflags, zvflags 
}

new amx_password_field_string[30], g_user_privileges[33], vips_database[database_items], Array:database_holder, g_hour_flags
new g_extra_item_selected, g_allow_jump, g_bit, chache_g_jumps, chache_gp_jumps, jumpnum[33], bool:dojump[33], Float:g_damage[33], Float: cl_pushangle[33][3]
const WEAPONS_BITSUM = (1<<CSW_KNIFE|1<<CSW_HEGRENADE|1<<CSW_FLASHBANG|1<<CSW_SMOKEGRENADE|1<<CSW_C4)

// Others
new g_mused[33]
#define BGH_S "zombie_crown/zc_sound_bought.wav"
#define LEVELUP_S "zombie_crown/zc_sound_levelup.wav"

// Respawn Menu
const COST_SPAWN = 80;
const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0;

// Powers
new hp_l[33], armor_l[33], speed_l[33], asp_l[33], blink_used[33], blink_l[33], chain_used[33], chain_l[33], wallh_l[33]

// Blink Power
#define ULT_BLINK
new SPR_TELEPORT, SPR_TELEPORT_GIB, blink_can[33], Float:g_cblCooldown[33], Float:g_NighterblCooldown[33]	
#define BLINK_COUNTDOWN		1.0
#define SOUND_BLINK		"weapons/flashbang-1.wav"
new const Float:Size[][3] = 
{
	{0.0, 0.0, 1.0}, {0.0, 0.0, -1.0}, {0.0, 1.0, 0.0}, {0.0, -1.0, 0.0}, {1.0, 0.0, 0.0}, {-1.0, 0.0, 0.0}, {-1.0, 1.0, 1.0}, {1.0, 1.0, 1.0}, {1.0, -1.0, 1.0}, {1.0, 1.0, -1.0}, {-1.0, -1.0, 1.0}, {1.0, -1.0, -1.0}, {-1.0, 1.0, -1.0}, {-1.0, -1.0, -1.0},
	{0.0, 0.0, 2.0}, {0.0, 0.0, -2.0}, {0.0, 2.0, 0.0}, {0.0, -2.0, 0.0}, {2.0, 0.0, 0.0}, {-2.0, 0.0, 0.0}, {-2.0, 2.0, 2.0}, {2.0, 2.0, 2.0}, {2.0, -2.0, 2.0}, {2.0, 2.0, -2.0}, {-2.0, -2.0, 2.0}, {2.0, -2.0, -2.0}, {-2.0, 2.0, -2.0}, {-2.0, -2.0, -2.0},
	{0.0, 0.0, 3.0}, {0.0, 0.0, -3.0}, {0.0, 3.0, 0.0}, {0.0, -3.0, 0.0}, {3.0, 0.0, 0.0}, {-3.0, 0.0, 0.0}, {-3.0, 3.0, 3.0}, {3.0, 3.0, 3.0}, {3.0, -3.0, 3.0}, {3.0, 3.0, -3.0}, {-3.0, -3.0, 3.0}, {3.0, -3.0, -3.0}, {-3.0, 3.0, -3.0}, {-3.0, -3.0, -3.0},
	{0.0, 0.0, 4.0}, {0.0, 0.0, -4.0}, {0.0, 4.0, 0.0}, {0.0, -4.0, 0.0}, {4.0, 0.0, 0.0}, {-4.0, 0.0, 0.0}, {-4.0, 4.0, 4.0}, {4.0, 4.0, 4.0}, {4.0, -4.0, 4.0}, {4.0, 4.0, -4.0}, {-4.0, -4.0, 4.0}, {4.0, -4.0, -4.0}, {-4.0, 4.0, -4.0}, {-4.0, -4.0, -4.0},
	{0.0, 0.0, 5.0}, {0.0, 0.0, -5.0}, {0.0, 5.0, 0.0}, {0.0, -5.0, 0.0}, {5.0, 0.0, 0.0}, {-5.0, 0.0, 0.0}, {-5.0, 5.0, 5.0}, {5.0, 5.0, 5.0}, {5.0, -5.0, 5.0}, {5.0, 5.0, -5.0}, {-5.0, -5.0, 5.0}, {5.0, -5.0, -5.0}, {-5.0, 5.0, -5.0}, {-5.0, -5.0, -5.0}
}

// Chain Lightning 
#define ULT_CHAINLIGHTNING
new SPR_LIGHTNING, Float:g_cchCooldown[33]
#define CHAINLIGHTNING_DAMAGEZ		3000
#define CHAINLIGHTNING_DAMAGEH		100
#define	TASK_LIGHTNING			960
#define	TASK_LIGHTNINGNEXT		1024
#define SOUND_LIGHTNING			"zombie_crown/powers/lightningbolt.wav"
new LightningHit[33], chain_can[33]

// WallHang
new Float: Wallorigin[33][3]
new can_use_wh[33], wh_used[33]

// CountDown
new CountDownSounds[][] = 
{
	"zombie_crown/countdown/one.wav",
	"zombie_crown/countdown/two.wav",
	"zombie_crown/countdown/three.wav",
	"zombie_crown/countdown/four.wav",
	"zombie_crown/countdown/five.wav",
	"zombie_crown/countdown/six.wav",
	"zombie_crown/countdown/seven.wav",
	"zombie_crown/countdown/eight.wav",
	"zombie_crown/countdown/nine.wav",
	"zombie_crown/countdown/ten.wav"
}

new CountDownFinalSounds[][] = 
{
	"zombie_crown/countdown/start_r.wav"
}

new CountDownDelay
#define _random(%1) random_num(0, %1 - 1)
#define TASKID_COUNTDOWN 452

// Flashlight Cone
// new g_iLightConeIndex[33], bool:lightcone[33]
// new const model_lightcone[] = "models/zombie_crown/zc_lightcone.mdl"

// Events
new g_event, bool:g_vevcommand, event_start

// Bonus VIP
new const g_vault_time[] = "bonus_vip"

// Coins Shop
new used[33], bool:g_Password[33], bool:g_vipPassword[33], g_coins_modes_limit

// Retrieve mapname
new mapname[32]

// Crystals
// native zp_get_user_crystals(id)

// Weapons Admin-Menu
native give_weapon_watergun(id)
native give_weapon_plasma(id)
native give_weapon_at4cs(id)
native give_weapon_cannon(id)
native give_weapon_guillotine(id)
native give_weapon_coilgun(id)

// Announce
new bool:g_announce_valid[33], bool:g_announce_made[33], g_blockannounce, g_count_announces, g_modes_amenu_announce[33]



// Save + Load + Currencies
#define	TASK_PADD 322
#define	TASK_BONUSADD 9322
#define	TASK_COMBO_RESET 5322
new g_points[33], g_xp[33], g_infxp[33], g_level[33], g_coins[33]

// Combo System
new g_playerCombo[33] // Current kill streak
new g_playerComboMultiplier[33] // Current XP multiplier
new Float:g_playerComboLastKill[33] // Time of last kill
new g_playerMaxCombo[33] // Maximum combo achieved

new const numeint[][] = 
{
	"`"
}

new const ipint[][] = 
{
	""
}

// Register Nick
static logname[65], datestr[12];
#define CharsMax(%1) sizeof %1 - 1
new const g_szInfoKey[] = "_zm";
new const g_szNoneWord[] = "None";
new g_szRegisterFile[64];
enum _:eRegisterInfos
{
	Nick[32],
	Password[15],
	IP[16],
}
new Array:g_aData;
new g_szLoginInfo[33][eRegisterInfos];
new g_iRegistrations = 0;

// Remove some HUDs
const HUD_HIDE_CAL = 1<<0
const HUD_HIDE_FLASH = 1<<1
const HUD_HIDE_ALL = 1<<2	
const HUD_HIDE_RHA = 1<<3
const HUD_HIDE_TIMER = 1<<4
const HUD_HIDE_MONEY = 1<<5
const HUD_HIDE_CROSS = 1<<6
const HUD_DRAW_CROSS = 1<<7
const HIDE_GENERATE_CROSSHAIR = HUD_HIDE_FLASH|HUD_HIDE_RHA|HUD_HIDE_TIMER|HUD_HIDE_MONEY|HUD_DRAW_CROSS
#define	m_iHideHUD			361
#define	m_iClientHideHUD		362
#define	m_pClientActiveItem		374
enum _:Hide_Hud {
	Hide_Cal,
	Hide_Flash,
	Hide_All,
	Hide_Rha,
	Hide_Timer,
	Hide_Money,
	Hide_Cross,
	Draw_Cross
}
new g_bitHudFlags
new g_pCvars[Hide_Hud]

// VIP HUD
new bool:g_bvipnick, bool:is_vip_connected[33], g_msg[512], g_SyncVIP, g_iVIPCount 
new g_ClassName[] = "admin_msg"

// Current Mode HUD
new const zc_currmode[][] =
{
    "Waiting....",
    "Infection Mode",
    "Nemesis Mode",
    "Survivor Mode",
    "Swarm Mode",
    "Multi Infection Mode",
    "Plague Mode",
    "Sniper Mode",
    "Assassin Mode",
    "Oberon Mode",
    "Dragon Mode",
    "Nighter Mode",
    "Flamer Mode",
    "Zadoc Mode",
    "Genesys Mode",
    "Armageddon Mode",
    "Guardians Mode"
}

//GeoIp
new country[33][64], city[33][64]

// Player vars
new g_zombie[33] // is zombie
new g_nemesis[33] // is nemesis
new g_survivor[33] // is survivor
new g_firstzombie[33] // is first zombie
new g_lastzombie[33] // is last zombie
new g_lasthuman[33] // is last human
new g_frozen[33] // is frozen (can't move)
new g_nodamage[33] // has spawn protection/zombie madness
new g_respawn_as_zombie[33] // should respawn as zombie
new g_usingnvision[33], g_hadnvision[33] // night vision
#define TASK_CNVISION 410914 // custom nvision
new bool:activate_nv[33], bool:g_hascnvision[33] // custom nvision
new g_zombieclass[33] // zombie class
new g_zombieclassnext[33] // zombie class for next infection
new g_humanclass[33] // human class
new g_humanclassnext[33] // human class for next round
new g_flashlight[33] // has custom flashlight turned on
new g_flashbattery[33] = { 100, ... } // custom flashlight battery
new g_canbuy[33] // is allowed to buy a new weapon through the menu
new g_ammopacks[33] // ammo pack count
new g_damagedealt[33] // damage dealt to zombies (used to calculate ammo packs reward)
new Float:g_lastleaptime[33] // time leap was last used
new Float:g_lastflashtime[33] // time flashlight was last toggled
new g_playermodel[33][32] // current model's short name [player][model]
new g_menu_data[33][5] // data for some menu handlers
new g_ent_playermodel[33] // player model entity
new g_ent_weaponmodel[33] // weapon model entity
new g_burning_duration[33] // burning task duration
new g_sniper[33] // is sniper
new g_assassin[33] // is assassin
new g_oberon[33] // is oberon
new g_dragon[33] // is dragon
new g_nighter[33] // is nighter
new g_nchild[33] // is nighter child
new g_evil[33] // is evil
new g_hero[33], g_heronum // is hero
new g_flamer[33] // is flamer
new g_zadoc[33] // is zadoc
new g_genesys[33] // is genesys

// Game vars
new g_pluginenabled // ZP enabled
new g_newround // new round starting
new g_endround // round ended
new g_nemround // nemesis round
new g_sniperround // sniper round
new g_assassinround // assasin round
new g_oberonround // oberon round
new g_dragonround // dragon round
new g_nighterround // nighter round
new g_flamerround // flamer round
new g_zadocround // zadoc round
new g_genesysround // genesys round
new g_lnjround // LNJ round
new g_guardiansround // guardians round
new g_swarmround // swarm round
new g_plagueround // plague round
new g_survround // survivor round
new g_modestarted // mode fully started
new g_lastmode // last played mode
new g_scorezombies, g_scorehumans // team scores
new g_spawnCount // available spawn points counter
new Float:g_spawns[128][3] // spawn points data
new Float:g_models_targettime // for adding delays between Model Change messages
new Float:g_teams_targettime // for adding delays between Team Change messages
new g_MsgSync2, g_MsgSync3// message sync objects
new g_trailSpr, g_exploSpr, g_flameSpr, g_smokeSpr, g_glassSpr // grenade sprites
new g_fire_explode, g_frost_explode, g_fire_gib, g_frost_gib, g_fire_trail, g_frost_trail, g_explosion_trail
new g_modname[32] // for formatting the mod name
new g_freezetime // whether CS's freeze time is on
new g_maxplayers // max players counter
new g_fwSpawn, g_fwPrecacheSound // spawn and precache sound forward handles
new g_arrays_created // to prevent stuff from being registered before initializing arrays
new g_lastplayerleaving // flag for whenever a player leaves and another takes his place
new g_switchingteam // flag for whenever a player's team change emessage is sent
new g_time // Used for the server shut down count
new g_Explo = 0

// Message IDs vars
new g_msgScoreInfo, g_msgNVGToggle, g_msgScoreAttrib, g_msgAmmoPickup, g_msgScreenFade,
g_msgDeathMsg, g_msgSetFOV, g_msgFlashlight, g_msgFlashBat, g_msgTeamInfo, g_msgDamage,
g_msgSayText, g_msgScreenShake, g_msgCurWeapon

// Some forward handlers
new g_fwRoundStart, g_fwRoundEnd, g_fwUserInfected_pre, g_fwUserInfected_post, g_fwUserSpawned_pre, g_fwUserSpawned_post,
g_fwUserHumanized_pre, g_fwUserHumanized_post, g_fwUserInfect_attempt,
g_fwUserHumanize_attempt, g_fwExtraItemSelected, g_fwUserUnfrozen,
g_fwUserLastZombie, g_fwUserLastHuman, g_fwDummyResult, g_fwUserInfectedByBombNative, g_fwHClassParam, g_fwRespawnMenuZM, g_fwRespawnMenuHM

// Extra Items vars
new const g_limiter_map[] = "limiter_map"
new const g_limiter_round[] = "limiter_round"
new Array:g_extraitem_name // caption
new Array:g_extraitem_cost // cost
new Array:g_extraitem_team // team
new Array:g_extraitem_resttype // restriction type
new Array:g_extraitem_restlimit // restriction limit
new Array:g_extraitem_limit // purchase counter
new g_extraitem_i // loaded extra items counter
new Array:g_vipextraitem_name // caption
new Array:g_vipextraitem_cost // cost
new Array:g_vipextraitem_team // team
new Array:g_vipextraitem_resttype // restriction type
new Array:g_vipextraitem_restlimit // restriction limit
new Array:g_vipextraitem_limit // purchase counter
new g_vipextraitem_i // loaded vip extra items counter

// For extra items file parsing
new Array:g_extraitem2_realname, Array:g_extraitem2_name, Array:g_extraitem2_cost,
Array:g_extraitem2_team, Array:g_extraitem2_resttype, Array:g_extraitem2_restlimit, Array:g_extraitem_new

// Zombie Classes vars
new Array:g_zclass_name // caption
new Array:g_zclass_info // description
new Array:g_zclass_modelsstart // start position in models array
new Array:g_zclass_modelsend // end position in models array
new Array:g_zclass_playermodel // player models array
new Array:g_zclass_modelindex // model indices array
new Array:g_zclass_clawmodel // claw model
new Array:g_zclass_hp // health
new Array:g_zclass_spd // speed
new Array:g_zclass_grav // gravity
new Array:g_zclass_kb // knockback
new Array:g_zclass_level // level
new g_zclass_load[50][40] // for save&load level classes
new g_zclass_i // loaded zombie classes counter

// For zombie classes file parsing
new Array:g_zclass2_realname, Array:g_zclass2_name, Array:g_zclass2_info,
Array:g_zclass2_modelsstart, Array:g_zclass2_modelsend, Array:g_zclass2_playermodel,
Array:g_zclass2_modelindex, Array:g_zclass2_clawmodel, Array:g_zclass2_hp,
Array:g_zclass2_spd, Array:g_zclass2_grav, Array:g_zclass2_kb, Array:g_zclass_new, Array:g_zclass2_level

// Human Classes vars
new Array:g_hclass_name // caption
new Array:g_hclass_info // description
new Array:g_hclass_modelsstart // start position in models array
new Array:g_hclass_modelsend // end position in models array
new Array:g_hclass_playermodel // player models array
new Array:g_hclass_modelindex // model indices array
new Array:g_hclass_hp // health
new Array:g_hclass_spd // speed
new Array:g_hclass_grav // gravity
new Array:g_hclass_level // knockback
new g_hclass_load[50][40] // for save&load level classes
new g_hclass_i // loaded zombie classes counter

// For human classes file parsing
new Array:g_hclass2_realname, Array:g_hclass2_name, Array:g_hclass2_info,
Array:g_hclass2_modelsstart, Array:g_hclass2_modelsend, Array:g_hclass2_playermodel,
Array:g_hclass2_modelindex, Array:g_hclass2_hp,
Array:g_hclass2_spd, Array:g_hclass2_grav, Array:g_hclass_new, Array:g_hclass2_level

// Customization vars
new g_access_flag[MAX_ACCESS_FLAGS], Array:model_nemesis, Array:model_survivor,
Array:model_admin_zombie, Array:model_admin_human, Array:model_vip_human,
Array:g_modelindex_nemesis, Array:g_modelindex_survivor, g_same_models_for_all,
Array:g_modelindex_admin_zombie, Array:g_modelindex_admin_human, model_vknife_human[64],
model_vknife_nemesis[64], model_vm249_survivor[64], model_vgrenade_infect[64], model_pgrenade_infect[64], model_wgrenade_infect[64],
model_vgrenade_fire[64], model_vgrenade_frost[64], model_vgrenade_explosion[64],
model_pgrenade_fire[64], model_pgrenade_frost[64], model_pgrenade_explosion[64],
model_wgrenade_fire[64], model_wgrenade_frost[64], model_wgrenade_explosion[64],
model_vknife_admin_human[64], model_vknife_admin_zombie[64],
sprite_grenade_trail[64], sprite_grenade_ring[64], sprite_grenade_fire[64],
sprite_grenade_smoke[64], sprite_grenade_glass[64], Array:sound_win_zombies,
Array:sound_win_humans, Array:sound_win_no_one, Array:zombie_infect, Array:zombie_idle,
Array:zombie_pain, Array:nemesis_pain, Array:assassin_pain, Array:oberon_pain, Array:dragon_pain, Array:nighter_pain, Array:genesys_pain, Array:evil_pain, Array:zombie_die, Array:zombie_fall,
Array:zombie_miss_wall, Array:zombie_hit_normal, Array:zombie_hit_stab, g_ambience_rain,
Array:zombie_idle_last, Array:zombie_madness, Array:sound_nemesis, Array:sound_survivor,
Array:sound_swarm, Array:sound_multi, Array:sound_plague, Array:grenade_infect,
Array:grenade_infect_player, Array:grenade_fire, Array:grenade_fire_player,
Array:grenade_frost, Array:grenade_frost_player, Array:grenade_frost_break,
Array:grenade_explosion, Array:sound_antidote, Array:sound_thunder, g_ambience_sounds[MAX_AMBIENCE_SOUNDS],
Array:sound_ambience1, Array:sound_ambience2, Array:sound_ambience3, Array:sound_ambience4,
Array:sound_ambience5, Array:sound_ambience1_duration, Array:sound_ambience2_duration,
Array:sound_ambience3_duration, Array:sound_ambience4_duration,
Array:sound_ambience5_duration, Array:sound_ambience1_ismp3, Array:sound_ambience2_ismp3,
Array:sound_ambience3_ismp3, Array:sound_ambience4_ismp3, Array:sound_ambience5_ismp3,
Array:g_primary_items, Array:g_secondary_items, Array:g_additional_items,
Array:g_primary_weaponids, Array:g_secondary_weaponids, Array:g_extraweapon_names,
Array:g_extraweapon_items, Array:g_extraweapon_costs, g_extra_costs2[EXTRA_WEAPONS_STARTID],
g_ambience_snow, g_ambience_fog, g_fog_density[10], g_fog_color[12], g_sky_enable,
Array:g_sky_names, Array:zombie_decals, Array:g_objective_ents,
Float:g_modelchange_delay, g_set_modelindex_offset, g_handle_models_on_separate_ent,
Float:kb_weapon_power[31] = { -1.0, ... }, Array:zombie_miss_slash, g_force_consistency,
Array:model_sniper, Array:g_modelindex_sniper, model_vawp_sniper[64],
Array:sound_sniper, Array:sound_ambience6, Array:sound_ambience6_duration, 
Array:sound_ambience6_ismp3,
Array:model_assassin, Array:g_modelindex_assassin, model_vknife_assassin[64],
Array:sound_assassin, Array:sound_ambience7, Array:sound_ambience7_duration, 
Array:sound_ambience7_ismp3, 
Array:model_oberon, Array:g_modelindex_oberon, model_vknife_oberon[64],
Array:sound_oberon, Array:sound_ambience7a, Array:sound_ambience7a_duration, 
Array:sound_ambience7a_ismp3, 
Array:model_dragon, Array:g_modelindex_dragon, model_vknife_dragon[64],
Array:sound_dragon, Array:sound_ambience7b, Array:sound_ambience7b_duration, 
Array:sound_ambience7b_ismp3, 
Array:model_nighter, Array:g_modelindex_nighter, model_vknife_nighter[64],
Array:sound_nighter, Array:sound_ambience7c, Array:sound_ambience7c_duration, 
Array:sound_ambience7c_ismp3,
Array:model_nchild, Array:g_modelindex_nchild, model_vknife_nchild[64],
Array:model_flamer, Array:g_modelindex_flamer, model_vweapon_flamer[64], model_pweapon_flamer[64],
Array:sound_flamer, Array:sound_ambience9a, Array:sound_ambience9a_duration, 
Array:sound_ambience9a_ismp3,
Array:model_zadoc, Array:g_modelindex_zadoc, model_vknife_zadoc[64], model_pknife_zadoc[64],
Array:sound_zadoc, Array:sound_ambience9b, Array:sound_ambience9b_duration, 
Array:sound_ambience9b_ismp3,
Array:model_genesys, Array:g_modelindex_genesys, model_vknife_genesys[64],
Array:sound_genesys, Array:sound_ambience9, Array:sound_ambience9_duration, 
Array:sound_ambience9_ismp3, Array:sound_lnj, Array:sound_ambience8, Array:sound_ambience8_duration, Array:sound_ambience8_ismp3,
Array:model_hero, Array:g_modelindex_hero, Array:model_evil, Array:g_modelindex_evil, model_vknife_evil[64],
Array:sound_guardians, Array:sound_ambience8d, Array:sound_ambience8d_duration, Array:sound_ambience8d_ismp3

// CVAR pointers
new cvar_lighting, cvar_toggle, sprite_fire

// Cached stuff for players
new g_isconnected[33] // whether player is connected
new g_isalive[33] // whether player is alive
new g_isbot[33] // whether player is a bot
new g_currentweapon[33] // player's current weapon id
new g_playername[33][32] // player's name
new g_playerip[33][16] // player's IP address
new Float:g_zombie_spd[33] // zombie class speed
new Float:g_zombie_knockback[33] // zombie class knockback
new g_zombie_classname[33][32] // zombie class name
new Float:g_human_spd[33] // human class speed
new g_human_classname[33][32] // human class name
#define is_user_valid_connected(%1) (1 <= %1 <= g_maxplayers && g_isconnected[%1])
#define is_user_valid_alive(%1) (1 <= %1 <= g_maxplayers && g_isalive[%1])

// Cached CVARs
new g_cached_customflash, g_cached_zombiesilent, Float:g_cached_nemspd,
Float:g_cached_survspd, g_cached_leapzombies, Float:g_cached_leapzombiescooldown, g_cached_leapnemesis,
Float:g_cached_leapnemesiscooldown, g_cached_leapsurvivor, Float:g_cached_leapsurvivorcooldown,
Float:g_cached_sniperspd, g_cached_leapsniper, Float:g_cached_leapsnipercooldown,
Float:g_cached_assassinspd, g_cached_leapassassin, Float:g_cached_leapassassincooldown, Float:g_cached_flamerspd, g_cached_leapflamer, Float:g_cached_leapflamercooldown,
Float:g_cached_oberonspd, g_cached_leapoberon, Float:g_cached_leapoberoncooldown, Float:g_cached_dragonspd, g_cached_leapdragon, Float:g_cached_leapdragoncooldown, Float:g_cached_zadocspd, g_cached_leapzadoc, Float:g_cached_leapzadoccooldown, 
Float:g_cached_nighterspd, g_cached_leapnighter, Float:g_cached_leapnightercooldown,
Float:g_cached_nchildspd, Float:g_cached_herospd, Float:g_cached_evilspd

//
LoadData(Player)
{
        if (is_user_bot(Player))
        {
        country[Player] = "Fake"
        city[Player] = "Fake"
        return
        }

	geoip_country(g_playerip[Player],country[Player],sizeof(country[]))
	
        if (!country[Player][0] || containi(country[Player], "Err") != -1)
        country[Player] = "N/A"

        city[Player] = "N/A"
}
//

/*================================================================================
 [Natives, Precache and Init]
=================================================================================*/
public plugin_natives()
{
	// Player specific natives
	register_native("zp_get_user_zombie", "native_get_user_zombie", 1)
	register_native("zp_set_user_blockbuy", "native_set_user_blockbuy", 1)
	register_native("zp_get_user_nemesis", "native_get_user_nemesis", 1)
	register_native("zp_get_user_survivor", "native_get_user_survivor", 1)
	register_native("zp_get_user_first_zombie", "native_get_user_first_zombie", 1)
	register_native("zp_get_user_last_zombie", "native_get_user_last_zombie", 1)
	register_native("zp_get_user_last_human", "native_get_user_last_human", 1)
	register_native("zp_get_user_zombie_class", "native_get_user_zombie_class", 1)
	register_native("zp_get_user_next_class", "native_get_user_next_class", 1)
	register_native("zp_set_user_zombie_class", "native_set_user_zombie_class", 1)
	register_native("zp_get_user_human_class", "native_get_user_human_class", 1)
	register_native("zp_get_user_next_hclass", "native_get_user_next_hclass", 1)
	register_native("zp_set_user_human_class", "native_set_user_human_class", 1)
	register_native("zp_get_user_ammo_packs", "native_get_user_ammo_packs", 1)
	register_native("zp_set_user_ammo_packs", "native_set_user_ammo_packs", 1)
	register_native("zp_get_zombie_maxhealth", "native_get_zombie_maxhealth", 1)
	register_native("zp_get_human_maxhealth", "native_get_human_maxhealth", 1)
	register_native("zp_get_user_batteries", "native_get_user_batteries", 1)
	register_native("zp_set_user_batteries", "native_set_user_batteries", 1)
	register_native("zp_get_user_nightvision", "native_get_user_nightvision", 1)
	register_native("zp_set_user_nightvision", "native_set_user_nightvision", 1)
	register_native("zp_infect_user", "native_infect_user", 1)
	register_native("zp_disinfect_user", "native_disinfect_user", 1)
	register_native("zp_make_user_nemesis", "native_make_user_nemesis", 1)
	register_native("zp_make_user_survivor", "native_make_user_survivor", 1)
	register_native("zp_respawn_user", "native_respawn_user", 1)
	register_native("zp_force_buy_extra_item", "native_force_buy_extra_item", 1)
	register_native("zp_get_user_sniper", "native_get_user_sniper", 1)
	register_native("zp_make_user_sniper", "native_make_user_sniper", 1)
	register_native("zp_get_user_assassin", "native_get_user_assassin", 1)
	register_native("zp_make_user_assassin", "native_make_user_assassin", 1)
	register_native("zp_get_user_oberon", "native_get_user_oberon", 1)
	register_native("zp_make_user_oberon", "native_make_user_oberon", 1)
	register_native("zp_get_user_dragon", "native_get_user_dragon", 1)
	register_native("zp_make_user_dragon", "native_make_user_dragon", 1)
	register_native("zp_get_user_nighter", "native_get_user_nighter", 1)
	register_native("zp_make_user_nighter", "native_make_user_nighter", 1)
	register_native("zp_get_user_flamer", "native_get_user_flamer", 1)
	register_native("zp_make_user_flamer", "native_make_user_flamer", 1)
	register_native("zp_get_user_zadoc", "native_get_user_zadoc", 1)
	register_native("zp_make_user_zadoc", "native_make_user_zadoc", 1)
	register_native("zp_get_user_genesys", "native_get_user_genesys", 1)
	register_native("zp_make_user_genesys", "native_make_user_genesys", 1)
	register_native("zp_get_user_points", "native_get_user_points", 1)
	register_native("zp_set_user_points", "native_set_user_points", 1)
	register_native("zp_get_user_coins", "native_get_user_coins", 1)
	register_native("zp_set_user_coins", "native_set_user_coins", 1)
	register_native("zp_get_user_xp", "native_get_user_xp", 1)
	register_native("zp_set_user_xp", "native_set_user_xp", 1)
	register_native("zp_get_user_level", "native_get_user_level", 1)
	register_native("zp_set_user_level", "native_set_user_level", 1)
	register_native("zp_get_user_power", "native_get_user_power", 1)
	register_native("zp_get_user_hclassname", "native_get_user_hclassname")
	register_native("zp_get_user_current_hc", "native_get_user_current_hc")
	register_native("zp_get_user_zclassname", "native_get_user_zclassname")
	register_native("zp_get_user_current_zc", "native_get_user_current_zc")
	register_native("SaveDate", "native_save_date", 1)
	register_native("zp_update_team", "native_update_team", 1)
	
	// Round natives
	register_native("zp_has_round_started", "native_has_round_started", 1)
	register_native("zp_is_nemesis_round", "native_is_nemesis_round", 1)
	register_native("zp_is_survivor_round", "native_is_survivor_round", 1)
	register_native("zp_is_swarm_round", "native_is_swarm_round", 1)
	register_native("zp_is_plague_round", "native_is_plague_round", 1)
	register_native("zp_get_zombie_count", "native_get_zombie_count", 1)
	register_native("zp_get_human_count", "native_get_human_count", 1)
	register_native("zp_get_nemesis_count", "native_get_nemesis_count", 1)
	register_native("zp_get_survivor_count", "native_get_survivor_count", 1)
	register_native("zp_is_sniper_round", "native_is_sniper_round", 1)
	register_native("zp_get_sniper_count", "native_get_sniper_count", 1)
	register_native("zp_is_assassin_round", "native_is_assassin_round", 1)
	register_native("zp_get_assassin_count", "native_get_assassin_count", 1)
	register_native("zp_is_oberon_round", "native_is_oberon_round", 1)
	register_native("zp_get_oberon_count", "native_get_oberon_count", 1)
	register_native("zp_is_dragon_round", "native_is_dragon_round", 1)
	register_native("zp_get_dragon_count", "native_get_dragon_count", 1)
	register_native("zp_is_nighter_round", "native_is_nighter_round", 1)
	register_native("zp_get_nighter_count", "native_get_nighter_count", 1)
	register_native("zp_is_flamer_round", "native_is_flamer_round", 1)
	register_native("zp_get_flamer_count", "native_get_flamer_count", 1)
	register_native("zp_is_zadoc_round", "native_is_zadoc_round", 1)
	register_native("zp_get_zadoc_count", "native_get_zadoc_count", 1)
	register_native("zp_is_genesys_round", "native_is_genesys_round", 1)
	register_native("zp_get_genesys_count", "native_get_genesys_count", 1)
	register_native("zp_is_lnj_round", "native_is_lnj_round", 1)
	register_native("zp_is_guardians_round", "native_is_guardians_round", 1)
	register_native("zp_get_zombie_hero", "native_get_zombie_hero", 1)
	register_native("zp_get_human_hero", "native_get_human_hero", 1)
	register_native("zp_is_hero_round", "native_is_hero_round", 1)
	
	// External additions natives
	register_native("zp_register_extra_item", "native_register_extra_item", 1)
	register_native("zp_register_zombie_class", "native_register_zombie_class", 1)
	register_native("zp_register_human_class", "native_register_human_class", 1)
	register_native("zp_get_extra_item_id", "native_get_extra_item_id", 1)
	register_native("zp_get_zombie_class_id", "native_get_zombie_class_id", 1)
	register_native("zp_get_human_class_id", "native_get_human_class_id", 1)

	// VIP
	register_native("zv_register_extra_item", "native_zv_register_extra_item", 1)
	register_native("zv_get_user_flags", "native_zv_get_user_flags", 1)

	// Accesses
	register_native("zc_get_user_flags", "native_zc_get_user_flags", 1)

	// Custom natives
	register_native("zp_get_user_frozen", "native_get_user_frozen", 1)
	register_native("zp_set_user_frozen", "native_set_user_frozen", 1)
}

public plugin_precache()
{
	// Register earlier to show up in plugins list properly after plugin disable/error at loading
	register_plugin("[Zombie Crown XP Mode]", PLUGIN_VERSION, PLUGIN_AUTHOR)
	
	// To switch plugin on/off
	register_concmd("zp_toggle", "cmd_toggle", _, "<1/0> - Enable/Disable Zombie Crown XP Mode (will restart the current map)", 0)
	cvar_toggle = register_cvar("zp_on", "1")
	
	// Plugin disabled?
	if (!get_pcvar_num(cvar_toggle)) return;
	g_pluginenabled = true
	
	// Initialize a few dynamically sized arrays (alright, maybe more than just a few...)
	model_nemesis = ArrayCreate(32, 1)
	model_survivor = ArrayCreate(32, 1)
	model_admin_human = ArrayCreate(32, 1)
	model_vip_human = ArrayCreate(32, 1)
	model_admin_zombie = ArrayCreate(32, 1)
	g_modelindex_nemesis = ArrayCreate(1, 1)
	g_modelindex_survivor = ArrayCreate(1, 1)
	g_modelindex_admin_human = ArrayCreate(1, 1)
	g_modelindex_admin_zombie = ArrayCreate(1, 1)
	sound_win_zombies = ArrayCreate(64, 1)
	sound_win_humans = ArrayCreate(64, 1)
	sound_win_no_one = ArrayCreate(64, 1)
	zombie_infect = ArrayCreate(64, 1)
	zombie_pain = ArrayCreate(64, 1)
	nemesis_pain = ArrayCreate(64, 1)
	assassin_pain = ArrayCreate(64, 1)
	oberon_pain = ArrayCreate(64, 1)
	dragon_pain = ArrayCreate(64, 1)
	nighter_pain = ArrayCreate(64, 1)
	genesys_pain = ArrayCreate(64, 1)
	evil_pain = ArrayCreate(64, 1)
	zombie_die = ArrayCreate(64, 1)
	zombie_fall = ArrayCreate(64, 1)
	zombie_miss_slash = ArrayCreate(64, 1)
	zombie_miss_wall = ArrayCreate(64, 1)
	zombie_hit_normal = ArrayCreate(64, 1)
	zombie_hit_stab = ArrayCreate(64, 1)
	zombie_idle = ArrayCreate(64, 1)
	zombie_idle_last = ArrayCreate(64, 1)
	zombie_madness = ArrayCreate(64, 1)
	sound_nemesis = ArrayCreate(64, 1)
	sound_survivor = ArrayCreate(64, 1)
	sound_swarm = ArrayCreate(64, 1)
	sound_multi = ArrayCreate(64, 1)
	sound_plague = ArrayCreate(64, 1)
	grenade_infect = ArrayCreate(64, 1)
	grenade_infect_player = ArrayCreate(64, 1)
	grenade_fire = ArrayCreate(64, 1)
	grenade_fire_player = ArrayCreate(64, 1)
	grenade_frost = ArrayCreate(64, 1)
	grenade_frost_player = ArrayCreate(64, 1)
	grenade_frost_break = ArrayCreate(64, 1)
	grenade_explosion = ArrayCreate(64, 1)
	g_Explo += precache_model("sprites/zerogxplode.spr")
	sound_antidote = ArrayCreate(64, 1)
	sound_thunder = ArrayCreate(64, 1)
	sound_ambience1 = ArrayCreate(64, 1)
	sound_ambience2 = ArrayCreate(64, 1)
	sound_ambience3 = ArrayCreate(64, 1)
	sound_ambience4 = ArrayCreate(64, 1)
	sound_ambience5 = ArrayCreate(64, 1)
	sound_ambience1_duration = ArrayCreate(1, 1)
	sound_ambience2_duration = ArrayCreate(1, 1)
	sound_ambience3_duration = ArrayCreate(1, 1)
	sound_ambience4_duration = ArrayCreate(1, 1)
	sound_ambience5_duration = ArrayCreate(1, 1)
	sound_ambience1_ismp3 = ArrayCreate(1, 1)
	sound_ambience2_ismp3 = ArrayCreate(1, 1)
	sound_ambience3_ismp3 = ArrayCreate(1, 1)
	sound_ambience4_ismp3 = ArrayCreate(1, 1)
	sound_ambience5_ismp3 = ArrayCreate(1, 1)
	g_primary_items = ArrayCreate(32, 1)
	g_secondary_items = ArrayCreate(32, 1)
	g_additional_items = ArrayCreate(32, 1)
	g_primary_weaponids = ArrayCreate(1, 1)
	g_secondary_weaponids = ArrayCreate(1, 1)
	g_extraweapon_names = ArrayCreate(32, 1)
	g_extraweapon_items = ArrayCreate(32, 1)
	g_extraweapon_costs = ArrayCreate(1, 1)
	g_sky_names = ArrayCreate(32, 1)
	zombie_decals = ArrayCreate(1, 1)
	g_objective_ents = ArrayCreate(32, 1)
	g_extraitem_name = ArrayCreate(32, 1)
	g_extraitem_cost = ArrayCreate(1, 1)
	g_extraitem_team = ArrayCreate(1, 1)
	g_extraitem_resttype = ArrayCreate(1, 1)
	g_extraitem_restlimit = ArrayCreate(1, 1)
	g_extraitem_limit = ArrayCreate(1, 1)
	g_extraitem2_realname = ArrayCreate(32, 1)
	g_extraitem2_name = ArrayCreate(32, 1)
	g_extraitem2_cost = ArrayCreate(1, 1)
	g_extraitem2_team = ArrayCreate(1, 1)
	g_extraitem2_resttype = ArrayCreate(1, 1)
	g_extraitem2_restlimit = ArrayCreate(1, 1)
	g_extraitem_new = ArrayCreate(1, 1)
	g_vipextraitem_name = ArrayCreate(32, 1)
	g_vipextraitem_cost = ArrayCreate(1, 1)
	g_vipextraitem_team = ArrayCreate(1, 1)
	g_vipextraitem_resttype = ArrayCreate(1, 1)
	g_vipextraitem_restlimit = ArrayCreate(1, 1)
	g_vipextraitem_limit = ArrayCreate(1, 1)
	g_zclass_name = ArrayCreate(32, 1)
	g_zclass_info = ArrayCreate(32, 1)
	g_zclass_modelsstart = ArrayCreate(1, 1)
	g_zclass_modelsend = ArrayCreate(1, 1)
	g_zclass_playermodel = ArrayCreate(32, 1)
	g_zclass_modelindex = ArrayCreate(1, 1)
	g_zclass_clawmodel = ArrayCreate(32, 1)
	g_zclass_hp = ArrayCreate(1, 1)
	g_zclass_spd = ArrayCreate(1, 1)
	g_zclass_grav = ArrayCreate(1, 1)
	g_zclass_kb = ArrayCreate(1, 1)
	g_zclass_level = ArrayCreate(1, 1)
	g_zclass2_realname = ArrayCreate(32, 1)
	g_zclass2_name = ArrayCreate(32, 1)
	g_zclass2_info = ArrayCreate(32, 1)
	g_zclass2_modelsstart = ArrayCreate(1, 1)
	g_zclass2_modelsend = ArrayCreate(1, 1)
	g_zclass2_playermodel = ArrayCreate(32, 1)
	g_zclass2_modelindex = ArrayCreate(1, 1)
	g_zclass2_clawmodel = ArrayCreate(32, 1)
	g_zclass2_hp = ArrayCreate(1, 1)
	g_zclass2_spd = ArrayCreate(1, 1)
	g_zclass2_grav = ArrayCreate(1, 1)
	g_zclass2_kb = ArrayCreate(1, 1)
	g_zclass2_level = ArrayCreate(1, 1)
	g_zclass_new = ArrayCreate(1, 1)
     	g_hclass_name = ArrayCreate(32, 1)
	g_hclass_info = ArrayCreate(32, 1)
	g_hclass_modelsstart = ArrayCreate(1, 1)
	g_hclass_modelsend = ArrayCreate(1, 1)
	g_hclass_playermodel = ArrayCreate(32, 1)
	g_hclass_modelindex = ArrayCreate(1, 1)	
	g_hclass_hp = ArrayCreate(1, 1)
	g_hclass_spd = ArrayCreate(1, 1)
	g_hclass_grav = ArrayCreate(1, 1)	
	g_hclass_level = ArrayCreate(1, 1)
	g_hclass2_realname = ArrayCreate(32, 1)
	g_hclass2_name = ArrayCreate(32, 1)
	g_hclass2_info = ArrayCreate(32, 1)
	g_hclass2_modelsstart = ArrayCreate(1, 1)
	g_hclass2_modelsend = ArrayCreate(1, 1)
	g_hclass2_playermodel = ArrayCreate(32, 1)
	g_hclass2_modelindex = ArrayCreate(1, 1)	
	g_hclass2_hp = ArrayCreate(1, 1)
	g_hclass2_spd = ArrayCreate(1, 1)
	g_hclass2_grav = ArrayCreate(1, 1)	
	g_hclass2_level = ArrayCreate(1, 1)
	g_hclass_new = ArrayCreate(1, 1)
	model_sniper = ArrayCreate(32, 1)
	g_modelindex_sniper = ArrayCreate(1, 1)
	sound_sniper = ArrayCreate(64, 1)
	sound_ambience6 = ArrayCreate(64, 1)
	sound_ambience6_duration = ArrayCreate(1, 1)
	sound_ambience6_ismp3 = ArrayCreate(1, 1)
	sound_lnj = ArrayCreate(64, 1)
	sound_ambience8 = ArrayCreate(64, 1)
	sound_ambience8_duration = ArrayCreate(1, 1)
	sound_ambience8_ismp3 = ArrayCreate(1, 1)
	model_assassin = ArrayCreate(32, 1)
	g_modelindex_assassin = ArrayCreate(1, 1)
	sound_assassin = ArrayCreate(64, 1)
	sound_ambience7 = ArrayCreate(64, 1)
	sound_ambience7_duration = ArrayCreate(1, 1)
	sound_ambience7_ismp3 = ArrayCreate(1, 1)
	model_oberon = ArrayCreate(32, 1)
	g_modelindex_oberon = ArrayCreate(1, 1)
	sound_oberon = ArrayCreate(64, 1)
	sound_ambience7a = ArrayCreate(64, 1)
	sound_ambience7a_duration = ArrayCreate(1, 1)
	sound_ambience7a_ismp3 = ArrayCreate(1, 1)
	model_dragon = ArrayCreate(32, 1)
	g_modelindex_dragon = ArrayCreate(1, 1)
	sound_dragon = ArrayCreate(64, 1)
	sound_ambience7b = ArrayCreate(64, 1)
	sound_ambience7b_duration = ArrayCreate(1, 1)
	sound_ambience7b_ismp3 = ArrayCreate(1, 1)
	model_nighter = ArrayCreate(32, 1)
	model_nchild = ArrayCreate(32, 1)
	g_modelindex_nighter = ArrayCreate(1, 1)
	g_modelindex_nchild = ArrayCreate(1, 1)
	sound_nighter = ArrayCreate(64, 1)
	sound_ambience7c = ArrayCreate(64, 1)
	sound_ambience7c_duration = ArrayCreate(1, 1)
	sound_ambience7c_ismp3 = ArrayCreate(1, 1)
	model_flamer = ArrayCreate(32, 1)
	g_modelindex_flamer = ArrayCreate(1, 1)
	sound_flamer = ArrayCreate(64, 1)
	sound_ambience9a = ArrayCreate(64, 1)
	sound_ambience9a_duration = ArrayCreate(1, 1)
	sound_ambience9a_ismp3 = ArrayCreate(1, 1)
	model_zadoc = ArrayCreate(32, 1)
	g_modelindex_zadoc = ArrayCreate(1, 1)
	sound_zadoc = ArrayCreate(64, 1)
	sound_ambience9b = ArrayCreate(64, 1)
	sound_ambience9b_duration = ArrayCreate(1, 1)
	sound_ambience9b_ismp3 = ArrayCreate(1, 1)
	model_genesys = ArrayCreate(32, 1)
	g_modelindex_genesys = ArrayCreate(1, 1)
	sound_genesys = ArrayCreate(64, 1)
	sound_ambience9 = ArrayCreate(64, 1)
	sound_ambience9_duration = ArrayCreate(1, 1)
	sound_ambience9_ismp3 = ArrayCreate(1, 1)
	model_hero = ArrayCreate(32, 1)
	g_modelindex_hero = ArrayCreate(1, 1)
	g_modelindex_hero = ArrayCreate(1, 1)
	model_evil = ArrayCreate(32, 1)
	g_modelindex_evil = ArrayCreate(1, 1)
	g_modelindex_evil = ArrayCreate(1, 1)
	sound_guardians = ArrayCreate(64, 1)
	sound_ambience8d = ArrayCreate(64, 1)
	sound_ambience8d_duration = ArrayCreate(1, 1)
	sound_ambience8d_ismp3 = ArrayCreate(1, 1)
	
	// Allow registering stuff now
	g_arrays_created = true
	
	// Load customization data
	load_customization_from_files()
	Load_GameConfig()

	new i, buffer[100]
	
	// Load up the hard coded extra items
	native_register_extra_item2("NightVision", g_extra_costs2[EXTRA_NVISION], ZP_TEAM_HUMAN, REST_NONE, 27)
	native_register_extra_item2("Super NightVision", g_extra_costs2[EXTRA_CNVISION], ZP_TEAM_ANY, REST_NONE, 27)
	native_register_extra_item2("T-Virus Antidote", g_extra_costs2[EXTRA_ANTIDOTE], ZP_TEAM_ZOMBIE, REST_MAP, 3)
	native_register_extra_item2("Zombie Madness", g_extra_costs2[EXTRA_MADNESS], ZP_TEAM_ZOMBIE, REST_MAP, 3)
	native_register_extra_item2("Infection Bomb", g_extra_costs2[EXTRA_INFBOMB], ZP_TEAM_ZOMBIE, REST_MAP, 1)
	
	// Extra weapons
	for (i = 0; i < ArraySize(g_extraweapon_names); i++)
	{
		ArrayGetString(g_extraweapon_names, i, buffer, charsmax(buffer))
		native_register_extra_item2(buffer, ArrayGetCell(g_extraweapon_costs, i), ZP_TEAM_HUMAN)
	}
	
	// Custom player models
	for (i = 0; i < ArraySize(model_nemesis); i++)
	{
		ArrayGetString(model_nemesis, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_nemesis, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
	}
	for (i = 0; i < ArraySize(model_survivor); i++)
	{
		ArrayGetString(model_survivor, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_survivor, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
	}
	for (i = 0; i < ArraySize(model_admin_zombie); i++)
	{
		ArrayGetString(model_admin_zombie, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_admin_zombie, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
	}
	for (i = 0; i < ArraySize(model_admin_human); i++)
	{
		ArrayGetString(model_admin_human, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_admin_human, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
	}
	for (i = 0; i < ArraySize(model_vip_human); i++)
	{
		ArrayGetString(model_vip_human, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_admin_human, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
	}
	for (i = 0; i < ArraySize(model_sniper); i++)
	{
		ArrayGetString(model_sniper, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_sniper, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
	}
	for (i = 0; i < ArraySize(model_assassin); i++)
	{
		ArrayGetString(model_assassin, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_assassin, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
	}
	for (i = 0; i < ArraySize(model_oberon); i++)
	{
		ArrayGetString(model_oberon, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_oberon, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
	}
	for (i = 0; i < ArraySize(model_dragon); i++)
	{
		ArrayGetString(model_dragon, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_dragon, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
	}
	for (i = 0; i < ArraySize(model_nighter); i++)
	{
		ArrayGetString(model_nighter, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_nighter, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
	}
	for (i = 0; i < ArraySize(model_nchild); i++)
	{
		ArrayGetString(model_nchild, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_nchild, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
	}
	for (i = 0; i < ArraySize(model_flamer); i++)
	{
		ArrayGetString(model_flamer, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_flamer, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
	}
	for (i = 0; i < ArraySize(model_zadoc); i++)
	{
		ArrayGetString(model_zadoc, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_zadoc, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
	}
	for (i = 0; i < ArraySize(model_genesys); i++)
	{
		ArrayGetString(model_genesys, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_genesys, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
	}
	for (i = 0; i < ArraySize(model_evil); i++)
	{
		ArrayGetString(model_evil, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_evil, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
	}
	for (i = 0; i < ArraySize(model_hero); i++)
	{
		ArrayGetString(model_hero, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_hero, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
	}
	
	// Custom weapon models
	engfunc(EngFunc_PrecacheModel, model_vknife_human)
	engfunc(EngFunc_PrecacheModel, model_vknife_nemesis)
	engfunc(EngFunc_PrecacheModel, model_vm249_survivor)
	engfunc(EngFunc_PrecacheModel, model_vgrenade_infect)
	engfunc(EngFunc_PrecacheModel, model_vgrenade_fire)
	engfunc(EngFunc_PrecacheModel, model_vgrenade_frost)
	engfunc(EngFunc_PrecacheModel, model_vgrenade_explosion)
	engfunc(EngFunc_PrecacheModel, model_pgrenade_infect)
	engfunc(EngFunc_PrecacheModel, model_pgrenade_fire)
	engfunc(EngFunc_PrecacheModel, model_pgrenade_frost)
	engfunc(EngFunc_PrecacheModel, model_pgrenade_explosion)
	engfunc(EngFunc_PrecacheModel, model_wgrenade_infect)
	engfunc(EngFunc_PrecacheModel, model_wgrenade_fire)
	engfunc(EngFunc_PrecacheModel, model_wgrenade_frost)
	engfunc(EngFunc_PrecacheModel, model_wgrenade_explosion)
	engfunc(EngFunc_PrecacheModel, model_vknife_admin_human)
	engfunc(EngFunc_PrecacheModel, model_vknife_admin_zombie)
	engfunc(EngFunc_PrecacheModel, model_vawp_sniper)
	engfunc(EngFunc_PrecacheModel, model_vknife_assassin)
	engfunc(EngFunc_PrecacheModel, model_vknife_oberon)
	engfunc(EngFunc_PrecacheModel, model_vknife_dragon)
	engfunc(EngFunc_PrecacheModel, model_vknife_nighter)
	engfunc(EngFunc_PrecacheModel, model_vknife_nchild)
	engfunc(EngFunc_PrecacheModel, model_vknife_evil)
	engfunc(EngFunc_PrecacheModel, model_vweapon_flamer)
	engfunc(EngFunc_PrecacheModel, model_pweapon_flamer)
	engfunc(EngFunc_PrecacheModel, model_vknife_zadoc)
	engfunc(EngFunc_PrecacheModel, model_pknife_zadoc)
	engfunc(EngFunc_PrecacheModel, model_vknife_genesys)

	// Flashlight cone
	// engfunc(EngFunc_PrecacheModel, model_lightcone)

	// Genesys Power
	sprite_fire = precache_model("sprites/explode1.spr");
	precache_sound("flamethrower.wav");
	SPR_LOCUST = precache_model("sprites/flare6.spr");
	precache_sound(SOUND_LOCUSTSWARM);

	// Flamer Power
	precache_model(fire_spr_name)
	precache_sound(fire_sound)
	precache_sound("weapons/flamegun-1.wav")
	precache_sound("weapons/flamegun_clipin1.wav")
	precache_sound("weapons/flamegun_clipout1.wav")
	precache_sound("weapons/flamegun_clipout2.wav")
	precache_sound("weapons/flamegun_draw.wav")

	// Oberon Powers
	precache_model(oberon_bomb_model)
	precache_sound(oberon_bomb_sound)
	exp_spr_id = precache_model("sprites/zerogxplode.spr")
	precache_sound(oberon_hole_sound)
	precache_model(oberon_hole_effect)

	// Dragon Powers
	for(new i = 0; i < sizeof(DragonRes); i++)
	{
		if(i == 1) g_FrezeExp_SprID = engfunc(EngFunc_PrecacheModel, DragonRes[i])
		else engfunc(EngFunc_PrecacheModel, DragonRes[i])
	}
	for (new i = 0; i < sizeof dragon_sound; i++) 
	{
		engfunc(EngFunc_PrecacheSound, dragon_sound[i])
	}

	// Zadoc Powers
	gSprZadoc = precache_model(zadoc_cyl)
	for (new i = 0; i < sizeof zadoc_sound; i++)
	{
		engfunc(EngFunc_PrecacheSound, zadoc_sound[i])
	}
	
	// Custom sprites for grenades
	g_trailSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_trail)
	g_exploSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_ring)
	g_flameSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_fire)
	g_smokeSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_smoke)
	g_glassSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_glass)
	g_fire_explode = precache_model ("sprites/zombie_crown/fire_explode.spr") 
	g_frost_explode = precache_model ("sprites/zombie_crown/frost_explode.spr") 
	g_fire_gib = precache_model ("sprites/zombie_crown/fire_gib.spr") 
	g_frost_gib = precache_model ("sprites/zombie_crown/frost_gib.spr") 
	g_fire_trail = precache_model ("sprites/zombie_crown/fire_trail.spr")
	g_frost_trail = precache_model ("sprites/zombie_crown/frost_trail.spr") 
	g_explosion_trail = precache_model ("sprites/zombie_crown/explosion_trail.spr")

	// Bought
	precache_sound(BGH_S)
	precache_sound(LEVELUP_S)
	
	// Custom sounds
	for (i = 0; i < ArraySize(sound_win_zombies); i++)
	{
		ArrayGetString(sound_win_zombies, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_win_humans); i++)
	{
		ArrayGetString(sound_win_humans, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_win_no_one); i++)
	{
		ArrayGetString(sound_win_no_one, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(zombie_infect); i++)
	{
		ArrayGetString(zombie_infect, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(zombie_pain); i++)
	{
		ArrayGetString(zombie_pain, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(nemesis_pain); i++)
	{
		ArrayGetString(nemesis_pain, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(assassin_pain); i++)
	{
		ArrayGetString(assassin_pain, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(oberon_pain); i++)
	{
		ArrayGetString(oberon_pain, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(dragon_pain); i++)
	{
		ArrayGetString(dragon_pain, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(nighter_pain); i++)
	{
		ArrayGetString(nighter_pain, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(genesys_pain); i++)
	{
		ArrayGetString(genesys_pain, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(evil_pain); i++)
	{
		ArrayGetString(evil_pain, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(zombie_die); i++)
	{
		ArrayGetString(zombie_die, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(zombie_fall); i++)
	{
		ArrayGetString(zombie_fall, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(zombie_miss_slash); i++)
	{
		ArrayGetString(zombie_miss_slash, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(zombie_miss_wall); i++)
	{
		ArrayGetString(zombie_miss_wall, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(zombie_hit_normal); i++)
	{
		ArrayGetString(zombie_hit_normal, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(zombie_hit_stab); i++)
	{
		ArrayGetString(zombie_hit_stab, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(zombie_idle); i++)
	{
		ArrayGetString(zombie_idle, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(zombie_idle_last); i++)
	{
		ArrayGetString(zombie_idle_last, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(zombie_madness); i++)
	{
		ArrayGetString(zombie_madness, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_nemesis); i++)
	{
		ArrayGetString(sound_nemesis, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_survivor); i++)
	{
		ArrayGetString(sound_survivor, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_swarm); i++)
	{
		ArrayGetString(sound_swarm, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_multi); i++)
	{
		ArrayGetString(sound_multi, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_plague); i++)
	{
		ArrayGetString(sound_plague, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(grenade_infect); i++)
	{
		ArrayGetString(grenade_infect, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(grenade_infect_player); i++)
	{
		ArrayGetString(grenade_infect_player, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(grenade_fire); i++)
	{
		ArrayGetString(grenade_fire, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(grenade_fire_player); i++)
	{
		ArrayGetString(grenade_fire_player, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(grenade_frost); i++)
	{
		ArrayGetString(grenade_frost, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(grenade_frost_player); i++)
	{
		ArrayGetString(grenade_frost_player, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(grenade_frost_break); i++)
	{
		ArrayGetString(grenade_frost_break, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(grenade_explosion); i++)
	{
		ArrayGetString(grenade_explosion, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_antidote); i++)
	{
		ArrayGetString(sound_antidote, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_thunder); i++)
	{
		ArrayGetString(sound_thunder, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_sniper); i++)
	{
		ArrayGetString(sound_sniper, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_assassin); i++)
	{
		ArrayGetString(sound_assassin, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_oberon); i++)
	{
		ArrayGetString(sound_oberon, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_dragon); i++)
	{
		ArrayGetString(sound_dragon, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_nighter); i++)
	{
		ArrayGetString(sound_nighter, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_flamer); i++)
	{
		ArrayGetString(sound_flamer, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "sound/%s", buffer)
		engfunc(EngFunc_PrecacheGeneric, buffer)
	}
	for (i = 0; i < ArraySize(sound_zadoc); i++)
	{
		ArrayGetString(sound_zadoc, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "sound/%s", buffer)
		engfunc(EngFunc_PrecacheGeneric, buffer)
	}
	for (i = 0; i < ArraySize(sound_genesys); i++)
	{
		ArrayGetString(sound_genesys, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "sound/%s", buffer)
		engfunc(EngFunc_PrecacheGeneric, buffer)
	}
	for (i = 0; i < ArraySize(sound_lnj); i++)
	{
		ArrayGetString(sound_lnj, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}  
	for (i = 0; i < ArraySize(sound_guardians); i++)
	{
		ArrayGetString(sound_guardians, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}  
	
	// Ambience Sounds
	if (g_ambience_sounds[AMBIENCE_SOUNDS_INFECTION])
	{
		for (i = 0; i < ArraySize(sound_ambience1); i++)
		{
			ArrayGetString(sound_ambience1, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience1_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}
	if (g_ambience_sounds[AMBIENCE_SOUNDS_NEMESIS])
	{
		for (i = 0; i < ArraySize(sound_ambience2); i++)
		{
			ArrayGetString(sound_ambience2, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience2_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}
	if (g_ambience_sounds[AMBIENCE_SOUNDS_SURVIVOR])
	{
		for (i = 0; i < ArraySize(sound_ambience3); i++)
		{
			ArrayGetString(sound_ambience3, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience3_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}
	if (g_ambience_sounds[AMBIENCE_SOUNDS_SWARM])
	{
		for (i = 0; i < ArraySize(sound_ambience4); i++)
		{
			ArrayGetString(sound_ambience4, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience4_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}
	if (g_ambience_sounds[AMBIENCE_SOUNDS_PLAGUE])
	{
		for (i = 0; i < ArraySize(sound_ambience5); i++)
		{
			ArrayGetString(sound_ambience5, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience5_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}
	if (g_ambience_sounds[AMBIENCE_SOUNDS_SNIPER])
	{
		for (i = 0; i < ArraySize(sound_ambience6); i++)
		{
			ArrayGetString(sound_ambience6, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience6_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}
	if (g_ambience_sounds[AMBIENCE_SOUNDS_ASSASSIN])
	{
		for (i = 0; i < ArraySize(sound_ambience7); i++)
		{
			ArrayGetString(sound_ambience7, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience7_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}
	if (g_ambience_sounds[AMBIENCE_SOUNDS_OBERON])
	{
		for (i = 0; i < ArraySize(sound_ambience7a); i++)
		{
			ArrayGetString(sound_ambience7a, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience7a_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}
	if (g_ambience_sounds[AMBIENCE_SOUNDS_DRAGON])
	{
		for (i = 0; i < ArraySize(sound_ambience7b); i++)
		{
			ArrayGetString(sound_ambience7b, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience7b_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}
	if (g_ambience_sounds[AMBIENCE_SOUNDS_NIGHTER])
	{
		for (i = 0; i < ArraySize(sound_ambience7c); i++)
		{
			ArrayGetString(sound_ambience7c, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience7c_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}
	if (g_ambience_sounds[AMBIENCE_SOUNDS_FLAMER])
	{
		for (i = 0; i < ArraySize(sound_ambience9a); i++)
		{
			ArrayGetString(sound_ambience9a, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience9a_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}
	if (g_ambience_sounds[AMBIENCE_SOUNDS_ZADOC])
	{
		for (i = 0; i < ArraySize(sound_ambience9b); i++)
		{
			ArrayGetString(sound_ambience9b, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience9b_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}
	if (g_ambience_sounds[AMBIENCE_SOUNDS_GENESYS])
	{
		for (i = 0; i < ArraySize(sound_ambience9); i++)
		{
			ArrayGetString(sound_ambience9, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience9_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}
	if (g_ambience_sounds[AMBIENCE_SOUNDS_LNJ])
	{
		for (i = 0; i < ArraySize(sound_ambience8); i++)
		{
			ArrayGetString(sound_ambience8, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience8_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}
	if (g_ambience_sounds[AMBIENCE_SOUNDS_GUARDIANS])
	{
		for (i = 0; i < ArraySize(sound_ambience8d); i++)
		{
			ArrayGetString(sound_ambience8d, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience8d_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}	
	
	// CS sounds (just in case)
	engfunc(EngFunc_PrecacheSound, sound_flashlight)
	engfunc(EngFunc_PrecacheSound, sound_buyammo)
	engfunc(EngFunc_PrecacheSound, sound_armorhit)
	
	new ent
	
	// Fake Hostage (to force round ending)
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "hostage_entity"))
	if (pev_valid(ent))
	{
		engfunc(EngFunc_SetOrigin, ent, Float:{8192.0,8192.0,8192.0})
		dllfunc(DLLFunc_Spawn, ent)
	}
	
	// Weather/ambience effects
	if (g_ambience_fog)
	{
		ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"))
		if (pev_valid(ent))
		{
			fm_set_kvd(ent, "density", g_fog_density, "env_fog")
			fm_set_kvd(ent, "rendercolor", g_fog_color, "env_fog")
		}
	}
	if (g_ambience_rain) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_rain"))
	if (g_ambience_snow) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_snow"))
	
	// Prevent some entities from spawning
	g_fwSpawn = register_forward(FM_Spawn, "fw_Spawn")
	
	// Prevent hostage sounds from being precached
	g_fwPrecacheSound = register_forward(FM_PrecacheSound, "fw_PrecacheSound")

	// CountDown
	for(i = 0; i < sizeof CountDownSounds; i++)
		precache_sound(CountDownSounds[i])
	for(i = 0; i < sizeof CountDownFinalSounds; i++)
		precache_sound(CountDownFinalSounds[i])

	// Blink Power
	SPR_TELEPORT = precache_model("sprites/b-tele1.spr")	
	SPR_TELEPORT_GIB = precache_model("sprites/blueflare2.spr")	
	precache_sound(SOUND_BLINK)

	// Chain Lightning Power
	SPR_LIGHTNING = precache_model("sprites/blue_lightning_blizzard.spr")
	precache_sound(SOUND_LIGHTNING)
}

public plugin_init()
{
	// Plugin disabled?
	if (!g_pluginenabled) return;
	
	// No zombie classes?
	if (!g_zclass_i) set_fail_state("No zombie classes loaded!")

	// No human classes?
	if (!g_hclass_i) set_fail_state("No human classes loaded!")
	
	// Language files
	register_dictionary("zc_dictionary.txt")

	// Retrieve mapname
	get_mapname(mapname, 31)

	
	// Events
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_logevent("logevent_round_start",2, "1=Round_Start")
	register_logevent("logevent_round_end", 2, "1=Round_End")
	register_event("AmmoX", "event_ammo_x", "be")
	if (g_ambience_sounds[AMBIENCE_SOUNDS_INFECTION] || g_ambience_sounds[AMBIENCE_SOUNDS_NEMESIS] || g_ambience_sounds[AMBIENCE_SOUNDS_SURVIVOR] || g_ambience_sounds[AMBIENCE_SOUNDS_SWARM] 
	|| g_ambience_sounds[AMBIENCE_SOUNDS_PLAGUE] || g_ambience_sounds[AMBIENCE_SOUNDS_SNIPER] || g_ambience_sounds[AMBIENCE_SOUNDS_ASSASSIN] || g_ambience_sounds[AMBIENCE_SOUNDS_OBERON] 
	|| g_ambience_sounds[AMBIENCE_SOUNDS_DRAGON] || g_ambience_sounds[AMBIENCE_SOUNDS_NIGHTER] || g_ambience_sounds[AMBIENCE_SOUNDS_FLAMER] || g_ambience_sounds[AMBIENCE_SOUNDS_ZADOC] 
	|| g_ambience_sounds[AMBIENCE_SOUNDS_GENESYS] || g_ambience_sounds[AMBIENCE_SOUNDS_LNJ] || g_ambience_sounds[AMBIENCE_SOUNDS_GUARDIANS])
		register_event("30", "event_intermission", "a")
	
	// HAM Forwards
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1)
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled_Post", 1)
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post", 1)
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack")
	RegisterHam(Ham_Use, "func_tank", "fw_UseStationary")
	RegisterHam(Ham_Use, "func_tankmortar", "fw_UseStationary")
	RegisterHam(Ham_Use, "func_tankrocket", "fw_UseStationary")
	RegisterHam(Ham_Use, "func_tanklaser", "fw_UseStationary")
	RegisterHam(Ham_Use, "func_tank", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tankmortar", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tankrocket", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tanklaser", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_pushable", "fw_UsePushable")
	RegisterHam(Ham_Touch, "weaponbox", "fw_TouchWeapon")
	RegisterHam(Ham_Touch, "armoury_entity", "fw_TouchWeapon")
	RegisterHam(Ham_Touch, "weapon_shield", "fw_TouchWeapon")
	RegisterHam(Ham_AddPlayerItem, "player", "fw_AddPlayerItem")
	for (new i = 1; i < sizeof WEAPONENTNAMES; i++)
		if (WEAPONENTNAMES[i][0]) RegisterHam(Ham_Item_Deploy, WEAPONENTNAMES[i], "fw_Item_Deploy_Post", 1)
	
	// FM Forwards
	register_forward(FM_ClientDisconnect, "fw_ClientDisconnect")
	register_forward(FM_ClientDisconnect, "fw_ClientDisconnect_Post", 1)
	register_forward(FM_ClientKill, "fw_ClientKill")
	register_forward(FM_EmitSound, "fw_EmitSound")
	if (!g_handle_models_on_separate_ent) register_forward(FM_SetClientKeyValue, "fw_SetClientKeyValue")
	register_forward(FM_ClientUserInfoChanged, "fw_ClientUserInfoChanged")
	register_forward(FM_GetGameDescription, "fw_GetGameDescription")
	register_forward(FM_SetModel, "fw_SetModel")
	RegisterHam(Ham_Think, "grenade", "fw_ThinkGrenade")
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	unregister_forward(FM_Spawn, g_fwSpawn)
	unregister_forward(FM_PrecacheSound, g_fwPrecacheSound)
	
	// Client commands
	register_clcmd("say zpmenu", "clcmd_saymenu")
	register_clcmd("say /zpmenu", "clcmd_saymenu")
	register_clcmd("say unstuck", "clcmd_sayunstuck")
	register_clcmd("say /unstuck", "clcmd_sayunstuck")
	register_clcmd("nightvision", "clcmd_nightvision")
	register_clcmd("drop", "clcmd_drop")
	register_clcmd("buyammo1", "clcmd_buyammo")
	register_clcmd("buyammo2", "clcmd_buyammo")
	register_clcmd("chooseteam", "clcmd_changeteam")
	register_clcmd("jointeam", "clcmd_changeteam")
	register_clcmd("showmenu", "show_menu_game")
	
	// Menus
	register_menu("Game Menu", KEYSMENU, "menu_game")
	register_menu("Buy Menu 1", KEYSMENU, "menu_buy1")
	register_menu("Buy Menu 2", KEYSMENU, "menu_buy2")
	register_menu("Menu2 Admin", KEYSMENU, "menu2_admin")
	register_menu("Menu3 Admin", KEYSMENU, "menu3_admin")
	register_menu("Menu4 Admin", KEYSMENU, "menu4_admin")

	// Modes accesses flags
	get_cvar_string("amx_password_field", zc_password_sf, charsmax(zc_password_sf))
	register_concmd("amx_reloadaccesses", "reload_acc_cmd", ADMIN_RCON)
	reload_accesses()
	
	// Admin commands
	register_concmd("zp_swarm", "cmd_swarm", _, " - Start Swarm Mode", 0)
	register_concmd("zp_multi", "cmd_multi", _, " - Start Multi Infection", 0)
	register_concmd("zp_plague", "cmd_plague", _, " - Start Plague Mode", 0)
	register_concmd("zp_lnj", "cmd_lnj", _, " - Start LNJ Mode", 0)
	register_concmd("zp_guardians", "cmd_guardians", _, " - Start guardians Mode", 0)

	// Genesys / Oberon / Dragon / Evil Powers Buttons
   	register_clcmd("radio1", "flamepw")
   	register_clcmd("radio2", "Ultimate_LocustSwarm")
   	register_clcmd("radio1", "ultbomb")
   	register_clcmd("radio2", "ulthole")
   	register_clcmd("radio1", "use_cmd")
	register_clcmd("radio1", "NighterBlink")
	register_clcmd("radio1", "evil_power")
	
	// Dragon Extra Power
	register_think(DRAGON_FREEZE, "fw_Think_Ice")
	register_touch(DRAGON_FREEZE, "*", "fw_Touch_Ice")

	// Zadoc Power
	register_forward(FM_EmitSound , "Forward_EmitSound")

	// Flamer Power
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	RegisterHam(Ham_Weapon_Reload, "weapon_m249", "fw_weapon_reload", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_m249", "fw_weapon_deploy", 1)
	RegisterHam(Ham_Item_PostFrame, "weapon_m249", "fw_item_postframe", 1)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_m249", "fw_item_addtoplayer", 1)
	register_forward(FM_CmdStart, "fw_cmdflamer")
	register_touch(fire_classname, "*", "fw_touch")
	register_think(fire_classname, "fw_think")
	register_clcmd("lastinv", "check_lastinv")

	// Remove some HUDs
	g_pCvars[Hide_Cal] = register_cvar("zp_hide_cross_ammo_weaponlist", "0")
	g_pCvars[Hide_Flash] = register_cvar("zp_hide_flashlight", "0")
	g_pCvars[Hide_All] = register_cvar("zp_hide_all", "0")
	g_pCvars[Hide_Rha] = register_cvar("zp_hide_radar_health_armor", "0")
	g_pCvars[Hide_Timer] = register_cvar("zp_hide_timer", "0")
	g_pCvars[Hide_Money] = register_cvar("zp_hide_money", "1")
	g_pCvars[Hide_Cross] = register_cvar("zp_hide_crosshair", "0")
	g_pCvars[Draw_Cross] = register_cvar("zp_draw_crosshair", "0")
	register_event("ResetHUD", "Event_ResetHUD", "b")
	register_event("HideWeapon", "Event_HideWeapon", "b")

	// VIP HUD
	register_think(g_ClassName,"ForwardThink")
	g_SyncVIP = CreateHudSyncObj()
	new iEnt = create_entity("info_target")
	entity_set_string(iEnt, EV_SZ_classname, g_ClassName)
	entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 2.0)

	// VIP
	register_event("ResetHUD", "HUDReset", "be")
	register_forward(FM_PlayerPreThink, "fw_PrethinkVip")
	register_forward(FM_PlayerPostThink, "fw_PostthinkVip")
	register_message(get_user_msgid("CurWeapon"), "message_cur_weapon_vip")
	register_concmd("amx_reloadvips","reload_vips_cmd", ADMIN_RCON, "use to reload VIPs")
	g_allow_jump = register_cvar("zp_vip_allow_jump", "ab")
	g_hour_flags = register_cvar("zp_vip_hour_flags", "abcde")
	get_cvar_string("amx_password_field", amx_password_field_string, charsmax(amx_password_field_string))
	set_task(5.0, "check_date",0)
	reload_vips()
	register_clcmd("say /vm", "menu_open")
	register_clcmd("vm", "menu_open")
	g_extra_item_selected = CreateMultiForward("zv_extra_item_selected", ET_CONTINUE, FP_CELL, FP_CELL)
	register_clcmd("say /vips", "print_viplist")
	register_clcmd("say /buyvip", "ShowMotd")
	register_clcmd("say /vip", "ShowMotd")
	new weapon_name[24]
	for (new i = 1; i <= 30; i++)
	{
		if (!(WEAPONS_BITSUM & 1 << i) && get_weaponname(i, weapon_name, 23))
		{
			RegisterHam(Ham_Weapon_PrimaryAttack, weapon_name, "fw_Weapon_PrimaryAttack_Pre")
			RegisterHam(Ham_Weapon_PrimaryAttack, weapon_name, "fw_Weapon_PrimaryAttack_Post", 1)
		}
	}

	// VIP Bonus
	register_concmd("amx_vip_bonus", "Bonus_VIP", ADMIN_RCON, "use to give VIP bonus")
   	register_clcmd("say /bonusvip" , "Load_Time" , -1)

	// Respawn Menu
	register_menu("menu_res" , KEYSMENU , "respawn_menu"); 
	register_clcmd("say /res" , "open_menu");
	register_clcmd("say /respawn" , "open_menu");
	register_clcmd("say /latejoin" , "open_menu");
	register_clcmd("say /zspawn" , "open_menu");
	register_clcmd("res" , "open_menu");
 
	// Target info
	register_clcmd("say", "say_info");

	// Event
	g_event = false

	// Powers
   	RegisterHam(Ham_Touch, "player", "HAM_Player_Touch", 1)
	register_forward(FM_PlayerPostThink, "WallHPWR") 
	register_clcmd("blinkpw", "ultbl")
	register_clcmd("chainpw", "ultch")
	register_concmd("amx_sethp", "SetHP", ADMIN_RCON, "use to give HP Level")
	register_concmd("amx_setarmor", "SetArmor", ADMIN_RCON, "use to give Armor Level")
	register_concmd("amx_setspeed", "SetSpeed", ADMIN_RCON, "use to give Speed Level")
	register_concmd("amx_setblink", "SetBlink", ADMIN_RCON, "use to give Blink Level")
	register_concmd("amx_setchain", "SetChain", ADMIN_RCON, "use to give Thunderbolt Level")
	register_concmd("amx_setwallh", "SetWallH", ADMIN_RCON, "use to give Wall Hang Level")
	register_concmd("amx_setaspirine", "SetAspirine", ADMIN_RCON, "use to give Aspirine Level")

	// Admin Give [2]
	register_concmd("amx_givebonus", "CmdBonus", ADMIN_LEVEL_B, "<*/name> <amount to set/+/-> <amount>")
	register_concmd("amx_set_level", "CmdSetLevel", ADMIN_RCON, "<*/name> <amount to set/+/-> <amount>")
	register_concmd("zp_ammo_e_self", "give_packs_e_self", ADMIN_LEVEL_H, " - zp_ammo_e_self <amount>");
	register_concmd("amx_set_ampks", "CmdSetAmpks", ADMIN_RCON, "<*/name> <amount to set/+/-> <amount>")
	register_concmd("amx_set_points", "CmdSetPoints", ADMIN_RCON, "<*/name> <amount to set/+/-> <amount>")
	register_concmd("zp_points_e_self", "give_points_e_self", ADMIN_LEVEL_G, " - zp_points_e_self <amount>")
	register_concmd("amx_set_coins", "CmdSetCoins", ADMIN_RCON, "<*/name> <amount to set/+/-> <amount>")
	register_concmd("zp_coins_e_self", "give_coins_e_self", ADMIN_LEVEL_F, " - zp_coins_e_self <amount>")
	register_concmd("amx_set_xp", "CmdSetXP", ADMIN_RCON, "<*/name> <amount to set/+/-> <amount>")

	// Donate Packs & points
	register_clcmd("donatepacks","DonatePacks");
	register_clcmd("Packs_amount", "dPacks" , ADMIN_ALL, "")
	register_clcmd("donatexp","DonateXP");
	register_clcmd("XP_amount", "dXP" , ADMIN_ALL, "")
	register_clcmd("donatepoints","DonatePoints");
	register_clcmd("Points_amount", "dPoints" , ADMIN_ALL, "")
	register_clcmd("donatecoins","DonateCoins");
	register_clcmd("Coins_amount", "dCoins" , ADMIN_ALL, "")

	// Register System
	register_concmd("amx_reloadrn", "reload_rn_cmd", ADMIN_RCON);
	register_forward(FM_ClientUserInfoChanged, "fwd_ClientUserInfoChangedPost", false);
	g_aData = ArrayCreate(eRegisterInfos);
	register_clcmd("say /reg", "ClCmdSayRegisterNick");
	register_clcmd("say /register", "ClCmdSayRegisterNick");
	register_clcmd("say /inregistrare", "ClCmdSayRegisterNick");
	register_clcmd("say /rezervare", "ClCmdSayRegisterNick");
	register_clcmd("RN_SetPassword", "__RN_SetPassword")
        register_clcmd("ChangePassword", "__ChangePassword")
	get_time("%d.%m.%Y", datestr, 11)
	formatex(logname, 64, "zc_nickreg_%s.log", datestr)

	// Exchange System
	register_clcmd("Points_wanted", "patopo" , ADMIN_ALL, "")
	register_clcmd("Points_to_packs", "potopa" , ADMIN_ALL, "")
	register_clcmd("Coins_wanted", "patoco" , ADMIN_ALL, "")
	register_clcmd("Coins_to_packs", "cotopa" , ADMIN_ALL, "")
	register_clcmd("Points_wanted_coins", "cotopo" , ADMIN_ALL, "")
	register_clcmd("Points_to_coins", "potoco" , ADMIN_ALL, "")
	register_clcmd("XP_to_Packs", "xptopa" , ADMIN_ALL, "")
	register_clcmd("XP_to_Points", "xptopo" , ADMIN_ALL, "")
	register_clcmd("XP_to_Coins", "xptoco" , ADMIN_ALL, "")

	// Coins Shop
	register_clcmd("say /announce" , "announce_mode" , -1);
	register_concmd("amx_removeannounce", "announce_remove", ADMIN_KICK, "Stop announces made <reason>")
	register_clcmd("amx_slot_password", "model", ADMIN_USER, "<password>");
	register_clcmd("amx_vipb_password", "vipb", ADMIN_USER, "<password>");

	// Message IDs
	g_msgScoreInfo = get_user_msgid("ScoreInfo")
	g_msgTeamInfo = get_user_msgid("TeamInfo")
	g_msgDeathMsg = get_user_msgid("DeathMsg")
	g_msgScoreAttrib = get_user_msgid("ScoreAttrib")
	g_msgSetFOV = get_user_msgid("SetFOV")
	g_msgScreenFade = get_user_msgid("ScreenFade")
	g_msgScreenShake = get_user_msgid("ScreenShake")
	g_msgNVGToggle = get_user_msgid("NVGToggle")
	g_msgFlashlight = get_user_msgid("Flashlight")
	g_msgFlashBat = get_user_msgid("FlashBat")
	g_msgAmmoPickup = get_user_msgid("AmmoPickup")
	g_msgDamage = get_user_msgid("Damage")
	g_msgSayText = get_user_msgid("SayText")
	g_msgCurWeapon = get_user_msgid("CurWeapon")
	
	// Message hooks
	register_message(g_msgCurWeapon, "message_cur_weapon")
	register_message(get_user_msgid("Money"), "message_money")
	register_message(get_user_msgid("Health"), "message_health")
	register_message(g_msgFlashBat, "message_flashbat")
	register_message(g_msgScreenFade, "message_screenfade")
	register_message(g_msgNVGToggle, "message_nvgtoggle")
	if (g_handle_models_on_separate_ent) register_message(get_user_msgid("ClCorpse"), "message_clcorpse")
	register_message(get_user_msgid("WeapPickup"), "message_weappickup")
	register_message(g_msgAmmoPickup, "message_ammopickup")
	register_message(get_user_msgid("Scenario"), "message_scenario")
	register_message(get_user_msgid("HostagePos"), "message_hostagepos")
	register_message(get_user_msgid("TextMsg"), "message_textmsg")
	register_message(get_user_msgid("SendAudio"), "message_sendaudio")
	register_message(get_user_msgid("TeamScore"), "message_teamscore")
	register_message(g_msgTeamInfo, "message_teaminfo")
	
	// CVARS - General Purpose
	cvar_lighting = register_cvar("zp_lighting", "a")

	// CVARS - Others
	register_cvar("zc_version", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY)
	register_cvar("zc_author", PLUGIN_AUTHOR_EXTERN, FCVAR_SERVER|FCVAR_SPONLY)
	set_cvar_string("zc_version", PLUGIN_VERSION)
	set_cvar_string("zc_author", PLUGIN_AUTHOR_EXTERN)
	
	// Custom Forwards
	g_fwRoundStart = CreateMultiForward("zp_round_started", ET_IGNORE, FP_CELL, FP_CELL)
	g_fwRoundEnd = CreateMultiForward("zp_round_ended", ET_IGNORE, FP_CELL)
	g_fwUserSpawned_pre = CreateMultiForward("zp_user_spawned_pre", ET_IGNORE, FP_CELL)
	g_fwUserSpawned_post = CreateMultiForward("zp_user_spawned_post", ET_IGNORE, FP_CELL)
	g_fwUserInfected_pre = CreateMultiForward("zp_user_infected_pre", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL)
	g_fwUserInfected_post = CreateMultiForward("zp_user_infected_post", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL)
	g_fwUserHumanized_pre = CreateMultiForward("zp_user_humanized_pre", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL)
	g_fwUserHumanized_post = CreateMultiForward("zp_user_humanized_post", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL)
	g_fwUserInfect_attempt = CreateMultiForward("zp_user_infect_attempt", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL)
	g_fwUserHumanize_attempt = CreateMultiForward("zp_user_humanize_attempt", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL)
	g_fwExtraItemSelected = CreateMultiForward("zp_extra_item_selected", ET_CONTINUE, FP_CELL, FP_CELL)
	g_fwUserUnfrozen = CreateMultiForward("zp_user_unfrozen", ET_IGNORE, FP_CELL)
	g_fwUserLastZombie = CreateMultiForward("zp_user_last_zombie", ET_IGNORE, FP_CELL)
	g_fwUserLastHuman = CreateMultiForward("zp_user_last_human", ET_IGNORE, FP_CELL)
	g_fwUserInfectedByBombNative = CreateMultiForward("zp_user_infected_bybomb_native", ET_CONTINUE, FP_CELL) 
	g_fwHClassParam = CreateMultiForward("zp_hclass_param", ET_IGNORE, FP_CELL) 
	g_fwRespawnMenuZM = CreateMultiForward("zp_respawn_menu_zm", ET_CONTINUE, FP_CELL)
	g_fwRespawnMenuHM = CreateMultiForward("zp_respawn_menu_hm", ET_CONTINUE, FP_CELL)
	
	// Collect random spawn points
	load_spawns()
	
	// Set a random skybox?
	if (g_sky_enable)
	{
		new sky[32]
		ArrayGetString(g_sky_names, random_num(0, ArraySize(g_sky_names) - 1), sky, charsmax(sky))
		set_cvar_string("sv_skyname", sky)
	}
	
	// Disable sky lighting so it doesn't mess with our custom lighting
	set_cvar_num("sv_skycolor_r", 0)
	set_cvar_num("sv_skycolor_g", 0)
	set_cvar_num("sv_skycolor_b", 0)
	
	// Create the HUD Sync Objects
	g_MsgSync2 = CreateHudSyncObj()
	g_MsgSync3 = CreateHudSyncObj()
	
	// Format mod name
	formatex(g_modname, charsmax(g_modname), "Zombie Crown XP Mode v%s", PLUGIN_VERSION)
	
	// Get Max Players
	g_maxplayers = get_maxplayers()
}

// Client joins the game
public client_putinserver(id)
{
	// Plugin disabled?
	if (!g_pluginenabled) return;
	
	// Cache player's name
	get_user_name(id, g_playername[id], charsmax(g_playername[]))
	get_user_ip(id, g_playerip[id], 16, 1);

	// Bugfix
	if(contain(g_playername[id], "`") != -1 || contain(g_playername[id], "'") != -1)
	{
		server_cmd("kick #%d ^"Your nickname must not contain the characters: ' `^"", get_user_userid(id))
		return;
	}
	
	// Player joined
	g_isconnected[id] = true
	
	// Initialize player vars
	reset_vars(id, 1)

	// Points Task
	set_task(float(zc_points_minutes*60), "PointsAdd", id+TASK_PADD,_,_, "b")

	// Bonus Task
	set_task(1200.0, "BonusAdd", id+TASK_BONUSADD,_,_, "b")

	// Combo Reset Task
	set_task(1.0, "ComboResetCheck", id+TASK_COMBO_RESET,_,_, "b")

	// Set the custom HUD display task
	set_task(1.0, "ShowHUD", id+TASK_SHOWHUD, _, _, "b")
		
	// Disable minmodels for clients to see zombies properly
	set_task(5.0, "disable_minmodels", id)

	// Load Dates
        load_stats(id)

	// Check for Bonus
	set_task(10.0, "Check_Time", id)

        LoadData(id)
        set_task(1.5, "Country_City", id)

	// VIP
	if(event_start == 1)
	{
		if(g_user_privileges[id] & FLAG_D)
		{
			return;
		}else{
			new fflags[10]
			get_pcvar_string(g_hour_flags, fflags, charsmax(fflags))
			g_user_privileges[id] = read_flags(fflags)
		}
   	}else{
		if(g_user_privileges[id] & FLAG_D)
		{
			is_vip_connected[id] = true
			g_iVIPCount++
			set_admin_msg()
		}
		if(g_iVIPCount == 0)
		{
			set_admin_msg()
		}
	}
}

public Country_City(id)
{
        if (!g_isconnected[id] || is_user_bot(id)) return 

        zp_colored_print(0, "^1Player^4 %s^1 connected from^x01 [^3%s^1]", g_playername[id], country[id])
}

// Client Disconnect
public fw_ClientDisconnect(id)
{
	// Check that we still have both humans and zombies to keep the round going
	if (g_isalive[id]) check_round(id)
	
	// Remove previous tasks
	remove_task(id+TASK_TEAM)
	remove_task(id+TASK_MODEL)
	remove_task(id+TASK_FLASH)
	remove_task(id+TASK_CHARGE)
	remove_task(id+TASK_SPAWN)
	remove_task(id+TASK_BLOOD)
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_BURN)
	remove_task(id+TASK_SHOWHUD)

	// Remove Flashlight Cone
	// set_cone_nodraw(id)

	// Remove NightVision
	g_hadnvision[id] = false
	set_user_nightvision(id, 0)

	// Remove Custom NVision
	if(g_hascnvision[id])
	{
		remove_task(id+TASK_CNVISION)
		activate_nv[id] = false
		g_hascnvision[id] = false
	}
	
	// Points
	remove_task(id+TASK_PADD)

	// Bonus
	remove_task(id+TASK_BONUSADD)

	// Models
	if (g_handle_models_on_separate_ent)
	{
		// Remove custom model entities
		fm_remove_model_ents(id)
	}

	// VIP
	jumpnum[id] = 0
	g_damage[id] = 0.0
	dojump[id] = false

	// Coins Shop
	if(g_announce_valid[id])
	{
		g_announce_valid[id] = false
		g_blockannounce = false 
		g_count_announces = 0
	}

	// Player left, clear cached flags
	g_isconnected[id] = false
	g_isbot[id] = false
	g_isalive[id] = false

	// FlashLight Cone
	// if (pev_valid(g_iLightConeIndex[id]))
	//	engfunc(EngFunc_RemoveEntity, g_iLightConeIndex[id])
	// g_iLightConeIndex[id] = 0
}

// Engine Client disconnect
public client_disconnect(id)
{
	// Save Dates
	

	// VIP HUD
	if(is_vip_connected[id])
	{
		is_vip_connected[id] = false
		g_iVIPCount--
		set_admin_msg()
	}
}

// Client left
public fw_ClientDisconnect_Post()
{
	// Last Zombie Check
	fnCheckLastZombie()
}


public load_stats(id)
{
	// Some init checks
	if(!is_user_valid_connected(id) || is_user_bot(id)) return;

}

public RegisterClient(FailState, Handle:Query, Error[], Errcode, Data[], DataSize)
{

	static id; id = Data[0]
	new i_hclass_id = -1
	new i_zclass_id = -1
	new hclass_n_f[32], zclass_n_f[32]

		g_ammopacks[id] = zc_starting_ammo_packs
		g_points[id] = 10
		g_coins[id] = 50
		g_xp[id] = 1
		g_level[id] = 5
		hp_l[id] = 0
		armor_l[id] = 0
		speed_l[id] = 0
		asp_l[id] = 0
		blink_l[id] = 0
		chain_l[id] = 0
		wallh_l[id] = 0
		g_zombieclassnext[id] = 0
		g_humanclassnext[id] = 0
		g_zombieclass[id] = 0
		g_humanclass[id] = 0

		// Initialize combo system
		g_playerCombo[id] = 0
		g_playerComboMultiplier[id] = 1
		g_playerComboLastKill[id] = 0.0
		g_playerMaxCombo[id] = 0

	return PLUGIN_CONTINUE
}





// Plugin CFG
public plugin_cfg()
{
	// Plugin disabled?
	if (!g_pluginenabled) return;
	
	// Prevent any more stuff from registering
	g_arrays_created = false

	// Lighting task
	lighting_effects(1)
	
	// Save customization data
	save_customization()
	
	// Cache CVARs after configs are loaded / call roundstart manually
	set_task(0.5, "cache_cvars")
	set_task(0.5, "event_round_start")
	set_task(0.5, "logevent_round_start")

	// Load Register Nicks
	LoadRegistrations()

	// Remove some HUDs
	set_task(3.0, "hudmanager")

	// Free VIP-Event Start
	set_task(0.6, "vevmanager")
}

// Remove HUD Task
public hudmanager()
{
	for(new i; i<Hide_Hud; i++) {
		if(get_pcvar_num(g_pCvars[i])) {
			g_bitHudFlags |= 1<<i
		}
	}
}

// Start Free-VIP Event Task
public vevmanager()
{
	static hour_str[3], get_hour, get_start, get_end
	get_time("%H", hour_str, 2)
	get_hour = str_to_num(hour_str)
	get_start = zc_vip_hour_init
	get_end = zc_vip_hour_end
   	if(get_start < get_end ? (get_start <= get_hour && get_hour < get_end) : (get_start <= get_hour || get_hour < get_end)) 
	{
        	if(event_start == 0) 
			event_start = 1
    	}else {
        	event_start = 0
    	}
}

// Flags Modes / VIP
public client_connect(id) 
{
	if(is_user_bot(id)) 
		return
	
	// Flags
	set_user_access(id)
	
	// VIP
	jumpnum[id] = 0
	g_damage[id] = 0.0
	dojump[id] = false
	set_flags(id)
}

// Show VIP HUD
public client_infochanged(id)
{
	if(!zc_vip_hud_enable) 
		return 

	if(is_vip_connected[id])
	{
		static NewName[32], OldName[32]
		get_user_info(id, "name", NewName, 31)
		get_user_name(id, OldName, 31)
		
		if(!equal(OldName, NewName))
		{
			g_bvipnick = true
		}
	}
}

public set_admin_msg()
{
	static g_iAdminName[32], pos, i
	pos = 0
	pos += formatex(g_msg[pos], 511-pos, "In game: %d VIP", g_iVIPCount)
	for(i = 1 ; i <= g_maxplayers ; i++)
	{	
		if(is_vip_connected[i])
		{
			get_user_name(i, g_iAdminName, 31)
			pos += formatex(g_msg[pos], 511-pos, "^n| %s", g_iAdminName)
		}
	}
}

public admins_online() 
{		
	if (g_iVIPCount > 0)
	{
		set_hudmessage(zc_vip_hud_color[0], zc_vip_hud_color[1], zc_vip_hud_color[2], zc_vip_hud_xpos, zc_vip_hud_ypos, 0, 6.0, 20.1)
		ShowSyncHudMsg(0, g_SyncVIP, "%s", g_msg)
	}else {
		set_hudmessage(zc_vip_hud_color[0], zc_vip_hud_color[1], zc_vip_hud_color[2], zc_vip_hud_xpos, zc_vip_hud_ypos, 0, 6.0, 20.1)
		ShowSyncHudMsg(0, g_SyncVIP, "%s", g_msg)
	}
} 

public set_free_message()
{
	new message[386]
	if(g_vevcommand)
	{
		set_hudmessage(zc_vip_hud_color[0], zc_vip_hud_color[1], zc_vip_hud_color[2], zc_vip_hud_xpos, zc_vip_hud_ypos, 0, 6.0, 20.1)
		formatex(message, charsmax(message), "++++++++++++++++++++++++^nFree V.I.P. event^n++++++++++++++++++++++++")
		ShowSyncHudMsg(0, g_SyncVIP, message)
	}else {
		set_hudmessage(zc_vip_hud_color[0], zc_vip_hud_color[1], zc_vip_hud_color[2], zc_vip_hud_xpos, zc_vip_hud_ypos, 0, 6.0, 20.1)
		formatex(message, charsmax(message), "++++++++++++++++++++++++^nFree V.I.P. event^nStart: %d:00 : End: %d:00^n++++++++++++++++++++++++", zc_vip_hour_init, zc_vip_hour_end)
		ShowSyncHudMsg(0, g_SyncVIP, message)
	}
}

public ForwardThink(iEnt)
{
	if(!zc_vip_hud_enable) 
		return 

	if(event_start == 0)
	{
		admins_online()
	}else{
		set_free_message()
	}
	
	if(g_bvipnick)
	{
		set_admin_msg()
		g_bvipnick = false
	}
        entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 2.0)
}

public zc_get_currmode()
{
       static currmode[25]
       if (g_newround) copy(currmode, 24, zc_currmode[0])
       else copy(currmode, 24, zc_currmode[g_lastmode])

       return currmode
}

/*================================================================================
 [Modes accesses flags]
=================================================================================*/
public set_user_access(id) 
{
	static ip[31], name[32], index, client_password[30], size
	get_user_ip(id, ip, 30, 1)
	get_user_name(id, name, 31)
	get_user_info(id, zc_password_sf, client_password, charsmax(client_password))
	
	g_privileges[id] = 0
	size = ArraySize(zc_db_holder)
	for(index=0; index < size; index++) 
	{
		ArrayGetArray(zc_db_holder, index, zc_database)
		if(equali(name, zc_database[zckey])) 
		{
			if(!(zc_database[zcflags] & MODE_FLAG_E)) 
			{
				if(equal(client_password, zc_database[zcpass]))
				{
					g_privileges[id] = zc_database[zcaccessflags]
				}else if(!equal(client_password, zc_database[zcpass]) && (zc_database[zcflags] & MODE_FLAG_A)) {
					server_cmd("kick #%d ^"Invalid password.^"", get_user_userid(id))
					break
				}
			}else { 
				g_privileges[id] = zc_database[zcaccessflags]
			}
		}
	}
}

public reload_acc_cmd(id, level, cid)
{
	if(!cmd_access(id , level , cid, 1)) 
		return PLUGIN_HANDLED;

	reload_accesses()
	server_print("[ZC] The accesses file was reloaded.")
	client_print(id, print_console, "[ZC] The accesses file was reloaded.")
	for(new i = 1; i <= g_maxplayers; i++) 
	{
		if(is_user_valid_connected(i)) {
			set_task(2.0, "set_user_access", i)
		}
	}
	return PLUGIN_HANDLED;
}

public reload_accesses()
{
	// Remove current database
	if(zc_db_holder)
		ArrayDestroy(zc_db_holder)

	// Create new database
	zc_db_holder = ArrayCreate(database_zcm)
	new configsDir[64]
	get_configsdir(configsDir, 63)
	format(configsDir, 63, "%s/zombie_crown/zc_accesses.ini", configsDir)
	new File=fopen(configsDir, "r")
	
	if (File)
	{
		static date[1024], getflag[32], getauth[50], get_privileges[32], get_password[50]
		while (!feof(File))
		{
			fgets(File,date,sizeof(date)-1);
			trim(date)

			if (date[0]==';') 
			{
				continue
			}
			
			getflag[0] = 0
			getauth[0] = 0
			get_privileges[0] = 0
			get_password[0] = 0

			if (parse(date, getauth, sizeof(getauth) - 1, get_password, sizeof(get_password) - 1, get_privileges, sizeof(get_privileges) - 1, getflag, sizeof(getflag) - 1) < 2)
			{
				continue;
			}

			zc_database[zckey] = getauth
			zc_database[zcpass] = get_password
			zc_database[zcaccessflags] = read_flags(get_privileges)
			zc_database[zcflags] = read_flags(getflag)
			ArrayPushArray(zc_db_holder, zc_database)
		}
		fclose(File);
	}
	else log_amx("Error: zc_accesses.ini file doesn't exist")
}

/*================================================================================
 [Main Events]
=================================================================================*/

// Event Round Start
public event_round_start()
{
	// Remove doors/lights?
	set_task(0.1, "remove_stuff")
	
	// New round starting
	g_newround = true
	g_endround = false
	g_survround = false
	g_nemround = false
	g_swarmround = false
	g_plagueround = false
	g_sniperround = false
	g_assassinround = false
	g_oberonround = false
	g_dragonround = false
	g_nighterround = false
	g_flamerround = false
	g_zadocround = false
	g_modestarted = false
	g_lnjround = false
	g_guardiansround = false
	g_genesysround = false
	
	// Freezetime begins
	g_freezetime = true
	
	// Show welcome message and T-Virus notice
	remove_task(TASK_WELCOMEMSG)
	set_task(2.0, "welcome_msg", TASK_WELCOMEMSG)
	
	// Set a new "Make Zombie Task"
	remove_task(TASK_MAKEZOMBIE)
	set_task(2.0 + zc_delay, "make_zombie_task", TASK_MAKEZOMBIE)

	// Items restrictions
	if (file_exists("addons/amxmodx/data/save/limiter_round.txt"))
	{
		delete_file("addons/amxmodx/data/save/limiter_round.txt")
	}

	// CountDown
	remove_task(TASKID_COUNTDOWN)
	if(zc_countdown) 
	{
		CountDownDelay = 9;	
		TASK_CountDown();
	}

	// Powers
	for(new idp = 1; idp <= g_maxplayers; idp++)  
	{
		if(is_user_valid_connected(idp)) 
		{
			if(blink_can[idp]) blink_can[idp] = false
			if(blink_used[idp] > 0) blink_used[idp] = 0
			if(chain_can[idp]) chain_can[idp] = false
			if(chain_used[idp] > 0) chain_used[idp] = 0
			if(wh_used[idp] > 0) wh_used[idp] = 0
		}
	}

	// VIP
	static string[5]
	get_pcvar_string(g_allow_jump, string, charsmax(string))
	g_bit = read_flags(string)
	chache_g_jumps = zc_vip_jumps
	chache_gp_jumps = zc_player_jumps

	// Coins Shop
	for(new idc = 1; idc <= g_maxplayers; idc++) 
	{
		if(is_user_valid_connected(idc)) 
		{
			fm_set_user_rendering(idc, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 255)  
			used[idc] = false

			// Modes
			if(g_announce_valid[idc])
			{
				if(g_count_announces == 3)
					set_task(8.0, "check_ann_count", idc)
				else if(g_count_announces == 2)
					set_task(3.0, "check_ann_count", idc)
				else if(g_count_announces == 1)
					set_task(3.0, "check_ann_count", idc)
				else if(g_count_announces == 0)
					set_task(2.5, "check_ann_count", idc)
			}
		}
	}

	// Guardians Mode reset
	for(new id = 1; id <= g_maxplayers; id++) 
	{
		remove_task(id+TASK_EVIL_SHOW)
		remove_task(id+TASK_EVIL_POWER)
		g_evolve[id] = 0
	}
}

// Log Event Round Start
public logevent_round_start()
{
	// Freezetime ends
	g_freezetime = false

	// Lighting Effect
	if(g_lastmode == MODE_ASSASSIN)
	{
		lighting_effects(1)
	}
}

// Log Event Round End
public logevent_round_end()
{
	// Prevent this from getting called twice when restarting (bugfix)
	static Float:lastendtime, Float:current_time
	current_time = get_gametime()
	if (current_time - lastendtime < 0.5) return;
	lastendtime = current_time			
		
	// Round ended
	g_endround = true

	// Guardians mode
	g_heronum = 0
	
	// Stop old tasks (if any)
	remove_task(TASK_WELCOMEMSG)
	remove_task(TASK_MAKEZOMBIE)

	// Nighter Mode HUD reset
	remove_task(TASK_NCHILDS_SHOW)
	nighterindex = 0
	g_nchilds_num = 0
	
	// Stop ambience sounds
	if ((g_ambience_sounds[AMBIENCE_SOUNDS_NEMESIS] && g_nemround) || (g_ambience_sounds[AMBIENCE_SOUNDS_SURVIVOR] && g_survround) || (g_ambience_sounds[AMBIENCE_SOUNDS_SWARM] && g_swarmround) || (g_ambience_sounds[AMBIENCE_SOUNDS_PLAGUE] && g_plagueround)
	|| (g_ambience_sounds[AMBIENCE_SOUNDS_INFECTION] && !g_nemround && !g_survround && !g_swarmround && !g_plagueround && !g_sniperround && !g_assassinround && !g_oberonround && !g_dragonround && !g_nighterround && !g_flamerround && !g_zadocround && !g_genesysround && !g_lnjround && !g_guardiansround) 
	|| (g_ambience_sounds[AMBIENCE_SOUNDS_SNIPER] && g_sniperround) || (g_ambience_sounds[AMBIENCE_SOUNDS_ASSASSIN] && g_assassinround) || (g_ambience_sounds[AMBIENCE_SOUNDS_OBERON] && g_oberonround) || (g_ambience_sounds[AMBIENCE_SOUNDS_DRAGON] && g_dragonround) || (g_ambience_sounds[AMBIENCE_SOUNDS_NIGHTER] && g_nighterround)
	|| (g_ambience_sounds[AMBIENCE_SOUNDS_FLAMER] && g_flamerround) || (g_ambience_sounds[AMBIENCE_SOUNDS_ZADOC] && g_zadocround) || (g_ambience_sounds[AMBIENCE_SOUNDS_GENESYS] && g_genesysround) || (g_ambience_sounds[AMBIENCE_SOUNDS_LNJ] && g_lnjround) || (g_ambience_sounds[AMBIENCE_SOUNDS_GUARDIANS] && g_guardiansround))
	{
		remove_task(TASK_AMBIENCESOUNDS)
		ambience_sound_stop()
	}
	
	// Show HUD notice, play win sound, update team scores...
	static sound[64]
	if (!fnGetZombies())
	{		
		// Play win sound and increase score
		ArrayGetString(sound_win_humans, random_num(0, ArraySize(sound_win_humans) - 1), sound, charsmax(sound))
		PlaySound(sound)
		g_scorehumans++
		
		// Round end forward
		ExecuteForward(g_fwRoundEnd, g_fwDummyResult, ZP_TEAM_HUMAN);
	}
	else if (!fnGetHumans())
	{
		// Play win sound and increase score
		ArrayGetString(sound_win_zombies, random_num(0, ArraySize(sound_win_zombies) - 1), sound, charsmax(sound))
		PlaySound(sound)
		g_scorezombies++
		
		// Round end forward
		ExecuteForward(g_fwRoundEnd, g_fwDummyResult, ZP_TEAM_ZOMBIE);
	}
	else if (zc_human_survive == 1)
	{
		// Play win sound and increase human score
		ArrayGetString(sound_win_humans, random_num(0, ArraySize(sound_win_humans) - 1), sound, charsmax(sound))
		PlaySound(sound)
		g_scorehumans++
		
		// Round end forward (will remain same)
		ExecuteForward(g_fwRoundEnd, g_fwDummyResult, ZP_TEAM_NO_ONE);
	}
	else 
	{	
		// Play win sound and increase human score
		ArrayGetString(sound_win_no_one, random_num(0, ArraySize(sound_win_no_one) - 1), sound, charsmax(sound))
		PlaySound(sound)
		
		// Round end forward
		ExecuteForward(g_fwRoundEnd, g_fwDummyResult, ZP_TEAM_NO_ONE);
	}
	
	// Balance the teams
	balance_teams()
}

// Event Map Ended
public event_intermission()
{
	// Remove ambience sounds task
	remove_task(TASK_AMBIENCESOUNDS)
}

// BP Ammo update
public event_ammo_x(id)
{
	// Humans only
	if (g_zombie[id] || g_zadoc[id])
		return;
	
	// Get ammo type
	static type
	type = read_data(1)
	
	// Unknown ammo type
	if (type >= sizeof AMMOWEAPON)
		return;
	
	// Get weapon's id
	static weapon
	weapon = AMMOWEAPON[type]
	
	// Primary and secondary only
	if (MAXBPAMMO[weapon] <= 2)
		return;
	
	// Get ammo amount
	static amount
	amount = read_data(2)
	
	// Unlimited BP Ammo?
	if (g_survivor[id] ? zc_surv_unlimited_ammo : zc_human_unlimited_ammo || g_sniper[id] ? zc_sniper_unlimited_ammo : zc_human_unlimited_ammo || g_hero[id] ? zc_hero_unlimited_ammo : zc_human_unlimited_ammo)
	{
		if (amount < MAXBPAMMO[weapon])
		{
			// The BP Ammo refill code causes the engine to send a message, but we
			// can't have that in this forward or we risk getting some recursion bugs.
			// For more info see: https://bugs.alliedmods.net/show_bug.cgi?id=3664
			static args[1]
			args[0] = weapon
			set_task(0.1, "refill_bpammo", id, args, sizeof args)
		}
	}
	
	// Bots automatically buy ammo when needed
	if (g_isbot[id] && amount <= BUYAMMO[weapon])
	{
		// Task needed for the same reason as above
		set_task(0.1, "clcmd_buyammo", id)
	}
}

/*================================================================================
 [Main Forwards]
=================================================================================*/

// Entity Spawn Forward
public fw_Spawn(entity)
{
	// Invalid entity
	if (!pev_valid(entity)) return FMRES_IGNORED;
	
	// Get classname
	new classname[32], objective[32], size = ArraySize(g_objective_ents)
	pev(entity, pev_classname, classname, charsmax(classname))
	
	// Check whether it needs to be removed
	for (new i = 0; i < size; i++)
	{
		ArrayGetString(g_objective_ents, i, objective, charsmax(objective))
		
		if (equal(classname, objective))
		{
			engfunc(EngFunc_RemoveEntity, entity)
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}

// Sound Precache Forward
public fw_PrecacheSound(const sound[])
{
	// Block all those unneeeded hostage sounds
	if (equal(sound, "hostage", 7))
		return FMRES_SUPERCEDE;
	
	return FMRES_IGNORED;
}

// Ham Player Spawn Post Forward
public fw_PlayerSpawn_Post(id)
{
	// Pre user spawn forward
	ExecuteForward(g_fwUserSpawned_pre, g_fwDummyResult, id)

	// Not alive or didn't join a team yet
	if (!is_user_alive(id) || !fm_cs_get_user_team(id))
		return;
	
	// Player spawned
	g_isalive[id] = true

	// Level & class check
	for (new class = 0; class < g_zclass_i; class++)
	{
		if(class == g_zombieclass[id])
		{
			if(ArrayGetCell(g_zclass_level, class) > g_level[id])
			{
				g_zombieclassnext[id] = ZCLASS_NONE
				zp_colored_print(id, "^x04[ZC]^x01 Your class was resetted because your^x03 level^x01 is too^x04 low^x01.")
			}
		}
	}

	for (new class = 0; class < g_hclass_i; class++)
	{
		if(class == g_humanclass[id])
		{
			if(ArrayGetCell(g_hclass_level, class) > g_level[id])
			{
				g_humanclassnext[id] = HCLASS_NONE
				zp_colored_print(id, "^x04[ZC]^x01 Your class was resetted because your^x03 level^x01 is too^x04 low^x01.")
			}
		}
	}
	
	// Remove previous tasks
	remove_task(id+TASK_SPAWN)
	remove_task(id+TASK_MODEL)
	remove_task(id+TASK_BLOOD)
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_BURN)
	remove_task(id+TASK_CHARGE)
	remove_task(id+TASK_FLASH)

	// Remove Flashlight Cone
	// set_cone_nodraw(id)
	
	// Respawn player if he dies because of a worldspawn kill?
	if (zc_respawn_on_worldspawn_kill)
		set_task(2.0, "respawn_player_task", id+TASK_SPAWN)
	
	// Spawn as zombie?
	if (g_respawn_as_zombie[id])
	{
		// Spawn as nemesis on LNJ round?
		if (!g_newround && (g_lnjround && zc_lnj_respawn_nem))
		{
			reset_vars(id, 0) // reset player vars
			zombieme(id, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0) // make him nemesis right away
			
			// Apply the nemesis health multiplier
			fm_set_user_health(id, floatround(float(pev(id, pev_health)) * zc_lnj_nem_hp_multi))
			return;
		}
		else if (!g_newround && g_nighterround)
		{
			// Continue respawning
			reset_vars(id, 0) // reset player vars
			zombieme(id, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0) // make him nchild right away
			return;
		}
		else if (!g_newround && !g_nighterround)
		{
			reset_vars(id, 0) // reset player vars
			zombieme(id, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0) // make him zombie right away
			return;
		}
		
	}
	// Spawn as survivor on LNJ round?
	if (!g_respawn_as_zombie[id] && !g_newround && g_lnjround && zc_lnj_respawn_surv)
	{
		reset_vars(id, 0) // reset player vars
		humanme(id, 1, 0, 0, 0, 0, 0) // make him survivor right away
		
		fm_set_user_health(id, floatround(float(pev(id, pev_health)) * zc_lnj_surv_hp_multi))
		return;
	}
	
	// Reset player vars
	reset_vars(id, 0)
	
	// Show custom buy menu?
	if (zc_buy_custom)
		set_task(0.2, "show_menu_buy1", id+TASK_SPAWN)

        // Show human class menu if they haven't chosen any (e.g. just connected)
	if (g_humanclassnext[id] == HCLASS_NONE && zc_human_classes)
		set_task(3.0, "show_menu_hclass", id)

	// Set selected human class
	g_humanclass[id] = g_humanclassnext[id]

	// If no class selected yet, use the first (default) one
	if (g_humanclass[id] == HCLASS_NONE) g_humanclass[id] = 0	

        // Cache speed, and name for player's class
	g_human_spd[id] = float(ArrayGetCell(g_hclass_spd, g_humanclass[id]))+(speed_l[id]*zc_powers_speed_rate)	
	ArrayGetString(g_hclass_name, g_humanclass[id], g_human_classname[id], charsmax(g_human_classname[]))
	
	// Set health and gravity, unless frozen
	fm_set_user_health(id, ArrayGetCell(g_hclass_hp, g_humanclass[id]) + hp_l[id]*zc_powers_hp_rate)
	set_pev(id, pev_gravity, Float:ArrayGetCell(g_hclass_grav, g_humanclass[id]))
        set_task(2.0, "armpwr", id)

	// Switch to CT if spawning mid-round
	if (!g_newround && fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
	{
		remove_task(id+TASK_TEAM)
		fm_cs_set_user_team(id, FM_CS_TEAM_CT)
		fm_user_team_update(id)
	}
	
	// Custom models stuff
	static currentmodel[32], tempmodel[32], already_has_model, i, iRand, size
	already_has_model = false
	
	if (g_handle_models_on_separate_ent)
	{
		// Set the right model
		if (zc_admin_models_human && ((g_privileges[id] & g_access_flag[ACCESS_ADMIN_MODELS]) || (g_user_privileges[id] & FLAG_D)))
		{
			if ((g_user_privileges[id] & FLAG_D))
			{
				iRand = random_num(0, ArraySize(model_vip_human) - 1)
				ArrayGetString(model_vip_human, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_admin_human, iRand))
			}

			else if ((g_privileges[id] & g_access_flag[ACCESS_ADMIN_MODELS]))
			{
				iRand = random_num(0, ArraySize(model_admin_human) - 1)
				ArrayGetString(model_admin_human, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_admin_human, iRand))
			}
		}
		else
		{
			iRand = random_num(ArrayGetCell(g_hclass_modelsstart, g_humanclass[id]), ArrayGetCell(g_hclass_modelsend, g_humanclass[id]) - 1)
			ArrayGetString(g_hclass_playermodel, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_hclass_modelindex, iRand))
		}
		
		// Set model on player model entity
		fm_set_playermodel_ent(id)
		
		// Remove glow on player model entity
		fm_set_rendering(g_ent_playermodel[id])
	}
	else
	{
		// Get current model for comparing it with the current one
		fm_cs_get_user_model(id, currentmodel, charsmax(currentmodel))
		
		// Set the right model, after checking that we don't already have it
		if (zc_admin_models_human && ((g_privileges[id] & g_access_flag[ACCESS_ADMIN_MODELS]) || (g_user_privileges[id] & FLAG_D)))
		{
			if ((g_user_privileges[id] & FLAG_D))
			{
				size = ArraySize(model_vip_human)
				for (i = 0; i < size; i++)
				{
					ArrayGetString(model_vip_human, i, tempmodel, charsmax(tempmodel))
					if (equal(currentmodel, tempmodel)) already_has_model = true
				}
				
				if (!already_has_model)
				{
					iRand = random_num(0, size - 1)
					ArrayGetString(model_vip_human, iRand, g_playermodel[id], charsmax(g_playermodel[]))
					if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_admin_human, iRand))
				}
			}
			else if ((g_privileges[id] & g_access_flag[ACCESS_ADMIN_MODELS]))
			{
				size = ArraySize(model_admin_human)
				for (i = 0; i < size; i++)
				{
					ArrayGetString(model_admin_human, i, tempmodel, charsmax(tempmodel))
					if (equal(currentmodel, tempmodel)) already_has_model = true
				}
				
				if (!already_has_model)
				{
					iRand = random_num(0, size - 1)
					ArrayGetString(model_admin_human, iRand, g_playermodel[id], charsmax(g_playermodel[]))
					if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_admin_human, iRand))
				}
			}
		}
		else
		{
			for (i = ArrayGetCell(g_hclass_modelsstart, g_humanclass[id]); i < ArrayGetCell(g_hclass_modelsend, g_humanclass[id]); i++)
			{
				ArrayGetString(g_hclass_playermodel, i, tempmodel, charsmax(tempmodel))
				if (equal(currentmodel, tempmodel)) already_has_model = true
			}
				
			if (!already_has_model)
		        {
				iRand = random_num(ArrayGetCell(g_hclass_modelsstart, g_humanclass[id]), ArrayGetCell(g_hclass_modelsend, g_humanclass[id]) - 1)
				ArrayGetString(g_hclass_playermodel, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_hclass_modelindex, iRand))
			}
		}
		
		// Need to change the model?
		if (!already_has_model)
		{
			// An additional delay is offset at round start
			// since SVC_BAD is more likely to be triggered there
			if (g_newround)
				set_task(5.0 * g_modelchange_delay, "fm_user_model_update", id+TASK_MODEL)
			else
				fm_user_model_update(id+TASK_MODEL)
		}
		
		// Remove glow
		fm_set_rendering(id)
	}
	
	// Bots stuff
	if (g_isbot[id])
	{
		// Turn off NVG for bots
		cs_set_user_nvg(id, 0)
		
		// Automatically buy extra items/weapons after first zombie is chosen
		if (zc_extra_items)
		{
			if (g_newround) set_task(10.0 + zc_delay, "bot_buy_extras", id+TASK_SPAWN)
			else set_task(10.0, "bot_buy_extras", id+TASK_SPAWN)
		}
	}
	
	// Enable spawn protection for humans spawning mid-round
	if (!g_newround && zc_spawn_protection > 0.0)
	{
		// Do not take damage
		g_nodamage[id] = true
		
		// Make temporarily invisible
		set_pev(id, pev_effects, pev(id, pev_effects) | EF_NODRAW)
		
		// Set task to remove it
		set_task(1.0+zc_spawn_protection, "remove_spawn_protection", id+TASK_SPAWN)
	}
	
	// Set the flashlight charge task to update battery status
	if (g_cached_customflash)
		set_task(1.0, "flashlight_charge", id+TASK_CHARGE, _, _, "b")
	
	// Replace weapon models (bugfix)
	static weapon_ent
	weapon_ent = fm_cs_get_current_weapon_ent(id)
	if (pev_valid(weapon_ent)) replace_weapon_models(id, cs_get_weapon_id(weapon_ent))

        // Post user spawn forward
	ExecuteForward(g_fwUserSpawned_post, g_fwDummyResult, id)

	// Remove NightVision
	set_user_nightvision(id, 0)
	g_hadnvision[id] = false

	// Remove Custom NVision
	if(g_hascnvision[id])
	{
		remove_task(id+TASK_CNVISION)
		activate_nv[id] = false
		g_hascnvision[id] = false
	}

	// Enable HClasses Params
	ExecuteForward(g_fwHClassParam, g_fwDummyResult, id)

	// If player is VIP, he will get free NightVision
	if (g_user_privileges[id] & FLAG_B)
	{
		g_hadnvision[id] = true
	}

	// Last Zombie Check
	fnCheckLastZombie()

	// Flamer Mode
	if(g_lastmode == MODE_FLAMER)
	{
		if(g_had_salamander[id])
			g_had_salamander[id] = false
		if(task_exists(id+TASK_FIRE)) 
			remove_task(id+TASK_FIRE)
		if(task_exists(id+TASK_RELOAD)) 
			remove_task(id+TASK_RELOAD)
		remove_entity_name(fire_classname)
	}

	// VIP
	if (!native_get_zombie_hero(id) && !native_get_human_hero(id) && g_user_privileges[id] & FLAG_A) 
	{
		if(event_start == 1)
		{ 
			if(g_user_privileges[id] & FLAG_D)
				set_pev(id, pev_armorvalue, float(zc_vip_armor))
			else
				set_pev(id, pev_armorvalue, float(zc_vip_armor_happy))
		}else if(event_start == 0){
			set_pev(id, pev_armorvalue, float(zc_vip_armor))
		}
	}
}

// Remove some HUDs
public Event_ResetHUD(id)
{
	if(g_bitHudFlags)
	{
		set_pdata_int(id, m_iClientHideHUD, 0)
		set_pdata_int(id, m_iHideHUD, g_bitHudFlags)
	}	
}

public Event_HideWeapon(id)
{
	new iFlags = read_data(1)
	if(g_bitHudFlags && (iFlags & g_bitHudFlags != g_bitHudFlags))
	{
		set_pdata_int(id, m_iClientHideHUD, 0)
		set_pdata_int(id, m_iHideHUD, iFlags|g_bitHudFlags)
	}

	if(iFlags & HIDE_GENERATE_CROSSHAIR && !(g_bitHudFlags & HUD_DRAW_CROSS) && is_user_alive(id))
	{
		set_pdata_cbase(id, m_pClientActiveItem, FM_NULLENT)
	}
}

// Ham Player Killed Forward
public fw_PlayerKilled(victim, attacker, shouldgib)
{
	// Player killed
	g_isalive[victim] = false

	// When a Nighter dies, the round is finishing
	if (g_nighter[victim] && g_nighterround)
	{
		remove_task(TASK_NCHILDS_SHOW)
		for(new kl = 1; kl <= g_maxplayers; kl++) 
		{
			if(g_nchild[kl]) user_silentkill(kl)
		}
	}

	// Guardians Mode HUD reset
	remove_task(victim+TASK_EVIL_SHOW)
	remove_task(victim+TASK_EVIL_POWER)
	
	// Disable nightvision when killed (bugfix)
	set_user_nightvision(victim, 0)
	g_hadnvision[victim] = false

	// Remove Custom NVision
	if(g_hascnvision[victim])
	{
		remove_task(victim+TASK_CNVISION)
		activate_nv[victim] = false
		g_hascnvision[victim] = false
	}

	// Enable dead players nightvision
	set_task(0.1, "spec_nvision", victim)
	
	// Turn off custom flashlight when killed
	if (g_cached_customflash)
	{
		// Turn it off
		g_flashlight[victim] = false
		g_flashbattery[victim] = 100
		
		// Remove previous tasks
		remove_task(victim+TASK_CHARGE)
		remove_task(victim+TASK_FLASH)
	}

	// Remove Flashlight Cone
	// set_cone_nodraw(victim)
	
	// Stop bleeding/burning/aura when killed
	if (g_zombie[victim] || g_survivor[victim] || g_sniper[victim] || g_flamer[victim] || g_zadoc[victim])
	{
		remove_task(victim+TASK_BLOOD)
		remove_task(victim+TASK_AURA)
		remove_task(victim+TASK_BURN)
	}
	
	// Nemesis explodes!
	if (g_nemesis[victim] || g_assassin[victim] || g_oberon[victim] || g_dragon[victim] || g_nighter[victim] || g_genesys[victim])
		SetHamParamInteger(3, 2)
	
	// Get deathmatch mode status and whether the player killed himself
	static selfkill
	selfkill = (victim == attacker || !is_user_valid_connected(attacker)) ? true : false
	
	// Killed by a non-player entity or self killed
	if (selfkill) return;

	// XP++
	static sk;
	sk = (victim == attacker || is_user_valid_connected(attacker)) ? true : false
	if (sk)
	{
		// Get XP
		if(native_get_human_hero(victim) || native_get_zombie_hero(victim)) 
			g_xp[attacker] += 1

		if(!(g_user_privileges[attacker] & FLAG_D))
		{
			if (g_zombie[victim] && !g_zombie[attacker]) g_xp[attacker] += zc_xp_step[0]
			else if (!g_zombie[victim] && g_zombie[attacker]) g_xp[attacker] += zc_xp_step[1]
		}else{
			if (g_zombie[victim] && !g_zombie[attacker]) g_xp[attacker] += zc_xp_step[2]
			else if (!g_zombie[victim] && g_zombie[attacker]) g_xp[attacker] += zc_xp_step[3]
		}

		// Level check
		if(g_level[attacker] < zc_max_level) {
			levelup(attacker)
		}

		// Guardians Mode
		if (g_evil[victim] && g_hero[attacker])
		{
			g_level[attacker] = g_level[attacker] + 1
			zp_colored_print(0, "^x04[ZC]^x01 Player^x03 %s^x01 got^x04 +1 level^x01 killing a^x04 Big Evil^x01.", g_playername[attacker])
		}

		// Combo System - Increment combo on kill
		g_playerCombo[attacker]++
		g_playerComboLastKill[attacker] = get_gametime()

		// Calculate combo multiplier
		new comboBonus = 0
		if (g_playerCombo[attacker] >= 2)
			g_playerComboMultiplier[attacker] = 1 + (g_playerCombo[attacker] / 5)
		else
			g_playerComboMultiplier[attacker] = 1

		// Apply combo bonus XP
		if (g_playerCombo[attacker] >= 2)
		{
			comboBonus = (zc_xp_step[0] * (g_playerCombo[attacker] / 2)) / 10
			g_xp[attacker] += comboBonus
		}

		// Track max combo
		if (g_playerCombo[attacker] > g_playerMaxCombo[attacker])
			g_playerMaxCombo[attacker] = g_playerCombo[attacker]

		// Show combo message
		if (g_playerCombo[attacker] >= 5 && g_playerCombo[attacker] % 5 == 0)
			zp_colored_print(attacker, "^x04[COMBO]^x01 %d kill streak! x%d.%d XP multiplier!", g_playerCombo[attacker], g_playerComboMultiplier[attacker], g_playerCombo[attacker] % 10)
	}

	// Reset combo on death
	g_playerCombo[victim] = 0
	g_playerComboMultiplier[victim] = 1
	g_playerComboLastKill[victim] = 0.0

	// Ignore Nemesis/Survivor/Sniper/Flamer/Zadoc Frags?
	if ((g_nemesis[attacker] && zc_nem_ignore_frags) || (g_survivor[attacker] && zc_surv_ignore_frags) || (g_sniper[attacker] && zc_sniper_ignore_frags) || (g_assassin[attacker] && zc_assassin_ignore_frags) 
	|| (g_oberon[attacker] && zc_oberon_ignore_frags) || (g_dragon[attacker] && zc_dragon_ignore_frags) || (g_nighter[attacker] && zc_nighter_ignore_frags) || (g_flamer[attacker] && zc_flamer_ignore_frags) || (g_zadoc[attacker] && zc_zadoc_ignore_frags) || (g_genesys[attacker] && zc_genesys_ignore_frags))
		RemoveFrags(attacker, victim)
	
	// Zombie/nemesis killed human, reward ammo packs
	if (g_zombie[attacker] && (!g_nemesis[attacker] || !zc_nem_ignore_rewards) && (!g_assassin[attacker] || !zc_assassin_ignore_rewards) && (!g_oberon[attacker] || !zc_oberon_ignore_rewards) && (!g_dragon[attacker] || !zc_dragon_ignore_rewards) && (!g_nighter[attacker] || !zc_nighter_ignore_rewards) && (!g_genesys[attacker] || !zc_genesys_ignore_rewards))
	{
		if(!(g_user_privileges[attacker] & FLAG_A))
			g_ammopacks[attacker] += zc_zombie_infect_reward
		else
			g_ammopacks[attacker] += (zc_zombie_infect_reward + zc_vip_killammo)
	}

	// Human killed zombie, add up the extra frags for kill
	if (!g_zombie[attacker] && zc_human_frags_for_kill > 1)
		UpdateFrags(attacker, victim, zc_human_frags_for_kill - 1, 0, 0)
	
	// Zombie killed human, add up the extra frags for kill
	if (g_zombie[attacker] && zc_zombie_frags_for_infect > 1)
		UpdateFrags(attacker, victim, zc_zombie_frags_for_infect - 1, 0, 0)
	
	// When killed by a Sniper victim explodes
	if (g_sniper[attacker])
	{
		new weapon = get_user_weapon(attacker)
		if (zc_sniper_frag_gore && weapon == CSW_AWP)
		{
			if (g_zombie[victim])
			{
				new origin[3];
				get_user_origin(victim, origin);
					
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
				write_byte(TE_LAVASPLASH);
				write_coord(origin[0]);
				write_coord(origin[1]);
				write_coord(origin[2]-26);
				message_end();
					
				SetHamParamInteger(3, 2);
			}
		}
	}
	
	// When killed by a Assassin victim is cut in pieces, if not Survivor or Sniper
	if (g_assassin[attacker])
	{
		if (zc_assassin_frag_gore)
			SetHamParamInteger(3, 2)
	}

	// When a Nighter Child kills someone, the Nighter will get bonuses
	if (g_nchild[attacker])
	{
		// Bonus received by Nighter
		g_xp[nighterindex] += zc_nchild_xp_to_nighter
		g_ammopacks[nighterindex] += zc_nchild_packs_to_nighter
		g_coins[nighterindex] += zc_nchild_coins_to_nighter

		// The number of childs
		g_nchilds_num += 1
	}

	// Evil?
	if (g_evil[attacker])
	{
		// Check Evolve Status
		if(g_evolve[attacker] < 5)
		{
			g_evolve[attacker] = g_evolve[attacker] + 1
		}
	}

	// Respawn if deathmatch is enabled
	if (zc_deathmatch)
	{
		// Respawn on suicide?
		if (selfkill && !zc_respawn_on_suicide)
			return;
		
		// Respawn if only the last human is left?
		if (!zc_respawn_after_last_human && fnGetHumans() <= 1)
			return;
		
		// Respawn if human/zombie/nemesis/survivor/sniper?
		if ((g_zombie[victim] && !g_nemesis[victim] && !g_assassin[victim] && !g_oberon[victim] && !g_dragon[victim] && !g_nighter[victim] && !g_genesys[victim] && !zc_respawn_zombies) || (!g_zombie[victim] && !g_survivor[victim] && !g_sniper[victim] && !g_flamer[victim] && !g_zadoc[victim] && !zc_respawn_humans) 
		|| (g_nemesis[victim] && !zc_respawn_nemesis) || (g_survivor[victim] && !zc_respawn_survivors) 
		|| (g_sniper[victim] && !zc_respawn_snipers) || (g_assassin[victim] && !zc_respawn_assassins) || (g_oberon[victim] && !zc_respawn_oberons) || (g_dragon[victim] && !zc_respawn_dragons) || (g_nighter[victim] && !zc_respawn_nighters) || (g_nchild[victim] && !zc_respawn_nchilds) || (g_flamer[victim] && !zc_respawn_flamers) || (g_zadoc[victim] && !zc_respawn_zadocs) || (g_genesys[victim] && !zc_respawn_assassins))
			return;

		// Respawn as zombie?
		if (zc_deathmatch == 2 || (zc_deathmatch == 3 && random_num(0, 1)) || (zc_deathmatch == 4 && fnGetZombies() < fnGetAlive()/2))
			g_respawn_as_zombie[victim] = true
		
		// Set the respawn task
		set_task(1.0+zc_spawn_delay, "respawn_player_task", victim+TASK_SPAWN)
	}
}

// Ham Player Killed Post Forward
public fw_PlayerKilled_Post()
{
	// Last Zombie Check
	fnCheckLastZombie()
}

// Ham Take Damage Forward
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	// Non-player damage or self damage
	if (victim == attacker || !is_user_valid_connected(attacker))
		return HAM_IGNORED;
	
	// New round starting or round ended
	if (g_newround || g_endround)
		return HAM_SUPERCEDE;
	
	// Victim shouldn't take damage or victim is frozen
	if (g_nodamage[victim] || (g_frozen[victim] && !zc_frost_hit))
		return HAM_SUPERCEDE;
	
	// Prevent friendly fire
	if (g_zombie[attacker] == g_zombie[victim])
		return HAM_SUPERCEDE;
	
	// Attacker is human...
	if (!g_zombie[attacker])
	{
		// Nighter power
		if(g_nighter[victim])
		{
			NighterRemovePower(victim)
			set_task(1.0, "NighterSetPower", victim)
		}

		// Armor multiplier for the final damage on normal zombies
		if (!g_nemesis[victim] && !g_assassin[victim] && !g_oberon[victim] && !g_dragon[victim] && !g_nighter[victim] && !g_genesys[victim])
		{
			damage *= zc_zombie_armor
			SetHamParamFloat(4, damage)
		}

		if (!g_zombie[attacker])
		{
			// Damage VIP
			if(g_user_privileges[attacker] & FLAG_D) {
				damage += float(zc_vip_damage_increase)
			}

			// Reward ammo packs
			if (!g_sniper[attacker] && !g_flamer[attacker] && !g_zadoc[attacker] && (!g_survivor[attacker] || !zc_surv_ignore_rewards))
			{
				// Store damage dealt - AMMO PACKS
				new gasp
				g_damagedealt[attacker] += floatround(damage)
				if(!(g_user_privileges[attacker] & FLAG_D))
					gasp = zc_human_damage_reward - (asp_l[attacker] * zc_powers_asp_rate)
				else
					gasp = zc_vip_damage_reward - (asp_l[attacker] * zc_powers_asp_rate)
				if(gasp <= 0){
					gasp = 200
				}

				// Reward ammo packs for every [ammo damage] dealt
				while (g_damagedealt[attacker] > gasp)
				{
					g_ammopacks[attacker]++
					g_damagedealt[attacker] -= gasp
				}
			}
			else if (!g_survivor[attacker] && !g_flamer[attacker] && !g_zadoc[attacker] && (g_sniper[attacker] && !zc_sniper_ignore_rewards))
			{
				// Store damage dealt
				new gasp
				g_damagedealt[attacker] += floatround(damage)
				if(!(g_user_privileges[attacker] & FLAG_D))
					gasp = zc_human_damage_reward - (asp_l[attacker] * zc_powers_asp_rate)
				else
					gasp = zc_vip_damage_reward - (asp_l[attacker] * zc_powers_asp_rate)
				if(gasp <= 0){
					gasp = 200
				}

				// Reward ammo packs for every [ammo damage] dealt
				while (g_damagedealt[attacker] > gasp)
				{
					g_ammopacks[attacker]++
					g_damagedealt[attacker] -= gasp
				}
			}
			else if (!g_survivor[attacker] && !g_sniper[attacker] && !g_zadoc[attacker] && (g_flamer[attacker] && !zc_flamer_ignore_rewards))
			{
				// Store damage dealt
				new gasp
				g_damagedealt[attacker] += floatround(damage)
				if(!(g_user_privileges[attacker] & FLAG_D))
					gasp = zc_human_damage_reward - (asp_l[attacker] * zc_powers_asp_rate)
				else
					gasp = zc_vip_damage_reward - (asp_l[attacker] * zc_powers_asp_rate)
				if(gasp <= 0){
					gasp = 200
				}

				// Reward ammo packs for every [ammo damage] dealt
				while (g_damagedealt[attacker] > gasp)
				{
					g_ammopacks[attacker]++
					g_damagedealt[attacker] -= gasp
				}
			}
			else if (!g_survivor[attacker] && !g_sniper[attacker] && !g_flamer[attacker] && (g_zadoc[attacker] && !zc_zadoc_ignore_rewards))
			{
				// Store damage dealt
				new gasp
				g_damagedealt[attacker] += floatround(damage)
				if(!(g_user_privileges[attacker] & FLAG_D))
					gasp = zc_human_damage_reward - (asp_l[attacker] * zc_powers_asp_rate)
				else
					gasp = zc_vip_damage_reward - (asp_l[attacker] * zc_powers_asp_rate)
				if(gasp <= 0){
					gasp = 200
				}

				// Reward ammo packs for every [ammo damage] dealt
				while (g_damagedealt[attacker] > gasp)
				{
					g_ammopacks[attacker]++
					g_damagedealt[attacker] -= gasp
				}
			}
		}
		// Get attacker's weapon
		new weapon = get_user_weapon(attacker)

		// Replace damage done by Sniper's weapon with the one set by cvar
		if (g_sniper[attacker])
		{
			if (weapon == CSW_AWP)
			{
				// Set sniper damage
				SetHamParamFloat(4, zc_sniper_damage)
			}
		}

		// Replace damage done by Survivor's weapon with the one set by cvar
		if (g_survivor[attacker])
		{
			if (weapon == CSW_XM1014)
			{
				// Set sniper damage
				SetHamParamFloat(4, zc_surv_damage)
			}
		}
		// Replace damage done by Zadoc's weapon with the one set by cvar
		if (g_zadoc[attacker])
		{
			if (weapon == CSW_KNIFE)
			{
				// Set zadoc damage
				SetHamParamFloat(4, zc_zadoc_damage)
			}
		}
		return HAM_IGNORED;
	}
	
	// Attacker is zombie...
	// Prevent infection/damage by HE grenade (bugfix)
	if (damage_type & DMG_HEGRENADE)
		return HAM_SUPERCEDE;
	
	// Nemesis?
	if (g_nemesis[attacker])
	{
		// Ignore nemesis damage override if damage comes from a 3rd party entity
		// (to prevent this from affecting a sub-plugin's rockets e.g.)
		if (inflictor == attacker)
		{
			// Set nemesis damage
			SetHamParamFloat(4, zc_nem_damage)
		}
		
		return HAM_IGNORED;
	}
	
	// Assassin?
	if (g_assassin[attacker])
	{
		// Ignore assassin damage override if damage comes from a 3rd party entity
		// (to prevent this from affecting a sub-plugin's rockets e.g.)
		if (inflictor == attacker)
		{
			// Set assassin damage
			SetHamParamFloat(4, zc_assassin_damage)
		}
		
		return HAM_IGNORED;
	}

	// Genesys?
	if (g_genesys[attacker])
	{
		// Ignore genesys damage override if damage comes from a 3rd party entity
		// (to prevent this from affecting a sub-plugin's rockets e.g.)
		if (inflictor == attacker)
		{
			// Set genesys damage
			SetHamParamFloat(4, zc_genesys_damage)
		}
		
		return HAM_IGNORED;
	}

	// Oberon?
	if (g_oberon[attacker])
	{
		// Ignore oberon damage override if damage comes from a 3rd party entity
		// (to prevent this from affecting a sub-plugin's rockets e.g.)
		if (inflictor == attacker)
		{
			// Set Oberon damage
			SetHamParamFloat(4, zc_oberon_damage)
		}
		
		return HAM_IGNORED;
	}

	// Dragon?
	if (g_dragon[attacker])
	{
		// Ignore dragon damage override if damage comes from a 3rd party entity
		// (to prevent this from affecting a sub-plugin's rockets e.g.)
		if (inflictor == attacker)
		{
			// Set Dragon damage
			SetHamParamFloat(4, zc_dragon_damage)
		}
		
		return HAM_IGNORED;
	}

	// Nighter?
	if (g_nighter[attacker])
	{
		// Ignore nighter damage override if damage comes from a 3rd party entity
		// (to prevent this from affecting a sub-plugin's rockets e.g.)
		if (inflictor == attacker)
		{
			// Set nighter damage
			SetHamParamFloat(4, zc_nighter_damage)
		}

		// Check if the victim isn't last human
		if(!g_lasthuman[victim])
		{
			// Make victim child
			zombieme(victim, attacker, 0, 0, 1, 0, 0, 0, 0, 2, 0)
			
			// Give attacker a bonus
			g_xp[attacker] += zc_nighter_xp_reward
			g_nchilds_num += 1
		}
		return HAM_IGNORED;
	}

	// Nighter Child?
	if (g_nchild[attacker])
	{
		// Ignore nighter child damage override if damage comes from a 3rd party entity
		// (to prevent this from affecting a sub-plugin's rockets e.g.)
		if (inflictor == attacker)
		{
			// Set nighter damage
			SetHamParamFloat(4, zc_nchild_damage)
		}

		return HAM_IGNORED;
	}

	// Evil?
	if (g_evil[attacker])
	{
		// Ignore evil damage override if damage comes from a 3rd party entity
		// (to prevent this from affecting a sub-plugin's rockets e.g.)
		if (inflictor == attacker)
		{
			// Set nighter damage
			SetHamParamFloat(4, zc_evil_damage)
		}
		return HAM_IGNORED;
	}
	
	// Last human or not an infection round
	if (g_survround || g_nemround || g_swarmround || g_plagueround || g_sniperround || g_flamerround || g_zadocround || g_genesysround || g_assassinround || g_oberonround || g_dragonround || g_nighterround || g_lnjround || g_guardiansround || fnGetHumans() == 1)
		return HAM_IGNORED; // human is killed
	
	// Zombie Attacker
	if (g_zombie[attacker])
	{
		// Ignore zombie damage override if damage comes from a 3rd party entity
		// (to prevent this from affecting a sub-plugin's rockets e.g.)
		if (inflictor == attacker)
		{
			SetHamParamFloat(4, zc_zombie_damage)
		}

		// Does human armor need to be reduced before infecting?
		if (zc_human_armor_protect)
		{
			// Get victim armor
			static Float:armor
			pev(victim, pev_armorvalue, armor)
		
			// Block the attack if he has some armor
			if (armor > 0.0)
			{
				emit_sound(victim, CHAN_BODY, sound_armorhit, 1.0, ATTN_NORM, 0, PITCH_NORM)
				set_pev(victim, pev_armorvalue, floatmax(0.0, armor - zc_zombie_damage))
				return HAM_SUPERCEDE;
			}
		}
	}
	
	// Infection allowed
	zombieme(victim, attacker, 0, 0, 1, 0, 0, 0, 0, 0, 0) // turn into zombie
	return HAM_SUPERCEDE;
}

// Ham Take Damage Post Forward
public fw_TakeDamage_Post(victim)
{
	// --- Check if victim should be Pain Shock Free ---
	
	// Check if proper CVARs are enabled
	if (g_zombie[victim])
	{
		if (g_nemesis[victim])
		{
			if (!zc_nem_painfree) return;
		}
		
		if (g_assassin[victim])
		{
			if (!zc_assassin_painfree) return;
		}

		if (g_oberon[victim])
		{
			if (!zc_oberon_painfree) return;
		}

		if (g_dragon[victim])
		{
			if (!zc_dragon_painfree) return;
		}

		if (g_nighter[victim])
		{
			if (!zc_nighter_painfree) return;
		}

		// Genesys
		if (g_genesys[victim])
		{
			if (!zc_assassin_painfree) return;
		}
		
		if (!g_assassin[victim] && !g_oberon[victim] && !g_dragon[victim] && !g_nighter[victim] && !g_nemesis[victim] && !g_genesys[victim])
		{
			switch (zc_zombie_painfree)
			{
				case 0: return;
				case 2: if (!g_lastzombie[victim]) return;
			}
		}
	}
	else
	{
		// Survivor
		if (g_survivor[victim])
		{
			if (!zc_surv_painfree) return;
		}
		
		// Sniper
		if (g_sniper[victim])
		{
			if (!zc_sniper_painfree) return;
		}
		// Flamer
		if (g_flamer[victim])
		{
			if (!zc_flamer_painfree) return;
		}
		// Zadoc
		if (g_zadoc[victim])
		{
			if (!zc_zadoc_painfree) return;
		}
		
		// Human
		if (!g_survivor[victim] && !g_sniper[victim] && !g_flamer[victim] && !g_zadoc[victim]) return;
	}
	
	// Set pain shock free offset
	set_pdata_float(victim, OFFSET_PAINSHOCK, 1.0, OFFSET_LINUX)
}

// Ham Trace Attack Forward
public fw_TraceAttack(victim, attacker, Float:damage, Float:direction[3], tracehandle, damage_type)
{
	// Non-player damage or self damage
	if (victim == attacker || !is_user_valid_connected(attacker))
		return HAM_IGNORED;
	
	// New round starting or round ended
	if (g_newround || g_endround)
		return HAM_SUPERCEDE;
	
	// Victim shouldn't take damage or victim is frozen
	if (g_nodamage[victim] || (g_frozen[victim] && !zc_frost_hit))
		return HAM_SUPERCEDE;
	
	// Prevent friendly fire
	if (g_zombie[attacker] == g_zombie[victim])
		return HAM_SUPERCEDE;
	
	// Victim isn't a zombie or not bullet damage, nothing else to do here
	if (!g_zombie[victim] || !(damage_type & DMG_BULLET))
		return HAM_IGNORED;
	
	// If zombie hitzones are enabled, check whether we hit an allowed one
	if (zc_zombie_hitzones && !g_nemesis[victim] && !g_assassin[victim] && !g_oberon[victim] && !g_dragon[victim] && !g_nighter[victim] && !g_genesys[victim] && !(zc_zombie_hitzones & (1<<get_tr2(tracehandle, TR_iHitgroup))))
		return HAM_SUPERCEDE;
	
	// Knockback disabled, nothing else to do here
	if (!zc_knockback)
		return HAM_IGNORED;
	
	// Nemesis knockback disabled, nothing else to do here
	if (g_nemesis[victim] && zc_knockback_nemesis == 0.0)
		return HAM_IGNORED;
		
	if (g_assassin[victim] && zc_knockback_assassin == 0.0)
		return HAM_IGNORED;

	if (g_oberon[victim] && zc_knockback_oberon == 0.0)
		return HAM_IGNORED;

	if (g_dragon[victim] && zc_knockback_dragon == 0.0)
		return HAM_IGNORED;

	if (g_nighter[victim] && zc_knockback_nighter == 0.0)
		return HAM_IGNORED;

	if (g_evil[victim] && zc_knockback_evil == 0.0)
		return HAM_IGNORED;

	if (g_genesys[victim] && zc_knockback_assassin == 0.0)
		return HAM_IGNORED;
	
	// Get whether the victim is in a crouch state
	static ducking
	ducking = pev(victim, pev_flags) & (FL_DUCKING | FL_ONGROUND) == (FL_DUCKING | FL_ONGROUND)
	
	// Zombie knockback when ducking disabled
	if (ducking && zc_knockback_ducking == 0.0)
		return HAM_IGNORED;
	
	// Get distance between players
	static origin1[3], origin2[3]
	get_user_origin(victim, origin1)
	get_user_origin(attacker, origin2)
	
	// Max distance exceeded
	if (get_distance(origin1, origin2) > zc_knockback_distance)
		return HAM_IGNORED;
	
	// Get victim's velocity
	static Float:velocity[3]
	pev(victim, pev_velocity, velocity)
	
	// Use damage on knockback calculation
	if (zc_knockback_damage)
		xs_vec_mul_scalar(direction, damage, direction)
	
	// Use weapon power on knockback calculation
	if (zc_knockback_power && kb_weapon_power[g_currentweapon[attacker]] > 0.0)
		xs_vec_mul_scalar(direction, kb_weapon_power[g_currentweapon[attacker]], direction)
	
	// Apply ducking knockback multiplier
	if (ducking)
		xs_vec_mul_scalar(direction, zc_knockback_ducking, direction)
	
	// Apply zombie class/nemesis knockback multiplier
	if (g_nemesis[victim])
		xs_vec_mul_scalar(direction, zc_knockback_nemesis, direction)
	else if (g_assassin[victim])
		xs_vec_mul_scalar(direction, zc_knockback_assassin, direction)
	else if (g_oberon[victim])
		xs_vec_mul_scalar(direction, zc_knockback_oberon, direction)
	else if (g_dragon[victim])
		xs_vec_mul_scalar(direction, zc_knockback_dragon, direction)
	else if (g_nighter[victim])
		xs_vec_mul_scalar(direction, zc_knockback_nighter, direction)
	else if (g_evil[victim])
		xs_vec_mul_scalar(direction, zc_knockback_evil, direction)
	else if (!g_assassin[victim] && !g_oberon[victim] && !g_dragon[victim] && !g_nighter[victim] && !g_nemesis[victim] && !g_evil[victim])
		xs_vec_mul_scalar(direction, g_zombie_knockback[victim], direction)
	
	// Add up the new vector
	xs_vec_add(velocity, direction, direction)
	
	// Should knockback also affect vertical velocity?
	if (!zc_knockback_zvel)
		direction[2] = velocity[2]
	
	// Set the knockback'd victim's velocity
	set_pev(victim, pev_velocity, direction)
	
	return HAM_IGNORED;
}

// Ham Use Stationary Gun Forward
public fw_UseStationary(entity, caller, activator, use_type)
{
	// Prevent zombies from using stationary guns
	if (use_type == USE_USING && is_user_valid_connected(caller) && g_zombie[caller])
		return HAM_SUPERCEDE;

	// Prevent zadocs from using stationary guns
	if (use_type == USE_USING && is_user_valid_connected(caller) && g_zadoc[caller])
		return HAM_SUPERCEDE;
	
	return HAM_IGNORED;
}

// Ham Use Stationary Gun Post Forward
public fw_UseStationary_Post(entity, caller, activator, use_type)
{
	// Someone stopped using a stationary gun
	if (use_type == USE_STOPPED && is_user_valid_connected(caller))
		replace_weapon_models(caller, g_currentweapon[caller]) // replace weapon models (bugfix)
}

// Ham Use Pushable Forward
public fw_UsePushable()
{
	// Prevent speed bug with pushables?
	if (zc_blockuse_pushable)
		return HAM_SUPERCEDE;
	
	return HAM_IGNORED;
}

// Ham Weapon Touch Forward
public fw_TouchWeapon(weapon, id)
{
	// Not a player
	if (!is_user_valid_connected(id))
		return HAM_IGNORED;
	
	// Dont pickup weapons if zombie, survivor, sniper, flamer or zadoc (+PODBot MM fix)
	if (g_zombie[id] || g_zadoc[id] || (g_survivor[id] && !g_isbot[id]) || (g_sniper[id] && !g_isbot[id]) || (g_flamer[id] && !g_isbot[id]))
		return HAM_SUPERCEDE;
	
	return HAM_IGNORED;
}

// Ham Weapon Pickup Forward
public fw_AddPlayerItem(id, weapon_ent)
{
	// HACK: Retrieve our custom extra ammo from the weapon
	static extra_ammo
	extra_ammo = pev(weapon_ent, PEV_ADDITIONAL_AMMO)
	
	// If present
	if (extra_ammo)
	{
		// Get weapon's id
		static weaponid
		weaponid = cs_get_weapon_id(weapon_ent)
		
		// Add to player's bpammo
		ExecuteHamB(Ham_GiveAmmo, id, extra_ammo, AMMOTYPE[weaponid], MAXBPAMMO[weaponid])
		set_pev(weapon_ent, PEV_ADDITIONAL_AMMO, 0)
	}
}

// Ham Weapon Deploy Forward
public fw_Item_Deploy_Post(weapon_ent)
{
	// Get weapon's owner
	static owner
    	if(!pev_valid(weapon_ent))
        	return HAM_IGNORED;

	owner = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	// Get weapon's id
	static weaponid
	weaponid = cs_get_weapon_id(weapon_ent)
	
	// Store current weapon's id for reference
	g_currentweapon[owner] = weaponid
	
	// Replace weapon models with custom ones
	replace_weapon_models(owner, weaponid)
	
	// Zombie not holding an allowed weapon for some reason
	if (g_zombie[owner] && !((1<<weaponid) & ZOMBIE_ALLOWED_WEAPONS_BITSUM))
	{
		// Switch to knife
		g_currentweapon[owner] = CSW_KNIFE
		engclient_cmd(owner, "weapon_knife")
	}
	if (g_zadoc[owner] && !((1<<weaponid) & ZOMBIE_ALLOWED_WEAPONS_BITSUM))
	{
		// Switch to knife
		g_currentweapon[owner] = CSW_KNIFE
		engclient_cmd(owner, "weapon_knife")
	}
	return HAM_IGNORED;
}

// WeaponMod bugfix
//forward wpn_gi_reset_weapon(id);
public wpn_gi_reset_weapon(id)
{
	// Replace knife model
	replace_weapon_models(id, CSW_KNIFE)
}

// Client Kill Forward
public fw_ClientKill()
{
	// Prevent players from killing themselves?
	if (zc_block_suicide)
		return FMRES_SUPERCEDE;
	
	return FMRES_IGNORED;
}

// Emit Sound Forward
public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	// Block all those unneeeded hostage sounds
	if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e')
		return FMRES_SUPERCEDE;
	
	// Replace these next sounds for zombies only
	if (!is_user_valid_connected(id) || !g_zombie[id])
		return FMRES_IGNORED;
	
	static sound[64]
	
	// Zombie being hit
	if (sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't')
	{
		if (g_nemesis[id])
		{
			ArrayGetString(nemesis_pain, random_num(0, ArraySize(nemesis_pain) - 1), sound, charsmax(sound))
			emit_sound(id, channel, sound, volume, attn, flags, pitch)
		}
		if (g_assassin[id])
		{
			ArrayGetString(assassin_pain, random_num(0, ArraySize(assassin_pain) - 1), sound, charsmax(sound))
			emit_sound(id, channel, sound, volume, attn, flags, pitch)
		}
		if (g_oberon[id])
		{
			ArrayGetString(oberon_pain, random_num(0, ArraySize(oberon_pain) - 1), sound, charsmax(sound))
			emit_sound(id, channel, sound, volume, attn, flags, pitch)
		}
		if (g_dragon[id])
		{
			ArrayGetString(dragon_pain, random_num(0, ArraySize(dragon_pain) - 1), sound, charsmax(sound))
			emit_sound(id, channel, sound, volume, attn, flags, pitch)
		}
		if (g_nighter[id])
		{
			ArrayGetString(nighter_pain, random_num(0, ArraySize(nighter_pain) - 1), sound, charsmax(sound))
			emit_sound(id, channel, sound, volume, attn, flags, pitch)
		}
		if (g_genesys[id])
		{
			ArrayGetString(genesys_pain, random_num(0, ArraySize(genesys_pain) - 1), sound, charsmax(sound))
			emit_sound(id, channel, sound, volume, attn, flags, pitch)
		}
		if (g_evil[id])
		{
			ArrayGetString(evil_pain, random_num(0, ArraySize(evil_pain) - 1), sound, charsmax(sound))
			emit_sound(id, channel, sound, volume, attn, flags, pitch)
		}
		if (!g_assassin[id] && !g_oberon[id] && !g_dragon[id] && !g_nighter[id] && !g_nemesis[id] && !g_genesys[id] && !g_evil[id])
		{
			ArrayGetString(zombie_pain, random_num(0, ArraySize(zombie_pain) - 1), sound, charsmax(sound))
			emit_sound(id, channel, sound, volume, attn, flags, pitch)
		}
		return FMRES_SUPERCEDE;
	}
	
	// Zombie attacks with knife
	if (sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i')
	{
		if (sample[14] == 's' && sample[15] == 'l' && sample[16] == 'a') // slash
		{
			ArrayGetString(zombie_miss_slash, random_num(0, ArraySize(zombie_miss_slash) - 1), sound, charsmax(sound))
			emit_sound(id, channel, sound, volume, attn, flags, pitch)
			return FMRES_SUPERCEDE;
		}
		if (sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't') // hit
		{
			if (sample[17] == 'w') // wall
			{
				ArrayGetString(zombie_miss_wall, random_num(0, ArraySize(zombie_miss_wall) - 1), sound, charsmax(sound))
				emit_sound(id, channel, sound, volume, attn, flags, pitch)
				return FMRES_SUPERCEDE;
			}
			else
			{
				ArrayGetString(zombie_hit_normal, random_num(0, ArraySize(zombie_hit_normal) - 1), sound, charsmax(sound))
				emit_sound(id, channel, sound, volume, attn, flags, pitch)
				return FMRES_SUPERCEDE;
			}
		}
		if (sample[14] == 's' && sample[15] == 't' && sample[16] == 'a') // stab
		{
			ArrayGetString(zombie_hit_stab, random_num(0, ArraySize(zombie_hit_stab) - 1), sound, charsmax(sound))
			emit_sound(id, channel, sound, volume, attn, flags, pitch)
			return FMRES_SUPERCEDE;
		}
	}
	
	// Zombie dies
	if (sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a')))
	{
		ArrayGetString(zombie_die, random_num(0, ArraySize(zombie_die) - 1), sound, charsmax(sound))
		emit_sound(id, channel, sound, volume, attn, flags, pitch)
		return FMRES_SUPERCEDE;
	}
	
	// Zombie falls off
	if (sample[10] == 'f' && sample[11] == 'a' && sample[12] == 'l' && sample[13] == 'l')
	{
		ArrayGetString(zombie_fall, random_num(0, ArraySize(zombie_fall) - 1), sound, charsmax(sound))
		emit_sound(id, channel, sound, volume, attn, flags, pitch)
		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}

// Forward Set ClientKey Value -prevent CS from changing player models-
public fw_SetClientKeyValue(id, const infobuffer[], const key[])
{
	// Block CS model changes
	if (key[0] == 'm' && key[1] == 'o' && key[2] == 'd' && key[3] == 'e' && key[4] == 'l')
		return FMRES_SUPERCEDE;
	
	return FMRES_IGNORED;
}

// Forward Client User Info Changed -prevent players from changing models-
public fw_ClientUserInfoChanged(id)
{
	// Cache player's name
	get_user_name(id, g_playername[id], charsmax(g_playername[]))
	
	if (!g_handle_models_on_separate_ent)
	{
		// Get current model
		static currentmodel[32]
		fm_cs_get_user_model(id, currentmodel, charsmax(currentmodel))
		
		// If they're different, set model again
		if (!equal(currentmodel, g_playermodel[id]) && !task_exists(id+TASK_MODEL))
			fm_cs_set_user_model(id+TASK_MODEL)
	}
}

// Forward Get Game Description
public fw_GetGameDescription()
{
	// Return the mod name so it can be easily identified
	forward_return(FMV_STRING, g_modname)
	
	return FMRES_SUPERCEDE;
}

// Forward Set Model
public fw_SetModel(entity, const model[])
{
	// We don't care
	if (strlen(model) < 8)
		return FMRES_IGNORED
	
	// Remove weapons?
	if (zc_remove_dropped > 0.0 && !g_event)
	{
		// Get entity's classname
		static classname[10]
		pev(entity, pev_classname, classname, charsmax(classname))
		
		// Check if it's a weapon box
		if (equal(classname, "weaponbox"))
		{
			// They get automatically removed when thinking
			set_pev(entity, pev_nextthink, get_gametime() + zc_remove_dropped)
			return FMRES_IGNORED
		}
	}
	
	// Narrow down our matches a bit
	if (model[7] != 'w' || model[8] != '_')
		return FMRES_IGNORED
	
	// Get damage time of grenade
	static Float:dmgtime
	pev(entity, pev_dmgtime, dmgtime)
	
	// Grenade not yet thrown
	if (dmgtime == 0.0)
		return FMRES_IGNORED
	
	// Get whether grenade's owner is a zombie
	if (g_zombie[pev(entity, pev_owner)])
	{
		if (model[9] == 'h' && model[10] == 'e' && zc_extra_infbomb) // Infection Bomb
		{
			// Give it a glow
			fm_set_rendering(entity, kRenderFxGlowShell, 0, 250, 0, kRenderNormal, 16);
			
			// And a colored trail
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_BEAMFOLLOW) // TE id
			write_short(entity) // entity
			write_short(g_trailSpr) // sprite
			write_byte(10) // life
			write_byte(10) // width
			write_byte(0) // r
			write_byte(250) // g
			write_byte(0) // b
			write_byte(200) // brightness
			message_end()
			
			// Set grenade type on the thrown grenade entity
			set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_INFECTION)

			// Set W_ model
			engfunc(EngFunc_SetModel, entity, model_wgrenade_infect)
            		return FMRES_SUPERCEDE
		}
	}
	else if (model[9] == 'h' && model[10] == 'e' && zc_fire_grenades) // Napalm Grenade
	{
		// Give it a glow
		fm_set_rendering(entity, kRenderFxGlowShell, 200, 0, 0, kRenderNormal, 16);

		// And a colored trail
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMFOLLOW) // TE id
		write_short(entity) // entity
		write_short(g_fire_trail) // sprite
		write_byte(10) // life
		write_byte(10) // width
		write_byte(200) // r
		write_byte(0) // g
		write_byte(0) // b
		write_byte(200) // brightness
		message_end()

		// Set grenade type on the thrown grenade entity
		set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_NAPALM)

		// Set W_ model
		engfunc(EngFunc_SetModel, entity, model_wgrenade_fire)
            	return FMRES_SUPERCEDE
	}
	else if (model[9] == 'f' && model[10] == 'l' && zc_frost_grenades) // Frost Grenade
	{
		// Check for Guardians mode
		new pid = entity_get_owner(entity)
		if(g_evil[pid])
            		return FMRES_SUPERCEDE

		// Give it a glow
		fm_set_rendering(entity, kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 16);

		// And a colored trail
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMFOLLOW) // TE id
		write_short(entity) // entity
		write_short(g_frost_trail) // sprite
		write_byte(10) // life
		write_byte(10) // width
		write_byte(0) // r
		write_byte(100) // g
		write_byte(200) // b
		write_byte(200) // brightness
		message_end()

		// Set grenade type on the thrown grenade entity
		set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_FROST)

		// Set W_ model
		engfunc(EngFunc_SetModel, entity, model_wgrenade_frost)
            	return FMRES_SUPERCEDE
	}
	else if (model[9] == 's' && model[10] == 'm' && zc_explosion_grenades) // Explosion
	{
		// Give it a glow
		fm_set_rendering(entity, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 16);

		// And a colored trail
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMFOLLOW) // TE id
		write_short(entity) // entity
		write_short(g_explosion_trail) // sprite
		write_byte(10) // life
		write_byte(10) // width
		write_byte(255) // r
		write_byte(0) // g
		write_byte(0) // b
		write_byte(200) // brightness
		message_end()

		// Set grenade type on the thrown grenade entity
		set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_EXPLOSION)

		// Set W_ model
		engfunc(EngFunc_SetModel, entity, model_wgrenade_explosion)
            	return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}

// Ham Grenade Think Forward
public fw_ThinkGrenade(entity)
{
	// Invalid entity
	if (!pev_valid(entity)) return HAM_IGNORED;
	
	// Get damage time of grenade
	static Float:dmgtime, Float:current_time
	pev(entity, pev_dmgtime, dmgtime)
	current_time = get_gametime()
	
	// Check if it's time to go off
	if (dmgtime > current_time)
		return HAM_IGNORED;
	
	// Check if it's one of our custom nades
	switch (pev(entity, PEV_NADE_TYPE))
	{
		case NADE_TYPE_INFECTION: // Infection Bomb
		{
			infection_explode(entity)
			return HAM_SUPERCEDE;
		}
		case NADE_TYPE_NAPALM: // Napalm Grenade
		{
			fire_explode(entity)
			return HAM_SUPERCEDE;
		}
		case NADE_TYPE_FROST: // Frost Grenade
		{
			frost_explode(entity)
			return HAM_SUPERCEDE;
		}
		case NADE_TYPE_EXPLOSION: // Flare
		{
			explosion_explode(entity)
			return HAM_SUPERCEDE;
		}
	}
	return HAM_IGNORED;
}

// Forward CmdStart
public fw_CmdStart(id, handle)
{
	// Not alive
	if (!g_isalive[id])
		return;
	
	// This logic looks kinda weird, but it should work in theory...
	// p = g_zombie[id], q = g_survivor[id], r = g_cached_customflash
	// �(p v q v (�p ^ r)) <=>= �p ^ �q ^ (p v �r)
	if (!g_zombie[id] && !g_survivor[id] && !g_sniper[id] && !g_flamer[id] && !g_zadoc[id] && (g_zombie[id] || !g_cached_customflash))
		return;
	
	// Check if it's a flashlight impulse
	if (get_uc(handle, UC_Impulse) != IMPULSE_FLASHLIGHT)
		return;
	
	// Block it I say!
	set_uc(handle, UC_Impulse, 0)
	
	// Should human's custom flashlight be turned on?
	if (!g_zombie[id] && !g_survivor[id] && !g_sniper[id] && !g_flamer[id] && !g_zadoc[id] && g_flashbattery[id] > 2 && get_gametime() - g_lastflashtime[id] > 1.2)
	{
		// Prevent calling flashlight too quickly (bugfix)
		g_lastflashtime[id] = get_gametime()
		
		// Toggle custom flashlight
		g_flashlight[id] = !(g_flashlight[id])
		
		// Play flashlight toggle sound
		emit_sound(id, CHAN_ITEM, sound_flashlight, 1.0, ATTN_NORM, 0, PITCH_NORM)

		// Update flashlight status on the HUD
		message_begin(MSG_ONE, g_msgFlashlight, _, id)
		write_byte(g_flashlight[id]) // toggle
		write_byte(g_flashbattery[id]) // battery
		message_end()
		
		// Remove previous tasks
		remove_task(id+TASK_CHARGE)
		remove_task(id+TASK_FLASH)
		
		// Set the flashlight charge task
		set_task(1.0, "flashlight_charge", id+TASK_CHARGE, _, _, "b")
		
		// Call our custom flashlight task if enabled
		if (g_flashlight[id]) set_task(0.1, "set_user_flashlight", id+TASK_FLASH, _, _, "b")

		// Set Flashlight cone
		// if(lightcone[id]) set_cone_nodraw(id)
		// else set_lightcone(id)
	}
}

// Flashlight Cone
// public set_lightcone(id)
// {
// 	if (!g_iLightConeIndex[id])
// 	{
// 		static info, iEntity
// 		if (!info) info = engfunc(EngFunc_AllocString, "info_target")
// 		iEntity = g_iLightConeIndex[id] = engfunc(EngFunc_CreateNamedEntity, info)
// 		if (pev_valid(iEntity))
// 		{
// 			engfunc(EngFunc_SetModel, iEntity, model_lightcone)
// 			set_pev(iEntity, pev_effects, 0)
// 			set_pev(iEntity, pev_owner, id)
// 			set_pev(iEntity, pev_movetype, MOVETYPE_FOLLOW)
// 			set_pev(iEntity, pev_aiment, id)
// 			lightcone[id] = true
// 		}
// 	}else {
// 		set_pev(g_iLightConeIndex[id], pev_effects, 0)
// 	}
// }

// public set_cone_nodraw(id)
// {
// 	if (g_iLightConeIndex[id])
// 	{
// 		set_pev(g_iLightConeIndex[id], pev_effects, EF_NODRAW)
// 		lightcone[id] = false
// 		g_iLightConeIndex[id] = 0
// 	}
// }

// Forward Player PreThink
public fw_PlayerPreThink(id)
{
	// Not alive
	if (!g_isalive[id])
		return;

	// Powers
	// if(chain_l[id] > 0 && chain_can[id] && is_user_alive(id) && native_has_round_started() && !g_endround && zp_get_user_crystals(id) < 5) 
	if(chain_l[id] > 0 && chain_can[id] && is_user_alive(id) && native_has_round_started() && !g_endround) 
	{
		new Target, Body;
		get_user_aiming(id, Target, Body, 9999999)
		if(is_user_alive(Target) && !g_firstzombie[Target] && cs_get_user_team(id) != cs_get_user_team(Target))
		{
			Ultimate_ChainLightning(id, Target, Body);
			chain_can[id] = false
		}
	}
	
	// Silent footsteps for zombies?
	if (g_cached_zombiesilent && g_zombie[id] && !g_nemesis[id])
		set_pev(id, pev_flTimeStepSound, STEPTIME_SILENT)
	
	// Silent footsteps for Assassin
	if (g_assassin[id])
		set_pev(id, pev_flTimeStepSound, STEPTIME_SILENT)
	
	// Set Player MaxSpeed
	if (g_frozen[id])
	{
		set_pev(id, pev_velocity, Float:{0.0,0.0,0.0}) // stop motion
		set_pev(id, pev_maxspeed, 1.0) // prevent from moving
		return; // shouldn't leap while frozen
	}
	else if (g_freezetime)
	{
		return; // shouldn't leap while in freezetime
	}
	else
	{
		if (g_zombie[id])
		{
			if (g_nemesis[id])
				set_pev(id, pev_maxspeed, g_cached_nemspd)
			else if (g_assassin[id])
				set_pev(id, pev_maxspeed, g_cached_assassinspd)
			else if (g_dragon[id])
				set_pev(id, pev_maxspeed, g_cached_dragonspd)
			else if (g_nighter[id])
				set_pev(id, pev_maxspeed, g_cached_nighterspd)
			else if (g_nchild[id])
				set_pev(id, pev_maxspeed, g_cached_nchildspd)
			else if (g_oberon[id])
				set_pev(id, pev_maxspeed, g_cached_oberonspd)
			else if (g_evil[id])
				set_pev(id, pev_maxspeed, g_cached_evilspd)
			else if (!g_assassin[id] && !g_oberon[id] && !g_dragon[id] && !g_nighter[id] && !g_nchild[id] && !g_nemesis[id] && !g_evil[id])
				set_pev(id, pev_maxspeed, g_zombie_spd[id])
		}
		else
		{
			if (g_survivor[id])
				set_pev(id, pev_maxspeed, g_cached_survspd)
			else if (g_sniper[id])
				set_pev(id, pev_maxspeed, g_cached_sniperspd)
			else if (g_flamer[id])
				set_pev(id, pev_maxspeed, g_cached_flamerspd)
			else if (g_zadoc[id])
				set_pev(id, pev_maxspeed, g_cached_zadocspd)
			else if (g_hero[id])
				set_pev(id, pev_maxspeed, g_cached_herospd)
			else if (!g_survivor[id] && !g_sniper[id] && !g_flamer[id] && !g_zadoc[id] && !g_hero[id])
				set_pev(id, pev_maxspeed, g_human_spd[id])
		}
	}

        // Parachute
	static Float:vel[3]
	pev(id, pev_velocity, vel)

	if (pev(id, pev_button) & IN_USE && vel[2] < 0.0)
	{
		vel[2] = -100.0
		set_pev(id, pev_velocity, vel)
	}
	
	// --- Check if player should leap ---
	
	// Check if proper CVARs are enabled and retrieve leap settings
	static Float:cooldown, Float:current_time
	if (g_zombie[id])
	{
		if (g_nemesis[id])
		{
			if (!g_cached_leapnemesis) return;
			cooldown = g_cached_leapnemesiscooldown
		}
		else if (g_assassin[id])
		{
			if (!g_cached_leapassassin) return;
			cooldown = g_cached_leapassassincooldown
		}
		else if (g_oberon[id])
		{
			if (!g_cached_leapoberon) return;
			cooldown = g_cached_leapoberoncooldown
		}
		else if (g_dragon[id])
		{
			if (!g_cached_leapdragon) return;
			cooldown = g_cached_leapdragoncooldown
		}
		else if (g_nighter[id])
		{
			if (!g_cached_leapnighter) return;
			cooldown = g_cached_leapnightercooldown
		}
		else if (!g_assassin[id] && !g_oberon[id] && !g_dragon[id] && !g_nighter[id] && !g_nemesis[id])
		{
			switch (g_cached_leapzombies)
			{
				case 0: return;
				case 2: if (!g_firstzombie[id]) return;
				case 3: if (!g_lastzombie[id]) return;
			}
			cooldown = g_cached_leapzombiescooldown
		}
	}
	else
	{
		if (g_survivor[id])
		{
			if (!g_cached_leapsurvivor) return;
			cooldown = g_cached_leapsurvivorcooldown
		}
		else if (g_sniper[id])
		{
			if (!g_cached_leapsniper) return;
			cooldown = g_cached_leapsnipercooldown
		}
		else if (g_flamer[id])
		{
			if (!g_cached_leapflamer) return;
			cooldown = g_cached_leapflamercooldown
		}
		else if (g_zadoc[id])
		{
			if (!g_cached_leapzadoc) return;
			cooldown = g_cached_leapzadoccooldown
		}
		else return;
	}
	
	current_time = get_gametime()
	
	// Cooldown not over yet
	if (current_time - g_lastleaptime[id] < cooldown)
		return;
	
	// Not doing a longjump (don't perform check for bots, they leap automatically)
	if (!g_isbot[id] && !(pev(id, pev_button) & (IN_JUMP | IN_DUCK) == (IN_JUMP | IN_DUCK)))
		return;
	
	// Not on ground or not enough speed
	if (!(pev(id, pev_flags) & FL_ONGROUND) || fm_get_speed(id) < 80)
		return;
	
	static Float:velocity[3]

	if (g_survivor[id])
		velocity_by_aim(id, zc_leap_survivor_force, velocity)
	else if (g_nemesis[id])
		velocity_by_aim(id, zc_leap_nemesis_force, velocity)
	else if (g_assassin[id])
		velocity_by_aim(id, zc_leap_assassin_force, velocity)
	else if (g_oberon[id])
		velocity_by_aim(id, zc_leap_oberon_force, velocity)
	else if (g_dragon[id])
		velocity_by_aim(id, zc_leap_dragon_force, velocity)
	else if (g_nighter[id])
		velocity_by_aim(id, zc_leap_nighter_force, velocity)
	else if (g_sniper[id])
		velocity_by_aim(id, zc_leap_sniper_force, velocity)
	else if (g_flamer[id])
		velocity_by_aim(id, zc_leap_flamer_force, velocity)
	else if (g_zadoc[id])
		velocity_by_aim(id, zc_leap_zadoc_force, velocity)
	else if (g_zombie[id] && !g_assassin[id] && !g_oberon[id] && !g_dragon[id] && !g_nighter[id] && !g_nemesis[id])
		velocity_by_aim(id, zc_leap_zombies_force, velocity)
	
	// Set custom height
	if (g_survivor[id])
		velocity[2] = zc_leap_survivor_height
	else if (g_nemesis[id])
		velocity[2] = zc_leap_nemesis_height
	else if (g_assassin[id])
		velocity[2] = zc_leap_assassin_height
	else if (g_oberon[id])
		velocity[2] = zc_leap_oberon_height
	else if (g_dragon[id])
		velocity[2] = zc_leap_dragon_height
	else if (g_nighter[id])
		velocity[2] = zc_leap_nighter_height
	else if (g_sniper[id])
		velocity[2] = zc_leap_sniper_height
	else if (g_flamer[id])
		velocity[2] = zc_leap_flamer_height
	else if (g_zadoc[id])
		velocity[2] = zc_leap_zadoc_height
	else if (g_zombie[id] && !g_assassin[id] && !g_oberon[id] && !g_dragon[id] && !g_nighter[id] && !g_nemesis[id])
		velocity[2] = zc_leap_zombies_height
	
	// Apply the new velocity
	set_pev(id, pev_velocity, velocity)
	
	// Update last leap time
	g_lastleaptime[id] = current_time
}

/*================================================================================
 [Client Commands]
=================================================================================*/
// Say "/zpmenu"
public clcmd_saymenu(id)
{
	show_menu_game(id) // show game menu
}

// Say "/unstuck"
public clcmd_sayunstuck(id)
{
	menu_game(id, 3) // try to get unstuck
}

// Nightvision toggle
public clcmd_nightvision(id)
{
	if(g_hadnvision[id])
	{
		if(!g_usingnvision[id]) set_user_nightvision(id, 1)
		else set_user_nightvision(id, 0)
	}
	if(g_hascnvision[id])
	{
		if(activate_nv[id] == false) {
			set_task(0.1, "set_user_nv", id+TASK_CNVISION, _, _, "b")
			activate_nv[id] = true
		}else if(activate_nv[id] == true) {
			remove_task(id+TASK_CNVISION)
			activate_nv[id] = false
		}
	}
	return PLUGIN_HANDLED;
}

// Weapon Drop
public clcmd_drop(id)
{
	// Survivor should stick with its weapon
	if (g_survivor[id])
		return PLUGIN_HANDLED
	if (g_sniper[id])
		return PLUGIN_HANDLED
	if (g_flamer[id])
		return PLUGIN_HANDLED
	if (g_zadoc[id])
		return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE;
}

// Buy BP Ammo
public clcmd_buyammo(id)
{
	// Not alive or infinite ammo setting enabled
	if (!g_isalive[id] || zc_human_unlimited_ammo)
		return PLUGIN_HANDLED;
	
	// Not human
	if (g_zombie[id])
	{
		zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_HUMAN_ONLY")
		return PLUGIN_HANDLED;
	}
	if (g_zadoc[id])
	{
		zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_HUMAN_ONLY")
		return PLUGIN_HANDLED;
	}
	
	// Not enough ammo packs
	if (g_ammopacks[id] < 1)
	{
		zp_colored_print(id, "^x04[ZC]^x01 %L", id, "NOT_ENOUGH_AMMO")
		return PLUGIN_HANDLED;
	}
	
	// Get user weapons
	static weapons[32], num, i, currentammo, weaponid, refilled
	num = 0 // reset passed weapons count (bugfix)
	refilled = false
	get_user_weapons(id, weapons, num)
	
	// Loop through them and give the right ammo type
	for (i = 0; i < num; i++)
	{
		// Prevents re-indexing the array
		weaponid = weapons[i]
		
		// Primary and secondary only
		if (MAXBPAMMO[weaponid] > 2)
		{
			// Get current ammo of the weapon
			currentammo = cs_get_user_bpammo(id, weaponid)
			
			// Give additional ammo
			ExecuteHamB(Ham_GiveAmmo, id, BUYAMMO[weaponid], AMMOTYPE[weaponid], MAXBPAMMO[weaponid])
			
			// Check whether we actually refilled the weapon's ammo
			if (cs_get_user_bpammo(id, weaponid) - currentammo > 0) refilled = true
		}
	}
	
	// Weapons already have full ammo
	if (!refilled) return PLUGIN_HANDLED;
	
	// Deduce ammo packs, play clip purchase sound, and notify player
	g_ammopacks[id]--
	emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
	zp_colored_print(id, "^x04[ZC]^x01 %L", id, "AMMO_BOUGHT")
	
	return PLUGIN_HANDLED;
}

// Block Team Change
public clcmd_changeteam(id)
{
	static team
	team = fm_cs_get_user_team(id)
	
	// Unless it's a spectator joining the game
	if (team == FM_CS_TEAM_UNASSIGNED)
		return PLUGIN_CONTINUE;
	
	// Pressing 'M' (chooseteam) ingame should show the main menu instead
	show_menu_game(id)
	return PLUGIN_HANDLED;
}

/*================================================================================
 [Menus]
=================================================================================*/
public show_menu_game(id)
{
	static menu[250], len, userflags
	len = 0
	userflags = g_privileges[id]
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\y%s^n^n", g_modname)
	
	// 1. Buy Menu
	if (g_isalive[id])
		len += formatex(menu[len], charsmax(menu) - len, "\r1.\w Equipment^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d1. Equipment^n")

	// 2. About
	len += formatex(menu[len], charsmax(menu) - len, "\r2.\w Supply powers^n")

	// 3. Donate System
	len += formatex(menu[len], charsmax(menu) - len, "\r3.\w Exchange \r/ \wDonate^n")
	
	// 4. Zombie/Human Classes
	len += formatex(menu[len], charsmax(menu) - len, "\r4.\w Select Classes^n")
	
	// 5. Register Nick
        if (UserIsRegistered(g_playername[id]))
        len += formatex(menu[len], charsmax(menu) - len, "\r5.\r Change Password^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r5.\r Register^n")
	
	// 6. Respawn
	len += formatex(menu[len], charsmax(menu) - len, "\r6.\y Show more^n")
	
	// 7. Join spec
	if (get_user_flags(id) & ADMIN_RESERVATION)
		len += formatex(menu[len], charsmax(menu) - len, "\r7.\w Switch team^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d7. Switch team^n")

	// 8. Unstuck
	if (g_isalive[id])
		len += formatex(menu[len], charsmax(menu) - len, "\r8.\w %L^n^n", id, "MENU_UNSTUCK")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d8. %L^n^n", id, "MENU_UNSTUCK")
	
	// 9. Admin menu
	if (userflags & g_access_flag[ACCESS_ADMIN_MENU3])
		len += formatex(menu[len], charsmax(menu) - len, "\r9.\y %L", id, "MENU3_ADMIN")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d9. %L", id, "MENU3_ADMIN")
	
	// 0. Exit
	len += formatex(menu[len], charsmax(menu) - len, "^n^n\r0.\w %L", id, "MENU_EXIT")
	show_menu(id, KEYSMENU, menu, -1, "Game Menu")

	return PLUGIN_HANDLED
}

// Buy Menu 1
public show_menu_buy1(taskid)
{
	// Get player's id
	static id
	(taskid > g_maxplayers) ? (id = ID_SPAWN) : (id = taskid);
	
	// Zombies, survivors or snipers get no guns
	if (!g_isalive[id] || g_zombie[id] || g_survivor[id] || g_sniper[id] || g_flamer[id] || g_zadoc[id])
		return;
	
	// Bots pick their weapons randomly / Random weapons setting enabled
	if (zc_random_weapons || g_isbot[id])
	{
		buy_primary_weapon(id, random_num(0, ArraySize(g_primary_items) - 1))
		menu_buy2(id, random_num(0, ArraySize(g_secondary_items) - 1))
		return;
	}
	
	// Automatic selection enabled for player and menu called on spawn event
	if (WPN_AUTO_ON && taskid > g_maxplayers)
	{
		buy_primary_weapon(id, WPN_AUTO_PRI)
		menu_buy2(id, WPN_AUTO_SEC)
		return;
	}
	
	static menu[300], len, weap, maxloops
	len = 0
	maxloops = min(WPN_STARTID+7, WPN_MAXIDS)
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\y%L \r[%d-%d]^n^n", id, "MENU_BUY1_TITLE", WPN_STARTID+1, min(WPN_STARTID+7, WPN_MAXIDS))
	
	// 1-7. Weapon List
	for (weap = WPN_STARTID; weap < maxloops; weap++)
		len += formatex(menu[len], charsmax(menu) - len, "\r%d.\w %s^n", weap-WPN_STARTID+1, WEAPONNAMES[ArrayGetCell(g_primary_weaponids, weap)])
	
	// 8. Auto Select
	len += formatex(menu[len], charsmax(menu) - len, "^n\r8.\w %L \y[%L]", id, "MENU_AUTOSELECT", id, (WPN_AUTO_ON) ? "MOTD_ENABLED" : "MOTD_DISABLED")
	
	// 9. Next/Back - 0. Exit
	len += formatex(menu[len], charsmax(menu) - len, "^n^n\r9.\w %L/%L^n^n\r0.\w %L", id, "MENU_NEXT", id, "MENU_BACK", id, "MENU_EXIT")
	
	show_menu(id, KEYSMENU, menu, -1, "Buy Menu 1")
}

// Buy Menu 2
show_menu_buy2(id)
{
	static menu[250], len, weap, maxloops
	len = 0
	maxloops = ArraySize(g_secondary_items)
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\y%L^n", id, "MENU_BUY2_TITLE")
	
	// 1-6. Weapon List
	for (weap = 0; weap < maxloops; weap++)
		len += formatex(menu[len], charsmax(menu) - len, "^n\r%d.\w %s", weap+1, WEAPONNAMES[ArrayGetCell(g_secondary_weaponids, weap)])
	
	// 8. Auto Select
	len += formatex(menu[len], charsmax(menu) - len, "^n^n\r8.\w %L \y[%L]", id, "MENU_AUTOSELECT", id, (WPN_AUTO_ON) ? "MOTD_ENABLED" : "MOTD_DISABLED")
	
	// 0. Exit
	len += formatex(menu[len], charsmax(menu) - len, "^n^n\r0.\w %L", id, "MENU_EXIT")
	
	show_menu(id, KEYSMENU, menu, -1, "Buy Menu 2")
}

// Extra Items Menu
show_menu_extras(id)
{
	static menuid, menu[1024], item, team, buffer[64], rest_type, rest_limit
	
	// Title
	if (g_zombie[id])
	{
		if (g_nemesis[id])
			formatex(menu, charsmax(menu), "%L [%L]\r", id, "MENU_EXTRA_TITLE", id, "CLASS_NEMESIS")
		if (g_assassin[id])
			formatex(menu, charsmax(menu), "%L [%L]\r", id, "MENU_EXTRA_TITLE", id, "CLASS_ASSASSIN")
		if (g_oberon[id])
			formatex(menu, charsmax(menu), "%L [%L]\r", id, "MENU_EXTRA_TITLE", id, "CLASS_OBERON")
		if (g_dragon[id])
			formatex(menu, charsmax(menu), "%L [%L]\r", id, "MENU_EXTRA_TITLE", id, "CLASS_DRAGON")
		if (g_nighter[id])
			formatex(menu, charsmax(menu), "%L [%L]\r", id, "MENU_EXTRA_TITLE", id, "CLASS_NIGHTER")
		if (g_nchild[id])
			formatex(menu, charsmax(menu), "%L [%L]\r", id, "MENU_EXTRA_TITLE", id, "CLASS_NCHILD")
		if (g_evil[id])
			formatex(menu, charsmax(menu), "%L [%L]\r", id, "MENU_EXTRA_TITLE", id, "CLASS_EVIL")
		if (g_genesys[id])
			formatex(menu, charsmax(menu), "%L [%L]\r", id, "MENU_EXTRA_TITLE", id, "CLASS_GENESYS")
		if (!g_assassin[id] && !g_oberon[id] && !g_dragon[id] && !g_nighter[id] && !g_nchild[id] && !g_nemesis[id] && !g_genesys[id] && !g_evil[id])
			formatex(menu, charsmax(menu), "%L [%L]\r", id, "MENU_EXTRA_TITLE", id, "CLASS_ZOMBIE")
	}
	else
	{
		if (g_survivor[id])
			formatex(menu, charsmax(menu), "%L [%L]\r", id, "MENU_EXTRA_TITLE", id, "CLASS_SURVIVOR")
		if (g_sniper[id])
			formatex(menu, charsmax(menu), "%L [%L]\r", id, "MENU_EXTRA_TITLE", id, "CLASS_SNIPER")
		if (g_flamer[id])
			formatex(menu, charsmax(menu), "%L [%L]\r", id, "MENU_EXTRA_TITLE", id, "CLASS_FLAMER")
		if (g_zadoc[id])
			formatex(menu, charsmax(menu), "%L [%L]\r", id, "MENU_EXTRA_TITLE", id, "CLASS_ZADOC")
		if (g_hero[id])
			formatex(menu, charsmax(menu), "%L [%L]\r", id, "MENU_EXTRA_TITLE", id, "CLASS_HERO")
		if (!g_survivor[id] && !g_sniper[id] && !g_flamer[id] && !g_zadoc[id] && !g_hero[id])
			formatex(menu, charsmax(menu), "%L [%L]\r", id, "MENU_EXTRA_TITLE", id, "CLASS_HUMAN")
	}
	menuid = menu_create(menu, "menu_extras")
	
	// Item List
	for (item = 0; item < g_extraitem_i; item++)
	{
		// Retrieve item's team
		team = ArrayGetCell(g_extraitem_team, item)
		rest_type = ArrayGetCell(g_extraitem_resttype, item)
		rest_limit = ArrayGetCell(g_extraitem_restlimit, item)
		
		// Item not available to player's team/class
		if ((g_zombie[id] && !native_get_zombie_hero(id) && (team != ZP_TEAM_ZOMBIE && team != ZP_TEAM_ANY)) || (!g_zombie[id] && !native_get_human_hero(id) && (team != ZP_TEAM_HUMAN && team != ZP_TEAM_ANY))
		|| (g_nemesis[id] && team != ZP_TEAM_NEMESIS) || (g_survivor[id] && team != ZP_TEAM_SURVIVOR) || (g_sniper[id] && team != ZP_TEAM_SNIPER) || (g_assassin[id] && team != ZP_TEAM_ASSASSIN) || (g_oberon[id] && team != ZP_TEAM_OBERON) || (g_dragon[id] && team != ZP_TEAM_DRAGON) 
		|| (g_nighter[id] && team != ZP_TEAM_NIGHTER) || (g_nchild[id] && team != ZP_TEAM_NCHILD) || (g_hero[id] && team != ZP_TEAM_HERO) || (g_evil[id] && team != ZP_TEAM_EVIL) || (g_flamer[id] && team != ZP_TEAM_FLAMER) || (g_zadoc[id] && team != ZP_TEAM_ZADOC) || (g_genesys[id] && team != ZP_TEAM_GENESYS))
			continue;
		
		// Check if it's one of the hardcoded items, check availability, set translated caption
		switch (item)
		{
			case EXTRA_NVISION:
			{
				if (!zc_extra_nvision) continue;
				formatex(buffer, charsmax(buffer), "%L", id, "MENU_EXTRA1")
			}
			case EXTRA_CNVISION:
			{
				if (!zc_extra_cnvision) continue;
				formatex(buffer, charsmax(buffer), "%L", id, "MENU_EXTRA1A")
			}
			case EXTRA_ANTIDOTE:
			{
				if (!zc_extra_antidote) continue;
				formatex(buffer, charsmax(buffer), "%L", id, "MENU_EXTRA2")
			}
			case EXTRA_MADNESS:
			{
				if (!zc_extra_madness) continue;
				formatex(buffer, charsmax(buffer), "%L", id, "MENU_EXTRA3")
			}
			case EXTRA_INFBOMB:
			{
				if (!zc_extra_infbomb) continue;
				formatex(buffer, charsmax(buffer), "%L", id, "MENU_EXTRA4")
			}
			default:
			{
				if (item >= EXTRA_WEAPONS_STARTID && item <= EXTRAS_CUSTOM_STARTID-1 && !zc_extra_weapons) continue;
				ArrayGetString(g_extraitem_name, item, buffer, charsmax(buffer))
			}
		}

		switch(rest_type)
		{
			case REST_NONE:
			{
				// Add Item Name and Cost
				formatex(menu, charsmax(menu), "\w%s \r| \y%d \rpacks | \wNo limit", buffer, ArrayGetCell(g_extraitem_cost, item))
			}
			case REST_ROUND:
			{
				// Check limit
				new limit, data[32], itemname[32]
				ArrayGetString(g_extraitem_name, item, itemname, charsmax(itemname))
				if(limiter_get_data(g_limiter_round, itemname, g_playername[id], data, 15))
				{
					limit = str_to_num(data)
				}

				// Add Item Name, Cost and Restriction
				if (limit < rest_limit)
					formatex(menu, charsmax(menu), "\w%s \r| \y%d \rpacks | \y%d\r/\y%d \wper round", buffer, ArrayGetCell(g_extraitem_cost, item), limit, rest_limit)
				else
					formatex(menu, charsmax(menu), "\d%s | P: %d packs | Limit reached", buffer, ArrayGetCell(g_extraitem_cost, item))
			}
			case REST_MAP:
			{
				// Check limit
				new limit, data[32], itemname[32]
				ArrayGetString(g_extraitem_name, item, itemname, charsmax(itemname))
				if(limiter_get_data(g_limiter_map, itemname, g_playername[id], data, 15))
				{
					limit = str_to_num(data)
				}

				// Add Item Name, Cost and Restriction
				if (limit < rest_limit)
					formatex(menu, charsmax(menu), "\w%s \r| \y%d \rpacks | \y%d\r/\y%d \wper map", buffer, ArrayGetCell(g_extraitem_cost, item), limit, rest_limit)
				else
					formatex(menu, charsmax(menu), "\d%s | P: %d packs | Limit reached", buffer, ArrayGetCell(g_extraitem_cost, item))
			}
		}
		buffer[0] = item
		buffer[1] = 0
		menu_additem(menuid, menu, buffer)
	}
	
	// No items to display?
	if (menu_items(menuid) <= 0)
	{
		zp_colored_print(id, "^x04[ZC]^x01 %L", id ,"CMD_NOT_EXTRAS")
		menu_destroy(menuid)
		return;
	}
	
	// Back - Next - Exit
	formatex(menu, charsmax(menu), "%L", id, "MENU_BACK")
	menu_setprop(menuid, MPROP_BACKNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_NEXT")
	menu_setprop(menuid, MPROP_NEXTNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_EXIT")
	menu_setprop(menuid, MPROP_EXITNAME, menu)
	
	menu_display(id, menuid)
}

// Zombie Class Menu
public show_menu_zclass(id)
{
	// Player disconnected
	if (!g_isconnected[id])
		return;
	
	// Bots pick their zombie class randomly
	if (g_isbot[id])
	{
		g_zombieclassnext[id] = random_num(0, g_zclass_i - 1)
		return;
	}
	
	static menuid, menu[128], class, buffer[32], buffer2[32], buffer3[32]
	
	// Title
	formatex(menu, charsmax(menu), "%L\r", id, "MENU_ZCLASS_TITLE")
	menuid = menu_create(menu, "menu_zclass")
	
	// Class List
	for (class = 0; class < g_zclass_i; class++)
	{
		// Retrieve name, info and level
		ArrayGetString(g_zclass_name, class, buffer, charsmax(buffer))
		ArrayGetString(g_zclass_info, class, buffer2, charsmax(buffer2))
		ArrayGetString(g_zclass_level, class, buffer3, charsmax(buffer3))
		
		// Add to menu
		if (class == g_zombieclassnext[id])
			formatex(menu, charsmax(menu), "\y%s \r| \y%s \r| \y%d \r|", buffer, buffer2, buffer3)
		else if(ArrayGetCell(g_zclass_level, class) > g_level[id])
			formatex(menu, charsmax(menu), "\d%s \r| \y%s \r| \y%d \r|", buffer, buffer2, buffer3)
		else if(ArrayGetCell(g_zclass_level, class) <= g_level[id])
			formatex(menu, charsmax(menu), "\w%s \r| \y%s \r| \y%d \r|", buffer, buffer2, buffer3)
		
		buffer[0] = class
		buffer[1] = 0
		menu_additem(menuid, menu, buffer)
	}
	
	// Back - Next - Exit
	formatex(menu, charsmax(menu), "%L", id, "MENU_BACK")
	menu_setprop(menuid, MPROP_BACKNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_NEXT")
	menu_setprop(menuid, MPROP_NEXTNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_EXIT")
	menu_setprop(menuid, MPROP_EXITNAME, menu)
	
	menu_display(id, menuid)
}

// Human Class Menu
public show_menu_hclass(id)
{
	// Player disconnected
	if (!g_isconnected[id])
		return;
	
	// Bots pick their human class randomly
	if (g_isbot[id])
	{
		g_humanclassnext[id] = random_num(0, g_hclass_i - 1)
		return;
	}
	
	static menuid, menu[128], class, buffer[32], buffer2[32], buffer3[32]
	
	// Title
	formatex(menu, charsmax(menu), "%L\r", id, "MENU_HCLASS_TITLE")
	menuid = menu_create(menu, "menu_hclass")

	// Class List
	for (class = 0; class < g_hclass_i; class++)
	{
		// Retrieve name, info and level
		ArrayGetString(g_hclass_name, class, buffer, charsmax(buffer))
		ArrayGetString(g_hclass_info, class, buffer2, charsmax(buffer2))
		ArrayGetString(g_hclass_level, class, buffer3, charsmax(buffer3))
		
		// Add to menu
		if (class == g_humanclassnext[id])
			formatex(menu, charsmax(menu), "\y%s \r| \y%s \r| \y%d \r|", buffer, buffer2, buffer3)
		else if(ArrayGetCell(g_hclass_level, class) > g_level[id])
			formatex(menu, charsmax(menu), "\d%s \r| \y%s \r| \y%d \r|", buffer, buffer2, buffer3)
		else if(ArrayGetCell(g_hclass_level, class) <= g_level[id])
			formatex(menu, charsmax(menu), "\w%s \r| \y%s \r| \y%d \r|", buffer, buffer2, buffer3)
		
		buffer[0] = class
		buffer[1] = 0
		menu_additem(menuid, menu, buffer)
	}
	
	// Back - Next - Exit
	formatex(menu, charsmax(menu), "%L", id, "MENU_BACK")
	menu_setprop(menuid, MPROP_BACKNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_NEXT")
	menu_setprop(menuid, MPROP_NEXTNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_EXIT")
	menu_setprop(menuid, MPROP_EXITNAME, menu)
	
	menu_display(id, menuid)
}

// Admin Menu
show_menu_admin(id)
{
	static userflags
	new formmenu[555]
	userflags = g_privileges[id]
	new admenu = menu_create("\rControl Board:", "menu_admin")

	// Zombiefy/Humanize command
	if (userflags & (g_access_flag[ACCESS_MODE_INFECTION] | g_access_flag[ACCESS_MAKE_ZOMBIE] | g_access_flag[ACCESS_MAKE_HUMAN]))
		formatex(formmenu, 63, "\w%L", id, "MENU_ADMIN1")
	else
		formatex(formmenu, 63, "\d%L", id, "MENU_ADMIN1")
	menu_additem(admenu, formmenu)
	
	// Nemesis command
	if (userflags & (g_access_flag[ACCESS_MODE_NEMESIS] | g_access_flag[ACCESS_MAKE_NEMESIS]))
		formatex(formmenu, 63, "\w%L", id, "MENU_ADMIN2")
	else
		formatex(formmenu, 63, "\d%L", id, "MENU_ADMIN2")
	menu_additem(admenu, formmenu)
	
	// Survivor command
	if (userflags & (g_access_flag[ACCESS_MODE_SURVIVOR] | g_access_flag[ACCESS_MAKE_SURVIVOR]))
		formatex(formmenu, 63, "\w%L", id, "MENU_ADMIN3")
	else
		formatex(formmenu, 63, "\d%L", id, "MENU_ADMIN3")
	menu_additem(admenu, formmenu)
	
	// Sniper command
	if (userflags & (g_access_flag[ACCESS_MODE_SNIPER] | g_access_flag[ACCESS_MAKE_SNIPER]))
		formatex(formmenu, 63, "\w%L", id, "MENU_ADMIN8")
	else
		formatex(formmenu, 63, "\d%L", id, "MENU_ADMIN8")
	menu_additem(admenu, formmenu)
	
	// Assassin command
	if (userflags & (g_access_flag[ACCESS_MODE_ASSASSIN] | g_access_flag[ACCESS_MAKE_ASSASSIN]))
		formatex(formmenu, 63, "\w%L", id, "MENU_ADMIN9")
	else
		formatex(formmenu, 63, "\d%L", id, "MENU_ADMIN9")
	menu_additem(admenu, formmenu)

	// Flamer command
	if (userflags & (g_access_flag[ACCESS_MODE_FLAMER] | g_access_flag[ACCESS_MAKE_FLAMER]))
		formatex(formmenu, 63, "\w%L", id, "MENU_ADMIN51")
	else
		formatex(formmenu, 63, "\d%L", id, "MENU_ADMIN51")
	menu_additem(admenu, formmenu)

	// Genesys command
	if (userflags & (g_access_flag[ACCESS_MODE_GENESYS] | g_access_flag[ACCESS_MAKE_GENESYS]))
		formatex(formmenu, 63, "\w%L", id, "MENU_ADMIN50")
	else
		formatex(formmenu, 63, "\d%L", id, "MENU_ADMIN50")
	menu_additem(admenu, formmenu)

	// Oberon command
	if (userflags & (g_access_flag[ACCESS_MODE_OBERON] | g_access_flag[ACCESS_MAKE_OBERON]))
		formatex(formmenu, 63, "\w%L", id, "MENU_ADMIN19")
	else
		formatex(formmenu, 63, "\d%L", id, "MENU_ADMIN19")
	menu_additem(admenu, formmenu)

	// Zadoc command
	if (userflags & (g_access_flag[ACCESS_MODE_ZADOC] | g_access_flag[ACCESS_MAKE_ZADOC]))
		formatex(formmenu, 63, "\w%L", id, "MENU_ADMIN51A")
	else
		formatex(formmenu, 63, "\d%L", id, "MENU_ADMIN51A")
	menu_additem(admenu, formmenu)

	// Dragon command
	if (userflags & (g_access_flag[ACCESS_MODE_DRAGON] | g_access_flag[ACCESS_MAKE_DRAGON]))
		formatex(formmenu, 63, "\w%L", id, "MENU_ADMIN19A")
	else
		formatex(formmenu, 63, "\d%L", id, "MENU_ADMIN19A")
	menu_additem(admenu, formmenu)

	// Nighter command
	if (userflags & (g_access_flag[ACCESS_MODE_NIGHTER] | g_access_flag[ACCESS_MAKE_NIGHTER]))
		formatex(formmenu, 63, "\w%L", id, "MENU_ADMIN19B")
	else
		formatex(formmenu, 63, "\d%L", id, "MENU_ADMIN19B")
	menu_additem(admenu, formmenu)
	
	// Respawn command
	if (userflags & g_access_flag[ACCESS_RESPAWN_PLAYERS])
		formatex(formmenu, 63, "\w%L", id, "MENU_ADMIN4")
	else
		formatex(formmenu, 63, "\d%L", id, "MENU_ADMIN4")
	menu_additem(admenu, formmenu)
			
	menu_setprop(admenu, MPROP_BACKNAME, "Back")
	menu_setprop(admenu, MPROP_NEXTNAME, "Next")
	menu_setprop(admenu, MPROP_EXITNAME, "Exit")	
	menu_display(id, admenu)
}

// Admin Menu 2
show_menu2_admin(id)
{
	static menu[250], len, userflags
	len = 0
	userflags = g_privileges[id]
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\y%L^n^n", id, "MENU2_ADMIN_TITLE")
	
	// 1. Multi infection command
	if ((userflags & g_access_flag[ACCESS_MODE_MULTI]) && allowed_multi())
		len += formatex(menu[len], charsmax(menu) - len, "\r1.\w %L^n", id, "MENU_ADMIN6")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d1. %L^n", id, "MENU_ADMIN6")
		
	// 2. Swarm mode command
	if ((userflags & g_access_flag[ACCESS_MODE_SWARM]) && allowed_swarm())
		len += formatex(menu[len], charsmax(menu) - len, "\r2.\w %L^n", id, "MENU_ADMIN5")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d2. %L^n", id, "MENU_ADMIN5")
	
	// 3. Plague mode command
	if ((userflags & g_access_flag[ACCESS_MODE_PLAGUE]) && allowed_plague())
		len += formatex(menu[len], charsmax(menu) - len, "\r3.\w %L^n", id, "MENU_ADMIN7")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d3. %L^n", id, "MENU_ADMIN7")
	
	// 4. LNJ mode command
	if ((userflags & g_access_flag[ACCESS_MODE_LNJ]) && allowed_lnj())
		len += formatex(menu[len], charsmax(menu) - len, "\r4.\w %L^n", id, "MENU_ADMIN10")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d4. %L^n", id, "MENU_ADMIN10")

	// 5. Guardians mode command
	if ((userflags & g_access_flag[ACCESS_MODE_GUARDIANS]) && allowed_guardians())
		len += formatex(menu[len], charsmax(menu) - len, "\r5.\w %L^n", id, "MENU_ADMIN10A")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d5. %L^n", id, "MENU_ADMIN10A")

	// 9. Exit
	len += formatex(menu[len], charsmax(menu) - len, "^n\r9.\w %L", id, "MENU_EXIT")
	
	// 0. Back
	len += formatex(menu[len], charsmax(menu) - len, "^n\r0.\w %L", id, "MENU_BACK")
	
	show_menu(id, KEYSMENU, menu, -1, "Menu2 Admin")
}

// Admin Menu 3
show_menu3_admin(id)
{
	static menu[245], len, userflags
	len = 0
	userflags = g_privileges[id]
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\y%L^n^n", id, "MENU3_ADMIN_TITLE")
	
	// 1. Admin menu of classes
	if (userflags & g_access_flag[ACCESS_ADMIN_MENU] && g_mused[id] == 0 || (get_user_flags(id) & ADMIN_RCON))
		len += formatex(menu[len], charsmax(menu) - len, "\r1.\w %L^n", id, "MENU_ADMIN")
	else if (userflags & g_access_flag[ACCESS_ADMIN_MENU] && g_mused[id] == 1)
		len += formatex(menu[len], charsmax(menu) - len, "\d1. %L^n", id, "MENU_ADMIN")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d1. %L^n", id, "MENU_ADMIN")

	// 2. Main Modes admin menu
	if (userflags & g_access_flag[ACCESS_ADMIN_MENU2] && g_mused[id] == 0 || (get_user_flags(id) & ADMIN_RCON))
		len += formatex(menu[len], charsmax(menu) - len, "\r2.\w %L^n", id, "MENU2_ADMIN")
	else if (userflags & g_access_flag[ACCESS_ADMIN_MENU2] && g_mused[id] == 1)
		len += formatex(menu[len], charsmax(menu) - len, "\d2. %L^n", id, "MENU2_ADMIN")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d2. %L^n", id, "MENU2_ADMIN")

	// 3. Weapons admin menu
	if (!g_zombie[id] && is_user_alive(id) && !native_get_human_hero(id) && !native_get_zombie_hero(id) && ((g_privileges[id] & MODE_FLAG_U) || (g_privileges[id] & MODE_FLAG_V) || (g_privileges[id] & MODE_FLAG_W)))
		len += formatex(menu[len], charsmax(menu) - len, "\r3.\r %L^n^n", id, "MENU5_ADMIN")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d3. %L^n^n", id, "MENU5_ADMIN")

	// 4. Event
	if (g_privileges[id] & MODE_FLAG_X)
		len += formatex(menu[len], charsmax(menu) - len, "\r4.\w %L^n", id, "MENU6_ADMIN")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d4. %L^n", id, "MENU6_ADMIN")
	
	// 5. Turn the Mod off
	if (userflags & g_access_flag[ACCESS_ENABLE_MOD])
	{
		len += formatex(menu[len], charsmax(menu) - len, "\r5.\w %L^n", id, "MENU4_ADMIN")
		len += formatex(menu[len], charsmax(menu) - len, "\y    %L^n^n", id, "MENU4_ADMIN3")
	}
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d5. %L^n", id, "MENU4_ADMIN")
	
	
	// 0. Exit
	len += formatex(menu[len], charsmax(menu) - len, "^n\r0.\w %L", id, "MENU_EXIT")
	
	show_menu(id, KEYSMENU, menu, -1, "Menu3 Admin")
}

// Mod turn off menu
show_menu4_admin(id)
{
	static menu[240], len
	len = 0
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\y%L^n^n", id, "MENU4_ADMIN_TITLE")
	
	len += formatex(menu[len], charsmax(menu) - len, "\r1.\w %L^n", id, "MENU4_ADMIN1")
	len += formatex(menu[len], charsmax(menu) - len, "\r    %L^n^n", id, "MENU4_ADMIN3")
	
	len += formatex(menu[len], charsmax(menu) - len, "\r2.\w %L^n", id, "MENU4_ADMIN2")
	
	// 0. Exit
	len += formatex(menu[len], charsmax(menu) - len, "^n\r0.\w %L", id, "MENU_EXIT")
	
	show_menu(id, KEYSMENU, menu, -1, "Menu4 Admin")
}


// Player List Menu
show_menu_player_list(id)
{
	static menuid, menu[128], player, userflags, buffer[2]
	userflags = g_privileges[id]
	
	// Title
	switch (PL_ACTION)
	{
		case 0: formatex(menu, charsmax(menu), "%L\r", id, "MENU_ADMIN1")
		case 1: formatex(menu, charsmax(menu), "%L\r", id, "MENU_ADMIN2")
		case 2: formatex(menu, charsmax(menu), "%L\r", id, "MENU_ADMIN3")
		case 3: formatex(menu, charsmax(menu), "%L\r", id, "MENU_ADMIN8")
		case 4: formatex(menu, charsmax(menu), "%L\r", id, "MENU_ADMIN9")
		case 5: formatex(menu, charsmax(menu), "%L\r", id, "MENU_ADMIN51")
		case 6: formatex(menu, charsmax(menu), "%L\r", id, "MENU_ADMIN50")
		case 7: formatex(menu, charsmax(menu), "%L\r", id, "MENU_ADMIN19")
		case 8: formatex(menu, charsmax(menu), "%L\r", id, "MENU_ADMIN51A")
		case 9: formatex(menu, charsmax(menu), "%L\r", id, "MENU_ADMIN19A")
		case 10: formatex(menu, charsmax(menu), "%L\r", id, "MENU_ADMIN19B")
		case 11: formatex(menu, charsmax(menu), "%L\r", id, "MENU_ADMIN4")
	}
	menuid = menu_create(menu, "menu_player_list")
	
	// Player List
	for (player = 0; player <= g_maxplayers; player++)
	{
		// Skip if not connected
		if (!g_isconnected[player])
			continue;
		
		// Format text depending on the action to take
		switch (PL_ACTION)
		{
			case 0: // Zombiefy/Humanize command
			{
				if (g_zombie[player])
				{
					if (allowed_human(player) && (userflags & g_access_flag[ACCESS_MAKE_HUMAN]))
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NEMESIS")
						if (g_assassin[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ASSASSIN")
						if (g_oberon[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_OBERON")
						if (g_genesys[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_GENESYS")
						if (g_dragon[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_DRAGON")
						if (g_nighter[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NIGHTER")
						if (g_nchild[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NCHILD")
						if (g_evil[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_EVIL")
						if (!g_nemesis[player] && !g_assassin[player] && !g_genesys[player] && !g_oberon[player] && !g_dragon[player] && !g_nighter[player] && !g_nchild[player] && !g_evil[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NEMESIS")
						if (g_assassin[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ASSASSIN")
						if (g_oberon[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_OBERON")
						if (g_genesys[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_GENESYS")
						if (g_dragon[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_DRAGON")
						if (g_nighter[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NIGHTER")
						if (g_nchild[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NCHILD")
						if (g_evil[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_EVIL")
						if (!g_nemesis[player] && !g_assassin[player] && !g_genesys[player] && !g_oberon[player] && !g_dragon[player] && !g_nighter[player] && !g_nchild[player] && !g_evil[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
				}
				else
				{
					if (allowed_zombie(player) && (g_newround ? (userflags & g_access_flag[ACCESS_MODE_INFECTION]) : (userflags & g_access_flag[ACCESS_MAKE_ZOMBIE])))
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SURVIVOR")
						if (g_sniper[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SNIPER")
						if (g_flamer[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_FLAMER")
						if (g_zadoc[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_ZADOC")
						if (g_hero[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HERO")
						if (!g_survivor[player] && !g_sniper[player] && !g_flamer[player] && !g_zadoc[player] && !g_hero[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HUMAN")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SURVIVOR")
						if (g_sniper[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SNIPER")
						if (g_flamer[player])
							formatex(menu, charsmax(menu), "\d%s \y[%L]", g_playername[player], id, "CLASS_FLAMER")
						if (g_zadoc[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZADOC")
						if (g_hero[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HERO")
						if (!g_survivor[player] && !g_sniper[player] && !g_flamer[player] && !g_zadoc[player] && !g_hero[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
			}
			case 1: // Nemesis command
			{
				if (allowed_nemesis(player) && (g_newround ? (userflags & g_access_flag[ACCESS_MODE_NEMESIS]) : (userflags & g_access_flag[ACCESS_MAKE_NEMESIS])))
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NEMESIS")
						if (g_assassin[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ASSASSIN")
						if (g_oberon[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_OBERON")
						if (g_genesys[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_GENESYS")
						if (g_dragon[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_DRAGON")
						if (g_nighter[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NIGHTER")
						if (g_nchild[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NCHILD")
						if (g_evil[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_EVIL")
						if (!g_nemesis[player] && !g_assassin[player] && !g_genesys[player] && !g_oberon[player] && !g_dragon[player] && !g_nighter[player] && !g_nchild[player] && !g_evil[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SURVIVOR")
						if (g_sniper[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SNIPER")
						if (g_flamer[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_FLAMER")
						if (g_zadoc[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_ZADOC")
						if (g_hero[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HERO")
						if (!g_survivor[player] && !g_sniper[player] && !g_flamer[player] && !g_zadoc[player] && !g_hero[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
				else
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NEMESIS")
						if (g_assassin[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ASSASSIN")
						if (g_oberon[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_OBERON")
						if (g_genesys[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_GENESYS")
						if (g_dragon[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_DRAGON")
						if (g_nighter[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NIGHTER")
						if (g_nchild[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NCHILD")
						if (g_evil[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_EVIL")
						if (!g_nemesis[player] && !g_assassin[player] && !g_genesys[player] && !g_oberon[player] && !g_dragon[player] && !g_nighter[player] && !g_nchild[player] && !g_evil[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SURVIVOR")
						if (g_sniper[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SNIPER")
						if (g_flamer[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_FLAMER")
						if (g_zadoc[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZADOC")
						if (g_hero[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HERO")
						if (!g_survivor[player] && !g_sniper[player] && !g_flamer[player] && !g_zadoc[player] && !g_hero[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
			}
			case 2: // Survivor command
			{
				if (allowed_survivor(player) && (g_newround ? (userflags & g_access_flag[ACCESS_MODE_SURVIVOR]) : (userflags & g_access_flag[ACCESS_MAKE_SURVIVOR])))
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NEMESIS")
						if (g_assassin[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ASSASSIN")
						if (g_oberon[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_OBERON")
						if (g_genesys[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_GENESYS")
						if (g_dragon[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_DRAGON")
						if (g_nighter[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NIGHTER")
						if (g_nchild[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NCHILD")
						if (g_evil[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_EVIL")
						if (!g_nemesis[player] && !g_assassin[player] && !g_genesys[player] && !g_oberon[player] && !g_dragon[player] && !g_nighter[player] && !g_nchild[player] && !g_evil[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SURVIVOR")
						if (g_sniper[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SNIPER")
						if (g_flamer[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_FLAMER")
						if (g_zadoc[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_ZADOC")
						if (g_hero[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HERO")
						if (!g_survivor[player] && !g_sniper[player] && !g_flamer[player] && !g_zadoc[player] && !g_hero[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
				else
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NEMESIS")
						if (g_assassin[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ASSASSIN")
						if (g_oberon[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_OBERON")
						if (g_genesys[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_GENESYS")
						if (g_dragon[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_DRAGON")
						if (g_nighter[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NIGHTER")
						if (g_nchild[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NCHILD")
						if (g_evil[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_EVIL")
						if (!g_nemesis[player] && !g_assassin[player] && !g_genesys[player] && !g_oberon[player] && !g_dragon[player] && !g_nighter[player] && !g_nchild[player] && !g_evil[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SURVIVOR")
						if (g_sniper[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SNIPER")
						if (g_flamer[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_FLAMER")
						if (g_zadoc[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZADOC")
						if (g_hero[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HERO")
						if (!g_survivor[player] && !g_sniper[player] && !g_flamer[player] && !g_zadoc[player] && !g_hero[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
			}
			case 3: // Sniper command
			{
				if (allowed_sniper(player) && (g_newround ? (userflags & g_access_flag[ACCESS_MODE_SNIPER]) : (userflags & g_access_flag[ACCESS_MAKE_SNIPER])))
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NEMESIS")
						if (g_assassin[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ASSASSIN")
						if (g_oberon[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_OBERON")
						if (g_genesys[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_GENESYS")
						if (g_dragon[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_DRAGON")
						if (g_nighter[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NIGHTER")
						if (g_nchild[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NCHILD")
						if (g_evil[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_EVIL")
						if (!g_nemesis[player] && !g_assassin[player] && !g_genesys[player] && !g_oberon[player] && !g_dragon[player] && !g_nighter[player] && !g_nchild[player] && !g_evil[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SURVIVOR")
						if (g_sniper[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SNIPER")
						if (g_flamer[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_FLAMER")
						if (g_zadoc[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_ZADOC")
						if (g_hero[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HERO")
						if (!g_survivor[player] && !g_sniper[player] && !g_flamer[player] && !g_zadoc[player] && !g_hero[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
				else
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NEMESIS")
						if (g_assassin[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ASSASSIN")
						if (g_oberon[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_OBERON")
						if (g_genesys[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_GENESYS")
						if (g_dragon[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_DRAGON")
						if (g_nighter[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NIGHTER")
						if (g_nchild[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NCHILD")
						if (g_evil[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_EVIL")
						if (!g_nemesis[player] && !g_assassin[player] && !g_genesys[player] && !g_oberon[player] && !g_dragon[player] && !g_nighter[player] && !g_nchild[player] && !g_evil[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SURVIVOR")
						if (g_sniper[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SNIPER")
						if (g_flamer[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_FLAMER")
						if (g_zadoc[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZADOC")
						if (g_hero[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HERO")
						if (!g_survivor[player] && !g_sniper[player] && !g_flamer[player] && !g_zadoc[player] && !g_hero[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
			}
			case 4: // Flamer command
			{
				if (allowed_flamer(player) && (g_newround ? (userflags & g_access_flag[ACCESS_MODE_FLAMER]) : (userflags & g_access_flag[ACCESS_MAKE_FLAMER])))
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NEMESIS")
						if (g_assassin[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ASSASSIN")
						if (g_oberon[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_OBERON")
						if (g_genesys[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_GENESYS")
						if (g_dragon[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_DRAGON")
						if (g_nighter[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NIGHTER")
						if (g_nchild[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NCHILD")
						if (g_evil[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_EVIL")
						if (!g_nemesis[player] && !g_assassin[player] && !g_genesys[player] && !g_oberon[player] && !g_dragon[player] && !g_nighter[player] && !g_nchild[player] && !g_evil[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SURVIVOR")
						if (g_sniper[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SNIPER")
						if (g_flamer[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_FLAMER")
						if (g_zadoc[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_ZADOC")
						if (g_hero[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HERO")
						if (!g_survivor[player] && !g_sniper[player] && !g_flamer[player] && !g_zadoc[player] && !g_hero[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
				else
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NEMESIS")
						if (g_assassin[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ASSASSIN")
						if (g_oberon[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_OBERON")
						if (g_genesys[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_GENESYS")
						if (g_dragon[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_DRAGON")
						if (g_nighter[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NIGHTER")
						if (g_nchild[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NCHILD")
						if (g_evil[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_EVIL")
						if (!g_nemesis[player] && !g_assassin[player] && !g_genesys[player] && !g_oberon[player] && !g_dragon[player] && !g_nighter[player] && !g_nchild[player] && !g_evil[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SURVIVOR")
						if (g_sniper[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SNIPER")
						if (g_flamer[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_FLAMER")
						if (g_zadoc[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZADOC")
						if (g_hero[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HERO")
						if (!g_survivor[player] && !g_sniper[player] && !g_flamer[player] && !g_zadoc[player] && !g_hero[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
			}
			case 5: // Assassin command
			{
				if (allowed_assassin(player) && (g_newround ? (userflags & g_access_flag[ACCESS_MODE_ASSASSIN]) : (userflags & g_access_flag[ACCESS_MAKE_ASSASSIN])))
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NEMESIS")
						if (g_assassin[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ASSASSIN")
						if (g_oberon[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_OBERON")
						if (g_genesys[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_GENESYS")
						if (g_dragon[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_DRAGON")
						if (g_nighter[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NIGHTER")
						if (g_nchild[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NCHILD")
						if (g_evil[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_EVIL")
						if (!g_nemesis[player] && !g_assassin[player] && !g_genesys[player] && !g_oberon[player] && !g_dragon[player] && !g_nighter[player] && !g_nchild[player] && !g_evil[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SURVIVOR")
						if (g_sniper[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SNIPER")
						if (g_flamer[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_FLAMER")
						if (g_zadoc[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_ZADOC")
						if (g_hero[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HERO")
						if (!g_survivor[player] && !g_sniper[player] && !g_flamer[player] && !g_zadoc[player] && !g_hero[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
				else
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NEMESIS")
						if (g_assassin[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ASSASSIN")
						if (g_oberon[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_OBERON")
						if (g_genesys[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_GENESYS")
						if (g_dragon[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_DRAGON")
						if (g_nighter[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NIGHTER")
						if (g_nchild[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NCHILD")
						if (g_evil[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_EVIL")
						if (!g_nemesis[player] && !g_assassin[player] && !g_genesys[player] && !g_oberon[player] && !g_dragon[player] && !g_nighter[player] && !g_nchild[player] && !g_evil[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SURVIVOR")
						if (g_sniper[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SNIPER")
						if (g_flamer[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_FLAMER")
						if (g_zadoc[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZADOC")
						if (g_hero[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HERO")
						if (!g_survivor[player] && !g_sniper[player] && !g_flamer[player] && !g_zadoc[player] && !g_hero[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
			}
			case 6: // Genesys command
			{
				if (allowed_genesys(player) && (g_newround ? (userflags & g_access_flag[ACCESS_MODE_GENESYS]) : (userflags & g_access_flag[ACCESS_MAKE_GENESYS])))
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NEMESIS")
						if (g_assassin[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ASSASSIN")
						if (g_oberon[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_OBERON")
						if (g_genesys[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_GENESYS")
						if (g_dragon[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_DRAGON")
						if (g_nighter[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NIGHTER")
						if (g_nchild[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NCHILD")
						if (g_evil[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_EVIL")
						if (!g_nemesis[player] && !g_assassin[player] && !g_genesys[player] && !g_oberon[player] && !g_dragon[player] && !g_nighter[player] && !g_nchild[player] && !g_evil[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SURVIVOR")
						if (g_sniper[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SNIPER")
						if (g_flamer[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_FLAMER")
						if (g_zadoc[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_ZADOC")
						if (g_hero[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HERO")
						if (!g_survivor[player] && !g_sniper[player] && !g_flamer[player] && !g_zadoc[player] && !g_hero[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
				else
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NEMESIS")
						if (g_assassin[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ASSASSIN")
						if (g_oberon[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_OBERON")
						if (g_genesys[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_GENESYS")
						if (g_dragon[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_DRAGON")
						if (g_nighter[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NIGHTER")
						if (g_nchild[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NCHILD")
						if (g_evil[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_EVIL")
						if (!g_nemesis[player] && !g_assassin[player] && !g_genesys[player] && !g_oberon[player] && !g_dragon[player] && !g_nighter[player] && !g_nchild[player] && !g_evil[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SURVIVOR")
						if (g_sniper[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SNIPER")
						if (g_flamer[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_FLAMER")
						if (g_zadoc[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZADOC")
						if (g_hero[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HERO")
						if (!g_survivor[player] && !g_sniper[player] && !g_flamer[player] && !g_zadoc[player] && !g_hero[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
			}
			case 7: // Oberon command
			{
				if (allowed_oberon(player) && (g_newround ? (userflags & g_access_flag[ACCESS_MODE_OBERON]) : (userflags & g_access_flag[ACCESS_MAKE_OBERON])))
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NEMESIS")
						if (g_assassin[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ASSASSIN")
						if (g_oberon[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_OBERON")
						if (g_genesys[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_GENESYS")
						if (g_dragon[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_DRAGON")
						if (g_nighter[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NIGHTER")
						if (g_nchild[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NCHILD")
						if (g_evil[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_EVIL")
						if (!g_nemesis[player] && !g_assassin[player] && !g_genesys[player] && !g_oberon[player] && !g_dragon[player] && !g_nighter[player] && !g_nchild[player] && !g_evil[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SURVIVOR")
						if (g_sniper[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SNIPER")
						if (g_flamer[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_FLAMER")
						if (g_zadoc[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_ZADOC")
						if (g_hero[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HERO")
						if (!g_survivor[player] && !g_sniper[player] && !g_flamer[player] && !g_zadoc[player] && !g_hero[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
				else
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NEMESIS")
						if (g_assassin[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ASSASSIN")
						if (g_oberon[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_OBERON")
						if (g_genesys[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_GENESYS")
						if (g_dragon[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_DRAGON")
						if (g_nighter[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NIGHTER")
						if (g_nchild[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NCHILD")
						if (g_evil[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_EVIL")
						if (!g_nemesis[player] && !g_assassin[player] && !g_genesys[player] && !g_oberon[player] && !g_dragon[player] && !g_nighter[player] && !g_nchild[player] && !g_evil[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SURVIVOR")
						if (g_sniper[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SNIPER")
						if (g_flamer[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_FLAMER")
						if (g_zadoc[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZADOC")
						if (g_hero[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HERO")
						if (!g_survivor[player] && !g_sniper[player] && !g_flamer[player] && !g_zadoc[player] && !g_hero[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
			}
			case 8: // Zadoc command
			{
				if (allowed_zadoc(player) && (g_newround ? (userflags & g_access_flag[ACCESS_MODE_ZADOC]) : (userflags & g_access_flag[ACCESS_MAKE_ZADOC])))
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NEMESIS")
						if (g_assassin[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ASSASSIN")
						if (g_oberon[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_OBERON")
						if (g_genesys[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_GENESYS")
						if (g_dragon[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_DRAGON")
						if (g_nighter[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NIGHTER")
						if (g_nchild[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NCHILD")
						if (g_evil[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_EVIL")
						if (!g_nemesis[player] && !g_assassin[player] && !g_genesys[player] && !g_oberon[player] && !g_dragon[player] && !g_nighter[player] && !g_nchild[player] && !g_evil[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SURVIVOR")
						if (g_sniper[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SNIPER")
						if (g_flamer[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_FLAMER")
						if (g_zadoc[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_ZADOC")
						if (g_hero[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HERO")
						if (!g_survivor[player] && !g_sniper[player] && !g_flamer[player] && !g_zadoc[player] && !g_hero[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
				else
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NEMESIS")
						if (g_assassin[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ASSASSIN")
						if (g_oberon[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_OBERON")
						if (g_genesys[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_GENESYS")
						if (g_dragon[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_DRAGON")
						if (g_nighter[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NIGHTER")
						if (g_nchild[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NCHILD")
						if (g_evil[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_EVIL")
						if (!g_nemesis[player] && !g_assassin[player] && !g_genesys[player] && !g_oberon[player] && !g_dragon[player] && !g_nighter[player] && !g_nchild[player] && !g_evil[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SURVIVOR")
						if (g_sniper[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SNIPER")
						if (g_flamer[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_FLAMER")
						if (g_zadoc[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZADOC")
						if (g_hero[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HERO")
						if (!g_survivor[player] && !g_sniper[player] && !g_flamer[player] && !g_zadoc[player] && !g_hero[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
			}
			case 9: // Dragon command
			{
				if (allowed_dragon(player) && (g_newround ? (userflags & g_access_flag[ACCESS_MODE_DRAGON]) : (userflags & g_access_flag[ACCESS_MAKE_DRAGON])))
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NEMESIS")
						if (g_assassin[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ASSASSIN")
						if (g_oberon[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_OBERON")
						if (g_genesys[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_GENESYS")
						if (g_dragon[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_DRAGON")
						if (g_nighter[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NIGHTER")
						if (g_nchild[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NCHILD")
						if (g_evil[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_EVIL")
						if (!g_nemesis[player] && !g_assassin[player] && !g_genesys[player] && !g_oberon[player] && !g_dragon[player] && !g_nighter[player] && !g_nchild[player] && !g_evil[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SURVIVOR")
						if (g_sniper[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SNIPER")
						if (g_flamer[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_FLAMER")
						if (g_zadoc[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_ZADOC")
						if (g_hero[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HERO")
						if (!g_survivor[player] && !g_sniper[player] && !g_flamer[player] && !g_zadoc[player] && !g_hero[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
				else
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NEMESIS")
						if (g_assassin[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ASSASSIN")
						if (g_oberon[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_OBERON")
						if (g_genesys[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_GENESYS")
						if (g_dragon[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_DRAGON")
						if (g_nighter[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NIGHTER")
						if (g_nchild[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NCHILD")
						if (g_evil[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_EVIL")
						if (!g_nemesis[player] && !g_assassin[player] && !g_genesys[player] && !g_oberon[player] && !g_dragon[player] && !g_nighter[player] && !g_nchild[player] && !g_evil[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SURVIVOR")
						if (g_sniper[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SNIPER")
						if (g_flamer[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_FLAMER")
						if (g_zadoc[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZADOC")
						if (g_hero[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HERO")
						if (!g_survivor[player] && !g_sniper[player] && !g_flamer[player] && !g_zadoc[player] && !g_hero[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
			}
			case 10: // Nighter command
			{
				if (allowed_nighter(player) && (g_newround ? (userflags & g_access_flag[ACCESS_MODE_NIGHTER]) : (userflags & g_access_flag[ACCESS_MAKE_NIGHTER])))
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NEMESIS")
						if (g_assassin[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ASSASSIN")
						if (g_oberon[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_OBERON")
						if (g_genesys[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_GENESYS")
						if (g_dragon[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_DRAGON")
						if (g_nighter[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NIGHTER")
						if (g_nchild[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NCHILD")
						if (g_evil[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_EVIL")
						if (!g_nemesis[player] && !g_assassin[player] && !g_genesys[player] && !g_oberon[player] && !g_dragon[player] && !g_nighter[player] && !g_nchild[player] && !g_evil[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SURVIVOR")
						if (g_sniper[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SNIPER")
						if (g_flamer[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_FLAMER")
						if (g_zadoc[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_ZADOC")
						if (g_hero[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HERO")
						if (!g_survivor[player] && !g_sniper[player] && !g_flamer[player] && !g_zadoc[player] && !g_hero[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
				else
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NEMESIS")
						if (g_assassin[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ASSASSIN")
						if (g_oberon[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_OBERON")
						if (g_genesys[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_GENESYS")
						if (g_dragon[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_DRAGON")
						if (g_nighter[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NIGHTER")
						if (g_nchild[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NCHILD")
						if (g_evil[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_EVIL")
						if (!g_nemesis[player] && !g_assassin[player] && !g_genesys[player] && !g_oberon[player] && !g_dragon[player] && !g_nighter[player] && !g_nchild[player] && !g_evil[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SURVIVOR")
						if (g_sniper[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SNIPER")
						if (g_flamer[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_FLAMER")
						if (g_zadoc[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZADOC")
						if (g_hero[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HERO")
						if (!g_survivor[player] && !g_sniper[player] && !g_flamer[player] && !g_zadoc[player] && !g_hero[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
			}
			case 11: // Respawn command
			{
				if (allowed_respawn(player) && (userflags & g_access_flag[ACCESS_RESPAWN_PLAYERS]))
					formatex(menu, charsmax(menu), "%s", g_playername[player])
				else
					formatex(menu, charsmax(menu), "\d%s", g_playername[player])
			}
		}
		
		// Add player
		buffer[0] = player
		buffer[1] = 0
		menu_additem(menuid, menu, buffer)
	}
	
	// Back - Next - Exit
	formatex(menu, charsmax(menu), "%L", id, "MENU_BACK")
	menu_setprop(menuid, MPROP_BACKNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_NEXT")
	menu_setprop(menuid, MPROP_NEXTNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_EXIT")
	menu_setprop(menuid, MPROP_EXITNAME, menu)
	
	menu_display(id, menuid)
}

/*================================================================================
 [Menu Handlers]
=================================================================================*/

// Game Menu
public menu_game(id, key)
{
	switch (key)
	{
		case 0: // Buy Menu
		{
		if (g_isalive[id])
			AwesomeMenu(id)
		else
			zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")

		}
		case 1: // Powers System
		{
                       	menu_powers(id)
                }
		case 2: // Exchange / Donate
		{
			exdon(id)
                }
		case 3: // Zombie Crown Level
		{
                        choseclass(id)
                }
		case 4: // Register Nick
	        {
                        ClCmdSayRegisterNick(id)
                }
		case 5: // Respawn?
		{
                        showmoremenu(id);
		}
		case 6: // Join Spectator
		{
			if (get_user_flags(id) & ADMIN_RESERVATION)
			{
				changetheteam(id)
			}else {
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
			}
		}

		case 7: // Unstuck
		{
			// Check if player is stuck
			if (g_isalive[id])
			{
				if (is_player_stuck(id))
				{
					// Move to an initial spawn
					do_spawn(id) // regular spawn
				}
				else
					zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_STUCK")
			}
			else
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
		}

		case 8: // Admin Menu
		{
			// Check if player has the required access
			if (g_privileges[id] & g_access_flag[ACCESS_ADMIN_MENU3])
			{
				show_menu3_admin(id)
			}else {
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
			}
		}
	}
	return PLUGIN_HANDLED;
}

public showmoremenu(id)
{
        new buffer[350]
	show_menu(id, 0, "\n", 1)
	new menu = menu_create("\rMore Options:", "menu_showmemore");
	menu_additem(menu, "\wRevive\y [or write\r /respawn\w |\r res\y]", "", 0);
	menu_additem(menu, "\wMissions\y [or write\r /missions\w |\r mmenu\y]", "", 0);
        menu_additem(menu, "\wFree Benefits\y [or write\r /get\y]", "", 0);
        menu_additem(menu, "\wViP Menu\y [or write\r /vm\y]", "", 0);
        formatex(buffer, 255, "\wBuy Vip\y [or write\r /vip\w |\r /buyvip\y]^n^n    \yType\r /info player\y to show the player's information. \
        ^n    Type\r /missioninfo player\y to show the player's mission information.^n    Type\r /announce\y to announce a mode.");
        menu_additem(menu, buffer, "", 0);
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
}

public menu_showmemore(id, menu, item)
{
	switch(item)	
	{
		case 0: open_menu(id)
		case 1: ShowMissionsMenu(id)
                case 2: ShowGetMenu(id)
                case 3: menu_open(id)
                case 4: ShowMotd(id)
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

// Choose Class
public exdon(id)
{
	show_menu(id, 0, "\n", 1)
	new menu = menu_create("\rExchange or donate something:", "menu_exdon");
	menu_additem(menu, "\wExchange", "", 0);
	menu_additem(menu, "\wDonate^n    \yWe are not responsible for your transactions!", "", 0);
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
}

public menu_exdon(id, menu, item)
{
	switch(item)	
	{
		case 0: ExchangeSystem(id)
		case 1: donatemenu(id)
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

// Choose Class
public choseclass(id)
{
	show_menu(id, 0, "\n", 1)
	new menu = menu_create("\rGet a class for playing with:", "menu_chcls");
	menu_additem(menu, "\wHumans", "", 0);
	menu_additem(menu, "\wZombies", "", 0);
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
}

public menu_chcls(id, menu, item)
{
	switch(item)	
	{
		case 0:
		{
			// Human classes enabled?
			if (zc_human_classes)
				show_menu_hclass(id)
			else
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_HCLASSES")
		}
		case 1:
		{
			// Zombie classes enabled?
			if (zc_zombie_classes)
				show_menu_zclass(id)
			else
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ZCLASSES")
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

// Change Team
public changetheteam(id)
{
	show_menu(id, 0, "\n", 1)
	new menu = menu_create("\rChange team:", "menu_chteam");

	menu_additem(menu, "\wTerrorist", "", 0);
	menu_additem(menu, "\wCounter-Terrorist", "", 0);
	menu_additem(menu, "\wSpectator", "", 0);

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
    	
	menu_display(id, menu, 0);
   
}

public menu_chteam(id, menu, item)
{
	if(!is_user_valid_connected(id)) return PLUGIN_HANDLED
	switch(item)	
	{
		case 0:
		{
			if (g_isalive[id])
			{
				// Prevent abuse by non-admins if block suicide setting is enabled
				if (!(get_user_flags(id) & ADMIN_RESERVATION))
				{
					zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
					return PLUGIN_HANDLED;
				}

				if (fm_cs_get_user_team(id) == FM_CS_TEAM_T || fm_cs_get_user_team(id) == FM_CS_TEAM_CT)
				{
					zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
					return PLUGIN_HANDLED;
				}
				
				// Check that we still have both humans and zombies to keep the round going
				check_round(id)
				
				// Kill him before he switches team
				dllfunc(DLLFunc_ClientKill, id)
			}
			
			// Remove previous tasks
			remove_task(id+TASK_TEAM)
			remove_task(id+TASK_MODEL)
			remove_task(id+TASK_FLASH)
			remove_task(id+TASK_CHARGE)
			remove_task(id+TASK_SPAWN)
			remove_task(id+TASK_BLOOD)
			remove_task(id+TASK_AURA)
			remove_task(id+TASK_BURN)

			// Remove Flashlight Cone
			// set_cone_nodraw(id)

			// Then move him to the spectator team
			fm_cs_set_user_team(id, FM_CS_TEAM_T)
			fm_user_team_update(id)
		}
		case 1:
		{
			if (g_isalive[id])
			{
				// Prevent abuse by non-admins if block suicide setting is enabled
				if (!(get_user_flags(id) & ADMIN_RESERVATION))
				{
					zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
					return PLUGIN_HANDLED;
				}
				
				if (fm_cs_get_user_team(id) == FM_CS_TEAM_T || fm_cs_get_user_team(id) == FM_CS_TEAM_CT)
				{
					zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
					return PLUGIN_HANDLED;
				}

				// Check that we still have both humans and zombies to keep the round going
				check_round(id)
				
				// Kill him before he switches team
				dllfunc(DLLFunc_ClientKill, id)
			}
			
			// Remove previous tasks
			remove_task(id+TASK_TEAM)
			remove_task(id+TASK_MODEL)
			remove_task(id+TASK_FLASH)
			remove_task(id+TASK_CHARGE)
			remove_task(id+TASK_SPAWN)
			remove_task(id+TASK_BLOOD)
			remove_task(id+TASK_AURA)
			remove_task(id+TASK_BURN)

			// Remove Flashlight Cone
			// set_cone_nodraw(id)

			// Then move him to the spectator team
			fm_cs_set_user_team(id, FM_CS_TEAM_CT)
			fm_user_team_update(id)
		}
		case 2:
		{
			if (g_isalive[id])
			{
				// Prevent abuse by non-admins if block suicide setting is enabled
				if (!(get_user_flags(id) & ADMIN_RESERVATION))
				{
					zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
					return PLUGIN_HANDLED;
				}
				
				// Check that we still have both humans and zombies to keep the round going
				check_round(id)
				
				// Kill him before he switches team
				dllfunc(DLLFunc_ClientKill, id)
			}
			
			// Remove previous tasks
			remove_task(id+TASK_TEAM)
			remove_task(id+TASK_MODEL)
			remove_task(id+TASK_FLASH)
			remove_task(id+TASK_CHARGE)
			remove_task(id+TASK_SPAWN)
			remove_task(id+TASK_BLOOD)
			remove_task(id+TASK_AURA)
			remove_task(id+TASK_BURN)

			// Remove Flashlight Cone
			// set_cone_nodraw(id)

			// Then move him to the spectator team
			fm_cs_set_user_team(id, FM_CS_TEAM_SPECTATOR)
			fm_user_team_update(id)
		}
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public AwesomeMenu(id)
{
	show_menu(id, 0, "\n", 1)
	new menu = menu_create("\rMain shop:", "menu_handler")
	menu_additem(menu, "\wPublic Market", "", 0)
	menu_additem(menu, "\wDefault Guns", "", 0)
	menu_additem(menu, "\wVIP Market", "", 0)
	menu_additem(menu, "\wCoins Market", "", 0)
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
}
 
public menu_handler(id, menu, item)
{
	switch(item)	
	{
		case 0:
		{
			if (zc_extra_items)
			{
				// Check whether the player is able to buy anything
				if (g_isalive[id])
					show_menu_extras(id)
				else
					zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
			}
			else
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_EXTRAS")
		}
		case 1:
		{
			// Custom buy menus enabled?
			if (zc_buy_custom)
			{
				// Disable the remember selection setting
				WPN_AUTO_ON = 0
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "BUY_ENABLED")
			
				// Show menu if player hasn't yet bought anything
				if (g_canbuy[id]) show_menu_buy1(id)
			}
			else
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
		}
		case 2:
		{
			client_cmd(id, "vm")
		}
		case 3:
		{
			CoinShop(id)
		}
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

// Buy Menu 1
public menu_buy1(id, key)
{
	// Zombies, survivors or snipers get no guns
	if (!g_isalive[id] || g_zombie[id] || g_survivor[id] || g_sniper[id] || g_flamer[id] || g_zadoc[id])
		return PLUGIN_HANDLED;
	
	// Special keys / weapon list exceeded
	if (key >= MENU_KEY_AUTOSELECT || WPN_SELECTION >= WPN_MAXIDS)
	{
		switch (key)
		{
			case MENU_KEY_AUTOSELECT: // toggle auto select
			{
				WPN_AUTO_ON = 1 - WPN_AUTO_ON
			}
			case MENU_KEY_NEXT: // next/back
			{
				if (WPN_STARTID+7 < WPN_MAXIDS)
					WPN_STARTID += 7
				else
					WPN_STARTID = 0
			}
			case MENU_KEY_EXIT: // exit
			{
				return PLUGIN_HANDLED;
			}
		}
		
		// Show buy menu again
		show_menu_buy1(id)
		return PLUGIN_HANDLED;
	}
	
	// Store selected weapon id
	WPN_AUTO_PRI = WPN_SELECTION
	
	// Buy primary weapon
	buy_primary_weapon(id, WPN_AUTO_PRI)
	
	// Show pistols menu
	show_menu_buy2(id)
	
	return PLUGIN_HANDLED;
}

// Buy Primary Weapon
buy_primary_weapon(id, selection)
{
	// Drop previous weapons
	drop_weapons(id, 1)
	drop_weapons(id, 2)
	
	// Strip off from weapons
	fm_strip_user_weapons(id)
	fm_give_item(id, "weapon_knife")
	
	// Get weapon's id and name
	static weaponid, wname[32]
	weaponid = ArrayGetCell(g_primary_weaponids, selection)
	ArrayGetString(g_primary_items, selection, wname, charsmax(wname))
	
	// Give the new weapon and full ammo
	fm_give_item(id, wname)
	ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[weaponid], AMMOTYPE[weaponid], MAXBPAMMO[weaponid])
	
	// Weapons bought
	g_canbuy[id] = false
	
	// Give additional items
	static i
	for (i = 0; i < ArraySize(g_additional_items); i++)
	{
		ArrayGetString(g_additional_items, i, wname, charsmax(wname))
		fm_give_item(id, wname)
	}
}

// Buy Menu 2
public menu_buy2(id, key)
{	
	// Zombies, survivors or snipers get no guns
	if (!g_isalive[id] || g_zombie[id] || g_survivor[id] || g_sniper[id] || g_flamer[id] || g_zadoc[id])
		return PLUGIN_HANDLED;
	
	// Special keys / weapon list exceeded
	if (key >= ArraySize(g_secondary_items))
	{
		// Toggle autoselect
		if (key == MENU_KEY_AUTOSELECT)
			WPN_AUTO_ON = 1 - WPN_AUTO_ON
		
		// Reshow menu unless user exited
		if (key != MENU_KEY_EXIT)
			show_menu_buy2(id)
		
		return PLUGIN_HANDLED;
	}
	
	// Store selected weapon
	WPN_AUTO_SEC = key
	
	// Drop secondary gun again, in case we picked another (bugfix)
	drop_weapons(id, 2)
	
	// Get weapon's id
	static weaponid, wname[32]
	weaponid = ArrayGetCell(g_secondary_weaponids, key)
	ArrayGetString(g_secondary_items, key, wname, charsmax(wname))
	
	// Give the new weapon and full ammo
	fm_give_item(id, wname)
	ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[weaponid], AMMOTYPE[weaponid], MAXBPAMMO[weaponid])
	
	return PLUGIN_HANDLED;
}

// Extra Items Menu
public menu_extras(id, menuid, item)
{
	// Menu was closed
	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Dead players are not allowed to buy items
	if (!g_isalive[id])
	{
		zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Retrieve extra item id
	static buffer[2], dummy, itemid
	menu_item_getinfo(menuid, item, dummy, buffer, charsmax(buffer), _, _, dummy)
	itemid = buffer[0]
	
	// Attempt to buy the item
	buy_extra_item(id, itemid)
	menu_destroy(menuid)
	return PLUGIN_HANDLED;
}

// Buy Extra Item
buy_extra_item(id, itemid, ignorecost = 0, ignorerest = 0)
{
	// Retrieve item's team
	static team
	team = ArrayGetCell(g_extraitem_team, itemid)
	
	// Check for team/class specific items
	if ((g_zombie[id] && !native_get_zombie_hero(id) && (team != ZP_TEAM_ZOMBIE && team != ZP_TEAM_ANY)) || (!g_zombie[id] && !native_get_human_hero(id) && (team != ZP_TEAM_HUMAN && team != ZP_TEAM_ANY)) || (g_nemesis[id] && team != ZP_TEAM_NEMESIS)
	|| (g_survivor[id] && team != ZP_TEAM_SURVIVOR) || (g_sniper[id] && team != ZP_TEAM_SNIPER) || (g_assassin[id] && team != ZP_TEAM_ASSASSIN) || (g_oberon[id] && team != ZP_TEAM_OBERON) || (g_dragon[id] && team != ZP_TEAM_DRAGON) || (g_nighter[id] && team != ZP_TEAM_NIGHTER) || (g_flamer[id] && team != ZP_TEAM_FLAMER) || (g_zadoc[id] && team != ZP_TEAM_ZADOC) || (g_genesys[id] && team != ZP_TEAM_GENESYS))
	{
		zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
		return;
	}
	
	// Check for unavailable items
	if (itemid == EXTRA_NVISION && !zc_extra_nvision)
	{
		zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
		return;
	}
	else if (itemid == EXTRA_CNVISION && !zc_extra_cnvision)
	{
		zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
		return;
	}
	else if (itemid >= EXTRA_WEAPONS_STARTID && itemid <= EXTRAS_CUSTOM_STARTID-1 && !zc_extra_weapons)
	{
		zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
		return;
	}
	else if (itemid == EXTRA_INFBOMB && !zc_extra_infbomb)
	{
		zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
		return;
	}
	else if (itemid == EXTRA_MADNESS && !zc_extra_madness)
	{
		zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
		return;
	}
	else if (itemid == EXTRA_ANTIDOTE && !zc_extra_antidote)
	{
		zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
		return;
	}
	
	// Check for hard coded items with special conditions
	if ((itemid == EXTRA_ANTIDOTE && (g_endround || g_swarmround || g_nemround || g_assassinround || g_oberonround || g_dragonround || g_nighterround && !g_nchild[id] || g_survround || g_plagueround || g_sniperround || g_flamerround || g_zadocround || g_genesysround || g_lnjround || g_guardiansround || fnGetZombies() <= 1 || (zc_deathmatch && !zc_respawn_after_last_human && fnGetHumans() == 1)))
	|| (itemid == EXTRA_MADNESS && g_nodamage[id]) || (itemid == EXTRA_INFBOMB && (g_endround || g_swarmround || g_nemround || g_survround || g_plagueround || g_assassinround || g_oberonround || g_dragonround || g_nighterround || g_genesysround || g_sniperround || g_flamerround || g_zadocround || g_lnjround || g_guardiansround)))
	{
		zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_CANTUSE")
		return;
	}
	
	// Ignore item's cost?
	if (!ignorecost)
	{
		// Check that we have enough ammo packs
		if (g_ammopacks[id] < ArrayGetCell(g_extraitem_cost, itemid))
		{
			zp_colored_print(id, "^x04[ZC]^x01 %L", id, "NOT_ENOUGH_AMMO")
			return;
		}
		
		// Deduce item cost
		g_ammopacks[id] -= ArrayGetCell(g_extraitem_cost, itemid)
	}
	
	// Check which kind of item we're buying
	switch (itemid)
	{
		case EXTRA_NVISION: // Night Vision
		{
			// Remove custom NV
			g_hascnvision[id] = false
			remove_task(id+TASK_CNVISION)

			// Get
			g_hadnvision[id] = true
			set_user_nightvision(id, 1)
		}
		case EXTRA_CNVISION: // Night Vision
		{
			// Remove default NV
			g_hadnvision[id] = false
			set_user_nightvision(id, 0)

			// Get
			g_hascnvision[id] = true
			set_task(0.1, "set_user_nv", id+TASK_CNVISION, _, _, "b")
			activate_nv[id] = true
		}
		case EXTRA_ANTIDOTE: // Antidote
		{
			switch(ArrayGetCell(g_extraitem_resttype, itemid))
			{
				case REST_NONE:
				{
					// Item selected forward
					ExecuteForward(g_fwExtraItemSelected, g_fwDummyResult, id, itemid);
				
					// Item purchase blocked, restore buyer's ammo packs
					if (g_fwDummyResult >= ZP_PLUGIN_HANDLED && !ignorecost)
					{
						g_ammopacks[id] += ArrayGetCell(g_extraitem_cost, itemid)
					}
				}
				case REST_ROUND:
				{
					// Check limit
					new limit, data[32], itemname[32], rest_limit
					rest_limit = ArrayGetCell(g_extraitem_restlimit, itemid)
					ArrayGetString(g_extraitem_name, itemid, itemname, charsmax(itemname))
					if(limiter_get_data(g_limiter_round, itemname, g_playername[id], data, 15))
					{
						limit = str_to_num(data)
					}

					if (limit < rest_limit)
					{
						// Item selected forward
						ExecuteForward(g_fwExtraItemSelected, g_fwDummyResult, id, itemid);
				
						// Item purchase blocked, restore buyer's ammo packs
						if (g_fwDummyResult >= ZP_PLUGIN_HANDLED && !ignorecost)
						{
							g_ammopacks[id] += ArrayGetCell(g_extraitem_cost, itemid)
						}
						else 
						{
							ArraySetCell(g_extraitem_limit, itemid, (limit+1))
							new save[16]
							num_to_str(ArrayGetCell(g_extraitem_limit, itemid), save, sizeof(save) - 1)
    							limiter_set_data(g_limiter_round, itemname, g_playername[id], save)
						}		
					}
					else
					{
						g_ammopacks[id] += ArrayGetCell(g_extraitem_cost, itemid)
						zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this round!")
						return;
					}
				}
				case REST_MAP:
				{
					// Check limit
					new limit, data[32], itemname[32], rest_limit
					rest_limit = ArrayGetCell(g_extraitem_restlimit, itemid)
					ArrayGetString(g_extraitem_name, itemid, itemname, charsmax(itemname))
					if(limiter_get_data(g_limiter_map, itemname, g_playername[id], data, 15))
					{
						limit = str_to_num(data)
					}

					if (limit < rest_limit)
					{
						// Item selected forward
						ExecuteForward(g_fwExtraItemSelected, g_fwDummyResult, id, itemid);
				
						// Item purchase blocked, restore buyer's ammo packs
						if (g_fwDummyResult >= ZP_PLUGIN_HANDLED && !ignorecost)
						{
							g_ammopacks[id] += ArrayGetCell(g_extraitem_cost, itemid)
						}
						else 
						{
							ArraySetCell(g_extraitem_limit, itemid, (limit+1))
							new save[16]
							num_to_str(ArrayGetCell(g_extraitem_limit, itemid), save, sizeof(save) - 1)
    							limiter_set_data(g_limiter_map, itemname, g_playername[id], save)
						}		
					}
					else
					{
						g_ammopacks[id] += ArrayGetCell(g_extraitem_cost, itemid)
						zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
						return;
					}
				}
			}

			// Execute
			humanme(id, 0, 0, 0, 0, 0, 0)
		}
		case EXTRA_MADNESS: // Zombie Madness
		{
			switch(ArrayGetCell(g_extraitem_resttype, itemid))
			{
				case REST_NONE:
				{
					// Item selected forward
					ExecuteForward(g_fwExtraItemSelected, g_fwDummyResult, id, itemid);
				
					// Item purchase blocked, restore buyer's ammo packs
					if (g_fwDummyResult >= ZP_PLUGIN_HANDLED && !ignorecost)
					{
						g_ammopacks[id] += ArrayGetCell(g_extraitem_cost, itemid)
					}
				}
				case REST_ROUND:
				{
					// Check limit
					new limit, data[32], itemname[32], rest_limit
					rest_limit = ArrayGetCell(g_extraitem_restlimit, itemid)
					ArrayGetString(g_extraitem_name, itemid, itemname, charsmax(itemname))
					if(limiter_get_data(g_limiter_round, itemname, g_playername[id], data, 15))
					{
						limit = str_to_num(data)
					}

					if (limit < rest_limit)
					{
						// Item selected forward
						ExecuteForward(g_fwExtraItemSelected, g_fwDummyResult, id, itemid);
				
						// Item purchase blocked, restore buyer's ammo packs
						if (g_fwDummyResult >= ZP_PLUGIN_HANDLED && !ignorecost)
						{
							g_ammopacks[id] += ArrayGetCell(g_extraitem_cost, itemid)
						}
						else 
						{
							ArraySetCell(g_extraitem_limit, itemid, (limit+1))
							new save[16]
							num_to_str(ArrayGetCell(g_extraitem_limit, itemid), save, sizeof(save) - 1)
    							limiter_set_data(g_limiter_round, itemname, g_playername[id], save)
						}		
					}
					else
					{
						g_ammopacks[id] += ArrayGetCell(g_extraitem_cost, itemid)
						zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this round!")
						return;
					}
				}
				case REST_MAP:
				{
					// Check limit
					new limit, data[32], itemname[32], rest_limit
					rest_limit = ArrayGetCell(g_extraitem_restlimit, itemid)
					ArrayGetString(g_extraitem_name, itemid, itemname, charsmax(itemname))
					if(limiter_get_data(g_limiter_map, itemname, g_playername[id], data, 15))
					{
						limit = str_to_num(data)
					}

					if (limit < rest_limit)
					{
						// Item selected forward
						ExecuteForward(g_fwExtraItemSelected, g_fwDummyResult, id, itemid);
				
						// Item purchase blocked, restore buyer's ammo packs
						if (g_fwDummyResult >= ZP_PLUGIN_HANDLED && !ignorecost)
						{
							g_ammopacks[id] += ArrayGetCell(g_extraitem_cost, itemid)
						}
						else 
						{
							ArraySetCell(g_extraitem_limit, itemid, (limit+1))
							new save[16]
							num_to_str(ArrayGetCell(g_extraitem_limit, itemid), save, sizeof(save) - 1)
    							limiter_set_data(g_limiter_map, itemname, g_playername[id], save)
						}		
					}
					else
					{
						g_ammopacks[id] += ArrayGetCell(g_extraitem_cost, itemid)
						zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
						return;
					}
				}
			}

			// Execute
			g_nodamage[id] = true
			set_task(0.1, "zombie_aura", id+TASK_AURA, _, _, "b")
			set_task(1.0+zc_extra_madness_duration, "madness_over", id+TASK_BLOOD)
			static sound[64]
			ArrayGetString(zombie_madness, random_num(0, ArraySize(zombie_madness) - 1), sound, charsmax(sound))
			emit_sound(id, CHAN_VOICE, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		case EXTRA_INFBOMB: // Infection Bomb
		{
			switch(ArrayGetCell(g_extraitem_resttype, itemid))
			{
				case REST_NONE:
				{
					// Item selected forward
					ExecuteForward(g_fwExtraItemSelected, g_fwDummyResult, id, itemid);
				
					// Item purchase blocked, restore buyer's ammo packs
					if (g_fwDummyResult >= ZP_PLUGIN_HANDLED && !ignorecost)
					{
						g_ammopacks[id] += ArrayGetCell(g_extraitem_cost, itemid)
					}
				}
				case REST_ROUND:
				{
					// Check limit
					new limit, data[32], itemname[32], rest_limit
					rest_limit = ArrayGetCell(g_extraitem_restlimit, itemid)
					ArrayGetString(g_extraitem_name, itemid, itemname, charsmax(itemname))
					if(limiter_get_data(g_limiter_round, itemname, g_playername[id], data, 15))
					{
						limit = str_to_num(data)
					}

					if (limit < rest_limit)
					{
						// Item selected forward
						ExecuteForward(g_fwExtraItemSelected, g_fwDummyResult, id, itemid);
				
						// Item purchase blocked, restore buyer's ammo packs
						if (g_fwDummyResult >= ZP_PLUGIN_HANDLED && !ignorecost)
						{
							g_ammopacks[id] += ArrayGetCell(g_extraitem_cost, itemid)
						}
						else 
						{
							ArraySetCell(g_extraitem_limit, itemid, (limit+1))
							new save[16]
							num_to_str(ArrayGetCell(g_extraitem_limit, itemid), save, sizeof(save) - 1)
    							limiter_set_data(g_limiter_round, itemname, g_playername[id], save)
						}		
					}
					else
					{
						g_ammopacks[id] += ArrayGetCell(g_extraitem_cost, itemid)
						zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this round!")
						return;
					}
				}
				case REST_MAP:
				{
					// Check limit
					new limit, data[32], itemname[32], rest_limit
					rest_limit = ArrayGetCell(g_extraitem_restlimit, itemid)
					ArrayGetString(g_extraitem_name, itemid, itemname, charsmax(itemname))
					if(limiter_get_data(g_limiter_map, itemname, g_playername[id], data, 15))
					{
						limit = str_to_num(data)
					}

					if (limit < rest_limit)
					{
						// Item selected forward
						ExecuteForward(g_fwExtraItemSelected, g_fwDummyResult, id, itemid);
				
						// Item purchase blocked, restore buyer's ammo packs
						if (g_fwDummyResult >= ZP_PLUGIN_HANDLED && !ignorecost)
						{
							g_ammopacks[id] += ArrayGetCell(g_extraitem_cost, itemid)
						}
						else 
						{
							ArraySetCell(g_extraitem_limit, itemid, (limit+1))
							new save[16]
							num_to_str(ArrayGetCell(g_extraitem_limit, itemid), save, sizeof(save) - 1)
    							limiter_set_data(g_limiter_map, itemname, g_playername[id], save)
						}		
					}
					else
					{
						g_ammopacks[id] += ArrayGetCell(g_extraitem_cost, itemid)
						zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
						return;
					}
				}
			}

			// Execute
			// Already own one
			if (user_has_weapon(id, CSW_HEGRENADE))
			{
				// Increase BP ammo on it instead
				cs_set_user_bpammo(id, CSW_HEGRENADE, cs_get_user_bpammo(id, CSW_HEGRENADE) + 1)
				
				// Flash ammo in hud
				message_begin(MSG_ONE_UNRELIABLE, g_msgAmmoPickup, _, id)
				write_byte(AMMOID[CSW_HEGRENADE]) // ammo id
				write_byte(1) // ammo amount
				message_end()
				
				// Play clip purchase sound
				emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
				
				return; // stop here
			}
			
			// Give weapon to the player
			fm_give_item(id, "weapon_hegrenade")
		}
		default:
		{
			if (itemid >= EXTRA_WEAPONS_STARTID && itemid <= EXTRAS_CUSTOM_STARTID-1) // Weapons
			{
				// Get weapon's id and name
				static weaponid, wname[32]
				ArrayGetString(g_extraweapon_items, itemid - EXTRA_WEAPONS_STARTID, wname, charsmax(wname))
				weaponid = cs_weapon_name_to_id(wname)
				
				// If we are giving a primary/secondary weapon
				if (MAXBPAMMO[weaponid] > 2)
				{
					// Make user drop the previous one
					if ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM)
						drop_weapons(id, 1)
					else
						drop_weapons(id, 2)
					
					// Give full BP ammo for the new one
					ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[weaponid], AMMOTYPE[weaponid], MAXBPAMMO[weaponid])
				}
				// If we are giving a grenade which the user already owns
				else if (user_has_weapon(id, weaponid))
				{
					// Increase BP ammo on it instead
					cs_set_user_bpammo(id, weaponid, cs_get_user_bpammo(id, weaponid) + 1)
					
					// Flash ammo in hud
					message_begin(MSG_ONE_UNRELIABLE, g_msgAmmoPickup, _, id)
					write_byte(AMMOID[weaponid]) // ammo id
					write_byte(1) // ammo amount
					message_end()
					
					// Play clip purchase sound
					emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
					
					return; // stop here
				}
				
				// Give weapon to the player
				fm_give_item(id, wname)
			}
			else // Custom additions
			{
				if (ignorerest)
				{
					// Item selected forward
					ExecuteForward(g_fwExtraItemSelected, g_fwDummyResult, id, itemid);
				
					// Item purchase blocked, restore buyer's ammo packs
					if (g_fwDummyResult >= ZP_PLUGIN_HANDLED && !ignorecost)
					{
						g_ammopacks[id] += ArrayGetCell(g_extraitem_cost, itemid)
					}
				}
				else
				{
					switch(ArrayGetCell(g_extraitem_resttype, itemid))
					{
						case REST_NONE:
						{
							// Item selected forward
							ExecuteForward(g_fwExtraItemSelected, g_fwDummyResult, id, itemid);
				
							// Item purchase blocked, restore buyer's ammo packs
							if (g_fwDummyResult >= ZP_PLUGIN_HANDLED && !ignorecost)
							{
								g_ammopacks[id] += ArrayGetCell(g_extraitem_cost, itemid)
							}
						}
						case REST_ROUND:
						{
							// Check limit
							new limit, data[32], itemname[32], rest_limit
							rest_limit = ArrayGetCell(g_extraitem_restlimit, itemid)
							ArrayGetString(g_extraitem_name, itemid, itemname, charsmax(itemname))
							if(limiter_get_data(g_limiter_round, itemname, g_playername[id], data, 15))
							{
								limit = str_to_num(data)
							}

							if (limit < rest_limit)
							{
								// Item selected forward
								ExecuteForward(g_fwExtraItemSelected, g_fwDummyResult, id, itemid);
				
								// Item purchase blocked, restore buyer's ammo packs
								if (g_fwDummyResult >= ZP_PLUGIN_HANDLED && !ignorecost)
								{
									g_ammopacks[id] += ArrayGetCell(g_extraitem_cost, itemid)
								}
								else 
								{
									ArraySetCell(g_extraitem_limit, itemid, (limit+1))
									new save[16]
									num_to_str(ArrayGetCell(g_extraitem_limit, itemid), save, sizeof(save) - 1)
    									limiter_set_data(g_limiter_round, itemname, g_playername[id], save)
								}		
							}
							else
							{
								g_ammopacks[id] += ArrayGetCell(g_extraitem_cost, itemid)
								zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this round!")
								return;
							}
						}
						case REST_MAP:
						{
							// Check limit
							new limit, data[32], itemname[32], rest_limit
							rest_limit = ArrayGetCell(g_extraitem_restlimit, itemid)
							ArrayGetString(g_extraitem_name, itemid, itemname, charsmax(itemname))
							if(limiter_get_data(g_limiter_map, itemname, g_playername[id], data, 15))
							{
								limit = str_to_num(data)
							}

							if (limit < rest_limit)
							{
								// Item selected forward
								ExecuteForward(g_fwExtraItemSelected, g_fwDummyResult, id, itemid);
				
								// Item purchase blocked, restore buyer's ammo packs
								if (g_fwDummyResult >= ZP_PLUGIN_HANDLED && !ignorecost)
								{
									g_ammopacks[id] += ArrayGetCell(g_extraitem_cost, itemid)
								}
								else 
								{
									ArraySetCell(g_extraitem_limit, itemid, (limit+1))
									new save[16]
									num_to_str(ArrayGetCell(g_extraitem_limit, itemid), save, sizeof(save) - 1)
    									limiter_set_data(g_limiter_map, itemname, g_playername[id], save)
								}		
							}
							else
							{
								g_ammopacks[id] += ArrayGetCell(g_extraitem_cost, itemid)
								zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
								return;
							}
						}
					}
				}
			}
		}
	}
	client_cmd(id, "spk %s", BGH_S)
	
}

// Zombie Class Menu
public menu_zclass(id, menuid, item)
{
	// Menu was closed
	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Retrieve zombie class id
	static buffer[2], dummy, classid
	menu_item_getinfo(menuid, item, dummy, buffer, charsmax(buffer), _, _, dummy)
	classid = buffer[0]

	// Store selection for the next infection
	if(ArrayGetCell(g_zclass_level, classid) <= g_level[id]) {
		if(g_zombieclassnext[id] == classid) {
			zp_colored_print(id, "^x04[ZC]^x01 It's already your^x04 selection^x01. Chose another^x04 class.")
			return PLUGIN_HANDLED
		}else {
			g_zombieclassnext[id] = classid
			
		}
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 Your^x04 level^x01 doesn't corespond with this^x04 class.")
		return PLUGIN_HANDLED
	}
	
	static name[32]
	ArrayGetString(g_zclass_name, g_zombieclassnext[id], name, charsmax(name))
	
	// Show selected zombie class info and stats
	zp_colored_print(id, "^x04[ZC]^x01 %L:^x04 %s", id, "ZOMBIE_SELECT", name)
	zp_colored_print(id, "^x04[ZC]^x01 %L:^x04 %d^x01 |^x01 %L^x01:^x04 %d^x01 |^x01 %L^x01:^x04 %d^x01 |^x01 %L^x01:^x04 %d%%", id, "ZOMBIE_ATTRIB1", ArrayGetCell(g_zclass_hp, g_zombieclassnext[id]), id, "ZOMBIE_ATTRIB2", ArrayGetCell(g_zclass_spd, g_zombieclassnext[id]),
	id, "ZOMBIE_ATTRIB3", floatround(Float:ArrayGetCell(g_zclass_grav, g_zombieclassnext[id]) * 800.0), id, "ZOMBIE_ATTRIB4", floatround(Float:ArrayGetCell(g_zclass_kb, g_zombieclassnext[id]) * 100.0))
	
	menu_destroy(menuid)
	return PLUGIN_HANDLED;
}

// Human Class Menu
public menu_hclass(id, menuid, item)
{
	// Menu was closed
	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Retrieve human class id
	static buffer[2], dummy, classid
	menu_item_getinfo(menuid, item, dummy, buffer, charsmax(buffer), _, _, dummy)
	classid = buffer[0]

	// Store selection for the next disinfection
	if(ArrayGetCell(g_hclass_level, classid) <= g_level[id]) {
		if(g_humanclassnext[id] == classid) {
			zp_colored_print(id, "^x04[ZC]^x01 It's already your^x04 selection^x01. Chose another^x04 class.")
			return PLUGIN_HANDLED
		}else {
			g_humanclassnext[id] = classid
			
		}
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 Your^x04 level^x01 doesn't corespond with this^x04 class.")
		return PLUGIN_HANDLED
	}
	
	static name[32]
	ArrayGetString(g_hclass_name, g_humanclassnext[id], name, charsmax(name))
	
	// Show selected zombie class info and stats
	zp_colored_print(id, "^x04[ZC]^x01 %L:^x04 %s", id, "HUMAN_SELECT", name)
	zp_colored_print(id, "^x04[ZC]^x01 %L:^x04 %d^x01 | %L:^x04 %d^x01 | %L:^x04 %d", id, "HUMAN_ATTRIB1", ArrayGetCell(g_hclass_hp, g_humanclassnext[id]), id, "HUMAN_ATTRIB2", ArrayGetCell(g_hclass_spd, g_humanclassnext[id]),
	id, "HUMAN_ATTRIB3", floatround(Float:ArrayGetCell(g_hclass_grav, g_humanclassnext[id]) * 800.0))
	
	menu_destroy(menuid)
	return PLUGIN_HANDLED;
}

// Admin Menu
public menu_admin(id, menu, item)
{
	static userflags
	userflags = g_privileges[id]
	
	switch(item)
	{
		case 0: // Zombiefy/Humanize command
		{
			if (userflags & (g_access_flag[ACCESS_MODE_INFECTION] | g_access_flag[ACCESS_MAKE_ZOMBIE] | g_access_flag[ACCESS_MAKE_HUMAN]))
			{
				// Show player list for admin to pick a target
				PL_ACTION = 0
				show_menu_player_list(id)
			}
			else
			{
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
				show_menu_admin(id)
			}
		}
		case 1: // Nemesis command
		{
			if (userflags & (g_access_flag[ACCESS_MODE_NEMESIS] | g_access_flag[ACCESS_MAKE_NEMESIS]))
			{
				// Show player list for admin to pick a target
				PL_ACTION = 1
				show_menu_player_list(id)
			}
			else
			{
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
				show_menu_admin(id)
			}
		}
		case 2: // Survivor command
		{
			if (userflags & (g_access_flag[ACCESS_MODE_SURVIVOR] | g_access_flag[ACCESS_MAKE_SURVIVOR]))
			{
				// Show player list for admin to pick a target
				PL_ACTION = 2
				show_menu_player_list(id)
			}
			else
			{
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
				show_menu_admin(id)
			}
		}
		case 3: // Sniper command
		{
			if (userflags & (g_access_flag[ACCESS_MODE_SNIPER] | g_access_flag[ACCESS_MAKE_SNIPER]))
			{
				// Show player list for admin to pick a target
				PL_ACTION = 3
				show_menu_player_list(id)
			}
			else
			{
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
				show_menu_admin(id)
			}
		}
		case 4: // Assassin command
		{
			if (userflags & (g_access_flag[ACCESS_MODE_ASSASSIN] | g_access_flag[ACCESS_MAKE_ASSASSIN]))
			{
				// Show player list for admin to pick a target
				PL_ACTION = 4
				show_menu_player_list(id)
			}
			else
			{
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
				show_menu_admin(id)
			}
		}
		case 5: // Flamer command
		{
			if (userflags & (g_access_flag[ACCESS_MODE_FLAMER] | g_access_flag[ACCESS_MAKE_FLAMER]))
			{
				PL_ACTION = 5
				show_menu_player_list(id)
			}
			else
			{
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
				show_menu_admin(id)
			}
		}
		case 6: // Genesys command
		{
			if (userflags & (g_access_flag[ACCESS_MODE_GENESYS] | g_access_flag[ACCESS_MAKE_GENESYS]))
			{
				PL_ACTION = 6
				show_menu_player_list(id)
			}
			else
			{
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
				show_menu_admin(id)
			}
		}
		case 7: // Oberon command
		{
			if (userflags & (g_access_flag[ACCESS_MODE_OBERON] | g_access_flag[ACCESS_MAKE_OBERON]))
			{
				// Show player list for admin to pick a target
				PL_ACTION = 7
				show_menu_player_list(id)
			}
			else
			{
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
				show_menu_admin(id)
			}
		}
		case 8: // Zadoc command
		{
			if (userflags & (g_access_flag[ACCESS_MODE_ZADOC] | g_access_flag[ACCESS_MAKE_ZADOC]))
			{
				PL_ACTION = 8
				show_menu_player_list(id)
			}
			else
			{
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
				show_menu_admin(id)
			}
		}
		case 9: // Dragon command
		{
			if (userflags & (g_access_flag[ACCESS_MODE_DRAGON] | g_access_flag[ACCESS_MAKE_DRAGON]))
			{
				// Show player list for admin to pick a target
				PL_ACTION = 9
				show_menu_player_list(id)
			}
			else
			{
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
				show_menu_admin(id)
			}
		}
		case 10: // Nighter command
		{
			if (userflags & (g_access_flag[ACCESS_MODE_NIGHTER] | g_access_flag[ACCESS_MAKE_NIGHTER]))
			{
				// Show player list for admin to pick a target
				PL_ACTION = 10
				show_menu_player_list(id)
			}
			else
			{
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
				show_menu_admin(id)
			}
		}
		case 11: // Respawn command
		{
			if (userflags & g_access_flag[ACCESS_RESPAWN_PLAYERS])
			{
				// Show player list for admin to pick a target
				PL_ACTION = 11
				show_menu_player_list(id)
			}
			else
			{
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
				show_menu_admin(id)
			}
		}
	}
	menu_destroy(menu)
    	return PLUGIN_HANDLED
}

public menu2_admin(id, key)
{
	static userflags
	userflags = g_privileges[id]
	
	switch (key)
	{
		case 0: // Multiple Infection command
		{
			if (userflags & g_access_flag[ACCESS_MODE_MULTI])
			{
				if (allowed_multi())
					command_multi(id)
				else
					zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
			}
			else
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			
			show_menu2_admin(id)
		}
		case 1: // Swarm Mode command
		{
			if (userflags & g_access_flag[ACCESS_MODE_SWARM])
			{
				if (allowed_swarm())
					command_swarm(id)
				else
					zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
			}
			else
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			
			show_menu2_admin(id)
		}
		case 2: // Plague Mode command
		{
			if (userflags & g_access_flag[ACCESS_MODE_PLAGUE])
			{
				if (allowed_plague())
					command_plague(id)
				else
					zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
			}
			else
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			
			show_menu2_admin(id)
		}
		case 3: // LNJ Mode command
		{
			if (userflags & g_access_flag[ACCESS_MODE_LNJ])
			{
				if (allowed_lnj())
					command_lnj(id)
				else
					zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
			}
			else
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			
			show_menu2_admin(id)
		}
		case 4: // Guardians Mode command
		{
			if (userflags & g_access_flag[ACCESS_MODE_GUARDIANS])
			{
				if (allowed_guardians())
					command_guardians(id)
				else
					zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
			}
			else
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			
			show_menu2_admin(id)
		}
		case 9: // Chose to return
		{
			show_menu3_admin(id)
		}
	}
	return PLUGIN_HANDLED;
}

public menu3_admin(id, key)
{
	switch (key)
	{
		case 0: // Admin Menu
		{
			// Check if player has the required access
			if (g_privileges[id] & g_access_flag[ACCESS_ADMIN_MENU])
			{
				if(g_mused[id] == 0 || (get_user_flags(id) & ADMIN_RCON))
				{
					if(!g_event || (get_user_flags(id) & ADMIN_RCON))
					{
						show_menu_admin(id)
						if(g_blockannounce)
						{
							zp_colored_print(id, "^x04[ZC]^x01 A mode is already^x04 announced^x01 by someone. We reccomend you^x04 not to start^x01 a mode for the moment.")
						}
					}else {
						zp_colored_print(id, "^x04[ZC]^x01 The event is^x04 ON^x01. You can use this menu next map, when the event will be^x03 OFF.")
					}
	
				}else {	
					zp_colored_print(id, "^x04[ZC]^x01 You've already used^x04 adminmenu^x01 this map, please try again next map^x04 [1/map]^x01.")
					return PLUGIN_HANDLED;
				}
	
			}else {
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			}
		}
		case 1: // Admin Menu Class
		{
			// Check if player has the required access
			if (g_privileges[id] & g_access_flag[ACCESS_ADMIN_MENU2])
			{
				if(g_mused[id] == 0 || (get_user_flags(id) & ADMIN_RCON))
				{
					if(!g_event || (get_user_flags(id) & ADMIN_RCON))
					{
						show_menu2_admin(id)
						if(g_blockannounce)
						{
							zp_colored_print(id, "^x04[ZC]^x01 A mode is already^x04 announced^x01 by someone. We reccomend you^x04 not to start^x01 a mode for the moment.")
						}
					}else {
						zp_colored_print(id, "^x04[ZC]^x01 The event is^x04 ON^x01. You can use this menu next map, when the event will be^x03 OFF.")
					}
	
				}else {	
					zp_colored_print(id, "^x04[ZC]^x01 You've already used^x04 adminmenu^x01 this map, please try again next map^x04 [1/map]^x01.")
					return PLUGIN_HANDLED;
				}
	
			}else {
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			}
		}
		case 2: // Weapons menu
		{
			// Check if player has the required access
			if (!g_zombie[id] && is_user_alive(id) && !native_get_human_hero(id) && !native_get_zombie_hero(id) && ((g_privileges[id] & MODE_FLAG_U) || (g_privileges[id] & MODE_FLAG_V) || (g_privileges[id] & MODE_FLAG_W)))
				show_menu_weapons(id)
			else
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
		}
		case 3: // Event menu
		{
			// Check if player has the required access
			if (g_privileges[id] & MODE_FLAG_X)
				am_event(id)
			else
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
		}
		case 4: // Shut the mod
		{
			// Check if player has the required access
			if (g_privileges[id] & g_access_flag[ACCESS_ENABLE_MOD])
				show_menu4_admin(id)
			else
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
		}
	}
	return PLUGIN_HANDLED;
}

public menu4_admin(id, key)
{
	switch (key)
	{
		case 0: // Shut the mode
		{
			// Set the counter
			g_time = 5
			
			// Run the function
			shut_the_mode()
		}
		case 1: // Return
		{
			show_menu3_admin(id)
		}
	}
	return PLUGIN_HANDLED;
}

// Shut the mode function
public shut_the_mode()
{
	// If the counter has reached 0 or below shut the Mod
	if(g_time <= 0)
	{		
		// Shut the Mod
		server_cmd("zp_toggle 0")
		
		// Stop here
		return;
	}
	
	// Send the notice to all players
	set_hudmessage(250, 10, 10, -1.0, -1.0, 1, 0.0, 5.0, 1.0, 1.0, -1)
	ShowSyncHudMsg(0, g_MsgSync3, "%L", LANG_PLAYER,"NOTICE_SHUT_DOWN", g_time)
	
	// Substract 1 from the variable
	g_time--
	
	// Repeat
	set_task(1.0, "shut_the_mode")
	
}

// Event Manager
public am_event(id)
{
	show_menu(id, 0, "\n", 1)
	new menu = menu_create("\rControl Board \w- \rEvents:", "menu_handler_ame")
	new szmenu[555]

	if(g_privileges[id] & MODE_FLAG_X) formatex(szmenu, 63, "\wModes Event \r| \wStatus: \y%s", g_event ? "ON" : "OFF")
	else formatex(szmenu, 63,"\dModes Event")
	menu_additem(menu, szmenu)

	if(g_privileges[id] & MODE_FLAG_X) formatex(szmenu, 63,"\wVIP Event \r| \wStatus: \y%s", g_vevcommand ? "ON" : "OFF")
	else formatex(szmenu, 63,"\dVIP Event")
	menu_additem(menu, szmenu)

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
}
 
public menu_handler_ame(id, menu, item)
{
	switch(item)	
	{
		case 0:
		{
			if(g_privileges[id] & MODE_FLAG_X)
				am_modesevent(id)
			else
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
		}
		case 1:
		{
			if(g_privileges[id] & MODE_FLAG_X)
			{
				if(g_vevcommand)
				{
					StartVIPEvent(id, 0)	
					set_task(0.1, "am_event", id)
				}else {
					StartVIPEvent(id, 1)
					set_task(0.1, "am_event", id)
				}
			}else {
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			}
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public StartVIPEvent(id, on) 
{
	if(on == 1) 
	{
		zp_colored_print(0, "^x04[ZC]^x01 The^x04 VIP-Event^x01 has been^x03 started^x01. Enjoy of it.")
		log_to_file("zc_event.log", "[START VIP EVENT] --- [%s]", g_playername[id]);
		event_start = 1
		g_vevcommand = true
		for(new i = 1; i <= g_maxplayers; i++) 
		{
			if(!(g_user_privileges[i] & FLAG_D))
			{
				new fflags[10]
				get_pcvar_string(g_hour_flags, fflags, charsmax(fflags))
				g_user_privileges[i] = read_flags(fflags)
			}
		}
	}else if(on == 0) {
		log_to_file("zc_event.log", "[STOP VIP EVENT] --- [%s]", g_playername[id]);
		zp_colored_print(0, "^x04[ZC]^x01 The^x04 VIP-Event^x01 has been^x03 stopped^x01. Keep calm, we'll make another one^x04 later!")
		event_start = 0
		g_vevcommand = false
		for(new i = 1; i <= g_maxplayers; i++) 
		{
			if(!(g_user_privileges[i] & FLAG_D))
			{
				set_flags(i)
			}
		}
	} 
}

// Admin Menu - Modes Event 
public am_modesevent(id)
{
	show_menu(id, 0, "\n", 1)
	new menu = menu_create("\rControl Board \w- \rModes Events:", "menu_handler_ame_modes")
	new szmenu[555]

	formatex(szmenu, 63, "\w%s", g_event ? "Stop" : "Start")
	menu_additem(menu, szmenu)

	formatex(szmenu, 63,"\wNemesis")
	menu_additem(menu, szmenu)

	formatex(szmenu, 63,"\wAssassin")
	menu_additem(menu, szmenu)

	formatex(szmenu, 63,"\wOberon")
	menu_additem(menu, szmenu)

	formatex(szmenu, 63,"\wGenesys")
	menu_additem(menu, szmenu)

	formatex(szmenu, 63,"\wSurvivor")
	menu_additem(menu, szmenu)

	formatex(szmenu, 63,"\wSniper")
	menu_additem(menu, szmenu)

	formatex(szmenu, 63,"\wFlamer")
	menu_additem(menu, szmenu)

	formatex(szmenu, 63,"\wZadoc")
	menu_additem(menu, szmenu)

	formatex(szmenu, 63,"\wDragon")
	menu_additem(menu, szmenu)

	formatex(szmenu, 63,"\wNighter")
	menu_additem(menu, szmenu)

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
}
 
public menu_handler_ame_modes(id, menu, item)
{
	switch(item)	
	{
		case 0:
		{
			if(g_event)
			{
				StartEvent(id, 0)	
				set_task(0.1, "am_modesevent", id)
				am_modesevent(id)
			}else {
				StartEvent(id, 1)
				set_task(0.1, "am_modesevent", id)
			}
		}
		case 1:
		{
			EventNemesis(id)
		}
		case 2:
		{
			EventAssassin(id)
		}
		case 3:
		{
			EventOberon(id)
		}
		case 4:
		{
			EventGenesys(id)
		}
		case 5:
		{
			EventSurvivor(id)
		}
		case 6:
		{
			EventSniper(id)
		}
		case 7:
		{
			EventFlamer(id)
		}
		case 8:
		{
			EventZadoc(id)
		}
		case 9:
		{
			EventDragon(id)
		}
		case 10:
		{
			EventNighter(id)
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public StartEvent(id, on) 
{ 
	if(on == 1)  
	{
		g_event = true
		zp_colored_print(0, "^x04[ZC]^x01 The^x04 Mode-Event^x01 has been^x03 started^x01. Enjoy of it, and be attentive, you can^x04 become^x01 a^x03 mode!")
		log_to_file("zc_event.log", "[START MAIN EVENT] --- [%s]", g_playername[id]);

		// Remove announces
		for(new i = 1; i <= g_maxplayers; i++)
		{
			if(g_announce_valid[i])
			{
				zp_colored_print(0, "^x04[ZC]^x01 All^x04 announcements^x01 were removed!")
				set_task(3.0, "removeannounce", i)
			}
		}
	}else if(on == 0) {
		log_to_file("zc_event.log", "[STOP MAIN EVENT] --- [%s]", g_playername[id]);
		g_event = false
		zp_colored_print(0, "^x04[ZC]^x01 The^x04 Mode-Event^x01 has been^x03 stopped^x01. Keep calm, we'll make another one^x04 later!")
	}
    	return PLUGIN_HANDLED; 
}

public EventNemesis(id)
{
	if (!g_event)
	{
		zp_colored_print(id, "^x04[ZC]^x01 The^x04 Mode-Event^x01 isn't^x03 started.")	
		return PLUGIN_HANDLED;
	}

	if (native_has_round_started())
	{
		zp_colored_print(id, "^x04[ZC]^x01 The^x04 Mode-Event^x01 can be used only on^x04 roundstart.")
		return PLUGIN_HANDLED;
	}
    
	static players[32], iPnum;
	static player;
	get_players(players, iPnum);
	player = players[random(iPnum)];
	if(!player)
	{
		console_print(id, "[ZC] Random player not found.");
		return PLUGIN_HANDLED;
	}

	// Give mode
	if (!allowed_nemesis(player) || player == id)
	{
		client_print(id, print_console, "[ZC] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	// Set message and mode
	zp_colored_print(0, "^x04[ZC]^x01 Yeah ...^x03 %s^x01 was randomly chosed to become^x04 Nemesis", g_playername[player])
	log_to_file("zc_event.log", "[MAIN EVENT : NEMESIS] --- [%s]", g_playername[id]);
	command_nemesis(id, player, 1)

	return PLUGIN_CONTINUE;
}

public EventAssassin(id)
{
	if (!g_event)
	{
		zp_colored_print(id, "^x04[ZC]^x01 The^x04 Mode-Event^x01 isn't^x03 started.")		
		return PLUGIN_HANDLED;
	}

	if (native_has_round_started())
	{
		zp_colored_print(id, "^x04[ZC]^x01 The^x04 Mode-Event^x01 can be used only on^x04 roundstart.")
		return PLUGIN_HANDLED;
	}
    
	static players[32], iPnum;
	static player;
	get_players(players, iPnum);
	player = players[random(iPnum)];
	if(!player)
	{
		console_print(id, "[ZC] Random player not found.");
		return PLUGIN_HANDLED;
	}

	// Give mode
	if (!allowed_assassin(player) || player == id)
	{
		client_print(id, print_console, "[ZC] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	// Set message and mode
	zp_colored_print(0, "^x04[ZC]^x01 Yeah ...^x03 %s^x01 was randomly chosed to become^x04 Assassin", g_playername[player])
	log_to_file("zc_event.log", "[MAIN EVENT : ASSASSIN] --- [%s]", g_playername[id]);
	command_assassin(id, player, 1)

	return PLUGIN_CONTINUE;
}

public EventOberon(id)
{
	if (!g_event)
	{
		zp_colored_print(id, "^x04[ZC]^x01 The^x04 Mode-Event^x01 isn't^x03 started.")		
		return PLUGIN_HANDLED;
	}

	if (native_has_round_started())
	{
		zp_colored_print(id, "^x04[ZC]^x01 The^x04 Mode-Event^x01 can be used only on^x04 roundstart.")
		return PLUGIN_HANDLED;
	}
    
	static players[32], iPnum;
	static player;
	get_players(players, iPnum);
	player = players[random(iPnum)];
	if(!player)
	{
		console_print(id, "[ZC] Random player not found.");
		return PLUGIN_HANDLED;
	}

	// Give mode
	if (!allowed_oberon(player) || player == id)
	{
		client_print(id, print_console, "[ZC] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	// Set message and mode
	zp_colored_print(0, "^x04[ZC]^x01 Yeah ...^x03 %s^x01 was randomly chosed to become^x04 Oberon", g_playername[player])
	log_to_file("zc_event.log", "[MAIN EVENT : OBERON] --- [%s]", g_playername[id]);
	command_oberon(id, player, 1)

	return PLUGIN_CONTINUE;
}

public EventGenesys(id)
{
	if (!g_event)
	{
		zp_colored_print(id, "^x04[ZC]^x01 The^x04 Mode-Event^x01 isn't^x03 started.")		
		return PLUGIN_HANDLED;
	}

	if (native_has_round_started())
	{
		zp_colored_print(id, "^x04[ZC]^x01 The^x04 Mode-Event^x01 can be used only on^x04 roundstart.")
		return PLUGIN_HANDLED;
	}
    
	static players[32], iPnum;
	static player;
	get_players(players, iPnum);
	player = players[random(iPnum)];
	if(!player)
	{
		console_print(id, "[ZC] Random player not found.");
		return PLUGIN_HANDLED;
	}

	// Give mode
	if (!allowed_genesys(player) || player == id)
	{
		client_print(id, print_console, "[ZC] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	// Set message and mode
	zp_colored_print(0, "^x04[ZC]^x01 Yeah ...^x03 %s^x01 was randomly chosed to become^x04 Genesys", g_playername[player])
	log_to_file("zc_event.log", "[MAIN EVENT : GENESYS] --- [%s]", g_playername[id]);
	command_genesys(id, player, 1)

	return PLUGIN_CONTINUE;
}

public EventSurvivor(id)
{
	if (!g_event)
	{
		zp_colored_print(id, "^x04[ZC]^x01 The^x04 Mode-Event^x01 isn't^x03 started.")		
		return PLUGIN_HANDLED;
	}

	if (native_has_round_started())
	{
		zp_colored_print(id, "^x04[ZC]^x01 The^x04 Mode-Event^x01 can be used only on^x04 roundstart.")
		return PLUGIN_HANDLED;
	}
    
	static players[32], iPnum;
	static player;
	get_players(players, iPnum);
	player = players[random(iPnum)];
	if(!player)
	{
		console_print(id, "[ZC] Random player not found.");
		return PLUGIN_HANDLED;
	}

	// Give mode
	if (!allowed_survivor(player) || player == id)
	{
		client_print(id, print_console, "[ZC] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	// Set message and mode
	zp_colored_print(0, "^x04[ZC]^x01 Yeah ...^x03 %s^x01 was randomly chosed to become^x04 Survivor", g_playername[player])
	log_to_file("zc_event.log", "[MAIN EVENT : SURVIVOR] --- [%s]", g_playername[id]);
	command_survivor(id, player, 1)

	return PLUGIN_CONTINUE;
}

public EventSniper(id)
{
	if (!g_event)
	{
		zp_colored_print(id, "^x04[ZC]^x01 The^x04 Mode-Event^x01 isn't^x03 started.")		
		return PLUGIN_HANDLED;
	}

	if (native_has_round_started())
	{
		zp_colored_print(id, "^x04[ZC]^x01 The^x04 Mode-Event^x01 can be used only on^x04 roundstart.")
		return PLUGIN_HANDLED;
	}
    
	static players[32], iPnum;
	static player;
	get_players(players, iPnum);
	player = players[random(iPnum)];
	if(!player)
	{
		console_print(id, "[ZC] Random player not found.");
		return PLUGIN_HANDLED;
	}

	// Give mode
	if (!allowed_sniper(player) || player == id)
	{
		client_print(id, print_console, "[ZC] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	// Set message and mode
	zp_colored_print(0, "^x04[ZC]^x01 Yeah ...^x03 %s^x01 was randomly chosed to become^x04 Sniper", g_playername[player])
	log_to_file("zc_event.log", "[MAIN EVENT : SNIPER] --- [%s]", g_playername[id]);
	command_sniper(id, player, 1)

	return PLUGIN_CONTINUE;
}

public EventFlamer(id)
{
	if (!g_event)
	{
		zp_colored_print(id, "^x04[ZC]^x01 The^x04 Mode-Event^x01 isn't^x03 started.")		
		return PLUGIN_HANDLED;
	}

	if (native_has_round_started())
	{
		zp_colored_print(id, "^x04[ZC]^x01 The^x04 Mode-Event^x01 can be used only on^x04 roundstart.")
		return PLUGIN_HANDLED;
	}
    
	static players[32], iPnum;
	static player;
	get_players(players, iPnum);
	player = players[random(iPnum)];
	if(!player)
	{
		console_print(id, "[ZC] Random player not found.");
		return PLUGIN_HANDLED;
	}

	// Give mode
	if (!allowed_flamer(player) || player == id)
	{
		client_print(id, print_console, "[ZC] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	// Set message and mode
	zp_colored_print(0, "^x04[ZC]^x01 Yeah ...^x03 %s^x01 was randomly chosed to become^x04 Flamer", g_playername[player])
	log_to_file("zc_event.log", "[MAIN EVENT : FLAMER] --- [%s]", g_playername[id]);
	command_flamer(id, player, 1)

	return PLUGIN_CONTINUE;
}

public EventZadoc(id)
{
	if (!g_event)
	{
		zp_colored_print(id, "^x04[ZC]^x01 The^x04 Mode-Event^x01 isn't^x03 started.")		
		return PLUGIN_HANDLED;
	}

	if (native_has_round_started())
	{
		zp_colored_print(id, "^x04[ZC]^x01 The^x04 Mode-Event^x01 can be used only on^x04 roundstart.")
		return PLUGIN_HANDLED;
	}
    
	static players[32], iPnum;
	static player;
	get_players(players, iPnum);
	player = players[random(iPnum)];
	if(!player)
	{
		console_print(id, "[ZC] Random player not found.");
		return PLUGIN_HANDLED;
	}

	// Give mode
	if (!allowed_zadoc(player) || player == id)
	{
		client_print(id, print_console, "[ZC] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	// Set message and mode
	zp_colored_print(0, "^x04[ZC]^x01 Yeah ...^x03 %s^x01 was randomly chosed to become^x04 Zadoc", g_playername[player])
	log_to_file("zc_event.log", "[MAIN EVENT : ZADOC] --- [%s]", g_playername[id]);
	command_zadoc(id, player, 1)

	return PLUGIN_CONTINUE;
}

public EventDragon(id)
{
	if (!g_event)
	{
		zp_colored_print(id, "^x04[ZC]^x01 The^x04 Mode-Event^x01 isn't^x03 started.")		
		return PLUGIN_HANDLED;
	}

	if (native_has_round_started())
	{
		zp_colored_print(id, "^x04[ZC]^x01 The^x04 Mode-Event^x01 can be used only on^x04 roundstart.")
		return PLUGIN_HANDLED;
	}
    
	static players[32], iPnum;
	static player;
	get_players(players, iPnum);
	player = players[random(iPnum)];
	if(!player)
	{
		console_print(id, "[ZC] Random player not found.");
		return PLUGIN_HANDLED;
	}

	// Give mode
	if (!allowed_dragon(player) || player == id)
	{
		client_print(id, print_console, "[ZC] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	// Set message and mode
	zp_colored_print(0, "^x04[ZC]^x01 Yeah ...^x03 %s^x01 was randomly chosed to become^x04 Dragon", g_playername[player])
	log_to_file("zc_event.log", "[MAIN EVENT : DRAGON] --- [%s]", g_playername[id]);
	command_dragon(id, player, 1)

	return PLUGIN_CONTINUE;
}

public EventNighter(id)
{
	if (!g_event)
	{
		zp_colored_print(id, "^x04[ZC]^x01 The^x04 Mode-Event^x01 isn't^x03 started.")		
		return PLUGIN_HANDLED;
	}

	if (native_has_round_started())
	{
		zp_colored_print(id, "^x04[ZC]^x01 The^x04 Mode-Event^x01 can be used only on^x04 roundstart.")
		return PLUGIN_HANDLED;
	}
    
	static players[32], iPnum;
	static player;
	get_players(players, iPnum);
	player = players[random(iPnum)];
	if(!player)
	{
		console_print(id, "[ZC] Random player not found.");
		return PLUGIN_HANDLED;
	}

	// Give mode
	if (!allowed_nighter(player) || player == id)
	{
		client_print(id, print_console, "[ZC] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	// Set message and mode
	zp_colored_print(0, "^x04[ZC]^x01 Yeah ...^x03 %s^x01 was randomly chosed to become^x04 Nighter", g_playername[player])
	log_to_file("zc_event.log", "[MAIN EVENT : NIGHTER] --- [%s]", g_playername[id]);
	command_nighter(id, player, 1)

	return PLUGIN_CONTINUE;
}

// Show Weapons Menu
public show_menu_weapons(id)
{
	show_menu(id, 0, "\n", 1)
	new menu = menu_create("\rGet a special weapon:", "menu_handler_sw")
	new szmenu[555]

	// Watergun
	new limit, data[32]
	if(g_privileges[id] & MODE_FLAG_U)
	{
		if(limiter_get_data(g_limiter_map, "AM_Watergun", g_playername[id], data, 15))
		{
			limit = str_to_num(data)
			if (limit < 2)
			{
				formatex(szmenu, 63,"\wWatergun \r| \y%d\r/\y%d \r| \wper map", limit, 6)
				menu_additem(menu, szmenu)
			}else {
				formatex(szmenu, 63,"\dWatergun | Limit reached", limit)
				menu_additem(menu, szmenu)
			}
		}else {
			formatex(szmenu, 63,"\wWatergun \r| \y%d\r/\y%d \r| \wper map", 0, 6)
			menu_additem(menu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\dWatergun | %d/%d | per map", 0, 6)
		menu_additem(menu, szmenu)
	}

	// Plasma
	if(g_privileges[id] & MODE_FLAG_U)
	{
		if(limiter_get_data(g_limiter_map, "AM_Plasma", g_playername[id], data, 15))
		{
			limit = str_to_num(data)
			if (limit < 1)
			{
				formatex(szmenu, 63,"\wPlasma \r| \y%d\r/\y%d \r| \wper map", limit, 6)
				menu_additem(menu, szmenu)
			}else {
				formatex(szmenu, 63,"\dPlasma | Limit reached", limit)
				menu_additem(menu, szmenu)
			}
		}else {
			formatex(szmenu, 63,"\wPlasma \r| \y%d\r/\y%d \r| \wper map", 0, 6)
			menu_additem(menu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\dPlasma | %d/%d | per map", 0, 6)
		menu_additem(menu, szmenu)
	}

	// AT4CS
	if(g_privileges[id] & MODE_FLAG_U)
	{
		if(limiter_get_data(g_limiter_map, "AM_AT4CS", g_playername[id], data, 15))
		{
			limit = str_to_num(data)
			if (limit < 2)
			{
				formatex(szmenu, 63,"\wAT4CS \r| \y%d\r/\y%d \r| \wper map", limit, 6)
				menu_additem(menu, szmenu)
			}else {
				formatex(szmenu, 63,"\dAT4CS| Limit reached", limit)
				menu_additem(menu, szmenu)
			}
		}else {
			formatex(szmenu, 63,"\wAT4CS \r| \y%d\r/\y%d \r| \wper map", 0, 6)
			menu_additem(menu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\dAT4CS | %d/%d | per map", 0, 6)
		menu_additem(menu, szmenu)
	}

	if(g_privileges[id] & MODE_FLAG_V) formatex(szmenu, 63,"\wFire Grenade \r| \wNo limit")
	else formatex(szmenu, 63,"\dFire Grenade")
	menu_additem(menu, szmenu)

	if(g_privileges[id] & MODE_FLAG_V) formatex(szmenu, 63,"\wFrost Grenade \r| \wNo limit")
	else formatex(szmenu, 63,"\dFrost Grenade")
	menu_additem(menu, szmenu)

	if(g_privileges[id] & MODE_FLAG_V) formatex(szmenu, 63,"\wFlame Grenade \r| \wNo limit")
	else formatex(szmenu, 63,"\dFlame Grenade")
	menu_additem(menu, szmenu)

	// Guillotine
	if(g_privileges[id] & MODE_FLAG_W)
	{
		if(limiter_get_data(g_limiter_map, "AM_Guillotine", g_playername[id], data, 15))
		{
			limit = str_to_num(data)
			if (limit < 4)
			{
				formatex(szmenu, 63,"\wGuillotine \r| \y%d\r/\y%d \r| \wper map", limit, 6)
				menu_additem(menu, szmenu)
			}else {
				formatex(szmenu, 63,"\dGuillotine | Limit reached", limit)
				menu_additem(menu, szmenu)
			}
		}else {
			formatex(szmenu, 63,"\wGuillotine \r| \y%d\r/\y%d \r| \wper map", 0, 6)
			menu_additem(menu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\dGuillotine | %d/%d | per map", 0, 6)
		menu_additem(menu, szmenu)
	}

	// Cannon
	if(g_privileges[id] & MODE_FLAG_W)
	{
		if(limiter_get_data(g_limiter_map, "AM_Cannon", g_playername[id], data, 15))
		{
			limit = str_to_num(data)
			if (limit < 2)
			{
				formatex(szmenu, 63,"\wCannon \r| \y%d\r/\y%d \r| \wper map", limit, 6)
				menu_additem(menu, szmenu)
			}else {
				formatex(szmenu, 63,"\dCannon | Limit reached", limit)
				menu_additem(menu, szmenu)
			}
		}else {
			formatex(szmenu, 63,"\wCannon \r| \y%d\r/\y%d \r| \wper map", 0, 6)
			menu_additem(menu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\dCannon | %d/%d | per map", 0, 6)
		menu_additem(menu, szmenu)
	}

	// Coilgun
	if(g_privileges[id] & MODE_FLAG_W)
	{
		if(limiter_get_data(g_limiter_map, "AM_Coilgun", g_playername[id], data, 15))
		{
			limit = str_to_num(data)
			if (limit < 2)
			{
				formatex(szmenu, 63,"\wCoilgun \r| \y%d\r/\y%d \r| \wper map", limit, 6)
				menu_additem(menu, szmenu)
			}else {
				formatex(szmenu, 63,"\dCoilgun | Limit reached", limit)
				menu_additem(menu, szmenu)
			}
		}else {
			formatex(szmenu, 63,"\wCoilgun \r| \y%d\r/\y%d \r| \wper map", 0, 6)
			menu_additem(menu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\dCoilgun | %d/%d | per map", 0, 6)
		menu_additem(menu, szmenu)
	}

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
}
 
public menu_handler_sw(id, menu, item)
{
	switch(item)	
	{
		case 0:
		{
			if(g_privileges[id] & MODE_FLAG_U)
			{
				// Check limit
				new limit, data[32], rest_limit, counter, save[16]
				// rest_limit = 2
				rest_limit = 6
				if(limiter_get_data(g_limiter_map, "AM_Watergun", g_playername[id], data, 15))
				{
					limit = str_to_num(data)
				}
				if (limit < rest_limit)
				{
					// Get item
					give_weapon_watergun(id)
					zp_colored_print(id, "^x04[ZC]^x01 You've just got an^x04 Watergun.")

					// Save limit
					counter = limit+1
					num_to_str(counter, save, sizeof(save) - 1)
    					limiter_set_data(g_limiter_map, "AM_Watergun", g_playername[id], save)		
				}else {
					zp_colored_print(id, "^x04[ZC]^x01 This item cannot be taken anymore on this map!")
					return PLUGIN_HANDLED
				}
			}else{
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			}
		}
		case 1:
		{
			if(g_privileges[id] & MODE_FLAG_U)
			{
				// Check limit
				new limit, data[32], rest_limit, counter, save[16]
				// rest_limit = 1
				rest_limit = 6
				if(limiter_get_data(g_limiter_map, "AM_Plasma", g_playername[id], data, 15))
				{
					limit = str_to_num(data)
				}
				if (limit < rest_limit)
				{
					// Get item
					give_weapon_plasma(id)
					zp_colored_print(id, "^x04[ZC]^x01 You've just got an^x04 Plasma.")

					// Save limit
					counter = limit+1
					num_to_str(counter, save, sizeof(save) - 1)
    					limiter_set_data(g_limiter_map, "AM_Plasma", g_playername[id], save)		
				}else {
					zp_colored_print(id, "^x04[ZC]^x01 This item cannot be taken anymore on this map!")
					return PLUGIN_HANDLED
				}
			}else{
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			}
		}
		case 2:
		{
			if(g_privileges[id] & MODE_FLAG_U)
			{
				// Check limit
				new limit, data[32], rest_limit, counter, save[16]
				// rest_limit = 2
				rest_limit = 6
				if(limiter_get_data(g_limiter_map, "AM_AT4CS", g_playername[id], data, 15))
				{
					limit = str_to_num(data)
				}
				if (limit < rest_limit)
				{
					// Get item
					give_weapon_at4cs(id)
					zp_colored_print(id, "^x04[ZC]^x01 You've just got an^x04 AT4CS.")

					// Save limit
					counter = limit+1
					num_to_str(counter, save, sizeof(save) - 1)
    					limiter_set_data(g_limiter_map, "AM_AT4CS", g_playername[id], save)		
				}else {
					zp_colored_print(id, "^x04[ZC]^x01 This item cannot be taken anymore on this map!")
					return PLUGIN_HANDLED
				}
			}else{
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			}
		}
		case 3:
		{
			if(g_privileges[id] & MODE_FLAG_V)
			{
				give_item(id, "weapon_hegrenade")
				cs_set_user_bpammo(id, CSW_HEGRENADE, 1)
				zp_colored_print(id, "^x04[ZC]^x01 You've just got an^x04 Fire Grenade.")
			}else{
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			}
		}
		case 4:
		{
			if(g_privileges[id] & MODE_FLAG_V)
			{
				give_item(id, "weapon_flashbang")
				cs_set_user_bpammo(id, CSW_FLASHBANG, 1)
				zp_colored_print(id, "^x04[ZC]^x01 You've just got an^x04 Frost Grenade.")
			}else{
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			}
		}
		case 5:
		{
			if(g_privileges[id] & MODE_FLAG_V)
			{
				give_item(id, "weapon_smokegrenade")
				cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 1)
				zp_colored_print(id, "^x04[ZC]^x01 You've just got an^x04 Flame Grenade.")
			}else{
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			}
		}
		case 6:
		{
			if(g_privileges[id] & MODE_FLAG_W)
			{
				// Check limit
				new limit, data[32], rest_limit, counter, save[16]
				// rest_limit = 4
				rest_limit = 6
				if(limiter_get_data(g_limiter_map, "AM_Guillotine", g_playername[id], data, 15))
				{
					limit = str_to_num(data)
				}
				if (limit < rest_limit)
				{
					// Get item
					give_weapon_guillotine(id)
					zp_colored_print(id, "^x04[ZC]^x01 You've just got a^x04 Guillotine.")

					// Save limit
					counter = limit+1
					num_to_str(counter, save, sizeof(save) - 1)
    					limiter_set_data(g_limiter_map, "AM_Guillotine", g_playername[id], save)		
				}else {
					zp_colored_print(id, "^x04[ZC]^x01 This item cannot be taken anymore on this map!")
					return PLUGIN_HANDLED
				}
			}else{
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			}
		}
		case 7:
		{
			if(g_privileges[id] & MODE_FLAG_W)
			{
				// Check limit
				new limit, data[32], rest_limit, counter, save[16]
				// rest_limit = 2
				rest_limit = 6
				if(limiter_get_data(g_limiter_map, "AM_Cannon", g_playername[id], data, 15))
				{
					limit = str_to_num(data)
				}
				if (limit < rest_limit)
				{
					// Get item
					give_weapon_cannon(id)
					zp_colored_print(id, "^x04[ZC]^x01 You've just got a^x04 Cannon.")

					// Save limit
					counter = limit+1
					num_to_str(counter, save, sizeof(save) - 1)
    					limiter_set_data(g_limiter_map, "AM_Cannon", g_playername[id], save)		
				}else {
					zp_colored_print(id, "^x04[ZC]^x01 This item cannot be taken anymore on this map!")
					return PLUGIN_HANDLED
				}
			}else{
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			}
		}
		case 8:
		{
			if(g_privileges[id] & MODE_FLAG_W)
			{
				// Check limit
				new limit, data[32], rest_limit, counter, save[16]
				// rest_limit = 2
				rest_limit = 6
				if(limiter_get_data(g_limiter_map, "AM_Coilgun", g_playername[id], data, 15))
				{
					limit = str_to_num(data)
				}
				if (limit < rest_limit)
				{
					// Get item
					give_weapon_coilgun(id)
					zp_colored_print(id, "^x04[ZC]^x01 You've just got a^x04 CoilGun.")

					// Save limit
					counter = limit+1
					num_to_str(counter, save, sizeof(save) - 1)
    					limiter_set_data(g_limiter_map, "AM_Coilgun", g_playername[id], save)		
				}else {
					zp_colored_print(id, "^x04[ZC]^x01 This item cannot be taken anymore on this map!")
					return PLUGIN_HANDLED
				}
			}else{
				zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			}
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

// Player List Menu
public menu_player_list(id, menuid, item)
{
	// Menu was closed
	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		show_menu_admin(id)
		return PLUGIN_HANDLED;
	}
	
	// Retrieve player id
	static buffer[2], dummy, playerid
	menu_item_getinfo(menuid, item, dummy, buffer, charsmax(buffer), _, _, dummy)
	playerid = buffer[0]
	
	// Perform action on player
	
	// Get admin flags
	static userflags
	userflags = g_privileges[id]
	
	// Make sure it's still connected
	if (g_isconnected[playerid])
	{
		// Perform the right action if allowed
		switch (PL_ACTION)
		{
			case 0: // Zombiefy/Humanize command
			{
				if (g_zombie[playerid])
				{
					if (userflags & g_access_flag[ACCESS_MAKE_HUMAN])
					{
						if (allowed_human(playerid))
							command_human(id, playerid)
						else
							zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
					}
					else
						zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
				}
				else
				{
					if (g_newround ? (userflags & g_access_flag[ACCESS_MODE_INFECTION]) : (userflags & g_access_flag[ACCESS_MAKE_ZOMBIE]))
					{
						if (allowed_zombie(playerid))
							command_zombie(id, playerid)
						else
							zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
					}
					else
						zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
				}
			}
			case 1: // Nemesis command
			{
				if (g_newround ? (userflags & g_access_flag[ACCESS_MODE_NEMESIS]) : (userflags & g_access_flag[ACCESS_MAKE_NEMESIS]))
				{
					if (allowed_nemesis(playerid))
						command_nemesis(id, playerid, 0)
					else
						zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
				}
				else
					zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			}
			case 2: // Survivor command
			{
				if (g_newround ? (userflags & g_access_flag[ACCESS_MODE_SURVIVOR]) : (userflags & g_access_flag[ACCESS_MAKE_SURVIVOR]))
				{
					if (allowed_survivor(playerid))
						command_survivor(id, playerid, 0)
					else
						zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
				}
				else
					zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			}
			case 3: // Sniper command
			{
				if (g_newround ? (userflags & g_access_flag[ACCESS_MODE_SNIPER]) : (userflags & g_access_flag[ACCESS_MAKE_SNIPER]))
				{
					if (allowed_sniper(playerid))
						command_sniper(id, playerid, 0)
					else
						zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
				}
				else
					zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			}
			case 4: // Assassin command
			{
				if (g_newround ? (userflags & g_access_flag[ACCESS_MODE_ASSASSIN]) : (userflags & g_access_flag[ACCESS_MAKE_ASSASSIN]))
				{
					if (allowed_assassin(playerid))
						command_assassin(id, playerid, 0)
					else
						zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
				}
				else
					zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			}
			case 5: // Flamer command
			{
				if (g_newround ? (userflags & g_access_flag[ACCESS_MODE_FLAMER]) : (userflags & g_access_flag[ACCESS_MAKE_FLAMER]))
				{
					if (allowed_flamer(playerid))
						command_flamer(id, playerid, 0)
					else
						zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
				}
				else
					zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			}
			case 6: // Genesys command
			{
				if (g_newround ? (userflags & g_access_flag[ACCESS_MODE_GENESYS]) : (userflags & g_access_flag[ACCESS_MAKE_GENESYS]))
				{
					if (allowed_genesys(playerid))
						command_genesys(id, playerid, 0)
					else
						zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
				}
				else
					zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			}
			case 7: // Oberon command
			{
				if (g_newround ? (userflags & g_access_flag[ACCESS_MODE_OBERON]) : (userflags & g_access_flag[ACCESS_MAKE_OBERON]))
				{
					if (allowed_oberon(playerid))
						command_oberon(id, playerid, 0)
					else
						zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
				}
				else
					zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			}
			case 8: // Zadoc command
			{
				if (g_newround ? (userflags & g_access_flag[ACCESS_MODE_ZADOC]) : (userflags & g_access_flag[ACCESS_MAKE_ZADOC]))
				{
					if (allowed_zadoc(playerid))
						command_zadoc(id, playerid, 0)
					else
						zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
				}
				else
					zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			}
			case 9: // Dragon command
			{
				if (g_newround ? (userflags & g_access_flag[ACCESS_MODE_DRAGON]) : (userflags & g_access_flag[ACCESS_MAKE_DRAGON]))
				{
					if (allowed_dragon(playerid))
						command_dragon(id, playerid, 0)
					else
						zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
				}
				else
					zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			}
			case 10: // Nighter command
			{
				if (g_newround ? (userflags & g_access_flag[ACCESS_MODE_NIGHTER]) : (userflags & g_access_flag[ACCESS_MAKE_NIGHTER]))
				{
					if (allowed_nighter(playerid))
						command_nighter(id, playerid, 0)
					else
						zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
				}
				else
					zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			}
			case 11: // Respawn command
			{
				if (userflags & g_access_flag[ACCESS_RESPAWN_PLAYERS])
				{
					if (allowed_respawn(playerid))
						command_respawn(id, playerid)
					else
						zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
				}
				else
					zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT_ACCESS")
			}
		}
	}
	else
		zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
	
	menu_destroy(menuid)
	show_menu_player_list(id)
	return PLUGIN_HANDLED;
}

/*================================================================================
 [Admin Commands]
=================================================================================*/

// zp_toggle [1/0]
public cmd_toggle(id, level, cid)
{
	// Check for access flag - Enable/Disable Mod
	if (!cmd_access(id, g_access_flag[ACCESS_ENABLE_MOD], cid, 2))
		return PLUGIN_HANDLED;
	
	// Retrieve arguments
	new arg[2]
	read_argv(1, arg, charsmax(arg))
	
	// Mod already enabled/disabled
	if (str_to_num(arg) == g_pluginenabled)
		return PLUGIN_HANDLED;
	
	// Set toggle cvar
	set_pcvar_num(cvar_toggle, str_to_num(arg))
	client_print(id, print_console, "Zombie Crown XP Mode %L.", id, str_to_num(arg) ? "MOTD_ENABLED" : "MOTD_DISABLED")
	
	// Restart current map
	server_cmd("changelevel %s", mapname)
	
	return PLUGIN_HANDLED;
}

// zp_swarm
public cmd_swarm(id, level, cid)
{
	// Check for access flag - Mode Swarm
	if(!(g_privileges[id] & g_access_flag[ACCESS_MODE_SWARM]))
		return PLUGIN_HANDLED;
	
	// Swarm mode not allowed
	if (!allowed_swarm())
	{
		client_print(id, print_console, "[ZC] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_swarm(id)
	
	return PLUGIN_HANDLED;
}

// zp_multi
public cmd_multi(id, level, cid)
{
	// Check for access flag - Mode Multi
	if(!(g_privileges[id] & g_access_flag[ACCESS_MODE_MULTI]))
		return PLUGIN_HANDLED;
	
	// Multi infection mode not allowed
	if (!allowed_multi())
	{
		client_print(id, print_console, "[ZC] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_multi(id)
	
	return PLUGIN_HANDLED;
}

// zp_plague
public cmd_plague(id, level, cid)
{
	// Check for access flag - Mode Plague
	if(!(g_privileges[id] & g_access_flag[ACCESS_MODE_PLAGUE]))
		return PLUGIN_HANDLED;
	
	// Plague mode not allowed
	if (!allowed_plague())
	{
		client_print(id, print_console, "[ZC] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_plague(id)
	
	return PLUGIN_HANDLED;
}

// zp_lnj
public cmd_lnj(id, level, cid)
{
	// Check for access flag - Mode LNJ
	if(!(g_privileges[id] & g_access_flag[ACCESS_MODE_LNJ]))
		return PLUGIN_HANDLED;

	// Apocalypse mode not allowed
	if (!allowed_lnj())
	{
		client_print(id, print_console, "[ZC] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	command_lnj(id)
	
	return PLUGIN_HANDLED;
}

// zp_guardians
public cmd_guardians(id, level, cid)
{
	// Check for access flag - Mode guardians
	if(!(g_privileges[id] & g_access_flag[ACCESS_MODE_GUARDIANS]))
		return PLUGIN_HANDLED;

	// Guardians mode not allowed
	if (!allowed_guardians())
	{
		client_print(id, print_console, "[ZC] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	command_guardians(id)
	
	return PLUGIN_HANDLED;
}
/*================================================================================
 [Message Hooks]
=================================================================================*/

// Current Weapon info
public message_cur_weapon(msg_id, msg_dest, msg_entity)
{
	// Not alive or zombie
	if (!g_isalive[msg_entity] || g_zombie[msg_entity] || g_zadoc[msg_entity])
		return;
	
	// Not an active weapon
	if (get_msg_arg_int(1) != 1)
		return;
	
	// Unlimited clip disabled for class
	if (g_survivor[msg_entity] ? zc_surv_unlimited_ammo <= 1 : zc_human_unlimited_ammo <= 1 && g_hero[msg_entity] ? zc_hero_unlimited_ammo <= 1 : zc_human_unlimited_ammo <= 1 && g_sniper[msg_entity] ? zc_sniper_unlimited_ammo <= 1 : zc_human_unlimited_ammo <= 1)
		return;
	
	// Get weapon's id
	static weapon
	weapon = get_msg_arg_int(2)
	
	// Unlimited Clip Ammo for this weapon?
	if (MAXBPAMMO[weapon] > 2)
	{
		// Max out clip ammo
		cs_set_weapon_ammo(fm_cs_get_current_weapon_ent(msg_entity), MAXCLIP[weapon])
		
		// HUD should show full clip all the time
		set_msg_arg_int(3, get_msg_argtype(3), MAXCLIP[weapon])
	}
}

// Take off player's money
public message_money(msg_id, msg_dest, msg_entity)
{
	// Remove money setting enabled?
	if (!get_pcvar_num(g_pCvars[Hide_Money]))
		return PLUGIN_CONTINUE;
	
	fm_cs_set_user_money(msg_entity, 0)
	return PLUGIN_HANDLED;
}

// Fix for the HL engine bug when HP is multiples of 256
public message_health(msg_id, msg_dest, msg_entity)
{
	// Get player's health
	static health
	health = get_msg_arg_int(1)
	
	// Don't bother
	if (health < 256) return;
	
	// Check if we need to fix it
	if (health % 256 == 0)
		fm_set_user_health(msg_entity, pev(msg_entity, pev_health) + 1)
	
	// HUD can only show as much as 255 hp
	set_msg_arg_int(1, get_msg_argtype(1), 255)
}

// Block flashlight battery messages if custom flashlight is enabled instead
public message_flashbat()
{
	if (g_cached_customflash)
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Flashbangs should only affect zombies
public message_screenfade(msg_id, msg_dest, msg_entity)
{
	if (get_msg_arg_int(4) != 255 || get_msg_arg_int(5) != 255 || get_msg_arg_int(6) != 255 || get_msg_arg_int(7) < 200)
		return PLUGIN_CONTINUE;
	
	// Nemesis shouldn't be FBed
	if (g_zombie[msg_entity] && !g_nemesis[msg_entity] && !g_assassin[msg_entity] && !g_oberon[msg_entity] && !g_dragon[msg_entity] && !g_nighter[msg_entity] && !g_genesys[msg_entity])
	{
		// Set flash color to nighvision's
		set_msg_arg_int(4, get_msg_argtype(4), 255)
		set_msg_arg_int(5, get_msg_argtype(5), 0)
		set_msg_arg_int(6, get_msg_argtype(6), 0)
		return PLUGIN_CONTINUE;
	}
	
	return PLUGIN_HANDLED;
}

// Prevent spectators' nightvision from being turned off when switching targets, etc.
public message_nvgtoggle()
{
	return PLUGIN_HANDLED;
}

// Set correct model on player corpses
public message_clcorpse()
{
	set_msg_arg_string(1, g_playermodel[get_msg_arg_int(12)])
}

// Prevent zombies from seeing any weapon pickup icon
public message_weappickup(msg_id, msg_dest, msg_entity)
{
	if (g_zombie[msg_entity] || g_zadoc[msg_entity])
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Prevent zombies from seeing any ammo pickup icon
public message_ammopickup(msg_id, msg_dest, msg_entity)
{
	if (g_zombie[msg_entity] || g_zadoc[msg_entity])
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Block hostage HUD display
public message_scenario()
{
	if (get_msg_args() > 1)
	{
		static sprite[8]
		get_msg_arg_string(2, sprite, charsmax(sprite))
		
		if (equal(sprite, "hostage"))
			return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

// Block hostages from appearing on radar
public message_hostagepos()
{
	return PLUGIN_HANDLED;
}

// Block some text messages
public message_textmsg()
{
	static textmsg[22]
	get_msg_arg_string(2, textmsg, charsmax(textmsg))
	
	// Game restarting, reset scores and call round end to balance the teams
	if (equal(textmsg, "#Game_will_restart_in"))
	{
		g_scorehumans = 0
		g_scorezombies = 0
		logevent_round_end()
	}
	// Block round end related messages
	else if (equal(textmsg, "#Hostages_Not_Rescued") || equal(textmsg, "#Round_Draw") || equal(textmsg, "#Terrorists_Win") || equal(textmsg, "#CTs_Win"))
	{
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

// Block CS round win audio messages, since we're playing our own instead
public message_sendaudio()
{
	static audio[17]
	get_msg_arg_string(2, audio, charsmax(audio))
	
	if (equal(audio[7], "terwin") || equal(audio[7], "ctwin") || equal(audio[7], "rounddraw"))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Send actual team scores (T = zombies // CT = humans)
public message_teamscore()
{
	static team[2]
	get_msg_arg_string(1, team, charsmax(team))
	
	switch (team[0])
	{
		// CT
		case 'C': set_msg_arg_int(2, get_msg_argtype(2), g_scorehumans)
		// Terrorist
		case 'T': set_msg_arg_int(2, get_msg_argtype(2), g_scorezombies)
	}
}

// Team Switch (or player joining a team for first time)
public message_teaminfo(msg_id, msg_dest)
{
	// Only hook global messages
	if (msg_dest != MSG_ALL && msg_dest != MSG_BROADCAST) return;
	
	// Don't pick up our own TeamInfo messages for this player (bugfix)
	if (g_switchingteam) return;
	
	// Get player's id
	static id
	id = get_msg_arg_int(1)
	
	// Enable spectators' nightvision if not spawning right away
	set_task(0.2, "spec_nvision", id)
	
	// Round didn't start yet, nothing to worry about
	if (g_newround) return;
	
	// Get his new team
	static team[2]
	get_msg_arg_string(2, team, charsmax(team))
	
	// Perform some checks to see if they should join a different team instead
	switch (team[0])
	{
		case 'C': // CT
		{
			if (g_survround && fnGetHumans() || g_sniperround && fnGetHumans() || g_flamerround && fnGetHumans() || g_zadocround && fnGetHumans()) // survivor, sniper, flamer or zadoc alive --> switch to T and spawn as zombie
			{
				g_respawn_as_zombie[id] = true;
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_T)
				set_msg_arg_string(2, "TERRORIST")
			}
			else if (!fnGetZombies()) // no zombies alive --> switch to T and spawn as zombie
			{
				g_respawn_as_zombie[id] = true;
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_T)
				set_msg_arg_string(2, "TERRORIST")
			}
		}
		case 'T': // Terrorist
		{
			if ((g_swarmround || g_survround || g_sniperround) && fnGetHumans() || g_flamerround && fnGetHumans() || g_zadocround && fnGetHumans()) // survivor\sniper\flamer\zadoc alive or swarm round w\ humans --> spawn as zombie
			{
				g_respawn_as_zombie[id] = true;
			}
			else if (fnGetZombies()) // zombies alive --> switch to CT
			{
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				set_msg_arg_string(2, "CT")
			}
		}
	}
}

/*================================================================================
 [Main Functions]
=================================================================================*/

// Make Zombie Task
public make_zombie_task()
{
	// Call make a zombie with no specific mode
	make_a_zombie(MODE_NONE, 0)
}

// Make a Zombie Function
make_a_zombie(mode, id)
{
	// Get alive players count
	static iPlayersnum
	iPlayersnum = fnGetAlive()
	
	// Not enough players, come back later!
	if (iPlayersnum < 1)
	{
		set_task(2.0, "make_zombie_task", TASK_MAKEZOMBIE)
		return;
	}
	
	// Round started!
	g_newround = false
	
	// Set up some common vars
	static forward_id, sound[64], iZombies, iMaxZombies
	
	if ((mode == MODE_NONE && g_lastmode == MODE_INFECTION && random_num(1, zc_surv_chance) == zc_surv_enabled && iPlayersnum >= zc_surv_min_players) || mode == MODE_SURVIVOR)
	{
		// Survivor Mode
		g_survround = true
		g_lastmode = MODE_SURVIVOR

		// Show HUD Message
		set_dhudmessage(0, 32, 276, HUD_EVENT_X, HUD_EVENT_Y, 1, 6.0, 1.0, 0.1, 1.5);
    		show_dhudmessage(0, "Survivor Mode !!!^n Our last chance ...");
		
		// Choose player randomly?
		if (mode == MODE_NONE)
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		// Turn player into a survivor
		humanme(id, 1, 0, 0, 0, 0, 0)
		
		// Turn the remaining players into zombies
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
				continue;
			
			// Survivor, sniper or already a zombie
			if (g_survivor[id] || g_zombie[id] || g_sniper[id])
				continue;
			
			// Turn into a zombie
			zombieme(id, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0)
		}
		
		// Play survivor sound
		ArrayGetString(sound_survivor, random_num(0, ArraySize(sound_survivor) - 1), sound, charsmax(sound))
		PlaySound(sound);

		// Remove any announcements
		for(new i = 1; i <= g_maxplayers; i++)
		{
			if(g_announce_valid[i]){
				zp_colored_print(0, "^x04[ZC]^x01 All^x04 announcements^x01 were removed by^x04 server.")
				set_task(0.1, "removeannounce", i)
			}
		}
		
		// Mode fully started!
		g_modestarted = true
		
		// Round start forward
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_SURVIVOR, forward_id);
	}
	else if ((mode == MODE_NONE && g_lastmode == MODE_INFECTION && random_num(1, zc_swarm_chance) == zc_swarm_enabled && iPlayersnum >= zc_swarm_min_players) || mode == MODE_SWARM)
	{		
		// Swarm Mode
		g_swarmround = true
		g_lastmode = MODE_SWARM

		// Show HUD Message
    		set_dhudmessage(215, 32, 76, HUD_EVENT_X, HUD_EVENT_Y, 1, 6.0, 1.0, 0.1, 1.5);
    		show_dhudmessage(0, "Swarm Mode !!!^n Beware of zombies !!");
		
		// Make sure there are alive players on both teams (BUGFIX)
		if (!fnGetAliveTs())
		{
			// Move random player to T team
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			remove_task(id+TASK_TEAM)
			fm_cs_set_user_team(id, FM_CS_TEAM_T)
			fm_user_team_update(id)
		}
		else if (!fnGetAliveCTs())
		{
			// Move random player to CT team
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			remove_task(id+TASK_TEAM)
			fm_cs_set_user_team(id, FM_CS_TEAM_CT)
			fm_user_team_update(id)
		}
		
		// Turn every T into a zombie
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
				continue;
			
			// Not a Terrorist
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_T)
				continue;
			
			// Turn into a zombie
			zombieme(id, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0)
		}
		
		// Play swarm sound
		ArrayGetString(sound_swarm, random_num(0, ArraySize(sound_swarm) - 1), sound, charsmax(sound))
		PlaySound(sound);
		
		// Mode fully started!
		g_modestarted = true
		
		// Round start forward
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_SWARM, 0);
	}
	else if ((mode == MODE_NONE && g_lastmode == MODE_INFECTION && random_num(1, zc_multi_chance) == zc_multi_enabled && floatround(iPlayersnum*zc_multi_ratio, floatround_ceil) >= 2 && floatround(iPlayersnum*zc_multi_ratio, floatround_ceil) < iPlayersnum && iPlayersnum >= zc_multi_min_players) || mode == MODE_MULTI)
	{
		// Multi Infection Mode
		g_lastmode = MODE_MULTI

		// Show HUD Message
    		set_dhudmessage(35, 255, 26, HUD_EVENT_X, HUD_EVENT_Y, 1, 6.0, 1.0, 0.1, 1.5);
    		show_dhudmessage(0, "Multi Infection Mode !!!^n Oh, no ! The virus spread so quickly ...");
		
		// iMaxZombies is rounded up, in case there aren't enough players
		iMaxZombies = floatround(iPlayersnum*zc_multi_ratio, floatround_ceil)
		iZombies = 0
		
		// Randomly turn iMaxZombies players into zombies
		while (iZombies < iMaxZombies)
		{
			// Keep looping through all players
			if (++id > g_maxplayers) id = 1
			
			// Dead or already a zombie
			if (!g_isalive[id] || g_zombie[id])
				continue;
			
			// Random chance
			if (random_num(0, 1))
			{
				// Turn into a zombie
				zombieme(id, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0)
				iZombies++
			}
		}
		
		// Turn the remaining players into humans
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Only those of them who aren't zombies
			if (!g_isalive[id] || g_zombie[id])
				continue;
			
			// Switch to CT
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
			{
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				fm_user_team_update(id)
			}
		}
		
		// Play multi infection sound
		ArrayGetString(sound_multi, random_num(0, ArraySize(sound_multi) - 1), sound, charsmax(sound))
		PlaySound(sound);
		
		// Mode fully started!
		g_modestarted = true
		
		// Round start forward
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_MULTI, 0);
	}
	else if ((mode == MODE_NONE && g_lastmode == MODE_INFECTION && random_num(1, zc_plague_chance) == zc_plague_enabled 
	&& floatround((iPlayersnum-(zc_plague_nem_number+zc_plague_surv_number))*zc_plague_ratio, floatround_ceil) >= 1 && 
	iPlayersnum-(zc_plague_surv_number+zc_plague_nem_number+floatround((iPlayersnum-(zc_plague_nem_number+zc_plague_surv_number))*zc_plague_ratio, floatround_ceil)) >= 1 
	&& iPlayersnum >= zc_plague_min_players) || mode == MODE_PLAGUE)
	{
		// Plague Mode
		g_plagueround = true
		g_lastmode = MODE_PLAGUE

		// Show HUD Message
    		set_dhudmessage(115, 52, 16, HUD_EVENT_X, HUD_EVENT_Y, 1, 6.0, 1.0, 0.1, 1.5);
    		show_dhudmessage(0, "Plague Mode !!!^n The nemesis is among zombie! But look, the survivor will help you !");
		
		// Turn specified amount of players into Survivors
		static iSurvivors, iMaxSurvivors
		iMaxSurvivors = zc_plague_surv_number
		iSurvivors = 0
		
		while (iSurvivors < iMaxSurvivors)
		{
			// Choose random guy
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			
			// Already a survivor?
			if (g_survivor[id])
				continue;
			
			// If not, turn him into one
			humanme(id, 1, 0, 0, 0, 0, 0)
			iSurvivors++
			
			// Apply survivor health multiplier
			fm_set_user_health(id, floatround(float(pev(id, pev_health)) * zc_plague_surv_hp_multi))
		}
		
		// Turn specified amount of players into Nemesis
		static iNemesis, iMaxNemesis
		iMaxNemesis = zc_plague_nem_number
		iNemesis = 0
		
		while (iNemesis < iMaxNemesis)
		{
			// Choose random guy
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			
			// Already a survivor or nemesis?
			if (g_survivor[id] || g_nemesis[id])
				continue;
			
			// If not, turn him into one
			zombieme(id, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0)
			iNemesis++
			
			// Apply nemesis health multiplier
			fm_set_user_health(id, floatround(float(pev(id, pev_health)) * zc_plague_nem_hp_multi))
		}
		
		// iMaxZombies is rounded up, in case there aren't enough players
		iMaxZombies = floatround((iPlayersnum-(zc_plague_nem_number+zc_plague_surv_number))*zc_plague_ratio, floatround_ceil)
		iZombies = 0
		
		// Randomly turn iMaxZombies players into zombies
		while (iZombies < iMaxZombies)
		{
			// Keep looping through all players
			if (++id > g_maxplayers) id = 1
			
			// Dead or already a zombie or survivor
			if (!g_isalive[id] || g_zombie[id] || g_survivor[id])
				continue;
			
			// Random chance
			if (random_num(0, 1))
			{
				// Turn into a zombie
				zombieme(id, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0)
				iZombies++
			}
		}
		
		// Turn the remaining players into humans
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Only those of them who arent zombies or survivor
			if (!g_isalive[id] || g_zombie[id] || g_survivor[id])
				continue;
			
			// Switch to CT
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
			{
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				fm_user_team_update(id)
			}
		}
		
		// Play plague sound
		ArrayGetString(sound_plague, random_num(0, ArraySize(sound_plague) - 1), sound, charsmax(sound))
		PlaySound(sound);

		// Remove any announcements
		for(new i = 1; i <= g_maxplayers; i++)
		{
			if(g_announce_valid[i]){
				zp_colored_print(0, "^x04[ZC]^x01 All^x04 announcements^x01 were removed by^x04 server.")
				set_task(0.1, "removeannounce", i)
			}
		}
		
		// Mode fully started!
		g_modestarted = true
		
		// Round start forward
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_PLAGUE, 0);
	}
	else if ((mode == MODE_NONE && g_lastmode == MODE_INFECTION && random_num(1, zc_sniper_chance) == zc_sniper_enabled && iPlayersnum >= zc_sniper_min_players) || mode == MODE_SNIPER)
	{
		// Sniper Mode
		g_sniperround = true
		g_lastmode = MODE_SNIPER

		// Show HUD Message
    		set_dhudmessage(215, 32, 76, HUD_EVENT_X, HUD_EVENT_Y, 1, 6.0, 1.0, 0.1, 1.5);
    		show_dhudmessage(0, "Sniper Mode !!!^n His AWP is invincible !!!");
		
		// Choose player randomly?
		if (mode == MODE_NONE)
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		// MAKE SNIPER
		humanme(id, 0, 0, 1, 0, 0, 0)
				
		// Turn the rest of players into zombies
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!is_user_alive(id))
				continue;
			
			// Sniper or already a zombie
			if (g_sniper[id] || g_zombie[id])
				continue;
			
			// Turn into a zombie
			zombieme(id, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0)
		}

		// Play sniper sound
		ArrayGetString(sound_sniper, random_num(0, ArraySize(sound_sniper) - 1), sound, charsmax(sound))
		PlaySound(sound);

		// Remove any announcements
		for(new i = 1; i <= g_maxplayers; i++)
		{
			if(g_announce_valid[i]){
				zp_colored_print(0, "^x04[ZC]^x01 All^x04 announcements^x01 were removed by^x04 server.")
				set_task(0.1, "removeannounce", i)
			}
		}
		
		// Mode fully started!
		g_modestarted = true
		
		// Round start forward
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_SNIPER, forward_id);
	}
	else if ((mode == MODE_NONE && g_lastmode == MODE_INFECTION && random_num(1, zc_flamer_chance) == zc_flamer_enabled && iPlayersnum >= zc_flamer_min_players) || mode == MODE_FLAMER)
	{
		// Flamer Mode
		g_flamerround = true
		g_lastmode = MODE_FLAMER

		// Show HUD Message
		set_dhudmessage(115, 132, 26, HUD_EVENT_X, HUD_EVENT_Y, 1, 6.0, 1.0, 0.1, 1.5);
    		show_dhudmessage(0, "Flamer Mode !!!^n Yep, the flamer has a super weapon !!! We will win!");
		
		// Choose player randomly?
		if (mode == MODE_NONE)
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		// MAKE FLAMER
		humanme(id, 0, 0, 0, 1, 0, 0)
				
		// Turn the rest of players into zombies
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!is_user_alive(id))
				continue;
			
			// Flamer or already a zombie
			if (g_flamer[id] || g_zombie[id])
				continue;
			
			// Turn into a zombie
			zombieme(id, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0)
		}

		// Play flamer sound
		ArrayGetString(sound_flamer, random_num(0, ArraySize(sound_flamer) - 1), sound, charsmax(sound))
		PlaySound(sound);

		// Remove any announcements
		for(new i = 1; i <= g_maxplayers; i++)
		{
			if(g_announce_valid[i]){
				zp_colored_print(0, "^x04[ZC]^x01 All^x04 announcements^x01 were removed by^x04 server.")
				set_task(0.1, "removeannounce", i)
			}
		}
		
		// Mode fully started!
		g_modestarted = true
		
		// Round start forward
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_FLAMER, forward_id);
	}
	else if ((mode == MODE_NONE && g_lastmode == MODE_INFECTION && random_num(1, zc_zadoc_chance) == zc_zadoc_enabled && iPlayersnum >= zc_zadoc_min_players) || mode == MODE_ZADOC)
	{
		// Zadoc Mode
		g_zadocround = true
		g_lastmode = MODE_ZADOC

		// Show HUD Message
		set_dhudmessage(115, 132, 26, HUD_EVENT_X, HUD_EVENT_Y, 1, 6.0, 1.0, 0.1, 1.5);
    		show_dhudmessage(0, "Zadoc Mode !!!^n Yep, the Zadoc has a super knife !!! We will win!");
		
		// Choose player randomly?
		if (mode == MODE_NONE)
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		// MAKE ZADOC
		humanme(id, 0, 0, 0, 0, 1, 0)
				
		// Turn the rest of players into zombies
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!is_user_alive(id))
				continue;
			
			// Zadoc or already a zombie
			if (g_zadoc[id] || g_zombie[id])
				continue;
			
			// Turn into a zombie
			zombieme(id, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0)
		}

		// Play Zadoc sound
		ArrayGetString(sound_zadoc, random_num(0, ArraySize(sound_zadoc) - 1), sound, charsmax(sound))
		PlaySound(sound);

		// Remove any announcements
		for(new i = 1; i <= g_maxplayers; i++)
		{
			if(g_announce_valid[i]){
				zp_colored_print(0, "^x04[ZC]^x01 All^x04 announcements^x01 were removed by^x04 server.")
				set_task(0.1, "removeannounce", i)
			}
		}
		
		// Mode fully started!
		g_modestarted = true
		
		// Round start forward
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_ZADOC, forward_id);
	}
	else  if ((mode == MODE_NONE && g_lastmode == MODE_INFECTION && random_num(1, zc_assassin_chance) == zc_assassin_enabled && iPlayersnum >= zc_assassin_min_players) || mode == MODE_ASSASSIN)
	{
		static ent
		// Assassin Mode
		g_assassinround = true
		g_lastmode = MODE_ASSASSIN

		// Change Lighting Effect
		lighting_effects(2)
		
		// Show HUD Message
		set_dhudmessage(215, 2, 116, HUD_EVENT_X, HUD_EVENT_Y, 1, 6.0, 1.0, 0.1, 1.5);
    		show_dhudmessage(0, "Assassin Mode !!!^n Oh, no ! The assassin has excaped! Attention!");
		
		// Choose player randomly?
		if (mode == MODE_NONE)
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			
		// Remember id for calling our forward later
		forward_id = id
		
		// Turn player into assassin
		zombieme(id, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0)
		
		// Remaining players should be humans (CTs)
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
				continue;
			
			// First assassin
			if (g_zombie[id])
				continue;

			// Switch to CT
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
			{
				// Change team
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				fm_user_team_update(id)
			}
			
			// Make a screen fade 
			message_begin(MSG_ONE, g_msgScreenFade, _, id)
			write_short(UNIT_SECOND*5) // duration
			write_short(0) // hold time
			write_short(FFADE_IN) // fade type
			write_byte(250) // red
			write_byte(0) // green
			write_byte(0) // blue
			write_byte(255) // alpha
			message_end()
			
			// Make a screen shake [Make it horrorful]
			message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id)
			write_short(UNIT_SECOND*(75*10)) // amplitude
			write_short(UNIT_SECOND*7) // duration
			write_short(UNIT_SECOND*(75)) // frequency
			message_end()
		}
		
		// Turn off the lights [Taken From Speeds Zombie Mutilation]
		ent = -1
		while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "light")) != 0)
		{
			dllfunc(DLLFunc_Use, ent, 0);
			set_pev(ent, pev_targetname, 0) 
		}
		
		// Play Assassin sound
		ArrayGetString(sound_assassin, random_num(0, ArraySize(sound_assassin) - 1), sound, charsmax(sound))
		PlaySound(sound);

		// Remove any announcements
		for(new i = 1; i <= g_maxplayers; i++)
		{
			if(g_announce_valid[i]){
				zp_colored_print(0, "^x04[ZC]^x01 All^x04 announcements^x01 were removed by^x04 server.")
				set_task(0.1, "removeannounce", i)
			}
		}
		
		// Mode fully started!
		g_modestarted = true
		
		// Round start forward
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_ASSASSIN, forward_id);
	}
	else  if ((mode == MODE_NONE && g_lastmode == MODE_INFECTION && random_num(1, zc_genesys_chance) == zc_genesys_enabled && iPlayersnum >= zc_genesys_min_players) || mode == MODE_GENESYS)
	{
		// Genesys Mode
		g_genesysround = true
		g_lastmode = MODE_GENESYS

		// Show HUD Message
		set_dhudmessage(35, 132, 176, HUD_EVENT_X, HUD_EVENT_Y, 1, 6.0, 1.0, 0.1, 1.5);
    		show_dhudmessage(0, "Genesys Mode !!!^n He is so powerful... He throws flames, creates locusts and walks through the walls !!");
		
		// Choose player randomly?
		if (mode == MODE_NONE)
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			
		// Remember id for calling our forward later
		forward_id = id
		
		// Turn player into genesys
		zombieme(id, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0)
		
		// Remaining players should be humans (CTs)
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
				continue;
			
			// First genesys
			if (g_zombie[id])
				continue;

			// Switch to CT
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
			{
				// Change team
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				fm_user_team_update(id)
			}
			
			// Make a screen fade 
			message_begin(MSG_ONE, g_msgScreenFade, _, id)
			write_short(UNIT_SECOND*5) // duration
			write_short(0) // hold time
			write_short(FFADE_IN) // fade type
			write_byte(250) // red
			write_byte(0) // green
			write_byte(0) // blue
			write_byte(255) // alpha
			message_end()
			
			// Make a screen shake [Make it horrorful]
			message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id)
			write_short(UNIT_SECOND*(75*10)) // amplitude
			write_short(UNIT_SECOND*7) // duration
			write_short(UNIT_SECOND*(75)) // frequency
			message_end()
		}
		
		// Play Genesys sound
		ArrayGetString(sound_genesys, random_num(0, ArraySize(sound_genesys) - 1), sound, charsmax(sound))
		PlaySound(sound);

		// Remove any announcements
		for(new i = 1; i <= g_maxplayers; i++)
		{
			if(g_announce_valid[i]){
				zp_colored_print(0, "^x04[ZC]^x01 All^x04 announcements^x01 were removed by^x04 server.")
				set_task(0.1, "removeannounce", i)
			}
		}		
		
		// Mode fully started!
		g_modestarted = true
		
		// Round start forward
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_GENESYS, forward_id);
	}
	else  if ((mode == MODE_NONE && g_lastmode == MODE_INFECTION && random_num(1, zc_oberon_chance) == zc_oberon_enabled && iPlayersnum >= zc_oberon_min_players) || mode == MODE_OBERON)
	{
		// Oberon Mode
		g_oberonround = true
		g_lastmode = MODE_OBERON

		// Show HUD Message
		set_dhudmessage(35, 132, 176, HUD_EVENT_X, HUD_EVENT_Y, 1, 6.0, 1.0, 0.1, 1.5);
    		show_dhudmessage(0, "Oberon Mode !!!^n He is so powerful... He throw bombs around you and create a super hole !!");
		
		// Choose player randomly?
		if (mode == MODE_NONE)
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			
		// Remember id for calling our forward later
		forward_id = id
		
		// Turn player into oberon
		zombieme(id, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0)
		
		// Remaining players should be humans (CTs)
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
				continue;
			
			// First oberon
			if (g_zombie[id])
				continue;

			// Switch to CT
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
			{
				// Change team
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				fm_user_team_update(id)
			}
			
			// Make a screen fade 
			message_begin(MSG_ONE, g_msgScreenFade, _, id)
			write_short(UNIT_SECOND*5) // duration
			write_short(0) // hold time
			write_short(FFADE_IN) // fade type
			write_byte(250) // red
			write_byte(0) // green
			write_byte(0) // blue
			write_byte(255) // alpha
			message_end()
			
			// Make a screen shake [Make it horrorful]
			message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id)
			write_short(UNIT_SECOND*(75*10)) // amplitude
			write_short(UNIT_SECOND*7) // duration
			write_short(UNIT_SECOND*(75)) // frequency
			message_end()
		}
		
		// Play Oberon sound
		ArrayGetString(sound_oberon, random_num(0, ArraySize(sound_oberon) - 1), sound, charsmax(sound))
		PlaySound(sound);

		// Remove any announcements
		for(new i = 1; i <= g_maxplayers; i++)
		{
			if(g_announce_valid[i]){
				zp_colored_print(0, "^x04[ZC]^x01 All^x04 announcements^x01 were removed by^x04 server.")
				set_task(0.1, "removeannounce", i)
			}
		}		
		
		// Mode fully started!
		g_modestarted = true
		
		// Round start forward
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_OBERON, forward_id);
	}
	else  if ((mode == MODE_NONE && g_lastmode == MODE_INFECTION && random_num(1, zc_dragon_chance) == zc_dragon_enabled && iPlayersnum >= zc_dragon_min_players) || mode == MODE_DRAGON)
	{
		// Dragon Mode
		g_dragonround = true
		g_lastmode = MODE_DRAGON

		// Show HUD Message
		set_dhudmessage(35, 132, 176, HUD_EVENT_X, HUD_EVENT_Y, 1, 6.0, 1.0, 0.1, 1.5);
    		show_dhudmessage(0, "Dragon Mode !!!^n He is so powerful... He can fly and throw frost air.");

		// Choose player randomly?
		if (mode == MODE_NONE)
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			
		// Remember id for calling our forward later
		forward_id = id
		
		// Turn player into Dragon
		zombieme(id, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0)
		
		// Remaining players should be humans (CTs)
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
				continue;
			
			// First dragon
			if (g_zombie[id])
				continue;

			// Switch to CT
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
			{
				// Change team
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				fm_user_team_update(id)
			}
			
			// Make a screen fade 
			message_begin(MSG_ONE, g_msgScreenFade, _, id)
			write_short(UNIT_SECOND*5) // duration
			write_short(0) // hold time
			write_short(FFADE_IN) // fade type
			write_byte(250) // red
			write_byte(0) // green
			write_byte(0) // blue
			write_byte(255) // alpha
			message_end()
			
			// Make a screen shake [Make it horrorful]
			message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id)
			write_short(UNIT_SECOND*(75*10)) // amplitude
			write_short(UNIT_SECOND*7) // duration
			write_short(UNIT_SECOND*(75)) // frequency
			message_end()
		}
		
		// Play Dragon sound
		ArrayGetString(sound_dragon, random_num(0, ArraySize(sound_dragon) - 1), sound, charsmax(sound))
		PlaySound(sound);

		// Remove any announcements
		for(new i = 1; i <= g_maxplayers; i++)
		{
			if(g_announce_valid[i]){
				zp_colored_print(0, "^x04[ZC]^x01 All^x04 announcements^x01 were removed by^x04 server.")
				set_task(0.1, "removeannounce", i)
			}
		}		
		
		// Mode fully started!
		g_modestarted = true
		
		// Round start forward
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_DRAGON, forward_id);
	}
	else  if ((mode == MODE_NONE && g_lastmode == MODE_INFECTION && random_num(1, zc_nighter_chance) == zc_nighter_enabled && iPlayersnum >= zc_nighter_min_players) || mode == MODE_NIGHTER)
	{
		// Nighter Mode
		g_nighterround = true
		g_lastmode = MODE_NIGHTER

		// Show HUD Message
		set_dhudmessage(35, 132, 176, HUD_EVENT_X, HUD_EVENT_Y, 1, 6.0, 1.0, 0.1, 1.5);
    		show_dhudmessage(0, "Nighter Mode !!!^n He is so powerful... He is invisible if you don't shot him.");

		// Choose player randomly?
		if (mode == MODE_NONE)
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			
		// Remember id for calling our forward later
		forward_id = id
		
		// Turn player into Nighter
		zombieme(id, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0)
		
		// Remaining players should be humans (CTs)
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
				continue;
			
			// First nighter
			if (g_zombie[id])
				continue;

			// Switch to CT
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
			{
				// Change team
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				fm_user_team_update(id)
			}
			
			// Make a screen fade 
			message_begin(MSG_ONE, g_msgScreenFade, _, id)
			write_short(UNIT_SECOND*5) // duration
			write_short(0) // hold time
			write_short(FFADE_IN) // fade type
			write_byte(250) // red
			write_byte(0) // green
			write_byte(0) // blue
			write_byte(255) // alpha
			message_end()
			
			// Make a screen shake [Make it horrorful]
			message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id)
			write_short(UNIT_SECOND*(75*10)) // amplitude
			write_short(UNIT_SECOND*7) // duration
			write_short(UNIT_SECOND*(75)) // frequency
			message_end()
		}
		
		// Play Nighter sound
		ArrayGetString(sound_nighter, random_num(0, ArraySize(sound_nighter) - 1), sound, charsmax(sound))
		PlaySound(sound);

		// Remove any announcements
		for(new i = 1; i <= g_maxplayers; i++)
		{
			if(g_announce_valid[i]){
				zp_colored_print(0, "^x04[ZC]^x01 All^x04 announcements^x01 were removed by^x04 server.")
				set_task(0.1, "removeannounce", i)
			}
		}		
		
		// Mode fully started!
		g_modestarted = true
		
		// Round start forward
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_NIGHTER, forward_id);
	}
	else if ((mode == MODE_NONE && g_lastmode == MODE_INFECTION && random_num(1, zc_lnj_chance) == zc_lnj_enabled && iPlayersnum >= zc_lnj_min_players &&iPlayersnum >= 2) || mode == MODE_LNJ)
	{
		// Armageddon Mode
		g_lnjround = true
		g_lastmode = MODE_LNJ

		// Show HUD Message
    		set_dhudmessage(54, 132, 216, HUD_EVENT_X, HUD_EVENT_Y, 1, 6.0, 1.0, 0.1, 1.5);
    		show_dhudmessage(0, "Armaggedon Mode !!!^n The final battle ! Survivor vs. Nemesis !");
		
		// iMaxZombies is rounded up, in case there aren't enough players
		iMaxZombies = floatround((iPlayersnum * zc_lnj_ratio), floatround_ceil)
		iZombies = 0
		
		// Randomly turn iMaxZombies players into Nemesis
		while (iZombies < iMaxZombies)
		{
			// Keep looping through all players
			if (++id > g_maxplayers) id = 1
			
			// Dead or already a zombie or survivor
			if (!g_isalive[id] || g_zombie[id] || g_survivor[id])
				continue;
			
			// Random chance
			if (random_num(0, 1))
			{
				// Turn into a Nemesis
				zombieme(id, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0)
				fm_set_user_health(id, floatround(float(pev(id, pev_health)) * zc_lnj_nem_hp_multi))
				iZombies++
			}
		}
		
		// Turn the remaining players into humans
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Only those of them who arent zombies or survivor
			if (!g_isalive[id] || g_zombie[id] || g_survivor[id])
				continue;
			
			// Turn into a Survivor
			humanme(id, 1, 0, 0, 0, 0, 0)
			fm_set_user_health(id, floatround(float(pev(id, pev_health)) * zc_lnj_surv_hp_multi))
		}
		
		// Play LNJ sound
		ArrayGetString(sound_lnj, random_num(0, ArraySize(sound_lnj) - 1), sound, charsmax(sound))
		PlaySound(sound);

		// Remove any announcements
		for(new i = 1; i <= g_maxplayers; i++)
		{
			if(g_announce_valid[i]){
				zp_colored_print(0, "^x04[ZC]^x01 All^x04 announcements^x01 were removed by^x04 server.")
				set_task(0.1, "removeannounce", i)
			}
		}
		
		// Mode fully started!
		g_modestarted = true
		
		// Round start forward
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_LNJ, 0);
	}
	else if ((mode == MODE_NONE && g_lastmode == MODE_INFECTION && random_num(1, zc_guardians_chance) == zc_guardians_enabled && iPlayersnum >= zc_guardians_min_players &&iPlayersnum >= 2) || mode == MODE_GUARDIANS)
	{
		// Guardians Mode
		g_guardiansround = true
		g_lastmode = MODE_GUARDIANS

		// Show HUD Message
    		set_dhudmessage(54, 132, 216, HUD_EVENT_X, HUD_EVENT_Y, 1, 6.0, 1.0, 0.1, 1.5);
    		show_dhudmessage(0, "Guardians Mode !!!^n The final battle ! Evil power vs. Guardians !");
		
		// iMaxZombies is rounded up, in case there aren't enough players
		iMaxZombies = 2
		iZombies = 0
		
		// Randomly turn iMaxZombies players into Evils
		while (iZombies < iMaxZombies)
		{
			// Keep looping through all players
			if (++id > g_maxplayers) id = 1
			
			// Dead or already a zombie or survivor
			if (!g_isalive[id] || g_zombie[id] || g_hero[id])
				continue;
			
			// Random chance
			if (random_num(0, 1))
			{
				// Turn into a Evil
				zombieme(id, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
				iZombies++
			}
		}

		// Turn the remaining players into Heroes
		for (id = 1; id <= g_maxplayers; id++)
		{
			if (!is_user_valid_connected(id) || !g_isalive[id] || g_zombie[id] || g_hero[id] || g_heronum == 5) continue;
			switch(id)
			{
				case 1..32:
				{
					switch(random_num(1, 5))
					{
						case 1:
						{
							if (!is_user_valid_connected(id) || !g_isalive[id] || g_zombie[id] || g_hero[id])
								continue;

							// Turn into Hero
							humanme(id, 0, 0, 0, 0, 0, 1)

							// Give weapons
							give_weapon_guillotine(id)
						}
						case 2:
						{
							if (!is_user_valid_connected(id) || !g_isalive[id] || g_zombie[id] || g_hero[id])
								continue;

							// Turn into Hero
							humanme(id, 0, 0, 0, 0, 0, 1)

							// Give weapons
							give_weapon_cannon(id)
						}		
						case 3:
						{
							if (!is_user_valid_connected(id) || !g_isalive[id] || g_zombie[id] || g_hero[id])
								continue;

							// Turn into Hero
							humanme(id, 0, 0, 0, 0, 0, 1)

							// Give weapons
							give_weapon_coilgun(id)
						}
						case 4:
						{
							if (!is_user_valid_connected(id) || !g_isalive[id] || g_zombie[id] || g_hero[id])
								continue;

							// Turn into Hero
							humanme(id, 0, 0, 0, 0, 0, 1)

							// Give weapons
							give_weapon_plasma(id)
						}
					}
				}
			}
		}

		// Turn the remaining players into Humans
		for (id = 1; id <= g_maxplayers; id++)
		{
			if (!is_user_valid_connected(id) || !g_isalive[id] || g_zombie[id] || g_hero[id]) continue;
			humanme(id, 0, 0, 0, 0, 0, 0)
		}
		
		// Play guardians sound
		ArrayGetString(sound_guardians, random_num(0, ArraySize(sound_guardians) - 1), sound, charsmax(sound))
		PlaySound(sound);

		// Remove any announcements
		for(new i = 1; i <= g_maxplayers; i++)
		{
			if(g_announce_valid[i]){
				zp_colored_print(0, "^x04[ZC]^x01 All^x04 announcements^x01 were removed by^x04 server.")
				set_task(0.1, "removeannounce", i)
			}
		}
		
		// Mode fully started!
		g_modestarted = true
		
		// Round start forward
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_GUARDIANS, 0);
	}
	else
	{
		// Choose player randomly?
		if (mode == MODE_NONE)
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		if ((mode == MODE_NONE && g_lastmode == MODE_INFECTION && random_num(1, zc_nem_chance) == zc_nem_enabled && iPlayersnum >= zc_nem_min_players) || mode == MODE_NEMESIS)
		{
			// Nemesis Mode
			g_nemround = true
			g_lastmode = MODE_NEMESIS
			
			// Turn player into nemesis
			zombieme(id, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0)
		}
		else
		{
			// Single Infection Mode
			g_lastmode = MODE_INFECTION
			
			// Turn player into the first zombie
			zombieme(id, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
		}
		
		// Remaining players should be humans (CTs)
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
				continue;
			
			// First zombie/nemesis
			if (g_zombie[id])
				continue;
			
			// Switch to CT
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
			{
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				fm_user_team_update(id)
			}
		}
		
		if (g_nemround)
		{
			
			// Show HUD Message
    			set_dhudmessage(212, 132, 76, HUD_EVENT_X, HUD_EVENT_Y, 1, 6.0, 1.0, 0.1, 1.5);
    			show_dhudmessage(0, "Nemesis Mode !!!^n Could this be the end... ?");

			// Play Nemesis sound
			ArrayGetString(sound_nemesis, random_num(0, ArraySize(sound_nemesis) - 1), sound, charsmax(sound))
			PlaySound(sound);

			// Remove any announcements
			for(new i = 1; i <= g_maxplayers; i++)
			{
				if(g_announce_valid[i]){
					zp_colored_print(0, "^x04[ZC]^x01 All^x04 announcements^x01 were removed by^x04 server.")
					set_task(0.1, "removeannounce", i)
				}
			}
				
			// Mode fully started!
			g_modestarted = true
			
			// Round start forward
			ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_NEMESIS, forward_id);
		}
		else
		{
			// HUD Message
			set_dhudmessage(255, 0, 0, HUD_EVENT_X, HUD_EVENT_Y, 1, 6.0, 1.0, 0.1, 1.5);
    			show_dhudmessage(0, "Infection Mode !!!^n The T-Virus has escaped !!!");
			
			// Mode fully started!
			g_modestarted = true
			
			// Round start forward
			ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_INFECTION, forward_id);
		}
	}
	
	// Start ambience sounds after a mode begins
	if ((g_ambience_sounds[AMBIENCE_SOUNDS_NEMESIS] && g_nemround) || (g_ambience_sounds[AMBIENCE_SOUNDS_SURVIVOR] && g_survround) || (g_ambience_sounds[AMBIENCE_SOUNDS_SWARM] && g_swarmround)
	|| (g_ambience_sounds[AMBIENCE_SOUNDS_PLAGUE] && g_plagueround) || (g_ambience_sounds[AMBIENCE_SOUNDS_INFECTION] && !g_nemround && !g_survround && !g_swarmround && !g_plagueround && !g_sniperround && !g_flamerround && !g_zadocround && !g_genesysround && !g_assassinround && !g_oberonround && !g_dragonround && !g_nighterround && !g_lnjround && !g_guardiansround)
	|| (g_ambience_sounds[AMBIENCE_SOUNDS_SNIPER] && g_sniperround) || (g_ambience_sounds[AMBIENCE_SOUNDS_FLAMER] && g_flamerround) || (g_ambience_sounds[AMBIENCE_SOUNDS_ZADOC] && g_zadocround) || (g_ambience_sounds[AMBIENCE_SOUNDS_GENESYS] && g_genesysround) 
	|| (g_ambience_sounds[AMBIENCE_SOUNDS_ASSASSIN] && g_assassinround) || (g_ambience_sounds[AMBIENCE_SOUNDS_OBERON] && g_oberonround) || (g_ambience_sounds[AMBIENCE_SOUNDS_DRAGON] && g_dragonround) || (g_ambience_sounds[AMBIENCE_SOUNDS_NIGHTER] && g_nighterround) || (g_ambience_sounds[AMBIENCE_SOUNDS_LNJ] && g_lnjround) || (g_ambience_sounds[AMBIENCE_SOUNDS_GUARDIANS] && g_guardiansround))
	{
		remove_task(TASK_AMBIENCESOUNDS)
		set_task(2.0, "ambience_sound_effects", TASK_AMBIENCESOUNDS)
	}
}

public give_assassin_nvision(id)
{
       if (!g_assassin[id] || !g_hadnvision[id]) return

       set_user_nightvision(id, 1)
}

send_infection_effects(id)
{
       message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenShake"), _, id)
       write_short((1<<10) * 45)
       write_short((1<<10) * 4)
       write_short((1<<10) * 35)
       message_end()
}
	
// Zombie Me Function (player id, infector, turn into a nemesis, silent mode, deathmsg and rewards)
zombieme(id, infector, nemesis, silentmode, rewards, assassin, genesys, oberon, dragon, nighter, evil)
{
	// User infect attempt forward
	ExecuteForward(g_fwUserInfect_attempt, g_fwDummyResult, id, infector, nemesis, assassin, genesys, oberon, dragon, nighter, evil)
	
	// One or more plugins blocked the infection. Only allow this after making sure it's
	// not going to leave us with no zombies. Take into account a last player leaving case.
	// BUGFIX: only allow after a mode has started, to prevent blocking first zombie e.g.
	if (g_fwDummyResult >= ZP_PLUGIN_HANDLED && g_modestarted && fnGetZombies() > g_lastplayerleaving)
		return;
	
	// Pre user infect forward
	ExecuteForward(g_fwUserInfected_pre, g_fwDummyResult, id, infector, nemesis, assassin, genesys, oberon, dragon, nighter, evil)
	
	// Show zombie class menu if they haven't chosen any (e.g. just connected)
	if (g_zombieclassnext[id] == ZCLASS_NONE && zc_zombie_classes)
		set_task(0.2, "show_menu_zclass", id)
	
	// Set selected zombie class
	g_zombieclass[id] = g_zombieclassnext[id]
	// If no class selected yet, use the first (default) one
	if (g_zombieclass[id] == ZCLASS_NONE) g_zombieclass[id] = 0
	
	// Way to go...
	g_zombie[id] = true
	g_nemesis[id] = false
	g_assassin[id] = false
	g_oberon[id] = false
	g_dragon[id] = false
	g_nighter[id] = false
	g_nchild[id] = false
	g_evil[id] = false
	g_genesys[id] = false
	g_survivor[id] = false
	g_firstzombie[id] = false
	g_sniper[id] = false
	g_flamer[id] = false
	g_zadoc[id] = false
	g_evil[id] = false

	// Remove aura (bugfix)
	remove_task(id+TASK_AURA)
	
	// Remove spawn protection (bugfix)
	g_nodamage[id] = false
	set_pev(id, pev_effects, pev(id, pev_effects) &~ EF_NODRAW)
	
	// Reset burning duration counter (bugfix)
	g_burning_duration[id] = 0
	
	// Show deathmsg and reward infector?
	if (rewards && infector)
	{
		// Send death notice and fix the "dead" attrib on scoreboard
		SendDeathMsg(infector, id)
		FixDeadAttrib(id)
		
		// Reward frags, deaths, health, ammo packs and XP
		UpdateFrags(infector, id, zc_zombie_frags_for_infect, 1, 1)
		g_ammopacks[infector] += zc_zombie_infect_reward
		fm_set_user_health(infector, pev(infector, pev_health) + zc_zombie_infect_health)

		// Reward coins
		g_coins[infector] += 1

		// Reward XP
		g_infxp[infector] += 1
		if(g_infxp[infector] >= 2 && !g_nighter[infector])
		{
			g_xp[infector] += 1
			g_infxp[infector] = 0
			if(g_level[infector] < zc_max_level) {
				levelup(infector)
			}
		}
	}
	
	// Cache speed, knockback, and name for player's class
	g_zombie_spd[id] = float(ArrayGetCell(g_zclass_spd, g_zombieclass[id]))+(speed_l[id]*zc_powers_speed_rate)
	g_zombie_knockback[id] = Float:ArrayGetCell(g_zclass_kb, g_zombieclass[id])
	ArrayGetString(g_zclass_name, g_zombieclass[id], g_zombie_classname[id], charsmax(g_zombie_classname[]))
	
	// Set zombie attributes based on the mode
	static sound[64]
	if (!silentmode)
	{
		if (nemesis)
		{
			// Remove Genesys Power
			if(get_user_noclip(id)) set_user_noclip(id, 0)

			// Remove Nighter Power
			if(g_nighter[id]) NighterRemovePower(id)

			// Nemesis
			g_nemesis[id] = true
			
			// Set health [0 = auto]
			if (zc_nem_health == 0)
			{
				if (zc_nem_base_health == 0)
					fm_set_user_health(id, ArrayGetCell(g_zclass_hp, 0) * fnGetAlive())
				else
					fm_set_user_health(id, zc_nem_base_health * fnGetAlive())
			}
			else
				fm_set_user_health(id, zc_nem_health)
			
			// Set gravity, unless frozen
			if (!g_frozen[id]) set_pev(id, pev_gravity, zc_nem_gravity)
		}
		
		else if (assassin)
		{
			// Remove Genesys Power
			if(get_user_noclip(id)) set_user_noclip(id, 0)

			// Remove Nighter Power
			if(g_nighter[id]) NighterRemovePower(id)

			// Assassin
			g_assassin[id] = true

			// Set health [0 = auto]
			if (zc_assassin_health == 0)
			{
				if (zc_assassin_base_health == 0)
					fm_set_user_health(id, ArrayGetCell(g_zclass_hp, 0) * fnGetAlive())
				else
					fm_set_user_health(id, zc_assassin_base_health * fnGetAlive())
			}
			else
				fm_set_user_health(id, zc_assassin_health)
			
			// Set gravity, unless frozen
			if (!g_frozen[id]) set_pev(id, pev_gravity, zc_assassin_gravity)
		}

		else if (genesys)
		{
			// Remove Nighter Power
			if(g_nighter[id]) NighterRemovePower(id)

			// Genesys
			g_genesys[id] = true

			// Set Genesys powers
			set_user_noclip(id, 1)
			fm_set_user_health(id, zc_genesys_health)

			// Show info Messages
			zp_colored_print(id, "^x04[ZC]^x01 Press^x03 Z^x01 [^x04 bind Z radio1^x01] to throw^x04 Flames !")
			zp_colored_print(id, "^x04[ZC]^x01 Press^x03 X^x01 [^x04 bind X radio2^x01] to create^x04 Locusts !")
		}
		else if (oberon)
		{
			// Remove Genesys Power
			if(get_user_noclip(id)) set_user_noclip(id, 0)

			// Remove Nighter Power
			if(g_nighter[id]) NighterRemovePower(id)

			// Oberon
			g_oberon[id] = true

			// Show info Messages
			zp_colored_print(id, "^x04[ZC]^x01 Press^x03 Z^x01 [^x04 bind Z radio1^x01] to throw^x04 Bombs !")
			zp_colored_print(id, "^x04[ZC]^x01 Press^x03 X^x01 [^x04 bind X radio2^x01] to create^x04 Black-Holes !")

			// Set health [0 = auto]
			if (zc_oberon_health == 0)
			{
				if (zc_oberon_base_health == 0)
					fm_set_user_health(id, ArrayGetCell(g_zclass_hp, 0) * fnGetAlive())
				else
					fm_set_user_health(id, zc_oberon_base_health * fnGetAlive())
			}
			else
				fm_set_user_health(id, zc_oberon_health)

			// Set gravity, unless frozen
			if (!g_frozen[id]) set_pev(id, pev_gravity, zc_oberon_gravity)
		}
		else if (dragon)
		{
			// Remove Genesys Power
			if(get_user_noclip(id)) set_user_noclip(id, 0)

			// Remove Nighter Power
			if(g_nighter[id]) NighterRemovePower(id)

			// Dragon
			g_dragon[id] = true

			// Show info Messages
			zp_colored_print(id, "^x04[ZC]^x01 Press^x03 Z^x01 [^x04 bind Z radio1^x01] to throw^x04 frost air !")
			zp_colored_print(id, "^x04[ZC]^x01 Hold^x03 SPACE^x01 to be able to fly !")

			// Set health [0 = auto]
			if (zc_dragon_health == 0)
			{
				if (zc_dragon_base_health == 0)
					fm_set_user_health(id, ArrayGetCell(g_zclass_hp, 0) * fnGetAlive())
				else
					fm_set_user_health(id, zc_dragon_base_health * fnGetAlive())
			}
			else
				fm_set_user_health(id, zc_dragon_health)
		}
		else if (nighter == 1)
		{
			// Remove Genesys Power
			if(get_user_noclip(id)) set_user_noclip(id, 0)

			// Nighter
			g_nighter[id] = true
			nighterindex = id

			// Start HUD
			set_task(1.0, "NighterChildsHUD", TASK_NCHILDS_SHOW, _, _, "b")

			// Show info Messages
			zp_colored_print(id, "^x04[ZC]^x01 Press^x03 Z^x01 [^x04 bind Z radio1^x01] to ^x04 teleport !")		

			// Set Nighter Power
			NighterSetPower(id)

			// Set health [0 = auto]
			if (zc_nighter_health == 0)
			{
				if (zc_nighter_base_health == 0)
					fm_set_user_health(id, ArrayGetCell(g_zclass_hp, 0) * fnGetAlive())
				else
					fm_set_user_health(id, zc_nighter_base_health * fnGetAlive())
			}
			else
				fm_set_user_health(id, zc_nighter_health)
		}
		else if (nighter == 2)
		{
			// Remove Nighter Power
			if(g_nighter[id]) NighterRemovePower(id)

			// Check for last human
			if(fnGetHumans() == 1 && g_nighter[nighterindex])
			{
				zombieme(nighterindex, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0)
				g_nighter[nighterindex] = false
			}

			// Nighter Child
			g_nchild[id] = true	
		
			// Show info Messages
			zp_colored_print(id, "^x04[ZC]^x01 You are now one of the Nighter's children.")

			// Remove Genesys Powers
			if(get_user_noclip(id)) set_user_noclip(id, 0)

			// Set Nighter Child Health
			fm_set_user_health(id, zc_nchild_health)
		}
		else if (evil)
		{
			// Remove Genesys Power
			if(get_user_noclip(id)) set_user_noclip(id, 0)

			// Nighter
			g_evil[id] = true

			// Set Evil Health
			fm_set_user_health(id, zc_evil_health)

			// Show HUD
			set_task(1.0, "EvolveHUD", id+TASK_EVIL_SHOW, _, _, "b")

			// Give first Smoke
			give_item(id, "weapon_flashbang")
			cs_set_user_bpammo(id, CSW_FLASHBANG, 1)
		}
		else if ((fnGetZombies() == 1) && !g_assassin[id] && !g_oberon[id] && !g_dragon[id] && !g_nighter[id] && !g_nchild[id] && !g_genesys[id] && !g_nemesis[id] && !g_evil[id])
		{
			// Remove Genesys Power
			if(get_user_noclip(id)) set_user_noclip(id, 0)

			// Remove Nighter Power
			if(g_nighter[id]) NighterRemovePower(id)

			// First zombie
			g_firstzombie[id] = true
			
			// Set health and gravity, unless frozen
			fm_set_user_health(id, floatround(float(ArrayGetCell(g_zclass_hp, g_zombieclass[id])) * zc_zombie_first_hp))
			if (!g_frozen[id]) set_pev(id, pev_gravity, Float:ArrayGetCell(g_zclass_grav, g_zombieclass[id]))
			
			// Infection sound
			if (!g_assassin[id] && !g_oberon[id] && !g_dragon[id] && !g_nighter[id] && !g_nchild[id] && !g_evil[id] && !g_genesys[id] && !g_nemesis[id])
			{
				ArrayGetString(zombie_infect, random_num(0, ArraySize(zombie_infect) - 1), sound, charsmax(sound))
				emit_sound(id, CHAN_VOICE, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
		}
		else
		{
			// Remove Genesys Power
			if(get_user_noclip(id)) set_user_noclip(id, 0)

			// Remove Nighter Power
			if(g_nighter[id]) NighterRemovePower(id)

			// Infected by someone
			
			// Set health and gravity, unless frozen
			fm_set_user_health(id, ArrayGetCell(g_zclass_hp, g_zombieclass[id]))
			if (!g_frozen[id]) set_pev(id, pev_gravity, Float:ArrayGetCell(g_zclass_grav, g_zombieclass[id]))
			
			// Infection sound
			if (!g_assassin[id] && !g_nemesis[id] && !g_oberon[id] && !g_dragon[id] && !g_nighter[id] && !g_nchild[id] && !g_evil[id] && !g_genesys[id])
			{
				ArrayGetString(zombie_infect, random_num(0, ArraySize(zombie_infect) - 1), sound, charsmax(sound))
				emit_sound(id, CHAN_VOICE, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
		}
	}
	else
	{
		// Silent mode, no HUD messages, no infection sounds
		
		// Set health and gravity, unless frozen
		fm_set_user_health(id, ArrayGetCell(g_zclass_hp, g_zombieclass[id]))
		if (!g_frozen[id]) set_pev(id, pev_gravity, Float:ArrayGetCell(g_zclass_grav, g_zombieclass[id]))
	}
	
	// Remove previous tasks
	remove_task(id+TASK_MODEL)
	remove_task(id+TASK_BLOOD)
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_BURN)
	
	// Switch to T
	if (fm_cs_get_user_team(id) != FM_CS_TEAM_T) // need to change team?
	{
		remove_task(id+TASK_TEAM)
		fm_cs_set_user_team(id, FM_CS_TEAM_T)
		fm_user_team_update(id)
	}
	
	// Custom models stuff
	static currentmodel[32], tempmodel[32], already_has_model, i, iRand, size
	already_has_model = false
	
	if (g_handle_models_on_separate_ent)
	{
		// Set the right model
		if (g_nemesis[id])
		{
			iRand = random_num(0, ArraySize(model_nemesis) - 1)
			ArrayGetString(model_nemesis, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_nemesis, iRand))
		}
		if (g_assassin[id])
		{
			iRand = random_num(0, ArraySize(model_assassin) - 1)
			ArrayGetString(model_assassin, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_assassin, iRand))
		}
		if (g_oberon[id])
		{
			iRand = random_num(0, ArraySize(model_oberon) - 1)
			ArrayGetString(model_oberon, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_oberon, iRand))
		}
		if (g_dragon[id])
		{
			iRand = random_num(0, ArraySize(model_dragon) - 1)
			ArrayGetString(model_dragon, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_dragon, iRand))
		}
		if (g_nighter[id])
		{
			iRand = random_num(0, ArraySize(model_nighter) - 1)
			ArrayGetString(model_nighter, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_nighter, iRand))
		}
		if (g_nchild[id])
		{
			iRand = random_num(0, ArraySize(model_nchild) - 1)
			ArrayGetString(model_nchild, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_nchild, iRand))
		}
		if (g_evil[id])
		{
			iRand = random_num(0, ArraySize(model_evil) - 1)
			ArrayGetString(model_evil, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_evil, iRand))
		}
		if (g_genesys[id])
		{
			iRand = random_num(0, ArraySize(model_genesys) - 1)
			ArrayGetString(model_genesys, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_genesys, iRand))
		}
		if (!g_assassin[id] && !g_nemesis[id] && !g_genesys[id] && !g_oberon[id] && !g_dragon[id] && !g_nighter[id])
		{
			if (zc_admin_models_zombie && (g_privileges[id] & g_access_flag[ACCESS_ADMIN_MODELS]))
			{
				iRand = random_num(0, ArraySize(model_admin_zombie) - 1)
				ArrayGetString(model_admin_zombie, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_admin_zombie, iRand))
			}
			else
			{
				iRand = random_num(ArrayGetCell(g_zclass_modelsstart, g_zombieclass[id]), ArrayGetCell(g_zclass_modelsend, g_zombieclass[id]) - 1)
				ArrayGetString(g_zclass_playermodel, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_zclass_modelindex, iRand))
			}
		}
		
		// Set model on player model entity
		fm_set_playermodel_ent(id)
		
		// Nemesis glow / remove glow on player model entity, unless frozen
		if (!g_frozen[id])
		{
			if (g_nemesis[id] && zc_nem_glow && !g_lnjround)
				fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 250, 0 , 0, kRenderNormal, 25)
			else if (g_nemesis[id] && !(zc_nem_glow))
				fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 0, 0 , 0, kRenderNormal, 25)
				
			else if (g_assassin[id] && zc_assassin_glow)
				fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 250, 0 , 0, kRenderNormal, 25)
			else if (g_assassin[id] && !(zc_assassin_glow))
				fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 0, 0 , 0, kRenderNormal, 25)

			else if (g_oberon[id] && zc_oberon_glow)
				fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 250, 0 , 0, kRenderNormal, 25)
			else if (g_oberon[id] && !(zc_oberon_glow))
				fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 0, 0 , 0, kRenderNormal, 25)

			else if (g_dragon[id] && zc_dragon_glow)
				fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 250, 0 , 0, kRenderNormal, 25)
			else if (g_dragon[id] && !(zc_dragon_glow))
				fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 0, 0 , 0, kRenderNormal, 25)
				
			else if (!g_assassin[id] && !g_nemesis[id] && !g_oberon[id] && !g_dragon[id] && !g_nighter[id] && !g_nchild[id] && !g_evil[id])
				fm_set_rendering(g_ent_playermodel[id])
		}
	}
	else
	{
		// Get current model for comparing it with the current one
		fm_cs_get_user_model(id, currentmodel, charsmax(currentmodel))
		
		// Set the right model, after checking that we don't already have it
		if (g_nemesis[id])
		{
			size = ArraySize(model_nemesis)
			for (i = 0; i < size; i++)
			{
				ArrayGetString(model_nemesis, i, tempmodel, charsmax(tempmodel))
				if (equal(currentmodel, tempmodel)) already_has_model = true
			}
			
			if (!already_has_model)
			{
				iRand = random_num(0, size - 1)
				ArrayGetString(model_nemesis, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_nemesis, iRand))
			}
		}
		
		if (g_assassin[id])
		{
			size = ArraySize(model_assassin)
			for (i = 0; i < size; i++)
			{
				ArrayGetString(model_assassin, i, tempmodel, charsmax(tempmodel))
				if (equal(currentmodel, tempmodel)) already_has_model = true
			}
			
			if (!already_has_model)
			{
				iRand = random_num(0, size - 1)
				ArrayGetString(model_assassin, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_assassin, iRand))
			}
		}

		if (g_oberon[id])
		{
			size = ArraySize(model_oberon)
			for (i = 0; i < size; i++)
			{
				ArrayGetString(model_oberon, i, tempmodel, charsmax(tempmodel))
				if (equal(currentmodel, tempmodel)) already_has_model = true
			}
			
			if (!already_has_model)
			{
				iRand = random_num(0, size - 1)
				ArrayGetString(model_oberon, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_oberon, iRand))
			}
		}

		if (g_dragon[id])
		{
			size = ArraySize(model_dragon)
			for (i = 0; i < size; i++)
			{
				ArrayGetString(model_dragon, i, tempmodel, charsmax(tempmodel))
				if (equal(currentmodel, tempmodel)) already_has_model = true
			}
			
			if (!already_has_model)
			{
				iRand = random_num(0, size - 1)
				ArrayGetString(model_dragon, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_dragon, iRand))
			}
		}

		if (g_nighter[id])
		{
			size = ArraySize(model_nighter)
			for (i = 0; i < size; i++)
			{
				ArrayGetString(model_nighter, i, tempmodel, charsmax(tempmodel))
				if (equal(currentmodel, tempmodel)) already_has_model = true
			}
			
			if (!already_has_model)
			{
				iRand = random_num(0, size - 1)
				ArrayGetString(model_nighter, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_nighter, iRand))
			}
		}

		if (g_nchild[id])
		{
			size = ArraySize(model_nchild)
			for (i = 0; i < size; i++)
			{
				ArrayGetString(model_nchild, i, tempmodel, charsmax(tempmodel))
				if (equal(currentmodel, tempmodel)) already_has_model = true
			}
			
			if (!already_has_model)
			{
				iRand = random_num(0, size - 1)
				ArrayGetString(model_nchild, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_nchild, iRand))
			}
		}

		if (g_evil[id])
		{
			size = ArraySize(model_evil)
			for (i = 0; i < size; i++)
			{
				ArrayGetString(model_evil, i, tempmodel, charsmax(tempmodel))
				if (equal(currentmodel, tempmodel)) already_has_model = true
			}
			
			if (!already_has_model)
			{
				iRand = random_num(0, size - 1)
				ArrayGetString(model_evil, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_evil, iRand))
			}
		}

		if (g_genesys[id])
		{
			size = ArraySize(model_genesys)
			for (i = 0; i < size; i++)
			{
				ArrayGetString(model_genesys, i, tempmodel, charsmax(tempmodel))
				if (equal(currentmodel, tempmodel)) already_has_model = true
			}
			
			if (!already_has_model)
			{
				iRand = random_num(0, size - 1)
				ArrayGetString(model_genesys, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_genesys, iRand))
			}
		}
		
		if (!g_assassin[id] && !g_nemesis[id] && !g_genesys[id] && !g_oberon[id] && !g_dragon[id] && !g_nighter[id] && !g_nchild[id] && !g_evil[id])
		{
			if (zc_admin_models_zombie && (g_privileges[id] & g_access_flag[ACCESS_ADMIN_MODELS]))
			{
				size = ArraySize(model_admin_zombie)
				for (i = 0; i < size; i++)
				{
					ArrayGetString(model_admin_zombie, i, tempmodel, charsmax(tempmodel))
					if (equal(currentmodel, tempmodel)) already_has_model = true
				}
				
				if (!already_has_model)
				{
					iRand = random_num(0, size - 1)
					ArrayGetString(model_admin_zombie, iRand, g_playermodel[id], charsmax(g_playermodel[]))
					if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_admin_zombie, iRand))
				}
			}
			else
			{
				for (i = ArrayGetCell(g_zclass_modelsstart, g_zombieclass[id]); i < ArrayGetCell(g_zclass_modelsend, g_zombieclass[id]); i++)
				{
					ArrayGetString(g_zclass_playermodel, i, tempmodel, charsmax(tempmodel))
					if (equal(currentmodel, tempmodel)) already_has_model = true
				}
				
				if (!already_has_model)
				{
					iRand = random_num(ArrayGetCell(g_zclass_modelsstart, g_zombieclass[id]), ArrayGetCell(g_zclass_modelsend, g_zombieclass[id]) - 1)
					ArrayGetString(g_zclass_playermodel, iRand, g_playermodel[id], charsmax(g_playermodel[]))
					if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_zclass_modelindex, iRand))
				}
			}
		}
		
		// Need to change the model?
		if (!already_has_model)
		{
			// An additional delay is offset at round start
			// since SVC_BAD is more likely to be triggered there
			if (g_newround)
				set_task(5.0 * g_modelchange_delay, "fm_user_model_update", id+TASK_MODEL)
			else
				fm_user_model_update(id+TASK_MODEL)
		}
		
		// Nemesis, Assassin, Oberon, Dragon, Nighter glow / remove glow, unless frozen
		if (!g_frozen[id])
		{
			if (g_nemesis[id] && zc_nem_glow && !g_lnjround)
				fm_set_rendering(id, kRenderFxGlowShell, 250, 0, 0, kRenderNormal, 25)
			else if (g_nemesis[id] && !(zc_nem_glow))
				fm_set_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)
				
			else if (g_assassin[id] && zc_assassin_glow)
				fm_set_rendering(id, kRenderFxGlowShell, 250, 0, 0, kRenderNormal, 25)
			else if (g_assassin[id] && !(zc_assassin_glow))
				fm_set_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)

			else if (g_oberon[id] && zc_oberon_glow)
				fm_set_rendering(id, kRenderFxGlowShell, 250, 0, 0, kRenderNormal, 25)
			else if (g_oberon[id] && !(zc_oberon_glow))
				fm_set_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)

			else if (g_dragon[id] && zc_dragon_glow)
				fm_set_rendering(id, kRenderFxGlowShell, 250, 0, 0, kRenderNormal, 25)
			else if (g_dragon[id] && !(zc_dragon_glow))
				fm_set_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)
				
			else if (!g_assassin[id] && !g_nemesis[id] && !g_oberon[id] && !g_dragon[id] && !g_nighter[id] && !g_nchild[id] && !g_evil[id])
				fm_set_rendering(id)
		}
	}
	
	// Remove any zoom (bugfix)
	cs_set_user_zoom(id, CS_RESET_ZOOM, 1)
	
	// Remove armor
	set_pev(id, pev_armorvalue, 0.0)
	
	// Drop weapons when infected
	drop_weapons(id, 1)
	drop_weapons(id, 2)
	
	// Strip zombies from guns and give them a knife
	fm_strip_user_weapons(id)
	fm_give_item(id, "weapon_knife")
	
	// Fancy effects
	infection_effects(id)
	
	// Nemesis aura task
	if (g_nemesis[id] && zc_nem_aura && !g_lnjround)
		set_task(0.1, "zombie_aura", id+TASK_AURA, _, _, "b")
		
	// Assassin aura task
	if (g_assassin[id] && zc_assassin_aura)
		set_task(0.1, "zombie_aura", id+TASK_AURA, _, _, "b")

	// Oberon aura task
	if (g_oberon[id] && zc_oberon_aura)
		set_task(0.1, "zombie_aura", id+TASK_AURA, _, _, "b")

	// Dragon aura task
	if (g_dragon[id] && zc_dragon_aura)
		set_task(0.1, "zombie_aura", id+TASK_AURA, _, _, "b")
	
	// Give Zombies Night Vision?
	if (zc_nvg_give)
	{
		g_hadnvision[id] = true
                if (g_assassinround) set_task(0.1, "give_assassin_nvision", id)
		//set_user_nightvision(id, 1)
	}
	// Disable nightvision when infected (bugfix)
	else if (g_usingnvision[id])
	{
		g_hadnvision[id] = false
		set_user_nightvision(id, 0)
	}

	// Remove Custom NVision
	if(g_hascnvision[id])
	{
		remove_task(id+TASK_CNVISION)
		activate_nv[id] = false
		g_hascnvision[id] = false
	}
	
	// Set custom FOV?
	if (zc_zombie_fov != 90 && zc_zombie_fov != 0)
	{
		message_begin(MSG_ONE, g_msgSetFOV, _, id)
		write_byte(zc_zombie_fov) // fov angle
		message_end()
	}

        send_infection_effects(id)
	
	// Idle sounds task
	if (!g_nemesis[id] && !g_assassin[id] && !g_oberon[id] && !g_dragon[id] && !g_nighter[id] && !g_nchild[id] && !g_evil[id] && !g_genesys[id])
		set_task(random_float(50.0, 70.0), "zombie_play_idle", id+TASK_BLOOD, _, _, "b")
	
	// Turn off zombie's flashlight
	turn_off_flashlight(id)
	
	// Post user infect forward
	ExecuteForward(g_fwUserInfected_post, g_fwDummyResult, id, infector, nemesis, assassin, genesys, oberon, dragon, nighter, evil)

	// VIP
	setVip()
	
	// Last Zombie Check
	fnCheckLastZombie()	
}

// Function Human Me (player id, turn into a survivor, silent mode)
humanme(id, survivor, silentmode, sniper, flamer, zadoc, hero)
{
	// User humanize attempt forward
	ExecuteForward(g_fwUserHumanize_attempt, g_fwDummyResult, id, survivor, sniper, flamer, zadoc, hero)
	
	// One or more plugins blocked the "humanization". Only allow this after making sure it's
	// not going to leave us with no humans. Take into account a last player leaving case.
	// BUGFIX: only allow after a mode has started, to prevent blocking first survivor e.g.
	if (g_fwDummyResult >= ZP_PLUGIN_HANDLED && g_modestarted && fnGetHumans() > g_lastplayerleaving)
		return;
	
	// Pre user humanize forward
	ExecuteForward(g_fwUserHumanized_pre, g_fwDummyResult, id, survivor, sniper, flamer, zadoc, hero)
	
	// Remove previous tasks
	remove_task(id+TASK_MODEL)
	remove_task(id+TASK_BLOOD)
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_BURN)

        // Show human class menu if they haven't chosen any (e.g. just connected)
	if (g_humanclassnext[id] == HCLASS_NONE && zc_human_classes)
		set_task(0.2, "show_menu_hclass", id)
	
	// Set selected human class
	g_humanclass[id] = g_humanclassnext[id]
	// If no class selected yet, use the first (default) one
	if (g_humanclass[id] == HCLASS_NONE) g_humanclass[id] = 0
	
	// Reset some vars
	g_usingnvision[id] = false
	g_zombie[id] = false
	g_nemesis[id] = false
	g_survivor[id] = false
	g_firstzombie[id] = false
	g_canbuy[id] = true
	g_hadnvision[id] = false
	g_sniper[id] = false
	g_flamer[id] = false
	g_zadoc[id] = false
	g_hero[id] = false
	g_assassin[id] = false
	g_oberon[id] = false
	g_dragon[id] = false
	g_nighter[id] = false
	g_nchild[id] = false
	g_evil[id] = false
	g_genesys[id] = false
	
	// Remove survivor/sniper's aura (bugfix)
	remove_task(id+TASK_AURA)
	
	// Remove spawn protection (bugfix)
	g_nodamage[id] = false
	set_pev(id, pev_effects, pev(id, pev_effects) &~ EF_NODRAW)
	
	// Reset burning duration counter (bugfix)
	g_burning_duration[id] = 0

        // Cache speed, and name for player's class
	g_human_spd[id] = float(ArrayGetCell(g_hclass_spd, g_humanclass[id]))+(speed_l[id]*zc_powers_speed_rate)	
	ArrayGetString(g_hclass_name, g_humanclass[id], g_human_classname[id], charsmax(g_human_classname[]))
	
	// Drop previous weapons
	drop_weapons(id, 1)
	drop_weapons(id, 2)
	
	// Strip off from weapons
	fm_strip_user_weapons(id)
	fm_give_item(id, "weapon_knife")

	// Set human attributes based on the mode
	if (flamer)
	{
		// Flamer
		g_flamer[id] = true

		// Give flamer his own weapon
		give_item(id, "weapon_m249")
		set_user_health(id, zc_flamer_health)
		g_had_salamander[id] = true
		is_reloading[id] = false
		is_firing[id] = true
		can_fire[id] = true
		g_ammo[id] = 19900

		// Set gravity, unless frozen
		if (!g_frozen[id]) set_pev(id, pev_gravity, zc_flamer_gravity)

		// Turn off his flashlight
		turn_off_flashlight(id)
		
		// Give the flamer a nice aura
		if (zc_flamer_aura)
			set_task(0.1, "human_aura", id+TASK_AURA, _, _, "b")
	}
	else if (zadoc)
	{
		// Zadoc
		g_zadoc[id] = true

		// Remove flamer powers
		g_had_salamander[id] = false
		is_firing[id] = false
		can_fire[id] = false
	
		// Show messages
		zp_colored_print(id, "^x04[ZC]^x01 Hit^x04 wall/floor^x03 1 time^x01, to throw away zombie around you !")

		// Give zadoc his own weapon
		give_item(id, "weapon_deagle")
		set_user_health(id, zc_zadoc_health)

		// Set gravity, unless frozen
		if (!g_frozen[id]) set_pev(id, pev_gravity, zc_zadoc_gravity)

		// Turn off his flashlight
		turn_off_flashlight(id)
		
		// Give the zadoc a nice aura
		if (zc_zadoc_aura)
			set_task(0.1, "human_aura", id+TASK_AURA, _, _, "b")
	}
	else if (survivor)
	{
		// Survivor
		g_survivor[id] = true

		// Remove flamer powers
		g_had_salamander[id] = false
		is_firing[id] = false
		can_fire[id] = false
		
		// Set Health [0 = auto]
		if (zc_surv_health == 0)
		{
			if (zc_surv_base_health == 0)
				fm_set_user_health(id, ArrayGetCell(g_hclass_hp, 0) * fnGetAlive())
			else
				fm_set_user_health(id, zc_surv_base_health * fnGetAlive())
		}
		else
			fm_set_user_health(id, zc_surv_health)
		
		// Set gravity, unless frozen
		if (!g_frozen[id]) set_pev(id, pev_gravity, zc_surv_gravity)
		
		// Give survivor his own weapon
		fm_give_item(id, "weapon_xm1014")
		ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[cs_weapon_name_to_id("weapon_xm1014")], AMMOTYPE[cs_weapon_name_to_id("weapon_xm1014")], MAXBPAMMO[cs_weapon_name_to_id("weapon_xm1014")])
		
		// Turn off his flashlight
		turn_off_flashlight(id)
		
		// Give the survivor a nice aura
		if (zc_surv_aura && !g_lnjround)
			set_task(0.1, "human_aura", id+TASK_AURA, _, _, "b")
	}
	else if (sniper)
	{
		// Sniper
		g_sniper[id] = true
		g_had_salamander[id] = false
		is_firing[id] = false
		can_fire[id] = false
		
		// Set Health [0 = auto]
		if (zc_sniper_health == 0)
		{
			if (zc_sniper_base_health == 0)
				fm_set_user_health(id, ArrayGetCell(g_hclass_hp, 0) * fnGetAlive())
			else
				fm_set_user_health(id, zc_sniper_base_health * fnGetAlive())
		}
		else
			fm_set_user_health(id, zc_sniper_health)
		
		// Set gravity, unless frozen
		if (!g_frozen[id]) set_pev(id, pev_gravity, zc_sniper_gravity)
		
		// Give sniper his own weapon and fill the ammo
		fm_give_item(id, "weapon_awp")
		ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[CSW_AWP], AMMOTYPE[CSW_AWP], MAXBPAMMO[CSW_AWP])
		
		// Turn off his flashlight
		turn_off_flashlight(id)
		
		// Give the sniper a nice aura
		if (zc_sniper_aura)
			set_task(0.1, "human_aura", id+TASK_AURA, _, _, "b")
	}
	else if (hero)
	{
		// Hero
		g_hero[id] = true

		// Count
		g_heronum++

		// Remove flamer powers
		g_had_salamander[id] = false
		is_firing[id] = false
		can_fire[id] = false
	
		// Show messages
		zp_colored_print(id, "^x04[ZC]^x01 You are now a^x04 Hero^x01. Use your powerfull guns to kill the^x03 Big Evil^x01.")

		// Give zadoc his own weapon
		give_item(id, "weapon_deagle")
		set_user_health(id, zc_hero_health)

		// Set gravity, unless frozen
		if (!g_frozen[id]) set_pev(id, pev_gravity, zc_hero_gravity)

		// Turn off his flashlight
		turn_off_flashlight(id)
	}
	else
	{
		// Human taking an antidote
		g_had_salamander[id] = false
		is_firing[id] = false
		can_fire[id] = false
		
                // Set health and gravity, unless frozen
		fm_set_user_health(id, ArrayGetCell(g_hclass_hp, g_humanclass[id]) + hp_l[id]*zc_powers_hp_rate)
                set_task(2.0, "armpwr", id)
		if (!g_frozen[id]) set_pev(id, pev_gravity, Float:ArrayGetCell(g_hclass_grav, g_humanclass[id]))
		
		// Show custom buy menu?
		if (zc_buy_custom)
			set_task(0.2, "show_menu_buy1", id+TASK_SPAWN)
		
		// Silent mode = no HUD messages, no antidote sound
		if (!silentmode)
		{
			// Antidote sound
			static sound[64]
			ArrayGetString(sound_antidote, random_num(0, ArraySize(sound_antidote) - 1), sound, charsmax(sound))
			emit_sound(id, CHAN_ITEM, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
	}
	
	// Switch to CT
	if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
	{
		remove_task(id+TASK_TEAM)
		fm_cs_set_user_team(id, FM_CS_TEAM_CT)
		fm_user_team_update(id)
	}
	
	// Custom models stuff
	static currentmodel[32], tempmodel[32], already_has_model, i, iRand, size
	already_has_model = false
	
	if (g_handle_models_on_separate_ent)
	{
		// Set the right model
		if (g_survivor[id])
		{
			iRand = random_num(0, ArraySize(model_survivor) - 1)
			ArrayGetString(model_survivor, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_survivor, iRand))
		}
		if (g_sniper[id])
		{
			iRand = random_num(0, ArraySize(model_sniper) - 1)
			ArrayGetString(model_sniper, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_sniper, iRand))
		}
		if (g_flamer[id])
		{
			iRand = random_num(0, ArraySize(model_flamer) - 1)
			ArrayGetString(model_flamer, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_flamer, iRand))
		}
		if (g_zadoc[id])
		{
			iRand = random_num(0, ArraySize(model_zadoc) - 1)
			ArrayGetString(model_zadoc, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_zadoc, iRand))
		}
		if (g_hero[id])
		{
			iRand = random_num(0, ArraySize(model_hero) - 1)
			ArrayGetString(model_hero, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_hero, iRand))
		}
		if (!g_survivor[id] && !g_sniper[id] && !g_flamer[id] && !g_zadoc[id] && !g_hero[id])
		{
			if (zc_admin_models_human && ((g_privileges[id] & g_access_flag[ACCESS_ADMIN_MODELS]) || (g_user_privileges[id] & FLAG_D)))
			{
				if ((g_user_privileges[id] & FLAG_D))
				{
					iRand = random_num(0, ArraySize(model_vip_human) - 1)
					ArrayGetString(model_vip_human, iRand, g_playermodel[id], charsmax(g_playermodel[]))
					if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_admin_human, iRand))
				}
				else if((g_privileges[id] & g_access_flag[ACCESS_ADMIN_MODELS]))
				{
					iRand = random_num(0, ArraySize(model_admin_human) - 1)
					ArrayGetString(model_admin_human, iRand, g_playermodel[id], charsmax(g_playermodel[]))
					if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_admin_human, iRand))
				}
			}
			else
			{
				iRand = random_num(ArrayGetCell(g_hclass_modelsstart, g_humanclass[id]), ArrayGetCell(g_hclass_modelsend, g_humanclass[id]) - 1)
				ArrayGetString(g_hclass_playermodel, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_hclass_modelindex, iRand))
			}
		}
		
		// Set model on player model entity
		fm_set_playermodel_ent(id)
		
		// Set survivor glow / remove glow on player model entity, unless frozen
		if (!g_frozen[id])
		{
			if (g_survivor[id] && zc_surv_glow && !g_lnjround) 
				fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 0, 250, 250, kRenderNormal, 25)
			else if (g_survivor[id] && !(zc_surv_glow)) 
				fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)
				
			else if (g_sniper[id] && zc_sniper_glow)
				fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, zc_sniper_aura_color_r, zc_sniper_aura_color_g, zc_sniper_aura_color_b, kRenderNormal, 25)
			else if (g_sniper[id] && !(zc_sniper_glow))
				fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)

			else if (g_flamer[id] && zc_flamer_glow)
				fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, zc_flamer_aura_color_r, zc_flamer_aura_color_g, zc_flamer_aura_color_b, kRenderNormal, 25)
			else if (g_flamer[id] && !(zc_flamer_glow))
				fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)


			else if (g_zadoc[id] && zc_zadoc_glow)
				fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, zc_zadoc_aura_color_r, zc_zadoc_aura_color_g, zc_zadoc_aura_color_b, kRenderNormal, 25)
			else if (g_zadoc[id] && !(zc_zadoc_glow))
				fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)
			
			else if (!g_flamer[id] && !g_sniper[id] && !g_survivor[id] && !g_zadoc[id])
				fm_set_rendering(g_ent_playermodel[id])
		}
	}
	else
	{
		// Get current model for comparing it with the current one
		fm_cs_get_user_model(id, currentmodel, charsmax(currentmodel))
		
		// Set the right model, after checking that we don't already have it
		if (g_survivor[id])
		{
			size = ArraySize(model_survivor)
			for (i = 0; i < size; i++)
			{
				ArrayGetString(model_survivor, i, tempmodel, charsmax(tempmodel))
				if (equal(currentmodel, tempmodel)) already_has_model = true
			}
			
			if (!already_has_model)
			{
				iRand = random_num(0, size - 1)
				ArrayGetString(model_survivor, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_survivor, iRand))
			}
		}
		if (g_sniper[id])
		{
			size = ArraySize(model_sniper)
			for (i = 0; i < size; i++)
			{
				ArrayGetString(model_sniper, i, tempmodel, charsmax(tempmodel))
				if (equal(currentmodel, tempmodel)) already_has_model = true
			}
			
			if (!already_has_model)
			{
				iRand = random_num(0, size - 1)
				ArrayGetString(model_sniper, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_sniper, iRand))
			}
		}
		if (g_flamer[id])
		{
			size = ArraySize(model_flamer)
			for (i = 0; i < size; i++)
			{
				ArrayGetString(model_flamer, i, tempmodel, charsmax(tempmodel))
				if (equal(currentmodel, tempmodel)) already_has_model = true
			}
			
			if (!already_has_model)
			{
				iRand = random_num(0, size - 1)
				ArrayGetString(model_flamer, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_flamer, iRand))
			}
		}
		if (g_zadoc[id])
		{
			size = ArraySize(model_zadoc)
			for (i = 0; i < size; i++)
			{
				ArrayGetString(model_zadoc, i, tempmodel, charsmax(tempmodel))
				if (equal(currentmodel, tempmodel)) already_has_model = true
			}
			
			if (!already_has_model)
			{
				iRand = random_num(0, size - 1)
				ArrayGetString(model_zadoc, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_zadoc, iRand))
			}
		}
		if (g_hero[id])
		{
			size = ArraySize(model_hero)
			for (i = 0; i < size; i++)
			{
				ArrayGetString(model_hero, i, tempmodel, charsmax(tempmodel))
				if (equal(currentmodel, tempmodel)) already_has_model = true
			}
			
			if (!already_has_model)
			{
				iRand = random_num(0, size - 1)
				ArrayGetString(model_hero, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_hero, iRand))
			}
		}
		if (!g_survivor[id] && !g_sniper[id] && !g_flamer[id] && !g_zadoc[id] && !g_hero[id])
		{
			if (zc_admin_models_human && ((g_privileges[id] & g_access_flag[ACCESS_ADMIN_MODELS]) || (g_user_privileges[id] & FLAG_D)))
			{
				if ((g_user_privileges[id] & FLAG_D))
				{
					size = ArraySize(model_vip_human)
					for (i = 0; i < size; i++)
					{
						ArrayGetString(model_vip_human, i, tempmodel, charsmax(tempmodel))
						if (equal(currentmodel, tempmodel)) already_has_model = true
					}
					
					if (!already_has_model)
					{
						iRand = random_num(0, size - 1)
						ArrayGetString(model_vip_human, iRand, g_playermodel[id], charsmax(g_playermodel[]))
						if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_admin_human, iRand))
					}
				}
				else if((g_privileges[id] & g_access_flag[ACCESS_ADMIN_MODELS]))
				{
					size = ArraySize(model_admin_human)
					for (i = 0; i < size; i++)
					{
						ArrayGetString(model_admin_human, i, tempmodel, charsmax(tempmodel))
						if (equal(currentmodel, tempmodel)) already_has_model = true
					}
					
					if (!already_has_model)
					{
						iRand = random_num(0, size - 1)
						ArrayGetString(model_admin_human, iRand, g_playermodel[id], charsmax(g_playermodel[]))
						if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_admin_human, iRand))
					}
				}
			}
			else
			{
				for (i = ArrayGetCell(g_hclass_modelsstart, g_humanclass[id]); i < ArrayGetCell(g_hclass_modelsend, g_humanclass[id]); i++)
				{
					ArrayGetString(g_hclass_playermodel, i, tempmodel, charsmax(tempmodel))
					if (equal(currentmodel, tempmodel)) already_has_model = true
				}
				
				if (!already_has_model)
				{
					iRand = random_num(ArrayGetCell(g_hclass_modelsstart, g_humanclass[id]), ArrayGetCell(g_hclass_modelsend, g_humanclass[id]) - 1)
					ArrayGetString(g_hclass_playermodel, iRand, g_playermodel[id], charsmax(g_playermodel[]))
					if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_hclass_modelindex, iRand))
				}
			}
		}
		
		// Need to change the model?
		if (!already_has_model)
		{
			// An additional delay is offset at round start
			// since SVC_BAD is more likely to be triggered there
			if (g_newround)
				set_task(5.0 * g_modelchange_delay, "fm_user_model_update", id+TASK_MODEL)
			else
				fm_user_model_update(id+TASK_MODEL)
		}
		
		// Set survivor glow / remove glow, unless frozen
		if (!g_frozen[id])
		{
			if (g_survivor[id] && zc_surv_glow && !g_lnjround) 
				fm_set_rendering(id, kRenderFxGlowShell, 0, 250, 250, kRenderNormal, 25)
			else if (g_survivor[id] && !(zc_surv_glow)) 
				fm_set_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)
				
			else if (g_sniper[id] && zc_sniper_glow)
				fm_set_rendering(id, kRenderFxGlowShell, zc_sniper_aura_color_r, zc_sniper_aura_color_g, zc_sniper_aura_color_b, kRenderNormal, 25)
			else if (g_sniper[id] && !(zc_sniper_glow))
				fm_set_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)

			else if (g_flamer[id] && zc_flamer_glow)
				fm_set_rendering(id, kRenderFxGlowShell, zc_flamer_aura_color_r, zc_flamer_aura_color_g, zc_flamer_aura_color_b, kRenderNormal, 25)
			else if (g_flamer[id] && !(zc_flamer_glow))
				fm_set_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)

			else if (g_zadoc[id] && zc_zadoc_glow)
				fm_set_rendering(id, kRenderFxGlowShell, zc_zadoc_aura_color_r, zc_zadoc_aura_color_g, zc_zadoc_aura_color_b, kRenderNormal, 25)
			else if (g_zadoc[id] && !(zc_zadoc_glow))
				fm_set_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)
			
			else if (!g_flamer[id] && !g_sniper[id] && !g_survivor[id] && !g_zadoc[id])
				fm_set_rendering(id)
		}
	}
	
	// Restore FOV?
	if (zc_zombie_fov != 90 && zc_zombie_fov != 0)
	{
		message_begin(MSG_ONE, g_msgSetFOV, _, id)
		write_byte(90) // angle
		message_end()
	}
	
	// Disable nightvision
	if (g_isbot[id]) cs_set_user_nvg(id, 0)
	set_user_nightvision(id, 0)

	// Remove Custom NVision
	if(g_hascnvision[id])
	{
		remove_task(id+TASK_CNVISION)
		activate_nv[id] = false
		g_hascnvision[id] = false
	}
	
	// Post user humanize forward
	ExecuteForward(g_fwUserHumanized_post, g_fwDummyResult, id, survivor, sniper, flamer, zadoc, hero)

	// Enable HClasses Params
	ExecuteForward(g_fwHClassParam, g_fwDummyResult, id)

	// If player is VIP, he will get free NightVision
	if (g_user_privileges[id] & FLAG_B)
	{
		g_hadnvision[id] = true
	}

	// VIP
	if (!native_get_human_hero(id) && g_user_privileges[id] & FLAG_A) 
   	{
		if(event_start == 1)
		{ 
			if(g_user_privileges[id] & FLAG_D)
				set_pev(id, pev_armorvalue, float(zc_vip_armor))
			else
				set_pev(id, pev_armorvalue, float(zc_vip_armor_happy))
		}else if(event_start  == 0){
			set_pev(id, pev_armorvalue, float(zc_vip_armor))
		}
	}
	// Last Zombie Check
	fnCheckLastZombie()
}

/*================================================================================
 [Other Functions and Tasks]
=================================================================================*/

public cache_cvars()
{
	for(new id = 1; id <= g_maxplayers; id++) 
	{
		g_cached_zombiesilent = zc_zombie_silent
		g_cached_customflash = zc_flash_custom
		g_cached_nemspd = zc_nem_speed+(speed_l[id]*zc_powers_speed_rate)
		g_cached_survspd = zc_surv_speed+(speed_l[id]*zc_powers_speed_rate)
		g_cached_leapzombies = zc_leap_zombies
		g_cached_leapzombiescooldown = zc_leap_zombies_cooldown
		g_cached_leapnemesis = zc_leap_nemesis
		g_cached_leapnemesiscooldown = zc_leap_nemesis_cooldown
		g_cached_leapsurvivor = zc_leap_survivor
		g_cached_leapsurvivorcooldown = zc_leap_survivor_cooldown
		g_cached_sniperspd = zc_sniper_speed+(speed_l[id]*zc_powers_speed_rate)
		g_cached_leapsniper = zc_leap_sniper
		g_cached_leapsnipercooldown = zc_leap_sniper_cooldown
		g_cached_assassinspd = zc_assassin_speed+(speed_l[id]*zc_powers_speed_rate)
		g_cached_leapassassin = zc_leap_assassin
		g_cached_leapassassincooldown = zc_leap_assassin_cooldown
		g_cached_oberonspd = zc_oberon_speed+(speed_l[id]*zc_powers_speed_rate)
		g_cached_dragonspd = zc_dragon_speed+(speed_l[id]*zc_powers_speed_rate)
		g_cached_nighterspd = zc_nighter_speed+(speed_l[id]*zc_powers_speed_rate)
		g_cached_nchildspd = zc_nchild_speed+(speed_l[id]*zc_powers_speed_rate)
		g_cached_evilspd = zc_evil_speed+(speed_l[id]*zc_powers_speed_rate)
		g_cached_leapoberon = zc_leap_oberon
		g_cached_leapoberoncooldown = zc_leap_oberon_cooldown
		g_cached_leapdragon = zc_leap_dragon
		g_cached_leapdragoncooldown = zc_leap_dragon_cooldown
		g_cached_leapnighter = zc_leap_nighter
		g_cached_leapnightercooldown = zc_leap_nighter_cooldown
		g_cached_flamerspd = zc_flamer_speed+(speed_l[id]*zc_powers_speed_rate)
		g_cached_leapflamer = zc_leap_flamer
		g_cached_leapflamercooldown = zc_leap_flamer_cooldown
		g_cached_zadocspd = zc_zadoc_speed+(speed_l[id]*zc_powers_speed_rate)
		g_cached_herospd = zc_hero_speed+(speed_l[id]*zc_powers_speed_rate)
		g_cached_leapzadoc = zc_leap_zadoc
		g_cached_leapzadoccooldown = zc_leap_zadoc_cooldown
	}
}

load_customization_from_files()
{
	// Build customization file path
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, ZC_CUSTOMIZATION_FILE)
	
	// File not present
	if (!file_exists(path))
	{
		new error[100]
		formatex(error, charsmax(error), "Cannot load customization file %s!", path)
		set_fail_state(error)
		return;
	}
	
	// Set up some vars to hold parsing info
	new linedata[1024], key[64], value[960], section, teams
	
	// Open customization file for reading
	new file = fopen(path, "rt")
	
	while (file && !feof(file))
	{
		// Read one line at a time
		fgets(file, linedata, charsmax(linedata))
		
		// Replace newlines with a null character to prevent headaches
		replace(linedata, charsmax(linedata), "^n", "")
		
		// Blank line or comment
		if (!linedata[0] || linedata[0] == ';') continue;
		
		// New section starting
		if (linedata[0] == '[')
		{
			section++
			continue;
		}
		
		// Get key and value(s)
		strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
		
		// Trim spaces
		trim(key)
		trim(value)
		
		switch (section)
		{
			case SECTION_ACCESS_FLAGS:
			{
				if (equal(key, "ENABLE/DISABLE MOD"))
					g_access_flag[ACCESS_ENABLE_MOD] = read_flags(value)
				else if (equal(key, "ADMIN MENU"))
					g_access_flag[ACCESS_ADMIN_MENU] = read_flags(value)
				else if (equal(key, "ADMIN MENU 2"))
					g_access_flag[ACCESS_ADMIN_MENU2] = read_flags(value)
				else if (equal(key, "ADMIN MENU 3"))
					g_access_flag[ACCESS_ADMIN_MENU3] = read_flags(value)
				else if (equal(key, "START MODE INFECTION"))
					g_access_flag[ACCESS_MODE_INFECTION] = read_flags(value)
				else if (equal(key, "START MODE NEMESIS"))
					g_access_flag[ACCESS_MODE_NEMESIS] = read_flags(value)
				else if (equal(key, "START MODE SURVIVOR"))
					g_access_flag[ACCESS_MODE_SURVIVOR] = read_flags(value)
				else if (equal(key, "START MODE SWARM"))
					g_access_flag[ACCESS_MODE_SWARM] = read_flags(value)
				else if (equal(key, "START MODE MULTI"))
					g_access_flag[ACCESS_MODE_MULTI] = read_flags(value)
				else if (equal(key, "START MODE PLAGUE"))
					g_access_flag[ACCESS_MODE_PLAGUE] = read_flags(value)
				else if (equal(key, "MAKE ZOMBIE"))
					g_access_flag[ACCESS_MAKE_ZOMBIE] = read_flags(value)
				else if (equal(key, "MAKE HUMAN"))
					g_access_flag[ACCESS_MAKE_HUMAN] = read_flags(value)
				else if (equal(key, "MAKE NEMESIS"))
					g_access_flag[ACCESS_MAKE_NEMESIS] = read_flags(value)
				else if (equal(key, "MAKE SURVIVOR"))
					g_access_flag[ACCESS_MAKE_SURVIVOR] = read_flags(value)
				else if (equal(key, "RESPAWN PLAYERS"))
					g_access_flag[ACCESS_RESPAWN_PLAYERS] = read_flags(value)
				else if (equal(key, "ADMIN MODELS"))
					g_access_flag[ACCESS_ADMIN_MODELS] = read_flags(value)
				else if (equal(key, "START MODE SNIPER"))
					g_access_flag[ACCESS_MODE_SNIPER] = read_flags(value)
				else if (equal(key, "MAKE SNIPER"))
					g_access_flag[ACCESS_MAKE_SNIPER] = read_flags(value)
				else if (equal(key, "START MODE ASSASSIN"))
					g_access_flag[ACCESS_MODE_ASSASSIN] = read_flags(value)
				else if (equal(key, "MAKE ASSASSIN"))
					g_access_flag[ACCESS_MAKE_ASSASSIN] = read_flags(value)
				else if (equal(key, "START MODE OBERON"))
					g_access_flag[ACCESS_MODE_OBERON] = read_flags(value)
				else if (equal(key, "MAKE OBERON"))
					g_access_flag[ACCESS_MAKE_OBERON] = read_flags(value)
				else if (equal(key, "START MODE DRAGON"))
					g_access_flag[ACCESS_MODE_DRAGON] = read_flags(value)
				else if (equal(key, "MAKE DRAGON"))
					g_access_flag[ACCESS_MAKE_DRAGON] = read_flags(value)
				else if (equal(key, "START MODE NIGHTER"))
					g_access_flag[ACCESS_MODE_NIGHTER] = read_flags(value)
				else if (equal(key, "MAKE NIGHTER"))
					g_access_flag[ACCESS_MAKE_NIGHTER] = read_flags(value)
				else if (equal(key, "MAKE FLAMER"))
					g_access_flag[ACCESS_MAKE_FLAMER] = read_flags(value)
				else if (equal(key, "START MODE FLAMER"))
					g_access_flag[ACCESS_MODE_FLAMER] = read_flags(value)
				else if (equal(key, "MAKE ZADOC"))
					g_access_flag[ACCESS_MAKE_ZADOC] = read_flags(value)
				else if (equal(key, "START MODE ZADOC"))
					g_access_flag[ACCESS_MODE_ZADOC] = read_flags(value)
				else if (equal(key, "MAKE GENESYS"))
					g_access_flag[ACCESS_MAKE_GENESYS] = read_flags(value)
				else if (equal(key, "START MODE GENESYS"))
					g_access_flag[ACCESS_MODE_GENESYS] = read_flags(value)
				else if (equal(key, "START MODE LNJ"))
					g_access_flag[ACCESS_MODE_LNJ] = read_flags(value)
				else if (equal(key, "START MODE GUARDIANS"))
					g_access_flag[ACCESS_MODE_GUARDIANS] = read_flags(value)
				
			}
			case SECTION_PLAYER_MODELS:
			{
			 	if (equal(key, "NEMESIS"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_nemesis, key)
					}
				}
				else if (equal(key, "SURVIVOR"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_survivor, key)
					}
				}
				else if (equal(key, "ADMIN ZOMBIE"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_admin_zombie, key)
					}
				}
				else if (equal(key, "ADMIN HUMAN"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_admin_human, key)
					}
				}
				else if (equal(key, "VIP HUMAN"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_vip_human, key)
					}
				}
				else if (equal(key, "SNIPER"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_sniper, key)
					}
				}
				else if (equal(key, "FLAMER"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_flamer, key)
					}
				}
				else if (equal(key, "ZADOC"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_zadoc, key)
					}
				}
				else if (equal(key, "HERO"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_hero, key)
					}
				}
				else if (equal(key, "ASSASSIN"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_assassin, key)
					}
				}

				else if (equal(key, "OBERON"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_oberon, key)
					}
				}

				else if (equal(key, "DRAGON"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_dragon, key)
					}
				}

				else if (equal(key, "NIGHTER"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_nighter, key)
					}
				}

				else if (equal(key, "NCHILD"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_nchild, key)
					}
				}

				else if (equal(key, "EVIL"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_evil, key)
					}
				}

				else if (equal(key, "GENESYS"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_genesys, key)
					}
				}
				
				else if (equal(key, "FORCE CONSISTENCY"))
					g_force_consistency = str_to_num(value)
				else if (equal(key, "SAME MODELS FOR ALL"))
					g_same_models_for_all = str_to_num(value)
				else if (g_same_models_for_all && equal(key, "ZOMBIE"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(g_zclass_playermodel, key)
						
						// Precache model and retrieve its modelindex
						formatex(linedata, charsmax(linedata), "models/player/%s/%s.mdl", key, key)
						ArrayPushCell(g_zclass_modelindex, engfunc(EngFunc_PrecacheModel, linedata))
						if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, linedata)
						if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, linedata)
					}
				}
                                else if (g_same_models_for_all && equal(key, "HUMAN"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(g_hclass_playermodel, key)
						
						// Precache model and retrieve its modelindex
						formatex(linedata, charsmax(linedata), "models/player/%s/%s.mdl", key, key)
						ArrayPushCell(g_hclass_modelindex, engfunc(EngFunc_PrecacheModel, linedata))
						if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, linedata)
						if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, linedata)
					}
				}
			}
			case SECTION_WEAPON_MODELS:
			{
				if (equal(key, "V_KNIFE HUMAN"))
					copy(model_vknife_human, charsmax(model_vknife_human), value)
				else if (equal(key, "V_KNIFE NEMESIS"))
					copy(model_vknife_nemesis, charsmax(model_vknife_nemesis), value)
				else if (equal(key, "V_M249 SURVIVOR"))
					copy(model_vm249_survivor, charsmax(model_vm249_survivor), value)
				else if (equal(key, "V_GRENADE INFECT"))
					copy(model_vgrenade_infect, charsmax(model_vgrenade_infect), value)
				else if (equal(key, "P_GRENADE INFECT"))
					copy(model_pgrenade_infect, charsmax(model_pgrenade_infect), value)
				else if (equal(key, "W_GRENADE INFECT"))
					copy(model_wgrenade_infect, charsmax(model_wgrenade_infect), value)
				else if (equal(key, "V_GRENADE FIRE"))
					copy(model_vgrenade_fire, charsmax(model_vgrenade_fire), value)
				else if (equal(key, "P_GRENADE FIRE"))
					copy(model_pgrenade_fire, charsmax(model_pgrenade_fire), value)
				else if (equal(key, "W_GRENADE FIRE"))
					copy(model_wgrenade_fire, charsmax(model_wgrenade_fire), value)
				else if (equal(key, "V_GRENADE FROST"))
					copy(model_vgrenade_frost, charsmax(model_vgrenade_frost), value)
				else if (equal(key, "P_GRENADE FROST"))
					copy(model_pgrenade_frost, charsmax(model_pgrenade_frost), value)
				else if (equal(key, "W_GRENADE FROST"))
					copy(model_wgrenade_frost, charsmax(model_wgrenade_frost), value)
				else if (equal(key, "V_GRENADE EXPLOSION"))
					copy(model_vgrenade_explosion, charsmax(model_vgrenade_explosion), value)
				else if (equal(key, "P_GRENADE_EXPLOSION"))
					copy(model_pgrenade_explosion, charsmax(model_pgrenade_explosion), value)
				else if (equal(key, "W_GRENADE EXPLOSION"))
					copy(model_wgrenade_explosion, charsmax(model_wgrenade_explosion), value)
				else if (equal(key, "V_KNIFE ADMIN HUMAN"))
					copy(model_vknife_admin_human, charsmax(model_vknife_admin_human), value)
				else if (equal(key, "V_KNIFE ADMIN ZOMBIE"))
					copy(model_vknife_admin_zombie, charsmax(model_vknife_admin_zombie), value)
				else if (equal(key, "V_AWP SNIPER"))
					copy(model_vawp_sniper, charsmax(model_vawp_sniper), value)
				else if (equal(key, "V_KNIFE ASSASSIN"))
					copy(model_vknife_assassin, charsmax(model_vknife_assassin), value)
				else if (equal(key, "V_KNIFE OBERON"))
					copy(model_vknife_oberon, charsmax(model_vknife_oberon), value)
				else if (equal(key, "V_KNIFE DRAGON"))
					copy(model_vknife_dragon, charsmax(model_vknife_dragon), value)
				else if (equal(key, "V_KNIFE NIGHTER"))
					copy(model_vknife_nighter, charsmax(model_vknife_nighter), value)
				else if (equal(key, "V_KNIFE NCHILD"))
					copy(model_vknife_nchild, charsmax(model_vknife_nchild), value)
				else if (equal(key, "V_WEAPON FLAMER"))
					copy(model_vweapon_flamer, charsmax(model_vweapon_flamer), value)
				else if (equal(key, "P_WEAPON FLAMER"))
					copy(model_pweapon_flamer, charsmax(model_pweapon_flamer), value)
				else if (equal(key, "V_KNIFE ZADOC"))
					copy(model_vknife_zadoc, charsmax(model_vknife_zadoc), value)
				else if (equal(key, "P_KNIFE ZADOC"))
					copy(model_pknife_zadoc, charsmax(model_pknife_zadoc), value)
				else if (equal(key, "V_KNIFE GENESYS"))
					copy(model_vknife_genesys, charsmax(model_vknife_genesys), value)
				else if (equal(key, "V_KNIFE EVIL"))
					copy(model_vknife_evil, charsmax(model_vknife_evil), value)
			}
			case SECTION_GRENADE_SPRITES:
			{
				if (equal(key, "TRAIL"))
					copy(sprite_grenade_trail, charsmax(sprite_grenade_trail), value)
				else if (equal(key, "RING"))
					copy(sprite_grenade_ring, charsmax(sprite_grenade_ring), value)
				else if (equal(key, "FIRE"))
					copy(sprite_grenade_fire, charsmax(sprite_grenade_fire), value)
				else if (equal(key, "SMOKE"))
					copy(sprite_grenade_smoke, charsmax(sprite_grenade_smoke), value)
				else if (equal(key, "GLASS"))
					copy(sprite_grenade_glass, charsmax(sprite_grenade_glass), value)
			}
			case SECTION_SOUNDS:
			{
				if (equal(key, "WIN ZOMBIES"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_win_zombies, key)
					}
				}
				else if (equal(key, "WIN HUMANS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_win_humans, key)
					}
				}
				else if (equal(key, "WIN NO ONE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_win_no_one, key)
					}
				}
				else if (equal(key, "ZOMBIE INFECT"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(zombie_infect, key)
					}
				}
				else if (equal(key, "ZOMBIE PAIN"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(zombie_pain, key)
					}
				}
				else if (equal(key, "NEMESIS PAIN"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(nemesis_pain, key)
					}
				}
				else if (equal(key, "ASSASSIN PAIN"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(assassin_pain, key)
					}
				}
				else if (equal(key, "OBERON PAIN"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(oberon_pain, key)
					}
				}
				else if (equal(key, "DRAGON PAIN"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(dragon_pain, key)
					}
				}
				else if (equal(key, "NIGHTER PAIN"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(nighter_pain, key)
					}
				}
				else if (equal(key, "GENESYS PAIN"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(genesys_pain, key)
					}
				}
				else if (equal(key, "EVIL PAIN"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(evil_pain, key)
					}
				}
				else if (equal(key, "ZOMBIE DIE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(zombie_die, key)
					}
				}
				else if (equal(key, "ZOMBIE FALL"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(zombie_fall, key)
					}
				}
				else if (equal(key, "ZOMBIE MISS SLASH"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(zombie_miss_slash, key)
					}
				}
				else if (equal(key, "ZOMBIE MISS WALL"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(zombie_miss_wall, key)
					}
				}
				else if (equal(key, "ZOMBIE HIT NORMAL"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(zombie_hit_normal, key)
					}
				}
				else if (equal(key, "ZOMBIE HIT STAB"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(zombie_hit_stab, key)
					}
				}
				else if (equal(key, "ZOMBIE IDLE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(zombie_idle, key)
					}
				}
				else if (equal(key, "ZOMBIE IDLE LAST"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(zombie_idle_last, key)
					}
				}
				else if (equal(key, "ZOMBIE MADNESS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(zombie_madness, key)
					}
				}
				else if (equal(key, "ROUND NEMESIS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_nemesis, key)
					}
				}
				else if (equal(key, "ROUND SURVIVOR"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_survivor, key)
					}
				}
				else if (equal(key, "ROUND SWARM"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_swarm, key)
					}
				}
				else if (equal(key, "ROUND MULTI"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_multi, key)
					}
				}
				else if (equal(key, "ROUND PLAGUE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_plague, key)
					}
				}
				else if (equal(key, "GRENADE INFECT EXPLODE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(grenade_infect, key)
					}
				}
				else if (equal(key, "GRENADE INFECT PLAYER"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(grenade_infect_player, key)
					}
				}
				else if (equal(key, "GRENADE FIRE EXPLODE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(grenade_fire, key)
					}
				}
				else if (equal(key, "GRENADE FIRE PLAYER"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(grenade_fire_player, key)
					}
				}
				else if (equal(key, "GRENADE FROST EXPLODE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(grenade_frost, key)
					}
				}
				else if (equal(key, "GRENADE FROST PLAYER"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(grenade_frost_player, key)
					}
				}
				else if (equal(key, "GRENADE FROST BREAK"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(grenade_frost_break, key)
					}
				}
				else if (equal(key, "GRENADE EXPLOSION"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(grenade_explosion, key)
					}
				}
				else if (equal(key, "ANTIDOTE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_antidote, key)
					}
				}
				else if (equal(key, "THUNDER"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_thunder, key)
					}
				}
				else if (equal(key, "ROUND SNIPER"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_sniper, key)
					}
				}
				else if (equal(key, "ROUND FLAMER"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_flamer, key)
					}
				}
				else if (equal(key, "ROUND ZADOC"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_zadoc, key)
					}
				}
				else if (equal(key, "ROUND ASSASSIN"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_assassin, key)
					}
				}
				else if (equal(key, "ROUND OBERON"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_oberon, key)
					}
				}
				else if (equal(key, "ROUND DRAGON"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_dragon, key)
					}
				}
				else if (equal(key, "ROUND NIGHTER"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_nighter, key)
					}
				}
				else if (equal(key, "ROUND GENESYS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_genesys, key)
					}
				}
				else if (equal(key, "ROUND LNJ"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_lnj, key)
					}
				}
				else if (equal(key, "ROUND GUARDIANS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_guardians, key)
					}
				}
			}
			case SECTION_AMBIENCE_SOUNDS:
			{
				if (equal(key, "INFECTION ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_INFECTION] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_INFECTION] && equal(key, "INFECTION SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience1, key)
						ArrayPushCell(sound_ambience1_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_INFECTION] && equal(key, "INFECTION DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience1_duration, str_to_num(key))
					}
				}
				else if (equal(key, "NEMESIS ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_NEMESIS] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_NEMESIS] && equal(key, "NEMESIS SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience2, key)
						ArrayPushCell(sound_ambience2_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_NEMESIS] && equal(key, "NEMESIS DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience2_duration, str_to_num(key))
					}
				}
				else if (equal(key, "SURVIVOR ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_SURVIVOR] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_SURVIVOR] && equal(key, "SURVIVOR SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience3, key)
						ArrayPushCell(sound_ambience3_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_SURVIVOR] && equal(key, "SURVIVOR DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience3_duration, str_to_num(key))
					}
				}
				else if (equal(key, "SWARM ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_SWARM] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_SWARM] && equal(key, "SWARM SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience4, key)
						ArrayPushCell(sound_ambience4_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_SWARM] && equal(key, "SWARM DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience4_duration, str_to_num(key))
					}
				}
				else if (equal(key, "PLAGUE ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_PLAGUE] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_PLAGUE] && equal(key, "PLAGUE SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience5, key)
						ArrayPushCell(sound_ambience5_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_PLAGUE] && equal(key, "PLAGUE DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience5_duration, str_to_num(key))
					}
				}
				else if (equal(key, "SNIPER ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_SNIPER] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_SNIPER] && equal(key, "SNIPER SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience6, key)
						ArrayPushCell(sound_ambience6_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_SNIPER] && equal(key, "SNIPER DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience6_duration, str_to_num(key))
					}
				}
				else if (equal(key, "ASSASSIN ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_ASSASSIN] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_ASSASSIN] && equal(key, "ASSASSIN SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience7, key)
						ArrayPushCell(sound_ambience7_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_ASSASSIN] && equal(key, "ASSASSIN DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience7_duration, str_to_num(key))
					}
				}
				else if (equal(key, "OBERON ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_OBERON] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_OBERON] && equal(key, "OBERON SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience7a, key)
						ArrayPushCell(sound_ambience7a_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_OBERON] && equal(key, "OBERON DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience7a_duration, str_to_num(key))
					}
				}
				else if (equal(key, "DRAGON ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_DRAGON] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_DRAGON] && equal(key, "DRAGON SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience7b, key)
						ArrayPushCell(sound_ambience7b_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_DRAGON] && equal(key, "DRAGON DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience7b_duration, str_to_num(key))
					}
				}
				else if (equal(key, "NIGHTER ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_NIGHTER] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_NIGHTER] && equal(key, "NIGHTER SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience7c, key)
						ArrayPushCell(sound_ambience7c_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_NIGHTER] && equal(key, "NIGHTER DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience7c_duration, str_to_num(key))
					}
				}
				else if (equal(key, "FLAMER ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_FLAMER] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_FLAMER] && equal(key, "FLAMER SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience9a, key)
						ArrayPushCell(sound_ambience9a_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_FLAMER] && equal(key, "FLAMER DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience9a_duration, str_to_num(key))
					}
				}
				else if (equal(key, "ZADOC ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_ZADOC] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_ZADOC] && equal(key, "ZADOC SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience9b, key)
						ArrayPushCell(sound_ambience9b_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_ZADOC] && equal(key, "ZADOC DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience9b_duration, str_to_num(key))
					}
				}
				else if (equal(key, "GENESYS ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_GENESYS] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_GENESYS] && equal(key, "GENESYS SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience9, key)
						ArrayPushCell(sound_ambience9_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_GENESYS] && equal(key, "GENESYS DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience9_duration, str_to_num(key))
					}
				}
				else if (equal(key, "LNJ ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_LNJ] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_LNJ] && equal(key, "LNJ SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience8, key)
						ArrayPushCell(sound_ambience8_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_LNJ] && equal(key, "LNJ DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience8_duration, str_to_num(key))
					}
				}
				else if (equal(key, "GUARDIANS ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_GUARDIANS] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_GUARDIANS] && equal(key, "GUARDIANS SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience8d, key)
						ArrayPushCell(sound_ambience8d_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_GUARDIANS] && equal(key, "GUARDIANS DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience8d_duration, str_to_num(key))
					}
				}
			}
			case SECTION_BUY_MENU_WEAPONS:
			{
				if (equal(key, "PRIMARY"))
				{
					// Parse weapons
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to weapons array
						ArrayPushString(g_primary_items, key)
						ArrayPushCell(g_primary_weaponids, cs_weapon_name_to_id(key))
					}
				}
				else if (equal(key, "SECONDARY"))
				{
					// Parse weapons
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to weapons array
						ArrayPushString(g_secondary_items, key)
						ArrayPushCell(g_secondary_weaponids, cs_weapon_name_to_id(key))
					}
				}
				else if (equal(key, "ADDITIONAL ITEMS"))
				{
					// Parse weapons
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to weapons array
						ArrayPushString(g_additional_items, key)
					}
				}
			}
			case SECTION_EXTRA_ITEMS_WEAPONS:
			{
				if (equal(key, "NAMES"))
				{
					// Parse weapon items
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to weapons array
						ArrayPushString(g_extraweapon_names, key)
					}
				}
				else if (equal(key, "ITEMS"))
				{
					// Parse weapon items
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to weapons array
						ArrayPushString(g_extraweapon_items, key)
					}
				}
				else if (equal(key, "COSTS"))
				{
					// Parse weapon items
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to weapons array
						ArrayPushCell(g_extraweapon_costs, str_to_num(key))
					}
				}
			}
			case SECTION_HARD_CODED_ITEMS_COSTS:
			{
				if (equal(key, "NIGHT VISION"))
					g_extra_costs2[EXTRA_NVISION] = str_to_num(value)
				else if (equal(key, "CUSTOM NVISION"))
					g_extra_costs2[EXTRA_CNVISION] = str_to_num(value)
				else if (equal(key, "ANTIDOTE"))
					g_extra_costs2[EXTRA_ANTIDOTE] = str_to_num(value)
				else if (equal(key, "ZOMBIE MADNESS"))
					g_extra_costs2[EXTRA_MADNESS] = str_to_num(value)
				else if (equal(key, "INFECTION BOMB"))
					g_extra_costs2[EXTRA_INFBOMB] = str_to_num(value)
			}
			case SECTION_WEATHER_EFFECTS:
			{
				if (equal(key, "RAIN"))
					g_ambience_rain = str_to_num(value)
				else if (equal(key, "SNOW"))
					g_ambience_snow = str_to_num(value)
				else if (equal(key, "FOG"))
					g_ambience_fog = str_to_num(value)
				else if (equal(key, "FOG DENSITY"))
					copy(g_fog_density, charsmax(g_fog_density), value)
				else if (equal(key, "FOG COLOR"))
					copy(g_fog_color, charsmax(g_fog_color), value)
			}
			case SECTION_SKY:
			{
				if (equal(key, "ENABLE"))
					g_sky_enable = str_to_num(value)
				else if (equal(key, "SKY NAMES"))
				{
					// Parse sky names
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to skies array
						ArrayPushString(g_sky_names, key)
						
						// Preache custom sky files
						formatex(linedata, charsmax(linedata), "gfx/env/%sbk.tga", key)
						engfunc(EngFunc_PrecacheGeneric, linedata)
						formatex(linedata, charsmax(linedata), "gfx/env/%sdn.tga", key)
						engfunc(EngFunc_PrecacheGeneric, linedata)
						formatex(linedata, charsmax(linedata), "gfx/env/%sft.tga", key)
						engfunc(EngFunc_PrecacheGeneric, linedata)
						formatex(linedata, charsmax(linedata), "gfx/env/%slf.tga", key)
						engfunc(EngFunc_PrecacheGeneric, linedata)
						formatex(linedata, charsmax(linedata), "gfx/env/%srt.tga", key)
						engfunc(EngFunc_PrecacheGeneric, linedata)
						formatex(linedata, charsmax(linedata), "gfx/env/%sup.tga", key)
						engfunc(EngFunc_PrecacheGeneric, linedata)
					}
				}
			}
			case SECTION_ZOMBIE_DECALS:
			{
				if (equal(key, "DECALS"))
				{
					// Parse decals
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to zombie decals array
						ArrayPushCell(zombie_decals, str_to_num(key))
					}
				}
			}
			case SECTION_KNOCKBACK:
			{
				// Format weapon entity name
				strtolower(key)
				format(key, charsmax(key), "weapon_%s", key)
				
				// Add value to knockback power array
				kb_weapon_power[cs_weapon_name_to_id(key)] = str_to_float(value)
			}
			case SECTION_OBJECTIVE_ENTS:
			{
				if (equal(key, "CLASSNAMES"))
				{
					// Parse classnames
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to objective ents array
						ArrayPushString(g_objective_ents, key)
					}
				}
			}
			case SECTION_SVC_BAD:
			{
				if (equal(key, "MODELCHANGE DELAY"))
					g_modelchange_delay = str_to_float(value)
				else if (equal(key, "HANDLE MODELS ON SEPARATE ENT"))
					g_handle_models_on_separate_ent = str_to_num(value)
				else if (equal(key, "SET MODELINDEX OFFSET"))
					g_set_modelindex_offset = str_to_num(value)
			}
		}
	}
	if (file) fclose(file)
	
	// Build zombie classes file path
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, ZC_ZOMBIECLASSES_FILE)
	
	// Parse if present
	if (file_exists(path))
	{
		// Open zombie classes file for reading
		file = fopen(path, "rt")
		
		while (file && !feof(file))
		{
			// Read one line at a time
			fgets(file, linedata, charsmax(linedata))
			
			// Replace newlines with a null character to prevent headaches
			replace(linedata, charsmax(linedata), "^n", "")
			
			// Blank line or comment
			if (!linedata[0] || linedata[0] == ';') continue;
			
			// New class starting
			if (linedata[0] == '[')
			{
				// Remove first and last characters (braces)
				linedata[strlen(linedata) - 1] = 0
				copy(linedata, charsmax(linedata), linedata[1])
				
				// Store its real name for future reference
				ArrayPushString(g_zclass2_realname, linedata)
				continue;
			}
			
			// Get key and value(s)
			strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
			
			// Trim spaces
			trim(key)
			trim(value)
			
			if (equal(key, "NAME"))
				ArrayPushString(g_zclass2_name, value)
			else if (equal(key, "INFO"))
				ArrayPushString(g_zclass2_info, value)
			else if (equal(key, "MODELS"))
			{
				// Set models start index
				ArrayPushCell(g_zclass2_modelsstart, ArraySize(g_zclass2_playermodel))
				
				// Parse class models
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					// Trim spaces
					trim(key)
					trim(value)
					
					// Add to class models array
					ArrayPushString(g_zclass2_playermodel, key)
					ArrayPushCell(g_zclass2_modelindex, -1)
				}
				
				// Set models end index
				ArrayPushCell(g_zclass2_modelsend, ArraySize(g_zclass2_playermodel))
			}
			else if (equal(key, "CLAWMODEL"))
				ArrayPushString(g_zclass2_clawmodel, value)
			else if (equal(key, "HEALTH"))
				ArrayPushCell(g_zclass2_hp, str_to_num(value))
			else if (equal(key, "SPEED"))
				ArrayPushCell(g_zclass2_spd, str_to_num(value))
			else if (equal(key, "GRAVITY"))
				ArrayPushCell(g_zclass2_grav, str_to_float(value))
			else if (equal(key, "KNOCKBACK"))
				ArrayPushCell(g_zclass2_kb, str_to_float(value))
			else if (equal(key, "LEVEL"))
				ArrayPushCell(g_zclass2_level, str_to_num(value))
		}
		if (file) fclose(file)
	}
	        // Build human classes file path
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, ZC_HUMANCLASSES_FILE)
	
	// Parse if present
	if (file_exists(path))
	{
		// Open human classes file for reading
		file = fopen(path, "rt")
		
		while (file && !feof(file))
		{
			// Read one line at a time
			fgets(file, linedata, charsmax(linedata))
			
			// Replace newlines with a null character to prevent headaches
			replace(linedata, charsmax(linedata), "^n", "")
			
			// Blank line or comment
			if (!linedata[0] || linedata[0] == ';') continue;
			
			// New class starting
			if (linedata[0] == '[')
			{
				// Remove first and last characters (braces)
				linedata[strlen(linedata) - 1] = 0
				copy(linedata, charsmax(linedata), linedata[1])
				
				// Store its real name for future reference
				ArrayPushString(g_hclass2_realname, linedata)
				continue;
			}
			
			// Get key and value(s)
			strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
			
			// Trim spaces
			trim(key)
			trim(value)
			
			if (equal(key, "NAME"))
				ArrayPushString(g_hclass2_name, value)
			else if (equal(key, "INFO"))
				ArrayPushString(g_hclass2_info, value)
			else if (equal(key, "MODELS"))
			{
				// Set models start index
				ArrayPushCell(g_hclass2_modelsstart, ArraySize(g_hclass2_playermodel))
				
				// Parse class models
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					// Trim spaces
					trim(key)
					trim(value)
					
					// Add to class models array
					ArrayPushString(g_hclass2_playermodel, key)
					ArrayPushCell(g_hclass2_modelindex, -1)
				}
				
				// Set models end index
				ArrayPushCell(g_hclass2_modelsend, ArraySize(g_hclass2_playermodel))
			}
			else if (equal(key, "HEALTH"))
				ArrayPushCell(g_hclass2_hp, str_to_num(value))
			else if (equal(key, "SPEED"))
				ArrayPushCell(g_hclass2_spd, str_to_num(value))
			else if (equal(key, "GRAVITY"))
				ArrayPushCell(g_hclass2_grav, str_to_float(value))
			else if (equal(key, "LEVEL"))
				ArrayPushCell(g_hclass2_level, str_to_num(value))		
		}
		if (file) fclose(file)
	}

	// Build extra items file path
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, ZC_EXTRAITEMS_FILE)
	
	// Parse if present
	if (file_exists(path))
	{
		// Open extra items file for reading
		file = fopen(path, "rt")
		
		while (file && !feof(file))
		{
			// Read one line at a time
			fgets(file, linedata, charsmax(linedata))
			
			// Replace newlines with a null character to prevent headaches
			replace(linedata, charsmax(linedata), "^n", "")
			
			// Blank line or comment
			if (!linedata[0] || linedata[0] == ';') continue;
			
			// New item starting
			if (linedata[0] == '[')
			{
				// Remove first and last characters (braces)
				linedata[strlen(linedata) - 1] = 0
				copy(linedata, charsmax(linedata), linedata[1])
				
				// Store its real name for future reference
				ArrayPushString(g_extraitem2_realname, linedata)
				continue;
			}
			
			// Get key and value(s)
			strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
			
			// Trim spaces
			trim(key)
			trim(value)
			
			if (equal(key, "NAME"))
				ArrayPushString(g_extraitem2_name, value)
			else if (equal(key, "COST"))
				ArrayPushCell(g_extraitem2_cost, str_to_num(value))
			else if (equal(key, "TEAMS"))
			{
				// Clear teams bitsum
				teams = 0
				
				// Parse teams
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					// Trim spaces
					trim(key)
					trim(value)
					
					if (equal(key, ZP_TEAM_NAMES[ZP_TEAM_ZOMBIE]))
						teams |= ZP_TEAM_ZOMBIE
					else if (equal(key, ZP_TEAM_NAMES[ZP_TEAM_HUMAN]))
						teams |= ZP_TEAM_HUMAN
					else if (equal(key, ZP_TEAM_NAMES[ZP_TEAM_NEMESIS]))
						teams |= ZP_TEAM_NEMESIS
					else if (equal(key, ZP_TEAM_NAMES[ZP_TEAM_SURVIVOR]))
						teams |= ZP_TEAM_SURVIVOR
					else if (equal(key, ZP_TEAM_NAMES[ZP_TEAM_SNIPER]))
						teams |= ZP_TEAM_SNIPER
					else if (equal(key, ZP_TEAM_NAMES[ZP_TEAM_ASSASSIN]))
						teams |= ZP_TEAM_ASSASSIN
					else if (equal(key, ZP_TEAM_NAMES[ZP_TEAM_OBERON]))
						teams |= ZP_TEAM_OBERON
					else if (equal(key, ZP_TEAM_NAMES[ZP_TEAM_DRAGON]))
						teams |= ZP_TEAM_DRAGON
					else if (equal(key, ZP_TEAM_NAMES[ZP_TEAM_NIGHTER]))
						teams |= ZP_TEAM_NIGHTER
					else if (equal(key, ZP_TEAM_NAMES[ZP_TEAM_NCHILD]))
						teams |= ZP_TEAM_NCHILD
					else if (equal(key, ZP_TEAM_NAMES[ZP_TEAM_FLAMER]))
						teams |= ZP_TEAM_FLAMER
					else if (equal(key, ZP_TEAM_NAMES[ZP_TEAM_ZADOC]))
						teams |= ZP_TEAM_ZADOC
					else if (equal(key, ZP_TEAM_NAMES[ZP_TEAM_GENESYS]))
						teams |= ZP_TEAM_GENESYS
					else if (equal(key, ZP_TEAM_NAMES[ZP_TEAM_EVIL]))
						teams |= ZP_TEAM_EVIL
					else if (equal(key, ZP_TEAM_NAMES[ZP_TEAM_HERO]))
						teams |= ZP_TEAM_HERO
				}
				
				// Add to teams array
				ArrayPushCell(g_extraitem2_team, teams)
			}
			else if(equal( key, "REST_TYPE"))
				ArrayPushCell(g_extraitem2_resttype, str_to_num(value))
			else if(equal( key, "REST_LIMIT"))
				ArrayPushCell(g_extraitem2_restlimit, str_to_num(value))
		}
		if (file) fclose(file)
	}
}

public Load_GameConfig()
{
	// Init
	static Buffer[64], Buffer2[3][8]
	
	// General
	Setting_Load_String(ZC_SETTINGS_FILE, "General", "ZP_DELAY", Buffer, sizeof(Buffer)); 
	zc_delay = str_to_float(Buffer)
	zc_triggered_lights = Setting_Load_Int(ZC_SETTINGS_FILE, "General", "ZP_TRIGGERED_LIGHTS")
	zc_remove_doors = Setting_Load_Int(ZC_SETTINGS_FILE, "General", "ZP_REMOVE_DOORS")
	zc_blockuse_pushable = Setting_Load_Int(ZC_SETTINGS_FILE, "General", "ZP_BLOCKUSE_PUSHABLES")
	zc_block_suicide = Setting_Load_Int(ZC_SETTINGS_FILE, "General", "ZP_BLOCK_SUICIDE")
	zc_respawn_on_worldspawn_kill = Setting_Load_Int(ZC_SETTINGS_FILE, "General", "ZP_RESPAWN_ON_WORLDSPAWN_KILL")
	zc_buy_custom = Setting_Load_Int(ZC_SETTINGS_FILE, "General", "ZP_BUY_CUSTOM")
	zc_random_weapons = Setting_Load_Int(ZC_SETTINGS_FILE, "General", "ZP_RANDOM_WEAPONS")
	zc_admin_models_human = Setting_Load_Int(ZC_SETTINGS_FILE, "General", "ZP_ADMIN_MODELS_HUMAN")
	zc_admin_knife_models_human = Setting_Load_Int(ZC_SETTINGS_FILE, "General", "ZP_ADMIN_KNIFE_MODELS_HUMAN")
	zc_admin_models_zombie = Setting_Load_Int(ZC_SETTINGS_FILE, "General", "ZP_ADMIN_MODELS_ZOMBIE")
	zc_admin_knife_models_zombie = Setting_Load_Int(ZC_SETTINGS_FILE, "General", "ZP_ADMIN_KNIFE_MODELS_ZOMBIE")
	zc_zombie_classes = Setting_Load_Int(ZC_SETTINGS_FILE, "General", "ZP_ZOMBIE_CLASSES")
	zc_human_classes = Setting_Load_Int(ZC_SETTINGS_FILE, "General", "ZP_HUMAN_CLASSES")
	zc_starting_ammo_packs = Setting_Load_Int(ZC_SETTINGS_FILE, "General", "ZP_STARTING_AMMO_PACKS")
	zc_keep_health_on_disconnect = Setting_Load_Int(ZC_SETTINGS_FILE, "General", "ZP_KEEP_HEALTH_ON_DISCONNECT")
	zc_human_survive = Setting_Load_Int(ZC_SETTINGS_FILE, "General", "ZP_HUMAN_SURVIVE")
	zc_countdown = Setting_Load_Int(ZC_SETTINGS_FILE, "General", "ZP_COUNTDOWN")
	Setting_Load_String(ZC_SETTINGS_FILE, "General", "ZP_REMOVE_DROPPED", Buffer, sizeof(Buffer));  zc_remove_dropped = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "General", "ZP_HUD_ALIVE_XPOS", Buffer, sizeof(Buffer));  zc_hud_alive_xpos = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "General", "ZP_HUD_ALIVE_YPOS", Buffer, sizeof(Buffer));  zc_hud_alive_ypos = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "General", "ZP_HUD_DEAD_XPOS", Buffer, sizeof(Buffer));  zc_hud_dead_xpos = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "General", "ZP_HUD_DEAD_YPOS", Buffer, sizeof(Buffer));  zc_hud_dead_ypos = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "General", "ZP_HUD_ALIVE_COLOR", Buffer, sizeof(Buffer))
	parse(Buffer, Buffer2[0], 7, Buffer2[1], 7, Buffer2[2], 7)
	zc_hud_alive_color[0] = str_to_num(Buffer2[0])
	zc_hud_alive_color[1] = str_to_num(Buffer2[1])
	zc_hud_alive_color[2] = str_to_num(Buffer2[2])
	Setting_Load_String(ZC_SETTINGS_FILE, "General", "ZP_HUD_DEAD_COLOR", Buffer, sizeof(Buffer))
	parse(Buffer, Buffer2[0], 7, Buffer2[1], 7, Buffer2[2], 7)
	zc_hud_dead_color[0] = str_to_num(Buffer2[0])
	zc_hud_dead_color[1] = str_to_num(Buffer2[1])
	zc_hud_dead_color[2] = str_to_num(Buffer2[2])

	// Deathmatch
	zc_deathmatch = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_DEATHMATCH")
	Setting_Load_String(ZC_SETTINGS_FILE, "Deathmatch", "ZP_SPAWN_DELAY", Buffer, sizeof(Buffer));  zc_spawn_delay = str_to_float(Buffer)
	zc_respawn_on_suicide = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_RESPAWN_ON_SUICIDE")
	Setting_Load_String(ZC_SETTINGS_FILE, "Deathmatch", "ZP_SPAWN_PROTECTION", Buffer, sizeof(Buffer));  zc_spawn_protection = str_to_float(Buffer)
	zc_respawn_after_last_human = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_RESPAWN_AFTER_LAST_HUMAN")
	zc_infecton_allow_respawn = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_INFECTION_ALLOW_RESPAWN")
	zc_nem_allow_respawn = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_NEM_ALLOW_RESPAWN")
	zc_surv_allow_respawn = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_SURV_ALLOW_RESPAWN")
	zc_sniper_allow_respawn = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_SNIPER_ALLOW_RESPAWN")
	zc_assassin_allow_respawn = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_ASSASSIN_ALLOW_RESPAWN")
	zc_oberon_allow_respawn = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_OBERON_ALLOW_RESPAWN")
	zc_dragon_allow_respawn = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_DRAGON_ALLOW_RESPAWN")
	zc_nighter_allow_respawn = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_NIGHTER_ALLOW_RESPAWN")
	zc_swarm_allow_respawn = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_SWARM_ALLOW_RESPAWN")
	zc_plague_allow_respawn = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_PLAGUE_ALLOW_RESPAWN")
	zc_flamer_allow_respawn = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_FLAMER_ALLOW_RESPAWN")
	zc_zadoc_allow_respawn = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_ZADOC_ALLOW_RESPAWN")
	zc_respawn_zombies = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_RESPAWN_ZOMBIES")
	zc_respawn_humans = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_RESPAWN_HUMANS")
	zc_respawn_nemesis = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_RESPAWN_NEMESIS")
	zc_respawn_survivors = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_RESPAWN_SURVIVORS")
	zc_respawn_snipers = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_RESPAWN_SNIPERS")
	zc_respawn_flamers = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_RESPAWN_FLAMERS")
	zc_respawn_zadocs = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_RESPAWN_ZADOCS")
	zc_respawn_assassins = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_RESPAWN_ASSASSINS")
	zc_respawn_oberons = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_RESPAWN_OBERONS")
	zc_respawn_dragons = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_RESPAWN_DRAGONS")
	zc_respawn_nighters = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_RESPAWN_NIGHTERS")
	zc_respawn_nchilds = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_RESPAWN_NCHILDS")
	zc_lnj_allow_respawn = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_LNJ_ALLOW_RESPAWN")
	zc_lnj_respawn_surv = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_LNJ_RESPAWN_SURV")
	zc_lnj_respawn_nem = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_LNJ_RESPAWN_NEM")
	zc_guardians_allow_respawn = Setting_Load_Int(ZC_SETTINGS_FILE, "Deathmatch", "ZP_GUARDIANS_ALLOW_RESPAWN")

	// Extraitems
	zc_extra_items = Setting_Load_Int(ZC_SETTINGS_FILE, "Extraitems", "ZP_EXTRA_ITEMS") 
	zc_extra_weapons = Setting_Load_Int(ZC_SETTINGS_FILE, "Extraitems", "ZP_EXTRA_WEAPONS")
	zc_extra_nvision = Setting_Load_Int(ZC_SETTINGS_FILE, "Extraitems", "ZP_EXTRA_NVISION") 
	zc_extra_cnvision = Setting_Load_Int(ZC_SETTINGS_FILE, "Extraitems", "ZP_EXTRA_CNVISION") 
	zc_extra_antidote = Setting_Load_Int(ZC_SETTINGS_FILE, "Extraitems", "ZP_EXTRA_ANTIDOTE") 
	zc_extra_madness = Setting_Load_Int(ZC_SETTINGS_FILE, "Extraitems", "ZP_EXTRA_MADNESS") 
	Setting_Load_String(ZC_SETTINGS_FILE, "Extraitems", "ZP_EXTRA_MADNESS_DURATION", Buffer, sizeof(Buffer));  zc_extra_madness_duration = str_to_float(Buffer) 
	zc_extra_infbomb = Setting_Load_Int(ZC_SETTINGS_FILE, "Extraitems", "ZP_EXTRA_INFBOMB")

	// Lights
	zc_nvg_give = Setting_Load_Int(ZC_SETTINGS_FILE, "Lights", "ZP_NVG_GIVE")
	zc_flash_custom = Setting_Load_Int(ZC_SETTINGS_FILE, "Lights", "ZP_FLASH_CUSTOM")
	zc_flash_size = Setting_Load_Int(ZC_SETTINGS_FILE, "Lights", "ZP_FLASH_SIZE")
	zc_flash_size_assassin = Setting_Load_Int(ZC_SETTINGS_FILE, "Lights", "ZP_FLASH_SIZE_ASSASSIN")
	zc_flash_drain = Setting_Load_Int(ZC_SETTINGS_FILE, "Lights", "ZP_FLASH_DRAIN")
	zc_flash_charge = Setting_Load_Int(ZC_SETTINGS_FILE, "Lights", "ZP_FLASH_CHARGE")
	zc_flash_distance = Setting_Load_Int(ZC_SETTINGS_FILE, "Lights", "ZP_FLASH_DISTANCE")
	zc_flash_color_r = Setting_Load_Int(ZC_SETTINGS_FILE, "Lights", "ZP_FLASH_COLOR_R")
	zc_flash_color_g = Setting_Load_Int(ZC_SETTINGS_FILE, "Lights", "ZP_FLASH_COLOR_G")
	zc_flash_color_b = Setting_Load_Int(ZC_SETTINGS_FILE, "Lights", "ZP_FLASH_COLOR_B")
	zc_flash_color_assassin_r = Setting_Load_Int(ZC_SETTINGS_FILE, "Lights", "ZP_FLASH_COLOR_ASSASSIN_R")
	zc_flash_color_assassin_g = Setting_Load_Int(ZC_SETTINGS_FILE, "Lights", "ZP_FLASH_COLOR_ASSASSIN_G")
	zc_flash_color_assassin_b = Setting_Load_Int(ZC_SETTINGS_FILE, "Lights", "ZP_FLASH_COLOR_ASSASSIN_B")
	zc_flash_show_all = Setting_Load_Int(ZC_SETTINGS_FILE, "Lights", "ZP_FLASH_SHOW_ALL")

	// Knockback
	zc_knockback = Setting_Load_Int(ZC_SETTINGS_FILE, "Knockback", "ZP_KNOCKBACK") 
	zc_knockback_damage = Setting_Load_Int(ZC_SETTINGS_FILE, "Knockback", "ZP_KNOCKBACK_DAMAGE")
	zc_knockback_power = Setting_Load_Int(ZC_SETTINGS_FILE, "Knockback", "ZP_KNOCKBACK_POWER") 
	zc_knockback_zvel = Setting_Load_Int(ZC_SETTINGS_FILE, "Knockback", "ZP_KNOCKBACK_ZVEL")
	Setting_Load_String(ZC_SETTINGS_FILE, "Knockback", "ZP_KNOCKBACK_DUCKING", Buffer, sizeof(Buffer));  zc_knockback_ducking = str_to_float(Buffer)
	zc_knockback_distance = Setting_Load_Int(ZC_SETTINGS_FILE, "Knockback", "ZP_KNOCKBACK_DISTANCE") 
	Setting_Load_String(ZC_SETTINGS_FILE, "Knockback", "ZP_KNOCKBACK_NEMESIS", Buffer, sizeof(Buffer));  zc_knockback_nemesis = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Knockback", "ZP_KNOCKBACK_ASSASSIN", Buffer, sizeof(Buffer));  zc_knockback_assassin = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Knockback", "ZP_KNOCKBACK_OBERON", Buffer, sizeof(Buffer));  zc_knockback_oberon = str_to_float(Buffer) 
	Setting_Load_String(ZC_SETTINGS_FILE, "Knockback", "ZP_KNOCKBACK_DRAGON", Buffer, sizeof(Buffer));  zc_knockback_dragon = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Knockback", "ZP_KNOCKBACK_NIGHTER", Buffer, sizeof(Buffer));  zc_knockback_nighter = str_to_float(Buffer)

	// Longjump
	zc_leap_zombies = Setting_Load_Int(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_ZOMBIES")
	zc_leap_zombies_force = Setting_Load_Int(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_ZOMBIES_FORCE")
	Setting_Load_String(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_ZOMBIES_HEIGHT", Buffer, sizeof(Buffer));  zc_leap_zombies_height = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_ZOMBIES_COOLDOWN", Buffer, sizeof(Buffer));  zc_leap_zombies_cooldown = str_to_float(Buffer)
	zc_leap_nemesis = Setting_Load_Int(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_NEMESIS")
	zc_leap_nemesis_force = Setting_Load_Int(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_NEMESIS_FORCE")
	Setting_Load_String(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_NEMESIS_HEIGHT", Buffer, sizeof(Buffer));  zc_leap_nemesis_height = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_NEMESIS_COOLDOWN", Buffer, sizeof(Buffer));  zc_leap_nemesis_cooldown = str_to_float(Buffer)
	zc_leap_survivor = Setting_Load_Int(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_SURVIVOR")
	zc_leap_survivor_force = Setting_Load_Int(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_SURVIVOR_FORCE")
	Setting_Load_String(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_SURVIVOR_HEIGHT", Buffer, sizeof(Buffer));  zc_leap_survivor_height = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_SURVIVOR_COOLDOWN", Buffer, sizeof(Buffer));  zc_leap_survivor_cooldown = str_to_float(Buffer)
	zc_leap_sniper = Setting_Load_Int(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_SNIPER")
	zc_leap_sniper_force = Setting_Load_Int(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_SNIPER_FORCE")
	Setting_Load_String(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_SNIPER_HEIGHT", Buffer, sizeof(Buffer));  zc_leap_sniper_height = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_SNIPER_COOLDOWN", Buffer, sizeof(Buffer));  zc_leap_sniper_cooldown = str_to_float(Buffer)
	zc_leap_assassin = Setting_Load_Int(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_ASSASSIN")
	zc_leap_assassin_force = Setting_Load_Int(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_ASSASSIN_FORCE")
	Setting_Load_String(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_ASSASSIN_HEIGHT", Buffer, sizeof(Buffer));  zc_leap_assassin_height = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_ASSASSIN_COOLDOWN", Buffer, sizeof(Buffer));  zc_leap_assassin_cooldown = str_to_float(Buffer)
	zc_leap_oberon = Setting_Load_Int(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_OBERON")
	zc_leap_oberon_force = Setting_Load_Int(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_OBERON_FORCE")
	Setting_Load_String(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_OBERON_HEIGHT", Buffer, sizeof(Buffer));  zc_leap_oberon_height = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_OBERON_COOLDOWN", Buffer, sizeof(Buffer));  zc_leap_oberon_cooldown = str_to_float(Buffer)
	zc_leap_dragon = Setting_Load_Int(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_DRAGON")
	zc_leap_dragon_force = Setting_Load_Int(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_DRAGON_FORCE")
	Setting_Load_String(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_DRAGON_HEIGHT", Buffer, sizeof(Buffer));  zc_leap_dragon_height = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_DRAGON_COOLDOWN", Buffer, sizeof(Buffer));  zc_leap_dragon_cooldown = str_to_float(Buffer)
	zc_leap_nighter = Setting_Load_Int(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_NIGHTER")
	zc_leap_nighter_force = Setting_Load_Int(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_NIGHTER_FORCE")
	Setting_Load_String(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_NIGHTER_HEIGHT", Buffer, sizeof(Buffer));  zc_leap_nighter_height = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_NIGHTER_COOLDOWN", Buffer, sizeof(Buffer));  zc_leap_nighter_cooldown = str_to_float(Buffer)
	zc_leap_flamer = Setting_Load_Int(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_FLAMER")
	zc_leap_flamer_force = Setting_Load_Int(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_FLAMER_FORCE")
	Setting_Load_String(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_FLAMER_HEIGHT", Buffer, sizeof(Buffer));  zc_leap_flamer_height = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_FLAMER_COOLDOWN", Buffer, sizeof(Buffer));  zc_leap_flamer_cooldown = str_to_float(Buffer)
	zc_leap_zadoc = Setting_Load_Int(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_ZADOC")
	zc_leap_zadoc_force = Setting_Load_Int(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_ZADOC_FORCE")
	Setting_Load_String(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_ZADOC_HEIGHT", Buffer, sizeof(Buffer));  zc_leap_zadoc_height = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Longjump", "ZP_LEAP_ZADOC_COOLDOWN", Buffer, sizeof(Buffer));  zc_leap_zadoc_cooldown = str_to_float(Buffer)

	// Humans
	zc_human_armor_protect = Setting_Load_Int(ZC_SETTINGS_FILE, "Humans", "ZP_HUMAN_ARMOR_PROTECT")
	zc_human_unlimited_ammo = Setting_Load_Int(ZC_SETTINGS_FILE, "Humans", "ZP_HUMAN_UNLIMITED_AMMO")
	zc_human_damage_reward = Setting_Load_Int(ZC_SETTINGS_FILE, "Humans", "ZP_HUMAN_DAMAGE_REWARD")
	zc_human_frags_for_kill = Setting_Load_Int(ZC_SETTINGS_FILE, "Humans", "ZP_HUMAN_FRAGS_FOR_KILL")

	// Grenades
	zc_fire_grenades = Setting_Load_Int(ZC_SETTINGS_FILE, "Grenades", "ZP_FIRE_GRENADES")
	zc_fire_duration = Setting_Load_Int(ZC_SETTINGS_FILE, "Grenades", "ZP_FIRE_DURATION")
	Setting_Load_String(ZC_SETTINGS_FILE, "Grenades", "ZP_FIRE_DAMAGE", Buffer, sizeof(Buffer));  zc_fire_damage = str_to_float(Buffer) 
	Setting_Load_String(ZC_SETTINGS_FILE, "Grenades", "ZP_FIRE_SLOWDOWN", Buffer, sizeof(Buffer));  zc_fire_slowdown = str_to_float(Buffer)
	zc_frost_grenades = Setting_Load_Int(ZC_SETTINGS_FILE, "Grenades", "ZP_FROST_GRENADES")
	Setting_Load_String(ZC_SETTINGS_FILE, "Grenades", "ZP_FROST_DURATION", Buffer, sizeof(Buffer));  zc_frost_duration = str_to_float(Buffer)
	zc_frost_hit = Setting_Load_Int(ZC_SETTINGS_FILE, "Grenades", "ZP_FROST_HIT") 
	zc_explosion_grenades = Setting_Load_Int(ZC_SETTINGS_FILE, "Grenades", "ZP_EXPLOSION_GRENADES")

	// Zombies
	Setting_Load_String(ZC_SETTINGS_FILE, "Zombies", "ZP_ZOMBIE_FIRST_HP", Buffer, sizeof(Buffer));  zc_zombie_first_hp = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Zombies", "ZP_ZOMBIE_ARMOR", Buffer, sizeof(Buffer));  zc_zombie_armor = str_to_float(Buffer) 
	zc_zombie_hitzones = Setting_Load_Int(ZC_SETTINGS_FILE, "Zombies", "ZP_ZOMBIE_HITZONES") 
	zc_zombie_infect_health = Setting_Load_Int(ZC_SETTINGS_FILE, "Zombies", "ZP_ZOMBIE_INFECT_HEALTH")
	zc_zombie_fov = Setting_Load_Int(ZC_SETTINGS_FILE, "Zombies", "ZP_ZOMBIE_FOV") 
	zc_zombie_silent = Setting_Load_Int(ZC_SETTINGS_FILE, "Zombies", "ZP_ZOMBIE_SILENT")
	zc_zombie_painfree = Setting_Load_Int(ZC_SETTINGS_FILE, "Zombies", "ZP_ZOMBIE_PAINFREE")
	zc_zombie_infect_reward = Setting_Load_Int(ZC_SETTINGS_FILE, "Zombies", "ZP_ZOMBIE_INFECT_REWARD")
	zc_zombie_frags_for_infect = Setting_Load_Int(ZC_SETTINGS_FILE, "Zombies", "ZP_ZOMBIE_FRAGS_FOR_INFECT") 
	Setting_Load_String(ZC_SETTINGS_FILE, "Zombies", "ZP_ZOMBIE_DAMAGE", Buffer, sizeof(Buffer));  zc_zombie_damage = str_to_float(Buffer) 

	// Effects
	zc_infection_screenfade = Setting_Load_Int(ZC_SETTINGS_FILE, "Effects", "ZP_INFECTION_SCREENFADE")
	zc_infection_screenshake = Setting_Load_Int(ZC_SETTINGS_FILE, "Effects", "ZP_INFECTION_SCREENSHAKE")
	zc_infection_sparkle = Setting_Load_Int(ZC_SETTINGS_FILE, "Effects", "ZP_INFECTION_SPARKLE")
	zc_infection_tracers = Setting_Load_Int(ZC_SETTINGS_FILE, "Effects", "ZP_INFECTION_TRACERS")
	zc_infection_particles = Setting_Load_Int(ZC_SETTINGS_FILE, "Effects", "ZP_INFECTION_PARTICLES")
	zc_hud_icons = Setting_Load_Int(ZC_SETTINGS_FILE, "Effects", "ZP_HUD_ICONS")
	zc_sniper_frag_gore = Setting_Load_Int(ZC_SETTINGS_FILE, "Effects", "ZP_SNIPER_FRAG_GORE")
	zc_assassin_frag_gore = Setting_Load_Int(ZC_SETTINGS_FILE, "Effects", "ZP_ASSASSIN_FRAG_GORE")

	// Nemesis
	zc_nem_enabled = Setting_Load_Int(ZC_SETTINGS_FILE, "Nemesis", "ZP_NEM_ENABLED")
	zc_nem_chance = Setting_Load_Int(ZC_SETTINGS_FILE, "Nemesis", "ZP_NEM_CHANCE")
	zc_nem_min_players = Setting_Load_Int(ZC_SETTINGS_FILE, "Nemesis", "ZP_NEM_MIN_PLAYERS")
	zc_nem_health = Setting_Load_Int(ZC_SETTINGS_FILE, "Nemesis", "ZP_NEM_HEALTH")
	zc_nem_base_health = Setting_Load_Int(ZC_SETTINGS_FILE, "Nemesis", "ZP_NEM_BASE_HEALTH")
	Setting_Load_String(ZC_SETTINGS_FILE, "Nemesis", "ZP_NEM_SPEED", Buffer, sizeof(Buffer));  zc_nem_speed = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Nemesis", "ZP_NEM_GRAVITY", Buffer, sizeof(Buffer));  zc_nem_gravity = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Nemesis", "ZP_NEM_DAMAGE", Buffer, sizeof(Buffer));  zc_nem_damage = str_to_float(Buffer)
	zc_nem_glow = Setting_Load_Int(ZC_SETTINGS_FILE, "Nemesis", "ZP_NEM_GLOW")
	zc_nem_aura = Setting_Load_Int(ZC_SETTINGS_FILE, "Nemesis", "ZP_NEM_AURA")
	zc_nem_painfree = Setting_Load_Int(ZC_SETTINGS_FILE, "Nemesis", "ZP_NEM_PAINFREE")
	zc_nem_ignore_frags = Setting_Load_Int(ZC_SETTINGS_FILE, "Nemesis", "ZP_NEM_IGNORE_FRAGS")
	zc_nem_ignore_rewards = Setting_Load_Int(ZC_SETTINGS_FILE, "Nemesis", "ZP_NEM_IGNORE_REWARDS")

	// Survivor
	zc_surv_enabled = Setting_Load_Int(ZC_SETTINGS_FILE, "Survivor", "ZP_SURV_ENABLED")
	zc_surv_chance = Setting_Load_Int(ZC_SETTINGS_FILE, "Survivor", "ZP_SURV_CHANCE")
	zc_surv_min_players = Setting_Load_Int(ZC_SETTINGS_FILE, "Survivor", "ZP_SURV_MIN_PLAYERS")
	zc_surv_health = Setting_Load_Int(ZC_SETTINGS_FILE, "Survivor", "ZP_SURV_HEALTH")
	zc_surv_base_health = Setting_Load_Int(ZC_SETTINGS_FILE, "Survivor", "ZP_SURV_BASE_HEALTH")
	Setting_Load_String(ZC_SETTINGS_FILE, "Survivor", "ZP_SURV_SPEED", Buffer, sizeof(Buffer));  zc_surv_speed = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Survivor", "ZP_SURV_GRAVITY", Buffer, sizeof(Buffer));  zc_surv_gravity = str_to_float(Buffer) 
	zc_surv_glow = Setting_Load_Int(ZC_SETTINGS_FILE, "Survivor", "ZP_SURV_GLOW")
	zc_surv_aura = Setting_Load_Int(ZC_SETTINGS_FILE, "Survivor", "ZP_SURV_AURA")
	zc_surv_aura_r = Setting_Load_Int(ZC_SETTINGS_FILE, "Survivor", "ZP_SURV_AURA_R")
	zc_surv_aura_g = Setting_Load_Int(ZC_SETTINGS_FILE, "Survivor", "ZP_SURV_AURA_G")
	zc_surv_aura_b = Setting_Load_Int(ZC_SETTINGS_FILE, "Survivor", "ZP_SURV_AURA_B")
	zc_surv_aura_size = Setting_Load_Int(ZC_SETTINGS_FILE, "Survivor", "ZP_SURV_AURA_SIZE")
	zc_surv_painfree = Setting_Load_Int(ZC_SETTINGS_FILE, "Survivor", "ZP_SURV_PAINFREE")
	zc_surv_ignore_frags = Setting_Load_Int(ZC_SETTINGS_FILE, "Survivor", "ZP_SURV_IGNORE_FRAGS")
	zc_surv_ignore_rewards = Setting_Load_Int(ZC_SETTINGS_FILE, "Survivor", "ZP_SURV_IGNORE_REWARDS")
	Setting_Load_String(ZC_SETTINGS_FILE, "Survivor", "ZP_SURV_DAMAGE", Buffer, sizeof(Buffer));  zc_surv_damage = str_to_float(Buffer)
	zc_surv_unlimited_ammo = Setting_Load_Int(ZC_SETTINGS_FILE, "Survivor", "ZP_SURV_UNLIMITED_AMMO")

	// Swarm
	zc_swarm_enabled = Setting_Load_Int(ZC_SETTINGS_FILE, "Swarm", "ZP_SWARM_ENABLED")
	zc_swarm_chance = Setting_Load_Int(ZC_SETTINGS_FILE, "Swarm", "ZP_SWARM_CHANCE")
	zc_swarm_min_players = Setting_Load_Int(ZC_SETTINGS_FILE, "Swarm", "ZP_SWARM_MIN_PLAYERS")

	// Multiinfection
	zc_multi_enabled = Setting_Load_Int(ZC_SETTINGS_FILE, "Multiinfection", "ZP_MULTI_ENABLED")
	zc_multi_chance = Setting_Load_Int(ZC_SETTINGS_FILE, "Multiinfection", "ZP_MULTI_CHANCE")
	zc_multi_min_players = Setting_Load_Int(ZC_SETTINGS_FILE, "Multiinfection", "ZP_MULTI_MIN_PLAYERS")
	Setting_Load_String(ZC_SETTINGS_FILE, "Multiinfection", "ZP_MULTI_RATIO", Buffer, sizeof(Buffer));  zc_multi_ratio = str_to_float(Buffer)

	// Plague
	zc_plague_enabled = Setting_Load_Int(ZC_SETTINGS_FILE, "Plague", "ZP_PLAGUE_ENABLED")
	zc_plague_chance = Setting_Load_Int(ZC_SETTINGS_FILE, "Plague", "ZP_PLAGUE_CHANCE") 
	zc_plague_min_players = Setting_Load_Int(ZC_SETTINGS_FILE, "Plague", "ZP_PLAGUE_MIN_PLAYERS") 
	Setting_Load_String(ZC_SETTINGS_FILE, "Plague", "ZP_PLAGUE_RATIO", Buffer, sizeof(Buffer));  zc_plague_ratio = str_to_float(Buffer) 
	zc_plague_nem_number = Setting_Load_Int(ZC_SETTINGS_FILE, "Plague", "ZP_PLAGUE_NEM_NUMBER") 
	Setting_Load_String(ZC_SETTINGS_FILE, "Plague", "ZP_PLAGUE_NEM_HP_MULTI", Buffer, sizeof(Buffer));  zc_plague_nem_hp_multi = str_to_float(Buffer) 
	zc_plague_surv_number = Setting_Load_Int(ZC_SETTINGS_FILE, "Plague", "ZP_PLAGUE_SURV_NUMBER")
	Setting_Load_String(ZC_SETTINGS_FILE, "Plague", "ZP_PLAGUE_SURV_HP_MULTI", Buffer, sizeof(Buffer));  zc_plague_surv_hp_multi = str_to_float(Buffer)

	// Sniper
	zc_sniper_enabled = Setting_Load_Int(ZC_SETTINGS_FILE, "Sniper", "ZP_SNIPER_ENABLED")
	zc_sniper_chance = Setting_Load_Int(ZC_SETTINGS_FILE, "Sniper", "ZP_SNIPER_CHANCE")
	zc_sniper_min_players = Setting_Load_Int(ZC_SETTINGS_FILE, "Sniper", "ZP_SNIPER_MIN_PLAYERS")
	zc_sniper_health = Setting_Load_Int(ZC_SETTINGS_FILE, "Sniper", "ZP_SNIPER_HEALTH")
	zc_sniper_base_health = Setting_Load_Int(ZC_SETTINGS_FILE, "Sniper", "ZP_SNIPER_BASE_HEALTH")
	Setting_Load_String(ZC_SETTINGS_FILE, "Sniper", "ZP_SNIPER_SPEED", Buffer, sizeof(Buffer));  zc_sniper_speed = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Sniper", "ZP_SNIPER_GRAVITY", Buffer, sizeof(Buffer));  zc_sniper_gravity = str_to_float(Buffer)
	zc_sniper_glow = Setting_Load_Int(ZC_SETTINGS_FILE, "Sniper", "ZP_SNIPER_GLOW")
	zc_sniper_aura = Setting_Load_Int(ZC_SETTINGS_FILE, "Sniper", "ZP_SNIPER_AURA")
	zc_sniper_aura_color_r = Setting_Load_Int(ZC_SETTINGS_FILE, "Sniper", "ZP_SNIPER_AURA_COLOR_R")
	zc_sniper_aura_color_g = Setting_Load_Int(ZC_SETTINGS_FILE, "Sniper", "ZP_SNIPER_AURA_COLOR_G")
	zc_sniper_aura_color_b = Setting_Load_Int(ZC_SETTINGS_FILE, "Sniper", "ZP_SNIPER_AURA_COLOR_B")
	zc_sniper_aura_size = Setting_Load_Int(ZC_SETTINGS_FILE, "Sniper", "ZP_SNIPER_AURA_SIZE")
	zc_sniper_painfree = Setting_Load_Int(ZC_SETTINGS_FILE, "Sniper", "ZP_SNIPER_PAINFREE")
	zc_sniper_ignore_frags = Setting_Load_Int(ZC_SETTINGS_FILE, "Sniper", "ZP_SNIPER_IGNORE_FRAGS")
	zc_sniper_ignore_rewards = Setting_Load_Int(ZC_SETTINGS_FILE, "Sniper", "ZP_SNIPER_IGNORE_REWARDS")
	Setting_Load_String(ZC_SETTINGS_FILE, "Sniper", "ZP_SNIPER_DAMAGE", Buffer, sizeof(Buffer));  zc_sniper_damage = str_to_float(Buffer)
	zc_sniper_unlimited_ammo = Setting_Load_Int(ZC_SETTINGS_FILE, "Sniper", "ZP_SNIPER_UNLIMITED_AMMO")

	// Assassin
	zc_assassin_enabled = Setting_Load_Int(ZC_SETTINGS_FILE, "Assassin", "ZP_ASSASSIN_ENABLED")
	zc_assassin_chance = Setting_Load_Int(ZC_SETTINGS_FILE, "Assassin", "ZP_ASSASSIN_CHANCE")
	zc_assassin_min_players = Setting_Load_Int(ZC_SETTINGS_FILE, "Assassin", "ZP_ASSASSIN_MIN_PLAYERS")
	zc_assassin_health = Setting_Load_Int(ZC_SETTINGS_FILE, "Assassin", "ZP_ASSASSIN_HEALTH")
	zc_assassin_base_health = Setting_Load_Int(ZC_SETTINGS_FILE, "Assassin", "ZP_ASSASSIN_BASE_HEALTH")
	Setting_Load_String(ZC_SETTINGS_FILE, "Assassin", "ZP_ASSASSIN_SPEED", Buffer, sizeof(Buffer));  zc_assassin_speed = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Assassin", "ZP_ASSASSIN_GRAVITY", Buffer, sizeof(Buffer));  zc_assassin_gravity = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Assassin", "ZP_ASSASSIN_DAMAGE", Buffer, sizeof(Buffer));  zc_assassin_damage = str_to_float(Buffer)
	zc_assassin_glow = Setting_Load_Int(ZC_SETTINGS_FILE, "Assassin", "ZP_ASSASSIN_GLOW")
	zc_assassin_aura = Setting_Load_Int(ZC_SETTINGS_FILE, "Assassin", "ZP_ASSASSIN_AURA")
	zc_assassin_painfree = Setting_Load_Int(ZC_SETTINGS_FILE, "Assassin", "ZP_ASSASSIN_PAINFREE")
	zc_assassin_ignore_frags = Setting_Load_Int(ZC_SETTINGS_FILE, "Assassin", "ZP_ASSASSIN_IGNORE_FRAGS")
	zc_assassin_ignore_rewards = Setting_Load_Int(ZC_SETTINGS_FILE, "Assassin", "ZP_ASSASSIN_IGNORE_REWARDS")

	// Flamer
	zc_flamer_enabled = Setting_Load_Int(ZC_SETTINGS_FILE, "Flamer", "ZP_FLAMER_ENABLED")
	zc_flamer_chance = Setting_Load_Int(ZC_SETTINGS_FILE, "Flamer", "ZP_FLAMER_CHANCE")
	zc_flamer_min_players = Setting_Load_Int(ZC_SETTINGS_FILE, "Flamer", "ZP_FLAMER_MIN_PLAYERS")
	zc_flamer_health = Setting_Load_Int(ZC_SETTINGS_FILE, "Flamer", "ZP_FLAMER_HEALTH")
	Setting_Load_String(ZC_SETTINGS_FILE, "Flamer", "ZP_FLAMER_SPEED", Buffer, sizeof(Buffer));  zc_flamer_speed = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Flamer", "ZP_FLAMER_GRAVITY", Buffer, sizeof(Buffer));  zc_flamer_gravity = str_to_float(Buffer)
	zc_flamer_glow = Setting_Load_Int(ZC_SETTINGS_FILE, "Flamer", "ZP_FLAMER_GLOW")
	zc_flamer_aura = Setting_Load_Int(ZC_SETTINGS_FILE, "Flamer", "ZP_FLAMER_AURA")
	zc_flamer_aura_size = Setting_Load_Int(ZC_SETTINGS_FILE, "Flamer", "ZP_FLAMER_AURA_SIZE")
	zc_flamer_aura_color_r = Setting_Load_Int(ZC_SETTINGS_FILE, "Flamer", "ZP_FLAMER_AURA_COLOR_R")
	zc_flamer_aura_color_g = Setting_Load_Int(ZC_SETTINGS_FILE, "Flamer", "ZP_FLAMER_AURA_COLOR_G")
	zc_flamer_aura_color_b = Setting_Load_Int(ZC_SETTINGS_FILE, "Flamer", "ZP_FLAMER_AURA_COLOR_B")
	Setting_Load_String(ZC_SETTINGS_FILE, "Flamer", "ZP_FLAMER_DAMAGE", Buffer, sizeof(Buffer));  zc_flamer_damage = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Flamer", "ZP_FLAMER_FIRE_DELAY", Buffer, sizeof(Buffer));  zc_flamer_fire_delay = str_to_float(Buffer)
	zc_flamer_max_clip = Setting_Load_Int(ZC_SETTINGS_FILE, "Flamer", "ZP_FLAMER_MAX_CLIP")
	zc_flamer_painfree = Setting_Load_Int(ZC_SETTINGS_FILE, "Flamer", "ZP_FLAMER_PAINFREE")
	zc_flamer_ignore_frags = Setting_Load_Int(ZC_SETTINGS_FILE, "Flamer", "ZP_FLAMER_IGNORE_FRAGS")
	zc_flamer_ignore_rewards = Setting_Load_Int(ZC_SETTINGS_FILE, "Flamer", "ZP_FLAMER_IGNORE_REWARDS")

	// Zadoc
	zc_zadoc_enabled = Setting_Load_Int(ZC_SETTINGS_FILE, "Zadoc", "ZP_ZADOC_ENABLED")
	zc_zadoc_chance = Setting_Load_Int(ZC_SETTINGS_FILE, "Zadoc", "ZP_ZADOC_CHANCE")
	zc_zadoc_min_players = Setting_Load_Int(ZC_SETTINGS_FILE, "Zadoc", "ZP_ZADOC_MIN_PLAYERS")
	zc_zadoc_health = Setting_Load_Int(ZC_SETTINGS_FILE, "Zadoc", "ZP_ZADOC_HEALTH")
	Setting_Load_String(ZC_SETTINGS_FILE, "Zadoc", "ZP_ZADOC_SPEED", Buffer, sizeof(Buffer));  zc_zadoc_speed = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Zadoc", "ZP_ZADOC_GRAVITY", Buffer, sizeof(Buffer));  zc_zadoc_gravity = str_to_float(Buffer)
	zc_zadoc_glow = Setting_Load_Int(ZC_SETTINGS_FILE, "Zadoc", "ZP_ZADOC_GLOW")
	zc_zadoc_aura = Setting_Load_Int(ZC_SETTINGS_FILE, "Zadoc", "ZP_ZADOC_AURA")
	zc_zadoc_aura_size = Setting_Load_Int(ZC_SETTINGS_FILE, "Zadoc", "ZP_ZADOC_AURA_SIZE")
	zc_zadoc_aura_color_r = Setting_Load_Int(ZC_SETTINGS_FILE, "Zadoc", "ZP_ZADOC_AURA_COLOR_R")
	zc_zadoc_aura_color_g = Setting_Load_Int(ZC_SETTINGS_FILE, "Zadoc", "ZP_ZADOC_AURA_COLOR_G")
	zc_zadoc_aura_color_b = Setting_Load_Int(ZC_SETTINGS_FILE, "Zadoc", "ZP_ZADOC_AURA_COLOR_B")
	Setting_Load_String(ZC_SETTINGS_FILE, "Zadoc", "ZP_ZADOC_DAMAGE", Buffer, sizeof(Buffer));  zc_zadoc_damage = str_to_float(Buffer)
	zc_zadoc_painfree = Setting_Load_Int(ZC_SETTINGS_FILE, "Zadoc", "ZP_ZADOC_PAINFREE")
	zc_zadoc_ignore_frags = Setting_Load_Int(ZC_SETTINGS_FILE, "Zadoc", "ZP_ZADOC_IGNORE_FRAGS")
	zc_zadoc_ignore_rewards = Setting_Load_Int(ZC_SETTINGS_FILE, "Zadoc", "ZP_ZADOC_IGNORE_REWARDS")
	Setting_Load_String(ZC_SETTINGS_FILE, "Zadoc", "ZP_ZADOC_RADIUS", Buffer, sizeof(Buffer));  zc_zadoc_radius = str_to_float(Buffer)
	zc_zadoc_power_delay = Setting_Load_Int(ZC_SETTINGS_FILE, "Zadoc", "ZP_ZADOC_POWER_DELAY")

	// Genesys
	zc_genesys_enabled = Setting_Load_Int(ZC_SETTINGS_FILE, "Genesys", "ZP_GENESYS_ENABLED")
	zc_genesys_chance = Setting_Load_Int(ZC_SETTINGS_FILE, "Genesys", "ZP_GENESYS_CHANCE")
	zc_genesys_min_players = Setting_Load_Int(ZC_SETTINGS_FILE, "Genesys", "ZP_GENESYS_MIN_PLAYERS")
	zc_genesys_health = Setting_Load_Int(ZC_SETTINGS_FILE, "Genesys", "ZP_GENESYS_HEALTH")
	Setting_Load_String(ZC_SETTINGS_FILE, "Genesy", "ZP_GENESYS_DAMAGE", Buffer, sizeof(Buffer));  zc_genesys_damage = str_to_float(Buffer)
	zc_genesys_ignore_frags = Setting_Load_Int(ZC_SETTINGS_FILE, "Genesys", "ZP_GENESYS_IGNORE_FRAGS")
	zc_genesys_ignore_rewards = Setting_Load_Int(ZC_SETTINGS_FILE, "Genesys", "ZP_GENESYS_IGNORE_REWARDS")
	zc_genesys_flames_dmg = Setting_Load_Int(ZC_SETTINGS_FILE, "Genesys", "ZP_GENESYS_FLAMES_DMG")
	zc_genesys_locust_delay = Setting_Load_Int(ZC_SETTINGS_FILE, "Genesys", "ZP_GENESYS_LOCUST_DELAY")

	// Oberon
	zc_oberon_enabled = Setting_Load_Int(ZC_SETTINGS_FILE, "Oberon", "ZP_OBERON_ENABLED")
	zc_oberon_chance = Setting_Load_Int(ZC_SETTINGS_FILE, "Oberon", "ZP_OBERON_CHANCE")
	zc_oberon_min_players = Setting_Load_Int(ZC_SETTINGS_FILE, "Oberon", "ZP_OBERON_MIN_PLAYERS")
	zc_oberon_health = Setting_Load_Int(ZC_SETTINGS_FILE, "Oberon", "ZP_OBERON_HEALTH")
	zc_oberon_base_health = Setting_Load_Int(ZC_SETTINGS_FILE, "Oberon", "ZP_OBERON_BASE_HEALTH")
	Setting_Load_String(ZC_SETTINGS_FILE, "Oberon", "ZP_OBERON_SPEED", Buffer, sizeof(Buffer));  zc_oberon_speed = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Oberon", "ZP_OBERON_GRAVITY", Buffer, sizeof(Buffer));  zc_oberon_gravity = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Oberon", "ZP_OBERON_DAMAGE", Buffer, sizeof(Buffer));  zc_oberon_damage = str_to_float(Buffer)
	zc_oberon_glow = Setting_Load_Int(ZC_SETTINGS_FILE, "Oberon", "ZP_OBERON_GLOW")
	zc_oberon_aura = Setting_Load_Int(ZC_SETTINGS_FILE, "Oberon", "ZP_OBERON_AURA")
	zc_oberon_painfree = Setting_Load_Int(ZC_SETTINGS_FILE, "Oberon", "ZP_OBERON_PAINFREE")
	zc_oberon_ignore_frags = Setting_Load_Int(ZC_SETTINGS_FILE, "Oberon", "ZP_OBERON_IGNORE_FRAGS")
	zc_oberon_ignore_rewards = Setting_Load_Int(ZC_SETTINGS_FILE, "Oberon", "ZP_OBERON_IGNORE_REWARDS")
	zc_oberon_hole_cd = Setting_Load_Int(ZC_SETTINGS_FILE, "Oberon", "ZP_OBERON_HOLE_CD")
	zc_oberon_bomb_cd = Setting_Load_Int(ZC_SETTINGS_FILE, "Oberon", "ZP_OBERON_BOMB_CD")

	// Dragon
	zc_dragon_enabled = Setting_Load_Int(ZC_SETTINGS_FILE, "Dragon", "ZP_DRAGON_ENABLED")
	zc_dragon_chance = Setting_Load_Int(ZC_SETTINGS_FILE, "Dragon", "ZP_DRAGON_CHANCE")
	zc_dragon_min_players = Setting_Load_Int(ZC_SETTINGS_FILE, "Dragon", "ZP_DRAGON_MIN_PLAYERS")
	zc_dragon_health = Setting_Load_Int(ZC_SETTINGS_FILE, "Dragon", "ZP_DRAGON_HEALTH")
	zc_dragon_base_health = Setting_Load_Int(ZC_SETTINGS_FILE, "Dragon", "ZP_DRAGON_BASE_HEALTH")
	Setting_Load_String(ZC_SETTINGS_FILE, "Dragon", "ZP_DRAGON_SPEED", Buffer, sizeof(Buffer));  zc_dragon_speed = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Dragon", "ZP_DRAGON_GRAVITY", Buffer, sizeof(Buffer));  zc_dragon_gravity = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Dragon", "ZP_DRAGON_DAMAGE", Buffer, sizeof(Buffer));  zc_dragon_damage = str_to_float(Buffer)
	zc_dragon_glow = Setting_Load_Int(ZC_SETTINGS_FILE, "Dragon", "ZP_DRAGON_GLOW")
	zc_dragon_aura = Setting_Load_Int(ZC_SETTINGS_FILE, "Dragon", "ZP_DRAGON_AURA")
	zc_dragon_painfree = Setting_Load_Int(ZC_SETTINGS_FILE, "Dragon", "ZP_DRAGON_PAINFREE")
	zc_dragon_ignore_frags = Setting_Load_Int(ZC_SETTINGS_FILE, "Dragon", "ZP_DRAGON_IGNORE_FRAGS")
	zc_dragon_ignore_rewards = Setting_Load_Int(ZC_SETTINGS_FILE, "Dragon", "ZP_DRAGON_IGNORE_REWARDS")
	Setting_Load_String(ZC_SETTINGS_FILE, "Dragon", "ZP_DRAGON_FROST_CD", Buffer, sizeof(Buffer));  zc_dragon_frost_cd = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Dragon", "ZP_DRAGON_FROST_DELAY", Buffer, sizeof(Buffer));  zc_dragon_frost_delay = str_to_float(Buffer)

	// Nighter
	zc_nighter_enabled = Setting_Load_Int(ZC_SETTINGS_FILE, "Nighter", "ZP_NIGHTER_ENABLED")
	zc_nighter_chance = Setting_Load_Int(ZC_SETTINGS_FILE, "Nighter", "ZP_NIGHTER_CHANCE")
	zc_nighter_min_players = Setting_Load_Int(ZC_SETTINGS_FILE, "Nighter", "ZP_NIGHTER_MIN_PLAYERS")
	zc_nighter_health = Setting_Load_Int(ZC_SETTINGS_FILE, "Nighter", "ZP_NIGHTER_HEALTH")
	zc_nighter_base_health = Setting_Load_Int(ZC_SETTINGS_FILE, "Nighter", "ZP_NIGHTER_BASE_HEALTH")
	Setting_Load_String(ZC_SETTINGS_FILE, "Nighter", "ZP_NIGHTER_SPEED", Buffer, sizeof(Buffer));  zc_nighter_speed = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Nighter", "ZP_NIGHTER_GRAVITY", Buffer, sizeof(Buffer));  zc_nighter_gravity = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Nighter", "ZP_NIGHTER_DAMAGE", Buffer, sizeof(Buffer));  zc_nighter_damage = str_to_float(Buffer)
	zc_nighter_painfree = Setting_Load_Int(ZC_SETTINGS_FILE, "Nighter", "ZP_NIGHTER_PAINFREE")
	zc_nighter_ignore_frags = Setting_Load_Int(ZC_SETTINGS_FILE, "Nighter", "ZP_NIGHTER_IGNORE_FRAGS")
	zc_nighter_ignore_rewards = Setting_Load_Int(ZC_SETTINGS_FILE, "Nighter", "ZP_NIGHTER_IGNORE_REWARDS")
	zc_nighter_xp_reward = Setting_Load_Int(ZC_SETTINGS_FILE, "Nighter", "ZP_NIGHTER_XP_REWARD")
	zc_nighter_blink_cd = Setting_Load_Int(ZC_SETTINGS_FILE, "Nighter", "ZP_NIGHTER_BLINK_CD")

	// Nighter Child
	zc_nchild_health = Setting_Load_Int(ZC_SETTINGS_FILE, "Nchild", "ZP_NCHILD_HEALTH")
	Setting_Load_String(ZC_SETTINGS_FILE, "Nchild", "ZP_NCHILD_DAMAGE", Buffer, sizeof(Buffer));  zc_nchild_damage = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Nchild", "ZP_NCHILD_SPEED", Buffer, sizeof(Buffer));  zc_nchild_speed = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Nchild", "ZP_NCHILD_GRAVITY", Buffer, sizeof(Buffer));  zc_nchild_gravity = str_to_float(Buffer)
	zc_nchild_xp_to_nighter = Setting_Load_Int(ZC_SETTINGS_FILE, "Nchild", "ZP_NCHILD_XP_TO_NIGHTER")
	zc_nchild_packs_to_nighter = Setting_Load_Int(ZC_SETTINGS_FILE, "Nchild", "ZP_NCHILD_PACKS_TO_NIGHTER")
	zc_nchild_coins_to_nighter = Setting_Load_Int(ZC_SETTINGS_FILE, "Nchild", "ZP_NCHILD_COINS_TO_NIGHTER")

	// LNJ
	zc_lnj_enabled = Setting_Load_Int(ZC_SETTINGS_FILE, "Lnj", "ZP_LNJ_ENABLED")
	zc_lnj_chance = Setting_Load_Int(ZC_SETTINGS_FILE, "Lnj", "ZP_LNJ_CHANCE")
	zc_lnj_min_players = Setting_Load_Int(ZC_SETTINGS_FILE, "Lnj", "ZP_LNJ_MIN_PLAYERS")
	Setting_Load_String(ZC_SETTINGS_FILE, "Lnj", "ZP_LNJ_NEM_HP_MULTI", Buffer, sizeof(Buffer));  zc_lnj_nem_hp_multi = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Lnj", "ZP_LNJ_SURV_HP_MULTI", Buffer, sizeof(Buffer));  zc_lnj_surv_hp_multi = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Lnj", "ZP_LNJ_RATIO", Buffer, sizeof(Buffer));  zc_lnj_ratio = str_to_float(Buffer)

	// Guardians
	zc_guardians_enabled = Setting_Load_Int(ZC_SETTINGS_FILE, "Guardians", "ZP_GUARDIANS_ENABLED")
	zc_guardians_chance = Setting_Load_Int(ZC_SETTINGS_FILE, "Guardians", "ZP_GUARDIANS_CHANCE")
	zc_guardians_min_players = Setting_Load_Int(ZC_SETTINGS_FILE, "Guardians", "ZP_GUARDIANS_MIN_PLAYERS")
	zc_evil_health = Setting_Load_Int(ZC_SETTINGS_FILE, "Guardians", "ZP_EVIL_HEALTH")
	Setting_Load_String(ZC_SETTINGS_FILE, "Guardians", "ZP_EVIL_DAMAGE", Buffer, sizeof(Buffer));  zc_evil_damage = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Guardians", "ZP_EVIL_SPEED", Buffer, sizeof(Buffer));  zc_evil_speed = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Guardians", "ZP_EVIL_GRAVITY", Buffer, sizeof(Buffer));  zc_evil_gravity = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Guardians", "ZP_KNOCKBACK_EVIL", Buffer, sizeof(Buffer));  zc_knockback_evil = str_to_float(Buffer)
	zc_hero_health = Setting_Load_Int(ZC_SETTINGS_FILE, "Guardians", "ZP_HERO_HEALTH")
	Setting_Load_String(ZC_SETTINGS_FILE, "Guardians", "ZP_HERO_SPEED", Buffer, sizeof(Buffer));  zc_hero_speed = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Guardians", "ZP_HERO_GRAVITY", Buffer, sizeof(Buffer));  zc_hero_gravity = str_to_float(Buffer)
	zc_hero_unlimited_ammo = Setting_Load_Int(ZC_SETTINGS_FILE, "Guardians", "ZP_HERO_UNLIMITED_AMMO")

	// Powers
	zc_chain_cooldown = Setting_Load_Int(ZC_SETTINGS_FILE, "Powers", "ZP_CHAIN_COOLDOWN")
	zc_blink_cooldown = Setting_Load_Int(ZC_SETTINGS_FILE, "Powers", "ZP_BLINK_COOLDOWN")
	zc_powers_prices[0] = Setting_Load_Int(ZC_SETTINGS_FILE, "Powers", "ZP_POWERS_PRICE_HP")
	zc_powers_prices[1] = Setting_Load_Int(ZC_SETTINGS_FILE, "Powers", "ZP_POWERS_PRICE_ARMOR")
	zc_powers_prices[2] = Setting_Load_Int(ZC_SETTINGS_FILE, "Powers", "ZP_POWERS_PRICE_SPEED")
	zc_powers_prices[3] = Setting_Load_Int(ZC_SETTINGS_FILE, "Powers", "ZP_POWERS_PRICE_ASPIRINE")
	zc_powers_prices[4] = Setting_Load_Int(ZC_SETTINGS_FILE, "Powers", "ZP_POWERS_PRICE_BLINK")
	zc_powers_prices[5] = Setting_Load_Int(ZC_SETTINGS_FILE, "Powers", "ZP_POWERS_PRICE_THUNDERBOLT")
	zc_powers_prices[6] = Setting_Load_Int(ZC_SETTINGS_FILE, "Powers", "ZP_POWERS_PRICE_WALLHANG")
	zc_powers_levels[0] = Setting_Load_Int(ZC_SETTINGS_FILE, "Powers", "ZP_POWERS_LEVELS_HP")
	zc_powers_levels[1] = Setting_Load_Int(ZC_SETTINGS_FILE, "Powers", "ZP_POWERS_LEVELS_ARMOR")
	zc_powers_levels[2] = Setting_Load_Int(ZC_SETTINGS_FILE, "Powers", "ZP_POWERS_LEVELS_SPEED")
	zc_powers_levels[3] = Setting_Load_Int(ZC_SETTINGS_FILE, "Powers", "ZP_POWERS_LEVELS_ASPIRINE")
	zc_powers_levels[4] = Setting_Load_Int(ZC_SETTINGS_FILE, "Powers", "ZP_POWERS_LEVELS_BLINK")
	zc_powers_levels[5] = Setting_Load_Int(ZC_SETTINGS_FILE, "Powers", "ZP_POWERS_LEVELS_THUNDERBOLT")
	zc_powers_levels[6] = Setting_Load_Int(ZC_SETTINGS_FILE, "Powers", "ZP_POWERS_LEVELS_WALLHANG")
	zc_powers_hp_rate = Setting_Load_Int(ZC_SETTINGS_FILE, "Powers", "ZP_POWERS_HP_RATE")
	zc_powers_speed_rate = Setting_Load_Int(ZC_SETTINGS_FILE, "Powers", "ZP_POWERS_SPEED_RATE")
	zc_powers_asp_rate = Setting_Load_Int(ZC_SETTINGS_FILE, "Powers", "ZP_POWERS_ASP_RATE")

	// Vip
	zc_vip_jumps = Setting_Load_Int(ZC_SETTINGS_FILE, "Vip", "ZP_VIP_JUMPS")
	zc_player_jumps = Setting_Load_Int(ZC_SETTINGS_FILE, "Vip", "ZP_PLAYER_JUMPS")
	zc_vip_armor = Setting_Load_Int(ZC_SETTINGS_FILE, "Vip", "ZP_VIP_ARMOR")
	zc_vip_armor_happy = Setting_Load_Int(ZC_SETTINGS_FILE, "Vip", "ZP_VIP_ARMOR_HAPPY")
	zc_vip_killammo = Setting_Load_Int(ZC_SETTINGS_FILE, "Vip", "ZP_VIP_KILLAMMO")
	zc_vip_unlimited_clip = Setting_Load_Int(ZC_SETTINGS_FILE, "Vip", "ZP_VIP_UNLIMITED_CLIP")
	zc_vip_no_recoil = Setting_Load_Int(ZC_SETTINGS_FILE, "Vip", "ZP_VIP_NO_RECOIL")
	zc_vip_damage_reward = Setting_Load_Int(ZC_SETTINGS_FILE, "Vip", "ZP_VIP_DAMAGE_REWARD")
	zc_vip_damage_increase = Setting_Load_Int(ZC_SETTINGS_FILE, "Vip", "ZP_VIP_DAMAGE_INCREASE")
	zc_vip_buy_time = Setting_Load_Int(ZC_SETTINGS_FILE, "Vip", "ZP_VIP_BUY_TIME")
	zc_vip_hour_init = Setting_Load_Int(ZC_SETTINGS_FILE, "Vip", "ZP_VIP_HOUR_INIT")
	zc_vip_hour_end = Setting_Load_Int(ZC_SETTINGS_FILE, "Vip", "ZP_VIP_HOUR_END")
	Setting_Load_String(ZC_SETTINGS_FILE, "Vip", "ZP_VIP_HUD_XPOS", Buffer, sizeof(Buffer));  zc_vip_hud_xpos = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Vip", "ZP_VIP_HUD_YPOS", Buffer, sizeof(Buffer));  zc_vip_hud_ypos = str_to_float(Buffer)
	Setting_Load_String(ZC_SETTINGS_FILE, "Vip", "ZP_VIP_HUD_COLOR", Buffer, sizeof(Buffer))
	parse(Buffer, Buffer2[0], 7, Buffer2[1], 7, Buffer2[2], 7)
	zc_vip_hud_color[0] = str_to_num(Buffer2[0])
	zc_vip_hud_color[1] = str_to_num(Buffer2[1])
	zc_vip_hud_color[2] = str_to_num(Buffer2[2])
	zc_vip_hud_enable = Setting_Load_Int(ZC_SETTINGS_FILE, "Vip", "ZP_VIP_HUD_ENABLE")

	// Coinshop
	zc_coins_max_modes = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_MAX_MODES")
	zc_coins_prices[0] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_PRICE_HP")
	zc_coins_prices[1] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_PRICE_INVISIBILITY1")
	zc_coins_prices[2] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_PRICE_SHOTGUN")
	zc_coins_prices[3] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_PRICE_GRENADE")
	zc_coins_prices[4] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_PRICE_INVISIBILITY2")
	zc_coins_prices[5] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_PRICE_NOCLIP")
	zc_coins_prices[6] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_PRICE_GODMODE")
	zc_coins_prices[7] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_PRICE_MODEL")
	zc_coins_prices[8] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_PRICE_VIP")
	zc_coins_prices[9] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_PRICE_SNIPER")
	zc_coins_prices[10] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_PRICE_SURVIVOR")
	zc_coins_prices[11] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_PRICE_GENESYS")
	zc_coins_prices[12] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_PRICE_FLAMER")
	zc_coins_prices[13] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_PRICE_ASSASSIN")
	zc_coins_prices[14] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_PRICE_NEMESIS")
	zc_coins_prices[15] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_PRICE_OBERON")
	zc_coins_prices[16] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_PRICE_ZADOC")
	zc_coins_prices[17] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_PRICE_DRAGON")
	zc_coins_prices[18] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_PRICE_NIGHTER")
	zc_coins_prices[19] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_PRICE_LNJ")
	zc_coins_prices[20] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_PRICE_SWARM")
	zc_coins_prices[21] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_PRICE_PLAGUE")
	zc_coins_prices[22] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_PRICE_GUARDIANS")
	zc_coins_items_limit[0] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_LIMIT_HP")
	zc_coins_items_limit[1] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_LIMIT_NOCLIP")
	zc_coins_items_limit[2] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_LIMIT_GODMODE")
	zc_coins_items_limit[3] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_LIMIT_SURVIVOR")
	zc_coins_items_limit[4] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_LIMIT_NEMESIS")
	zc_coins_items_limit[5] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_LIMIT_SNIPER")
	zc_coins_items_limit[6] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_LIMIT_ASSASSIN")
	zc_coins_items_limit[7] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_LIMIT_FLAMER")
	zc_coins_items_limit[8] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_LIMIT_GENESYS")
	zc_coins_items_limit[9] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_LIMIT_OBERON")
	zc_coins_items_limit[10] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_LIMIT_DRAGON")
	zc_coins_items_limit[11] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_LIMIT_ZADOC")
	zc_coins_items_limit[12] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_LIMIT_NIGHTER")
	zc_coins_items_limit[13] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_LIMIT_PLAGUE")
	zc_coins_items_limit[14] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_LIMIT_SWARM")
	zc_coins_items_limit[15] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_LIMIT_LNJ")
	zc_coins_items_limit[16] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_LIMIT_INV1")
	zc_coins_items_limit[17] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_LIMIT_INV2")
	zc_coins_items_limit[18] = Setting_Load_Int(ZC_SETTINGS_FILE, "Coinshop", "ZP_COINS_LIMIT_GUARDIANS")

	// Steps
	zc_max_level = Setting_Load_Int(ZC_SETTINGS_FILE, "Steps", "ZP_LEVEL_MAX")
	zc_level_step = Setting_Load_Int(ZC_SETTINGS_FILE, "Steps", "ZP_LEVEL_STEP")
	zc_xp_step[0] = Setting_Load_Int(ZC_SETTINGS_FILE, "Steps", "ZP_XP_PLAYER_HUMAN")
	zc_xp_step[1] = Setting_Load_Int(ZC_SETTINGS_FILE, "Steps", "ZP_XP_PLAYER_ZOMBIE")
	zc_xp_step[2] = Setting_Load_Int(ZC_SETTINGS_FILE, "Steps", "ZP_XP_VIP_HUMAN")
	zc_xp_step[3] = Setting_Load_Int(ZC_SETTINGS_FILE, "Steps", "ZP_XP_VIP_ZOMBIE")
	zc_points_minutes = Setting_Load_Int(ZC_SETTINGS_FILE, "Steps", "ZP_POINTS_MINUTES")

	// Others
 	zc_logcommands = Setting_Load_Int(ZC_SETTINGS_FILE, "Others", "ZP_LOGCOMMANDS") 
	zc_show_activity = Setting_Load_Int(ZC_SETTINGS_FILE, "Others", "ZP_SHOW_ACTIVITY") 
}

stock Setting_Load_Int(const filename[], const setting_section[], setting_key[])
{
	if (strlen(filename) < 1)
	{
		log_error(AMX_ERR_NATIVE, "[Error] Can't load settings: empty filename")
		return false;
	}
	
	if (strlen(setting_section) < 1 || strlen(setting_key) < 1)
	{
		log_error(AMX_ERR_NATIVE, "[Error] Can't load settings: empty section/key")
		return false;
	}
	
	// Build customization file path
	new path[128]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, filename)
	
	// File not present
	if (!file_exists(path))
	{
		static DataA[128]; formatex(DataA, sizeof(DataA), "[Error] Can't load: %s", path)
		set_fail_state(DataA)
		
		return false;
	}
	
	// Open customization file for reading
	new file = fopen(path, "rt")
	
	// File can't be opened
	if (!file)
		return false;
	
	// Set up some vars to hold parsing info
	new linedata[1024], section[64]
	
	// Seek to setting's section
	while (!feof(file))
	{
		// Read one line at a time
		fgets(file, linedata, charsmax(linedata))
		
		// Replace newlines with a null character to prevent headaches
		replace(linedata, charsmax(linedata), "^n", "")
		
		// New section starting
		if (linedata[0] == '[')
		{
			// Store section name without braces
			copyc(section, charsmax(section), linedata[1], ']')
			
			// Is this our setting's section?
			if (equal(section, setting_section))
				break;
		}
	}
	
	// Section not found
	if (!equal(section, setting_section))
	{
		fclose(file)
		return false;
	}
	
	// Set up some vars to hold parsing info
	new key[64], current_value[32]
	
	// Seek to setting's key
	while (!feof(file))
	{
		// Read one line at a time
		fgets(file, linedata, charsmax(linedata))
		
		// Replace newlines with a null character to prevent headaches
		replace(linedata, charsmax(linedata), "^n", "")
		
		// Blank line or comment
		if (!linedata[0] || linedata[0] == ';') continue;
		
		// Section ended?
		if (linedata[0] == '[')
			break;
		
		// Get key and value
		strtok(linedata, key, charsmax(key), current_value, charsmax(current_value), '=')
		
		// Trim spaces
		trim(key)
		trim(current_value)
		
		// Is this our setting's key?
		if (equal(key, setting_key))
		{
			static return_value
			// Return int by reference
			return_value = str_to_num(current_value)
			
			// Values succesfully retrieved
			fclose(file)
			return return_value
		}
	}
	
	// Key not found
	fclose(file)
	return false;
}

stock Setting_Load_String(const filename[], const setting_section[], setting_key[], return_string[], string_size)
{
	if (strlen(filename) < 1)
	{
		log_error(AMX_ERR_NATIVE, "[Error] Can't load settings: empty filename")
		return false;
	}

	if (strlen(setting_section) < 1 || strlen(setting_key) < 1)
	{
		log_error(AMX_ERR_NATIVE, "[Error] Can't load settings: empty section/key")
		return false;
	}
	
	// Build customization file path
	new path[128]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, filename)
	
	// File not present
	if (!file_exists(path))
	{
		static DataA[128]; formatex(DataA, sizeof(DataA), "[Error] Can't load: %s", path)
		set_fail_state(DataA)
		
		return false;
	}
	
	// Open customization file for reading
	new file = fopen(path, "rt")
	
	// File can't be opened
	if (!file)
		return false;
	
	// Set up some vars to hold parsing info
	new linedata[1024], section[64]
	
	// Seek to setting's section
	while (!feof(file))
	{
		// Read one line at a time
		fgets(file, linedata, charsmax(linedata))
		
		// Replace newlines with a null character to prevent headaches
		replace(linedata, charsmax(linedata), "^n", "")
		
		// New section starting
		if (linedata[0] == '[')
		{
			// Store section name without braces
			copyc(section, charsmax(section), linedata[1], ']')
			
			// Is this our setting's section?
			if (equal(section, setting_section))
				break;
		}
	}
	
	// Section not found
	if (!equal(section, setting_section))
	{
		fclose(file)
		return false;
	}
	
	// Set up some vars to hold parsing info
	new key[64], current_value[128]
	
	// Seek to setting's key
	while (!feof(file))
	{
		// Read one line at a time
		fgets(file, linedata, charsmax(linedata))
		
		// Replace newlines with a null character to prevent headaches
		replace(linedata, charsmax(linedata), "^n", "")
		
		// Blank line or comment
		if (!linedata[0] || linedata[0] == ';') continue;
		
		// Section ended?
		if (linedata[0] == '[')
			break;
		
		// Get key and value
		strtok(linedata, key, charsmax(key), current_value, charsmax(current_value), '=')
		
		// Trim spaces
		trim(key)
		trim(current_value)
		
		// Is this our setting's key?
		if (equal(key, setting_key))
		{
			formatex(return_string, string_size, "%s", current_value)
			
			// Values succesfully retrieved
			fclose(file)
			return true;
		}
	}
	
	// Key not found
	fclose(file)
	return false;
}

save_customization()
{
	new i, k, buffer[1024]
	
	// Build zombie classes file path
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, ZC_ZOMBIECLASSES_FILE)
	
	// Open zombie classes file for appending data
	new file = fopen(path, "at"), size = ArraySize(g_zclass_name)
	
	// Add any new zombie classes data at the end if needed
	for (i = 0; i < size; i++)
	{
		if (ArrayGetCell(g_zclass_new, i))
		{
			// Add real name
			ArrayGetString(g_zclass_name, i, buffer, charsmax(buffer))
			format(buffer, charsmax(buffer), "^n[%s]", buffer)
			fputs(file, buffer)
			
			// Add caption
			ArrayGetString(g_zclass_name, i, buffer, charsmax(buffer))
			format(buffer, charsmax(buffer), "^nNAME = %s", buffer)
			fputs(file, buffer)
			
			// Add info
			ArrayGetString(g_zclass_info, i, buffer, charsmax(buffer))
			format(buffer, charsmax(buffer), "^nINFO = %s", buffer)
			fputs(file, buffer)
			
			// Add models
			for (k = ArrayGetCell(g_zclass_modelsstart, i); k < ArrayGetCell(g_zclass_modelsend, i); k++)
			{
				if (k == ArrayGetCell(g_zclass_modelsstart, i))
				{
					// First model, overwrite buffer
					ArrayGetString(g_zclass_playermodel, k, buffer, charsmax(buffer))
				}
				else
				{
					// Successive models, append to buffer
					ArrayGetString(g_zclass_playermodel, k, path, charsmax(path))
					format(buffer, charsmax(buffer), "%s , %s", buffer, path)
				}
			}
			format(buffer, charsmax(buffer), "^nMODELS = %s", buffer)
			fputs(file, buffer)
			
			// Add clawmodel
			ArrayGetString(g_zclass_clawmodel, i, buffer, charsmax(buffer))
			format(buffer, charsmax(buffer), "^nCLAWMODEL = %s", buffer)
			fputs(file, buffer)
			
			// Add health
			formatex(buffer, charsmax(buffer), "^nHEALTH = %d", ArrayGetCell(g_zclass_hp, i))
			fputs(file, buffer)
			
			// Add speed
			formatex(buffer, charsmax(buffer), "^nSPEED = %d", ArrayGetCell(g_zclass_spd, i))
			fputs(file, buffer)
			
			// Add gravity
			formatex(buffer, charsmax(buffer), "^nGRAVITY = %.2f", Float:ArrayGetCell(g_zclass_grav, i))
			fputs(file, buffer)
			
			// Add knockback
			formatex(buffer, charsmax(buffer), "^nKNOCKBACK = %.2f", Float:ArrayGetCell(g_zclass_kb, i))
			fputs(file, buffer)

			// Add level
			formatex(buffer, charsmax(buffer), "^nLEVEL = %d^n", ArrayGetCell(g_zclass_level, i))
			fputs(file, buffer)
		}
	}
	fclose(file)
	
        // Build human classes file path	
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, ZC_HUMANCLASSES_FILE)
	
	// Open human classes file for appending data
	file = fopen(path, "at"), size = ArraySize(g_hclass_name)
	
	// Add any new human classes data at the end if needed
	for (i = 0; i < size; i++)
	{
		if (ArrayGetCell(g_hclass_new, i))
		{
			// Add real name
			ArrayGetString(g_hclass_name, i, buffer, charsmax(buffer))
			format(buffer, charsmax(buffer), "^n[%s]", buffer)
			fputs(file, buffer)
			
			// Add caption
			ArrayGetString(g_hclass_name, i, buffer, charsmax(buffer))
			format(buffer, charsmax(buffer), "^nNAME = %s", buffer)
			fputs(file, buffer)
			
			// Add info
			ArrayGetString(g_hclass_info, i, buffer, charsmax(buffer))
			format(buffer, charsmax(buffer), "^nINFO = %s", buffer)
			fputs(file, buffer)
			
			// Add models
			for (k = ArrayGetCell(g_hclass_modelsstart, i); k < ArrayGetCell(g_hclass_modelsend, i); k++)
			{
				if (k == ArrayGetCell(g_hclass_modelsstart, i))
				{
					// First model, overwrite buffer
					ArrayGetString(g_hclass_playermodel, k, buffer, charsmax(buffer))
				}
				else
				{
					// Successive models, append to buffer
					ArrayGetString(g_hclass_playermodel, k, path, charsmax(path))
					format(buffer, charsmax(buffer), "%s , %s", buffer, path)
				}
			}
			format(buffer, charsmax(buffer), "^nMODELS = %s", buffer)
			fputs(file, buffer)

			// Add health
			formatex(buffer, charsmax(buffer), "^nHEALTH = %d", ArrayGetCell(g_hclass_hp, i))
			fputs(file, buffer)
			
			// Add speed
			formatex(buffer, charsmax(buffer), "^nSPEED = %d", ArrayGetCell(g_hclass_spd, i))
			fputs(file, buffer)
			
			// Add gravity
			formatex(buffer, charsmax(buffer), "^nGRAVITY = %.2f", Float:ArrayGetCell(g_hclass_grav, i))
			fputs(file, buffer)	

			// Add level
			formatex(buffer, charsmax(buffer), "^nLEVEL = %d^n", ArrayGetCell(g_hclass_level, i))
			fputs(file, buffer)
		}
	}
	fclose(file)

	// Build extra items file path
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, ZC_EXTRAITEMS_FILE)
	
	// Open extra items file for appending data
	file = fopen(path, "at")
	size = ArraySize(g_extraitem_name)
	
	// Add any new extra items data at the end if needed
	for (i = EXTRAS_CUSTOM_STARTID; i < size; i++)
	{
		if (ArrayGetCell(g_extraitem_new, i))
		{
			// Add real name
			ArrayGetString(g_extraitem_name, i, buffer, charsmax(buffer))
			format(buffer, charsmax(buffer), "^n[%s]", buffer)
			fputs(file, buffer)
			
			// Add caption
			ArrayGetString(g_extraitem_name, i, buffer, charsmax(buffer))
			format(buffer, charsmax(buffer), "^nNAME = %s", buffer)
			fputs(file, buffer)
			
			// Add cost
			formatex(buffer, charsmax(buffer), "^nCOST = %d", ArrayGetCell(g_extraitem_cost, i))
			fputs(file, buffer)
			
			// Add team
			formatex(buffer, charsmax(buffer), "^nTEAMS = %s", ZP_TEAM_NAMES[ArrayGetCell(g_extraitem_team, i)])
			fputs(file, buffer)

			// Add restriction type
			formatex(buffer, charsmax(buffer), "^nREST_TYPE = %d", ArrayGetCell(g_extraitem_resttype, i))
			fputs(file, buffer)

			// Add restriction limit
			formatex(buffer, charsmax(buffer), "^nREST_LIMIT = %d^n", ArrayGetCell(g_extraitem_restlimit, i))
			fputs(file, buffer)
		}
	}
	fclose(file)
	
	// Free arrays containing class/item overrides
	ArrayDestroy(g_zclass2_realname)
	ArrayDestroy(g_zclass2_name)
	ArrayDestroy(g_zclass2_info)
	ArrayDestroy(g_zclass2_modelsstart)
	ArrayDestroy(g_zclass2_modelsend)
	ArrayDestroy(g_zclass2_playermodel)
	ArrayDestroy(g_zclass2_modelindex)
	ArrayDestroy(g_zclass2_clawmodel)
	ArrayDestroy(g_zclass2_hp)
	ArrayDestroy(g_zclass2_spd)
	ArrayDestroy(g_zclass2_grav)
	ArrayDestroy(g_zclass2_kb)
	ArrayDestroy(g_zclass2_level)
	ArrayDestroy(g_zclass_new)
        ArrayDestroy(g_hclass2_realname)
	ArrayDestroy(g_hclass2_name)
	ArrayDestroy(g_hclass2_info)
	ArrayDestroy(g_hclass2_modelsstart)
	ArrayDestroy(g_hclass2_modelsend)
	ArrayDestroy(g_hclass2_playermodel)
	ArrayDestroy(g_hclass2_modelindex)	
	ArrayDestroy(g_hclass2_hp)
	ArrayDestroy(g_hclass2_spd)
	ArrayDestroy(g_hclass2_grav)	
	ArrayDestroy(g_hclass2_level)
	ArrayDestroy(g_hclass_new)
	ArrayDestroy(g_extraitem2_realname)
	ArrayDestroy(g_extraitem2_name)
	ArrayDestroy(g_extraitem2_cost)
	ArrayDestroy(g_extraitem2_team)
	ArrayDestroy(g_extraitem2_resttype)
	ArrayDestroy(g_extraitem2_restlimit)
	ArrayDestroy(g_extraitem_new)
}

// Disable minmodels task
public disable_minmodels(id)
{
	if (!g_isconnected[id]) return;
	client_cmd(id, "cl_minmodels 0")
}

// Bots automatically buy extra items
public bot_buy_extras(taskid)
{
	// Nemesis, Survivor or Sniper bots have nothing to buy by default
	if (!g_isalive[ID_SPAWN] || g_survivor[ID_SPAWN] || g_nemesis[ID_SPAWN] || g_sniper[ID_SPAWN] || g_flamer[ID_SPAWN] || g_zadoc[ID_SPAWN])
		return;
	
	if (!g_zombie[ID_SPAWN]) // human bots
	{
		// Attempt to buy Night Vision
		buy_extra_item(ID_SPAWN, EXTRA_NVISION)
		
		// Attempt to buy a weapon
		buy_extra_item(ID_SPAWN, random_num(EXTRA_WEAPONS_STARTID, EXTRAS_CUSTOM_STARTID-1))
	}
	else // zombie bots
	{
		// Attempt to buy an Antidote
		buy_extra_item(ID_SPAWN, EXTRA_ANTIDOTE)
	}
}

// Refill BP Ammo Task
public refill_bpammo(const args[], id)
{
	// Player died or turned into a zombie
	if (!g_isalive[id] || g_zombie[id] || g_zadoc[id])
		return;
	
	set_msg_block(g_msgAmmoPickup, BLOCK_ONCE)
	ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[REFILL_WEAPONID], AMMOTYPE[REFILL_WEAPONID], MAXBPAMMO[REFILL_WEAPONID])
}

// Balance Teams Task
balance_teams()
{
	// Get amount of users playing
	static iPlayersnum
	iPlayersnum = fnGetPlaying()
	
	// No players, don't bother
	if (iPlayersnum < 1) return;
	
	// Split players evenly
	static iTerrors, iMaxTerrors, id, team[33]
	iMaxTerrors = iPlayersnum/2
	iTerrors = 0
	
	// First, set everyone to CT
	for (id = 1; id <= g_maxplayers; id++)
	{
		// Skip if not connected
		if (!g_isconnected[id])
			continue;
		
		team[id] = fm_cs_get_user_team(id)
		
		// Skip if not playing
		if (team[id] == FM_CS_TEAM_SPECTATOR || team[id] == FM_CS_TEAM_UNASSIGNED)
			continue;
		
		// Set team
		remove_task(id+TASK_TEAM)
		fm_cs_set_user_team(id, FM_CS_TEAM_CT)
		team[id] = FM_CS_TEAM_CT
	}
	
	// Then randomly set half of the players to Terrorists
	while (iTerrors < iMaxTerrors)
	{
		// Keep looping through all players
		if (++id > g_maxplayers) id = 1
		
		// Skip if not connected
		if (!g_isconnected[id])
			continue;
		
		// Skip if not playing or already a Terrorist
		if (team[id] != FM_CS_TEAM_CT)
			continue;
		
		// Random chance
		if (random_num(0, 1))
		{
			fm_cs_set_user_team(id, FM_CS_TEAM_T)
			team[id] = FM_CS_TEAM_T
			iTerrors++
		}
	}
}

// Welcome Message Task
public welcome_msg()
{
	// Retrieve full address
	new full_address[32];
	get_user_ip(0, full_address, sizeof(full_address) - 1);

	// Show mod info
	zp_colored_print(0, "^x04%s^x01 ||^x03 %s^x01 ||^x04 Zombie Crown XP Mode v%s^x01.", SERVER_NAME, full_address, PLUGIN_VERSION)
	zp_colored_print(0, "^x04[ZC]^x03 Press M^x01 to open^x04 main menu^x01.")
}

// Respawn Player Task
public respawn_player_task(taskid)
{
	// Get player's team
	static team
	team = fm_cs_get_user_team(ID_SPAWN)
	
	// Respawn player automatically if allowed on current round
	if (!g_endround && team != FM_CS_TEAM_SPECTATOR && team != FM_CS_TEAM_UNASSIGNED && !g_isalive[ID_SPAWN] && (!g_survround || zc_surv_allow_respawn) 
	&& (!g_swarmround || zc_swarm_allow_respawn) && (!g_nemround || zc_nem_allow_respawn) && (!g_plagueround || zc_plague_allow_respawn) && (!g_sniperround || zc_sniper_allow_respawn) 
	&& (!g_assassinround || zc_assassin_allow_respawn) && (!g_oberonround || zc_oberon_allow_respawn) && (!g_dragonround || zc_dragon_allow_respawn) && (!g_nighterround || zc_nighter_allow_respawn) 
	&& (!g_lnjround || zc_lnj_allow_respawn) && (!g_guardiansround || zc_guardians_allow_respawn) && (!g_flamerround || zc_flamer_allow_respawn) && (!g_zadocround || zc_zadoc_allow_respawn) && (!g_genesysround || zc_assassin_allow_respawn))
	{
		// Infection rounds = none of the above
		if (!zc_infecton_allow_respawn && !g_survround && !g_nemround && !g_swarmround && !g_plagueround && !g_sniperround && !g_flamerround && !g_zadocround && !g_genesysround && !g_assassinround && !g_oberonround && !g_dragonround && !g_nighterround && !g_lnjround && !g_guardiansround)
			return;
		
		// Override respawn as zombie setting on nemesis, survivor and sniper rounds
		if (g_survround || g_sniperround || g_flamerround || g_zadocround || g_nighterround) g_respawn_as_zombie[ID_SPAWN] = true
		else if (g_nemround || g_assassinround || g_oberonround || g_dragonround || g_genesysround) g_respawn_as_zombie[ID_SPAWN] = false
		
		respawn_player_manually(ID_SPAWN)
	}
}

// Respawn Player Manually (called after respawn checks are done)
respawn_player_manually(id)
{
	// Set proper team before respawning, so that the TeamInfo message that's sent doesn't confuse PODBots
	if (g_respawn_as_zombie[id])
		fm_cs_set_user_team(id, FM_CS_TEAM_T)
	else
		fm_cs_set_user_team(id, FM_CS_TEAM_CT)
	
	// Respawning a player has never been so easy
	ExecuteHamB(Ham_CS_RoundRespawn, id)
}

// Check Round Task -check that we still have both zombies and humans on a round-
check_round(leaving_player)
{
	// Round ended or make_a_zombie task still active
	if (g_endround || task_exists(TASK_MAKEZOMBIE))
		return;
	
	// Get alive players count
	static iPlayersnum, id
	iPlayersnum = fnGetAlive()
	
	// Last alive player, don't bother
	if (iPlayersnum < 2)
		return;
	
	// Last zombie disconnecting
	if (g_zombie[leaving_player] && fnGetZombies() == 1)
	{
		// Only one CT left, don't bother
		if (fnGetHumans() == 1 && fnGetCTs() == 1)
			return;
		
		// Pick a random one to take his place
		while ((id = fnGetRandomAlive(random_num(1, iPlayersnum))) == leaving_player) { /* keep looping */ }
		
		// Show last zombie left notice
		zp_colored_print(0, "^x04[ZC]^x01 %L", LANG_PLAYER, "LAST_ZOMBIE_LEFT", g_playername[id])
		
		// Set player leaving flag
		g_lastplayerleaving = true
		
		// Turn into a Nemesis or just a zombie?
		if (g_nemesis[leaving_player])
			zombieme(id, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0)
		if (g_assassin[leaving_player])
			zombieme(id, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0)
		if (g_oberon[leaving_player])
			zombieme(id, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0)
		if (g_dragon[leaving_player])
			zombieme(id, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0)
		if (g_nighter[leaving_player])
			zombieme(id, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0)
		if (g_nchild[leaving_player])
			zombieme(id, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0)
		if (g_evil[leaving_player])
			zombieme(id, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
		if (g_genesys[leaving_player])
			zombieme(id, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0)
		if (!g_assassin[leaving_player] && !g_nemesis[leaving_player] && !g_genesys[leaving_player] && !g_oberon[leaving_player] && !g_dragon[leaving_player] && !g_nighter[leaving_player] && !g_nchild[leaving_player] && !g_evil[leaving_player])
			zombieme(id, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
		
		// Remove player leaving flag
		g_lastplayerleaving = false
		
		// If Nemesis, set chosen player's health to that of the one who's leaving
		if (zc_keep_health_on_disconnect && g_nemesis[leaving_player])
			fm_set_user_health(id, pev(leaving_player, pev_health))
			
		// If Assassin, set chosen player's health to that of the one who's leaving
		if (zc_keep_health_on_disconnect && g_assassin[leaving_player])
			fm_set_user_health(id, pev(leaving_player, pev_health))

		// If Oberon, set chosen player's health to that of the one who's leaving
		if (zc_keep_health_on_disconnect && g_oberon[leaving_player])
			fm_set_user_health(id, pev(leaving_player, pev_health))

		// If Dragon, set chosen player's health to that of the one who's leaving
		if (zc_keep_health_on_disconnect && g_dragon[leaving_player])
			fm_set_user_health(id, pev(leaving_player, pev_health))

		// If Nighter, set chosen player's health to that of the one who's leaving
		if (zc_keep_health_on_disconnect && g_nighter[leaving_player])
			fm_set_user_health(id, pev(leaving_player, pev_health))

		// If Nchild, set chosen player's health to that of the one who's leaving
		if (zc_keep_health_on_disconnect && g_nchild[leaving_player])
			fm_set_user_health(id, pev(leaving_player, pev_health))

		// If Genesys, set chosen player's health to that of the one who's leaving
		if (zc_keep_health_on_disconnect && g_genesys[leaving_player])
			fm_set_user_health(id, pev(leaving_player, pev_health))

		// If Evil, set chosen player's health to that of the one who's leaving
		if (zc_keep_health_on_disconnect && g_evil[leaving_player])
			fm_set_user_health(id, pev(leaving_player, pev_health))
	}
	
	// Last human disconnecting
	else if (!g_zombie[leaving_player] && fnGetHumans() == 1)
	{
		// Only one T left, don't bother
		if (fnGetZombies() == 1 && fnGetTs() == 1)
			return;
		
		// Pick a random one to take his place
		while ((id = fnGetRandomAlive(random_num(1, iPlayersnum))) == leaving_player) { /* keep looping */ }
		
		// Show last human left notice
		zp_colored_print(0, "^x04[ZC]^x01 %L", LANG_PLAYER, "LAST_HUMAN_LEFT", g_playername[id])
		
		// Set player leaving flag
		g_lastplayerleaving = true
		
		// Turn into a Survivor, Sniper or just a human?
		if (g_survivor[leaving_player])
			humanme(id, 1, 0, 0, 0, 0, 0)
		if (g_sniper[leaving_player])
			humanme(id, 0, 0, 1, 0, 0, 0)
		if (g_flamer[leaving_player])
			humanme(id, 0, 0, 0, 1, 0, 0)
		if (g_zadoc[leaving_player])
			humanme(id, 0, 0, 0, 0, 1, 0)
		if (g_hero[leaving_player])
			humanme(id, 0, 0, 0, 0, 0, 1)
		if (!g_survivor[leaving_player] && !g_sniper[leaving_player] && !g_flamer[leaving_player] && !g_zadoc[leaving_player] && !g_hero[leaving_player])
			humanme(id, 0, 0, 0, 0, 0, 0)
		
		// Remove player leaving flag
		g_lastplayerleaving = false
		
		// If Survivor, set chosen player's health to that of the one who's leaving
		if (zc_keep_health_on_disconnect && g_survivor[leaving_player])
			fm_set_user_health(id, pev(leaving_player, pev_health))
		
		// If Sniper, set chosen player's health to that of the one who's leaving
		if (zc_keep_health_on_disconnect && g_sniper[leaving_player])
			fm_set_user_health(id, pev(leaving_player, pev_health))

		// If Flamer, set chosen player's health to that of the one who's leaving
		if (zc_keep_health_on_disconnect && g_flamer[leaving_player])
			fm_set_user_health(id, pev(leaving_player, pev_health))

		// If Zadoc, set chosen player's health to that of the one who's leaving
		if (zc_keep_health_on_disconnect && g_zadoc[leaving_player])
			fm_set_user_health(id, pev(leaving_player, pev_health))
	}
}

// Lighting Effects Task
public lighting_effects(mode)
{	
	// Get lighting style
	static lighting[2]
	get_pcvar_string(cvar_lighting, lighting, charsmax(lighting))
	strtolower(lighting)
	
	// Lighting disabled? ["0"]
	if (lighting[0] == '0')
		return;
	
	// Light
	if(mode == 1)
	{
		message_begin(MSG_BROADCAST, SVC_LIGHTSTYLE)
		write_byte(0)
		write_string(lighting[0])
		message_end()
	}
	else if(mode == 2) 
	{
		message_begin(MSG_BROADCAST, SVC_LIGHTSTYLE)
		write_byte(0)
		write_string("a")
		message_end()
	}
}

// Ambience Sound Effects Task
public ambience_sound_effects(taskid)
{
	// Play a random sound depending on the round
	static sound[64], iRand, duration, ismp3
	
	if (g_nemround) // Nemesis Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience2) - 1)
		ArrayGetString(sound_ambience2, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience2_duration, iRand)
		ismp3 = ArrayGetCell(sound_ambience2_ismp3, iRand)
	}
	else if (g_survround) // Survivor Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience3) - 1)
		ArrayGetString(sound_ambience3, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience3_duration, iRand)
		ismp3 = ArrayGetCell(sound_ambience3_ismp3, iRand)
	}
	else if (g_swarmround) // Swarm Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience4) - 1)
		ArrayGetString(sound_ambience4, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience4_duration, iRand)
		ismp3 = ArrayGetCell(sound_ambience4_ismp3, iRand)
	}
	else if (g_plagueround) // Plague Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience5) - 1)
		ArrayGetString(sound_ambience5, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience5_duration, iRand)
		ismp3 = ArrayGetCell(sound_ambience5_ismp3, iRand)
	}
	else if (g_sniperround) // Sniper Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience6) - 1)
		ArrayGetString(sound_ambience6, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience6_duration, iRand)
		ismp3 = ArrayGetCell(sound_ambience6_ismp3, iRand)
	}
	else if (g_flamerround) // Flamer Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience9a) - 1)
		ArrayGetString(sound_ambience9a, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience9a_duration, iRand)
		ismp3 = ArrayGetCell(sound_ambience9a_ismp3, iRand)
	}
	else if (g_zadocround) // Zadoc Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience9b) - 1)
		ArrayGetString(sound_ambience9b, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience9b_duration, iRand)
		ismp3 = ArrayGetCell(sound_ambience9b_ismp3, iRand)
	}
	else if (g_assassinround) // Assassin Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience7) - 1)
		ArrayGetString(sound_ambience7, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience7_duration, iRand)
		ismp3 = ArrayGetCell(sound_ambience7_ismp3, iRand)
	}
	else if (g_oberonround) // Oberon Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience7a) - 1)
		ArrayGetString(sound_ambience7a, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience7a_duration, iRand)
		ismp3 = ArrayGetCell(sound_ambience7a_ismp3, iRand)
	}
	else if (g_dragonround) // Dragon Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience7b) - 1)
		ArrayGetString(sound_ambience7b, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience7b_duration, iRand)
		ismp3 = ArrayGetCell(sound_ambience7b_ismp3, iRand)
	}
	else if (g_nighterround) // Nighter Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience7c) - 1)
		ArrayGetString(sound_ambience7c, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience7c_duration, iRand)
		ismp3 = ArrayGetCell(sound_ambience7c_ismp3, iRand)
	}
	else if (g_genesysround) // Genesys Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience9) - 1)
		ArrayGetString(sound_ambience9, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience9_duration, iRand)
		ismp3 = ArrayGetCell(sound_ambience9_ismp3, iRand)
	}
	else if (g_lnjround) // LNJ Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience8) - 1)
		ArrayGetString(sound_ambience8, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience8_duration, iRand)
		ismp3 = ArrayGetCell(sound_ambience8_ismp3, iRand)
	}
	else if (g_guardiansround) // Guardians Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience8d) - 1)
		ArrayGetString(sound_ambience8d, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience8d_duration, iRand)
		ismp3 = ArrayGetCell(sound_ambience8d_ismp3, iRand)
	}
	else // Infection Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience1) - 1)
		ArrayGetString(sound_ambience1, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience1_duration, iRand)
		ismp3 = ArrayGetCell(sound_ambience1_ismp3, iRand)
	}
	
	// Play it on clients
	if (ismp3)
		client_cmd(0, "mp3 play ^"sound/%s^"", sound)
	else
		PlaySound(sound)
	
	// Set the task for when the sound is done playing
	set_task(float(duration), "ambience_sound_effects", TASK_AMBIENCESOUNDS)
}

// Ambience Sounds Stop Task
ambience_sound_stop()
{
	client_cmd(0, "mp3 stop; stopsound")
}

// Flashlight Charge Task
public flashlight_charge(taskid)
{
	// Drain or charge?
	if (g_flashlight[ID_CHARGE])
		g_flashbattery[ID_CHARGE] -= zc_flash_drain
	else
		g_flashbattery[ID_CHARGE] += zc_flash_charge
	
	// Battery fully charged
	if (g_flashbattery[ID_CHARGE] >= 100)
	{
		// Don't exceed 100%
		g_flashbattery[ID_CHARGE] = 100
		
		// Update flashlight battery on HUD
		message_begin(MSG_ONE, g_msgFlashBat, _, ID_CHARGE)
		write_byte(100) // battery
		message_end()
		
		// Task not needed anymore
		remove_task(taskid);
		return;
	}
	
	// Battery depleted
	if (g_flashbattery[ID_CHARGE] <= 0)
	{
		// Turn it off
		g_flashlight[ID_CHARGE] = false
		g_flashbattery[ID_CHARGE] = 0

		// Remove Flashlight Cone
		// set_cone_nodraw(ID_CHARGE)
		
		// Play flashlight toggle sound
		emit_sound(ID_CHARGE, CHAN_ITEM, sound_flashlight, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		// Update flashlight status on HUD
		message_begin(MSG_ONE, g_msgFlashlight, _, ID_CHARGE)
		write_byte(0) // toggle
		write_byte(0) // battery
		message_end()
		
		// Remove flashlight task for this player
		remove_task(ID_CHARGE+TASK_FLASH)

		// Remove Flashlight Cone
		// set_cone_nodraw(ID_CHARGE)
	}
	else
	{
		// Update flashlight battery on HUD
		message_begin(MSG_ONE_UNRELIABLE, g_msgFlashBat, _, ID_CHARGE)
		write_byte(g_flashbattery[ID_CHARGE]) // battery
		message_end()
	}
}

// Remove Spawn Protection Task
public remove_spawn_protection(taskid)
{
	// Not alive
	if (!g_isalive[ID_SPAWN])
		return;
	
	// Remove spawn protection
	g_nodamage[ID_SPAWN] = false
	set_pev(ID_SPAWN, pev_effects, pev(ID_SPAWN, pev_effects) & ~EF_NODRAW)
}

// Turn Off Flashlight and Restore Batteries
turn_off_flashlight(id)
{
	// Restore batteries for the next use
	fm_cs_set_user_batteries(id, 100)

	// Remove Flashlight Cone
	// set_cone_nodraw(id)
	
	// Check if flashlight is on
	if (pev(id, pev_effects) & EF_DIMLIGHT)
	{
		// Turn it off
		set_pev(id, pev_impulse, IMPULSE_FLASHLIGHT)
	}
	else
	{
		// Clear any stored flashlight impulse (bugfix)
		set_pev(id, pev_impulse, 0)
	}
	
	// Turn off custom flashlight
	if (g_cached_customflash)
	{
		// Turn it off
		g_flashlight[id] = false
		g_flashbattery[id] = 100
		
		// Update flashlight HUD
		message_begin(MSG_ONE, g_msgFlashlight, _, id)
		write_byte(0) // toggle
		write_byte(100) // battery
		message_end()
		
		// Remove previous tasks
		remove_task(id+TASK_CHARGE)
		remove_task(id+TASK_FLASH)

		// Remove Flashlight Cone
		// set_cone_nodraw(id)
	}
}

// Infection Bomb Explosion
infection_explode(ent)
{
	// Round ended (bugfix)
	if (g_endround) return;
	
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	// Make the explosion
	create_blast(originF)
	
	// Infection nade explode sound
	static sound[64]
	ArrayGetString(grenade_infect, random_num(0, ArraySize(grenade_infect) - 1), sound, charsmax(sound))
	emit_sound(ent, CHAN_WEAPON, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Get attacker
	static attacker
	attacker = pev(ent, pev_owner)
	
	// Collisions
	static victim
	victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		// Only effect alive non-spawnprotected humans
		if (!is_user_valid_alive(victim) || g_lasthuman[victim] || g_zombie[victim] || g_nodamage[victim])
			continue;

		// For gas-mask
        	ExecuteForward(g_fwUserInfectedByBombNative, g_fwDummyResult, victim)
        	if (g_fwDummyResult >= ZP_PLUGIN_HANDLED)
            		continue;  
		
		// Infected victim's sound
		ArrayGetString(grenade_infect_player, random_num(0, ArraySize(grenade_infect_player) - 1), sound, charsmax(sound))
		emit_sound(victim, CHAN_VOICE, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		// Turn into zombie
		zombieme(victim, attacker, 0, 1, 1, 0, 0, 0, 0, 0, 0)
	}
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

// Fire Grenade Explosion
fire_explode(ent)
{
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	// Make the explosion
	create_blast2(originF)
	
	// Fire nade explode sound
	static sound[64]
	ArrayGetString(grenade_fire, random_num(0, ArraySize(grenade_fire) - 1), sound, charsmax(sound))
	emit_sound(ent, CHAN_WEAPON, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Collisions
	static victim
	victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		// Only effect alive zombies
		if (!is_user_valid_alive(victim) || g_firstzombie[victim] || !g_zombie[victim] || g_nodamage[victim])
			continue;
		
		// Heat icon?
		if (zc_hud_icons)
		{
			message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, victim)
			write_byte(0) // damage save
			write_byte(0) // damage take
			write_long(DMG_BURN) // damage type
			write_coord(0) // x
			write_coord(0) // y
			write_coord(0) // z
			message_end()
		}
		
		if (g_nemesis[victim] || g_assassin[victim] || g_oberon[victim] || g_dragon[victim] || g_nighter[victim] || g_genesys[victim]) // fire duration (nemesis is fire resistant)
			g_burning_duration[victim] += zc_fire_duration
		else
			g_burning_duration[victim] += zc_fire_duration * 5
		
		// Set burning task on victim if not present
		if (!task_exists(victim+TASK_BURN))
			set_task(0.2, "burning_flame", victim+TASK_BURN, _, _, "b")
	}
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

// Frost Grenade Explosion
frost_explode(ent)
{
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	// Make the explosion
	create_blast3(originF)
	
	// Frost nade explode sound
	static sound[64]
	ArrayGetString(grenade_frost, random_num(0, ArraySize(grenade_frost) - 1), sound, charsmax(sound))
	emit_sound(ent, CHAN_WEAPON, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Collisions
	static victim
	victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		// Only effect alive zombies
		if (!is_user_valid_alive(victim) || !g_zombie[victim] || g_nodamage[victim])
			continue;
		
		// Nemesis, Assassin, Genesys, Oberon, Dragon, Nighter shouldn't be frozen
		if (g_nemesis[victim] || g_firstzombie[victim] || g_assassin[victim] || g_oberon[victim] || g_dragon[victim] || g_nighter[victim] || g_genesys[victim])
		{
			// Get player's origin
			static origin2[3]
			get_user_origin(victim, origin2)
			
			// Broken glass sound
			ArrayGetString(grenade_frost_break, random_num(0, ArraySize(grenade_frost_break) - 1), sound, charsmax(sound))
			emit_sound(victim, CHAN_BODY, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
			
			// Glass shatter
			message_begin(MSG_PVS, SVC_TEMPENTITY, origin2)
			write_byte(TE_BREAKMODEL) // TE id
			write_coord(origin2[0]) // x
			write_coord(origin2[1]) // y
			write_coord(origin2[2]+24) // z
			write_coord(16) // size x
			write_coord(16) // size y
			write_coord(16) // size z
			write_coord(random_num(-50, 50)) // velocity x
			write_coord(random_num(-50, 50)) // velocity y
			write_coord(25) // velocity z
			write_byte(10) // random velocity
			write_short(g_glassSpr) // model
			write_byte(10) // count
			write_byte(25) // life
			write_byte(BREAK_GLASS) // flags
			message_end()
			
			continue;
		}
		
		// Freeze icon?
		if (zc_hud_icons)
		{
			message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, victim)
			write_byte(0) // damage save
			write_byte(0) // damage take
			write_long(DMG_DROWN) // damage type - DMG_FREEZE
			write_coord(0) // x
			write_coord(0) // y
			write_coord(0) // z
			message_end()
		}
		
		// Light blue glow while frozen
		if (g_handle_models_on_separate_ent)
			fm_set_rendering(g_ent_playermodel[victim], kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 25)
		else
			fm_set_rendering(victim, kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 25)
		
		// Freeze sound
		ArrayGetString(grenade_frost_player, random_num(0, ArraySize(grenade_frost_player) - 1), sound, charsmax(sound))
		emit_sound(victim, CHAN_BODY, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		// Add a blue tint to their screen
		message_begin(MSG_ONE, g_msgScreenFade, _, victim)
		write_short(0) // duration
		write_short(0) // hold time
		write_short(FFADE_STAYOUT) // fade type
		write_byte(0) // red
		write_byte(50) // green
		write_byte(200) // blue
		write_byte(100) // alpha
		message_end()
		
		// Prevent from jumping
		if (pev(victim, pev_flags) & FL_ONGROUND)
			set_pev(victim, pev_gravity, 999999.9) // set really high
		else
			set_pev(victim, pev_gravity, 0.000001) // no gravity
		
		// Set a task to remove the freeze
		g_frozen[victim] = true;
		set_task(1.0+zc_frost_duration, "remove_freeze", victim)
	}
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

// Remove freeze task
public remove_freeze(id)
{
	// Not alive or not frozen anymore
	if (!g_isalive[id] || !g_frozen[id])
		return;
	
	// Unfreeze
	g_frozen[id] = false;
	
	// Restore gravity
	if (g_zombie[id])
	{
		if (g_nemesis[id])
			set_pev(id, pev_gravity, zc_nem_gravity)
		if (g_assassin[id])
			set_pev(id, pev_gravity, zc_assassin_gravity)
		if (g_oberon[id])
			set_pev(id, pev_gravity, zc_oberon_gravity)
		if (g_dragon[id])
			set_pev(id, pev_gravity, zc_dragon_gravity)
		if (g_nighter[id])
			set_pev(id, pev_gravity, zc_nighter_gravity)
		if (g_nchild[id])
			set_pev(id, pev_gravity, zc_nchild_gravity)
		if (g_evil[id])
			set_pev(id, pev_gravity, zc_evil_gravity)
		if (!g_assassin[id] && !g_nemesis[id] && !g_oberon[id] && !g_dragon[id] && !g_nighter[id] && !g_nchild[id] && !g_evil[id])
			set_pev(id, pev_gravity, Float:ArrayGetCell(g_zclass_grav, g_zombieclass[id]))
	}
	else
	{
		if (g_survivor[id])
			set_pev(id, pev_gravity, zc_surv_gravity)
		if (g_sniper[id])
			set_pev(id, pev_gravity, zc_sniper_gravity)
		if (g_flamer[id])
			set_pev(id, pev_gravity, zc_flamer_gravity)
		if (g_zadoc[id])
			set_pev(id, pev_gravity, zc_zadoc_gravity)
		if (g_hero[id])
			set_pev(id, pev_gravity, zc_hero_gravity)
		if (!g_survivor[id] && !g_sniper[id] && !g_flamer[id] && !g_zadoc[id] && !g_hero[id])
			set_pev(id, pev_gravity, Float:ArrayGetCell(g_hclass_grav, g_humanclass[id]))
	}
	
	// Restore rendering
	if (g_handle_models_on_separate_ent)
	{
		// Nemesis, Survivor or Sniper glow / remove glow on player model entity
		if (g_nemesis[id] && zc_nem_glow && !g_lnjround)
			fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 250, 0, 0, kRenderNormal, 25)
		else if (g_nemesis[id] && !(zc_nem_glow))
			fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)
			
		else if (g_assassin[id] && zc_assassin_glow)
			fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 250, 0, 0, kRenderNormal, 25)
		else if (g_assassin[id] && !(zc_assassin_glow))
			fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)	

		else if (g_oberon[id] && zc_oberon_glow)
			fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 250, 0, 0, kRenderNormal, 25)
		else if (g_oberon[id] && !(zc_oberon_glow))
			fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)

		else if (g_dragon[id] && zc_dragon_glow)
			fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 250, 0, 0, kRenderNormal, 25)
		else if (g_dragon[id] && !(zc_dragon_glow))
			fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)
		
		else if (g_survivor[id] && zc_surv_glow && !g_lnjround)
			fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 0, 250, 250, kRenderNormal, 25)
		else if (g_survivor[id] && !(zc_surv_glow))
			fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)
		
		else if (g_sniper[id] && zc_sniper_glow)
			fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, zc_sniper_aura_color_r, zc_sniper_aura_color_g, zc_sniper_aura_color_b, kRenderNormal, 25)
		else if (g_sniper[id] && !(zc_sniper_glow))
			fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)

		else if (g_flamer[id] && zc_flamer_glow)
			fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, zc_flamer_aura_color_r, zc_flamer_aura_color_g, zc_flamer_aura_color_b, kRenderNormal, 25)
		else if (g_flamer[id] && !(zc_flamer_glow))
			fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)

		else if (g_zadoc[id] && zc_zadoc_glow)
			fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, zc_zadoc_aura_color_r, zc_zadoc_aura_color_g, zc_zadoc_aura_color_b, kRenderNormal, 25)
		else if (g_zadoc[id] && !(zc_zadoc_glow))
			fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)
		
		else
			fm_set_rendering(g_ent_playermodel[id])
	}
	else
	{
		// Nemesis, Survivor or Sniper glow / remove glow
		if (g_nemesis[id] && zc_nem_glow && !g_lnjround)
			fm_set_rendering(id, kRenderFxGlowShell, 250, 0, 0, kRenderNormal, 25)
		else if (g_nemesis[id] && !(zc_nem_glow))
			fm_set_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)
			
		else if (g_assassin[id] && zc_assassin_glow)
			fm_set_rendering(id, kRenderFxGlowShell, 250, 0, 0, kRenderNormal, 25)
		else if (g_assassin[id] && !(zc_assassin_glow))
			fm_set_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)	

		else if (g_oberon[id] && zc_oberon_glow)
			fm_set_rendering(id, kRenderFxGlowShell, 250, 0, 0, kRenderNormal, 25)
		else if (g_oberon[id] && !(zc_oberon_glow))
			fm_set_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)

		else if (g_dragon[id] && zc_dragon_glow)
			fm_set_rendering(id, kRenderFxGlowShell, 250, 0, 0, kRenderNormal, 25)
		else if (g_dragon[id] && !(zc_dragon_glow))
			fm_set_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)
		
		else if (g_survivor[id] && zc_surv_glow && !g_lnjround)
			fm_set_rendering(id, kRenderFxGlowShell, 0, 250, 250, kRenderNormal, 25)
		else if (g_survivor[id] && !(zc_surv_glow))
			fm_set_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)
		
		else if (g_sniper[id] && zc_sniper_glow)
			fm_set_rendering(id, kRenderFxGlowShell, zc_sniper_aura_color_r, zc_sniper_aura_color_g, zc_sniper_aura_color_b, kRenderNormal, 25)
		else if (g_sniper[id] && !(zc_sniper_glow))
			fm_set_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)

		else if (g_flamer[id] && zc_flamer_glow)
			fm_set_rendering(id, kRenderFxGlowShell, zc_flamer_aura_color_r, zc_flamer_aura_color_g, zc_flamer_aura_color_b, kRenderNormal, 25)
		else if (g_flamer[id] && !(zc_flamer_glow))
			fm_set_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)

		else if (g_zadoc[id] && zc_zadoc_glow)
			fm_set_rendering(id, kRenderFxGlowShell, zc_zadoc_aura_color_r, zc_zadoc_aura_color_g, zc_zadoc_aura_color_b, kRenderNormal, 25)
		else if (g_zadoc[id] && !(zc_zadoc_glow))
			fm_set_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25)
		
		else
			fm_set_rendering(id)
	}
	
	// Gradually remove screen's blue tint
	message_begin(MSG_ONE, g_msgScreenFade, _, id)
	write_short(UNIT_SECOND) // duration
	write_short(0) // hold time
	write_short(FFADE_IN) // fade type
	write_byte(0) // red
	write_byte(50) // green
	write_byte(200) // blue
	write_byte(100) // alpha
	message_end()
	
	// Broken glass sound
	static sound[64]
	ArrayGetString(grenade_frost_break, random_num(0, ArraySize(grenade_frost_break) - 1), sound, charsmax(sound))
	emit_sound(id, CHAN_BODY, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Get player's origin
	static origin2[3]
	get_user_origin(id, origin2)
	
	// Glass shatter
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin2)
	write_byte(TE_BREAKMODEL) // TE id
	write_coord(origin2[0]) // x
	write_coord(origin2[1]) // y
	write_coord(origin2[2]+24) // z
	write_coord(16) // size x
	write_coord(16) // size y
	write_coord(16) // size z
	write_coord(random_num(-50, 50)) // velocity x
	write_coord(random_num(-50, 50)) // velocity y
	write_coord(25) // velocity z
	write_byte(10) // random velocity
	write_short(g_glassSpr) // model
	write_byte(10) // count
	write_byte(25) // life
	write_byte(BREAK_GLASS) // flags
	message_end()
	
	ExecuteForward(g_fwUserUnfrozen, g_fwDummyResult, id);
}

// Explosion
explosion_explode(ent)
{
	// Get origin
	static Float:origin[3], i, Float:clorigin[3],Float: clvelocity[3], special[3],Float: dist, Float: dmg,hlt,own, name[32]
	pev(ent, pev_origin, origin)
	FVecIVec(origin,special);
	own = pev(ent,pev_owner);
	if(!pev_valid(own)||!is_user_connected(own)){
		engfunc(EngFunc_RemoveEntity,ent);
		return;
	}
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_EXPLOSION);
	write_coord(special[0]);
	write_coord(special[1]);
	write_coord(special[2]);
	write_short(g_Explo);
	write_byte(32);
	write_byte(16);
	write_byte(0);
	message_end();
	for(i = 1 ; i <=g_maxplayers; i ++)
	{
    		if(!is_user_alive(i))
    			continue;
    			
    		if(!g_zombie[i])
    			continue;
    		
    		pev(i, pev_origin, clorigin)
    		dist = get_distance_f(origin, clorigin);
    		if(dist < 330)
    		{
    			dmg = 700.0-dist;
    			hlt = get_user_health(i);
    			dmg = float(floatround(dmg));
    			pev(i, pev_velocity, clvelocity);
    			clvelocity[0] += random_float(-230.0, 230.0);
    			clvelocity[1] += random_float(-230.0, 230.0);
    			clvelocity[2] += random_float(60.0, 129.0);
    			set_pev(i, pev_velocity, clvelocity);
    			message_begin( MSG_ONE_UNRELIABLE, g_msgScreenFade, _, i);
    			write_short(4096)
    			write_short(4096)
    			write_short(0x0000)
    			write_byte(225)
    			write_byte(0)
    			write_byte(0)
    			write_byte(220)
    			message_end()
    			client_cmd(i, "spk fvox/flatline")
    			message_begin(MSG_ONE_UNRELIABLE,g_msgScreenShake,_,i)
    			write_short(4096*6)
    			write_short(4096*random_num(4,12))
    			write_short(4096*random_num(4,12))
    			message_end()
    			if(hlt-floatround(dmg)<0)
    			{
    				ExecuteHamB(Ham_Killed, i, own, 2)
    			}else {
    				ExecuteHamB(Ham_TakeDamage, i, ent, own, dmg, DMG_MORTAR)
			}
			get_user_name(i, name, 31)
			if(!g_nemesis[i] && !g_assassin[i]) dmg *= 0.75
			zp_colored_print(own, "^x04[ZC]^x01 Damage to^x04 %s^x01 ::^x03 %d damage", name, floatround(dmg))
		}
	}

	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

// Remove Stuff Task
public remove_stuff()
{
	static ent
	
	// Remove rotating doors
	if (zc_remove_doors > 0)
	{
		ent = -1;
		while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "func_door_rotating")) != 0)
			engfunc(EngFunc_SetOrigin, ent, Float:{8192.0 ,8192.0 ,8192.0})
	}
	
	// Remove all doors
	if (zc_remove_doors > 1)
	{
		ent = -1;
		while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "func_door")) != 0)
			engfunc(EngFunc_SetOrigin, ent, Float:{8192.0 ,8192.0 ,8192.0})
	}
	
	// Triggered lights
	if (!zc_triggered_lights)
	{
		ent = -1
		while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "light")) != 0)
		{
			dllfunc(DLLFunc_Use, ent, 0); // turn off the light
			set_pev(ent, pev_targetname, 0) // prevent it from being triggered
		}
	}
}

// Set Custom Weapon Models
replace_weapon_models(id, weaponid)
{
	switch (weaponid)
	{
		case CSW_KNIFE: // Custom knife models
		{
			if (g_zombie[id])
			{
				if (g_nemesis[id]) // Nemesis
				{
					set_pev(id, pev_viewmodel2, model_vknife_nemesis)
					set_pev(id, pev_weaponmodel2, "")
				}
				if (g_assassin[id]) // Assassin
				{
					set_pev(id, pev_viewmodel2, model_vknife_assassin)
					set_pev(id, pev_weaponmodel2, "")
				}
				if (g_oberon[id]) // Oberon
				{
					set_pev(id, pev_viewmodel2, model_vknife_oberon)
					set_pev(id, pev_weaponmodel2, "")
				}
				if (g_dragon[id]) // Dragon
				{
					set_pev(id, pev_viewmodel2, model_vknife_dragon)
					set_pev(id, pev_weaponmodel2, "")
				}
				if (g_nighter[id]) // Nighter
				{
					set_pev(id, pev_viewmodel2, model_vknife_nighter)
					set_pev(id, pev_weaponmodel2, "")
				}	
				if (g_nchild[id]) // Nighter Child
				{
					set_pev(id, pev_viewmodel2, model_vknife_nchild)
					set_pev(id, pev_weaponmodel2, "")
				}
				if (g_evil[id]) // Evil
				{
					set_pev(id, pev_viewmodel2, model_vknife_evil)
					set_pev(id, pev_weaponmodel2, "")
				}			
				if (g_genesys[id]) // Genesys
				{
					set_pev(id, pev_viewmodel2, model_vknife_genesys)
					set_pev(id, pev_weaponmodel2, "")
				}
				if (!g_nemesis[id] && !g_assassin[id] && !g_oberon[id] && !g_dragon[id] && !g_nighter[id] && !g_nchild[id] && !g_genesys[id] && !g_evil[id]) // Zombies
				{
					// Admin knife models?
					if (zc_admin_knife_models_zombie && g_privileges[id] & g_access_flag[ACCESS_ADMIN_MODELS])
					{
						set_pev(id, pev_viewmodel2, model_vknife_admin_zombie)
						set_pev(id, pev_weaponmodel2, "")
					}
					else
					{
						static clawmodel[100]
						ArrayGetString(g_zclass_clawmodel, g_zombieclass[id], clawmodel, charsmax(clawmodel))
						format(clawmodel, charsmax(clawmodel), "models/zombie_crown/%s", clawmodel)
						set_pev(id, pev_viewmodel2, clawmodel)
						set_pev(id, pev_weaponmodel2, "")
					}
				}
			}
			else // Humans
			{
				// Admin knife models?
				if (zc_admin_knife_models_human && g_privileges[id] & g_access_flag[ACCESS_ADMIN_MODELS])
				{
					if(g_zadoc[id])
					{
						set_pev(id, pev_viewmodel2, model_vknife_zadoc)
						set_pev(id, pev_weaponmodel2, "")
					}else{
						set_pev(id, pev_viewmodel2, model_vknife_admin_human)
						set_pev(id, pev_weaponmodel2, "")
					}
				}
				else
				{
					if(g_zadoc[id])
					{
						set_pev(id, pev_viewmodel2, model_vknife_zadoc)
						set_pev(id, pev_weaponmodel2, model_pknife_zadoc)
					}else{
						set_pev(id, pev_viewmodel2, model_vknife_human)
						set_pev(id, pev_weaponmodel2, "models/p_knife.mdl")
					}
				}
			}
		}
		case CSW_M249: // Survivor's M249
		{
			if (g_survivor[id])
			{
				set_pev(id, pev_viewmodel2, model_vm249_survivor)
			}
			else if (g_flamer[id])
			{
				set_pev(id, pev_viewmodel2, model_vweapon_flamer)
				set_pev(id, pev_weaponmodel2, model_pweapon_flamer)
			}
		}
		case CSW_HEGRENADE: // Infection bomb or fire grenade
		{
			if (g_zombie[id])
			{
				set_pev(id, pev_viewmodel2, model_vgrenade_infect)
				set_pev(id, pev_weaponmodel2, model_pgrenade_infect)
			}
			else
			{
				set_pev(id, pev_viewmodel2, model_vgrenade_fire)
				set_pev(id, pev_weaponmodel2, model_pgrenade_fire)
			}
		}
		case CSW_FLASHBANG: // Frost grenade
		{
			set_pev(id, pev_viewmodel2, model_vgrenade_frost)
			set_pev(id, pev_weaponmodel2, model_pgrenade_frost)
		}
		case CSW_SMOKEGRENADE: // Explosion grenade
		{
			set_pev(id, pev_viewmodel2, model_vgrenade_explosion)
			set_pev(id, pev_weaponmodel2, model_pgrenade_explosion)
		}
		case CSW_AWP: // Sniper's AWP
		{
			if (g_sniper[id])
				set_pev(id, pev_viewmodel2, model_vawp_sniper)
		}
	}
	
	// Update model on weaponmodel ent
	if (g_handle_models_on_separate_ent) fm_set_weaponmodel_ent(id)
}

// Reset Player Vars
reset_vars(id, resetall)
{
	g_zombie[id] = false
	g_nemesis[id] = false
	g_survivor[id] = false
	g_firstzombie[id] = false
	g_lastzombie[id] = false
	g_lasthuman[id] = false
	g_sniper[id] = false
	g_flamer[id] = false
	g_zadoc[id] = false
	g_assassin[id] = false
	g_oberon[id] = false
	g_dragon[id] = false
	g_nighter[id] = false
	g_nchild[id] = false
	g_evil[id] = false
	g_hero[id] = false
	g_genesys[id] = false
	g_frozen[id] = false
	g_nodamage[id] = false
	g_respawn_as_zombie[id] = false
	g_hadnvision[id] = false
	set_user_nightvision(id, 0)
	g_flashlight[id] = false
	g_flashbattery[id] = 100
	g_canbuy[id] = true
	g_burning_duration[id] = 0

	// Remove Flashlight Cone
	// set_cone_nodraw(id)

	// Remove Custom NVision
	if(g_hascnvision[id])
	{
		remove_task(id+TASK_CNVISION)
		activate_nv[id] = false
		g_hascnvision[id] = false
	}
	
	if (resetall)
	{
		g_ammopacks[id] = zc_starting_ammo_packs
		g_zombieclass[id] = ZCLASS_NONE
		g_zombieclassnext[id] = ZCLASS_NONE
		g_humanclass[id] = HCLASS_NONE
		g_humanclassnext[id] = HCLASS_NONE
		g_damagedealt[id] = 0
		WPN_AUTO_ON = 0
	}
}

// Set spectators nightvision
public spec_nvision(id)
{
	// Not connected, alive, or bot
	if (!g_isconnected[id] || g_isalive[id] || g_isbot[id])
		return;
	
	// Give Night Vision?
	if (zc_nvg_give)
	{
		g_hadnvision[id] = true
		set_user_nightvision(id, 1)
	}
}

// Show HUD Task - Modernized with Combo System
public ShowHUD(taskid)
{
	static id
	id = ID_SHOWHUD;

	// Player died?
	if (!g_isalive[id])
	{
		// Get spectating target
		id = pev(id, PEV_SPEC_TARGET)

		// Target not alive
		if (!g_isalive[id]) return;
	}

	// Format classname
	static class[32]

	if (g_zombie[id]) // zombies
	{
		if (g_nemesis[id])
			formatex(class, charsmax(class), "%L", ID_SHOWHUD, "CLASS_NEMESIS")
		if (g_assassin[id])
			formatex(class, charsmax(class), "%L", ID_SHOWHUD, "CLASS_ASSASSIN")
		if (g_oberon[id])
			formatex(class, charsmax(class), "%L", ID_SHOWHUD, "CLASS_OBERON")
		if (g_dragon[id])
			formatex(class, charsmax(class), "%L", ID_SHOWHUD, "CLASS_DRAGON")
		if (g_nighter[id])
			formatex(class, charsmax(class), "%L", ID_SHOWHUD, "CLASS_NIGHTER")
		if (g_nchild[id])
			formatex(class, charsmax(class), "%L", ID_SHOWHUD, "CLASS_NCHILD")
		if (g_evil[id])
			formatex(class, charsmax(class), "%L", ID_SHOWHUD, "CLASS_EVIL")
		if (g_genesys[id])
			formatex(class, charsmax(class), "%L", ID_SHOWHUD, "CLASS_GENESYS")
		if (!g_assassin[id] && !g_nemesis[id] && !g_genesys[id] && !g_oberon[id] && !g_dragon[id] && !g_nighter[id] && !g_nchild[id] && !g_evil[id])
			copy(class, charsmax(class), g_zombie_classname[id])
	}
	else // humans
	{
		if (g_survivor[id])
			formatex(class, charsmax(class), "%L", ID_SHOWHUD, "CLASS_SURVIVOR")
		if (g_sniper[id])
			formatex(class, charsmax(class), "%L", ID_SHOWHUD, "CLASS_SNIPER")
		if (g_flamer[id])
			formatex(class, charsmax(class), "%L", ID_SHOWHUD, "CLASS_FLAMER")
		if (g_zadoc[id])
			formatex(class, charsmax(class), "%L", ID_SHOWHUD, "CLASS_ZADOC")
		if (g_hero[id])
			formatex(class, charsmax(class), "%L", ID_SHOWHUD, "CLASS_HERO")
		if (!g_survivor[id] && !g_sniper[id] && !g_flamer[id] && !g_zadoc[id] && !g_hero[id])
			copy(class, charsmax(class), g_human_classname[id])
	}

        static mission_name[64]
        get_mission(id, mission_name, 64)

	// Calculate combo multiplier
	static comboText[32]
	if (g_playerCombo[id] >= 5)
		formatex(comboText, charsmax(comboText), "x%d.%d COMBO!", g_playerComboMultiplier[id], g_playerCombo[id] % 10)
	else if (g_playerCombo[id] >= 2)
		formatex(comboText, charsmax(comboText), "%d Combo", g_playerCombo[id])
	else
		comboText[0] = 0

	// Spectating someone else?
	if (id == ID_SHOWHUD)
	{
		// Show health, class and ammo packs
		static chp[15], acopacks[15], acopoints[15], acoxp[15], aconxp[15], acoins[15]
		AddCommas(pev(ID_SHOWHUD, pev_health), chp, charsmax(chp))
		AddCommas(g_ammopacks[ID_SHOWHUD], acopacks, charsmax(acopacks))
		AddCommas(g_points[ID_SHOWHUD], acopoints, charsmax(acopoints))
		AddCommas(g_xp[ID_SHOWHUD], acoxp, charsmax(acoxp))
		AddCommas(get_user_next(ID_SHOWHUD), aconxp, charsmax(aconxp))
		AddCommas(g_coins[ID_SHOWHUD], acoins, charsmax(acoins))

		// Use HUD color with green tint for combo
		if (g_playerCombo[ID_SHOWHUD] >= 5)
			set_hudmessage(0, 255, 0, zc_hud_alive_xpos, zc_hud_alive_ypos, 0, 6.0, 1.1, 0.0, 0.0, -1)
		else
			set_hudmessage(zc_hud_alive_color[0], zc_hud_alive_color[1], zc_hud_alive_color[2], zc_hud_alive_xpos, zc_hud_alive_ypos, 0, 6.0, 1.1, 0.0, 0.0, -1)

		if (comboText[0] != 0)
			ShowSyncHudMsg(ID_SHOWHUD, g_MsgSync2, "[%s]^nHealth: %s | Armor: %d^nClass: %s | %s^nLevel: %d/%d (%d%%) | Packs: %s^nXP: %s/%s | Points: %s | Coins: %s", comboText, chp, pev(ID_SHOWHUD, pev_armorvalue), class, zc_get_currmode(), g_level[ID_SHOWHUD], zc_max_level, get_user_power(ID_SHOWHUD), acopacks, acoxp, aconxp, acopoints, acoins)
		else
			ShowSyncHudMsg(ID_SHOWHUD, g_MsgSync2, "Health: %s | Armor: %d^nClass: %s | %s^nLevel: %d/%d (%d%%) | Packs: %s^nXP: %s/%s | Points: %s | Coins: %s", chp, pev(ID_SHOWHUD, pev_armorvalue), class, zc_get_currmode(), g_level[ID_SHOWHUD], zc_max_level, get_user_power(ID_SHOWHUD), acopacks, acoxp, aconxp, acopoints, acoins)
	}
	else if (id != ID_SHOWHUD)
	{
		// Show health, class and ammo packs
		static chp[15], acopacks[15], acopoints[15], acoxp[15], aconxp[15], acoins[15]
		AddCommas(pev(id, pev_health), chp, charsmax(chp))
		AddCommas(g_ammopacks[id], acopacks, charsmax(acopacks))
		AddCommas(g_points[id], acopoints, charsmax(acopoints))
		AddCommas(g_xp[id], acoxp, charsmax(acoxp))
		AddCommas(get_user_next(id), aconxp, charsmax(aconxp))
		AddCommas(g_coins[id], acoins, charsmax(acoins))

		// Use HUD color with green tint for combo
		if (g_playerCombo[id] >= 5)
			set_hudmessage(0, 255, 0, zc_hud_dead_xpos, zc_hud_dead_ypos, 0, 6.0, 1.1, 0.0, 0.0, -1)
		else
			set_hudmessage(zc_hud_dead_color[0], zc_hud_dead_color[1], zc_hud_dead_color[2], zc_hud_dead_xpos, zc_hud_dead_ypos, 0, 6.0, 1.1, 0.0, 0.0, -1)

		if (comboText[0] != 0)
			ShowSyncHudMsg(ID_SHOWHUD, g_MsgSync2, "[%s]^nHealth: %s | Armor: %d^nClass: %s^nLevel: %d/%d (%d%%) | Packs: %s^nXP: %s/%s | Points: %s | Coins: %s^n%s | %s", comboText, chp, pev(id, pev_armorvalue), class, g_level[id], zc_max_level, get_user_power(id), acopacks, acoxp, aconxp, acopoints, acoins, country[id], city[id])
		else
			ShowSyncHudMsg(ID_SHOWHUD, g_MsgSync2, "Health: %s | Armor: %d^nClass: %s^nLevel: %d/%d (%d%%) | Packs: %s^nXP: %s/%s | Points: %s | Coins: %s^n%s | %s", chp, pev(id, pev_armorvalue), class, g_level[id], zc_max_level, get_user_power(id), acopacks, acoxp, aconxp, acopoints, acoins, country[id], city[id])
	}
}

// Play idle zombie sounds
public zombie_play_idle(taskid)
{
	// Round ended/new one starting
	if (g_endround || g_newround)
		return;
	
	static sound[64]
	
	// Last zombie?
	if (g_lastzombie[ID_BLOOD])
	{
		ArrayGetString(zombie_idle_last, random_num(0, ArraySize(zombie_idle_last) - 1), sound, charsmax(sound))
		emit_sound(ID_BLOOD, CHAN_VOICE, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	else
	{
		ArrayGetString(zombie_idle, random_num(0, ArraySize(zombie_idle) - 1), sound, charsmax(sound))
		emit_sound(ID_BLOOD, CHAN_VOICE, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
}

// Madness Over Task
public madness_over(taskid)
{
	g_nodamage[ID_BLOOD] = false
}

// Place user at a random spawn
do_spawn(id)
{
	static hull, sp_index, i
	
	// Get whether the player is crouching
	hull = (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN
	
	// No spawns?
	if (!g_spawnCount)
		return;
		
	// Choose random spawn to start looping at
	sp_index = random_num(0, g_spawnCount - 1)
		
	// Try to find a clear spawn
	for (i = sp_index + 1; /*no condition*/; i++)
	{
		// Start over when we reach the end
		if (i >= g_spawnCount) i = 0
		
		// Free spawn space?
		if (is_hull_vacant(g_spawns[i], hull))
		{
			// Engfunc_SetOrigin is used so ent's mins and maxs get updated instantly
			engfunc(EngFunc_SetOrigin, id, g_spawns[i])
			break;
		}
			
		// Loop completed, no free space found
		if (i == sp_index) break;
	}
}

// Get Zombies -returns alive zombies number-
fnGetZombies()
{
	static iZombies, id
	iZombies = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_zombie[id])
			iZombies++
	}
	
	return iZombies;
}

// Get Humans -returns alive humans number-
fnGetHumans()
{
	static iHumans, id
	iHumans = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && !g_zombie[id])
			iHumans++
	}
	
	return iHumans;
}

// Get Nemesis -returns alive nemesis number-
fnGetNemesis()
{
	static iNemesis, id
	iNemesis = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_nemesis[id])
			iNemesis++
	}
	
	return iNemesis;
}

// Get Survivors -returns alive survivors number-
fnGetSurvivors()
{
	static iSurvivors, id
	iSurvivors = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_survivor[id])
			iSurvivors++
	}
	
	return iSurvivors;
}

// Get Snipers -returns alive snipers number-
fnGetSnipers()
{
	static iSnipers, id
	iSnipers = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_sniper[id])
			iSnipers++
	}
	
	return iSnipers;
}

// Get Flamers -returns alive snipers number-
fnGetFlamers()
{
	static iFlamers, id
	iFlamers = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_flamer[id])
			iFlamers++
	}
	
	return iFlamers;
}

// Get Zadocs -returns alive snipers number-
fnGetZadocs()
{
	static iZadocs, id
	iZadocs = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_zadoc[id])
			iZadocs++
	}
	
	return iZadocs;
}

// Get Assassins -returns alive assassin numbers-
fnGetAssassin()
{
	static iAssassin, id
	iAssassin = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_assassin[id])
			iAssassin++
	}
	
	return iAssassin;
}

// Get Oberons -returns alive oberon numbers-
fnGetOberon()
{
	static iOberon, id
	iOberon = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_oberon[id])
			iOberon++
	}
	
	return iOberon;
}

// Get Dragons -returns alive oberon numbers-
fnGetDragon()
{
	static iDragon, id
	iDragon = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_dragon[id])
			iDragon++
	}
	
	return iDragon;
}

// Get Nighter -returns alive oberon numbers-
fnGetNighter()
{
	static iNighter, id
	iNighter = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_nighter[id])
			iNighter++
	}
	
	return iNighter;
}

// Get Genesys -returns alive genesys numbers-
fnGetGenesys()
{
	static iGenesys, id
	iGenesys = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_genesys[id])
			iGenesys++
	}
	
	return iGenesys;
}

// Get Alive -returns alive players number-
fnGetAlive()
{
	static iAlive, id
	iAlive = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id])
			iAlive++
	}
	
	return iAlive;
}

// Get Random Alive -returns index of alive player number n -
fnGetRandomAlive(n)
{
	static iAlive, id
	iAlive = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id])
			iAlive++
		
		if (iAlive == n)
			return id;
	}
	
	return -1;
}

// Get Playing -returns number of users playing-
fnGetPlaying()
{
	static iPlaying, id, team
	iPlaying = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isconnected[id])
		{
			team = fm_cs_get_user_team(id)
			
			if (team != FM_CS_TEAM_SPECTATOR && team != FM_CS_TEAM_UNASSIGNED)
				iPlaying++
		}
	}
	
	return iPlaying;
}

// Get CTs -returns number of CTs connected-
fnGetCTs()
{
	static iCTs, id
	iCTs = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isconnected[id])
		{			
			if (fm_cs_get_user_team(id) == FM_CS_TEAM_CT)
				iCTs++
		}
	}
	
	return iCTs;
}

// Get Ts -returns number of Ts connected-
fnGetTs()
{
	static iTs, id
	iTs = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isconnected[id])
		{			
			if (fm_cs_get_user_team(id) == FM_CS_TEAM_T)
				iTs++
		}
	}
	
	return iTs;
}

// Get Alive CTs -returns number of CTs alive-
fnGetAliveCTs()
{
	static iCTs, id
	iCTs = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id])
		{			
			if (fm_cs_get_user_team(id) == FM_CS_TEAM_CT)
				iCTs++
		}
	}
	
	return iCTs;
}

// Get Alive Ts -returns number of Ts alive-
fnGetAliveTs()
{
	static iTs, id
	iTs = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id])
		{			
			if (fm_cs_get_user_team(id) == FM_CS_TEAM_T)
				iTs++
		}
	}
	
	return iTs;
}

// Last Zombie Check -check for last zombie and set its flag-
fnCheckLastZombie()
{
	static id
	for (id = 1; id <= g_maxplayers; id++)
	{
		// Last zombie
		if (g_isalive[id] && g_zombie[id] && !g_nemesis[id] && !g_assassin[id] && !g_oberon[id] && !g_dragon[id] && !g_nighter[id] && !g_genesys[id] && fnGetZombies() == 1)
		{
			if (!g_lastzombie[id])
			{
				// Last zombie forward
				ExecuteForward(g_fwUserLastZombie, g_fwDummyResult, id);
			}
			g_lastzombie[id] = true
		}
		else
			g_lastzombie[id] = false
		
		// Last human
		if (g_isalive[id] && !g_zombie[id] && !g_survivor[id] && !g_sniper[id] && !g_flamer[id] && !g_zadoc[id] && fnGetHumans() == 1)
		{
			if (!g_lasthuman[id])
			{
				// Last human forward
				ExecuteForward(g_fwUserLastHuman, g_fwDummyResult, id);
			}
			g_lasthuman[id] = true
		}
		else
			g_lasthuman[id] = false
	}
}

// Checks if a player is allowed to be zombie
allowed_zombie(id)
{
	if ((g_zombie[id] && !g_nemesis[id] && !g_assassin[id] && !g_genesys[id] && !g_oberon[id] && !g_dragon[id] && !g_nighter[id]) || g_endround || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && !g_zombie[id] && fnGetHumans() == 1))
		return false;
	
	return true;
}

// Checks if a player is allowed to be human
allowed_human(id)
{
	if ((!g_zombie[id] && !g_survivor[id] && !g_sniper[id] && !g_flamer[id] && !g_zadoc[id]) || g_endround || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && g_zombie[id] && fnGetZombies() == 1))
		return false;
	
	return true;
}

// Checks if a player is allowed to be survivor
allowed_survivor(id)
{
	if (g_endround || g_survivor[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && g_zombie[id] && fnGetZombies() == 1))
		return false;
	
	return true;
}

// Checks if a player is allowed to be nemesis
allowed_nemesis(id)
{
	if (g_endround || g_nemesis[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && !g_zombie[id] && fnGetHumans() == 1))
		return false;
	
	return true;
}

// Checks if a player is allowed to respawn
allowed_respawn(id)
{
	static team
	team = fm_cs_get_user_team(id)
	
	if (g_endround || team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED || g_isalive[id])
		return false;
	
	return true;
}

// Checks if swarm mode is allowed
allowed_swarm()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG))
		return false;
	
	return true;
}

// Checks if multi infection mode is allowed
allowed_multi()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || floatround(fnGetAlive()*zc_multi_ratio, floatround_ceil) < 2 || floatround(fnGetAlive()*zc_multi_ratio, floatround_ceil) >= fnGetAlive())
		return false;
	
	return true;
}

// Checks if plague mode is allowed
allowed_plague()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || floatround((fnGetAlive()-(zc_plague_nem_number+zc_plague_surv_number))*zc_plague_ratio, floatround_ceil) < 1
	|| fnGetAlive()-(zc_plague_surv_number+zc_plague_nem_number+floatround((fnGetAlive()-(zc_plague_nem_number+zc_plague_surv_number))*zc_plague_ratio, floatround_ceil)) < 1)
		return false;
	
	return true;
}

// Checks if a player is allowed to be sniper
allowed_sniper(id)
{
	if (g_endround || g_sniper[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && g_zombie[id] && fnGetZombies() == 1))
		return false;
	
	return true;
}

// Checks if a player is allowed to be flamer
allowed_flamer(id)
{
	if (g_endround || g_flamer[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && g_zombie[id] && fnGetZombies() == 1))
		return false;
	
	return true;
}

// Checks if a player is allowed to be zadoc
allowed_zadoc(id)
{
	if (g_endround || g_zadoc[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && g_zombie[id] && fnGetZombies() == 1))
		return false;
	
	return true;
}

// Checks if a player ia sllowed to be assassin
allowed_assassin(id)
{
	if (g_endround || g_assassin[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && !g_zombie[id] && fnGetHumans() == 1))
		return false;
	
	return true;
}

// Checks if a player is allowed to be Oberon
allowed_oberon(id)
{
	if (g_endround || g_oberon[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && !g_zombie[id] && fnGetHumans() == 1))
		return false;
	
	return true;
}

// Checks if a player is allowed to be Dragon
allowed_dragon(id)
{
	if (g_endround || g_dragon[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && !g_zombie[id] && fnGetHumans() == 1))
		return false;
	
	return true;
}

// Checks if a player is allowed to be Nighter
allowed_nighter(id)
{
	if (g_endround || g_nighter[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && !g_zombie[id] && fnGetHumans() == 1))
		return false;
	
	return true;
}

// Checks if a player ia sllowed to be genesys
allowed_genesys(id)
{
	if (g_endround || g_genesys[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && !g_zombie[id] && fnGetHumans() == 1))
		return false;
	
	return true;
}

// Checks if armageddon mode is allowed
allowed_lnj()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || fnGetAlive() < 2)
		return false;
	
	return true;
}

// Checks if guardians mode is allowed
allowed_guardians()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || fnGetAlive() < 3)
		return false;
	
	return true;
}

// Admin Command. zp_zombie
command_zombie(id, player)
{
	// Show activity?
	switch (zc_show_activity)
	{
		case 1: client_print(0, print_chat, "ADMIN - %s %L", g_playername[player], LANG_PLAYER, "CMD_INFECT")
		case 2: client_print(0, print_chat, "ADMIN %s - %s %L", g_playername[id], g_playername[player], LANG_PLAYER, "CMD_INFECT")
	}
	
	// Log to Zombie Crown  log file?
	if (zc_logcommands)
	{
		static ipa[16], ipp[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		get_user_ip(player, ipp, charsmax(ipp), 1);
		log_to_file("zc_logs.log", "[ZOMBIE] [%s - %s] [%s - %s] [%s]", g_playername[id], ipa, g_playername[player], ipp, mapname);
	}
	
	// New round?
	if (g_newround)
	{
		// Set as first zombie
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_INFECTION, player)
	}
	else
	{
		// Just infect
		zombieme(player, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	}

	// Counter
	g_mused[id] += 1
}

// Admin Command. zp_human
command_human(id, player)
{
	// Show activity?
	switch (zc_show_activity)
	{
		case 1: client_print(0, print_chat, "ADMIN - %s %L", g_playername[player], LANG_PLAYER, "CMD_DISINFECT")
		case 2: client_print(0, print_chat, "ADMIN %s - %s %L", g_playername[id], g_playername[player], LANG_PLAYER, "CMD_DISINFECT")
	}
	
	// Log to Zombie Crown XP Mode log file?
	if (zc_logcommands)
	{
		static ipa[16], ipp[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		get_user_ip(player, ipp, charsmax(ipp), 1);
		log_to_file("zc_logs.log", "[HUMAN] [%s - %s] [%s - %s] [%s]", g_playername[id], ipa, g_playername[player], ipp, mapname);
	}
	
	// Turn to human
	humanme(player, 0, 0, 0, 0, 0, 0)

	// Remove Genesys Powers
	if(get_user_noclip(id))
	{
		set_user_noclip(id, 0)
	}

	// Counter
	g_mused[id] += 1
}

// Admin Command. zp_survivor
command_survivor(id, player, event)
{
	// Check announcement
	if (event == 0 && (g_count_announces >= 2 || !g_announce_valid[id]))
	{
		if(!(get_user_flags(id) & ADMIN_RCON))
		{
			if(g_count_announces >= 2) zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
			else if(!g_announce_valid[id]) zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
        		return PLUGIN_HANDLED
		}
	}

	// Show activity?
	switch (zc_show_activity && !g_event)
	{
		case 1: client_print(0, print_chat, "ADMIN - %s %L", g_playername[player], LANG_PLAYER, "CMD_SURVIVAL")
		case 2: client_print(0, print_chat, "ADMIN %s - %s %L", g_playername[id], g_playername[player], LANG_PLAYER, "CMD_SURVIVAL")
	}
	
	// Log to Zombie Crown XP Mode log file?
	if (zc_logcommands)
	{
		static ipa[16], ipp[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		get_user_ip(player, ipp, charsmax(ipp), 1);
		log_to_file("zc_logs.log", "[SURVIVOR] [%s - %s] [%s - %s] [%s]", g_playername[id], ipa, g_playername[player], ipp, mapname);
	}
	
	// New round?
	if (g_newround)
	{
		// Set as first survivor
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_SURVIVOR, player)
	}
	else
	{
		// Turn player into a Survivor
		humanme(player, 1, 0, 0, 0, 0, 0)
	}

	// Counter
	g_mused[id] += 1
	g_modes_amenu_announce[id] += 1
	return PLUGIN_CONTINUE
}

// Admin Command. zp_nemesis
command_nemesis(id, player, event)
{
	// Check announcement
	if (event == 0 && (g_count_announces >= 2 || !g_announce_valid[id]))
	{
		if(!(get_user_flags(id) & ADMIN_RCON))
		{
			if(g_count_announces >= 2) zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
			else if(!g_announce_valid[id]) zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
        		return PLUGIN_HANDLED
		}
	}

	// Show activity?
	switch (zc_show_activity && !g_event)
	{
		case 1: client_print(0, print_chat, "ADMIN - %s %L", g_playername[player], LANG_PLAYER, "CMD_NEMESIS")
		case 2: client_print(0, print_chat, "ADMIN %s - %s %L", g_playername[id], g_playername[player], LANG_PLAYER, "CMD_NEMESIS")
	}
	
	// Log to Zombie Crown XP Mode log file?
	if (zc_logcommands)
	{
		static ipa[16], ipp[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		get_user_ip(player, ipp, charsmax(ipp), 1);
		log_to_file("zc_logs.log", "[NEMESIS] [%s - %s] [%s - %s] [%s]", g_playername[id], ipa, g_playername[player], ipp, mapname);
	}

	// New round?
	if (g_newround)
	{
		// Set as first nemesis
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_NEMESIS, player)
	}
	else
	{
		// Turn player into a Nemesis
		zombieme(player, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0)
	}

	// Counter
	g_mused[id] += 1
	g_modes_amenu_announce[id] += 1
	return PLUGIN_CONTINUE
}

// Admin Command. zp_respawn
command_respawn(id, player)
{
	// Show activity?
	switch (zc_show_activity)
	{
		case 1: client_print(0, print_chat, "ADMIN - %s %L", g_playername[player], LANG_PLAYER, "CMD_RESPAWN")
		case 2: client_print(0, print_chat, "ADMIN %s - %s %L", g_playername[id], g_playername[player], LANG_PLAYER, "CMD_RESPAWN")
	}
	
	// Log to Zombie Crown XP Mode log file?
	if (zc_logcommands)
	{
		static ipa[16], ipp[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		get_user_ip(player, ipp, charsmax(ipp), 1);
		log_to_file("zc_logs.log", "[RESPAWN] [%s - %s] [%s - %s] [%s]", g_playername[id], ipa, g_playername[player], ipp, mapname);
	}
	
	// Respawn as zombie?
	if (zc_deathmatch == 2 || (zc_deathmatch == 3 && random_num(0, 1)) || (zc_deathmatch == 4 && fnGetZombies() < fnGetAlive()/2))
		g_respawn_as_zombie[player] = true
	
	// Override respawn as zombie setting on nemesis, survivor and sniper rounds
	if (g_survround || g_sniperround || g_flamerround || g_zadocround) g_respawn_as_zombie[player] = true
	else if (g_nemround || g_assassinround || g_oberonround || g_dragonround || g_nighterround || g_genesysround) g_respawn_as_zombie[player] = false
	
	respawn_player_manually(player);

	// Counter
	g_mused[id] += 1
}

// Admin Command. zp_swarm
command_swarm(id)
{
	// Check announcement
	if (g_count_announces >= 2 || !g_announce_valid[id])
	{
		if(!(get_user_flags(id) & ADMIN_RCON))
		{
			if(g_count_announces >= 2) zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
			else if(!g_announce_valid[id]) zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
        		return PLUGIN_HANDLED
		}
	}

	// Show activity?
	switch (zc_show_activity)
	{
		case 1: client_print(0, print_chat, "ADMIN - %L", LANG_PLAYER, "CMD_SWARM")
		case 2: client_print(0, print_chat, "ADMIN %s - %L", g_playername[id], LANG_PLAYER, "CMD_SWARM")
	}
	
	// Log to Zombie Crown XP Mode log file?
	if (zc_logcommands)
	{
		static ipa[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		log_to_file("zc_logs.log", "[SWARM] [%s - %s] [%s]", g_playername[id], ipa, mapname);
	}
	
	// Call Swarm Mode
	remove_task(TASK_MAKEZOMBIE)
	make_a_zombie(MODE_SWARM, 0)

	// Counter
	g_mused[id] += 1
	g_modes_amenu_announce[id] += 1
	return PLUGIN_CONTINUE
}

// Admin Command. zp_multi
command_multi(id)
{
	// Check announcement
	if (g_count_announces >= 2 || !g_announce_valid[id])
	{
		if(!(get_user_flags(id) & ADMIN_RCON))
		{
			if(g_count_announces >= 2) zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
			else if(!g_announce_valid[id]) zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
        		return PLUGIN_HANDLED
		}
	}

	// Show activity?
	switch (zc_show_activity)
	{
		case 1: client_print(0, print_chat, "ADMIN - %L", LANG_PLAYER, "CMD_MULTI")
		case 2: client_print(0, print_chat, "ADMIN %s - %L", g_playername[id], LANG_PLAYER, "CMD_MULTI")
	}
	
	// Log to Zombie Crown XP Mode log file?
	if (zc_logcommands)
	{
		static ipa[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		log_to_file("zc_logs.log", "[MULTI] [%s - %s] [%s]", g_playername[id], ipa, mapname);
	}
	
	// Call Multi Infection
	remove_task(TASK_MAKEZOMBIE)
	make_a_zombie(MODE_MULTI, 0)

	// Counter
	g_mused[id] += 1
	g_modes_amenu_announce[id] += 1
	return PLUGIN_CONTINUE
}

// Admin Command. zp_plague
command_plague(id)
{
	// Check announcement
	if (g_count_announces >= 2 || !g_announce_valid[id])
	{
		if(!(get_user_flags(id) & ADMIN_RCON))
		{
			if(g_count_announces >= 2) zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
			else if(!g_announce_valid[id]) zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
        		return PLUGIN_HANDLED
		}
	}

	// Show activity?
	switch (zc_show_activity)
	{
		case 1: client_print(0, print_chat, "ADMIN - %L", LANG_PLAYER, "CMD_PLAGUE")
		case 2: client_print(0, print_chat, "ADMIN %s - %L", g_playername[id], LANG_PLAYER, "CMD_PLAGUE")
	}
	
	// Log to Zombie Crown XP Mode log file?
	if (zc_logcommands)
	{
		static ipa[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		log_to_file("zc_logs.log", "[PLAGUE] [%s - %s] [%s]", g_playername[id], ipa, mapname);
	}
	
	// Call Plague Mode
	remove_task(TASK_MAKEZOMBIE)
	make_a_zombie(MODE_PLAGUE, 0)

	// Counter
	g_mused[id] += 1
	g_modes_amenu_announce[id] += 1
	return PLUGIN_CONTINUE
}

// Admin Command. zp_sniper
command_sniper(id, player, event)
{
	// Check announcement
	if (event == 0 && (g_count_announces >= 2 || !g_announce_valid[id]))
	{
		if(!(get_user_flags(id) & ADMIN_RCON))
		{
			if(g_count_announces >= 2) zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
			else if(!g_announce_valid[id]) zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
        		return PLUGIN_HANDLED
		}
	}

	// Show activity?
	switch (zc_show_activity && !g_event)
	{
		case 1: client_print(0, print_chat, "ADMIN - %s %L", g_playername[player], LANG_PLAYER, "CMD_SNIPER")
		case 2: client_print(0, print_chat, "ADMIN %s - %s %L", g_playername[id], g_playername[player], LANG_PLAYER, "CMD_SNIPER")
	}
	
	 // Log to Zombie Crown XP Mode log file?
	if (zc_logcommands)
	{
		static ipa[16], ipp[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		get_user_ip(player, ipp, charsmax(ipp), 1);
		log_to_file("zc_logs.log", "[SNIPER] [%s - %s] [%s - %s] [%s]", g_playername[id], ipa, g_playername[player], ipp, mapname);
	}
	
	// New round?
	if (g_newround)
	{
		// Set as first sniper
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_SNIPER, player)
	}
	else
	{
		// Turn player into a Sniper
		humanme(player, 0, 0, 1, 0, 0, 0)
	}

	// Counter
	g_mused[id] += 1
	g_modes_amenu_announce[id] += 1
	return PLUGIN_CONTINUE
}
// Admin command: Assassin
command_assassin(id, player, event)
{
	// Check announcement
	if (event == 0 && (g_count_announces >= 2 || !g_announce_valid[id]))
	{
		if(!(get_user_flags(id) & ADMIN_RCON))
		{
			if(g_count_announces >= 2) zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
			else if(!g_announce_valid[id]) zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
        		return PLUGIN_HANDLED
		}
	}

	// Show activity?
	switch (zc_show_activity && !g_event)
	{
		case 1: client_print(0, print_chat, "ADMIN - %s %L", g_playername[player], LANG_PLAYER, "CMD_ASSASSIN")
		case 2: client_print(0, print_chat, "ADMIN %s - %s %L", g_playername[id], g_playername[player], LANG_PLAYER, "CMD_ASSASSIN")
	}
	
	// Log to Zombie Crown XP Mode log file?
	if (zc_logcommands)
	{
		static ipa[16], ipp[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		get_user_ip(player, ipp, charsmax(ipp), 1);
		log_to_file("zc_logs.log", "[ASSASSIN] [%s - %s] [%s - %s] [%s]", g_playername[id], ipa, g_playername[player], ipp, mapname);
	}
	
	// New round?
	if (g_newround)
	{
		// Set as first assassin
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_ASSASSIN, player)
	}
	else
	{
		// Turn player into a Assassin
		zombieme(player, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0)
	}

	// Counter
	g_mused[id] += 1
	g_modes_amenu_announce[id] += 1
	return PLUGIN_CONTINUE
}

// Admin command: Oberon
command_oberon(id, player, event)
{
	// Check announcement
	if (event == 0 && (g_count_announces >= 2 || !g_announce_valid[id]))
	{
		if(!(get_user_flags(id) & ADMIN_RCON))
		{
			if(g_count_announces >= 2) zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
			else if(!g_announce_valid[id]) zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
        		return PLUGIN_HANDLED
		}
	}

	// Show activity?
	switch (zc_show_activity && !g_event)
	{
		case 1: client_print(0, print_chat, "ADMIN - %s %L", g_playername[player], LANG_PLAYER, "CMD_OBERON")
		case 2: client_print(0, print_chat, "ADMIN %s - %s %L", g_playername[id], g_playername[player], LANG_PLAYER, "CMD_OBERON")
	}
	
	// Log to Zombie Crown XP Mode log file?
	if (zc_logcommands)
	{
		static ipa[16], ipp[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		get_user_ip(player, ipp, charsmax(ipp), 1);
		log_to_file("zc_logs.log", "[OBERON] [%s - %s] [%s - %s] [%s]", g_playername[id], ipa, g_playername[player], ipp, mapname);
	}
	
	// New round?
	if (g_newround)
	{
		// Set as first Oberon
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_OBERON, player)
	}
	else
	{
		// Turn player into a Oberon
		zombieme(player, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0)
	}

	// Counter
	g_mused[id] += 1
	g_modes_amenu_announce[id] += 1
	return PLUGIN_CONTINUE
}

// Admin command: Dragon
command_dragon(id, player, event)
{
	// Check announcement
	if (event == 0 && (g_count_announces >= 2 || !g_announce_valid[id]))
	{
		if(!(get_user_flags(id) & ADMIN_RCON))
		{
			if(g_count_announces >= 2) zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
			else if(!g_announce_valid[id]) zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
        		return PLUGIN_HANDLED
		}
	}

	// Show activity?
	switch (zc_show_activity && !g_event)
	{
		case 1: client_print(0, print_chat, "ADMIN - %s %L", g_playername[player], LANG_PLAYER, "CMD_DRAGON")
		case 2: client_print(0, print_chat, "ADMIN %s - %s %L", g_playername[id], g_playername[player], LANG_PLAYER, "CMD_DRAGON")
	}
	
	// Log to Zombie Crown XP Mode log file?
	if (zc_logcommands)
	{
		static ipa[16], ipp[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		get_user_ip(player, ipp, charsmax(ipp), 1);
		log_to_file("zc_logs.log", "[DRAGON] [%s - %s] [%s - %s] [%s]", g_playername[id], ipa, g_playername[player], ipp, mapname);
	}
	
	// New round?
	if (g_newround)
	{
		// Set as first Dragon
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_DRAGON, player)
	}
	else
	{
		// Turn player into a Dragon
		zombieme(player, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0)
	}

	// Counter
	g_mused[id] += 1
	g_modes_amenu_announce[id] += 1
	return PLUGIN_CONTINUE
}

// Admin command: Nighter
command_nighter(id, player, event)
{
	// Check announcement
	if (event == 0 && (g_count_announces >= 2 || !g_announce_valid[id]))
	{
		if(!(get_user_flags(id) & ADMIN_RCON))
		{
			if(g_count_announces >= 2) zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
			else if(!g_announce_valid[id]) zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
        		return PLUGIN_HANDLED
		}
	}

	// Show activity?
	switch (zc_show_activity && !g_event)
	{
		case 1: client_print(0, print_chat, "ADMIN - %s %L", g_playername[player], LANG_PLAYER, "CMD_NIGHTER")
		case 2: client_print(0, print_chat, "ADMIN %s - %s %L", g_playername[id], g_playername[player], LANG_PLAYER, "CMD_NIGHTER")
	}
	
	// Log to Zombie Crown XP Mode log file?
	if (zc_logcommands)
	{
		static ipa[16], ipp[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		get_user_ip(player, ipp, charsmax(ipp), 1);
		log_to_file("zc_logs.log", "[NIGHTER] [%s - %s] [%s - %s] [%s]", g_playername[id], ipa, g_playername[player], ipp, mapname);
	}
	
	// New round?
	if (g_newround)
	{
		// Set as first Nighter
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_NIGHTER, player)
	}
	else
	{
		// Turn player into a Nighter
		zombieme(player, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0)
	}

	// Counter
	g_mused[id] += 1
	g_modes_amenu_announce[id] += 1
	return PLUGIN_CONTINUE
}

// Admin command: genesys
command_genesys(id, player, event)
{
	// Check announcement
	if (event == 0 && (g_count_announces >= 2 || !g_announce_valid[id]))
	{
		if(!(get_user_flags(id) & ADMIN_RCON))
		{
			if(g_count_announces >= 2) zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
			else if(!g_announce_valid[id]) zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
        		return PLUGIN_HANDLED
		}
	}

	// Show activity?
	switch (zc_show_activity && !g_event)
	{
		case 1: client_print(0, print_chat, "ADMIN - %s %L", g_playername[player], LANG_PLAYER, "CMD_GENESYS")
		case 2: client_print(0, print_chat, "ADMIN %s - %s %L", g_playername[id], g_playername[player], LANG_PLAYER, "CMD_GENESYS")
	}
	
	// Log to Zombie Crown XP Mode log file?
	if (zc_logcommands)
	{
		static ipa[16], ipp[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		get_user_ip(player, ipp, charsmax(ipp), 1);
		log_to_file("zc_logs.log", "[GENESYS] [%s - %s] [%s - %s] [%s]", g_playername[id], ipa, g_playername[player], ipp, mapname);
	}
	
	// New round?
	if (g_newround)
	{
		// Set as first genesys
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_GENESYS, player)
	}
	else
	{
		// Turn player into a genesys
		zombieme(player, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0)
	}

	// Counter
	g_mused[id] += 1
	g_modes_amenu_announce[id] += 1
	return PLUGIN_CONTINUE
}

// Admin Command. zp_flamer
command_flamer(id, player, event)
{
	// Check announcement
	if (event == 0 && (g_count_announces >= 2 || !g_announce_valid[id]))
	{
		if(!(get_user_flags(id) & ADMIN_RCON))
		{
			if(g_count_announces >= 2) zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
			else if(!g_announce_valid[id]) zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
        		return PLUGIN_HANDLED
		}
	}

	// Show activity?
	switch (zc_show_activity && !g_event)
	{
		case 1: client_print(0, print_chat, "ADMIN - %s %L", g_playername[player], LANG_PLAYER, "CMD_FLAMER")
		case 2: client_print(0, print_chat, "ADMIN %s - %s %L", g_playername[id], g_playername[player], LANG_PLAYER, "CMD_FLAMER")
	}
	
	 // Log to Zombie Crown XP Mode log file?
	if (zc_logcommands)
	{
		static ipa[16], ipp[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		get_user_ip(player, ipp, charsmax(ipp), 1);
		log_to_file("zc_logs.log", "[FLAMER] [%s - %s] [%s - %s] [%s]", g_playername[id], ipa, g_playername[player], ipp, mapname);
	}
	
	// New round?
	if (g_newround)
	{
		// Set as first flamer
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_FLAMER, player)

	}
	else
	{
		// Turn player into a Flamer
		humanme(player, 0, 0, 0, 1, 0, 0)
	}

	// Counter
	g_mused[id] += 1
	g_modes_amenu_announce[id] += 1
	return PLUGIN_CONTINUE
}

// Admin Command. zp_zadoc
command_zadoc(id, player, event)
{
	// Check announcement
	if (event == 0 && (g_count_announces >= 2 || !g_announce_valid[id]))
	{
		if(!(get_user_flags(id) & ADMIN_RCON))
		{
			if(g_count_announces >= 2) zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
			else if(!g_announce_valid[id]) zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
        		return PLUGIN_HANDLED
		}
	}

	// Show activity?
	switch (zc_show_activity && !g_event)
	{
		case 1: client_print(0, print_chat, "ADMIN - %s %L", g_playername[player], LANG_PLAYER, "CMD_ZADOC")
		case 2: client_print(0, print_chat, "ADMIN %s - %s %L", g_playername[id], g_playername[player], LANG_PLAYER, "CMD_ZADOC")
	}
	
	 // Log to Zombie Crown XP Mode log file?
	if (zc_logcommands)
	{
		static ipa[16], ipp[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		get_user_ip(player, ipp, charsmax(ipp), 1);
		log_to_file("zc_logs.log", "[ZADOC] [%s - %s] [%s - %s] [%s]", g_playername[id], ipa, g_playername[player], ipp, mapname);
	}
	
	// New round?
	if (g_newround)
	{
		// Set as first zadoc
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_ZADOC, player)

	}
	else
	{
		// Turn player into a Zadoc
		humanme(player, 0, 0, 0, 0, 1, 0)
	}

	// Counter
	g_mused[id] += 1
	g_modes_amenu_announce[id] += 1
	return PLUGIN_CONTINUE
}

// Admin Command. zp_lnj
command_lnj(id)
{
	// Check announcement
	if (g_count_announces >= 2 || !g_announce_valid[id])
	{
		if(!(get_user_flags(id) & ADMIN_RCON))
		{
			if(g_count_announces >= 2) zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
			else if(!g_announce_valid[id]) zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
        		return PLUGIN_HANDLED
		}
	}

	// Show activity?
	switch (zc_show_activity)
	{
		case 1: client_print(0, print_chat, "ADMIN - %L", LANG_PLAYER, "CMD_LNJ")
		case 2: client_print(0, print_chat, "ADMIN %s - %L", g_playername[id], LANG_PLAYER, "CMD_LNJ")
	}
	
	// Log to Zombie Crown XP Mode log file?
	if (zc_logcommands)
	{
		static ipa[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		log_to_file("zc_logs.log", "[LNJ] [%s - %s] [%s]", g_playername[id], ipa, mapname);
	}
	
	// Call Armageddon Mode
	remove_task(TASK_MAKEZOMBIE)
	make_a_zombie(MODE_LNJ, 0)

	// Counter
	g_mused[id] += 1
	g_modes_amenu_announce[id] += 1
	return PLUGIN_CONTINUE
}

// Admin Command. zp_guardians
command_guardians(id)
{
	// Check announcement
	if (g_count_announces >= 2 || !g_announce_valid[id])
	{
		if(!(get_user_flags(id) & ADMIN_RCON))
		{
			if(g_count_announces >= 2) zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
			else if(!g_announce_valid[id]) zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
        		return PLUGIN_HANDLED
		}
	}

	// Show activity?
	switch (zc_show_activity)
	{
		case 1: client_print(0, print_chat, "ADMIN - %L", LANG_PLAYER, "CMD_GUARDIANS")
		case 2: client_print(0, print_chat, "ADMIN %s - %L", g_playername[id], LANG_PLAYER, "CMD_GUARDIANS")
	}
	
	// Log to Zombie Crown XP Mode log file?
	if (zc_logcommands)
	{
		static ipa[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		log_to_file("zc_logs.log", "[GUARDIANS] [%s - %s] [%s]", g_playername[id], ipa, mapname);
	}
	
	// Call Guardians Mode
	remove_task(TASK_MAKEZOMBIE)
	make_a_zombie(MODE_GUARDIANS, 0)

	// Counter
	g_mused[id] += 1
	g_modes_amenu_announce[id] += 1
	return PLUGIN_CONTINUE
}

/*================================================================================
 [Custom Messages]
=================================================================================*/
// Custom Night Vision
public set_user_nightvision(id, on)
{
	static lighting[2]
	get_pcvar_string(cvar_lighting, lighting, charsmax(lighting))
	strtolower(lighting)

	if(on == 1)
	{
		// Set Light
		g_usingnvision[id] = true
		message_begin(MSG_ONE_UNRELIABLE, SVC_LIGHTSTYLE, .player = id)
		write_byte(0)
		write_string("n")
		message_end()	
	}
	else if(on == 0) 
	{
		if(g_assassinround)
		{
			// Set Default Light
			g_usingnvision[id] = false
			message_begin(MSG_ONE_UNRELIABLE, SVC_LIGHTSTYLE, .player = id)
			write_byte(0)
			write_string("a")
			message_end()
		}else {
			// Set Default Light
			g_usingnvision[id] = false
			message_begin(MSG_ONE_UNRELIABLE, SVC_LIGHTSTYLE, .player = id)
			write_byte(0)
			write_string(lighting[0])
			message_end()
		}	
	}
	return PLUGIN_HANDLED
}

// Custom NVision
public set_user_nv(id)
{
	id -= TASK_CNVISION
	static origin[3]
	get_user_origin(id, origin)
	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, id)
	write_byte(TE_DLIGHT)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_byte(50)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(2)
	write_byte(0)
	message_end()
}

// Custom Flashlight
public set_user_flashlight(taskid)
{
	// Get player and aiming origins
	static Float:originF[3], Float:destoriginF[3]
	pev(ID_FLASH, pev_origin, originF)
	fm_get_aim_origin(ID_FLASH, destoriginF)
	
	// Max distance check
	if (get_distance_f(originF, destoriginF) > zc_flash_distance)
		return;
	
	// Send to all players?
	if (zc_flash_show_all)
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, destoriginF, 0)
	else
		message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, ID_FLASH)
	
	// Specific Round
	if (g_assassinround)
	{
		// Flashlight on assassin round is different
		write_byte(TE_DLIGHT) // TE id
		engfunc(EngFunc_WriteCoord, destoriginF[0]) // x
		engfunc(EngFunc_WriteCoord, destoriginF[1]) // y
		engfunc(EngFunc_WriteCoord, destoriginF[2]) // z
		write_byte(zc_flash_size_assassin) // radius
		write_byte(zc_flash_color_assassin_r) // r
		write_byte(zc_flash_color_assassin_g) // g
		write_byte(zc_flash_color_assassin_b) // b
		write_byte(3) // life
		write_byte(0) // decay rate
		message_end()
	}
	else
	{
		// Flashlight
		write_byte(TE_DLIGHT) // TE id
		engfunc(EngFunc_WriteCoord, destoriginF[0]) // x
		engfunc(EngFunc_WriteCoord, destoriginF[1]) // y
		engfunc(EngFunc_WriteCoord, destoriginF[2]) // z
		write_byte(zc_flash_size) // radius
		write_byte(zc_flash_color_r) // r
		write_byte(zc_flash_color_g) // g
		write_byte(zc_flash_color_b) // b
		write_byte(3) // life
		write_byte(0) // decay rate
		message_end()
	}
}

// Infection special effects
infection_effects(id)
{
	// Screen fade? (unless frozen)
	if (!g_frozen[id] && zc_infection_screenfade)
	{
		message_begin(MSG_ONE_UNRELIABLE, g_msgScreenFade, _, id)
		write_short(UNIT_SECOND) // duration
		write_short(0) // hold time
		write_short(FFADE_IN) // fade type
		if (g_nemesis[id])
		{
			write_byte(255) // r
			write_byte(0) // g
			write_byte(0) // b
		}else {
			write_byte(22) // r
			write_byte(155) // g
			write_byte(50) // b
		}
		write_byte (255) // alpha
		message_end()
	}
	
	// Screen shake?
	if (zc_infection_screenshake)
	{
		message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id)
		write_short(UNIT_SECOND*75) // amplitude
		write_short(UNIT_SECOND*5) // duration
		write_short(UNIT_SECOND*75) // frequency
		message_end()
	}
	
	// Infection icon?
	if (zc_hud_icons)
	{
		message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, id)
		write_byte(0) // damage save
		write_byte(0) // damage take
		write_long(DMG_NERVEGAS) // damage type - DMG_RADIATION
		write_coord(0) // x
		write_coord(0) // y
		write_coord(0) // z
		message_end()
	}
	
	// Get player's origin
	static origin[3]
	get_user_origin(id, origin)
	
	// Tracers?
	if (zc_infection_tracers)
	{
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
		write_byte(TE_IMPLOSION) // TE id
		write_coord(origin[0]) // x
		write_coord(origin[1]) // y
		write_coord(origin[2]) // z
		write_byte(128) // radius
		write_byte(20) // count
		write_byte(3) // duration
		message_end()
	}
	
	// Particle burst?
	if (zc_infection_particles)
	{
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
		write_byte(TE_PARTICLEBURST) // TE id
		write_coord(origin[0]) // x
		write_coord(origin[1]) // y
		write_coord(origin[2]) // z
		write_short(50) // radius
		write_byte(70) // color
		write_byte(3) // duration (will be randomized a bit)
		message_end()
	}
	
	// Light sparkle?
	if (zc_infection_sparkle)
	{
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
		write_byte(TE_DLIGHT) // TE id
		write_coord(origin[0]) // x
		write_coord(origin[1]) // y
		write_coord(origin[2]) // z
		write_byte(20) // radius
		write_byte(255) // r
		write_byte(0) // g
		write_byte(0) // b
		write_byte(2) // life
		write_byte(0) // decay rate
		message_end()
	}
}

// Nemesis/madness aura task
public zombie_aura(taskid)
{
	// Not nemesis, not in zombie madness
	if (!g_nemesis[ID_AURA] && !g_nodamage[ID_AURA] && !g_assassin[ID_AURA] && !g_oberon[ID_AURA] && !g_dragon[ID_AURA] && !g_nighter[ID_AURA])
	{
		// Task not needed anymore
		remove_task(taskid);
		return;
	}
	
	// Get player's origin
	static origin[3]
	get_user_origin(ID_AURA, origin)
	
	// Colored Aura
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_DLIGHT) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_byte(25) // radius
	write_byte(255) // r
	write_byte(0) // g
	write_byte(0) // b
	write_byte(2) // life
	write_byte(0) // decay rate
	message_end()
}

// Survivor/Sniper aura task
public human_aura(taskid)
{
	// Not survivor or sniper
	if (!g_survivor[ID_AURA] && !g_sniper[ID_AURA] && !g_flamer[ID_AURA] && !g_zadoc[ID_AURA])
	{
		// Task not needed anymore
		remove_task(taskid);
		return;
	}
	
	if (g_sniper[ID_AURA])
	{
		// Get player's origin
		static origin[3]
		get_user_origin(ID_AURA, origin)
	
		// Colored Aura
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
		write_byte(TE_DLIGHT) // TE id
		write_coord(origin[0]) // x
		write_coord(origin[1]) // y
		write_coord(origin[2]) // z
		write_byte(zc_sniper_aura_size) // radius
		write_byte(zc_sniper_aura_color_r) // r
		write_byte(zc_sniper_aura_color_g) // g
		write_byte(zc_sniper_aura_color_b) // b
		write_byte(2) // life
		write_byte(0) // decay rate
		message_end()
	}
	else if (g_flamer[ID_AURA])
	{
		// Get player's origin
		static origin[3]
		get_user_origin(ID_AURA, origin)
	
		// Colored Aura
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
		write_byte(TE_DLIGHT) // TE id
		write_coord(origin[0]) // x
		write_coord(origin[1]) // y
		write_coord(origin[2]) // z
		write_byte(zc_flamer_aura_size) // radius
		write_byte(zc_flamer_aura_color_r) // r
		write_byte(zc_flamer_aura_color_g) // g
		write_byte(zc_flamer_aura_color_b) // b
		write_byte(2) // life
		write_byte(0) // decay rate
		message_end()
	}
	else if (g_zadoc[ID_AURA])
	{
		// Get player's origin
		static origin[3]
		get_user_origin(ID_AURA, origin)
	
		// Colored Aura
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
		write_byte(TE_DLIGHT) // TE id
		write_coord(origin[0]) // x
		write_coord(origin[1]) // y
		write_coord(origin[2]) // z
		write_byte(zc_zadoc_aura_size) // radius
		write_byte(zc_zadoc_aura_color_r) // r
		write_byte(zc_zadoc_aura_color_g) // g
		write_byte(zc_zadoc_aura_color_b) // b
		write_byte(2) // life
		write_byte(0) // decay rate
		message_end()
	}
	else 
	{
		// Get player's origin
		static origin[3]
		get_user_origin(ID_AURA, origin)
	
		// Colored Aura
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
		write_byte(TE_DLIGHT) // TE id
		write_coord(origin[0]) // x
		write_coord(origin[1]) // y
		write_coord(origin[2]) // z
		write_byte(zc_surv_aura_size) // radius
		write_byte(zc_surv_aura_r) // r
		write_byte(zc_surv_aura_g) // g
		write_byte(zc_surv_aura_b) // b
		write_byte(2) // life
		write_byte(0) // decay rate
		message_end()
	}
}

// Burning Flames
public burning_flame(taskid)
{
	// Get player origin and flags
	static origin[3], flags
	get_user_origin(ID_BURN, origin)
	flags = pev(ID_BURN, pev_flags)
	
	// Madness mode - in water - burning stopped
	if (g_nodamage[ID_BURN] || (flags & FL_INWATER) || g_burning_duration[ID_BURN] < 1)
	{
		// Smoke sprite
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
		write_byte(TE_SMOKE) // TE id
		write_coord(origin[0]) // x
		write_coord(origin[1]) // y
		write_coord(origin[2]-50) // z
		write_short(g_smokeSpr) // sprite
		write_byte(random_num(15, 20)) // scale
		write_byte(random_num(10, 20)) // framerate
		message_end()
		
		// Task not needed anymore
		remove_task(taskid);
		return;
	}
	
	// Randomly play burning zombie scream sounds (not for nemesis or assassin)
	if ((!g_nemesis[ID_BURN] && !g_assassin[ID_BURN] && !g_oberon[ID_BURN] && !g_dragon[ID_BURN] && !g_nighter[ID_BURN] && !g_genesys[ID_BURN]) && !random_num(0, 20))
	{
		static sound[64]
		ArrayGetString(grenade_fire_player, random_num(0, ArraySize(grenade_fire_player) - 1), sound, charsmax(sound))
		emit_sound(ID_BURN, CHAN_VOICE, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	
	// Fire slow down, unless nemesis
	if ((!g_nemesis[ID_BURN] && !g_assassin[ID_BURN] && !g_oberon[ID_BURN] && !g_dragon[ID_BURN] && !g_nighter[ID_BURN] && !g_genesys[ID_BURN]) && (flags & FL_ONGROUND) && zc_fire_slowdown > 0.0)
	{
		static Float:velocity[3]
		pev(ID_BURN, pev_velocity, velocity)
		xs_vec_mul_scalar(velocity, zc_fire_slowdown, velocity)
		set_pev(ID_BURN, pev_velocity, velocity)
	}
	
	// Get player's health
	static health
	health = pev(ID_BURN, pev_health)
	
	// Take damage from the fire
	if (health - floatround(zc_fire_damage, floatround_ceil) > 0)
		fm_set_user_health(ID_BURN, health - floatround(zc_fire_damage, floatround_ceil))
	
	// Flame sprite
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_SPRITE) // TE id
	write_coord(origin[0]+random_num(-5, 5)) // x
	write_coord(origin[1]+random_num(-5, 5)) // y
	write_coord(origin[2]+random_num(-10, 10)) // z
	write_short(g_flameSpr) // sprite
	write_byte(random_num(5, 10)) // scale
	write_byte(200) // brightness
	message_end()
	
	// Decrease burning duration counter
	g_burning_duration[ID_BURN]--
}

// Infection Bomb: Blast
create_blast(const Float:originF[3])
{
	// Smallest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+385.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(250) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Medium ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+470.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(250) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Largest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+555.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(250) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
}

// Fire Grenade: Fire Blast 
create_blast2(const Float:originF[3]) 
{ 
	// Smallest ring 
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0) 
	write_byte(TE_BEAMCYLINDER) // TE id 
	engfunc(EngFunc_WriteCoord, originF[0]) // x 
	engfunc(EngFunc_WriteCoord, originF[1]) // y 
	engfunc(EngFunc_WriteCoord, originF[2]) // z 
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis 
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis 
	engfunc(EngFunc_WriteCoord, originF[2]+385.0) // z axis 
	write_short(g_exploSpr) // sprite 
	write_byte(0) // startframe 
	write_byte(0) // framerate 
	write_byte(4) // life 
	write_byte(60) // width 
	write_byte(0) // noise 
	write_byte(200) // red 
	write_byte(100) // green 
	write_byte(0) // blue 
	write_byte(200) // brightness 
	write_byte(0) // speed 
	message_end() 

	// Medium ring 
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0) 
	write_byte(TE_BEAMCYLINDER) // TE id 
	engfunc(EngFunc_WriteCoord, originF[0]) // x 
	engfunc(EngFunc_WriteCoord, originF[1]) // y 
	engfunc(EngFunc_WriteCoord, originF[2]) // z 
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis 
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis 
	engfunc(EngFunc_WriteCoord, originF[2]+470.0) // z axis 
	write_short(g_exploSpr) // sprite 
	write_byte(0) // startframe 
	write_byte(0) // framerate 
	write_byte(4) // life 
	write_byte(60) // width 
	write_byte(0) // noise 
	write_byte(200) // red 
	write_byte(50) // green 
	write_byte(0) // blue 
	write_byte(200) // brightness 
	write_byte(0) // speed 
	message_end() 

	// Largest ring 
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0) 
	write_byte(TE_BEAMCYLINDER) // TE id 
	engfunc(EngFunc_WriteCoord, originF[0]) // x 
	engfunc(EngFunc_WriteCoord, originF[1]) // y 
	engfunc(EngFunc_WriteCoord, originF[2]) // z 
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis 
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis 
	engfunc(EngFunc_WriteCoord, originF[2]+555.0) // z axis 
	write_short(g_exploSpr) // sprite 
	write_byte(0) // startframe 
	write_byte(0) // framerate 
	write_byte(4) // life 
	write_byte(60) // width 
	write_byte(0) // noise 
	write_byte(200) // red 
	write_byte(0) // green 
	write_byte(0) // blue 
	write_byte(200) // brightness 
	write_byte(0) // speed 
	message_end() 

	// TE_SPRITETRAIL 
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST ,SVC_TEMPENTITY, originF, 0) 
	write_byte(TE_SPRITETRAIL) // TE ID 
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis 
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis 
	engfunc(EngFunc_WriteCoord, originF[2]+70) // z axis 
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis 
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis 
	engfunc(EngFunc_WriteCoord, originF[2]) // z axis 
	write_short(g_fire_gib) // Sprite Index 
	write_byte(80) // Count 
	write_byte(20) // Life 
	write_byte(2) // Scale 
	write_byte(50) // Velocity Along Vector 
	write_byte(10) // Rendomness of Velocity 
	message_end(); 

	// TE_EXPLOSION 
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST,SVC_TEMPENTITY, originF, 0) 
	write_byte(TE_EXPLOSION) 
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis 
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis 
	engfunc(EngFunc_WriteCoord, originF[2]+75) // z axis 
	write_short(g_fire_explode) 
	write_byte(22) 
	write_byte(35) 
	write_byte(TE_EXPLFLAG_NOSOUND) 
	message_end() 
} 

// Frost Grenade: Freeze Blast 
create_blast3(const Float:originF[3]) 
{ 
	// Smallest ring 
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0) 
	write_byte(TE_BEAMCYLINDER) // TE id 
	engfunc(EngFunc_WriteCoord, originF[0]) // x 
	engfunc(EngFunc_WriteCoord, originF[1]) // y 
	engfunc(EngFunc_WriteCoord, originF[2]) // z 
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis 
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis 
	engfunc(EngFunc_WriteCoord, originF[2]+385.0) // z axis 
	write_short(g_exploSpr) // sprite 
	write_byte(0) // startframe 
	write_byte(0) // framerate 
	write_byte(4) // life 
	write_byte(60) // width 
	write_byte(0) // noise 
	write_byte(0) // red 
	write_byte(100) // green 
	write_byte(200) // blue 
	write_byte(200) // brightness 
	write_byte(0) // speed 
	message_end() 

	// Medium ring 
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0) 
	write_byte(TE_BEAMCYLINDER) // TE id 
	engfunc(EngFunc_WriteCoord, originF[0]) // x 
	engfunc(EngFunc_WriteCoord, originF[1]) // y 
	engfunc(EngFunc_WriteCoord, originF[2]) // z 
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis 
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis 
	engfunc(EngFunc_WriteCoord, originF[2]+470.0) // z axis 
	write_short(g_exploSpr) // sprite 
	write_byte(0) // startframe 
	write_byte(0) // framerate 
	write_byte(4) // life 
	write_byte(60) // width 
	write_byte(0) // noise 
	write_byte(0) // red 
	write_byte(100) // green 
	write_byte(200) // blue 
	write_byte(200) // brightness 
	write_byte(0) // speed 
	message_end() 

	// Largest ring 
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0) 
	write_byte(TE_BEAMCYLINDER) // TE id 
	engfunc(EngFunc_WriteCoord, originF[0]) // x 
	engfunc(EngFunc_WriteCoord, originF[1]) // y 
	engfunc(EngFunc_WriteCoord, originF[2]) // z 
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis 
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis 
	engfunc(EngFunc_WriteCoord, originF[2]+555.0) // z axis 
	write_short(g_exploSpr) // sprite 
	write_byte(0) // startframe 
	write_byte(0) // framerate 
	write_byte(4) // life 
	write_byte(60) // width 
	write_byte(0) // noise 
	write_byte(0) // red 
	write_byte(100) // green 
	write_byte(200) // blue 
	write_byte(200) // brightness 
	write_byte(0) // speed 
	message_end() 

	// TE_SPRITETRAIL 
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST ,SVC_TEMPENTITY, originF, 0) 
	write_byte(TE_SPRITETRAIL) // TE ID 
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis 
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis 
	engfunc(EngFunc_WriteCoord, originF[2]+70) // z axis 
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis 
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis 
	engfunc(EngFunc_WriteCoord, originF[2]) // z axis 
	write_short(g_frost_gib) // Sprite Index 
	write_byte(80) // Count 
	write_byte(20) // Life 
	write_byte(2) // Scale 
	write_byte(50) // Velocity Along Vector 
	write_byte(10) // Rendomness of Velocity 
	message_end(); 

	// TE_EXPLOSION 
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST,SVC_TEMPENTITY, originF, 0) 
	write_byte(TE_EXPLOSION) 
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis 
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis 
	engfunc(EngFunc_WriteCoord, originF[2]+75) // z axis 
	write_short(g_frost_explode) 
	write_byte(22) 
	write_byte(35) 
	write_byte(TE_EXPLFLAG_NOSOUND) 
	message_end() 
}
// Fix Dead Attrib on scoreboard
FixDeadAttrib(id)
{
	message_begin(MSG_BROADCAST, g_msgScoreAttrib)
	write_byte(id) // id
	write_byte(0) // attrib
	message_end()
}

// Send Death Message for infections
SendDeathMsg(attacker, victim)
{
	message_begin(MSG_BROADCAST, g_msgDeathMsg)
	write_byte(attacker) // killer
	write_byte(victim) // victim
	write_byte(1) // headshot flag
	write_string("infection") // killer's weapon
	message_end()
}

// Update Player Frags and Deaths
UpdateFrags(attacker, victim, frags, deaths, scoreboard)
{
	if(!is_user_valid_connected(attacker) || !is_user_valid_connected(victim)) return
	// Set attacker frags
	set_pev(attacker, pev_frags, float(pev(attacker, pev_frags) + frags))
	
	// Set victim deaths
	fm_cs_set_user_deaths(victim, cs_get_user_deaths(victim) + deaths)
	
	// Update scoreboard with attacker and victim info
	if (scoreboard)
	{
		message_begin(MSG_BROADCAST, g_msgScoreInfo)
		write_byte(attacker) // id
		write_short(pev(attacker, pev_frags)) // frags
		write_short(cs_get_user_deaths(attacker)) // deaths
		write_short(0) // class?
		write_short(fm_cs_get_user_team(attacker)) // team
		message_end()
		
		message_begin(MSG_BROADCAST, g_msgScoreInfo)
		write_byte(victim) // id
		write_short(pev(victim, pev_frags)) // frags
		write_short(cs_get_user_deaths(victim)) // deaths
		write_short(0) // class?
		write_short(fm_cs_get_user_team(victim)) // team
		message_end()
	}
}

// Remove Player Frags (when Nemesis/Survivor/Sniper ignore_frags cvar is enabled)
RemoveFrags(attacker, victim)
{
	if(!is_user_valid_connected(attacker) || !is_user_valid_connected(victim)) return
	// Remove attacker frags
	set_pev(attacker, pev_frags, float(pev(attacker, pev_frags) - 1))
	
	// Remove victim deaths
	fm_cs_set_user_deaths(victim, cs_get_user_deaths(victim) - 1)
}

// Plays a sound on clients
PlaySound(const sound[])
{
	client_cmd(0, "spk ^"%s^"", sound)
}

/*================================================================================
 [Guardians Mode]
=================================================================================*/
public EvolveHUD(id)
{
	id -= TASK_EVIL_SHOW
	new message[128]
	set_hudmessage(255, 100, 5, -1.0, 0.8, 0, 6.0, 1.1, 0.0, 0.0, -1)
	if(g_evolve[id] == 0) formatex(message, sizeof(message)-1, "Evolve status: 0/5^n[_________________________]")
	else if(g_evolve[id] == 1) formatex(message, sizeof(message)-1, "Evolve status: 1/5^n[||||_____________________]")
	else if(g_evolve[id] == 2) formatex(message, sizeof(message)-1, "Evolve status: 2/5^n[||||||||||_______________]")
	else if(g_evolve[id] == 3) formatex(message, sizeof(message)-1, "Evolve status: 3/5^n[||||||||||||||||_________]")
	else if(g_evolve[id] == 4) formatex(message, sizeof(message)-1, "Evolve status: 4/5^n[||||||||||||||||||||||____]")
	else if(g_evolve[id] == 5) formatex(message, sizeof(message)-1, "Press Z to use your power!^nEvolve status: 5/5^n[|||||||||||||||||||||||||]")
	show_hudmessage(id, message);
}

public evil_power(id)
{
	if(g_evil_power_used[id] == 0 && g_evolve[id] == 5) 
	{
		i_noclip_time_hud[id] = 5
		remove_task(id+TASK_EVIL_SHOW)
		g_evil_power_used[id] = 1
		set_user_noclip(id, 1)
		give_item(id, "weapon_flashbang")
		cs_set_user_bpammo(id, CSW_FLASHBANG, 1)
		set_task(1.0, "start_evil_power", id+TASK_EVIL_POWER, _, _, "a", i_noclip_time_hud[id])
	}
}

public start_evil_power(id)
{
	id -= TASK_EVIL_POWER
	i_noclip_time_hud[id] = i_noclip_time_hud[id] - 1;
	set_hudmessage(200, 100, 0, 0.75, 0.92, 0, 1.0, 1.1, 0.0, 0.0, -1)
	show_hudmessage(id, "Power cooldown: %d", i_noclip_time_hud[id])
	if(i_noclip_time_hud[id] <= 0)
	{
		remove_task(id+TASK_EVIL_POWER)
		set_user_noclip(id, 0)
		g_evolve[id] = 0
		g_evil_power_used[id] = 0
		set_task(1.0, "EvolveHUD", id+TASK_EVIL_SHOW, _, _, "b")
	}
}

/*================================================================================
 [Genesys Power]
=================================================================================*/
public flamepw(id)
{
  	if(g_genesys[id] && is_user_valid_alive(id) && !is_player_stuck(id))
	{
		new Float:fOrigin[3], Float:fVelocity[3];
		entity_get_vector(id, EV_VEC_origin, fOrigin);
		VelocityByAim(id, 35, fVelocity);
		new Float:fTemp[3], iFireOrigin[3];
		xs_vec_add(fOrigin, fVelocity, fTemp);
		FVecIVec(fTemp, iFireOrigin);	
		new Float:fFireVelocity[3], iFireVelocity[3];
		VelocityByAim(id, 100, fFireVelocity);
		FVecIVec(fFireVelocity, iFireVelocity);
		create_flames_n_sounds(id, iFireOrigin, iFireVelocity);
		direct_damage(id);
	}
}

public direct_damage(id)
{
	new ent, body;
	get_user_aiming(id, ent, body, 600) ;
	
	if (ent > 0 && is_user_valid_alive(ent))
	{
		if (get_user_team(id) != get_user_team(ent)) 
			damage_user(id, ent, zc_genesys_flames_dmg);
	}
}

public create_flames_n_sounds(id, origin[3], velocity[3])
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(120);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2]);
	write_coord(velocity[0]);
	write_coord(velocity[1]);
	write_coord(velocity[2] + 5);
	write_short(sprite_fire);
	write_byte(1);
	write_byte(10);
	write_byte(1);
	write_byte(5);
	message_end();
	emit_sound(id, CHAN_WEAPON, "flamethrower.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
}

// ========= Start Genesys Power 2 =========
public Ultimate_LocustSwarm(id)
{
	if(g_genesys[id] && is_user_valid_alive(id))
	{
		static Float: gametime ; 
		gametime = get_gametime();
		if(gametime - float(zc_genesys_locust_delay) > g_fCooldown[id])
		{
			new Victim = LocustGetTarget(id)

			if(Victim == -1) 
			{
				new Message[64];
				formatex(Message,sizeof(Message)-1, "No valid victim found.")
				HudMessage(id, Message, _, _, _, _, _, _, _, 2.0)
			}else {
				new CasterOrigin[3]
				get_user_origin(id, CasterOrigin)
				new parm[10]
				parm[0] = id	
				parm[1] = Victim		
				parm[2] = CasterOrigin[0]
				parm[3] = CasterOrigin[1]
				parm[4] = CasterOrigin[2]
				LocustEffect(parm)
			}
			g_fCooldown[id] = gametime;
		}else{
			zp_colored_print(id, "^x04[ZC]^x01 Your power will charge in:^x04 %.1f seconds !", float(zc_genesys_locust_delay) - (gametime - g_fCooldown[id]))
		}
	}
}

public LocustGetTarget(id) 
{
	new Team = get_user_team(id);
	new Players[32], Num, TargetID;
	new Targets[33], TotalTargets = 0;
	
	get_players(Players, Num, "a");
	
	for(new i = 0; i < Num; i++) {
		TargetID = Players[i];
		
		if(get_user_team(TargetID) != Team) {
			Targets[TotalTargets++] = TargetID;
		}
	}
	
	if(TotalTargets == 0) {
		return -1;
	}
	
	new Victim = 0, RandomSpot;
	while(Victim == 0) {
		RandomSpot = random_num(0, TotalTargets);
		
		Victim = Targets[RandomSpot];
	}
	return Victim;
}


public LocustEffect(parm[]) {
	new Attacker = parm[0];
	new Victim = parm[1];
	if(Attacker >= TASK_FUNNELS) {
		Attacker -= TASK_FUNNELS;
	}
	
	if(!is_user_valid_alive(Victim) && g_zombie[Victim]) 
	{
		new Message1[64];
		formatex(Message1,sizeof(Message1)-1, "The victim isn't detected ...I'll find another one!");
		HudMessage(Attacker, Message1, _, _, _, _, _, _, _, 2.0);

		new Victim = LocustGetTarget(Attacker);
		
		if(Victim == -1) {
			new Message[64];
			formatex(Message,sizeof(Message)-1, "No valid victim.");
			HudMessage(Attacker, Message, _, _, _, _, _, _, _, 2.0);
		}
		else {
			new CasterOrigin[3];
			get_user_origin(Attacker, CasterOrigin);
			parm[1] = Victim;	// victim
			parm[2] = CasterOrigin[0];
			parm[3] = CasterOrigin[1];
			parm[4] = CasterOrigin[2];
			new Message2[64];
			formatex(Message2,sizeof(Message2)-1, "The victim is no longer detected.");
			HudMessage(Attacker, Message2, _, _, _, _, _, _, _, 2.0);
		}
	}
	
	new MULTIPLIER = 150
	
	new VictimOrigin[3], Funnel[3];
	get_user_origin(Victim, VictimOrigin);
	
	Funnel[0] = parm[2];
	Funnel[1] = parm[3];
	Funnel[2] = parm[4];
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)	
	write_byte(TE_LARGEFUNNEL)
	write_coord(Funnel[0])		// origin, x
	write_coord(Funnel[1])		// origin, y
	write_coord(Funnel[2])		// origin, z
	write_short(SPR_LOCUST)		// sprite(0 for none)
	write_short(0)			// 0 for collapsing, 1 for sending outward
	message_end() 
	
	new Dist[3];
	Dist[0] = HLP_Diff(VictimOrigin[0], Funnel[0]);
	Dist[1] = HLP_Diff(VictimOrigin[1], Funnel[1]);
	Dist[2] = HLP_Diff(VictimOrigin[2], Funnel[2]);	
	
	for(new i = 0; i < 3; i++) {
		if(HLP_Diff(VictimOrigin[i], Funnel[i] - MULTIPLIER) < Dist[i]) {
			Funnel[i] -= MULTIPLIER;
		}
		else if(HLP_Diff(VictimOrigin[i], Funnel[0] + MULTIPLIER) < Dist[i]) {
			Funnel[i] += MULTIPLIER;
		}
		else {
			Funnel[i] = VictimOrigin[i];
		}
	}
	
	parm[2] = Funnel[0];
	parm[3] = Funnel[1];
	parm[4] = Funnel[2];
	
	
	if(!(Dist[0] < 50 && Dist[1] < 50 && Dist[2] < 50)) {
		
		new Float:Time = 0.2;
		set_task(Time, "LocustEffect", Attacker + TASK_FUNNELS, parm, 5);
	}
	else {
		new Damage = random_num(LOCUSTSWARM_DMG_MIN, LOCUSTSWARM_DMG_MAX);
		damage_user(Attacker, Victim, Damage)
		emit_sound(Victim, CHAN_STATIC, SOUND_LOCUSTSWARM, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		new Message[64];
		formatex(Message,sizeof(Message)-1, "You hit %s with %d damage.", g_playername[Victim], Damage);
		HudMessage(Attacker, Message, _, _, _, _, _, _, _, 2.0);
	}
}

public HLP_Diff(iNum, iNum2) {
	if(iNum > iNum2) {
		return(iNum-iNum2);
	}
	else {
		return(iNum2-iNum);
	}
	
	return 0;
}

/*================================================================================
 [Flamer Power]
=================================================================================*/
public fw_item_postframe(ent)
{
	if(!is_valid_ent(ent))
		return HAM_IGNORED
	
	static id
	id = pev(ent, pev_owner)
	
	if(!is_user_valid_alive(id) || !is_user_valid_connected(id) || g_zombie[id])
		return HAM_IGNORED
	
	if(get_user_weapon(id) != CSW_SALAMANDER || !g_had_salamander[id])
		return HAM_IGNORED
		
	if(!is_reloading[id])
	{
		static iAnim
		iAnim = pev(id, pev_weaponanim)
	
		if(iAnim == RELOAD_ANIM)
			play_weapon_anim(id, IDLE_ANIM)
	}
		
	static salamander
	salamander = fm_find_ent_by_class(-1, "weapon_m249")
	
	set_pdata_int(salamander, 54, 0, 4)
	
	return HAM_HANDLED
}

public fw_item_addtoplayer(ent, id)
{
	if(!pev_valid(ent) || g_zombie[id])
		return HAM_HANDLED
			
	if(entity_get_int(ent, EV_INT_impulse) == 701)
	{
		g_had_salamander[id] = true
		g_ammo[id] = pev(ent, pev_iuser3)
		entity_set_int(id, EV_INT_impulse, 0)
		play_weapon_anim(id, DRAW_ANIM)
		set_task(1.0, "make_wpn_canfire", id)
		return HAM_HANDLED
	}		
	return HAM_HANDLED
}

public check_lastinv(id)
{
	if(!is_user_alive(id) || !is_user_valid_connected(id) || g_zombie[id])
		return PLUGIN_HANDLED
		
	if(get_user_weapon(id) == CSW_SALAMANDER && g_had_salamander[id])
	{
		set_task(0.5, "start_check_draw", id)
	}
	return PLUGIN_CONTINUE
}

public start_check_draw(id)
{
	if(can_fire[id])
		can_fire[id] = false
}

public fw_weapon_deploy(ent)
{
	static id
	id = pev(ent, pev_owner)
	
	if(!is_user_alive(id) || !is_user_valid_connected(id) || g_zombie[id])
		return HAM_IGNORED
	
	if(!g_had_salamander[id])
		return HAM_IGNORED
		
	can_fire[id] = false
	
	play_weapon_anim(id, DRAW_ANIM)
	set_task(1.0, "make_wpn_canfire", id)
		
	return HAM_HANDLED
}

public make_wpn_canfire(id)
{
	can_fire[id] = true
}

public fw_weapon_reload(ent)
{
	static id
	id = pev(ent, pev_owner)
	
	if(!is_user_alive(id) || !is_user_valid_connected(id) || g_zombie[id])
		return HAM_IGNORED
	
	if(get_user_weapon(id) != CSW_SALAMANDER && !g_had_salamander[id])
		return HAM_IGNORED
		
	return HAM_SUPERCEDE
}

public client_PostThink(id)
{
	if(is_user_alive(id) && is_user_valid_connected(id) && !g_zombie[id])
	{
		if(g_had_salamander[id] && get_user_weapon(id) != CSW_SALAMANDER)
		{
			if(can_fire[id])
				can_fire[id] = false

			if(is_reloading[id])
			{
				is_reloading[id] = false
				if(task_exists(id+TASK_RELOAD)) remove_task(id+TASK_RELOAD)
			}			
		} else if(g_had_salamander[id] && get_user_weapon(id) == CSW_SALAMANDER) {
			static salamander
			salamander = fm_get_user_weapon_entity(id, CSW_M249)
			cs_set_weapon_ammo(salamander, g_ammo[id])
		}
	}
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(!is_user_alive(id) || !is_user_valid_connected(id) || g_zombie[id])
		return FMRES_IGNORED
	
	if(get_user_weapon(id) != CSW_SALAMANDER || !g_had_salamander[id])
		return FMRES_IGNORED
		
	set_cd(cd_handle, CD_flNextAttack, halflife_time() + 0.001)  

	return FMRES_HANDLED
}

public fw_cmdflamer(id, uc_handle, seed)
{
	if(!is_user_alive(id) || !is_user_valid_connected(id) || g_zombie[id])
		return FMRES_IGNORED
	
	if(get_user_weapon(id) != CSW_SALAMANDER || !g_had_salamander[id])
		return FMRES_IGNORED
	
	static Button
	Button = get_uc(uc_handle, UC_Buttons)
	
	if(Button & IN_ATTACK)
	{
		if((get_gametime() - zc_flamer_fire_delay > g_last_fire[id]))
		{
			if(can_fire[id] && !is_reloading[id])
			{
				if(g_ammo[id] > 0)
				{
					if(pev(id, pev_weaponanim) != SHOOT_ANIM)
						play_weapon_anim(id, SHOOT_ANIM)
					
					if(task_exists(id+TASK_FIRE)) remove_task(id+TASK_FIRE)
					is_firing[id] = true
					throw_fire(id)
					emit_sound(id, CHAN_WEAPON, "weapons/flamegun-2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					g_ammo[id]--
				}

			}
			g_last_fire[id] = get_gametime()
		}
	}else {
		if(is_firing[id])
		{
			if(!task_exists(id+TASK_FIRE))
			{
				set_task(0.1, "stop_fire", id+TASK_FIRE)
				emit_sound(id, CHAN_WEAPON, "weapons/flamegun-2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
		}
		
	}
	
	if(Button & IN_RELOAD)
	{
		if(!is_reloading[id] && !is_firing[id])
		{
			static curammo, require_ammo, bpammo
			
			curammo = g_ammo[id]
			bpammo = cs_get_user_bpammo(id, CSW_SALAMANDER)
			require_ammo = zc_flamer_max_clip - curammo
			
			if(bpammo > require_ammo)
			{
				g_reload_ammo[id] = require_ammo
			}else {
				g_reload_ammo[id] = bpammo
			}
			
			if(g_ammo[id] < zc_flamer_max_clip && bpammo > 0)
			{
				is_reloading[id] = true
				play_weapon_anim(id, RELOAD_ANIM)
			
				set_task(5.0, "finish_reload", id+TASK_RELOAD)
			}
		}
	}
	
	Button &= ~IN_ATTACK
	set_uc(uc_handle, UC_Buttons, Button)
	
	Button &= ~IN_RELOAD
	set_uc(uc_handle, UC_Buttons, Button)
	
	return FMRES_HANDLED
}

public finish_reload(id)
{
	id -= TASK_RELOAD

	g_ammo[id] += g_reload_ammo[id]
	cs_set_user_bpammo(id, CSW_SALAMANDER, cs_get_user_bpammo(id, CSW_SALAMANDER) - g_reload_ammo[id])
	is_reloading[id] = false
}

public stop_fire(id)
{
	id -= TASK_FIRE
	
	is_firing[id] = false
	if(pev(id, pev_weaponanim) != SHOOT_END_ANIM)
		play_weapon_anim(id, SHOOT_END_ANIM)	
}

public throw_fire(id)
{
	new iEnt = create_entity("env_sprite")
	new Float:vfVelocity[3]
	
	velocity_by_aim(id, 500, vfVelocity)
	xs_vec_mul_scalar(vfVelocity, 0.4, vfVelocity)
	
	// add velocity of Owner for ent
	new Float:fOwnerVel[3], Float:vfAttack[3], Float:vfAngle[3]
	pev(id, pev_angles, vfAngle)
	//pev(id, pev_origin, vfAttack)
	get_weapon_attackment(id, vfAttack, 20.0)
	vfAttack[2] -= 7.0
	//vfAttack[1] += 7.0
	pev(id, pev_velocity, fOwnerVel)
	fOwnerVel[2] = 0.0
	xs_vec_add(vfVelocity, fOwnerVel, vfVelocity)
	
	// set info for ent
	set_pev(iEnt, pev_movetype, MOVETYPE_FLY)
	set_pev(iEnt, pev_rendermode, kRenderTransAdd)
	set_pev(iEnt, pev_renderamt, 150.0)
	set_pev(iEnt, PEV_ENT_TIME, get_gametime() + 1.5)	// time remove
	set_pev(iEnt, pev_scale, 0.2)
	set_pev(iEnt, pev_nextthink, halflife_time() + 0.05)
	
	set_pev(iEnt, pev_classname, fire_classname)
	engfunc(EngFunc_SetModel, iEnt, fire_spr_name)
	set_pev(iEnt, pev_mins, Float:{-1.0, -1.0, -1.0})
	set_pev(iEnt, pev_maxs, Float:{1.0, 1.0, 1.0})
	set_pev(iEnt, pev_origin, vfAttack)
	set_pev(iEnt, pev_gravity, 0.01)
	set_pev(iEnt, pev_velocity, vfVelocity)
	vfAngle[1] += 30.0
	set_pev(iEnt, pev_angles, vfAngle)
	set_pev(iEnt, pev_solid, SOLID_BBOX)
	set_pev(iEnt, pev_owner, id)
	set_pev(iEnt, pev_iuser2, 1)
}

public fw_think(iEnt)
{
    	if(!pev_valid(iEnt)) 
        	return

	new owner = pev(iEnt, pev_owner)
	if(!is_user_valid_connected(owner))
		return
	if(!is_user_valid_alive(owner))
		return

	new Float:fFrame, Float:fScale, Float:fNextThink
	pev(iEnt, pev_frame, fFrame)
	pev(iEnt, pev_scale, fScale)
	
	// effect exp
	new iMoveType = pev(iEnt, pev_movetype)
	if (iMoveType == MOVETYPE_NONE)
	{
		fNextThink = 0.015
		fFrame += 1.0
		
		if (fFrame > 21.0)
		{
			engfunc(EngFunc_RemoveEntity, iEnt)
			return 
		}
	}
	// effect normal
	else
	{
		fNextThink = 0.045
		fFrame += 1.0
		fFrame = floatmin(21.0, fFrame)
	}
	fScale = ((entity_range(iEnt, owner) / 500) * 3.0)
	
	set_pev(iEnt, pev_frame, fFrame)
	set_pev(iEnt, pev_scale, fScale)
	set_pev(iEnt, pev_nextthink, halflife_time() + fNextThink)
	
	// time remove
	new Float:fTimeRemove
	pev(iEnt, PEV_ENT_TIME, fTimeRemove)
	if (get_gametime() >= fTimeRemove)
	{
		engfunc(EngFunc_RemoveEntity, iEnt)
		return 
	}
	return
}

public fw_touch(ent, id)
{
	if(!pev_valid(ent))
		return FMRES_HANDLED

	if(pev(ent, pev_movetype) == MOVETYPE_NONE)
		return FMRES_HANDLED

	set_pev(ent, pev_movetype, MOVETYPE_NONE)
	set_pev(ent, pev_solid, SOLID_NOT)	
	
	if(!is_valid_ent(id))
		return FMRES_IGNORED
	
	if(!is_user_alive(id) || !is_user_valid_connected(id) || !g_zombie[id])
		return FMRES_IGNORED
	
	if(pev(ent, pev_iuser2) == 1)
	{
		set_pev(ent, pev_iuser2, 0)
		static attacker, ent_kill
		attacker = pev(ent, pev_owner)
		ent_kill = fm_get_user_weapon_entity(id, CSW_KNIFE)
		ExecuteHam(Ham_TakeDamage, id, ent_kill, attacker, zc_flamer_damage, DMG_BULLET)		
	}
	return FMRES_HANDLED
}

/*================================================================================
 [Oberon Powers]
=================================================================================*/
public ultbomb(id)
{	
	if(g_oberon[id] && is_user_alive(id)) 
	{
		static Float: gametime ; gametime = get_gametime();
		if(gametime - float(zc_oberon_bomb_cd) > g_BombCooldown[id])
		{
			do_bomb(id)
			g_BombCooldown[id] = gametime
		}else{
			zp_colored_print(id, "^x04[ZC]^x01 Your power will charge in:^x04 %.1f seconds !", float(zc_oberon_bomb_cd) - (gametime - g_BombCooldown[id]))
			return
		}	
	}else {
		return
	}
}

public ulthole(id)
{	
	if(g_oberon[id] && is_user_alive(id)) 
	{
		static Float: gametime ; gametime = get_gametime();
		if(gametime - float(zc_oberon_hole_cd) > g_HoleCooldown[id])
		{
			do_hole(id)
			g_HoleCooldown[id] = gametime
		}else{
			zp_colored_print(id, "^x04[ZC]^x01 Your power will charge in:^x04 %.1f seconds !", float(zc_oberon_hole_cd) - (gametime - g_HoleCooldown[id]))
			return
		}	
	}else {
		return
	}
}

public do_bomb(id)
{
	set_task(2.0, "do_skill_bomb", id, _, _, "b")
	set_task(3.8, "stop_skill_bomb", id)
}
	
public stop_skill_bomb(id)
{
	if(g_oberon[id]) {
		do_takedmg(id)
	}
	remove_task(id)
}

public do_skill_bomb(id)
{
	if(!native_has_round_started())
		return
	static Float:StartOrigin[3], Float:TempOrigin[3][3], Float:VicOrigin[3][3], Float:Random1
	pev(id, pev_origin, StartOrigin)
	emit_sound(id, CHAN_BODY, oberon_bomb_sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// 1st Bomb
	Random1 = random_float(100.0, 500.0)
	VicOrigin[0][0] = StartOrigin[0] + Random1
	VicOrigin[0][1] = StartOrigin[1]
	VicOrigin[0][2] = StartOrigin[2]
	TempOrigin[0][0] = VicOrigin[0][0] - (Random1 / 2.0)
	TempOrigin[0][1] = VicOrigin[0][1]
	TempOrigin[0][2] = VicOrigin[0][2] + 500.0
	
	// 2nd Bomb
	Random1 = random_float(100.0, 500.0)
	VicOrigin[1][0] = StartOrigin[0]
	VicOrigin[1][1] = StartOrigin[1] + Random1
	VicOrigin[1][2] = StartOrigin[2]
	TempOrigin[1][0] = VicOrigin[1][0]
	TempOrigin[1][1] = VicOrigin[1][1] - (Random1 / 2.0)
	TempOrigin[1][2] = VicOrigin[1][2] + 500.0	
	
	// 3rd Bomb
	Random1 = random_float(100.0, 500.0)
	VicOrigin[2][0] = StartOrigin[0] - Random1
	VicOrigin[2][1] = StartOrigin[1]
	VicOrigin[2][2] = StartOrigin[2]
	TempOrigin[2][0] = VicOrigin[2][0] - (Random1 / 2.0)
	TempOrigin[2][1] = VicOrigin[2][1]
	TempOrigin[2][2] = VicOrigin[2][2] + 500.0		
	for(new i = 0; i < 3; i++)
	{
		make_bomb(StartOrigin, TempOrigin[i], VicOrigin[i])
	}	
}

public make_bomb(Float:StartOrigin[3], Float:TempOrigin[3], Float:VicOrigin[3])
{
	if(!native_has_round_started())
		return
	new ent = create_entity("info_target")
	StartOrigin[2] += 20.0
	entity_set_origin(ent, StartOrigin)
	entity_set_string(ent,EV_SZ_classname, "oberon_bomb")
	entity_set_model(ent, oberon_bomb_model)
	entity_set_int(ent, EV_INT_solid, SOLID_NOT)
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_BOUNCE)
	new Float:maxs[3] = {10.0,10.0,10.0}
	new Float:mins[3] = {-10.0,-10.0,-5.0}
	entity_set_size(ent, mins, maxs)		
	static arg[4], arg2[4]
	arg[0] = ent
	arg[1] = floatround(TempOrigin[0])
	arg[2] = floatround(TempOrigin[1])
	arg[3] = floatround(TempOrigin[2])
	arg2[0] = ent
	arg2[1] = floatround(VicOrigin[0])
	arg2[2] = floatround(VicOrigin[1])
	arg2[3] = floatround(VicOrigin[2])	
	set_task(0.1, "do_hook_bomb_up", TASK_HOOKINGUP, arg, sizeof(arg), "b")
	set_task(0.9, "do_hook_bomb_down", _, arg2, sizeof(arg2))
	set_task(1.5, "bomb_explode", ent)
}

public bomb_explode(ent)
{
	remove_task(TASK_HOOKINGUP)
	remove_task(TASK_HOOKINGDOWN)
	static Float:Origin[3]
	pev(ent, pev_origin, Origin)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, Origin[0])
	engfunc(EngFunc_WriteCoord, Origin[1])
	engfunc(EngFunc_WriteCoord, Origin[2])
	write_short(exp_spr_id)	// sprite index
	write_byte(20)	// scale in 0.1's
	write_byte(30)	// framerate
	write_byte(0)	// flags
	message_end()	
	remove_entity(ent)
}

public do_hook_bomb_down(arg[4])
{
	remove_task(TASK_HOOKINGUP)
	set_task(0.1, "do_hook_bomb_down2", TASK_HOOKINGDOWN, arg, sizeof(arg), "b")
}

public do_hook_bomb_down2(arg[4])
{
	static ent, Float:VicOrigin[3]
	ent = arg[0]
	VicOrigin[0] = float(arg[1])
	VicOrigin[1] = float(arg[2])
	VicOrigin[2] = float(arg[3])	
	hook_ent2(ent, VicOrigin, 500.0)
}

public do_hook_bomb_up(arg[4])
{
	static ent, Float:TempOrigin[3]
	ent = arg[0]
	TempOrigin[0] = float(arg[1])
	TempOrigin[1] = float(arg[2])
	TempOrigin[2] = float(arg[3])
	hook_ent2(ent, TempOrigin, 500.0)
}

public do_hole(id)
{
	if(!native_has_round_started())
		return

	emit_sound(id, CHAN_BODY, oberon_hole_sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	new ent = create_entity("info_target")
	static Float:Origin[3]
	pev(id, pev_origin, Origin)
	
	Origin[2] -= 12.0
	
	entity_set_origin(ent, Origin)
	
	entity_set_string(ent,EV_SZ_classname, "hole_hook")
	entity_set_model(ent, oberon_hole_effect)
	entity_set_int(ent, EV_INT_solid, SOLID_NOT)
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_NONE)
	
	new Float:maxs[3] = {1.0,1.0,1.0}
	new Float:mins[3] = {-1.0,-1.0,-1.0}
	entity_set_size(ent, mins, maxs)
	
	entity_set_float(ent, EV_FL_animtime, get_gametime())
	entity_set_float(ent, EV_FL_framerate, 1.0)	
	entity_set_int(ent, EV_INT_sequence, 0)	
	
	set_pev(ent, pev_rendermode, kRenderTransAdd)
	set_pev(ent, pev_renderamt, 255.0)	
	
	drop_to_floor(ent)	

	for(new i = 0; i < g_maxplayers; i++)
	{
		if(is_user_valid_connected(i) && is_user_valid_connected(id) && is_user_alive(i) && is_user_alive(id) && !g_zombie[i] && entity_range(id, i) <= 1000.0)
		{
			static arg[2]
			arg[0] = id
			arg[1] = i
			set_task(0.01, "do_hook_player", 512512, arg, sizeof(arg), "b")
		}
	}
	set_task(5.0, "stop_hook", id+321321)	
}

public do_hook_player(arg[2])
{
	if(!is_user_valid_alive(arg[0]))
		return
	if(!is_user_valid_alive(arg[1]))
		return
	if(!native_has_round_started())
		return
	static Float:Origin[3], Float:Speed
	pev(arg[0], pev_origin, Origin)
	Speed = (1000.0 / entity_range(arg[0], arg[1])) * 75.0
	hook_ent2(arg[1], Origin, Speed)
}

public stop_hook(id)
{
	id -= 321321
	
	static ent
	ent = find_ent_by_class(-1, "hole_hook")
	remove_entity(ent)
	remove_task(512512)
	do_takedmg(id)
}

public hook_ent2(ent, Float:VicOrigin[3], Float:speed)
{
	if(!native_has_round_started())
		return
	static Float:fl_Velocity[3]
	static Float:EntOrigin[3]
	pev(ent, pev_origin, EntOrigin)
	static Float:distance_f
	distance_f = get_distance_f(EntOrigin, VicOrigin)
	if (distance_f > 60.0)
	{
		new Float:fl_Time = distance_f / speed
		fl_Velocity[0] = (VicOrigin[0] - EntOrigin[0]) / fl_Time
		fl_Velocity[1] = (VicOrigin[1] - EntOrigin[1]) / fl_Time
		fl_Velocity[2] = (VicOrigin[2] - EntOrigin[2]) / fl_Time
	}else {
		fl_Velocity[0] = 0.0
		fl_Velocity[1] = 0.0
		fl_Velocity[2] = 0.0
	}
	entity_set_vector(ent, EV_VEC_velocity, fl_Velocity)
}

public do_takedmg(id)
{	
	for(new victim = 1; victim < g_maxplayers; victim++)
	{
		if(victim != id && is_user_valid_connected(victim) && is_user_valid_connected(id) && is_user_alive(victim) && is_user_alive(id) && !g_zombie[victim] && entity_range(id, victim) <= 500.0)
		{
			damage_user(id, victim, 80)
		}
	}	
}

/*================================================================================
 [Dragon Powers]
=================================================================================*/
public use_cmd(id)
{	
	if(g_dragon[id] && is_user_alive(id)) 
	{
		static Float: gametime ; gametime = get_gametime();
		if(gametime -zc_dragon_frost_cd > g_DragonCooldown[id])
		{
			Create_IceBall(id)
			g_DragonCooldown[id] = gametime
		}else{
			zp_colored_print(id, "^x04[ZC]^x01 Your power will charge in:^x04 %.1f seconds !", zc_dragon_frost_cd - (gametime - g_DragonCooldown[id]))
			return
		}	
	}else {
		return
	}
}

public Create_IceBall(id)
{
	emit_sound(id, CHAN_VOICE, dragon_sound[random_num(0, sizeof dragon_sound - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	static Float:StartOrigin[3], Float:TargetOrigin[3], Float:MyVelocity[3], Float:VecLength
	get_position(id, 48.0, 10.0, -5.0, StartOrigin)
	get_position(id, 1024.0, 0.0, 0.0, TargetOrigin)
	
	pev(id, pev_velocity, MyVelocity)
	VecLength = vector_length(MyVelocity)
	
	if(VecLength)
	{
		TargetOrigin[0] += random_float(-16.0, 16.0); TargetOrigin[1] += random_float(-16.0, 16.0); TargetOrigin[2] += random_float(-16.0, 16.0)
	}else {
		TargetOrigin[0] += random_float(-8.0, 8.0); TargetOrigin[1] += random_float(-8.0, 8.0); TargetOrigin[2] += random_float(-8.0, 8.0)
	}
	
	static Ent; Ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"))
	if(!pev_valid(Ent)) 
		return
	
	set_pev(Ent, pev_movetype, MOVETYPE_FLY)
	set_pev(Ent, pev_rendermode, kRenderTransAdd)
	set_pev(Ent, pev_renderamt, 10.0)
	set_pev(Ent, pev_iuser1, id) // Better than pev_owner
	set_pev(Ent, pev_fuser1, get_gametime() + 3.0)
	set_pev(Ent, pev_scale, random_float(1.2, 2.2))
	set_pev(Ent, pev_nextthink, halflife_time() + 0.1)
	entity_set_string(Ent, EV_SZ_classname, DRAGON_FREEZE)
	engfunc(EngFunc_SetModel, Ent, DragonRes[0])
	set_pev(Ent, pev_mins, Float:{11.0, 11.0, 11.0})
	set_pev(Ent, pev_maxs, Float:{12.0, 12.0, 12.0})
	set_pev(Ent, pev_origin, StartOrigin)
	set_pev(Ent, pev_gravity, 0.1)
	set_pev(Ent, pev_solid, SOLID_TRIGGER)
	set_pev(Ent, pev_frame, 0.0)
	static Float:Velocity[3]
	get_speed_vector(StartOrigin, TargetOrigin, DRAGONFR_SPEED, Velocity)
	set_pev(Ent, pev_velocity, Velocity)
}

public fw_Think_Ice(Ent)
{
	if(!pev_valid(Ent))
		return
		
	static Float:RenderAmt; pev(Ent, pev_renderamt, RenderAmt)
	
	RenderAmt += 50.0
	RenderAmt = float(clamp(floatround(RenderAmt), 0, 255))
	set_pev(Ent, pev_renderamt, RenderAmt)
	set_pev(Ent, pev_nextthink, halflife_time() + 0.1)
}

public fw_Touch_Ice(Ent, Id)
{
	if(!pev_valid(Ent))
		return
	if(pev(Ent, pev_movetype) == MOVETYPE_NONE)
		return
		
	// Exp Sprite
	static Float:Origin[3], TE_FLAG
	pev(Ent, pev_origin, Origin)
	TE_FLAG |= TE_EXPLFLAG_NODLIGHTS
	TE_FLAG |= TE_EXPLFLAG_NOSOUND
	TE_FLAG |= TE_EXPLFLAG_NOPARTICLES
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, Origin[0])
	engfunc(EngFunc_WriteCoord, Origin[1])
	engfunc(EngFunc_WriteCoord, Origin[2])
	write_short(g_FrezeExp_SprID)
	write_byte(20)
	write_byte(40)
	write_byte(TE_FLAG)
	message_end()	
	
	// Set Froze
	SetFroze(Ent, Id)
	
	// Remove Ent
	set_pev(Ent, pev_movetype, MOVETYPE_NONE)
	set_task(0.1, "Remove_IceBall", Ent)
}

public SetFroze(Ent, Id)
{	
	for(new i = 0; i < get_maxplayers(); i++)
	{
		if(!is_user_alive(i) || g_zombie[i])
			continue
		if(entity_range(i, Ent) > DRAGONFR_RADIUS)
			continue

		native_set_user_frozen(i, 1)
		set_task(1.0+zc_dragon_frost_delay, "unfreeze", i)
	}
}

public unfreeze(id)
{
	native_set_user_frozen(id, 0)
}

public Remove_IceBall(Ent)
{
	if(!pev_valid(Ent)) return
	engfunc(EngFunc_RemoveEntity, Ent)
}

stock get_position(id,Float:forw, Float:right, Float:up, Float:vStart[])
{
	static Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]
	
	pev(id, pev_origin, vOrigin)
	pev(id, pev_view_ofs, vUp) //for player
	xs_vec_add(vOrigin, vUp, vOrigin)
	pev(id, pev_v_angle, vAngle) // if normal entity ,use pev_angles
	
	angle_vector(vAngle, ANGLEVECTOR_FORWARD, vForward) //or use EngFunc_AngleVectors
	angle_vector(vAngle, ANGLEVECTOR_RIGHT, vRight)
	angle_vector(vAngle, ANGLEVECTOR_UP, vUp)
	
	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
}

stock get_speed_vector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	static Float:num; num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
	
	return 1;
}

public client_PreThink(id) 
{
	// Set dragon power
	if(g_dragon[id]) 
	{
		new Float:fAim[3] , Float:fVelocity[3];
		VelocityByAim(id, 400, fAim);
		if((get_user_button(id) & IN_JUMP))
		{
			fVelocity[0] = fAim[0];
			fVelocity[1] = fAim[1];
			fVelocity[2] = fAim[2];
			set_user_velocity(id , fVelocity);
		}
	}
}

/*================================================================================
 [Zadoc Power]
=================================================================================*/
public Forward_EmitSound(id, channel, sample[]) 
{
	if(is_user_alive(id) && g_zadoc[id])
	{
        	if(equal(sample, "weapons/knife_hitwall1.wav"))
       	 	{
			static Float: gametime ; gametime = get_gametime();
			if(gametime - float(zc_zadoc_power_delay) > g_ZadocCooldown[id])
			{
				blast_players(id)
				g_ZadocCooldown[id] = gametime
			}else{
				zp_colored_print(id, "^x04[ZC]^x01 Your power will charge in:^x04 %.1f seconds !", float(zc_zadoc_power_delay) - (gametime - g_ZadocCooldown[id]))
				return FMRES_IGNORED
			}
		}
	}
	return FMRES_IGNORED
}

public blast_players(id)
{
	new Float: iOrigin[3]
	pev(id, pev_origin, iOrigin)
	emit_sound(id, CHAN_VOICE, zadoc_sound[random_num(0, sizeof zadoc_sound - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, iOrigin, 0)
	write_byte(TE_BEAMCYLINDER)
	engfunc(EngFunc_WriteCoord, iOrigin[0])
	engfunc(EngFunc_WriteCoord, iOrigin[1])
	engfunc(EngFunc_WriteCoord, iOrigin[2])
	engfunc(EngFunc_WriteCoord, iOrigin[0])
	engfunc(EngFunc_WriteCoord, iOrigin[1])
	engfunc(EngFunc_WriteCoord, iOrigin[2]+485.0)
	write_short(gSprZadoc)
	write_byte(0)
	write_byte(0)
	write_byte(4)
	write_byte(60)
	write_byte(0)
	write_byte(0)
	write_byte(255)
	write_byte(0)
	write_byte(200)
	write_byte(0)
	message_end()
	static Ent, Float: originF[3]
	while( (Ent = engfunc(EngFunc_FindEntityInSphere, Ent, iOrigin, zc_zadoc_radius)) )
	{
		if(is_user_valid_connected(Ent) && Ent != id)
		{
			//if(zp_get_user_zombie(Ent))
				//return PLUGIN_CONTINUE;
			
			pev(Ent, pev_origin, originF)
			originF[0] = (originF[0] - iOrigin[0]) * 12.0 
			originF[1] = (originF[1] - iOrigin[1]) * 12.0 
			originF[2] = (originF[2] - iOrigin[2]) + 500.0
			set_pev(Ent, pev_velocity, originF)
		}
	}
	return PLUGIN_HANDLED;
}

/*================================================================================
 [Nighter Power]
=================================================================================*/
public NighterChildsHUD()
{
	set_hudmessage(0, 100, 200, -1.0, 0.0, 0, 6.0, 8.0)
	show_hudmessage(0, "The Nighter has %d childs !", g_nchilds_num);
}

public NighterSetPower(id)
{
	if(!is_user_alive(id) || !g_nighter[id]) return;
	set_user_rendering(id, kRenderFxGlowShell, 20, 20, 20, kRenderTransAlpha, 15)
}

public NighterRemovePower(id)
{
	fm_set_rendering(id)
}

public NighterBlink(id)
{	
	if(is_user_alive(id) && g_nighter[id]) 
	{
		static Float: gametime; gametime = get_gametime()
		if(gametime - float(zc_nighter_blink_cd) > g_NighterblCooldown[id])
		{
			Ultimate_Blink(id)
			g_NighterblCooldown[id] = gametime
		}else{
			zp_colored_print(id, "^x04[ZC]^x01 Your power will charge in:^x04 %.1f seconds !", float(zc_nighter_blink_cd) - (gametime - g_NighterblCooldown[id]))
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE
}

/*================================================================================
 [LevelUP]
=================================================================================*/
public levelup(id)
{
	if(g_xp[id] > get_user_next(id)) 
	{
		if(g_xp[id] == get_user_next(id)) {
			g_xp[id] = 0
		}else if(g_xp[id] > get_user_next(id)) {
			g_xp[id] -= get_user_next(id)
		}
		g_level[id] += 1
		client_cmd(id, "spk %s", LEVELUP_S)
		
	}
}

public get_user_next(id)
{
	new x[33]
	if(g_level[id] >= 1 && g_level[id] <= zc_max_level) x[id] = g_level[id] * zc_level_step
	else if(g_level[id] == zc_max_level) x[id] = 0
	return x[id];
}

/*================================================================================
 [Respawn Menu]
=================================================================================*/
public open_menu(pPlayer) 
{
	if(!is_user_alive(pPlayer))  open_respawn_menu(pPlayer)
	else  zp_colored_print(pPlayer, "^x04[ZC]^x01 You are alive") 
	return PLUGIN_HANDLED
}

public open_respawn_menu(pPlayer) 
{
	static menu[1024 char] , len 
	len = 0 
	new ipacks = g_ammopacks[pPlayer] - COST_SPAWN 
	len += formatex(menu[len] , charsmax(menu) - len , "Respawn Menu^n^nYour packs \r(\y%d\r)^n\wCost respawn \r(\y%d\r)^n\wpacks after respawn \r(\y%d\r)^n", g_ammopacks[pPlayer], COST_SPAWN , ipacks) 
	
	if(g_ammopacks[pPlayer] < COST_SPAWN) 
	{
		len += formatex(menu[len], charsmax(menu) - len, "^n\d1. \dRespawn as a zombie(\rNot enough packs\d)^n"); 
		len += formatex(menu[len], charsmax(menu) - len, "\d2. \dRespawn as a human(\rNot enough packs\d)^n"); 
	}else if(native_is_hero_round()) {
		len += formatex(menu[len], charsmax(menu) - len, "^n\d1. \dRespawn as a zombie(\rInvalid round\d)^n"); 
		len += formatex(menu[len], charsmax(menu) - len, "\d2. \dRespawn as a human(\rInvalid round\d)^n"); 
	}else {
		len += formatex(menu[len], charsmax(menu) - len, "^n\r1. \wRespawn as a zombie^n"); 
		len += formatex(menu[len], charsmax(menu) - len, "\r2. \wRespawn as a human^n"); 
	}
	
	len += formatex(menu[len], charsmax(menu) - len, "^n\r0. \wExit")
	set_pdata_int(pPlayer , 205, 0, 5)
	show_menu(pPlayer, KEYSMENU, menu, -1, "menu_res")
}

public respawn_menu(pPlayer, key) 
{
	switch(key) 
	{
		case 0: 
		{
			ExecuteForward(g_fwRespawnMenuZM, g_fwDummyResult, pPlayer)
        		if (g_fwDummyResult >= PLUGIN_HANDLED)
			{
				zp_colored_print(pPlayer, "^x04[ZC]^x01 You can't use it right now.")
				return ZP_PLUGIN_HANDLED;
			}
			if(g_ammopacks[pPlayer] < COST_SPAWN) 
			{				
				zp_colored_print(pPlayer, "^x04[ZC]^x01 You don't have enough packs, needed^x04 %d", COST_SPAWN)
				open_respawn_menu(pPlayer) 
				return PLUGIN_HANDLED
			}else if(native_is_hero_round()) {				
				zp_colored_print(pPlayer, "^x04[ZC]^x01 This round is prohibited to respawn.") 
				open_respawn_menu(pPlayer) 
			}else {
				g_ammopacks[pPlayer] = g_ammopacks[pPlayer] - COST_SPAWN
				native_respawn_user(pPlayer , ZP_TEAM_ZOMBIE);
				set_hudmessage(255, 255, 0, 0.05, 0.45, 1, 0.0, 1.0, 1.0, 1.0, -1);
				show_hudmessage(0, "%s used Respawn", g_playername[pPlayer]);
			}	
		}
		case 1:
		{
			ExecuteForward(g_fwRespawnMenuHM, g_fwDummyResult, pPlayer)
        		if (g_fwDummyResult >= PLUGIN_HANDLED)
			{
				zp_colored_print(pPlayer, "^x04[ZC]^x01 You can't use it right now.")
				return ZP_PLUGIN_HANDLED;
			}
			if(g_ammopacks[pPlayer] < COST_SPAWN) 
			{				
				zp_colored_print(pPlayer, "^x04[ZC]^x01 You don't have enough packs, needed^x04 %d", COST_SPAWN)
				open_respawn_menu(pPlayer) 
				return PLUGIN_HANDLED
			}else if(native_is_hero_round()) {				
				zp_colored_print(pPlayer, "^x04[ZC]^x01 This round is prohibited to respawn.") 
				open_respawn_menu(pPlayer) 
			}else {
				g_ammopacks[pPlayer] = g_ammopacks[pPlayer] - COST_SPAWN
				native_respawn_user(pPlayer , ZP_TEAM_HUMAN);
				set_hudmessage(255, 255, 0, 0.05, 0.45, 1, 0.0, 1.0, 1.0, 1.0, -1);
				show_hudmessage(0, "%s used Respawn", g_playername[pPlayer]);
			}	
		}
	}
	return PLUGIN_HANDLED
}

/*================================================================================
 [Powers]
=================================================================================*/
public ultbl(id)
{	
	if(!native_has_round_started() || !is_user_alive(id) || native_get_zombie_hero(id) || native_get_human_hero(id)) 
		return PLUGIN_HANDLED

	if(blink_used[id] < blink_l[id])
	{
		blink_can[id] = true
		static Float: gametime; gametime = get_gametime()
		if(gametime - float(zc_blink_cooldown) > g_cblCooldown[id])
		{
			Ultimate_Blink(id)
			g_cblCooldown[id] = gametime
		}else{
			zp_colored_print(id, "^x04[ZC]^x01 Your power will charge in:^x04 %.1f seconds !", float(zc_blink_cooldown) - (gametime - g_cblCooldown[id]))
			return PLUGIN_HANDLED
		}
	}else{
		zp_colored_print(id, "^x04[ZC]^x01 You have no^x04 blink^x01 remaining!")
		return PLUGIN_HANDLED
	}	
	return PLUGIN_CONTINUE
}

public ultch(id)
{	
	if(!is_user_alive(id) || chain_can[id]) 
		return PLUGIN_HANDLED

	if(chain_used[id] < chain_l[id])
	{
		static Float: gametime; gametime = get_gametime()
		if(gametime - float(zc_chain_cooldown) > g_cchCooldown[id])
		{
			chain_can[id] = true
			chain_used[id] += 1
			zp_colored_print(id, "^x04[ZC]^x01 Put^x04 your crosshair^x01 on a^x04 victim!")
			g_cchCooldown[id] = gametime
		}else{
			zp_colored_print(id, "^x04[ZC]^x01 Your power will charge in:^x04 %.1f seconds !", float(zc_chain_cooldown) - (gametime - g_cchCooldown[id]))
			return PLUGIN_HANDLED
		}
	}else{
		zp_colored_print(id, "^x04[ZC]^x01 You have no^x04 Thunderbolt^x01 remaining!")
		return PLUGIN_HANDLED
	}	
	return PLUGIN_CONTINUE
}

// Start Blink Power
public Ultimate_Blink(id) 
{
	new Origin[3], NewOrigin[3]
	get_user_origin(id, NewOrigin, 3)
	get_user_origin(id, Origin)
	
	Origin[2] += 15
	NewOrigin[2] += 15

	if(!blink_can[id] && !g_nighter[id])
	{
		client_print(id, print_center, "You don't have any blink!")
		return false
	}	
	
	if(pev(id, pev_maxspeed) <= 1.0) 
	{
		client_print(id, print_center, "You can't blink when you're stunned!")
		return false
	}
	
	new Float:SpriteOrigin[3]
	pev(id, pev_origin, SpriteOrigin)
	set_user_origin(id, NewOrigin)
	new Float:SpriteOrigin2[3]
	pev(id, pev_origin, SpriteOrigin2)
	if(is_pplayer_stuck(id)) {				
		if(is_user_connected(id)) {
			static Float:origin[3]
			static Float:mins[3], hull
			static Float:vec[3]
			static o
			pev(id, pev_origin, origin)
			hull = pev(id, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN
			if(!is_phull_vacant(origin, hull, id) && !(pev(id, pev_solid) & SOLID_NOT)) {
				pev(id, pev_mins, mins)
				vec[2] = origin[2]
				for(o = 0; o < sizeof Size; ++o) {
					vec[0] = origin[0] - mins[0] * Size[o][0]
					vec[1] = origin[1] - mins[1] * Size[o][1]
					vec[2] = origin[2] - mins[2] * Size[o][2]
					if(is_phull_vacant(vec, hull, id)) {
						engfunc(EngFunc_SetOrigin, id, vec)
						set_pev(id, pev_velocity,{0.0,0.0,0.0})
						o = sizeof Size
					}
				}
			}
		}
	}
	emit_sound(id, CHAN_STATIC, SOUND_BLINK, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST,SVC_TEMPENTITY, SpriteOrigin, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, SpriteOrigin[0]) // x axis
	engfunc(EngFunc_WriteCoord, SpriteOrigin[1]) // y axis
	engfunc(EngFunc_WriteCoord, SpriteOrigin[2]) // z axis
	write_short(SPR_TELEPORT)
	write_byte(22)
	write_byte(35)
	write_byte(TE_EXPLFLAG_NOSOUND)
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST,SVC_TEMPENTITY, SpriteOrigin2, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, SpriteOrigin2[0]) // x axis
	engfunc(EngFunc_WriteCoord, SpriteOrigin2[1]) // y axis
	engfunc(EngFunc_WriteCoord, SpriteOrigin2[2]) // z axis
	write_short(SPR_TELEPORT)
	write_byte(22)
	write_byte(35)
	write_byte(TE_EXPLFLAG_NOSOUND)
	message_end()
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_SPRITETRAIL)
	write_coord(floatround(SpriteOrigin2[0]))
	write_coord(floatround(SpriteOrigin2[1]))
	write_coord(floatround(SpriteOrigin2[2])+40)
	write_coord(floatround(SpriteOrigin2[0]))
	write_coord(floatround(SpriteOrigin2[1]))
	write_coord(floatround(SpriteOrigin2[2]))
	write_short(SPR_TELEPORT_GIB)
	write_byte(30)
	write_byte(10)
	write_byte(1)
	write_byte(50)
	write_byte(10)
	message_end()
	
	Create_ScreenFade(id,(1<<15),(1<<10),(1<<12), 0, 0, 255, 180)
	Create_ScreenShake(id,(1<<14),(1<<13),(1<<14))
	if(!g_nighter[id])
	{
		blink_can[id] = false
		blink_used[id] += 1
		zp_colored_print(id, "^x04[ZC]^x01 Blink remaining:^x04 %d", blink_l[id]-blink_used[id])
	}
	return true
}

public is_pplayer_stuck(id) 
{
	static Float:originF[3]
	pev(id, pev_origin, originF)
	engfunc(EngFunc_TraceHull, originF, originF, 0,(pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0)
	if(get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen))
		return true
	return false
}

public is_phull_vacant(const Float:origin[3], hull, id)
{
	static tr
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, id, tr)
	if(!get_tr2(tr, TR_StartSolid) || !get_tr2(tr, TR_AllSolid))
		return true
	return false
}

// Start Chain Lightning Power
// Prethink - zombie_crown

public Ultimate_ChainLightning(Caster, Target, BodyPart) 
{
	if(is_user_connected(Caster) && chain_can[Caster])
	{
		zp_colored_print(Caster, "^x04[ZC]^x01 Thunderbolt remaining:^x04 %d", chain_l[Caster]-chain_used[Caster])
		if(g_zombie[Caster])
		{
			ChainEffect(Caster, Target, 60, CHAINLIGHTNING_DAMAGEH, BodyPart)
			new parm[5]
			parm[0] = Target
			parm[1] = CHAINLIGHTNING_DAMAGEH
			parm[2] = 60
			parm[3] = Caster
			parm[4] = BodyPart
			set_task(0.2, "ChainLightning", TASK_LIGHTNING + Target, parm, 5)	
		}else if(!g_zombie[Caster] && !native_get_zombie_hero(Target)){
			ChainEffect(Caster, Target, 60, CHAINLIGHTNING_DAMAGEZ, BodyPart)
			new parm[5]
			parm[0] = Target
			parm[1] = CHAINLIGHTNING_DAMAGEZ
			parm[2] = 60
			parm[3] = Caster
			parm[4] = BodyPart
			set_task(0.2, "ChainLightning", TASK_LIGHTNING + Target, parm, 5)	
		}
	}
}

public ChainLightning(parm[5]) 
{
	new Enemy = parm[0]
	if(is_user_connected(Enemy)) 
	{
		new Caster = parm[3]
		new BodyPart = parm[4]
		new CasterTeam	= get_user_team(Caster)
		
		new Origin[3]
		get_user_origin(Enemy, Origin)
		
		new Players[32], Num
		get_players(Players, Num, "a")
		
		new i, Target = 0
		new ClosestTarget = 0, ClosestDistance = 0
		new DistanceBetween = 0
		new TargetOrigin[3]
		
		for(i = 0; i < Num; i++) {
			Target = Players[i]
			if(get_user_team(Target) != CasterTeam) {
				get_user_origin(Target, TargetOrigin)
				DistanceBetween = get_distance(Origin, TargetOrigin)
				if(DistanceBetween < 500 && !LightningHit[Target]) {
					if(DistanceBetween < ClosestDistance || ClosestTarget == 0) {
						ClosestDistance = DistanceBetween
						ClosestTarget = Target
					}
				}
			}
		}
		if(ClosestTarget) {
			parm[1] = floatround(float(parm[2])*2/3)
			parm[2] = floatround(float(parm[2])*2/3)
			
			ChainEffect(Caster, ClosestTarget, parm[2], parm[1], BodyPart)
			
			parm[0] = ClosestTarget
			set_task(0.2, "ChainLightning", TASK_LIGHTNINGNEXT + Caster, parm, 5)
		}
		else {
			for(i = 0; i < Num; i++) {
				LightningHit[Players[i]] = false
			}
		}
	}
}

public ChainEffect(Caster, Target, LineWidth, Damage, BodyPart)
{
	LightningHit[Target] = true
	damage_user(Caster, Target, Damage)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMENTS)
	write_short(Caster)		// start entity
	write_short(Target)		// end entity
	write_short(SPR_LIGHTNING)	// model
	write_byte(0)			// starting frame
	write_byte(30)			// frame rate
	write_byte(10)			// life
	write_byte(LineWidth)		// line width
	write_byte(50)			// noise amplitude
	write_byte(255)			// red
	write_byte(255)			// green
	write_byte(255)			// blue
	write_byte(200)			// brightness
	write_byte(0)			// scroll speed
	message_end()
	
	new Origin[3]
	get_user_origin(Target, Origin)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_ELIGHT)
	write_short(Target)			// entity
	write_coord(Origin[0])			// initial position
	write_coord(Origin[1])			// initial position
	write_coord(Origin[2])			// initial position
	write_coord(100)			// radius
	write_byte(255)				// red
	write_byte(255)				// green
	write_byte(255)				// blue
	write_byte(10)				// life
	write_coord(0)				// decay rate
	message_end()
	emit_sound(Caster, CHAN_STATIC, SOUND_LIGHTNING, 1.0, ATTN_NORM, 0, PITCH_NORM)
}

// Start WallHang
public HAM_Player_Touch(id, world) 
{
	if(!is_user_alive(id) || wallh_l[id] == 0 && wh_used[id] > wallh_l[id]) return	
	new ClassName[32]
	pev(world, pev_classname, ClassName,(32-1))
	if(equal(ClassName, "worldspawn") || equal(ClassName, "func_wall") || equal(ClassName, "func_breakable"))
		pev(id, pev_origin, Wallorigin[id])
}

public WallHPWR(id)
{
	if(!is_user_alive(id) || wh_used[id] > wallh_l[id]) return
	static Float:Origin[3]
	pev(id, pev_origin, Origin)
	static Button 
	Button = pev(id, pev_button)
	if(Button & IN_USE && get_distance_f(Origin, Wallorigin[id]) <= 5.0 && !(pev(id, pev_flags) & FL_ONGROUND)) 
	{
		new Float:Velocity[3]
		new ClimbSpeed = floatround(pev(id, pev_maxspeed) / 2.0)
		if(Button & IN_FORWARD) {
			velocity_by_aim(id, ClimbSpeed, Velocity)
			fm_set_user_velocity(id, Velocity)
			can_use_wh[id] = 1
		}else {
			set_pev(id, pev_origin, Wallorigin[id])
			velocity_by_aim(id, 0, Velocity)
			fm_set_user_velocity(id, Velocity)
		}	
	}else if (get_distance_f(Origin, Wallorigin[id]) > 5.0 && (pev(id, pev_flags) & FL_ONGROUND) && can_use_wh[id] == 1) {
		wh_used[id]++
		can_use_wh[id] = 0
		zp_colored_print(id, "^x04[ZC]^x01 Wall hangs^x04 remaining^x01:^x03 %d", (1+wallh_l[id]) - wh_used[id])		
	}
}
// Stop WallHang

public armpwr(id)
{
	fm_set_user_armor(id, get_user_armor(id) + armor_l[id]*10)
}

public menu_powers(id)
{
	new pn_hp, pn_armor, pn_speed, pn_asp, pn_blink, pn_chain, pn_wallh
	if(hp_l[id] == 0) pn_hp = zc_powers_prices[0]
	else pn_hp = hp_l[id] * zc_powers_prices[0]
	
	if(armor_l[id] == 0) pn_armor = zc_powers_prices[1]
	else pn_armor = armor_l[id] * zc_powers_prices[1]

	if(speed_l[id] == 0) pn_speed = zc_powers_prices[2]
	else pn_speed = speed_l[id] * zc_powers_prices[2]

	if(asp_l[id] == 0) pn_asp = zc_powers_prices[3]
	else pn_asp = asp_l[id] * zc_powers_prices[3]

	if(blink_l[id] == 0) pn_blink = zc_powers_prices[4]
	else pn_blink = blink_l[id] * zc_powers_prices[4]

	if(chain_l[id] == 0) pn_chain = zc_powers_prices[5]
	else pn_chain = chain_l[id] * zc_powers_prices[5]

	if(wallh_l[id] == 0) pn_wallh = zc_powers_prices[6]
	else pn_wallh = wallh_l[id] * zc_powers_prices[6]

	new szmenu[555]	
	new hzmenu = menu_create("\rPower System:", "hzmshop_H")
	if(hp_l[id] < zc_powers_levels[0]) formatex(szmenu, 63,"\wHP \r| \y%d\r points | \r%d\w%%", pn_hp, hp_l[id])
	else formatex(szmenu, 63,"\dHP \r| \yMaxim power \r| \r%d\w%%", hp_l[id])
	menu_additem(hzmenu, szmenu)

	if(armor_l[id] < zc_powers_levels[1]) formatex(szmenu, 63,"\wArmor \r| \y%d\r points | \r%d\w%%", pn_armor, armor_l[id])
	else formatex(szmenu, 63,"\dArmor \r| \yMaxim power \r| \r%d\w%%", armor_l[id])
	menu_additem(hzmenu, szmenu)

	if(speed_l[id] < zc_powers_levels[2]) formatex(szmenu, 63,"\wSpeed \r| \y%d\r points | \r%d\w%%", pn_speed, speed_l[id])
	else formatex(szmenu, 63,"\dSpeed \r| \yMaxim power \r| \r%d\w%%", speed_l[id])
	menu_additem(hzmenu, szmenu)

	if(asp_l[id] < zc_powers_levels[3]) formatex(szmenu, 63,"\wAspirine \r| \y%d\r points | \r%d\w%%", pn_asp, asp_l[id])
	else formatex(szmenu, 63,"\dAspirine \r| \yMaxim power \r| \r%d\w%%", asp_l[id])
	menu_additem(hzmenu, szmenu)

	if(blink_l[id] < zc_powers_levels[4]) formatex(szmenu, 63,"\wBlink \r| \y%d\r points | \r%d\w%%", pn_blink, blink_l[id])
	else formatex(szmenu, 63,"\dBlink \r| \yMaxim power \r| \r%d\w%%", blink_l[id])
	menu_additem(hzmenu, szmenu)

	if(chain_l[id] < zc_powers_levels[5]) formatex(szmenu, 63,"\wThunderbolt \r| \y%d\r points | \r%d\w%%", pn_chain, chain_l[id])
	else formatex(szmenu, 63,"\dThunderbolt \r| \yMaxim power \r| \r%d\w%%", chain_l[id])
	menu_additem(hzmenu, szmenu)

	if(wallh_l[id] < zc_powers_levels[6]) formatex(szmenu, 63,"\wWhallHang \r| \y%d\r points | \r%d\w%%", pn_wallh, wallh_l[id])
	else formatex(szmenu, 63,"\dWallHang \r| \yMaxim power \r| \r%d\w%%", wallh_l[id])
	menu_additem(hzmenu, szmenu)
			
	menu_setprop(hzmenu, MPROP_BACKNAME, "Back")
	menu_setprop(hzmenu, MPROP_NEXTNAME, "Next")
	menu_setprop(hzmenu, MPROP_EXITNAME, "Exit")	
	menu_display(id, hzmenu)
}

public hzmshop_H(id, menu, item)
{
	new pn_hp, pn_armor, pn_speed, pn_asp, pn_blink, pn_chain, pn_wallh
	if(hp_l[id] == 0) pn_hp = zc_powers_prices[0]
	else pn_hp = hp_l[id] * zc_powers_prices[0] 
	
	if(armor_l[id] == 0) pn_armor = zc_powers_prices[1]
	else pn_armor = armor_l[id] * zc_powers_prices[1]

	if(speed_l[id] == 0) pn_speed = zc_powers_prices[2]
	else pn_speed = speed_l[id] * zc_powers_prices[2]

	if(asp_l[id] == 0) pn_asp = zc_powers_prices[3]
	else pn_asp = asp_l[id] * zc_powers_prices[3]

	if(blink_l[id] == 0) pn_blink = zc_powers_prices[4]
	else pn_blink = blink_l[id] * zc_powers_prices[4]

	if(chain_l[id] == 0) pn_chain = zc_powers_prices[5]
	else pn_chain = chain_l[id] * zc_powers_prices[5]

	if(wallh_l[id] == 0) pn_wallh = zc_powers_prices[6]
	else pn_wallh = wallh_l[id] * zc_powers_prices[6]

	switch(item)
	{
		case 0:
		{
			if(hp_l[id] < zc_powers_levels[0])
			{
				if(g_points[id] >= pn_hp)
				{
					g_points[id] = g_points[id] - pn_hp
					hp_l[id] += 1
					zp_colored_print(id, "^x04[ZC]^x01 You've advanced^x04 %d levels^x01 on^x04 HP.", hp_l[id])
					
					client_cmd(id, "spk %s", LEVELUP_S)
				}else{
					zp_colored_print(id, "^x04[ZC]^x01 You don't have enough points - needed^x04 %d^x01.", pn_hp)
				}
			}else {
				hp_l[id] = zc_powers_levels[0]
				zp_colored_print(id, "^x04[ZC]^x01 You have this power maximum increased.")
			}
		}
		case 1:
		{
			if(armor_l[id] < zc_powers_levels[1])
			{
				if(g_points[id] >= pn_armor)
				{
					g_points[id] = g_points[id] - pn_armor
					armor_l[id] += 1
					zp_colored_print(id, "^x04[ZC]^x01 You've advanced^x04 %d levels^x01 on^x04 Armor.", armor_l[id])
					
					client_cmd(id, "spk %s", LEVELUP_S)
				}else{
					zp_colored_print(id, "^x04[ZC]^x01 You don't have enough points - needed^x04 %d^x01.", pn_armor)
				}
			}else {
				armor_l[id] = zc_powers_levels[1]
				zp_colored_print(id, "^x04[ZC]^x01 You have this power maximum increased.")
			}
		}
		case 2:
		{
			if(speed_l[id] < zc_powers_levels[2])
			{
				if(g_points[id] >= pn_speed)
				{
					g_points[id] = g_points[id] - pn_speed
					speed_l[id] += 1
					zp_colored_print(id, "^x04[ZC]^x01 You've advanced^x04 %d levels^x01 on^x04 Speed.", speed_l[id])
					
					client_cmd(id, "spk %s", LEVELUP_S)
				}else{
					zp_colored_print(id, "^x04[ZC]^x01 You don't have enough points - needed^x04 %d^x01.", pn_speed)
				}
			}else {
				speed_l[id] = zc_powers_levels[2]
				zp_colored_print(id, "^x04[ZC]^x01 You have this power maximum increased.")
			}
		}
		case 3:
		{
			if(asp_l[id] < zc_powers_levels[3])
			{
				if(g_points[id] >= pn_asp)
				{
					g_points[id] = g_points[id] - pn_asp
					asp_l[id] += 1
					zp_colored_print(id, "^x04[ZC]^x01 You've advanced^x04 %d levels^x01 on^x04 Aspirine.", asp_l[id])
					
					client_cmd(id, "spk %s", LEVELUP_S)
				}else{
					zp_colored_print(id, "^x04[ZC]^x01 You don't have enough points - needed^x04 %d^x01.", pn_asp)
				}
			}else {
				asp_l[id] = zc_powers_levels[3]
				zp_colored_print(id, "^x04[ZC]^x01 You have this power maximum increased.")
			}
		}
		case 4:
		{
			if(blink_l[id] < zc_powers_levels[4])
			{
				if(g_points[id] >= pn_blink)
				{
					g_points[id] = g_points[id] - pn_blink
					blink_l[id] += 1
					zp_colored_print(id, "^x04[ZC]^x01 You've advanced^x04 %d levels^x01 on^x04 Blink.", blink_l[id])
					zp_colored_print(id, "^x04[ZC]^x01 Use^x04 blink^x01 pressing^x04 F3^x01. Write in console:^x04 bind F3 blinkpw")
					zp_colored_print(id, "^x04[ZC]^x01 Use^x04 blink^x01 pressing^x04 F3^x01. Write in console:^x04 bind F3 blinkpw")
					
					client_cmd(id, "spk %s", LEVELUP_S)
				}else{
					zp_colored_print(id, "^x04[ZC]^x01 You don't have enough points - needed^x04 %d^x01.", pn_blink)
				}
			}else {
				blink_l[id] = zc_powers_levels[4]
				zp_colored_print(id, "^x04[ZC]^x01 You have this power maximum increased.")
			}
		}
		case 5:
		{
			if(chain_l[id] < zc_powers_levels[5])
			{
				if(g_points[id] >= pn_chain)
				{
					g_points[id] = g_points[id] - pn_chain
					chain_l[id] += 1
					zp_colored_print(id, "^x04[ZC]^x01 You've advanced^x04 %d levels^x01 on^x04 Thunderbolt.", chain_l[id])
					zp_colored_print(id, "^x04[ZC]^x01 Use^x04 thunderblots^x01 pressing^x04 F4^x01. Write in console:^x04 bind F4 chainpw")
					zp_colored_print(id, "^x04[ZC]^x01 Use^x04 thunderblots^x01 pressing^x04 F4^x01. Write in console:^x04 bind F4 chainpw")
					
					client_cmd(id, "spk %s", LEVELUP_S)
				}else{
					zp_colored_print(id, "^x04[ZC]^x01 You don't have enough points - needed^x04 %d^x01.", pn_chain)
				}
			}else {
				chain_l[id] = zc_powers_levels[5]
				zp_colored_print(id, "^x04[ZC]^x01 You have this power maximum increased.")
			}
		}
		case 6:
		{
			if(wallh_l[id] < zc_powers_levels[6])
			{
				if(g_points[id] >= pn_wallh)
				{
					g_points[id] = g_points[id] - pn_wallh
					wallh_l[id] += 1
					zp_colored_print(id, "^x04[ZC]^x01 You've advanced^x04 %d levels^x01 on^x04 Wall Hang.", wallh_l[id])
					zp_colored_print(id, "^x04[ZC]^x01 Use^x04 wall hang^x01 pressing^x04 Space + E + W^x01 near a wall.")
					zp_colored_print(id, "^x04[ZC]^x01 Use^x04 wall hang^x01 pressing^x04 Space + E + W^x01 near a wall.")
					
					client_cmd(id, "spk %s", LEVELUP_S)
				}else{
					zp_colored_print(id, "^x04[ZC]^x01 You don't have enough points - needed^x04 %d^x01.", pn_wallh)
				}
			}else {
				wallh_l[id] = zc_powers_levels[6]
				zp_colored_print(id, "^x04[ZC]^x01 You have this power maximum increased.")
			}
		}
	}
	menu_destroy(menu)
    	return PLUGIN_HANDLED
}

public SetHP(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2)){
		return PLUGIN_HANDLED;
	}
	new arg1[32], arg2[10], amount
	read_argv(1, arg1, sizeof(arg1) - 1)
	read_argv(2, arg2, sizeof(arg2) - 1)
	amount = str_to_num(arg2)
	if(amount <= 0) amount = 1
	new target = cmd_target(0, arg1, 2)
	if (target == 0)
	{
		zp_colored_print(id, "^x04[ZC]^x01 I can't find this player.")
		return PLUGIN_HANDLED
	}else { 
		hp_l[target] = amount
		if(id == target)
		{
			zp_colored_print(id, "^x04[ZC]^x01 You've set yourself HP level to %d!", amount)
		}else {
			zp_colored_print(id, "^x04[ZC]^x01 You've set to %s HP level to %d!", g_playername[target], amount)
			zp_colored_print(target, "^x04[ZC]^x01 You've been set HP level to %d!", amount)
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public SetArmor(id, level, cid)
{	
	if (!cmd_access(id, level, cid, 2)){
		return PLUGIN_HANDLED;
	}
	new arg1[32], arg2[10], amount
	read_argv(1, arg1, sizeof(arg1) - 1)
	read_argv(2, arg2, sizeof(arg2) - 1)	
	amount = str_to_num(arg2)
	if(amount <= 0) amount = 1
	new target = cmd_target(0, arg1, 2)
	if (target == 0)
	{
		zp_colored_print(id, "^x04[ZC]^x01 I can't find this player.")	
		return PLUGIN_HANDLED
	}else { 
		armor_l[target] = amount
		if(id == target)
		{
			zp_colored_print(id, "^x04[ZC]^x01 You've set yourself armor level to %d!", amount)
		}else {
			zp_colored_print(id, "^x04[ZC]^x01 You've set to %s armor level to %d!" , g_playername[target], amount)
			zp_colored_print(target, "^x04[ZC]^x01 You've been set armor level to %d!" , amount)
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED	
}

public SetSpeed(id, level, cid)
{	
	if (!cmd_access(id, level, cid, 2)){
		return PLUGIN_HANDLED;
	}
	new arg1[32], arg2[10], amount
	read_argv(1, arg1, sizeof(arg1) - 1)
	read_argv(2, arg2, sizeof(arg2) - 1)	
	amount = str_to_num(arg2)
	if(amount <= 0) amount = 1
	new target = cmd_target(0, arg1, 2)
	if (target == 0)
	{
		zp_colored_print(id, "^x04[ZC]^x01 I can't find this player.")	
		return PLUGIN_HANDLED
	}else { 
		speed_l[target] = amount
		if(id == target)
		{
			zp_colored_print(id, "^x04[ZC]^x01 You've set yourself speed level to %d!", amount)
		}else {
			zp_colored_print(id, "^x04[ZC]^x01 You've set to %s speed level to %d!" , g_playername[target], amount)
			zp_colored_print(target, "^x04[ZC]^x01 You've been set armor level to %d!" , amount)
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED	
}

public SetAspirine(id, level, cid)
{	
	if (!cmd_access(id, level, cid, 2)){
		return PLUGIN_HANDLED;
	}	
	new arg1[32], arg2[10], amount
	read_argv(1, arg1, sizeof(arg1) - 1)
	read_argv(2, arg2, sizeof(arg2) - 1)	
	amount = str_to_num(arg2)
	if(amount <= 0) amount = 1
	new target = cmd_target(0, arg1, 2)
	if (target == 0)
	{
		zp_colored_print(id, "^x04[ZC]^x01 I can't find this player.")
		return PLUGIN_HANDLED

	}else { 
		asp_l[target] = amount
		if(id == target)
		{
			zp_colored_print(id, "^x04[ZC]^x01 You've set yourself Aspirine level to %d!", amount)
		}else {
			zp_colored_print(id, "^x04[ZC]^x01 You've set to %s Aspirine level to %d!" , g_playername[target], amount)
			zp_colored_print(target, "^x04[ZC]^x01 You've been set Aspirine level to %d!" , amount)
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED	
}

public SetBlink(id, level, cid)
{	
	if (!cmd_access(id, level, cid, 2)){
		return PLUGIN_HANDLED;
	}	
	new arg1[32], arg2[10], amount
	read_argv(1, arg1, sizeof(arg1) - 1)
	read_argv(2, arg2, sizeof(arg2) - 1)	
	amount = str_to_num(arg2)
	if(amount <= 0) amount = 1
	new target = cmd_target(0, arg1, 2)
	if (target == 0)
	{
		zp_colored_print(id, "^x04[ZC]^x01 I can't find this player.")	
		return PLUGIN_HANDLED
	}else { 
		blink_l[target] = amount
		if(id == target)
		{
			zp_colored_print(id, "^x04[ZC]^x01 You've set yourself Blink level to %d!", amount)
		}else {
			zp_colored_print(id, "^x04[ZC]^x01 You've set to %s Blink level to %d!" , g_playername[target], amount)
			zp_colored_print(target, "^x04[ZC]^x01 You've been set Blink level to %d!" , amount)
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED	
}

public SetChain(id, level, cid)
{	
	if (!cmd_access(id, level, cid, 2)){
		return PLUGIN_HANDLED;
	}	
	new arg1[32], arg2[10], amount
	read_argv(1, arg1, sizeof(arg1) - 1)
	read_argv(2, arg2, sizeof(arg2) - 1)	
	amount = str_to_num(arg2)
	if(amount <= 0) amount = 1
	new target = cmd_target(0, arg1, 2)
	if (target == 0)
	{
		zp_colored_print(id, "^x04[ZC]^x01 I can't find this player.")
		return PLUGIN_HANDLED

	}else { 
		chain_l[target] = amount
		if(id == target)
		{
			zp_colored_print(id, "^x04[ZC]^x01 You've set yourself ThunderBolt level to %d!", amount)
		}else {
			zp_colored_print(id, "^x04[ZC]^x01 You've set to %s ThunderBolt level to %d!", g_playername[target], amount)
			zp_colored_print(target, "^x04[ZC]^x01 You've been set ThunderBolt level to %d!" , amount)
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public SetWallH(id, level, cid)
{	
	if (!cmd_access(id, level, cid, 2)){
		return PLUGIN_HANDLED;
	}	
	new arg1[32], arg2[10], amount
	read_argv(1, arg1, sizeof(arg1) - 1)
	read_argv(2, arg2, sizeof(arg2) - 1)	
	amount = str_to_num(arg2)
	if(amount <= 0) amount = 1
	new target = cmd_target(0, arg1, 2)
	if (target == 0)
	{
		zp_colored_print(id, "^x04[ZC]^x01 I can't find this player.")	
		return PLUGIN_HANDLED

	}else { 
		wallh_l[target] = amount
		if(id == target)
		{
			zp_colored_print(id, "^x04[ZC]^x01 You've set yourself Wall Hang level to %d!", amount)
		}else {
			zp_colored_print(id, "^x04[ZC]^x01 You've set to %s Wall Hang level to %d!", g_playername[target], amount)
			zp_colored_print(target, "^x04[ZC]^x01 You've been set Wall Hang level to %d!" , amount)
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED	
}

public get_user_power(id)
{
	return hp_l[id]+armor_l[id]+speed_l[id]+asp_l[id]+blink_l[id]+chain_l[id]+wallh_l[id]
}

stock fm_set_user_armor(index, armor) 
{
	set_pev(index, pev_armorvalue, float(armor));
}

stock fm_set_user_velocity(entity, const Float:vector[3]) {
	set_pev(entity, pev_velocity, vector);

	return 1;
}

/*================================================================================
 [Target info]
=================================================================================*/
public say_info(id)
{
	new text[70], arg1[32], target[32], count[32]
	read_args(text, sizeof(text)-1);
	remove_quotes(text);
	arg1[0] = '^0';
	target[0] = '^0';
	count[0] = '^0';
	parse(text, arg1, sizeof(arg1)-1, target, sizeof(target)-1, count, sizeof(count)-1);
	if (equali(arg1, "info", 4))
	{
		info_player(id, target);
	}
	if (equali(arg1, "/info", 4))
	{
		info_player(id, target);
	}
	return PLUGIN_CONTINUE;
}

public info_player(id, target[])
{
	new target_2;
	target_2 = find_player("bl", target)
	if(!target_2)
	{
		zp_colored_print(id, "^x04[ZC]^x01 This^x04 player^x01 doen't exist!")
		return PLUGIN_HANDLED
	}
	if(is_user_bot(target_2))
	{
		zp_colored_print(id, "^x04[ZC]^x01 This^x04 player^x01 is a^x04 bot!")
		return PLUGIN_HANDLED
	}
	static packs[15], pts[15], pxp[15], pnxp[15], pcoins[15]
	AddCommas(g_ammopacks[target_2], packs, charsmax(packs))
	AddCommas(g_points[target_2], pts, charsmax(pts))
	AddCommas(g_xp[target_2], pxp, charsmax(pxp))
	AddCommas(get_user_next(target_2), pnxp, charsmax(pnxp))
	AddCommas(g_coins[target_2], pcoins, charsmax(pcoins))
	zp_colored_print(id, "^x04===============================================")
	zp_colored_print(id, "^x01| Nick:^x04 %s^x01 | Packs:^x04 %s^x01 | Coins:^x04 %s^x01 |", g_playername[target_2], packs, pcoins)
	zp_colored_print(id, "^x01| Points:^x04 %s^x01 | XP:^x04 %s/%s^x01 | Level:^x04 %d/%d^x01 | Powers:^x04 %d%%^x01 |", pts, pxp, pnxp, g_level[target_2], zc_max_level, get_user_power(target_2))
	zp_colored_print(id, "^x04===============================================")
	return PLUGIN_HANDLED
}

/*================================================================================
 [CountDown System]
=================================================================================*/
public TASK_CountDown() 
{
	new Players[32]
	new PlayersNum
	get_players(Players, PlayersNum, "a")
	
	if(CountDownDelay > sizeof CountDownSounds) 
	{
		CountDownDelay--
		new Message[64]
		formatex(Message, sizeof(Message)-1, "The virus will escape in %d secon%s", CountDownDelay, CountDownDelay == 1 ? "d" : "ds")
		HudMessage(0, Message, 179, 0, 0, -1.0, 0.28, _, _, 1.0)
		set_task(1.0, "TASK_CountDown", TASKID_COUNTDOWN)
	}
	else if(CountDownDelay > 1) 
	{
		CountDownDelay--
		new Message[64]
		formatex(Message,sizeof(Message)-1, "The virus will escape in %d secon%s", CountDownDelay, CountDownDelay == 1 ? "d" : "ds")
		HudMessage(0, Message, 179, 0, 0, -1.0, 0.28, _, _, 1.0)
		emit_sound(0, CHAN_VOICE, CountDownSounds[CountDownDelay-1], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		set_task(1.0, "TASK_CountDown", TASKID_COUNTDOWN)
		for(new i = 0 ; i < PlayersNum ; i++) 
		{
			if(is_user_connected(Players[i])) 
			{
				new Clr[3]
				Clr[0] = 000; Clr[1] = 000; Clr[2] = 150
				UTIL_ScreenFade(Players[i], Clr, 0.5, 0.5, 125)
				new Shock[3]
				Shock[0] = 3; Shock[1] = 2; Shock[2] = 3
				message_begin(MSG_ONE, get_user_msgid("ScreenShake"), _, Players[i])
				write_short((1<<12)*Shock[0])
				write_short((1<<12)*Shock[1])
				write_short((1<<12)*Shock[2])
				message_end()
			}
		}	
	}
	else if(CountDownDelay <= 1) 
	{
		new Message[64];
		formatex(Message,sizeof(Message)-1, "The virus excaped! ^nBe attentive!")
		HudMessage(0, Message, 179, 0, 0, -1.0, 0.28, _, _, 1.0)
		emit_sound(0, CHAN_VOICE, CountDownFinalSounds[_random(sizeof CountDownFinalSounds)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		for(new i = 0 ; i < PlayersNum ; i++) 
		{
			if(is_user_connected(Players[i])) 
			{
				new Clr[3]
				Clr[0] = 000; Clr[1] = 000; Clr[2] = 150
				UTIL_ScreenFade(Players[i], Clr, 0.5, 0.5, 125)
				new Shock[3]
				Shock[0] = 3; Shock[1] = 2; Shock[2] = 3
				message_begin(MSG_ONE, get_user_msgid("ScreenShake"), _, Players[i])
				write_short((1<<12)*Shock[0])
				write_short((1<<12)*Shock[1])
				write_short((1<<12)*Shock[2])
				message_end()
			}
		}
		CountDownDelay = 0
	}
}

/*================================================================================
 [VIP]
=================================================================================*/
public menu_open(id) 
{
	if(g_user_privileges[id] & FLAG_E) {
		show_vip_menu_extras(id)
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 %L", id, "NOT_A_VIP")
	}
	return ZP_PLUGIN_HANDLED
}
	
public show_vip_menu_extras(id)
{
	static menuid, menu[128], item, team, buffer[32], rest_type, rest_limit
	
	// Title
	if (g_zombie[id])
	{
		if (g_nemesis[id])
			formatex(menu, 127, "%L [%L]\r", id, "MENU_VIP_EXTRA_TITLE", id, "CLASS_NEMESIS")
		if (g_assassin[id])
			formatex(menu, 127, "%L [%L]\r", id, "MENU_VIP_EXTRA_TITLE", id, "CLASS_ASSASSIN")
		if (g_oberon[id])
			formatex(menu, 127, "%L [%L]\r", id, "MENU_VIP_EXTRA_TITLE", id, "CLASS_OBERON")
		if (g_dragon[id])
			formatex(menu, 127, "%L [%L]\r", id, "MENU_VIP_EXTRA_TITLE", id, "CLASS_DRAGON")
		if (g_nighter[id])
			formatex(menu, 127, "%L [%L]\r", id, "MENU_VIP_EXTRA_TITLE", id, "CLASS_NIGHTER")
		if (g_nchild[id])
			formatex(menu, 127, "%L [%L]\r", id, "MENU_VIP_EXTRA_TITLE", id, "CLASS_NCHILD")
		if (g_evil[id])
			formatex(menu, 127, "%L [%L]\r", id, "MENU_VIP_EXTRA_TITLE", id, "CLASS_EVIL")
		if (g_genesys[id])
			formatex(menu, 127, "%L [%L]\r", id, "MENU_VIP_EXTRA_TITLE", id, "CLASS_GENESYS")
		if (!g_assassin[id] && !g_oberon[id] && !g_dragon[id] && !g_nighter[id] && !g_nchild[id] && !g_nemesis[id] && !g_genesys[id] && !g_evil[id])
			formatex(menu, 127, "%L [%L]\r", id, "MENU_VIP_EXTRA_TITLE", id, "CLASS_ZOMBIE")
	}
	else
	{
		if (g_survivor[id])
			formatex(menu, 127, "%L [%L]\r", id, "MENU_VIP_EXTRA_TITLE", id, "CLASS_SURVIVOR")
		if (g_sniper[id])
			formatex(menu, 127, "%L [%L]\r", id, "MENU_VIP_EXTRA_TITLE", id, "CLASS_SNIPER")
		if (g_flamer[id])
			formatex(menu, 127, "%L [%L]\r", id, "MENU_VIP_EXTRA_TITLE", id, "CLASS_FLAMER")
		if (g_zadoc[id])
			formatex(menu, 127, "%L [%L]\r", id, "MENU_VIP_EXTRA_TITLE", id, "CLASS_ZADOC")
		if (g_hero[id])
			formatex(menu, 127, "%L [%L]\r", id, "MENU_VIP_EXTRA_TITLE", id, "CLASS_HERO")
		if (!g_survivor[id] && !g_sniper[id] && !g_flamer[id] && !g_zadoc[id] && !g_hero[id])
			formatex(menu, 127, "%L [%L]\r", id, "MENU_VIP_EXTRA_TITLE", id, "CLASS_HUMAN")
	}
	menuid = menu_create(menu, "menu_vip_extras")
	
	// Item List
	for (item = 0; item < g_vipextraitem_i; item++)
	{
		// Retrieve item's team
		team = ArrayGetCell(g_vipextraitem_team, item)
		rest_type = ArrayGetCell(g_vipextraitem_resttype, item)
		rest_limit = ArrayGetCell(g_vipextraitem_restlimit, item)
		
		// Item not available to player's team/class
		if ((g_zombie[id] && !native_get_zombie_hero(id) && (team != ZP_TEAM_ZOMBIE && team != ZP_TEAM_ANY)) || (!g_zombie[id] && !native_get_human_hero(id) && (team != ZP_TEAM_HUMAN && team != ZP_TEAM_ANY))
		|| (g_nemesis[id] && team != ZP_TEAM_NEMESIS) || (g_survivor[id] && team != ZP_TEAM_SURVIVOR) || (g_sniper[id] && team != ZP_TEAM_SNIPER) || (g_assassin[id] && team != ZP_TEAM_ASSASSIN) || (g_oberon[id] && team != ZP_TEAM_OBERON) || (g_dragon[id] && team != ZP_TEAM_DRAGON) 
		|| (g_nighter[id] && team != ZP_TEAM_NIGHTER) || (g_nchild[id] && team != ZP_TEAM_NCHILD) || (g_hero[id] && team != ZP_TEAM_HERO) || (g_evil[id] && team != ZP_TEAM_EVIL) || (g_flamer[id] && team != ZP_TEAM_FLAMER) || (g_zadoc[id] && team != ZP_TEAM_ZADOC) || (g_genesys[id] && team != ZP_TEAM_GENESYS))
			continue;

		switch(rest_type)
		{
			case REST_NONE:
			{
				new itemname[32]
				ArrayGetString(g_vipextraitem_name, item, itemname, charsmax(itemname))

				// Add Item Name and Cost
				formatex(menu, 127, "\w%s \r| \y%d \rpacks | \wNo limit", itemname, ArrayGetCell(g_vipextraitem_cost, item))
			}
			case REST_ROUND:
			{
				// Check limit
				new limit, data[32], itemname[32]
				ArrayGetString(g_vipextraitem_name, item, itemname, charsmax(itemname))
				if(limiter_get_data(g_limiter_round, itemname, g_playername[id], data, 15))
				{
					limit = str_to_num(data)
				}

				// Add Item Name, Cost and Restriction
				if (limit < rest_limit)
					formatex(menu, 127, "\w%s \r| \y%d \rpacks | \y%d\r/\y%d \wper round", itemname, ArrayGetCell(g_vipextraitem_cost, item), limit, rest_limit)
				else
					formatex(menu, 127, "\d%s | P: %d packs | Limit reached", itemname, ArrayGetCell(g_vipextraitem_cost, item))
			}
			case REST_MAP:
			{
				// Check limit
				new limit, data[32], itemname[32]
				ArrayGetString(g_vipextraitem_name, item, itemname, charsmax(itemname))
				if(limiter_get_data(g_limiter_map, itemname, g_playername[id], data, 15))
				{
					limit = str_to_num(data)
				}

				// Add Item Name, Cost and Restriction
				if (limit < rest_limit)
					formatex(menu, 127, "\w%s \r| \y%d \rpacks | \y%d\r/\y%d \wper map", itemname, ArrayGetCell(g_vipextraitem_cost, item), limit, rest_limit)
				else
					formatex(menu, 127, "\d%s | P: %d packs | Limit reached", itemname, ArrayGetCell(g_vipextraitem_cost, item))
			}
		}
		buffer[0] = item
		buffer[1] = 0
		menu_additem(menuid, menu, buffer)
	}
	
	// No items to display?
	if (menu_items(menuid) <= 0)
	{
		zp_colored_print(id, "^x04[ZC]^x01 %L", id ,"CMD_NOT_EXTRAS")
		menu_destroy(menuid)
		return;
	}
	
	// Back - Next - Exit
	menu_setprop(menuid, MPROP_BACKNAME, "Back")
	menu_setprop(menuid, MPROP_NEXTNAME, "Next")
	menu_setprop(menuid, MPROP_EXITNAME, "Exit")	
	menu_display(id, menuid)
}

// Extra Items Menu
public menu_vip_extras(id, menuid, item)
{
	// Menu was closed
	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Dead players are not allowed to buy items
	if (!g_isalive[id])
	{
		zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Retrieve extra item id
	static buffer[2], dummy, itemid
	menu_item_getinfo(menuid, item, dummy, buffer, charsmax(buffer), _, _, dummy)
	itemid = buffer[0]
	
	// Attempt to buy the item
	buy_vip_extra_item(id, itemid)
	menu_destroy(menuid)
	return PLUGIN_HANDLED;
}

// Buy VIP Extra Item
buy_vip_extra_item(id, itemid)
{
	// Retrieve item's team
	static team
	team = ArrayGetCell(g_vipextraitem_team, itemid)
	
	// Check for team/class specific items
	if ((g_zombie[id] && !native_get_zombie_hero(id) && (team != ZP_TEAM_ZOMBIE && team != ZP_TEAM_ANY)) || (!g_zombie[id] && !native_get_human_hero(id) && (team != ZP_TEAM_HUMAN && team != ZP_TEAM_ANY)) || (g_nemesis[id] && team != ZP_TEAM_NEMESIS)
	|| (g_survivor[id] && team != ZP_TEAM_SURVIVOR) || (g_sniper[id] && team != ZP_TEAM_SNIPER) || (g_assassin[id] && team != ZP_TEAM_ASSASSIN) || (g_oberon[id] && team != ZP_TEAM_OBERON) || (g_dragon[id] && team != ZP_TEAM_DRAGON) || (g_nighter[id] && team != ZP_TEAM_NIGHTER) || (g_flamer[id] && team != ZP_TEAM_FLAMER) || (g_zadoc[id] && team != ZP_TEAM_ZADOC) || (g_genesys[id] && team != ZP_TEAM_GENESYS))
	{
		zp_colored_print(id, "^x04[ZC]^x01 %L", id, "CMD_NOT")
		return;
	}
	
	// Check that we have enough ammo packs
	if (g_ammopacks[id] < ArrayGetCell(g_vipextraitem_cost, itemid))
	{
		zp_colored_print(id, "^x04[ZC]^x01 %L", id, "NOT_ENOUGH_AMMO")
		return;	
	}

	// Deduce item cost
	g_ammopacks[id] -= ArrayGetCell(g_vipextraitem_cost, itemid)
	
	// Check which kind of item we're buying
	switch(ArrayGetCell(g_vipextraitem_resttype, itemid))
	{
		case REST_NONE:
		{
			// Item selected forward
			ExecuteForward(g_extra_item_selected, g_fwDummyResult, id, itemid);
				
			// Item purchase blocked, restore buyer's ammo packs
			if (g_fwDummyResult >= ZP_PLUGIN_HANDLED)
			{
					g_ammopacks[id] += ArrayGetCell(g_vipextraitem_cost, itemid)
			}
		}
		case REST_ROUND:
		{
			// Check limit
			new limit, data[32], itemname[32], rest_limit
			rest_limit = ArrayGetCell(g_vipextraitem_restlimit, itemid)
			ArrayGetString(g_vipextraitem_name, itemid, itemname, charsmax(itemname))
			if(limiter_get_data(g_limiter_round, itemname, g_playername[id], data, 15))
			{
				limit = str_to_num(data)
			}
			if (limit < rest_limit)
			{
				// Item selected forward
				ExecuteForward(g_extra_item_selected, g_fwDummyResult, id, itemid);
				
				// Item purchase blocked, restore buyer's ammo packs
				if (g_fwDummyResult >= ZP_PLUGIN_HANDLED)
				{
					g_ammopacks[id] += ArrayGetCell(g_vipextraitem_cost, itemid)
				}
				else 
				{
					ArraySetCell(g_vipextraitem_limit, itemid, (limit+1))
					new save[16]
					num_to_str(ArrayGetCell(g_vipextraitem_limit, itemid), save, sizeof(save) - 1)
    					limiter_set_data(g_limiter_round, itemname, g_playername[id], save)
				}		
			}
			else
			{
				g_ammopacks[id] += ArrayGetCell(g_vipextraitem_cost, itemid)
				zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this round!")
				return;
			}
		}
		case REST_MAP:
		{
			// Check limit
			new limit, data[32], itemname[32], rest_limit
			rest_limit = ArrayGetCell(g_vipextraitem_restlimit, itemid)
			ArrayGetString(g_vipextraitem_name, itemid, itemname, charsmax(itemname))
			if(limiter_get_data(g_limiter_map, itemname, g_playername[id], data, 15))
			{
				limit = str_to_num(data)
			}
			if (limit < rest_limit)
			{
				// Item selected forward
				ExecuteForward(g_extra_item_selected, g_fwDummyResult, id, itemid);
				
				// Item purchase blocked, restore buyer's ammo packs
				if (g_fwDummyResult >= ZP_PLUGIN_HANDLED)
				{
					g_ammopacks[id] += ArrayGetCell(g_vipextraitem_cost, itemid)
				}
				else 
				{
					ArraySetCell(g_vipextraitem_limit, itemid, (limit+1))
					new save[16]
					num_to_str(ArrayGetCell(g_vipextraitem_limit, itemid), save, sizeof(save) - 1)
    					limiter_set_data(g_limiter_map, itemname, g_playername[id], save)
				}		
			}
			else
			{
				g_ammopacks[id] += ArrayGetCell(g_vipextraitem_cost, itemid)
				zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
				return;
			}
		}
	}
	client_cmd(id, "spk %s", BGH_S)
	
}

// UnlimitedClip VIP
public message_cur_weapon_vip(msg_id, msg_dest, msg_entity)
{
	if (!zc_vip_unlimited_clip) return
	if (!(g_user_privileges[msg_entity] & FLAG_C)) return
	if (!is_user_alive(msg_entity) || get_msg_arg_int(1) != 1) return
	
	static weapon, clip
	weapon = get_msg_arg_int(2)
	clip = get_msg_arg_int(3)
	
	if (MAXCLIP[weapon] > 2)
	{
		set_msg_arg_int(3, get_msg_argtype(3), MAXCLIP[weapon])
		
		if (clip < 2)
		{
			static wname[32], weapon_ent
			get_weaponname(weapon, wname, sizeof wname - 1)
			weapon_ent = find_ent_by_owner(-1, wname, msg_entity)
			fm_set_weapon_ammo(weapon_ent, MAXCLIP[weapon])
		}
	}
}

// No-Recoil VIP
public fw_Weapon_PrimaryAttack_Pre(entity)
{
	// Define owner
	new id = pev(entity, pev_owner)

	// Some 'questions'
	if (!zc_vip_no_recoil) return HAM_IGNORED;
	if (g_zombie[id]) return HAM_IGNORED;

	// Set No-Recoil
	if (g_user_privileges[id] & FLAG_C)
	{
		pev(id, pev_punchangle, cl_pushangle[id])
		return HAM_IGNORED;
	}
	return HAM_IGNORED;
}

public fw_Weapon_PrimaryAttack_Post(entity)
{
	// Define owner
	new id = pev(entity, pev_owner)

	// Some 'questions'
	if (!zc_vip_no_recoil) return HAM_IGNORED;
	if (g_zombie[id]) return HAM_IGNORED;

	// Set No-Recoil
	if (g_user_privileges[id] & FLAG_C)
	{
		new Float: push[3]
		pev(id, pev_punchangle, push)
		xs_vec_sub(push, cl_pushangle[id], push)
		xs_vec_mul_scalar(push, 0.0, push)
		xs_vec_add(push, cl_pushangle[id], push)
		set_pev(id, pev_punchangle, push)
		return HAM_IGNORED;
	}
	return HAM_IGNORED;
}

public HUDReset()
{
	setVip()
}
	
public setVip()
{
	new players[32], pNum
	get_players(players, pNum, "a")

	for (new i = 0; i < pNum; i++)
	{
		new id = players[i]	
		if (g_user_privileges[id] & FLAG_A)
		{
			message_begin(MSG_ALL, get_user_msgid("ScoreAttrib"))
			write_byte(id)
			write_byte(4)
			message_end()
		}
	}
	return PLUGIN_HANDLED
}

ShowMainMenu(id)
{
    	new menu = menu_create("\yZombie Crown XP Mode - \rVIPs\w:", "MenuSelect");
    	new bool:vips_in_server = false;
    	for(new i = 1; i <= g_maxplayers; i++)
    	{	
        	if(!is_user_connected(i)) continue
        	if(!(g_user_privileges[i] & FLAG_A)) continue
        	menu_additem(menu, g_playername[i], "")
        	vips_in_server = true
    	}
    
    	if(vips_in_server)
    	{
        	menu_display(id, menu);
    	}else {
        	zp_colored_print(id, "^x04[ZC]^x01 There are no^x03 VIP^x04 online^x01 at this time.");
        	menu_destroy(menu);
    	}
}

public MenuSelect(id, menu, item)
{
	show_motd(id, "go.html")
}  

public print_viplist(id)
{
	ShowMainMenu(id)
}

public fw_PrethinkVip(id)
{
	if(!is_user_valid_connected(id) || !is_user_alive(id) || !zc_vip_jumps) return PLUGIN_CONTINUE
	static nbut, obut, fflags
	nbut = pev(id, pev_button)
	obut = pev(id, pev_oldbuttons) 
	fflags = pev(id, pev_flags)
	if((nbut & IN_JUMP) && !(fflags & FL_ONGROUND) && !(obut & IN_JUMP) && (g_user_privileges[id] & FLAG_B))
	{
		if(jumpnum[id] < chache_g_jumps && ((g_bit & FLAG_D && native_get_zombie_hero(id)) || (g_bit & FLAG_C && native_get_human_hero(id)) || (g_bit & FLAG_A && !g_zombie[id]) ||(g_bit & FLAG_B && g_zombie[id] && !native_get_zombie_hero(id))))
		{
			dojump[id] = true
			jumpnum[id]++
			return PLUGIN_CONTINUE
		}
	}
	else if((nbut & IN_JUMP) && !(fflags & FL_ONGROUND) && !(obut & IN_JUMP) && !(g_user_privileges[id] & FLAG_B))
	{
		if(jumpnum[id] < chache_gp_jumps && ((g_bit & FLAG_D && native_get_zombie_hero(id)) || (g_bit & FLAG_C && native_get_human_hero(id)) || (g_bit & FLAG_A && !g_zombie[id]) ||(g_bit & FLAG_B && g_zombie[id] && !native_get_zombie_hero(id))))
		{
			dojump[id] = true
			jumpnum[id]++
			return PLUGIN_CONTINUE
		}
	}
	if((nbut & IN_JUMP) && (fflags & FL_ONGROUND))
	{
		jumpnum[id] = 0
		return PLUGIN_CONTINUE
	}
	
	return PLUGIN_CONTINUE
}

public fw_PostthinkVip(id)
{
	if(!is_user_valid_connected(id) || !is_user_alive(id) || !zc_vip_jumps) return PLUGIN_CONTINUE
	if(dojump[id] == true)
	{
		static Float:velocity[3]	
		entity_get_vector(id,EV_VEC_velocity,velocity)
		velocity[2] = random_float(265.0,285.0)
		entity_set_vector(id,EV_VEC_velocity,velocity)
		dojump[id] = false
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}	

public ShowMotd(id)
{
	show_motd(id, "go.html")
}

public reload_vips_cmd(id, level, cid)
{
    	if(!cmd_access(id , level , cid, 1)) 
		return PLUGIN_HANDLED

	reload_vips()
	server_print("[ZC] The VIP file was reloaded.")
 	client_print(id, print_console, "[ZC] The VIP file was reloaded.")
	for(new i = 1; i <= g_maxplayers; i++) 
	{
		if(is_user_valid_connected(i)) {
			set_task(2.0, "set_flags", i)
		}
	}
	return PLUGIN_HANDLED
}

public reload_vips() 
{
	if(database_holder) ArrayDestroy(database_holder)
	database_holder = ArrayCreate(database_items)
	new configsDir[64]
	get_configsdir(configsDir, 63)
	format(configsDir, 63, "%s/zombie_crown/zc_vip.ini", configsDir)
	new File=fopen(configsDir,"r");
	
	if (File)
	{
		static Text[512], Flags[32], AuthData[50], Privileges_Flags[32], vpPassword[50]
		while (!feof(File))
		{
			fgets(File,Text,sizeof(Text)-1);
			
			trim(Text);
			
			// comment
			if (Text[0]==';') 
			{
				continue;
			}
			
			Flags[0]=0;
			AuthData[0]=0;
			Privileges_Flags[0]=0;
			vpPassword[0]=0;
			
			// not enough parameters
			if (parse(Text,AuthData,sizeof(AuthData)-1,vpPassword,sizeof(vpPassword)-1,Privileges_Flags,sizeof(Privileges_Flags)-1,Flags,sizeof(Flags)-1) < 2)
			{
				continue;
			}

			vips_database[auth] = AuthData
			vips_database[zvpassword] = vpPassword
			vips_database[accessflags] = read_flags(Privileges_Flags)
			vips_database[zvflags] = read_flags(Flags)
			ArrayPushArray(database_holder, vips_database)
		}
		
		fclose(File);
	}
	else log_amx("Error: zc_vip.ini file doesn't exist")
}

public check_date()
{
	new holder[20]
	new y, m ,d
	date(y, m, d)
	format(holder, charsmax(holder), "m%dd%dy%d", m, d, y)
	new configdir[200]
	get_configsdir(configdir,199)
	new configfile1[200]
	format(configfile1,199,"%s/zombie_crown/zc_vip.ini",configdir)
	new text[512], len
	new pnum = file_size(configfile1,1)
	for(new i = 1; i < pnum; i++)
	{
		read_file(configfile1, i, text, 511, len)
		if ( contain(text, holder) != -1 ) 
		{
			DeleteLine(configfile1, i)
		}
	}
	return PLUGIN_HANDLED
}

DeleteLine( const szFilename[ ], const iLine )
{
	new iFile = fopen( szFilename, "rt" );
	if( !iFile )
	{
		return;
	}
	static const szTempFilename[ ] = "delete_line.txt";
	new iTempFile = fopen( szTempFilename, "wt" );
    
	new szData[ 256 ], iLineCount, bool:bReplaced = false;
	while( !feof( iFile ) )
	{
		fgets( iFile, szData, 255 );
        
		if( iLineCount++ == iLine )
		{
			bReplaced = true;
		}
		else
		{
			fputs( iTempFile, szData );
		}
	}
    
	fclose( iFile );
	fclose( iTempFile );
    
	if( bReplaced )
	{
		delete_file( szFilename );
        
		while( !rename_file( szTempFilename, szFilename, 1 ) ) { }
	}else {
		delete_file( szTempFilename );
	}
}

stock get_date(days, string[], chars) {
	
	new y, m, d
	date(y, m ,d)
	
	d+=days
	
	new go = true
	while(go) {
		switch(m) {
			case 1,3, 5, 7, 8, 10: {
				if(d>31) { d=d-31; m++; }
				else go = false
			}
			case 2: {
				if(d>28) { d=d-28; m++; }
				else go = false
			}
			case 4, 6, 9, 11: {
				if(d>30) { d=d-30; m++; }
				else go = false
			}
			case 12: {
				if(d>31) { d=d-31; y++; m=1; }
				else go = false
			}
		}
	}
	formatex(string, chars, "m%dd%dy%d", m, d ,y)
}

stock fm_set_weapon_ammo(entity, amount)
{
	set_pdata_int(entity, OFFSET_CLIPAMMO, amount, OFFSET_LINUX_WEAPONS);
}

public set_flags(id) 
{
	static authid[31], ip[31], name[51], index, client_password[30], size, log_flags[11]
	get_user_authid(id, authid, 30)
	get_user_ip(id, ip, 30, 1)
	get_user_name(id, name, 50)
	get_user_info(id, amx_password_field_string, client_password, charsmax(client_password))
	
	g_user_privileges[id] = 0
	size = ArraySize(database_holder)
	for(index=0; index < size ; index++) 
	{
		ArrayGetArray(database_holder, index, vips_database)
		if(equali(name, vips_database[auth])) 
		{
			if(!(vips_database[zvflags] & FLAG_E)) 
			{
				if(equal(client_password, vips_database[zvpassword]))
				{
					g_user_privileges[id] = vips_database[accessflags]
				}else if(!equal(client_password, vips_database[zvpassword]) && (vips_database[zvflags] & FLAG_A)) {
					server_cmd("kick #%d ^"%L^"", get_user_userid(id), id, "INV_PAS")
					break
				}
			}else { 
				g_user_privileges[id] = vips_database[accessflags]
			}
			get_flags(vips_database[accessflags], log_flags, 10)
			log_amx("%s become VIP. (SteamID: ^"%s^") (IP: ^"%s^") (Flags: ^"%s^")", name, authid, ip, log_flags)
			break
		}
	}

        if (event_start == 1) vipBugFix()
}

stock generate_password(id) 
{	
	new password_holder[30]
	formatex(password_holder, charsmax(password_holder), "%d%d%d%d%d", random(10), random(10), random(10), random(10), random(10))
	client_cmd(id, "setinfo %s %s", amx_password_field_string, password_holder)
}

public vipBugFix()
{
        if (event_start == 1)
        {
        for (new id = 1; id <= 33; id++)
        {
                if (!is_user_connected(id)) continue;

		if(!(g_user_privileges[id] & FLAG_D))
		{
			new fflags[10]
			get_pcvar_string(g_hour_flags, fflags, charsmax(fflags))
			g_user_privileges[id] = read_flags(fflags)
		}
   	}}
}

/*================================================================================
 [Donate System]
=================================================================================*/
public donatemenu(id)
{
	show_menu(id, 0, "\n", 1)
	new menu = menu_create("\rDonate Menu:", "menu_donate");
	menu_additem(menu, "\wDonate Packs", "", 0);
	menu_additem(menu, "\wDonate XP", "", 0);
	menu_additem(menu, "\wDonate Points", "", 0);
	menu_additem(menu, "\wDonate Coins", "", 0);
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
}

public menu_donate(id, menu, item)
{
	switch(item)	
	{
		case 0: client_cmd(id, "donatepacks")
		case 1: client_cmd(id, "donatexp")
		case 2: client_cmd(id, "donatepoints")
		case 3: client_cmd(id, "donatecoins")
	}
	menu_destroy(menu);
}

public DonatePacks(id)
{
    	new menu = menu_create("\wDonate \rPacks System ^n\wChose \ythe player \wbelow:", "amenu_handler");
    	new players[32], pnum, tempid;
    	new szUserId[32];
    	get_players(players, pnum, "c")
    	for (new i; i<pnum; i++) {
        	tempid = players[i];
        	formatex(szUserId, charsmax(szUserId), "%d", get_user_userid(tempid));
        	menu_additem (menu, g_playername[tempid], szUserId, 0);
    	}
    	menu_display(id, menu, 0);
}

public amenu_handler(id, menu, item)
{
    	if (item == MENU_EXIT) {
        	menu_destroy(menu);
        	return;
    	}
    	new szData[6], szName[64];
    	new item_access, item_callback;
    	menu_item_getinfo(menu, item, item_access, szData, charsmax(szData), szName, charsmax(szName), item_callback);
    	new userid = str_to_num(szData);
    	new player = find_player("k", userid);
	if(id == player){
		zp_colored_print(id, "^x04[ZC]^x01 You can't^x04 donate^x01 yourself.")  
		return;
	}else {
		client_cmd(id, "messagemode ^"Packs_amount %i^"", player)
	}
    	menu_destroy(menu);
}

public dPacks(id)
{    
	if(!is_user_connected(id)) 
		return PLUGIN_HANDLED
	
	static g_param[6], g_Amount, g_Player, ip[16], ipr[16]
	read_argv(2, g_param, charsmax(g_param))
	g_Amount = str_to_num(g_param)  

	for (new p; p < strlen(g_param); p++) {       
		if(!isdigit(g_param[p])) {                    
			zp_colored_print(id, "^x04[ZC]^x01 You must write a^x04 number^x01.") 
			return PLUGIN_HANDLED  
		}    
	}    

	if(g_ammopacks[id] < g_Amount) {                  
		zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 packs^x01 .") 
		return PLUGIN_HANDLED  
	} 
 
	read_argv(1, g_param, charsmax(g_param))
	g_Player = str_to_num(g_param)  
	if(id == g_Player) {                  
		zp_colored_print(id, "^x04[ZC]^x01 You can't^x04 donate^x01 yourself.") 
		return PLUGIN_HANDLED   
	}

	if (get_user_flags(id) & ADMIN_LEVEL_H) {
		zp_colored_print(id, "^x04[ZC]^x01 Because you have^x04 'infinite packs command'^x01, you can't donate^x04 any pack^x01 !!!")
		return PLUGIN_HANDLED
	}

	get_user_ip(id, ip, charsmax(ip), 1);
	get_user_ip(g_Player, ipr, charsmax(ipr), 1);   
	if (equal(ip, ipr)) {
		zp_colored_print(id, "^x04[ZC]^x01 Invalid^x04 command^x01.")
		return PLUGIN_HANDLED
	}

	if (g_Amount <= 0) {
		zp_colored_print(id, "^x04[ZC]^x01 Wrong packs quantity. !")
		return PLUGIN_HANDLED
	}
 
	if(UserIsRegistered(g_playername[id]) && UserIsRegistered(g_playername[g_Player])) {
		zp_colored_print(0, "^x04[ZC]^x01 Player^x04 %s^x01 donated^x04 %d^x01 packs to^x04 %s", g_playername[id], g_Amount, g_playername[g_Player])   
		g_ammopacks[id] -= g_Amount 
		    
		g_ammopacks[g_Player] += g_Amount
		log_to_file("zc_donate.log", "[AMMO] [%s - %s] [%d] [%s - %s]", g_playername[id], ip, g_Amount, g_playername[g_Player], ipr)
	}else {
		zp_colored_print(g_Player, "^x04[ZC]^x01 You can't^x04 donate/receive^x01 packs, until you will^x04 register^x01 ! Press^x04 m5")
		zp_colored_print(id, "^x04[ZC]^x01 You can't^x04 donate/receive^x01 packs, until you will^x04 register^x01 ! Press^x04 m5")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public DonateXP(id)
{
    	new menu = menu_create("\wDonate \rXP System ^n\wChose \ythe player \wbelow:", "bmenu_handler");
    	new players[32], pnum, tempid;
    	new szUserId[32];
    	get_players(players, pnum, "c")
    	for (new i; i<pnum; i++) {
        	tempid = players[i];
        	formatex(szUserId, charsmax(szUserId), "%d", get_user_userid(tempid));
        	menu_additem (menu, g_playername[tempid], szUserId, 0);
    	}
    	menu_display(id, menu, 0);
}

public bmenu_handler(id, menu, item)
{
    	if (item == MENU_EXIT) {
        	menu_destroy(menu);
        	return;
    	}
    	new szData[6], szName[64];
    	new item_access, item_callback;
    	menu_item_getinfo(menu, item, item_access, szData, charsmax(szData), szName, charsmax(szName), item_callback);
    	new userid = str_to_num(szData);
    	new player = find_player("k", userid);
	if(id == player){
		zp_colored_print(id, "^x04[ZC]^x01 You can't^x04 donate^x01 yourself.")  
		return;
	}else {
		client_cmd(id, "messagemode ^"XP_amount %i^"", player)
	}
    	menu_destroy(menu);
}

public dXP(id)
{    
	if(!is_user_connected(id)) 
		return PLUGIN_HANDLED
	
	static g_param[6], ip[16], ipr[16], g_Amount, g_Player
	read_argv(2, g_param, charsmax(g_param))
	g_Amount = str_to_num(g_param) 

	for (new p; p < strlen(g_param); p++) {       
		if(!isdigit(g_param[p])) {                    
			zp_colored_print(id, "^x04[ZC]^x01 You must write a^x04 number^x01.") 
			return PLUGIN_HANDLED     
		}    
	}    

	if(g_xp[id] < g_Amount) {                  
		zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 XP^x01 .") 
		return PLUGIN_HANDLED 
	} 

	read_argv(1, g_param, charsmax(g_param))
	g_Player = str_to_num(g_param)   
	if(id == g_Player) {                  
		zp_colored_print(id, "^x04[ZC]^x01 You can't^x04 donate^x01 yourself.") 
		return PLUGIN_HANDLED 
	}

	get_user_ip(id, ip, charsmax(ip), 1);
	get_user_ip(g_Player, ipr, charsmax(ipr), 1);
	if (equal(ip, ipr)) {
		zp_colored_print(id, "^x04[ZC]^x01 Invalid^x04 command^x01.")
		return PLUGIN_HANDLED
	}

	if (g_Amount <= 0) {
		zp_colored_print(id, "^x04[ZC]^x01 Wrong XP quantity !")
		return PLUGIN_HANDLED
	}

	if(UserIsRegistered(g_playername[id]) && UserIsRegistered(g_playername[g_Player])) {
		zp_colored_print(0, "^x04[ZC]^x01 Player^x04 %s^x01 donated^x04 %d^x01 XP to^x04 %s", g_playername[id], g_Amount, g_playername[g_Player]) 
		g_xp[id] -= g_Amount
		    
		g_xp[g_Player] += g_Amount
		log_to_file("zc_donate.log", "[XP] [%s - %s] [%d] [%s - %s]", g_playername[id], ip, g_Amount, g_playername[g_Player], ipr)

		// Level check
		if(g_level[g_Player] < zc_max_level) {
			levelup(g_Player)
		}
	}else{
		zp_colored_print(g_Player, "^x04[ZC]^x01 You can't^x04 donate/receive^x01 XP, until you will^x04 register^x01 ! Press^x04 m5")
		zp_colored_print(id, "^x04[ZC]^x01 You can't^x04 donate/receive^x01 XP, until you will^x04 register^x01 ! Press^x04 m5")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public DonatePoints(id)
{
    	new menu = menu_create("\wDonate \rPoints System ^n\wChose \ythe player \wbelow:", "cmenu_handler");
    	new players[32], pnum, tempid;
    	new szUserId[32];
    	get_players(players, pnum, "c")
    	for (new i; i<pnum; i++) {
        	tempid = players[i];
        	formatex(szUserId, charsmax(szUserId), "%d", get_user_userid(tempid));
        	menu_additem (menu, g_playername[tempid], szUserId, 0);
    	}
    	menu_display(id, menu, 0);
}

public cmenu_handler(id, menu, item)
{
    	if (item == MENU_EXIT) {
        	menu_destroy(menu);
        	return;
    	}
    	new szData[6], szName[64];
    	new item_access, item_callback;
    	menu_item_getinfo(menu, item, item_access, szData, charsmax(szData), szName, charsmax(szName), item_callback);
    	new userid = str_to_num(szData);
    	new player = find_player("k", userid);
	if(id == player) {
		zp_colored_print(id, "^x04[ZC]^x01 You can't^x04 donate^x01 yourself.")  
		return;
	}else {
		client_cmd(id, "messagemode ^"Points_amount %i^"", player)
	}
    	menu_destroy(menu);
}

public dPoints(id)
{    
	if(!is_user_connected(id))
		return PLUGIN_HANDLED
	
	static g_param[6], ip[16], ipr[16], g_Amount, g_Player
	read_argv(2, g_param, charsmax(g_param))
	g_Amount = str_to_num(g_param) 
	for (new p; p < strlen(g_param); p++) {       
		if(!isdigit(g_param[p])) {                    
			zp_colored_print(id, "^x04[ZC]^x01 You must write a^x04 number^x01.") 
			return PLUGIN_HANDLED     
		}    
	}    

	if(g_points[id] < g_Amount) {                  
		zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 points^x01 .") 
		return PLUGIN_HANDLED  
	} 

	read_argv(1, g_param, charsmax(g_param))
	g_Player = str_to_num(g_param)   
	if(id == g_Player) {                  
		zp_colored_print(id, "^x04[ZC]^x01 You can't^x04 donate^x01 yourself.") 
		return PLUGIN_HANDLED  
	}

	if (get_user_flags(id) & ADMIN_LEVEL_A) {
		zp_colored_print(id, "^x04[ZC]^x01 Because you have^x04 'infinite points command'^x01, you can't donate^x04 any point^x01 !!!")
		return PLUGIN_HANDLED
	}

	get_user_ip(id, ip, charsmax(ip), 1);
	get_user_ip(g_Player, ipr, charsmax(ipr), 1);
	if (equal(ip, ipr)) {
		zp_colored_print(id, "^x04[ZC]^x01 Invalid^x04 command^x01.")
		return PLUGIN_HANDLED
	}

	if (g_Amount <= 0) {
		zp_colored_print(id, "^x04[ZC]^x01 Wrong points quantity !")
		return PLUGIN_HANDLED
	} 

	if(UserIsRegistered(g_playername[id]) && UserIsRegistered(g_playername[g_Player])) {
		zp_colored_print(0, "^x04[ZC]^x01 Player^x04 %s^x01 donated^x04 %d^x01 points to^x04 %s", g_playername[id], g_Amount, g_playername[g_Player])
		g_points[id] -= g_Amount
		    
		g_points[g_Player] += g_Amount
		log_to_file("zc_donate.log", "[POINTS] [%s - %s] [%d] [%s - %s]", g_playername[id], ip, g_Amount, g_playername[g_Player], ipr)
	}else {
		zp_colored_print(g_Player, "^x04[ZC]^x01 You can't^x04 donate/receive^x01 points, until you will^x04 register^x01 ! Press^x04 m5")
		zp_colored_print(id, "^x04[ZC]^x01 You can't^x04 donate/receive^x01 points, until you will^x04 register^x01 ! Press^x04 m5")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public DonateCoins(id)
{
    	new menu = menu_create("\wDonate \rCoins System ^n\wChose \ythe player \wbelow:", "dmenu_handler");
    	new players[32], pnum, tempid;
    	new szUserId[32];
    	get_players(players, pnum, "c")
    	for (new i; i<pnum; i++) {
        	tempid = players[i];
        	formatex(szUserId, charsmax(szUserId), "%d", get_user_userid(tempid));
        	menu_additem (menu, g_playername[tempid], szUserId, 0);
    	}
    	menu_display(id, menu, 0);
}

public dmenu_handler(id, menu, item)
{
    	if (item == MENU_EXIT) {
        	menu_destroy(menu);
        	return;
    	}
    	new szData[6], szName[64];
    	new item_access, item_callback;
    	menu_item_getinfo(menu, item, item_access, szData, charsmax(szData), szName, charsmax(szName), item_callback);
    	new userid = str_to_num(szData);
    	new player = find_player("k", userid);
	if(id == player) {
		zp_colored_print(id, "^x04[ZC]^x01 You can't^x04 donate^x01 yourself.")  
		return;
	}else {
		client_cmd(id, "messagemode ^"Coins_amount %i^"", player)
	}
    	menu_destroy(menu);
}

public dCoins(id)
{    
	if(!is_user_connected(id))
		return PLUGIN_HANDLED
	
	static g_param[6], ip[16], ipr[16], g_Amount, g_Player 
	read_argv(2, g_param, charsmax(g_param))
	g_Amount = str_to_num(g_param) 
	for (new p; p < strlen(g_param); p++) {       
		if(!isdigit(g_param[p])) {                    
			zp_colored_print(id, "^x04[ZC]^x01 You must write a^x04 number^x01.") 
			return PLUGIN_HANDLED    
		}    
	}    

	if(g_coins[id] < g_Amount) {                  
		zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins^x01 .") 
		return PLUGIN_HANDLED
	} 

	read_argv(1, g_param, charsmax(g_param))
	g_Player = str_to_num(g_param)   
	if(id == g_Player) {                  
		zp_colored_print(id, "^x04[ZC]^x01 You can't^x04 donate^x01 yourself.") 
		return PLUGIN_HANDLED  
	}

	if (get_user_flags(id) & ADMIN_LEVEL_A) {
		zp_colored_print(id, "^x04[ZC]^x01 Because you have^x04 'infinite coins command'^x01, you can't donate^x04 any coin^x01 !!!")
		return PLUGIN_HANDLED
	}

	get_user_ip(id, ip, charsmax(ip), 1);
	get_user_ip(g_Player, ipr, charsmax(ipr), 1);
	if (equal(ip, ipr)) {
		zp_colored_print(id, "^x04[ZC]^x01 Invalid^x04 command^x01.")
		return PLUGIN_HANDLED
	}

	if (g_Amount <= 0) {
		zp_colored_print(id, "^x04[ZC]^x01 Wrong coins quantity !")
		return PLUGIN_HANDLED
	} 

	if(UserIsRegistered(g_playername[id]) && UserIsRegistered(g_playername[g_Player])) {
		zp_colored_print(0, "^x04[ZC]^x01 Player^x04 %s^x01 donated^x04 %d^x01 coins to^x04 %s", g_playername[id], g_Amount, g_playername[g_Player]) 
		g_coins[id] -= g_Amount
		    
		g_coins[g_Player] += g_Amount
		log_to_file("zc_donate.log", "[COINS] [%s - %s] [%d] [%s - %s]", g_playername[id], ip, g_Amount, g_playername[g_Player], ipr)
	}else {
		zp_colored_print(g_Player, "^x04[ZC]^x01 You can't^x04 donate/receive^x01 coins, until you will^x04 register^x01 ! Press^x04 m5")
		zp_colored_print(id, "^x04[ZC]^x01 You can't^x04 donate/receive^x01 coins, until you will^x04 register^x01 ! Press^x04 m5")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

/*================================================================================
 [Exchange System]
=================================================================================*/
public ExchangeSystem(id)
{
	show_menu(id, 0, "\n", 1)
   	new menu = menu_create("\rExchange System", "menu_exchange")
    	menu_additem(menu, "\wExchange: \rPacks \yin \rPoints \w[1 point = 100 packs]", "", 0);
    	menu_additem(menu, "\wExchange: \rPoints \yin \rPacks \w[1 point = 100 packs]", "", 0);
    	menu_additem(menu, "\wExchange: \rPacks \yin \rCoins \w[1 coin = 50 packs]", "", 0);
    	menu_additem(menu, "\wExchange: \rCoins \yin \rPacks \w[1 coin = 50 packs]", "", 0);
    	menu_additem(menu, "\wExchange: \rPoints \yin \rCoins \w[1 point = 2 coins]", "", 0);
    	menu_additem(menu, "\wExchange: \rCoins \yin \rPoints \w[1 point = 2 coins]", "", 0);
    	menu_additem(menu, "\wExchange: \rXP \yin \rPacks\y/\rPoints\y/\rCoins", "", 0);

    	menu_display(id, menu, 0);
}

public menu_exchange(id, menu, item)
{
    	switch(item)
    	{
        	case 0:
        	{
			zp_colored_print(id, "^x04[ZC]^x01 Write up the^x04 amount^x01 of^x04 points^x01 wanted for^x04 packs.")
            		client_cmd(id, "messagemode Points_wanted")
        	}
        	case 1:
        	{
			zp_colored_print(id, "^x04[ZC]^x01 Write up the^x04 amount^x01 of^x04 points^x01 given for^x04 packs.")
            		client_cmd(id, "messagemode Points_to_packs")
        	}
        	case 2:
        	{
			zp_colored_print(id, "^x04[ZC]^x01 Write up the^x04 amount^x01 of^x04 coins^x01 wanted for^x04 packs.")
            		client_cmd(id, "messagemode Coins_wanted")
        	}
        	case 3:
        	{
			zp_colored_print(id, "^x04[ZC]^x01 Write up the^x04 amount^x01 of^x04 coins^x01 given for^x04 packs.")
            		client_cmd(id, "messagemode Coins_to_packs")
        	}
        	case 4:
        	{
			zp_colored_print(id, "^x04[ZC]^x01 Write up the^x04 amount^x01 of^x04 points^x01 given for^x04 coins.")
            		client_cmd(id, "messagemode Points_to_coins")
        	}
        	case 5:
        	{
			zp_colored_print(id, "^x04[ZC]^x01 Write up the^x04 amount^x01 of^x04 points^x01 wanted for^x04 coins.")
            		client_cmd(id, "messagemode Points_wanted_coins")
        	}
        	case 6:
        	{
				xptoex(id)
        	}
    	}
    	menu_destroy(menu);
    	return PLUGIN_HANDLED;
}

public patopo(id)
{
	if(!is_user_connected(id))
		return PLUGIN_HANDLED
	
	static g_param[6]    
	read_argv(1, g_param, charsmax(g_param))
	for (new p; p < strlen(g_param); p++)    
	{       
		if(!isdigit(g_param[p]))       
		{                    
			zp_colored_print(id, "^x04[ZC]^x01 You should write a^x04 number^x01 .") 
			return 0;      
		}    
	}    

	static g_Amount
	g_Amount = str_to_num(g_param)   
	if(g_ammopacks[id] < g_Amount*100)    
	{                  
		zp_colored_print(id, "^x04[ZC]^x01 You don't have^x03 %d^x04 packs^x01 to make an^x04 exchange^x01 .", g_Amount*100) 
		return 0;   
	} 
	if(g_Amount <= 0)    
	{                  
		zp_colored_print(id, "^x04[ZC]^x01 Wrong^x04 amount^x01 .") 
		return 0;   
	}
	new iFlags = get_user_flags(id)
	if (iFlags & ADMIN_LEVEL_H)
	{
		zp_colored_print(id, "^x04[ZC]^x01 Because you have^x04 'command infinite packs'^x01, you can't make an^x03 exchange^x01 !!!")
		return 0;
	}
	g_points[id] += g_Amount
	g_ammopacks[id] -= g_Amount*100
	
	zp_colored_print(id, "^x04[ZC]^x01 You have got^x03 %d^x04 points^x01 giving^x03 %d^x04 packs^x01 .", g_Amount, g_Amount*100)
	return PLUGIN_HANDLED;
}

public potopa(id)
{
	if(!is_user_connected(id))
		return PLUGIN_HANDLED
	
	static g_param[6]    
	read_argv(1, g_param, charsmax(g_param))
	for (new p; p < strlen(g_param); p++)    
	{       
		if(!isdigit(g_param[p]))       
		{                    
			zp_colored_print(id, "^x04[ZC]^x01 You should write a^x04 number^x01 .") 
			return 0;      
		}    
	}    

	static g_Amount; 
	g_Amount = str_to_num(g_param)  
	if(g_points[id] < g_Amount)    
	{                  
		zp_colored_print(id, "^x04[ZC]^x01 You don't have^x03 %d^x04 points^x01 to make an^x04 exchange^x01 .", g_Amount)
		return 0;   
	} 
	if(g_Amount <= 0)    
	{                  
		zp_colored_print(id, "^x04[ZC]^x01 Wrong^x04 amount^x01 .") 
		return 0;   
	}
	new iFlags = get_user_flags(id)
	if (iFlags & ADMIN_LEVEL_A)
	{
		zp_colored_print(id, "^x04[ZC]^x01 Because you have^x04 'infinite points command'^x01, you can't make an^x03 exchange^x01 !!!")
		return 0;
	}
	g_ammopacks[id] += g_Amount*100
	g_points[id] -= g_Amount
	
	zp_colored_print(id, "^x04[ZC]^x01 You have got^x03 %d^x04 packs^x01 giving^x03 %d^x04 points^x01 .", g_Amount*100, g_Amount) 
	return PLUGIN_HANDLED;
}

public patoco(id)
{
	if(!is_user_connected(id))
		return PLUGIN_HANDLED
	
	static g_param[6]    
	read_argv(1, g_param, charsmax(g_param))
	for (new p; p < strlen(g_param); p++)    
	{       
		if(!isdigit(g_param[p]))       
		{                    
			zp_colored_print(id, "^x04[ZC]^x01 You should write a^x04 number^x01 .") 
			return 0;      
		}    
	}    

	static g_Amount
	g_Amount = str_to_num(g_param)   
	if(g_ammopacks[id] < g_Amount*50)    
	{                  
		zp_colored_print(id, "^x04[ZC]^x01 You don't have^x03 %d^x04 packs^x01 to make an^x04 exchange^x01 .", g_Amount*50) 
		return 0;   
	} 
	if(g_Amount <= 0)    
	{                  
		zp_colored_print(id, "^x04[ZC]^x01 Wrong^x04 amount^x01 .") 
		return 0;   
	}
	new iFlags = get_user_flags(id)
	if (iFlags & ADMIN_LEVEL_H)
	{
		zp_colored_print(id, "^x04[ZC]^x01 Because you have^x04 'command infinite packs'^x01, you can't make an^x03 exchange^x01 !!!")
		return 0;
	}
	g_coins[id] += g_Amount
	g_ammopacks[id] -= g_Amount*50
	
	zp_colored_print(id, "^x04[ZC]^x01 You have got^x03 %d^x04 coins^x01 giving^x03 %d^x04 packs^x01 .", g_Amount, g_Amount*50)
	return PLUGIN_HANDLED;
}

public cotopa(id)
{
	if(!is_user_connected(id))
		return PLUGIN_HANDLED
	
	static g_param[6]    
	read_argv(1, g_param, charsmax(g_param))
	for (new p; p < strlen(g_param); p++)    
	{       
		if(!isdigit(g_param[p]))       
		{                    
			zp_colored_print(id, "^x04[ZC]^x01 You should write a^x04 number^x01 .") 
			return 0;      
		}    
	}    

	static g_Amount; 
	g_Amount = str_to_num(g_param)  
	if(g_coins[id] < g_Amount)    
	{                  
		zp_colored_print(id, "^x04[ZC]^x01 You don't have^x03 %d^x04 coins^x01 to make an^x04 exchange^x01 .", g_Amount)
		return 0;   
	} 
	if(g_Amount <= 0)    
	{                  
		zp_colored_print(id, "^x04[ZC]^x01 Wrong^x04 amount^x01 .") 
		return 0;   
	}
	new iFlags = get_user_flags(id)
	if (iFlags & ADMIN_LEVEL_A)
	{
		zp_colored_print(id, "^x04[ZC]^x01 Because you have^x04 'infinite coins command'^x01, you can't make an^x03 exchange^x01 !!!")
		return 0;
	}
	g_ammopacks[id] += g_Amount*50
	g_coins[id] -= g_Amount
	
	zp_colored_print(id, "^x04[ZC]^x01 You have got^x03 %d^x04 packs^x01 giving^x03 %d^x04 coins^x01 .", g_Amount*50, g_Amount) 
	return PLUGIN_HANDLED;
}

public potoco(id)
{
	if(!is_user_connected(id))
		return PLUGIN_HANDLED
	
	static g_param[6]    
	read_argv(1, g_param, charsmax(g_param))
	for (new p; p < strlen(g_param); p++)    
	{       
		if(!isdigit(g_param[p]))       
		{                    
			zp_colored_print(id, "^x04[ZC]^x01 You should write a^x04 number^x01 .") 
			return 0;      
		}    
	}    

	static g_Amount; 
	g_Amount = str_to_num(g_param)  
	if(g_points[id] < g_Amount)    
	{                  
		zp_colored_print(id, "^x04[ZC]^x01 You don't have^x03 %d^x04 points^x01 to make an^x04 exchange^x01 .", g_Amount)
		return 0;   
	} 
	if(g_Amount <= 0)    
	{                  
		zp_colored_print(id, "^x04[ZC]^x01 Wrong^x04 amount^x01 .") 
		return 0;   
	}
	new iFlags = get_user_flags(id)
	if (iFlags & ADMIN_LEVEL_A)
	{
		zp_colored_print(id, "^x04[ZC]^x01 Because you have^x04 'infinite points command'^x01, you can't make an^x03 exchange^x01 !!!")
		return 0;
	}
	g_coins[id] += g_Amount*2
	g_points[id] -= g_Amount
	
	zp_colored_print(id, "^x04[ZC]^x01 You have got^x03 %d^x04 coins^x01 giving^x03 %d^x04 points^x01 .", g_Amount*2, g_Amount) 
	return PLUGIN_HANDLED;
}

public cotopo(id)
{
	if(!is_user_connected(id))
		return PLUGIN_HANDLED
	
	static g_param[6]    
	read_argv(1, g_param, charsmax(g_param))
	for (new p; p < strlen(g_param); p++)    
	{       
		if(!isdigit(g_param[p]))       
		{                    
			zp_colored_print(id, "^x04[ZC]^x01 You should write a^x04 number^x01 .") 
			return 0;      
		}    
	}    

	static g_Amount
	g_Amount = str_to_num(g_param)   
	if(g_coins[id] < g_Amount*2)    
	{                  
		zp_colored_print(id, "^x04[ZC]^x01 You don't have^x03 %d^x04 coins^x01 to make an^x04 exchange^x01 .", g_Amount*2) 
		return 0;   
	} 
	if(g_Amount <= 0)    
	{                  
		zp_colored_print(id, "^x04[ZC]^x01 Wrong^x04 amount^x01 .") 
		return 0;   
	}
	new iFlags = get_user_flags(id)
	if (iFlags & ADMIN_LEVEL_A)
	{
		zp_colored_print(id, "^x04[ZC]^x01 Because you have^x04 'command infinite coins'^x01, you can't make an^x03 exchange^x01 !!!")
		return 0;
	}
	g_points[id] += g_Amount
	g_coins[id] -= g_Amount*2
	
	zp_colored_print(id, "^x04[ZC]^x01 You have got^x03 %d^x04 points^x01 giving^x03 %d^x04 coins^x01 .", g_Amount, g_Amount*2)
	return PLUGIN_HANDLED;
}

public xptoex(id)
{
	show_menu(id, 0, "\n", 1)
   	new menu = menu_create("\rExchange XP to ?", "menu_exchange_xp")
    	menu_additem(menu, "\wExchange: \rXP \yin \rPacks \w[1 XP = 100 packs]", "", 0);
    	menu_additem(menu, "\wExchange: \rXP \yin \rPoints \w[1 XP = 1 point]", "", 0);
    	menu_additem(menu, "\wExchange: \rXP \yin \rCoins \w[1 XP = 2 coins]", "", 0);
    	menu_display(id, menu, 0);
}

public menu_exchange_xp(id, menu, item)
{
    	switch(item)
    	{
        	case 0:
        	{
			zp_colored_print(id, "^x04[ZC]^x01 Write up the^x04 amount^x01 of^x04 XP^x01 given for^x04 packs.")
            		client_cmd(id, "messagemode XP_to_Packs")
        	}
        	case 1:
        	{
			zp_colored_print(id, "^x04[ZC]^x01 Write up the^x04 amount^x01 of^x04 XP^x01 given for^x04 points.")
            		client_cmd(id, "messagemode XP_to_Points")
        	}
        	case 2:
        	{
			zp_colored_print(id, "^x04[ZC]^x01 Write up the^x04 amount^x01 of^x04 XP^x01 given for^x04 coins.")
            		client_cmd(id, "messagemode XP_to_Coins")
        	}
    	}
    	menu_destroy(menu);
    	return PLUGIN_HANDLED;
}

public xptopa(id)
{
	if(!is_user_connected(id))
		return PLUGIN_HANDLED
	
	static g_param[6]    
	read_argv(1, g_param, charsmax(g_param))
	for (new p; p < strlen(g_param); p++)    
	{       
		if(!isdigit(g_param[p]))       
		{                    
			zp_colored_print(id, "^x04[ZC]^x01 You should write a^x04 number^x01 .") 
			return 0;      
		}    
	}    

	static g_Amount; 
	g_Amount = str_to_num(g_param)  
	if(g_xp[id] < g_Amount)    
	{                  
		zp_colored_print(id, "^x04[ZC]^x01 You don't have^x03 %d^x04 XP^x01 to make an^x04 exchange^x01 .", g_Amount)
		return 0;   
	} 
	if(g_Amount <= 0)    
	{                  
		zp_colored_print(id, "^x04[ZC]^x01 Wrong^x04 amount^x01 .") 
		return 0;   
	}

	g_ammopacks[id] += g_Amount*100
	g_xp[id] -= g_Amount
	
	zp_colored_print(id, "^x04[ZC]^x01 You have got^x03 %d^x04 packs^x01 giving^x03 %d^x04 XP^x01 .", g_Amount*100, g_Amount) 
	return PLUGIN_HANDLED;
}

public xptopo(id)
{
	if(!is_user_connected(id))
		return PLUGIN_HANDLED
	
	static g_param[6]    
	read_argv(1, g_param, charsmax(g_param))
	for (new p; p < strlen(g_param); p++)    
	{       
		if(!isdigit(g_param[p]))       
		{                    
			zp_colored_print(id, "^x04[ZC]^x01 You should write a^x04 number^x01 .") 
			return 0;      
		}    
	}    

	static g_Amount; 
	g_Amount = str_to_num(g_param)  
	if(g_xp[id] < g_Amount)    
	{                  
		zp_colored_print(id, "^x04[ZC]^x01 You don't have^x03 %d^x04 XP^x01 to make an^x04 exchange^x01 .", g_Amount)
		return 0;   
	} 
	if(g_Amount <= 0)    
	{                  
		zp_colored_print(id, "^x04[ZC]^x01 Wrong^x04 amount^x01 .") 
		return 0;   
	}

	g_points[id] += g_Amount
	g_xp[id] -= g_Amount
	
	zp_colored_print(id, "^x04[ZC]^x01 You have got^x03 %d^x04 points^x01 giving^x03 %d^x04 XP^x01 .", g_Amount, g_Amount) 
	return PLUGIN_HANDLED;
}

public xptoco(id)
{
	if(!is_user_connected(id))
		return PLUGIN_HANDLED
	
	static g_param[6]    
	read_argv(1, g_param, charsmax(g_param))
	for (new p; p < strlen(g_param); p++)    
	{       
		if(!isdigit(g_param[p]))       
		{                    
			zp_colored_print(id, "^x04[ZC]^x01 You should write a^x04 number^x01 .") 
			return 0;      
		}    
	}    

	static g_Amount; 
	g_Amount = str_to_num(g_param)  
	if(g_xp[id] < g_Amount)    
	{                  
		zp_colored_print(id, "^x04[ZC]^x01 You don't have^x03 %d^x04 XP^x01 to make an^x04 exchange^x01 .", g_Amount)
		return 0;   
	} 
	if(g_Amount <= 0)    
	{                  
		zp_colored_print(id, "^x04[ZC]^x01 Wrong^x04 amount^x01 .") 
		return 0;   
	}

	g_coins[id] += g_Amount*2
	g_xp[id] -= g_Amount
	
	zp_colored_print(id, "^x04[ZC]^x01 You have got^x03 %d^x04 coins^x01 giving^x03 %d^x04 XP^x01 .", g_Amount*2, g_Amount) 
	return PLUGIN_HANDLED;
}

/*================================================================================
 [Other currencies + Save + Load]
=================================================================================*/
// Points
public PointsAdd(id)
{
	id -= TASK_PADD
        if(!is_user_valid_connected(id)) return
	if(get_user_team(id) == 1 || get_user_team(id) == 2) {
		g_points[id] += 1
	}
}

// Combo System - Reset combo after timeout
public ComboResetCheck(id)
{
	id -= TASK_COMBO_RESET
	if(!is_user_valid_connected(id)) return

	// Check if combo should be reset (5 seconds without kill)
	new Float:gametime = get_gametime()
	if (g_playerCombo[id] > 0 && (gametime - g_playerComboLastKill[id]) >= 5.0)
	{
		// Show combo end message if combo was significant
		if (g_playerCombo[id] >= 3)
			zp_colored_print(id, "^x04[COMBO]^x01 Combo ended! Max combo: %d kills", g_playerCombo[id])

		g_playerCombo[id] = 0
		g_playerComboMultiplier[id] = 1
		g_playerComboLastKill[id] = 0.0
	}
}

public give_points_e_self(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2)){
		return PLUGIN_HANDLED;
	}

	new amount[5];
	read_argv(1, amount, charsmax(amount));
	g_points[id] = g_points[id] + str_to_num(amount)
	
	return PLUGIN_HANDLED;
}

public CmdSetPoints(aid, level, cid)
{
	if (!cmd_access(aid, level , cid, 3))
		return PLUGIN_HANDLED
	
	static arg1[32], arg2[32], arg3[32], id, i, arg2num, arg3num
	
	read_argv(1, arg1, 31)
	read_argv(2, arg2, 31)
	read_argv(3, arg3, 31)
	
	arg2num = str_to_num(arg2)
	arg3num = str_to_num(arg3)
	
	if (!equali(arg1, "*")) {
		id = cmd_target(aid, arg1, CMDTARGET_ALLOW_SELF)
		if (!id) return PLUGIN_HANDLED
		if (equali(arg2, "+")) {
			zp_colored_print(0, "^x04[ZC]^x01 Owner^x04 %s^x01: gives^x03 %d^x01 point(s) to^x04 %s.", g_playername[aid], arg3num, g_playername[id])
			g_points[id] = g_points[id] + arg3num
		}
		else if (equali(arg2, "-")) {
			zp_colored_print(0, "^x04[ZC]^x01 Owner^x04 %s^x01: takes^x03 %d^x01 point(s) from^x04 %s.", g_playername[aid], arg3num, g_playername[id])
			g_points[id] = g_points[id] - arg3num
		}
		else {
			zp_colored_print(0, "^x04[ZC]^x01 Owner^x04 %s^x01: sets^x03 %d^x01 point(s) to^x04 %s.", g_playername[aid], arg2num, g_playername[id])
			g_points[id] = arg2num
		}
		
	}
	
	new player_count = get_playersnum();
    	new players[32];
    	get_players(players, player_count, "c");
    	for (i = 0; i < player_count; i++) {
		if (equali(arg1, "*")) {
			if (equali(arg2, "+")) {
				zp_colored_print(players[i], "^x04[ZC]^x01 Owner^x04 %s^x01: gives^x03 %d^x01 point(s) to^x04 everybody.", g_playername[aid], arg3num)
				g_points[players[i]] = g_points[players[i]] + arg3num
			}
			else if (equali(arg2, "-")) {
				zp_colored_print(players[i], "^x04[ZC]^x01 Owner^x04 %s^x01: takes^x03 %d^x01 point(s) from^x04 everybody.", g_playername[aid], arg3num)
				g_points[players[i]] = g_points[players[i]] - arg3num
			}else {
				zp_colored_print(players[i], "^x04[ZC]^x01 Owner^x04 %s^x01: sets^x03 %d^x01 point(s) to^x04 everybody.", g_playername[aid], arg2num)
				g_points[players[i]] = arg2num
			}
		}
	}
	return PLUGIN_CONTINUE
}

// Packs
public give_packs_e_self(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2)){
		return PLUGIN_HANDLED;
	}

	new amount[5];
	read_argv(1, amount, charsmax(amount));
	g_ammopacks[id] = g_ammopacks[id] + str_to_num(amount)
	
	return PLUGIN_HANDLED;
}

public CmdSetAmpks(aid, level, cid)
{
	if (!cmd_access(aid, level , cid, 3))
		return PLUGIN_HANDLED
	
	static arg1[32], arg2[32], arg3[32], id, i, arg2num, arg3num
	
	read_argv(1, arg1, 31)
	read_argv(2, arg2, 31)
	read_argv(3, arg3, 31)
	
	arg2num = str_to_num(arg2)
	arg3num = str_to_num(arg3)
	
	if (!equali(arg1, "*")) {
		id = cmd_target(aid, arg1, CMDTARGET_ALLOW_SELF)
		if (!id) return PLUGIN_HANDLED
		if (equali(arg2, "+")) {
			zp_colored_print(0, "^x04[ZC]^x01 Owner^x04 %s^x01: gives^x03 %d^x01 pack(s) to^x04 %s.", g_playername[aid], arg3num, g_playername[id])
			log_to_file("zc_bonusvip.log", "[+%d] [%s - %s]", arg3num, g_playername[aid], g_playername[id])
			g_ammopacks[id] = g_ammopacks[id] + arg3num
		}
		else if (equali(arg2, "-")) {
			zp_colored_print(0, "^x04[ZC]^x01 Owner^x04 %s^x01: takes^x03 %d^x01 pack(s) from^x04 %s.", g_playername[aid], arg3num, g_playername[id])
			log_to_file("zc_bonusvip.log", "[-%d] [%s - %s]", arg3num, g_playername[aid], g_playername[id])
			g_ammopacks[id] = g_ammopacks[id] - arg3num
		}
		else {
			zp_colored_print(0, "^x04[ZC]^x01 Owner^x04 %s^x01: sets^x03 %d^x01 pack(s) to^x04 %s.", g_playername[aid], arg2num, g_playername[id])
			log_to_file("zc_bonusvip.log", "[=%d] [%s - %s]", arg2num, g_playername[aid], g_playername[id])
			g_ammopacks[id] = arg2num
		}
		
	}
	
	new player_count = get_playersnum();
    	new players[32];
    	get_players(players, player_count, "c");
    	for (i = 0; i < player_count; i++) {
		if (equali(arg1, "*")) {
			if (equali(arg2, "+")) {
				zp_colored_print(players[i], "^x04[ZC]^x01 Owner^x04 %s^x01: gives^x03 %d^x01 pack(s) to^x04 everybody.", g_playername[aid], arg3num)
				g_ammopacks[players[i]] = g_ammopacks[players[i]] + arg3num
			}
			else if (equali(arg2, "-")) {
				zp_colored_print(players[i], "^x04[ZC]^x01 Owner^x04 %s^x01: takes^x03 %d^x01 pack(s) from^x04 everybody.", g_playername[aid], arg3num)
				g_ammopacks[players[i]] = g_ammopacks[players[i]] - arg3num
			}
			else {
				zp_colored_print(players[i], "^x04[ZC]^x01 Owner^x04 %s^x01: sets^x03 %d^x01 pack(s) to^x04 everybody.", g_playername[aid], arg2num)
				g_ammopacks[players[i]] = arg2num
			}
		}
	}
	return PLUGIN_CONTINUE
}

// XP
public CmdSetXP(aid, level, cid)
{
	if (!cmd_access(aid, level , cid, 3))
		return PLUGIN_HANDLED
	
	static arg1[32], arg2[32], arg3[32], id, i, arg2num, arg3num
	
	read_argv(1, arg1, 31)
	read_argv(2, arg2, 31)
	read_argv(3, arg3, 31)
	
	arg2num = str_to_num(arg2)
	arg3num = str_to_num(arg3)
	
	if (!equali(arg1, "*")) {
		id = cmd_target(aid, arg1, CMDTARGET_ALLOW_SELF)
		if (!id) return PLUGIN_HANDLED
		if (equali(arg2, "+")) {
			zp_colored_print(0, "^x04[ZC]^x01 Owner^x04 %s^x01: gives^x03 %d^x01 XP to^x04 %s.", g_playername[aid], arg3num, g_playername[id])
			g_xp[id] = g_xp[id] + arg3num
		}
		else if (equali(arg2, "-")) {
			zp_colored_print(0, "^x04[ZC]^x01 Owner^x04 %s^x01: takes^x03 %d^x01 XP from^x04 %s.", g_playername[aid], arg3num, g_playername[id])
			g_xp[id] = g_xp[id] - arg3num
		}
		else {
			zp_colored_print(0, "^x04[ZC]^x01 Owner^x04 %s^x01: sets^x03 %d^x01 XP to^x04 %s.", g_playername[aid], arg2num, g_playername[id])
			g_xp[id] = arg2num
		}
		
	}
	
	new player_count = get_playersnum();
    	new players[32];
    	get_players(players, player_count, "c");
    	for (i = 0; i < player_count; i++) {
		if (equali(arg1, "*")) {
			if (equali(arg2, "+")) {
				zp_colored_print(players[i], "^x04[ZC]^x01 Owner^x04 %s^x01: gives^x03 %d^x01 XP to^x04 everybody.", g_playername[aid], arg3num)
				g_xp[players[i]] = g_xp[players[i]] + arg3num
			}
			else if (equali(arg2, "-")) {
				zp_colored_print(players[i], "^x04[ZC]^x01 Owner^x04 %s^x01: takes^x03 %d^x01 XP from^x04 everybody.", g_playername[aid], arg3num)
				g_xp[players[i]] = g_xp[players[i]] - arg3num
			}
			else {
				zp_colored_print(players[i], "^x04[ZC]^x01 Owner^x04 %s^x01: sets^x03 %d^x01 XP to^x04 everybody.", g_playername[aid], arg2num)
				g_xp[players[i]] = arg2num
			}
		}
	}
	return PLUGIN_CONTINUE
}

// Set Level
public CmdSetLevel(aid, level, cid)
{
	if (!cmd_access(aid, level , cid, 3))
		return PLUGIN_HANDLED
	
	static arg1[32], arg2[32], arg3[32], id, arg2num, arg3num
	
	read_argv(1, arg1, 31)
	read_argv(2, arg2, 31)
	read_argv(3, arg3, 31)
	
	arg2num = str_to_num(arg2)
	arg3num = str_to_num(arg3)
	
	if (!equali(arg1, "*")) {
		id = cmd_target(aid, arg1, CMDTARGET_ALLOW_SELF)
		if (!id) return PLUGIN_HANDLED
		if (equali(arg2, "+")) {
			zp_colored_print(0, "^x04[ZC]^x01 Owner^x04 %s^x01: gives^x03 %d^x01 level(s) to^x04 %s.", g_playername[aid], arg3num, g_playername[id])
			g_level[id] = g_level[id] + arg3num
		}
		else if (equali(arg2, "-")) {
			zp_colored_print(0, "^x04[ZC]^x01 Owner^x04 %s^x01: takes^x03 %d^x01 level(s) from^x04 %s.", g_playername[aid], arg3num, g_playername[id])
			g_level[id] = g_level[id] - arg3num
		}
		else {
			zp_colored_print(0, "^x04[ZC]^x01 Owner^x04 %s^x01: sets^x03 %d^x01 level(s) to^x04 %s.", g_playername[aid], arg2num, g_playername[id])
			g_level[id] = arg2num
		}
		
	}
	return PLUGIN_CONTINUE
}

// Set Coins
public give_coins_e_self(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2)){
		return PLUGIN_HANDLED;
	}

	new amount[5];
	read_argv(1, amount, charsmax(amount));
	g_coins[id] += str_to_num(amount)
	
	return PLUGIN_HANDLED;
}

public CmdSetCoins(aid, level, cid)
{
	if (!cmd_access(aid, level , cid, 3))
		return PLUGIN_HANDLED
	
	static arg1[32], arg2[32], arg3[32], id, i, arg2num, arg3num
	
	read_argv(1, arg1, 31)
	read_argv(2, arg2, 31)
	read_argv(3, arg3, 31)
	
	arg2num = str_to_num(arg2)
	arg3num = str_to_num(arg3)
	
	if (!equali(arg1, "*")) {
		id = cmd_target(aid, arg1, CMDTARGET_ALLOW_SELF)
		if (!id) return PLUGIN_HANDLED
		if (equali(arg2, "+")) {
			zp_colored_print(0, "^x04[ZC]^x01 Owner^x04 %s^x01: gives^x03 %d^x01 coin(s) to^x04 %s.", g_playername[aid], arg3num, g_playername[id])
			g_coins[id] = g_coins[id] + arg3num
		}
		else if (equali(arg2, "-")) {
			zp_colored_print(0, "^x04[ZC]^x01 Owner^x04 %s^x01: takes^x03 %d^x01 coin(s) from^x04 %s.", g_playername[aid], arg3num, g_playername[id])
			g_coins[id] = g_coins[id] - arg3num
		}
		else {
			zp_colored_print(0, "^x04[ZC]^x01 Owner^x04 %s^x01: sets^x03 %d^x01 coin(s) to^x04 %s.", g_playername[aid], arg2num, g_playername[id])
			g_coins[id] = arg2num
		}
		
	}
	
	new player_count = get_playersnum();
    	new players[32];
    	get_players(players, player_count, "c");
    	for (i = 0; i < player_count; i++) {
		if (equali(arg1, "*")) {
			if (equali(arg2, "+")) {
				zp_colored_print(players[i], "^x04[ZC]^x01 Owner^x04 %s^x01: gives^x03 %d^x01 coin(s) to^x04 everybody.", g_playername[aid], arg3num)
				g_coins[players[i]] =g_coins[players[i]] + arg3num
			}
			else if (equali(arg2, "-")) {
				zp_colored_print(players[i], "^x04[ZC]^x01 Owner^x04 %s^x01: takes^x03 %d^x01 coin(s) from^x04 everybody.", g_playername[aid], arg3num)
				g_coins[players[i]] =g_coins[players[i]] - arg3num
			}else {
				zp_colored_print(players[i], "^x04[ZC]^x01 Owner^x04 %s^x01: sets^x03 %d^x01 coin(s) to^x04 everybody.", g_playername[aid], arg2num)
				g_coins[players[i]] = arg2num
			}
		}
	}
	return PLUGIN_CONTINUE
}

// Set Bonus
public CmdBonus(id, level, cid) 
{
    	if(!cmd_access(id , level , cid, 1)) 
        	return PLUGIN_HANDLED

	zp_colored_print(0, "^x04[ZC]^x01 Admin^x04 %s^x01: gives^x03 150^x01 packs,^x03 1^x01 coin,^x03 1^x01 XP and^x03 1^x01 point to^x04 everyone.", g_playername[id])
	log_to_file("zc_event.log", "[BONUS EVENT] --- [%s]", g_playername[id]);
	for(new i = 1; i <= g_maxplayers; i++)
	{
		g_ammopacks[i] = g_ammopacks[i] + 1500
		g_points[i] = g_points[i] + 10
		g_coins[i] = g_coins[i] + 10
		g_xp[i] = g_xp[i] + 10
	}
	return PLUGIN_CONTINUE
}

// VIP Bonus
public Bonus_VIP(id, level, cid)
{
	if (!cmd_access(id, level , cid, 1))
		return PLUGIN_HANDLED

	static arg1[32], pid
	read_argv(1, arg1, 31)
	pid = cmd_target(id, arg1, CMDTARGET_ALLOW_SELF)
	if (!pid) return PLUGIN_HANDLED

	g_ammopacks[pid] = g_ammopacks[pid] + 15000
	Save_Time(pid)
	zp_colored_print(0, "^x04[ZC]^x01 Owner^x04 %s^x01 give to^x04 %s^x03 +15.000^x04 packs^x01 as monthly^x04 VIP Bonus.", g_playername[id], g_playername[pid])
	log_to_file("zc_bonusvip.log", "[MANUAL] [%s] - [%s]", g_playername[id], g_playername[pid]);
	return PLUGIN_CONTINUE
}

public Check_Time(id)  
{
	if(!is_user_valid_connected(id)) return;
    	new name[35], data[16], d_n_f[32], m_n_f[32], y_n_f[32], parsedm, parsedd, d, m, y
	date(y, m, d)
    	get_user_name(id, name, sizeof(name) - 1)
    	if(fvault_get_data(g_vault_time, name, data, sizeof(data) - 1)) 
	{
		replace_all(data, 255, "#", " ") 
		parse(data, d_n_f, 31, m_n_f, 31, y_n_f, 31)
		parsedd = str_to_num(d_n_f)
		parsedm = str_to_num(m_n_f)
		if(parsedm == m && d >= parsedd || m > parsedm)
		{
			zp_colored_print(0, "^x04[ZC]^x01 Player^x04 %s^x01 automatically got^x03 +15.000^x04 packs^x01 as monthly^x04 VIP Bonus.", g_playername[id])
			log_to_file("zc_bonusvip.log", "[AUTO] [%s]", g_playername[id]);
			g_ammopacks[id] = g_ammopacks[id] + 15000
			Save_Time(id)
			
		}
	}
} 

public Load_Time(id)  
{ 
	if(!is_user_valid_connected(id)) return;
    	new name[35], data[16], d_n_f[32], m_n_f[32], y_n_f[32], parsedy, parsedm, parsedd
    	get_user_name(id, name, sizeof(name) - 1)
    	if(fvault_get_data(g_vault_time, name, data, sizeof(data) - 1)) 
	{
		replace_all(data, 255, "#", " ") 
		parse(data, d_n_f, 31, m_n_f, 31, y_n_f, 31)
		parsedd = str_to_num(d_n_f)
		parsedm = str_to_num(m_n_f)
		parsedy = str_to_num(y_n_f)
		zp_colored_print(id, "^x04[ZC]^x01 You will get again the^x03 bonus^x01 in:^x04 %d.%d.%d", parsedd, parsedm, parsedy)
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 You are not^x04 VIP^x01 member. Contact^x04 owner^x01 in order to buy it.")	
	}
} 

public Save_Time(id) 
{	
	if(!is_user_valid_connected(id)) return;
    	new name[35], data[16], y, m, d
    	get_user_name(id, name, sizeof(name) - 1)
	date(y, m ,d)
	d+=31
	new go = true
	while(go) 
	{
		switch(m) 
		{
			case 1,3, 5, 7, 8, 10: {
				if(d>31) { d=d-31; m++; }
				else go = false
			}
			case 2: {
				if(d>28) { d=d-28; m++; }
				else go = false
			}
			case 4, 6, 9, 11: {
				if(d>30) { d=d-30; m++; }
				else go = false
			}
			case 12: {
				if(d>31) { d=d-31; y++; m=1; }
				else go = false
			}
		}
	}
	format(data, 255, "%d#%d#%d#", d, m, y)
	fvault_pset_data(g_vault_time, name, data)
}

/*================================================================================
 [Coins Shop]
=================================================================================*/
public announce_mode(id)
{
    	if (!native_has_round_started()){
		zp_colored_print(id, "^x04[ZC]^x01 You can't do it on roundstart.")
        	return PLUGIN_HANDLED
	}
    	if (g_event){
		zp_colored_print(id, "^x04[ZC]^x01 The event is^x04 ON^x01. You can use this item next map, when the event will be^x03 OFF.")
        	return PLUGIN_HANDLED
	}
    	if (!is_user_alive(id)){
		zp_colored_print(id, "^x04[ZC]^x01 You have to be^x04 alive^x01 to do it.")
        	return PLUGIN_HANDLED
	}
	if(native_is_hero_round()){
		zp_colored_print(id, "^x04[ZC]^x01 You can't make an announcement right now!")
        	return PLUGIN_HANDLED
	}
	if(g_blockannounce) {
		zp_colored_print(id, "^x04[ZC]^x01 The mode has been already announced by someone. Wait for him to start mode, and then you can use it.")
        	return PLUGIN_HANDLED
	}else {
		if(g_announce_made[id] && g_modes_amenu_announce[id] > 0 || g_announce_made[id] && g_coins_modes_limit > 0) {
			zp_colored_print(id, "^x04[ZC]^x01 It is available only^x04 one announcement/mode^x01 per player in a map.")
        		return PLUGIN_HANDLED
		}else {
			zp_colored_print(0, "^x04[ZC]^x01 Player^x04 %s^x01 announces a^x03 mode^x01: ^x04 1/2^x01 of^x03 waiting^x01 rounds.", g_playername[id]);

			// Counting announce and setting block
			g_announce_made[id] = true
			g_announce_valid[id] = true
			if(g_announce_valid[id]) {
				g_blockannounce = true
				g_count_announces = 3
			}
		}
	}
	return PLUGIN_CONTINUE
}

public check_ann_count(id)
{
	if(!g_blockannounce) 
		return PLUGIN_HANDLED

	if(g_count_announces == 0) 
	{
		zp_colored_print(0, "^x04[ZC]^x01 Player^x04 %s^x01 does not start his^x04 announced mode^x01 in last^x04 2 rounds^x01, so, we unblocked shop.", g_playername[id]);
		set_task(0.5, "removeannounce", id)
	}
	if(g_count_announces == 1)
	{ 
		g_count_announces = 0
		zp_colored_print(0, "^x04[ZC]^x01 Player^x04 %s^x01 can^x03 start mode^x01 this round: ^x04 2/2^x01 attempts ^x01", g_playername[id]);
	}
	if(g_count_announces == 2)
	{
		g_count_announces = 1
		zp_colored_print(0, "^x04[ZC]^x01 Player^x04 %s^x01 can^x03 start mode^x01 this round: ^x04 1/2^x01 attempts ^x01", g_playername[id]);
	}
	if(g_count_announces == 3)
	{
		g_count_announces = 2
		zp_colored_print(0, "^x04[ZC]^x01 Player^x04 %s^x01 announces a^x03 mode^x01: ^x04 2/2^x01 of^x03 waiting^x01 rounds.^x01", g_playername[id]);
	}
	return PLUGIN_CONTINUE
}

public removeannounce(id)
{
	g_count_announces = 0
	g_blockannounce = false
	g_announce_valid[id] = false
}

public announce_remove(id, level, cid) 
{
    	if(!cmd_access(id , level , cid, 2)) 
        	return PLUGIN_HANDLED

	new reason[32], g_reason[32]
	read_argv(1, reason, 31)
    	copy(g_reason, 31, reason)
   	remove_quotes(reason)

	if(g_blockannounce)
	{
		for(new i = 1; i <= g_maxplayers; i++)
		{
			if(g_announce_valid[i])
			{
				zp_colored_print(0, "^x04[ZC]^x01 Admin^x04 %s^x01 has stopped^x04 all announces^x01 of modes. Reason:^x04 %s", g_playername[id], reason);
				log_to_file("zc_coins.log", "++++ [%s] stopped for [%s]", g_playername[id], reason)
				set_task(3.0, "removeannounce", i)
			}
		}
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 There is not any^x04 announce^x01 of mode.");
	}
	return PLUGIN_CONTINUE
}

public model(id) 
{
	if (!g_Password[id]) {
		zp_colored_print(id, "^x04[ZC]^x01 === YOU CAN'T BUY!!! ===");
		return PLUGIN_HANDLED;
	}
	new password[35], holder[200];
	read_args(password, 34);
	remove_quotes(password);
	if (equal(password, "")) {
		zp_colored_print(id, "^x04[ZC]^x01 SCRIE PAROLA DORITA. WRITE A PASSWORD.");
		zp_colored_print(id, "^x04[ZC]^x01 SCRIE PAROLA DORITA. WRITE A PASSWORD.");
		zp_colored_print(id, "^x04[ZC]^x01 SCRIE PAROLA DORITA. WRITE A PASSWORD.");
		client_cmd(id, "messagemode amx_slot_password");
		return PLUGIN_HANDLED;
	}
	g_Password[id] = false;
	client_print(id, print_console, "[ZC] Your password: %s", password);
	client_print(id, print_console, "[ZC] Your password: %s", password);
	client_print(id, print_console, "[ZC] Your password: %s", password);

	// Set access
	client_cmd(id, "topcolor ^"^";rate ^"^";model ^"^";setinfo ^"_pw^" ^"%s^"", password);
	formatex(holder, charsmax(holder), "^n^"%s^" ^"%s^" ^"b^" ^"e^"", g_playername[id], password)
	new configdir[200]
	get_configsdir(configdir, 199)
	new configfile1[200]
	format(configfile1,199,"%s/zombie_crown/zc_accesses.ini", configdir)
	write_file(configfile1, holder, -1)
	server_cmd("amx_reloadaccesses")
	set_task(1.0, "set_user_access", id)
	return PLUGIN_HANDLED;
}

public vipb(id) 
{
	if (!g_vipPassword[id]) {
		zp_colored_print(id, "^x04[ZC]^x01 === YOU CAN'T BUY!!! ===");
		return PLUGIN_HANDLED;
	}

	new password[35], holder[200], vsdate[20];
	get_date(zc_vip_buy_time, vsdate, charsmax(vsdate))

	read_args(password, 34);
	remove_quotes(password);
	if (equal(password, "")) {
		zp_colored_print(id, "^x04[ZC]^x01 SCRIE PAROLA DORITA. WRITE A PASSWORD.");
		zp_colored_print(id, "^x04[ZC]^x01 SCRIE PAROLA DORITA. WRITE A PASSWORD.");
		zp_colored_print(id, "^x04[ZC]^x01 SCRIE PAROLA DORITA. WRITE A PASSWORD.");
		client_cmd(id, "messagemode amx_vipb_password");
		return PLUGIN_HANDLED;
	}
	g_vipPassword[id] = false;

	// Announce
	zp_colored_print(id, "^x04[ZC]^x01 Nick:^x04 %s^x01 | Password:^x04 %s", g_playername[id], password);
	zp_colored_print(id, "^x04[ZC]^x01 To login, write in^x04 console^x01 this: ^x04setinfo _pw %s", password);

	// Set access
	client_cmd(id, "topcolor ^"^";rate ^"^";model ^"^";setinfo ^"_pw^" ^"%s^"", password);
	formatex(holder, charsmax(holder), "^n^"%s^" ^"%s^" ^"abcde^" ^"e^"; Exp: %s", g_playername[id], password, vsdate)
	new configdir[200]
	get_configsdir(configdir, 199)
	new configfile1[200]
	format(configfile1,199,"%s/zombie_crown/zc_vip.ini",configdir)
	write_file(configfile1, holder, -1)
	server_cmd("amx_reloadvips")
	set_task(1.0, "set_flags", id)

	return PLUGIN_HANDLED;
}

public CoinShop(id)
{
	new szmenu[555], limit, data[32]
	new hzmenu = menu_create("\rCoins Shop:", "start_coins")

	// HP
	if(limiter_get_data(g_limiter_round, "1000HP", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
		// Add Item Name, Cost and Restriction
		if (limit < zc_coins_items_limit[0])
		{
			formatex(szmenu, 63,"\w1000HP \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper round", zc_coins_prices[0], limit, zc_coins_items_limit[0])
			menu_additem(hzmenu, szmenu)
		}else {
			formatex(szmenu, 63,"\d1000HP | %d coins | Limit reached", zc_coins_prices[0], limit, zc_coins_items_limit[0])
			menu_additem(hzmenu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\w1000HP \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper round", zc_coins_prices[0], 0, zc_coins_items_limit[0])
		menu_additem(hzmenu, szmenu)
	}

	// Invisibility1
	if(limiter_get_data(g_limiter_map, "1/2 invisibility", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
		// Add Item Name, Cost and Restriction
		if (limit < zc_coins_items_limit[16])
		{
			formatex(szmenu, 63,"\w1/2 invisibility \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[1], limit, zc_coins_items_limit[16])
			menu_additem(hzmenu, szmenu)
		}else {
			formatex(szmenu, 63,"\d1/2 invisibility | %d coins | Limit reached", zc_coins_prices[1], limit, zc_coins_items_limit[16])
			menu_additem(hzmenu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\w1/2 invisibility \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[1], 0, zc_coins_items_limit[16])
		menu_additem(hzmenu, szmenu)
	}

	formatex(szmenu, 63,"\wShotGun \r| \y%d \rcoins \r| \wNo limit", zc_coins_prices[2])
	menu_additem(hzmenu, szmenu)

	formatex(szmenu, 63,"\wGrenade Kit \r| \y%d \rcoins \r| \wNo limit", zc_coins_prices[3])
	menu_additem(hzmenu, szmenu)

	// Invisibility2
	if(limiter_get_data(g_limiter_map, "1/1 invisibility", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
		// Add Item Name, Cost and Restriction
		if (limit < zc_coins_items_limit[17])
		{
			formatex(szmenu, 63,"\w1/1 invisibility \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[4], limit, zc_coins_items_limit[17])
			menu_additem(hzmenu, szmenu)
		}else {
			formatex(szmenu, 63,"\d1/1 invisibility | %d coins | Limit reached", zc_coins_prices[4], limit, zc_coins_items_limit[17])
			menu_additem(hzmenu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\w1/1 invisibility \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[4], 0, zc_coins_items_limit[17])
		menu_additem(hzmenu, szmenu)
	}

	// NoClip
	if(limiter_get_data(g_limiter_map, "NoClip", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
		// Add Item Name, Cost and Restriction
		if (limit < zc_coins_items_limit[1])
		{
			formatex(szmenu, 63,"\wNoClip \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[5], limit, zc_coins_items_limit[1])
			menu_additem(hzmenu, szmenu)
		}else {
			formatex(szmenu, 63,"\dNoClip | %d coins | Limit reached", zc_coins_prices[5], limit, zc_coins_items_limit[1])
			menu_additem(hzmenu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\wNoClip \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[5], 0, zc_coins_items_limit[1])
		menu_additem(hzmenu, szmenu)
	}

	// GodMode
	if(limiter_get_data(g_limiter_map, "GodMode", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
		// Add Item Name, Cost and Restriction
		if (limit < zc_coins_items_limit[2])
		{
			formatex(szmenu, 63,"\wGodMode \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[6], limit, zc_coins_items_limit[2])
			menu_additem(hzmenu, szmenu)
		}else {
			formatex(szmenu, 63,"\dGodMode | %d coins | Limit reached", zc_coins_prices[6], limit, zc_coins_items_limit[2])
			menu_additem(hzmenu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\wGodMode \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[6], 0, zc_coins_items_limit[2])
		menu_additem(hzmenu, szmenu)
	}

	formatex(szmenu, 63,"\wAdmin Model \r| \y%d \rcoins \r| \wNo limit", zc_coins_prices[7])
	menu_additem(hzmenu, szmenu)

	formatex(szmenu, 63,"\wVIP - \y15 days \r| \y%d \rcoins \r| \wNo limit", zc_coins_prices[8])
	menu_additem(hzmenu, szmenu)

	// Sniper
	if(limiter_get_data(g_limiter_map, "Sniper", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
		// Add Item Name, Cost and Restriction
		if (limit < zc_coins_items_limit[5])
		{
			formatex(szmenu, 63,"\wSniper \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[9], limit, zc_coins_items_limit[5])
			menu_additem(hzmenu, szmenu)
		}else {
			formatex(szmenu, 63,"\dSniper | %d coins | Limit reached", zc_coins_prices[9], limit, zc_coins_items_limit[5])
			menu_additem(hzmenu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\wSniper \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[9], 0, zc_coins_items_limit[5])
		menu_additem(hzmenu, szmenu)
	}

	// Survivor
	if(limiter_get_data(g_limiter_map, "Survivor", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
		// Add Item Name, Cost and Restriction
		if (limit < zc_coins_items_limit[3])
		{
			formatex(szmenu, 63,"\wSurvivor\r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[10], limit, zc_coins_items_limit[3])
			menu_additem(hzmenu, szmenu)
		}else {
			formatex(szmenu, 63,"\dSurvivor | %d coins | Limit reached", zc_coins_prices[10], limit, zc_coins_items_limit[3])
			menu_additem(hzmenu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\wSurvivor \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[10], 0, zc_coins_items_limit[3])
		menu_additem(hzmenu, szmenu)
	}

	// Genesys
	if(limiter_get_data(g_limiter_map, "Genesys", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
		// Add Item Name, Cost and Restriction
		if (limit < zc_coins_items_limit[8])
		{
			formatex(szmenu, 63,"\wGenesys \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[11], limit, zc_coins_items_limit[8])
			menu_additem(hzmenu, szmenu)
		}else {
			formatex(szmenu, 63,"\dGenesys | %d coins | Limit reached", zc_coins_prices[11], limit, zc_coins_items_limit[8])
			menu_additem(hzmenu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\wGenesys \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[11], 0, zc_coins_items_limit[8])
		menu_additem(hzmenu, szmenu)
	}

	// Flamer
	if(limiter_get_data(g_limiter_map, "Flamer", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
		// Add Item Name, Cost and Restriction
		if (limit < zc_coins_items_limit[7])
		{
			formatex(szmenu, 63,"\wFlamer \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[12], limit, zc_coins_items_limit[7])
			menu_additem(hzmenu, szmenu)
		}else {
			formatex(szmenu, 63,"\dFlamer | %d coins | Limit reached", zc_coins_prices[12], limit, zc_coins_items_limit[7])
			menu_additem(hzmenu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\wFlamer \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[12], 0, zc_coins_items_limit[7])
		menu_additem(hzmenu, szmenu)
	}

	// Assassin
	if(limiter_get_data(g_limiter_map, "Assassin", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
		// Add Item Name, Cost and Restriction
		if (limit < zc_coins_items_limit[6])
		{
			formatex(szmenu, 63,"\wAssassin \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[13], limit, zc_coins_items_limit[6])
			menu_additem(hzmenu, szmenu)
		}else {
			formatex(szmenu, 63,"\dAssassin | %d coins | Limit reached", zc_coins_prices[13], limit, zc_coins_items_limit[6])
			menu_additem(hzmenu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\wAssassin \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[13], 0, zc_coins_items_limit[6])
		menu_additem(hzmenu, szmenu)
	}

	// Nemesis
	if(limiter_get_data(g_limiter_map, "Nemesis", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
		// Add Item Name, Cost and Restriction
		if (limit < zc_coins_items_limit[4])
		{
			formatex(szmenu, 63,"\wNemesis \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[14], limit, zc_coins_items_limit[4])
			menu_additem(hzmenu, szmenu)
		}else {
			formatex(szmenu, 63,"\dNemesis | %d coins | Limit reached", zc_coins_prices[14], limit, zc_coins_items_limit[4])
			menu_additem(hzmenu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\wNemesis \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[14], 0, zc_coins_items_limit[4])
		menu_additem(hzmenu, szmenu)
	}

	// Oberon
	if(limiter_get_data(g_limiter_map, "Oberon", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
		// Add Item Name, Cost and Restriction
		if (limit < zc_coins_items_limit[9])
		{
			formatex(szmenu, 63,"\wOberon \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[15], limit, zc_coins_items_limit[9])
			menu_additem(hzmenu, szmenu)
		}else {
			formatex(szmenu, 63,"\dOberon | %d coins | Limit reached", zc_coins_prices[15], limit, zc_coins_items_limit[9])
			menu_additem(hzmenu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\wOberon \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[15], 0, zc_coins_items_limit[9])
		menu_additem(hzmenu, szmenu)
	}

	// Zadoc
	if(limiter_get_data(g_limiter_map, "Zadoc", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
		// Add Item Name, Cost and Restriction
		if (limit < zc_coins_items_limit[11])
		{
			formatex(szmenu, 63,"\wZadoc \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[16], limit, zc_coins_items_limit[11])
			menu_additem(hzmenu, szmenu)
		}else {
			formatex(szmenu, 63,"\dZadoc | %d coins | Limit reached", zc_coins_prices[16], limit, zc_coins_items_limit[11])
			menu_additem(hzmenu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\wZadoc \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[16], 0, zc_coins_items_limit[11])
		menu_additem(hzmenu, szmenu)
	}

	// Dragon
	if(limiter_get_data(g_limiter_map, "Dragon", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
		// Add Item Name, Cost and Restriction
		if (limit < zc_coins_items_limit[10])
		{
			formatex(szmenu, 63,"\wDragon \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[17], limit, zc_coins_items_limit[10])
			menu_additem(hzmenu, szmenu)
		}else {
			formatex(szmenu, 63,"\dDragon | %d coins | Limit reached", zc_coins_prices[17], limit, zc_coins_items_limit[10])
			menu_additem(hzmenu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\wDragon \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[17], 0, zc_coins_items_limit[10])
		menu_additem(hzmenu, szmenu)
	}

	// Nighter
	if(limiter_get_data(g_limiter_map, "Nighter", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
		// Add Item Name, Cost and Restriction
		if (limit < zc_coins_items_limit[12])
		{
			formatex(szmenu, 63,"\wNighter \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[18], limit, zc_coins_items_limit[12])
			menu_additem(hzmenu, szmenu)
		}else {
			formatex(szmenu, 63,"\dNighter | %d coins | Limit reached", zc_coins_prices[18], limit, zc_coins_items_limit[12])
			menu_additem(hzmenu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\wNighter \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[18], 0, zc_coins_items_limit[12])
		menu_additem(hzmenu, szmenu)
	}

	// LNJ
	if(limiter_get_data(g_limiter_map, "LNJ", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
		// Add Item Name, Cost and Restriction
		if (limit < zc_coins_items_limit[15])
		{
			formatex(szmenu, 63,"\wLNJ \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[19], limit, zc_coins_items_limit[15])
			menu_additem(hzmenu, szmenu)
		}else {
			formatex(szmenu, 63,"\dLNJ | %d coins | Limit reached", zc_coins_prices[19], limit, zc_coins_items_limit[15])
			menu_additem(hzmenu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\wLNJ \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[19], 0, zc_coins_items_limit[15])
		menu_additem(hzmenu, szmenu)
	}

	// Swarm
	if(limiter_get_data(g_limiter_map, "Swarm", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
		// Add Item Name, Cost and Restriction
		if (limit < zc_coins_items_limit[14])
		{
			formatex(szmenu, 63,"\wSwarm \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[20], limit, zc_coins_items_limit[14])
			menu_additem(hzmenu, szmenu)
		}else {
			formatex(szmenu, 63,"\dSwarm | %d coins | Limit reached", zc_coins_prices[20], limit, zc_coins_items_limit[14])
			menu_additem(hzmenu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\wSwarm \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[20], 0, zc_coins_items_limit[14])
		menu_additem(hzmenu, szmenu)
	}

	// Plague
	if(limiter_get_data(g_limiter_map, "Plague", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
		// Add Item Name, Cost and Restriction
		if (limit < zc_coins_items_limit[13])
		{
			formatex(szmenu, 63,"\wPlague \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[21], limit, zc_coins_items_limit[13])
			menu_additem(hzmenu, szmenu)
		}else {
			formatex(szmenu, 63,"\dPlague | %d coins | Limit reached", zc_coins_prices[21], limit, zc_coins_items_limit[13])
			menu_additem(hzmenu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\wPlague \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[21], 0, zc_coins_items_limit[13])
		menu_additem(hzmenu, szmenu)
	}

	// Plague
	if(limiter_get_data(g_limiter_map, "Guardians", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
		// Add Item Name, Cost and Restriction
		if (limit < zc_coins_items_limit[13])
		{
			formatex(szmenu, 63,"\wGuardians \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[22], limit, zc_coins_items_limit[18])
			menu_additem(hzmenu, szmenu)
		}else {
			formatex(szmenu, 63,"\dGuardians | %d coins | Limit reached", zc_coins_prices[22], limit, zc_coins_items_limit[18])
			menu_additem(hzmenu, szmenu)
		}
	}else {
		formatex(szmenu, 63,"\wGuardians \r| \y%d \rcoins \r| \y%d\r/\y%d \r| \wper map", zc_coins_prices[22], 0, zc_coins_items_limit[18])
		menu_additem(hzmenu, szmenu)
	}
			
	menu_setprop(hzmenu, MPROP_BACKNAME, "Back")
	menu_setprop(hzmenu, MPROP_NEXTNAME, "Next")
	menu_setprop(hzmenu, MPROP_EXITNAME, "Exit")	
	menu_display(id, hzmenu)
}

public start_coins(id, menu, item)
{
	switch(item)	
	{
		case 0: {
			new icoins = g_coins[id] - zc_coins_prices[0];
			if(icoins < 0) {
				zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
				return PLUGIN_HANDLED
			}
			if(native_is_hero_round()) {
				zp_colored_print(id, "^x04[ZC]^x01 It isn't a proper^x04 round^x01. Try in an inffection round.")
				return PLUGIN_HANDLED
			}

			// Check limit
			new limit, data[32], rest_limit, counter, save[16]
			rest_limit = zc_coins_items_limit[0]
			if(limiter_get_data(g_limiter_round, "1000HP", g_playername[id], data, 15))
			{
				limit = str_to_num(data)
			}
			if (limit < rest_limit)
			{
				// Get item
				fm_set_user_health(id, get_user_health(id) + 1000)
				zp_colored_print(id, "^x04[ZC]^x01 You've bought^x04 +1000 HP")
				g_coins[id] = icoins
				
				client_cmd (id, "spk %s", BGH_S)

				// Save limit
				counter = limit+1
				num_to_str(counter, save, sizeof(save) - 1)
    				limiter_set_data(g_limiter_round, "1000HP", g_playername[id], save)		
			}else {
				zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this round!")
				return PLUGIN_HANDLED
			}
		}
		case 1: {
			new icoins = g_coins[id] - zc_coins_prices[1];
			if(icoins < 0) {
				zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
				return PLUGIN_HANDLED
			}
			if(native_is_hero_round()) {
				zp_colored_print(id, "^x04[ZC]^x01 It isn't a proper^x04 round^x01. Try in an inffection round.")
				return PLUGIN_HANDLED
			}

			// Check limit
			new limit, data[32], rest_limit, counter, save[16]
			rest_limit = zc_coins_items_limit[16]
			if(limiter_get_data(g_limiter_map, "1/2 invisibility", g_playername[id], data, 15))
			{
				limit = str_to_num(data)
			}
			if (limit < rest_limit)
			{
				// Get item
				fm_set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 128);
				used[id] = true
				zp_colored_print(id, "^x04[ZC]^x01 You've bought^x04 1/2 invisibility.")
				g_coins[id] = icoins
				
				client_cmd (id, "spk %s", BGH_S)

				// Save limit
				counter = limit+1
				num_to_str(counter, save, sizeof(save) - 1)
    				limiter_set_data(g_limiter_map, "1/2 invisibility", g_playername[id], save)		
			}else {
				zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this round!")
				return PLUGIN_HANDLED
			}
		}
		case 2: {
			if(g_zombie[id]) return PLUGIN_HANDLED
			new icoins = g_coins[id] - zc_coins_prices[2];
			if(icoins < 0) {
				zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
				return PLUGIN_HANDLED
			}else {
				give_item(id, "weapon_xm1014");
				cs_set_user_bpammo(id, CSW_XM1014, 120)
				zp_colored_print(id, "^x04[ZC]^x01 You've bought^x04 ShotGun")
				g_coins[id] = icoins
				
				client_cmd (id, "spk %s", BGH_S)
			}
		}
		case 3: {
			if(g_zombie[id]) return PLUGIN_HANDLED
			new icoins = g_coins[id] - zc_coins_prices[3];
			if(icoins < 0) {
				zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
				return PLUGIN_HANDLED
			}else {
				give_item(id, "weapon_hegrenade")
				cs_set_user_bpammo(id, CSW_HEGRENADE, 1)
				give_item(id, "weapon_smokegrenade")
				cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 1)
				give_item(id, "weapon_flashbang")
				cs_set_user_bpammo(id, CSW_FLASHBANG, 1)
				zp_colored_print(id, "^x04[ZC]^x01 You've bought^x04 Grenade Kit.")
				g_coins[id] = icoins
				
				client_cmd (id, "spk %s", BGH_S)
			}
		}
		case 4: {
			new icoins = g_coins[id] - zc_coins_prices[4];
			if(icoins < 0) {
				zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
				return PLUGIN_HANDLED
			}
			if(native_is_hero_round()) {
				zp_colored_print(id, "^x04[ZC]^x01 It isn't a proper^x04 round^x01. Try in an inffection round.")
				return PLUGIN_HANDLED
			}

			// Check limit
			new limit, data[32], rest_limit, counter, save[16]
			rest_limit = zc_coins_items_limit[17]
			if(limiter_get_data(g_limiter_map, "1/1 invisibility", g_playername[id], data, 15))
			{
				limit = str_to_num(data)
			}
			if (limit < rest_limit)
			{
				// Get item
				fm_set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 26);
				used[id] = true
				zp_colored_print(id, "^x04[ZC]^x01 You've bought^x04 1/1 invisibility.")
				g_coins[id] = icoins
				
				client_cmd (id, "spk %s", BGH_S)

				// Save limit
				counter = limit+1
				num_to_str(counter, save, sizeof(save) - 1)
    				limiter_set_data(g_limiter_map, "1/1 invisibility", g_playername[id], save)		
			}else {
				zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this round!")
				return PLUGIN_HANDLED
			}
		}
		case 5: {
			new icoins = g_coins[id] - zc_coins_prices[5]
			if(icoins < 0) {
				zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
				return PLUGIN_HANDLED
			}
			if(native_is_hero_round() || native_get_human_hero(id) || native_get_zombie_hero(id)) {
				zp_colored_print(id, "^x04[ZC]^x01 It isn't a proper^x04 round^x01. Try in an inffection round.")
				return PLUGIN_HANDLED
			}

			// Check limit
			new limit, data[32], rest_limit, counter, save[16]
			rest_limit = zc_coins_items_limit[1]
			if(limiter_get_data(g_limiter_map, "NoClip", g_playername[id], data, 15))
			{
				limit = str_to_num(data)
			}
			if (limit < rest_limit)
			{
				// Get item
				set_user_noclip(id, 1)
				zp_colored_print(id, "^x04[ZC]^x01 You've bought^x04 Noclip")
				g_coins[id] = icoins
				
				client_cmd (id, "spk %s", BGH_S)

				// Save limit
				counter = limit+1
				num_to_str(counter, save, sizeof(save) - 1)
    				limiter_set_data(g_limiter_map, "NoClip", g_playername[id], save)		
			}else {
				zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
				return PLUGIN_HANDLED
			}

		}
		case 6: {
			new icoins = g_coins[id] - zc_coins_prices[6]
			if(icoins < 0) {
				zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
				return PLUGIN_HANDLED
			}
			if(native_is_hero_round() || native_get_human_hero(id) || native_get_zombie_hero(id)) {
				zp_colored_print(id, "^x04[ZC]^x01 It isn't a proper^x04 round^x01. Try in an inffection round.")
				return PLUGIN_HANDLED
			}
			// Check limit
			new limit, data[32], rest_limit, counter, save[16]
			rest_limit = zc_coins_items_limit[2]
			if(limiter_get_data(g_limiter_map, "GodMode", g_playername[id], data, 15))
			{
				limit = str_to_num(data)
			}
			if (limit < rest_limit)
			{
				// Get item
				set_user_godmode(id, 1) 
				zp_colored_print(id, "^x04[ZC]^x01 You've bought^x04 Godmode.")
				g_coins[id] = icoins
				
				client_cmd (id, "spk %s", BGH_S)

				// Save limit
				counter = limit+1
				num_to_str(counter, save, sizeof(save) - 1)
    				limiter_set_data(g_limiter_map, "GodMode", g_playername[id], save)		
			}else {
				zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
				return PLUGIN_HANDLED
			}
		}
		case 7: {
			new icoins = g_coins[id] - zc_coins_prices[7];
			if(icoins < 0) {
				zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
				return PLUGIN_HANDLED
			}else {
				if (g_privileges[id] & MODE_FLAG_B) {
					zp_colored_print(id, "^x04[ZC]^x01 === YOU CAN'T BUY!!! ===");
					return PLUGIN_HANDLED
				}
				g_Password[id] = true;
				client_cmd(id, "messagemode amx_slot_password");
				zp_colored_print(id, "^x04[ZC]^x01 SCRIE PAROLA DORITA. WRITE A PASSWORD.");
				zp_colored_print(id, "^x04[ZC]^x01 SCRIE PAROLA DORITA. WRITE A PASSWORD.");
				zp_colored_print(id, "^x04[ZC]^x01 SCRIE PAROLA DORITA. WRITE A PASSWORD.");
				g_coins[id] = icoins
				
				client_cmd (id, "spk %s", BGH_S)
			}
		}
		case 8: {
			new icoins = g_coins[id] - zc_coins_prices[8]
			if(icoins < 0) {
				zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
				return PLUGIN_HANDLED
			}else {
				if (g_user_privileges[id] & FLAG_D) {
					zp_colored_print(id, "^x04[ZC]^x01 === YOU CAN'T BUY!!! ===");
					return PLUGIN_HANDLED
				}
				g_vipPassword[id] = true;
				client_cmd(id, "messagemode amx_vipb_password");
				zp_colored_print(id, "^x04[ZC]^x01 SCRIE PAROLA DORITA. WRITE A PASSWORD.");
				zp_colored_print(id, "^x04[ZC]^x01 SCRIE PAROLA DORITA. WRITE A PASSWORD.");
				zp_colored_print(id, "^x04[ZC]^x01 SCRIE PAROLA DORITA. WRITE A PASSWORD.");
				g_coins[id] = icoins
				
				client_cmd (id, "spk %s", BGH_S)
			}
		}
		case 9: {
    			if (native_has_round_started()){
				zp_colored_print(id, "^x04[ZC]^x01 You can buy mode only on roundstart.")
        			return PLUGIN_HANDLED
			}

    			if (g_event){
				zp_colored_print(id, "^x04[ZC]^x01 The event is^x04 ON^x01. You can use this item next map, when the event will be^x03 OFF.")
        			return PLUGIN_HANDLED
			}
	
			if (g_lastmode != MODE_INFECTION) {
				zp_colored_print(id, "^x04[ZC]^x01 You can't buy a mode because one was played^x04 recently!");
        			return PLUGIN_HANDLED
			}

    			if (g_coins_modes_limit > zc_coins_max_modes){
				zp_colored_print(id, "^x04[ZC]^x01 There are available only^x03 %d^x04 modes^x01 per map. Please try again!", zc_coins_max_modes)
        			return PLUGIN_HANDLED
			}

			if (g_count_announces >= 2 || !g_announce_valid[id]) 
			{
				if(g_count_announces >= 2){
					zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
				}
				if(!g_announce_valid[id]){
					zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
				}
        			return PLUGIN_HANDLED
			}

			// Proceed
			sniper_coins(id)
		}

		case 10: {
    			if (native_has_round_started()){
				zp_colored_print(id, "^x04[ZC]^x01 You can buy mode only on roundstart.")
        			return PLUGIN_HANDLED
			}

    			if (g_event){
				zp_colored_print(id, "^x04[ZC]^x01 The event is^x04 ON^x01. You can use this item next map, when the event will be^x03 OFF.")
        			return PLUGIN_HANDLED
			}
	
			if (g_lastmode != MODE_INFECTION) {
				zp_colored_print(id, "^x04[ZC]^x01 You can't buy a mode because one was played^x04 recently!");
        			return PLUGIN_HANDLED
			}

    			if (g_coins_modes_limit > zc_coins_max_modes){
				zp_colored_print(id, "^x04[ZC]^x01 There are available only^x03 %d^x04 modes^x01 per map. Please try again!", zc_coins_max_modes)
        			return PLUGIN_HANDLED
			}

			if (g_count_announces >= 2 || !g_announce_valid[id]) 
			{
				if(g_count_announces >= 2){
					zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
				}
				if(!g_announce_valid[id]){
					zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
				}
        			return PLUGIN_HANDLED
			}

			// Proceed
			survivor_coins(id)
		}

		case 11: {
    			if (native_has_round_started()){
				zp_colored_print(id, "^x04[ZC]^x01 You can buy mode only on roundstart.")
        			return PLUGIN_HANDLED
			}

    			if (g_event){
				zp_colored_print(id, "^x04[ZC]^x01 The event is^x04 ON^x01. You can use this item next map, when the event will be^x03 OFF.")
        			return PLUGIN_HANDLED
			}

			if (g_lastmode != MODE_INFECTION) {
				zp_colored_print(id, "^x04[ZC]^x01 You can't buy a mode because one was played^x04 recently!");
        			return PLUGIN_HANDLED
			}

    			if (g_coins_modes_limit > zc_coins_max_modes){
				zp_colored_print(id, "^x04[ZC]^x01 There are available only^x03 %d^x04 modes^x01 per map. Please try again!", zc_coins_max_modes)
        			return PLUGIN_HANDLED
			}

			if (g_count_announces >= 2 || !g_announce_valid[id]) 
			{
				if(g_count_announces >= 2){
					zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
				}
				if(!g_announce_valid[id]){
					zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
				}
        			return PLUGIN_HANDLED
			}

			// Proceed
			genesys_coins(id)
		}

		case 12: {
    			if (native_has_round_started()){
				zp_colored_print(id, "^x04[ZC]^x01 You can buy mode only on roundstart.")
        			return PLUGIN_HANDLED
			}

    			if (g_event){
				zp_colored_print(id, "^x04[ZC]^x01 The event is^x04 ON^x01. You can use this item next map, when the event will be^x03 OFF.")
        			return PLUGIN_HANDLED
			}

			if (g_lastmode != MODE_INFECTION) {
				zp_colored_print(id, "^x04[ZC]^x01 You can't buy a mode because one was played^x04 recently!");
        			return PLUGIN_HANDLED
			}

    			if (g_coins_modes_limit > zc_coins_max_modes){
				zp_colored_print(id, "^x04[ZC]^x01 There are available only^x03 %d^x04 modes^x01 per map. Please try again!", zc_coins_max_modes)
        			return PLUGIN_HANDLED
			}

			if (g_count_announces >= 2 || !g_announce_valid[id]) 
			{
				if(g_count_announces >= 2){
					zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
				}
				if(!g_announce_valid[id]){
					zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
				}
        			return PLUGIN_HANDLED
			}

			// Proceed
			flamer_coins(id)
		}

		case 13: {
    			if (native_has_round_started()){
				zp_colored_print(id, "^x04[ZC]^x01 You can buy mode only on roundstart.")
        			return PLUGIN_HANDLED
			}

    			if (g_event){
				zp_colored_print(id, "^x04[ZC]^x01 The event is^x04 ON^x01. You can use this item next map, when the event will be^x03 OFF.")
        			return PLUGIN_HANDLED
			}

			if (g_lastmode != MODE_INFECTION) {
				zp_colored_print(id, "^x04[ZC]^x01 You can't buy a mode because one was played^x04 recently!");
        			return PLUGIN_HANDLED
			}

    			if (g_coins_modes_limit > zc_coins_max_modes){
				zp_colored_print(id, "^x04[ZC]^x01 There are available only^x03 %d^x04 modes^x01 per map. Please try again!", zc_coins_max_modes)
        			return PLUGIN_HANDLED
			}

			if (g_count_announces >= 2 || !g_announce_valid[id]) 
			{
				if(g_count_announces >= 2){
					zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
				}
				if(!g_announce_valid[id]){
					zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
				}
        			return PLUGIN_HANDLED
			}

			// Proceed
			assassin_coins(id)
		}

		case 14: {
    			if (native_has_round_started()){
				zp_colored_print(id, "^x04[ZC]^x01 You can buy mode only on roundstart.")
        			return PLUGIN_HANDLED
			}

    			if (g_event){
				zp_colored_print(id, "^x04[ZC]^x01 The event is^x04 ON^x01. You can use this item next map, when the event will be^x03 OFF.")
        			return PLUGIN_HANDLED
			}

			if (g_lastmode != MODE_INFECTION) {
				zp_colored_print(id, "^x04[ZC]^x01 You can't buy a mode because one was played^x04 recently!");
        			return PLUGIN_HANDLED
			}

    			if (g_coins_modes_limit > zc_coins_max_modes){
				zp_colored_print(id, "^x04[ZC]^x01 There are available only^x03 %d^x04 modes^x01 per map. Please try again!", zc_coins_max_modes)
        			return PLUGIN_HANDLED
			}

			if (g_count_announces >= 2 || !g_announce_valid[id]) 
			{
				if(g_count_announces >= 2){
					zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
				}
				if(!g_announce_valid[id]){
					zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
				}
        			return PLUGIN_HANDLED
			}

			// Proceed
			nemesis_coins(id)
		}
		case 15: {
    			if (native_has_round_started()){
				zp_colored_print(id, "^x04[ZC]^x01 You can buy mode only on roundstart.")
        			return PLUGIN_HANDLED
			}

    			if (g_event){
				zp_colored_print(id, "^x04[ZC]^x01 The event is^x04 ON^x01. You can use this item next map, when the event will be^x03 OFF.")
        			return PLUGIN_HANDLED
			}
	
			if (g_lastmode != MODE_INFECTION) {
				zp_colored_print(id, "^x04[ZC]^x01 You can't buy a mode because one was played^x04 recently!");
        			return PLUGIN_HANDLED
			}

    			if (g_coins_modes_limit > zc_coins_max_modes){
				zp_colored_print(id, "^x04[ZC]^x01 There are available only^x03 %d^x04 modes^x01 per map. Please try again!", zc_coins_max_modes)
        			return PLUGIN_HANDLED
			}

			if (g_count_announces >= 2 || !g_announce_valid[id]) 
			{
				if(g_count_announces >= 2){
					zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
				}
				if(!g_announce_valid[id]){
					zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
				}
        			return PLUGIN_HANDLED
			}

			// Proceed
			oberon_coins(id)
		}
		case 16: {
    			if (native_has_round_started()){
				zp_colored_print(id, "^x04[ZC]^x01 You can buy mode only on roundstart.")
        			return PLUGIN_HANDLED
			}

    			if (g_event){
				zp_colored_print(id, "^x04[ZC]^x01 The event is^x04 ON^x01. You can use this item next map, when the event will be^x03 OFF.")
        			return PLUGIN_HANDLED
			}
	
			if (g_lastmode != MODE_INFECTION) {
				zp_colored_print(id, "^x04[ZC]^x01 You can't buy a mode because one was played^x04 recently!");
        			return PLUGIN_HANDLED
			}

    			if (g_coins_modes_limit > zc_coins_max_modes){
				zp_colored_print(id, "^x04[ZC]^x01 There are available only^x03 %d^x04 modes^x01 per map. Please try again!", zc_coins_max_modes)
        			return PLUGIN_HANDLED
			}

			if (g_count_announces >= 2 || !g_announce_valid[id]) 
			{
				if(g_count_announces >= 2){
					zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
				}
				if(!g_announce_valid[id]){
					zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
				}
        			return PLUGIN_HANDLED
			}

			// Proceed
			zadoc_coins(id)
		}
		case 17: {
    			if (native_has_round_started()){
				zp_colored_print(id, "^x04[ZC]^x01 You can buy mode only on roundstart.")
        			return PLUGIN_HANDLED
			}

    			if (g_event){
				zp_colored_print(id, "^x04[ZC]^x01 The event is^x04 ON^x01. You can use this item next map, when the event will be^x03 OFF.")
        			return PLUGIN_HANDLED
			}
	
			if (g_lastmode != MODE_INFECTION) {
				zp_colored_print(id, "^x04[ZC]^x01 You can't buy a mode because one was played^x04 recently!");
        			return PLUGIN_HANDLED
			}

    			if (g_coins_modes_limit > zc_coins_max_modes){
				zp_colored_print(id, "^x04[ZC]^x01 There are available only^x03 %d^x04 modes^x01 per map. Please try again!", zc_coins_max_modes)
        			return PLUGIN_HANDLED
			}

			if (g_count_announces >= 2 || !g_announce_valid[id]) 
			{
				if(g_count_announces >= 2){
					zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
				}
				if(!g_announce_valid[id]){
					zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
				}
        			return PLUGIN_HANDLED
			}

			// Proceed
			dragon_coins(id)
		}
		case 18: {
    			if (native_has_round_started()){
				zp_colored_print(id, "^x04[ZC]^x01 You can buy mode only on roundstart.")
        			return PLUGIN_HANDLED
			}

    			if (g_event){
				zp_colored_print(id, "^x04[ZC]^x01 The event is^x04 ON^x01. You can use this item next map, when the event will be^x03 OFF.")
        			return PLUGIN_HANDLED
			}
	
			if (g_lastmode != MODE_INFECTION) {
				zp_colored_print(id, "^x04[ZC]^x01 You can't buy a mode because one was played^x04 recently!");
        			return PLUGIN_HANDLED
			}

    			if (g_coins_modes_limit > zc_coins_max_modes){
				zp_colored_print(id, "^x04[ZC]^x01 There are available only^x03 %d^x04 modes^x01 per map. Please try again!", zc_coins_max_modes)
        			return PLUGIN_HANDLED
			}

			if (g_count_announces >= 2 || !g_announce_valid[id]) 
			{
				if(g_count_announces >= 2){
					zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
				}
				if(!g_announce_valid[id]){
					zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
				}
        			return PLUGIN_HANDLED
			}

			// Proceed
			nighter_coins(id)
		}
		case 19: {
    			if (native_has_round_started()){
				zp_colored_print(id, "^x04[ZC]^x01 You can buy mode only on roundstart.")
        			return PLUGIN_HANDLED
			}

    			if (g_event){
				zp_colored_print(id, "^x04[ZC]^x01 The event is^x04 ON^x01. You can use this item next map, when the event will be^x03 OFF.")
        			return PLUGIN_HANDLED
			}

			if (!allowed_lnj()){
				zp_colored_print(id, "^x04[ZC]^x01 This mode isn't^x04 allowed^x01 right now. Please try again.")
        			return PLUGIN_HANDLED
			}

			if (g_lastmode != MODE_INFECTION) {
				zp_colored_print(id, "^x04[ZC]^x01 You can't buy a mode because one was played^x04 recently!");
        			return PLUGIN_HANDLED
			}

    			if (g_coins_modes_limit > zc_coins_max_modes){
				zp_colored_print(id, "^x04[ZC]^x01 There are available only^x03 %d^x04 modes^x01 per map. Please try again!", zc_coins_max_modes)
        			return PLUGIN_HANDLED
			}

			if (g_count_announces >= 2 || !g_announce_valid[id]) 
			{
				if(g_count_announces >= 2){
					zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
				}
				if(!g_announce_valid[id]){
					zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
				}
        			return PLUGIN_HANDLED
			}

			// Proceed
			new icoins = g_coins[id] - zc_coins_prices[18];
			if(icoins < 0) {
				zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
				return PLUGIN_HANDLED
			}

			// Check limit
			new limit, data[32], rest_limit, counter, save[16]
			rest_limit = zc_coins_items_limit[15]
			if(limiter_get_data(g_limiter_map, "LNJ", g_playername[id], data, 15))
			{
				limit = str_to_num(data)
			}
			if (limit < rest_limit)
			{
				// Get item
				if(get_playersnum() > 4) 
				{
					zp_colored_print(0, "^x04[ZC]^x01 The player^x04 %s^x01 has bought^x04 LNJ Mode !!", g_playername[id])
					set_task(3.0, "removeannounce", id)
					g_coins[id] = icoins
					
					g_coins_modes_limit += 1
					static ip[16];
					get_user_ip(id, ip, charsmax(ip), 1);
					log_to_file("zc_coins.log", "[LNJ] [%s] [%s] [%s]", g_playername[id], ip, mapname);
					client_cmd (id, "spk %s", BGH_S)
					command_lnj(id)
				}else{
					zp_colored_print(id, "^x04[ZC]^x01 To buy it must be online^x04 4^x01 players.")
					return PLUGIN_HANDLED
				}

				// Save limit
				counter = limit+1
				num_to_str(counter, save, sizeof(save) - 1)
    				limiter_set_data(g_limiter_map, "LNJ", g_playername[id], save)		
			}else {
				zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
				return PLUGIN_HANDLED
			}
		}
		case 20: {
    			if (native_has_round_started()){
				zp_colored_print(id, "^x04[ZC]^x01 You can buy mode only on roundstart.")
        			return PLUGIN_HANDLED
			}

    			if (g_event){
				zp_colored_print(id, "^x04[ZC]^x01 The event is^x04 ON^x01. You can use this item next map, when the event will be^x03 OFF.")
        			return PLUGIN_HANDLED
			}

			if (!allowed_swarm()){
				zp_colored_print(id, "^x04[ZC]^x01 This mode isn't^x04 allowed^x01 right now. Please try again.")
        			return PLUGIN_HANDLED
			}
	
			if (g_lastmode != MODE_INFECTION) {
				zp_colored_print(id, "^x04[ZC]^x01 You can't buy a mode because one was played^x04 recently!");
        			return PLUGIN_HANDLED
			}

			if (g_count_announces >= 2 || !g_announce_valid[id]) 
			{
				if(g_count_announces >= 2){
					zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
				}
				if(!g_announce_valid[id]){
					zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
				}
        			return PLUGIN_HANDLED
			}

			// Proceed
			new icoins = g_coins[id] - zc_coins_prices[19];
			if(icoins < 0) {
				zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
				return PLUGIN_HANDLED
			}

			// Check limit
			new limit, data[32], rest_limit, counter, save[16]
			rest_limit = zc_coins_items_limit[14]
			if(limiter_get_data(g_limiter_map, "Swarm", g_playername[id], data, 15))
			{
				limit = str_to_num(data)
			}
			if (limit < rest_limit)
			{
				// Get item
				if(get_playersnum() > 4) {
					zp_colored_print(0, "^x04[ZC]^x01 The player^x04 %s^x01 has bought^x04 Swarm Mode !!", g_playername[id])
					set_task(3.0, "removeannounce", id)
					g_coins[id] = icoins
					
					g_coins_modes_limit += 1
					static ip[16];
					get_user_ip(id, ip, charsmax(ip), 1);
					log_to_file("zc_coins.log", "[SWARM] [%s] [%s] [%s]", g_playername[id], ip, mapname);
					client_cmd (id, "spk %s", BGH_S)
					command_swarm(id)
				}else{
					zp_colored_print(id, "^x04[ZC]^x01 To buy it must be online^x04 4^x01 players.")
					return PLUGIN_HANDLED
				}

				// Save limit
				counter = limit+1
				num_to_str(counter, save, sizeof(save) - 1)
    				limiter_set_data(g_limiter_map, "Swarm", g_playername[id], save)		
			}else {
				zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
				return PLUGIN_HANDLED
			}
		}
		case 21: {
    			if (native_has_round_started()){
				zp_colored_print(id, "^x04[ZC]^x01 You can buy mode only on roundstart.")
        			return PLUGIN_HANDLED
			}

    			if (g_event){
				zp_colored_print(id, "^x04[ZC]^x01 The event is^x04 ON^x01. You can use this item next map, when the event will be^x03 OFF.")
        			return PLUGIN_HANDLED
			}

			if (!allowed_plague()){
				zp_colored_print(id, "^x04[ZC]^x01 This mode isn't^x04 allowed^x01 right now. Please try again.")
        			return PLUGIN_HANDLED
			}
	
			if (g_lastmode != MODE_INFECTION) {
				zp_colored_print(id, "^x04[ZC]^x01 You can't buy a mode because one was played^x04 recently!");
        			return PLUGIN_HANDLED
			}

			if (g_count_announces >= 2 || !g_announce_valid[id]) 
			{
				if(g_count_announces >= 2){
					zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
				}
				if(!g_announce_valid[id]){
					zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
				}
        			return PLUGIN_HANDLED
			}

			// Proceed
			new icoins = g_coins[id] - zc_coins_prices[20];
			if(icoins < 0) {
				zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
				return PLUGIN_HANDLED
			}

			// Check limit
			new limit, data[32], rest_limit, counter, save[16]
			rest_limit = zc_coins_items_limit[13]
			if(limiter_get_data(g_limiter_map, "Plague", g_playername[id], data, 15))
			{
				limit = str_to_num(data)
			}
			if (limit < rest_limit)
			{
				// Get item
				if(get_playersnum() > 4) {
					zp_colored_print(0, "^x04[ZC]^x01 The player^x04 %s^x01 has bought^x04 Plague !!", g_playername[id])
					set_task(3.0, "removeannounce", id)
					g_coins[id] = icoins
					
					g_coins_modes_limit += 1
					static ip[16];
					get_user_ip(id, ip, charsmax(ip), 1);
					log_to_file("zc_coins.log", "[PLAGUE] [%s] [%s] [%s]", g_playername[id], ip, mapname);
					client_cmd (id, "spk %s", BGH_S)
					command_plague(id)
				}else {
					zp_colored_print(id, "^x04[ZC]^x01 To buy it must be online^x04 4^x01 players.")
					return PLUGIN_HANDLED
				}

				// Save limit
				counter = limit+1
				num_to_str(counter, save, sizeof(save) - 1)
    				limiter_set_data(g_limiter_map, "Plague", g_playername[id], save)		
			}else {
				zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
				return PLUGIN_HANDLED
			}
		}
		case 22: {
    			if (native_has_round_started()){
				zp_colored_print(id, "^x04[ZC]^x01 You can buy mode only on roundstart.")
        			return PLUGIN_HANDLED
			}

    			if (g_event){
				zp_colored_print(id, "^x04[ZC]^x01 The event is^x04 ON^x01. You can use this item next map, when the event will be^x03 OFF.")
        			return PLUGIN_HANDLED
			}

			if (!allowed_guardians()){
				zp_colored_print(id, "^x04[ZC]^x01 This mode isn't^x04 allowed^x01 right now. Please try again.")
        			return PLUGIN_HANDLED
			}
	
			if (g_lastmode != MODE_INFECTION) {
				zp_colored_print(id, "^x04[ZC]^x01 You can't buy a mode because one was played^x04 recently!");
        			return PLUGIN_HANDLED
			}

			if (g_count_announces >= 2 || !g_announce_valid[id]) 
			{
				if(g_count_announces >= 2){
					zp_colored_print(id, "^x04[ZC]^x01 You have to wait^x03 %d^x04 rounds.", g_count_announces-1)
				}
				if(!g_announce_valid[id]){
					zp_colored_print(id, "^x04[ZC]^x01 You have to^x04 announce^x01 the mode.")
				}
        			return PLUGIN_HANDLED
			}

			// Proceed
			new icoins = g_coins[id] - zc_coins_prices[22];
			if(icoins < 0) {
				zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
				return PLUGIN_HANDLED
			}

			// Check limit
			new limit, data[32], rest_limit, counter, save[16]
			rest_limit = zc_coins_items_limit[18]
			if(limiter_get_data(g_limiter_map, "Guardians", g_playername[id], data, 15))
			{
				limit = str_to_num(data)
			}
			if (limit < rest_limit)
			{
				// Get item
				if(get_playersnum() > 4) {
					zp_colored_print(0, "^x04[ZC]^x01 The player^x04 %s^x01 has bought^x04 Guardians Mode !!", g_playername[id])
					set_task(3.0, "removeannounce", id)
					g_coins[id] = icoins
					
					g_coins_modes_limit += 1
					static ip[16];
					get_user_ip(id, ip, charsmax(ip), 1);
					log_to_file("zc_coins.log", "[GUARDIANS] [%s] [%s] [%s]", g_playername[id], ip, mapname);
					client_cmd (id, "spk %s", BGH_S)
					command_guardians(id)
				}else {
					zp_colored_print(id, "^x04[ZC]^x01 To buy it must be online^x04 4^x01 players.")
					return PLUGIN_HANDLED
				}

				// Save limit
				counter = limit+1
				num_to_str(counter, save, sizeof(save) - 1)
    				limiter_set_data(g_limiter_map, "Guardians", g_playername[id], save)		
			}else {
				zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
				return PLUGIN_HANDLED
			}
		}
	}
	menu_destroy(menu)
    	return PLUGIN_HANDLED
}

/*================================================================================
 [Nemesis Coins]
=================================================================================*/
public nemesis_coins(id)
{
	new menu = menu_create("\rCoins Shop:", "menu_handler_nemesis");
	menu_additem(menu, "\wMake me Nemesis", "", 0);
	menu_additem(menu, "\wMake somebody else Nemesis", "", 0);
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
}

public menu_handler_nemesis(id, menu, item)
{
	switch(item)	
	{
		case 0: makeme_nemesis(id)
		case 1: makese_nemesis(id)
	}
	menu_destroy(menu);
}

public makeme_nemesis(id)
{
	// Check availability
	if (!allowed_nemesis(id)){
		zp_colored_print(id, "^x04[ZC]^x01 This mode isn't^x04 allowed^x01 right now. Please try again.")
        	return PLUGIN_HANDLED
	}

	// Proceed
	new icoins = g_coins[id] - zc_coins_prices[14];
	if(icoins < 0) {
		zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
		return PLUGIN_HANDLED
	}

	// Check limit
	new limit, data[32], rest_limit, counter, save[16]
	rest_limit = zc_coins_items_limit[4]
	if(limiter_get_data(g_limiter_map, "Nemesis", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
	}
	if (limit < rest_limit)
	{
		// Get item
		zp_colored_print(0, "^x04[ZC]^x01 The player^x04 %s^x01 has bought^x04 Nemesis !!", g_playername[id])
		set_task(3.0, "removeannounce", id)
		g_coins[id] = icoins
		
		g_coins_modes_limit += 1
		static ip[16];
		get_user_ip(id, ip, charsmax(ip), 1);
		log_to_file("zc_coins.log", "[NEMESIS] [%s] [%s] [%s]", g_playername[id], ip, mapname);
		client_cmd (id, "spk %s", BGH_S)
		native_make_user_nemesis(id);

		// Save limit
		counter = limit+1
		num_to_str(counter, save, sizeof(save) - 1)
    		limiter_set_data(g_limiter_map, "Nemesis", g_playername[id], save)		
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public makese_nemesis(id)
{
    	new menu = menu_create("\wChose \ythe player \wbelow:", "makese_handler_nemesis");
    	new players[32], pnum, tempid;
    	new szUserId[32];
    	get_players(players, pnum, "a")
    	for (new i; i<pnum; i++) {
        	tempid = players[i];
        	formatex(szUserId, charsmax(szUserId), "%d", get_user_userid(tempid));
        	menu_additem (menu, g_playername[tempid], szUserId, 0);
    	}
    	menu_display(id, menu, 0);
}

public makese_handler_nemesis(id, menu, item)
{
    	if (item == MENU_EXIT) {
        	menu_destroy(menu);
        	return PLUGIN_HANDLED
    	}
    	new szData[6], szName[64];
    	new item_access, item_callback;
    	menu_item_getinfo(menu, item, item_access, szData, charsmax(szData), szName, charsmax(szName), item_callback);
    	new userid = str_to_num(szData);
    	new player = find_player("k", userid);

	// Check availability
	if (!allowed_nemesis(player)){
		zp_colored_print(id, "^x04[ZC]^x01 This mode isn't^x04 allowed^x01 right now. Please try again.")
        	return PLUGIN_HANDLED
	}

	// Proceed
	new icoins = g_coins[id] - zc_coins_prices[14];
	if(icoins < 0) {
		zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
		return PLUGIN_HANDLED
	}

	// Check limit
	new limit, data[32], rest_limit, counter, save[16]
	rest_limit = zc_coins_items_limit[4]
	if(limiter_get_data(g_limiter_map, "Nemesis", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
	}
	if (limit < rest_limit)
	{
		// Get item
		zp_colored_print(0, "^x04[ZC]^x01 Player^x04 %s^x01 makes^x04 %s^x01 a^x03 Nemesis !", g_playername[id], g_playername[player])
		set_task(3.0, "removeannounce", id)
		g_coins[id] = icoins
		
		g_coins_modes_limit += 1
		static ipa[16], ipb[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		get_user_ip(player, ipb, charsmax(ipb), 1);
		log_to_file("zc_coins.log", "[NEMESIS] [%s - %s]  [%s - %s] [%s]", g_playername[id], ipa, g_playername[player], ipb, mapname);
		client_cmd (id, "spk %s", BGH_S)
		native_make_user_nemesis(player);

		// Save limit
		counter = limit+1
		num_to_str(counter, save, sizeof(save) - 1)
    		limiter_set_data(g_limiter_map, "Nemesis", g_playername[id], save)		
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
		return PLUGIN_HANDLED
	}

	// Destroy menu
    	menu_destroy(menu);
	return PLUGIN_HANDLED
}

/*================================================================================
 [Survivor Coins]
=================================================================================*/
public survivor_coins(id)
{
	new menu = menu_create("\rCoins Shop:", "menu_handler_survivor");
	menu_additem(menu, "\wMake me survivor", "", 0);
	menu_additem(menu, "\wMake somebody else survivor", "", 0);
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
}

public menu_handler_survivor(id, menu, item)
{
	switch(item)	
	{
		case 0: makeme_survivor(id)
		case 1: makese_survivor(id)
	}
	menu_destroy(menu);
}

public makeme_survivor(id)
{
	// Check availability
	if (!allowed_survivor(id)){
		zp_colored_print(id, "^x04[ZC]^x01 This mode isn't^x04 allowed^x01 right now. Please try again.")
        	return PLUGIN_HANDLED
	}
	// Proceed
	new icoins = g_coins[id] - zc_coins_prices[10];
	if(icoins < 0) {
		zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
		return PLUGIN_HANDLED
	}

	// Check limit
	new limit, data[32], rest_limit, counter, save[16]
	rest_limit = zc_coins_items_limit[3]
	if(limiter_get_data(g_limiter_map, "Survivor", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
	}
	if (limit < rest_limit)
	{
		// Get item
		zp_colored_print(0, "^x04[ZC]^x01 The player^x04 %s^x01 has bought^x04 Survivor !!", g_playername[id])
		set_task(3.0, "removeannounce", id)
		g_coins[id] = icoins
		
		g_coins_modes_limit += 1
		static ip[16];
		get_user_ip(id, ip, charsmax(ip), 1);
		log_to_file("zc_coins.log", "[SURVIVOR] [%s] [%s] [%s]", g_playername[id], ip, mapname);
		client_cmd (id, "spk %s", BGH_S)
		native_make_user_survivor(id);

		// Save limit
		counter = limit+1
		num_to_str(counter, save, sizeof(save) - 1)
    		limiter_set_data(g_limiter_map, "Survivor", g_playername[id], save)		
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public makese_survivor(id)
{
    	new menu = menu_create("\wChose \ythe player \wbelow:", "makese_handler_survivor");
    	new players[32], pnum, tempid;
    	new szUserId[32];
    	get_players(players, pnum, "a")
    	for (new i; i<pnum; i++) {
        	tempid = players[i];
        	formatex(szUserId, charsmax(szUserId), "%d", get_user_userid(tempid));
        	menu_additem (menu, g_playername[tempid], szUserId, 0);
    	}
    	menu_display(id, menu, 0);
}

public makese_handler_survivor(id, menu, item)
{
    	if (item == MENU_EXIT) {
        	menu_destroy(menu);
        	return PLUGIN_HANDLED
    	}
    	new szData[6], szName[64];
    	new item_access, item_callback;
    	menu_item_getinfo(menu, item, item_access, szData, charsmax(szData), szName, charsmax(szName), item_callback);
    	new userid = str_to_num(szData);
    	new player = find_player("k", userid);

	// Check availability
	if (!allowed_survivor(player)){
		zp_colored_print(id, "^x04[ZC]^x01 This mode isn't^x04 allowed^x01 right now. Please try again.")
        	return PLUGIN_HANDLED
	}
	// Proceed
	new icoins = g_coins[id] - zc_coins_prices[10];
	if(icoins < 0) {
		zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
		return PLUGIN_HANDLED
	}

	// Check limit
	new limit, data[32], rest_limit, counter, save[16]
	rest_limit = zc_coins_items_limit[3]
	if(limiter_get_data(g_limiter_map, "Survivor", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
	}
	if (limit < rest_limit)
	{
		// Get item
		zp_colored_print(0, "^x04[ZC]^x01 Player^x04 %s^x01 makes^x04 %s^x01 a^x03 Survivor !", g_playername[id], g_playername[player])
		set_task(3.0, "removeannounce", id)
		g_coins[id] = icoins
		
		g_coins_modes_limit += 1
		static ipa[16], ipb[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		get_user_ip(player, ipb, charsmax(ipb), 1);
		log_to_file("zc_coins.log", "[SURVIVOR] [%s - %s]  [%s - %s] [%s]", g_playername[id], ipa, g_playername[player], ipb, mapname);
		client_cmd (id, "spk %s", BGH_S)
		native_make_user_survivor(player);

		// Save limit
		counter = limit+1
		num_to_str(counter, save, sizeof(save) - 1)
    		limiter_set_data(g_limiter_map, "Survivor", g_playername[id], save)		
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
		return PLUGIN_HANDLED
	}

	// Destroy menu
    	menu_destroy(menu);
	return PLUGIN_HANDLED
}

/*================================================================================
 [Sniper Coins]
=================================================================================*/
public sniper_coins(id)
{
	new menu = menu_create("\rCoins Shop:", "menu_handler_sniper");
	menu_additem(menu, "\wMake me Sniper", "", 0);
	menu_additem(menu, "\wMake somebody else sniper", "", 0);
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
}

public menu_handler_sniper(id, menu, item)
{
	switch(item)	
	{
		case 0: makeme_sniper(id)
		case 1: makese_sniper(id)
	}
	menu_destroy(menu);
}

public makeme_sniper(id)
{
	// Check availability
	if (!allowed_sniper(id)){
		zp_colored_print(id, "^x04[ZC]^x01 This mode isn't^x04 allowed^x01 right now. Please try again.")
        	return PLUGIN_HANDLED
	}
	
	// Proceed
	new icoins = g_coins[id] - zc_coins_prices[9];
	if(icoins < 0) {
		zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
		return PLUGIN_HANDLED
	}

	// Check limit
	new limit, data[32], rest_limit, counter, save[16]
	rest_limit = zc_coins_items_limit[5]
	if(limiter_get_data(g_limiter_map, "Sniper", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
	}
	if (limit < rest_limit)
	{
		// Get item
		zp_colored_print(0, "^x04[ZC]^x01 The player^x04 %s^x01 has bought^x04 Sniper !!", g_playername[id])
		set_task(3.0, "removeannounce", id)
		g_coins[id] = icoins
		g_coins_modes_limit += 1
		static ip[16];
		get_user_ip(id, ip, charsmax(ip), 1);
		log_to_file("zc_coins.log", "[SNIPER] [%s] [%s] [%s]", g_playername[id], ip, mapname);
		client_cmd (id, "spk %s", BGH_S)
		native_make_user_sniper(id);

		// Save limit
		counter = limit+1
		num_to_str(counter, save, sizeof(save) - 1)
    		limiter_set_data(g_limiter_map, "Sniper", g_playername[id], save)		
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public makese_sniper(id)
{
    	new menu = menu_create("\wChose \ythe player \wbelow:", "makese_handler_sniper");
    	new players[32], pnum, tempid;
    	new szUserId[32];
    	get_players(players, pnum, "a")
    	for (new i; i<pnum; i++) {
        	tempid = players[i];
        	formatex(szUserId, charsmax(szUserId), "%d", get_user_userid(tempid));
        	menu_additem (menu, g_playername[tempid], szUserId, 0);
    	}
    	menu_display(id, menu, 0);
}

public makese_handler_sniper(id, menu, item)
{
    	if (item == MENU_EXIT) {
        	menu_destroy(menu);
        	return PLUGIN_HANDLED
    	}
    	new szData[6], szName[64];
    	new item_access, item_callback;
    	menu_item_getinfo(menu, item, item_access, szData, charsmax(szData), szName, charsmax(szName), item_callback);
    	new userid = str_to_num(szData);
    	new player = find_player("k", userid);

	// Check availability
	if (!allowed_sniper(player)){
		zp_colored_print(id, "^x04[ZC]^x01 This mode isn't^x04 allowed^x01 right now. Please try again.")
        	return PLUGIN_HANDLED
	}

	// Proceed
	new icoins = g_coins[id] - zc_coins_prices[9];
	if(icoins < 0) {
		zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
		return PLUGIN_HANDLED
	}

	// Check limit
	new limit, data[32], rest_limit, counter, save[16]
	rest_limit = zc_coins_items_limit[5]
	if(limiter_get_data(g_limiter_map, "Sniper", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
	}
	if (limit < rest_limit)
	{
		// Get item
		zp_colored_print(0, "^x04[ZC]^x01 Player^x04 %s^x01 makes^x04 %s^x01 a^x03 Sniper !", g_playername[id], g_playername[player])
		set_task(3.0, "removeannounce", id)
		g_coins[id] = icoins
		g_coins_modes_limit += 1
		static ipa[16], ipb[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		get_user_ip(player, ipb, charsmax(ipb), 1);
		log_to_file("zc_coins.log", "[SNIPER] [%s - %s]  [%s - %s] [%s]", g_playername[id], ipa, g_playername[player], ipb, mapname);
		client_cmd (id, "spk %s", BGH_S)
		native_make_user_sniper(player);

		// Save limit
		counter = limit+1
		num_to_str(counter, save, sizeof(save) - 1)
    		limiter_set_data(g_limiter_map, "Sniper", g_playername[id], save)		
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
		return PLUGIN_HANDLED
	}

	// Destroy menu
    	menu_destroy(menu);
	return PLUGIN_HANDLED
}

/*================================================================================
 [Assassin Coins]
=================================================================================*/
public assassin_coins(id)
{
	new menu = menu_create("\rCoins Shop:", "menu_handler_assassin");
	menu_additem(menu, "\wMake me assassin", "", 0);
	menu_additem(menu, "\wMake somebody else assassin", "", 0);
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
}

public menu_handler_assassin(id, menu, item)
{
	switch(item)	
	{
		case 0: makeme_assassin(id)
		case 1: makese_assassin(id)

	}
	menu_destroy(menu);
}

public makeme_assassin(id)
{
	// Check availability
	if (!allowed_assassin(id)){
		zp_colored_print(id, "^x04[ZC]^x01 This mode isn't^x04 allowed^x01 right now. Please try again.")
        	return PLUGIN_HANDLED
	}

	// Proceed
	new icoins = g_coins[id] - zc_coins_prices[13];
	if(icoins < 0) {
		zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
		return PLUGIN_HANDLED
	}

	// Check limit
	new limit, data[32], rest_limit, counter, save[16]
	rest_limit = zc_coins_items_limit[6]
	if(limiter_get_data(g_limiter_map, "Assassin", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
	}
	if (limit < rest_limit)
	{
		// Get item
		zp_colored_print(0, "^x04[ZC]^x01 The player^x04 %s^x01 has bought^x04 Assassin !!", g_playername[id])
		set_task(3.0, "removeannounce", id)
		g_coins[id] = icoins
		g_coins_modes_limit += 1
		static ip[16];
		get_user_ip(id, ip, charsmax(ip), 1);
		log_to_file("zc_coins.log", "[ASSASSIN] [%s] [%s] [%s]", g_playername[id], ip, mapname);
		client_cmd (id, "spk %s", BGH_S)
		native_make_user_assassin(id);

		// Save limit
		counter = limit+1
		num_to_str(counter, save, sizeof(save) - 1)
    		limiter_set_data(g_limiter_map, "Assassin", g_playername[id], save)		
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public makese_assassin(id)
{
    	new menu = menu_create("\wChose \ythe player \wbelow:", "makese_handler_assassin");
    	new players[32], pnum, tempid;
    	new szUserId[32];
    	get_players(players, pnum, "a")
    	for (new i; i<pnum; i++) {
        	tempid = players[i];
        	formatex(szUserId, charsmax(szUserId), "%d", get_user_userid(tempid));
        	menu_additem (menu, g_playername[tempid], szUserId, 0);
    	}
    	menu_display(id, menu, 0);
}

public makese_handler_assassin(id, menu, item)
{
    	if (item == MENU_EXIT) {
        	menu_destroy(menu);
        	return PLUGIN_HANDLED
    	}
    	new szData[6], szName[64];
    	new item_access, item_callback;
    	menu_item_getinfo(menu, item, item_access, szData, charsmax(szData), szName, charsmax(szName), item_callback);
    	new userid = str_to_num(szData);
    	new player = find_player("k", userid);

	// Check availability
	if (!allowed_assassin(player)){
		zp_colored_print(id, "^x04[ZC]^x01 This mode isn't^x04 allowed^x01 right now. Please try again.")
        	return PLUGIN_HANDLED
	}

	// Proceed
	new icoins = g_coins[id] - zc_coins_prices[13];
	if(icoins < 0) {
		zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
		return PLUGIN_HANDLED
	}

	// Check limit
	new limit, data[32], rest_limit, counter, save[16]
	rest_limit = zc_coins_items_limit[6]
	if(limiter_get_data(g_limiter_map, "Assassin", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
	}
	if (limit < rest_limit)
	{
		// Get item
		zp_colored_print(0, "^x04[ZC]^x01 Player^x04 %s^x01 makes^x04 %s^x01 a^x03 Assassin !", g_playername[id], g_playername[player])
		set_task(3.0, "removeannounce", id)
		g_coins[id] = icoins
		g_coins_modes_limit += 1
		static ipa[16], ipb[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		get_user_ip(player, ipb, charsmax(ipb), 1);
		log_to_file("zc_coins.log", "[ASSASSIN] [%s - %s]  [%s - %s] [%s]", g_playername[id], ipa, g_playername[player], ipb, mapname);
		client_cmd (id, "spk %s", BGH_S)
		native_make_user_assassin(player);

		// Save limit
		counter = limit+1
		num_to_str(counter, save, sizeof(save) - 1)
    		limiter_set_data(g_limiter_map, "Assassin", g_playername[id], save)		
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
		return PLUGIN_HANDLED
	}

	// Destroy menu
    	menu_destroy(menu);
	return PLUGIN_HANDLED
}

/*================================================================================
 [Genesys Coins]
=================================================================================*/
public genesys_coins(id)
{
	new menu = menu_create("\rCoins Shop:", "menu_handler_genesys");
	menu_additem(menu, "\wMake me genesys", "", 0);
	menu_additem(menu, "\wMake somebody else genesys", "", 0);
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
}

public menu_handler_genesys(id, menu, item)
{
	switch(item)	
	{
		case 0: makeme_genesys(id)
		case 1: makese_genesys(id)

	}
	menu_destroy(menu);
}

public makeme_genesys(id)
{
	// Check availability
	if (!allowed_genesys(id)){
		zp_colored_print(id, "^x04[ZC]^x01 This mode isn't^x04 allowed^x01 right now. Please try again.")
        	return PLUGIN_HANDLED
	}

	// Proceed
	new icoins = g_coins[id] - zc_coins_prices[11];
	if(icoins < 0) {
		zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
		return PLUGIN_HANDLED
	}

	// Check limit
	new limit, data[32], rest_limit, counter, save[16]
	rest_limit = zc_coins_items_limit[8]
	if(limiter_get_data(g_limiter_map, "Genesys", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
	}
	if (limit < rest_limit)
	{
		// Get item
		zp_colored_print(0, "^x04[ZC]^x01 The player^x04 %s^x01 has bought^x04 Genesys !!", g_playername[id])
		set_task(3.0, "removeannounce", id)
		g_coins[id] = icoins
		g_coins_modes_limit += 1
		static ip[16];
		get_user_ip(id, ip, charsmax(ip), 1);
		log_to_file("zc_coins.log", "[GENESYS] [%s] [%s] [%s]", g_playername[id], ip, mapname);
		client_cmd (id, "spk %s", BGH_S)
		native_make_user_genesys(id);

		// Save limit
		counter = limit+1
		num_to_str(counter, save, sizeof(save) - 1)
    		limiter_set_data(g_limiter_map, "Genesys", g_playername[id], save)		
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public makese_genesys(id)
{
    	new menu = menu_create("\wChose \ythe player \wbelow:", "makese_handler_genesys");
    	new players[32], pnum, tempid;
    	new szUserId[32];
    	get_players(players, pnum, "a")
    	for (new i; i<pnum; i++) {
        	tempid = players[i];
        	formatex(szUserId, charsmax(szUserId), "%d", get_user_userid(tempid));
        	menu_additem (menu, g_playername[tempid], szUserId, 0);
    	}
    	menu_display(id, menu, 0);
}

public makese_handler_genesys(id, menu, item)
{
    	if (item == MENU_EXIT) {
        	menu_destroy(menu);
        	return PLUGIN_HANDLED
    	}
    	new szData[6], szName[64];
    	new item_access, item_callback;
    	menu_item_getinfo(menu, item, item_access, szData, charsmax(szData), szName, charsmax(szName), item_callback);
    	new userid = str_to_num(szData);
    	new player = find_player("k", userid);

	// Check availability
	if (!allowed_genesys(player)){
		zp_colored_print(id, "^x04[ZC]^x01 This mode isn't^x04 allowed^x01 right now. Please try again.")
        	return PLUGIN_HANDLED
	}

	// Proceed
	new icoins = g_coins[id] - zc_coins_prices[11];
	if(icoins < 0) {
		zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
		return PLUGIN_HANDLED
	}

	// Check limit
	new limit, data[32], rest_limit, counter, save[16]
	rest_limit = zc_coins_items_limit[8]
	if(limiter_get_data(g_limiter_map, "Genesys", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
	}
	if (limit < rest_limit)
	{
		// Get item
		zp_colored_print(0, "^x04[ZC]^x01 Player^x04 %s^x01 makes^x04 %s^x01 a^x03 Genesys !", g_playername[id], g_playername[player])
		set_task(3.0, "removeannounce", id)
		g_coins[id] = icoins
		g_coins_modes_limit += 1
		static ipa[16], ipb[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		get_user_ip(player, ipb, charsmax(ipb), 1);
		log_to_file("zc_coins.log", "[GENESYS] [%s - %s]  [%s - %s] [%s]", g_playername[id], ipa, g_playername[player], ipb, mapname);
		client_cmd (id, "spk %s", BGH_S)
		native_make_user_genesys(player);

		// Save limit
		counter = limit+1
		num_to_str(counter, save, sizeof(save) - 1)
    		limiter_set_data(g_limiter_map, "Genesys", g_playername[id], save)		
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
		return PLUGIN_HANDLED
	}

	// Destroy menu
    	menu_destroy(menu);
	return PLUGIN_HANDLED
}

/*================================================================================
 [Flamer Coins]
=================================================================================*/
public flamer_coins(id)
{
	new menu = menu_create("\rCoins Shop:", "menu_handler_flamer");
	menu_additem(menu, "\wMake me flamer", "", 0);
	menu_additem(menu, "\wMake somebody else flamer", "", 0);
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
}

public menu_handler_flamer(id, menu, item)
{
	switch(item)	
	{
		case 0: makeme_flamer(id)
		case 1: makese_flamer(id)

	}
	menu_destroy(menu);
}

public makeme_flamer(id)
{
	// Check availability
	if (!allowed_flamer(id)){
		zp_colored_print(id, "^x04[ZC]^x01 This mode isn't^x04 allowed^x01 right now. Please try again.")
        	return PLUGIN_HANDLED
	}

	// Proceed
	new icoins = g_coins[id] - zc_coins_prices[12];
	if(icoins < 0) {
		zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
		return PLUGIN_HANDLED
	}

	// Check limit
	new limit, data[32], rest_limit, counter, save[16]
	rest_limit = zc_coins_items_limit[7]
	if(limiter_get_data(g_limiter_map, "Flamer", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
	}
	if (limit < rest_limit)
	{
		// Get item
		zp_colored_print(0, "^x04[ZC]^x01 The player^x04 %s^x01 has bought^x04 Flamer !!", g_playername[id])
		set_task(3.0, "removeannounce", id)
		g_coins[id] = icoins
		g_coins_modes_limit += 1
		static ip[16];
		get_user_ip(id, ip, charsmax(ip), 1);
		log_to_file("zc_coins.log", "[FLAMER] [%s] [%s] [%s]", g_playername[id], ip, mapname);
		client_cmd (id, "spk %s", BGH_S)
		native_make_user_flamer(id);

		// Save limit
		counter = limit+1
		num_to_str(counter, save, sizeof(save) - 1)
    		limiter_set_data(g_limiter_map, "Flamer", g_playername[id], save)		
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public makese_flamer(id)
{
    	new menu = menu_create("\wChose \ythe player \wbelow:", "makese_handler_flamer");
    	new players[32], pnum, tempid;
    	new szUserId[32];
    	get_players(players, pnum, "a")
    	for (new i; i<pnum; i++) {
        	tempid = players[i];
        	formatex(szUserId, charsmax(szUserId), "%d", get_user_userid(tempid));
        	menu_additem (menu, g_playername[tempid], szUserId, 0);
    	}
    	menu_display(id, menu, 0);
}

public makese_handler_flamer(id, menu, item)
{
    	if (item == MENU_EXIT) {
        	menu_destroy(menu);
        	return PLUGIN_HANDLED
    	}
    	new szData[6], szName[64];
    	new item_access, item_callback;
    	menu_item_getinfo(menu, item, item_access, szData, charsmax(szData), szName, charsmax(szName), item_callback);
    	new userid = str_to_num(szData);
    	new player = find_player("k", userid);

	// Check availability
	if (!allowed_flamer(player)){
		zp_colored_print(id, "^x04[ZC]^x01 This mode isn't^x04 allowed^x01 right now. Please try again.")
        	return PLUGIN_HANDLED
	}

	// Proceed
	new icoins = g_coins[id] - zc_coins_prices[12];
	if(icoins < 0) {
		zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
		return PLUGIN_HANDLED
	}

	// Check limit
	new limit, data[32], rest_limit, counter, save[16]
	rest_limit = zc_coins_items_limit[7]
	if(limiter_get_data(g_limiter_map, "Flamer", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
	}
	if (limit < rest_limit)
	{
		// Get item
		zp_colored_print(0, "^x04[ZC]^x01 Player^x04 %s^x01 makes^x04 %s^x01 a^x03 Flamer !", g_playername[id], g_playername[player])
		set_task(3.0, "removeannounce", id)
		g_coins[id] = icoins
		g_coins_modes_limit += 1
		static ipa[16], ipb[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		get_user_ip(player, ipb, charsmax(ipb), 1);
		log_to_file("zc_coins.log", "[FLAMER] [%s - %s]  [%s - %s] [%s]", g_playername[id], ipa, g_playername[player], ipb, mapname);
		client_cmd (id, "spk %s", BGH_S)
		native_make_user_flamer(player);

		// Save limit
		counter = limit+1
		num_to_str(counter, save, sizeof(save) - 1)
    		limiter_set_data(g_limiter_map, "Flamer", g_playername[id], save)		
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
		return PLUGIN_HANDLED
	}

	// Destroy menu
    	menu_destroy(menu);
	return PLUGIN_HANDLED
}

/*================================================================================
 [Oberon Coins]
=================================================================================*/
public oberon_coins(id)
{
	new menu = menu_create("\rCoins Shop:", "menu_handler_oberon");
	menu_additem(menu, "\wMake me oberon", "", 0);
	menu_additem(menu, "\wMake somebody else oberon", "", 0);
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
}

public menu_handler_oberon(id, menu, item)
{
	switch(item)	
	{
		case 0: makeme_oberon(id)
		case 1: makese_oberon(id)

	}
	menu_destroy(menu);
}

public makeme_oberon(id)
{
	// Check availability
	if (!allowed_oberon(id)){
		zp_colored_print(id, "^x04[ZC]^x01 This mode isn't^x04 allowed^x01 right now. Please try again.")
        	return PLUGIN_HANDLED
	}

	// Proceed
	new icoins = g_coins[id] - zc_coins_prices[15];
	if(icoins < 0) {
		zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
		return PLUGIN_HANDLED
	}

	// Check limit
	new limit, data[32], rest_limit, counter, save[16]
	rest_limit = zc_coins_items_limit[9]
	if(limiter_get_data(g_limiter_map, "Oberon", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
	}
	if (limit < rest_limit)
	{
		// Get item
		zp_colored_print(0, "^x04[ZC]^x01 The player^x04 %s^x01 has bought^x04 Oberon !!", g_playername[id])
		set_task(3.0, "removeannounce", id)
		g_coins[id] = icoins
		g_coins_modes_limit += 1
		static ip[16];
		get_user_ip(id, ip, charsmax(ip), 1);
		log_to_file("zc_coins.log", "[OBERON] [%s] [%s] [%s]", g_playername[id], ip, mapname);
		client_cmd (id, "spk %s", BGH_S)
		native_make_user_oberon(id);

		// Save limit
		counter = limit+1
		num_to_str(counter, save, sizeof(save) - 1)
    		limiter_set_data(g_limiter_map, "Oberon", g_playername[id], save)		
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public makese_oberon(id)
{
    	new menu = menu_create("\wChose \ythe player \wbelow:", "makese_handler_oberon");
    	new players[32], pnum, tempid;
    	new szUserId[32];
    	get_players(players, pnum, "a")
    	for (new i; i<pnum; i++) {
        	tempid = players[i];
        	formatex(szUserId, charsmax(szUserId), "%d", get_user_userid(tempid));
        	menu_additem (menu, g_playername[tempid], szUserId, 0);
    	}
    	menu_display(id, menu, 0);
}

public makese_handler_oberon(id, menu, item)
{
    	if (item == MENU_EXIT) {
        	menu_destroy(menu);
        	return PLUGIN_HANDLED
    	}
    	new szData[6], szName[64];
    	new item_access, item_callback;
    	menu_item_getinfo(menu, item, item_access, szData, charsmax(szData), szName, charsmax(szName), item_callback);
    	new userid = str_to_num(szData);
    	new player = find_player("k", userid);

	// Check availability
	if (!allowed_oberon(player)){
		zp_colored_print(id, "^x04[ZC]^x01 This mode isn't^x04 allowed^x01 right now. Please try again.")
        	return PLUGIN_HANDLED
	}

	// Proceed
	new icoins = g_coins[id] - zc_coins_prices[15];
	if(icoins < 0) {
		zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
		return PLUGIN_HANDLED
	}

	// Check limit
	new limit, data[32], rest_limit, counter, save[16]
	rest_limit = zc_coins_items_limit[9]
	if(limiter_get_data(g_limiter_map, "Oberon", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
	}
	if (limit < rest_limit)
	{
		// Get item
		zp_colored_print(0, "^x04[ZC]^x01 Player^x04 %s^x01 makes^x04 %s^x01 a^x03 Oberon !", g_playername[id], g_playername[player])
		set_task(3.0, "removeannounce", id)
		g_coins[id] = icoins
		g_coins_modes_limit += 1
		static ipa[16], ipb[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		get_user_ip(player, ipb, charsmax(ipb), 1);
		log_to_file("zc_coins.log", "[OBERON] [%s - %s]  [%s - %s] [%s]", g_playername[id], ipa, g_playername[player], ipb, mapname);
		client_cmd (id, "spk %s", BGH_S)
		native_make_user_oberon(player);

		// Save limit
		counter = limit+1
		num_to_str(counter, save, sizeof(save) - 1)
    		limiter_set_data(g_limiter_map, "Oberon", g_playername[id], save)		
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
		return PLUGIN_HANDLED
	}

	// Destroy menu
    	menu_destroy(menu);
	return PLUGIN_HANDLED
}

/*================================================================================
 [Dragon Coins]
=================================================================================*/
public dragon_coins(id)
{
	new menu = menu_create("\rCoins Shop:", "menu_handler_dragon");
	menu_additem(menu, "\wMake me dragon", "", 0);
	menu_additem(menu, "\wMake somebody else dragon", "", 0);
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
}

public menu_handler_dragon(id, menu, item)
{
	switch(item)	
	{
		case 0: makeme_dragon(id)
		case 1: makese_dragon(id)

	}
	menu_destroy(menu);
}

public makeme_dragon(id)
{
	// Check availability
	if (!allowed_dragon(id)){
		zp_colored_print(id, "^x04[ZC]^x01 This mode isn't^x04 allowed^x01 right now. Please try again.")
        	return PLUGIN_HANDLED
	}

	// Proceed
	new icoins = g_coins[id] - zc_coins_prices[17];
	if(icoins < 0) {
		zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
		return PLUGIN_HANDLED
	}

	// Check limit
	new limit, data[32], rest_limit, counter, save[16]
	rest_limit = zc_coins_items_limit[10]
	if(limiter_get_data(g_limiter_map, "Dragon", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
	}
	if (limit < rest_limit)
	{
		// Get item
		zp_colored_print(0, "^x04[ZC]^x01 The player^x04 %s^x01 has bought^x04 Dragon !!", g_playername[id])
		set_task(3.0, "removeannounce", id)
		g_coins[id] = icoins
		g_coins_modes_limit += 1
		static ip[16];
		get_user_ip(id, ip, charsmax(ip), 1);
		log_to_file("zc_coins.log", "DRAGON] [%s] [%s] [%s]", g_playername[id], ip, mapname);
		client_cmd (id, "spk %s", BGH_S)
		native_make_user_dragon(id);

		// Save limit
		counter = limit+1
		num_to_str(counter, save, sizeof(save) - 1)
    		limiter_set_data(g_limiter_map, "Dragon", g_playername[id], save)		
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public makese_dragon(id)
{
    	new menu = menu_create("\wChose \ythe player \wbelow:", "makese_handler_dragon");
    	new players[32], pnum, tempid;
    	new szUserId[32];
    	get_players(players, pnum, "a")
    	for (new i; i<pnum; i++) {
        	tempid = players[i];
        	formatex(szUserId, charsmax(szUserId), "%d", get_user_userid(tempid));
        	menu_additem (menu, g_playername[tempid], szUserId, 0);
    	}
    	menu_display(id, menu, 0);
}

public makese_handler_dragon(id, menu, item)
{
    	if (item == MENU_EXIT) {
        	menu_destroy(menu);
        	return PLUGIN_HANDLED
    	}
    	new szData[6], szName[64];
    	new item_access, item_callback;
    	menu_item_getinfo(menu, item, item_access, szData, charsmax(szData), szName, charsmax(szName), item_callback);
    	new userid = str_to_num(szData);
    	new player = find_player("k", userid);

	// Check availability
	if (!allowed_dragon(player)){
		zp_colored_print(id, "^x04[ZC]^x01 This mode isn't^x04 allowed^x01 right now. Please try again.")
        	return PLUGIN_HANDLED
	}

	// Proceed
	new icoins = g_coins[id] - zc_coins_prices[17];
	if(icoins < 0) {
		zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
		return PLUGIN_HANDLED
	}

	// Check limit
	new limit, data[32], rest_limit, counter, save[16]
	rest_limit = zc_coins_items_limit[10]
	if(limiter_get_data(g_limiter_map, "Dragon", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
	}
	if (limit < rest_limit)
	{
		// Get item
		zp_colored_print(0, "^x04[ZC]^x01 Player^x04 %s^x01 makes^x04 %s^x01 a^x03 Dragon !", g_playername[id], g_playername[player])
		set_task(3.0, "removeannounce", id)
		g_coins[id] = icoins
		g_coins_modes_limit += 1
		static ipa[16], ipb[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		get_user_ip(player, ipb, charsmax(ipb), 1);
		log_to_file("zc_coins.log", "[DRAGON] [%s - %s]  [%s - %s] [%s]", g_playername[id], ipa, g_playername[player], ipb, mapname);
		client_cmd (id, "spk %s", BGH_S)
		native_make_user_dragon(player);

		// Save limit
		counter = limit+1
		num_to_str(counter, save, sizeof(save) - 1)
    		limiter_set_data(g_limiter_map, "Dragon", g_playername[id], save)		
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
		return PLUGIN_HANDLED
	}

	// Destroy menu
    	menu_destroy(menu);
	return PLUGIN_HANDLED
}

/*================================================================================
 [Zadoc Coins]
=================================================================================*/
public zadoc_coins(id)
{
	new menu = menu_create("\rCoins Shop:", "menu_handler_zadoc");
	menu_additem(menu, "\wMake me zadoc", "", 0);
	menu_additem(menu, "\wMake somebody else zadoc", "", 0);
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
}

public menu_handler_zadoc(id, menu, item)
{
	switch(item)	
	{
		case 0: makeme_zadoc(id)
		case 1: makese_zadoc(id)

	}
	menu_destroy(menu);
}

public makeme_zadoc(id)
{
	// Check availability
	if (!allowed_zadoc(id)){
		zp_colored_print(id, "^x04[ZC]^x01 This mode isn't^x04 allowed^x01 right now. Please try again.")
        	return PLUGIN_HANDLED
	}

	// Proceed
	new icoins = g_coins[id] - zc_coins_prices[16];
	if(icoins < 0) {
		zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
		return PLUGIN_HANDLED
	}

	// Check limit
	new limit, data[32], rest_limit, counter, save[16]
	rest_limit = zc_coins_items_limit[11]
	if(limiter_get_data(g_limiter_map, "Zadoc", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
	}
	if (limit < rest_limit)
	{
		// Get item
		zp_colored_print(0, "^x04[ZC]^x01 The player^x04 %s^x01 has bought^x04 Zadoc !!", g_playername[id])
		set_task(3.0, "removeannounce", id)
		g_coins[id] = icoins
		g_coins_modes_limit += 1
		static ip[16];
		get_user_ip(id, ip, charsmax(ip), 1);
		log_to_file("zc_coins.log", "[ZADOC] [%s] [%s] [%s]", g_playername[id], ip, mapname);
		client_cmd (id, "spk %s", BGH_S)
		native_make_user_zadoc(id);

		// Save limit
		counter = limit+1
		num_to_str(counter, save, sizeof(save) - 1)
    		limiter_set_data(g_limiter_map, "Zadoc", g_playername[id], save)		
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public makese_zadoc(id)
{
    	new menu = menu_create("\wChose \ythe player \wbelow:", "makese_handler_zadoc");
    	new players[32], pnum, tempid;
    	new szUserId[32];
    	get_players(players, pnum, "a")
    	for (new i; i<pnum; i++) {
        	tempid = players[i];
        	formatex(szUserId, charsmax(szUserId), "%d", get_user_userid(tempid));
        	menu_additem (menu, g_playername[tempid], szUserId, 0);
    	}
    	menu_display(id, menu, 0);
}

public makese_handler_zadoc(id, menu, item)
{
    	if (item == MENU_EXIT) {
        	menu_destroy(menu);
        	return PLUGIN_HANDLED
    	}
    	new szData[6], szName[64];
    	new item_access, item_callback;
    	menu_item_getinfo(menu, item, item_access, szData, charsmax(szData), szName, charsmax(szName), item_callback);
    	new userid = str_to_num(szData);
    	new player = find_player("k", userid);

	// Check availability
	if (!allowed_zadoc(player)){
		zp_colored_print(id, "^x04[ZC]^x01 This mode isn't^x04 allowed^x01 right now. Please try again.")
        	return PLUGIN_HANDLED
	}

	// Proceed
	new icoins = g_coins[id] - zc_coins_prices[16];
	if(icoins < 0) {
		zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
		return PLUGIN_HANDLED
	}

	// Check limit
	new limit, data[32], rest_limit, counter, save[16]
	rest_limit = zc_coins_items_limit[11]
	if(limiter_get_data(g_limiter_map, "Zadoc", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
	}
	if (limit < rest_limit)
	{
		// Get item
		zp_colored_print(0, "^x04[ZC]^x01 Player^x04 %s^x01 makes^x04 %s^x01 a^x03 Zadoc !", g_playername[id], g_playername[player])
		set_task(3.0, "removeannounce", id)
		g_coins[id] = icoins
		g_coins_modes_limit += 1
		static ipa[16], ipb[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		get_user_ip(player, ipb, charsmax(ipb), 1);
		log_to_file("zc_coins.log", "[ZADOC] [%s - %s]  [%s - %s] [%s]", g_playername[id], ipa, g_playername[player], ipb, mapname);
		client_cmd (id, "spk %s", BGH_S)
		native_make_user_zadoc(player);

		// Save limit
		counter = limit+1
		num_to_str(counter, save, sizeof(save) - 1)
    		limiter_set_data(g_limiter_map, "Zadoc", g_playername[id], save)		
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
		return PLUGIN_HANDLED
	}

	// Destroy menu
    	menu_destroy(menu);
	return PLUGIN_HANDLED
}

/*================================================================================
 [Nighter Coins]
=================================================================================*/
public nighter_coins(id)
{
	new menu = menu_create("\rCoins Shop:", "menu_handler_nighter");
	menu_additem(menu, "\wMake me nighter", "", 0);
	menu_additem(menu, "\wMake somebody else nighter", "", 0);
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
}

public menu_handler_nighter(id, menu, item)
{
	switch(item)	
	{
		case 0: makeme_nighter(id)
		case 1: makese_nighter(id)

	}
	menu_destroy(menu);
}

public makeme_nighter(id)
{
	// Check availability
	if (!allowed_nighter(id)){
		zp_colored_print(id, "^x04[ZC]^x01 This mode isn't^x04 allowed^x01 right now. Please try again.")
        	return PLUGIN_HANDLED
	}

	// Proceed
	new icoins = g_coins[id] - zc_coins_prices[18];
	if(icoins < 0) {
		zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
		return PLUGIN_HANDLED
	}

	// Check limit
	new limit, data[32], rest_limit, counter, save[16]
	rest_limit = zc_coins_items_limit[12]
	if(limiter_get_data(g_limiter_map, "Nighter", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
	}
	if (limit < rest_limit)
	{
		// Get item
		zp_colored_print(0, "^x04[ZC]^x01 The player^x04 %s^x01 has bought^x04 Nighter !!", g_playername[id])
		set_task(3.0, "removeannounce", id)
		g_coins[id] = icoins
		g_coins_modes_limit += 1
		static ip[16];
		get_user_ip(id, ip, charsmax(ip), 1);
		log_to_file("zc_coins.log", "[NIGHTER] [%s] [%s] [%s]", g_playername[id], ip, mapname);
		client_cmd (id, "spk %s", BGH_S)
		native_make_user_nighter(id);

		// Save limit
		counter = limit+1
		num_to_str(counter, save, sizeof(save) - 1)
    		limiter_set_data(g_limiter_map, "Nighter", g_playername[id], save)		
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public makese_nighter(id)
{
    	new menu = menu_create("\wChose \ythe player \wbelow:", "makese_handler_nighter");
    	new players[32], pnum, tempid;
    	new szUserId[32];
    	get_players(players, pnum, "a")
    	for (new i; i<pnum; i++) {
        	tempid = players[i];
        	formatex(szUserId, charsmax(szUserId), "%d", get_user_userid(tempid));
        	menu_additem (menu, g_playername[tempid], szUserId, 0);
    	}
    	menu_display(id, menu, 0);
}

public makese_handler_nighter(id, menu, item)
{
    	if (item == MENU_EXIT) {
        	menu_destroy(menu);
        	return PLUGIN_HANDLED
    	}
    	new szData[6], szName[64];
    	new item_access, item_callback;
    	menu_item_getinfo(menu, item, item_access, szData, charsmax(szData), szName, charsmax(szName), item_callback);
    	new userid = str_to_num(szData);
    	new player = find_player("k", userid);

	// Check availability
	if (!allowed_nighter(player)){
		zp_colored_print(id, "^x04[ZC]^x01 This mode isn't^x04 allowed^x01 right now. Please try again.")
        	return PLUGIN_HANDLED
	}

	// Proceed
	new icoins = g_coins[id] - zc_coins_prices[18];
	if(icoins < 0) {
		zp_colored_print(id, "^x04[ZC]^x01 You don't have enough^x04 coins.");
		return PLUGIN_HANDLED
	}

	// Check limit
	new limit, data[32], rest_limit, counter, save[16]
	rest_limit = zc_coins_items_limit[12]
	if(limiter_get_data(g_limiter_map, "Nighter", g_playername[id], data, 15))
	{
		limit = str_to_num(data)
	}
	if (limit < rest_limit)
	{
		// Get item
		zp_colored_print(0, "^x04[ZC]^x01 Player^x04 %s^x01 makes^x04 %s^x01 a^x03 Nighter !", g_playername[id], g_playername[player])
		set_task(3.0, "removeannounce", id)
		g_coins[id] = icoins
		g_coins_modes_limit += 1
		static ipa[16], ipb[16];
		get_user_ip(id, ipa, charsmax(ipa), 1);
		get_user_ip(player, ipb, charsmax(ipb), 1);
		log_to_file("zc_coins.log", "[NIGHTER] [%s - %s]  [%s - %s] [%s]", g_playername[id], ipa, g_playername[player], ipb, mapname);
		client_cmd (id, "spk %s", BGH_S)
		native_make_user_nighter(player);

		// Save limit
		counter = limit+1
		num_to_str(counter, save, sizeof(save) - 1)
    		limiter_set_data(g_limiter_map, "Nighter", g_playername[id], save)		
	}else {
		zp_colored_print(id, "^x04[ZC]^x01 This item cannot be purchased anymore on this map!")
		return PLUGIN_HANDLED
	}

	// Destroy menu
    	menu_destroy(menu);
	return PLUGIN_HANDLED
}

/*================================================================================
 [Register System]
=================================================================================*/
public client_authorized(id)
{	
	static name[32], Ip[22];
	get_user_ip(id, Ip, sizeof(Ip) -1, 1);
	get_user_name(id, name, 31);

	if(CheckRegistration(id, name))
	{
		static szPassword[15]
		get_user_info(id, g_szInfoKey, szPassword, sizeof(szPassword) -1);

		if(equal(szPassword, g_szLoginInfo[id][Password]))
		{
			log_to_file(logname, "[SUCCES] [%s - %s] [W: %s] [RN: %s]", name, Ip, szPassword, g_szLoginInfo[id][Nick]);
		}else {
           		server_cmd("kick #%i ^"Scrie/Write in console (`~ button): setinfo %s parola (space between setinfo and _zm)^"", get_user_userid(id), g_szInfoKey);
			log_to_file(logname, "[GRESEALA] [%s - %s] [W: %s - R: %s] [RN: %s]", name, Ip, szPassword, g_szLoginInfo[id][Password], g_szLoginInfo[id][Nick])			
		}
	}
}

public fwd_ClientUserInfoChangedPost(id, InfoKey)
{
	if(!is_user_connected(id) || is_user_connecting(id))
		return FMRES_IGNORED;
	
	new Ip[22];
	get_user_ip(id, Ip, sizeof(Ip) -1, 1);
	
	new szNewName[32];
	engfunc(EngFunc_InfoKeyValue, InfoKey, "name", szNewName, sizeof (szNewName) -1);
	
	if(equali(g_playername[id], szNewName))
		return FMRES_IGNORED;
		
	if(CheckRegistration(id, szNewName))
	{
		static szPassword[15]
		get_user_info(id, g_szInfoKey, szPassword, sizeof (szPassword) -1);
		if(equal(szPassword, g_szLoginInfo[id][Password]))
		{
			log_to_file(logname, "[SUCCES] [%s - %s] [W: %s] [RN: %s]", szNewName, Ip, szPassword, g_szLoginInfo[id][Nick]);
		}else {
           		server_cmd("kick #%i ^"Scrie/Write in console (`~ button): setinfo %s parola (space between setinfo and _zm)^"", get_user_userid(id), g_szInfoKey);
			log_to_file(logname, "[GRESEALA] [%s - %s] [W: %s - R: %s] [RN: %s]", szNewName, Ip, szPassword, g_szLoginInfo[id][Password], g_szLoginInfo[id][Nick])
		}
	}
	return FMRES_IGNORED;
}

public reload_rn_cmd(id, level, cid)
{
    	if(!cmd_access(id , level , cid, 1)) 
		return PLUGIN_HANDLED;

	server_print("[ZC] The nicknames file was reloaded.")
	client_print(id, print_console, "[ZC] The nicknames file was reloaded.")
	LoadRegistrations();
	return PLUGIN_HANDLED;
}

public ClCmdSayRegisterNick(id)
{
	// Remove the last menu
	show_menu(id, 0, "\n", 1)

	// Continue checking
	if(!is_user_valid_connected(id)) 
	{
		return PLUGIN_HANDLED;
	}
	new szIP[16]
	get_user_ip(id, szIP, charsmax(szIP), 1)
	for (new i = 0; i<sizeof(numeint); i++)
	{
		if(containi(g_playername[id], numeint[i]) != -1) {
			return PLUGIN_HANDLED;
		}		
	}

	for (new ix = 0; ix <sizeof(ipint); ix++)
	{
		if(containi(szIP, ipint[ix]) != -1) {
			return PLUGIN_HANDLED;
		}		
	}

	/*if(UserIsRegistered(g_playername[id]) || UserIsRegistered1(szIP)) {
		zp_colored_print(id, "^x04[ZC]^x01 This nickname is already registered.");
		return PLUGIN_HANDLED;
	}*/

        if(UserIsRegistered(g_playername[id])) {
                new szMenuTitle[128];
                formatex(szMenuTitle, sizeof(szMenuTitle) - 1, "\r  Change password^n^n\wCurrent Nick:\y %s\r [REGISTERED]^n", g_playername[id]);
                new iMenu = menu_create(szMenuTitle, "ChangePasswordMenu");
                menu_additem(iMenu, "\wChange Password (cost:\r 1200 ammo packs\w)^n    \yIt's best not to forget your password!", "1", 0);
                menu_additem(iMenu, "\wBack to main menu", "2", 0);
                menu_setprop(iMenu, MPROP_EXITNAME, "\wExit");
                menu_display(id, iMenu);
                return PLUGIN_CONTINUE;
        }

	if(g_ammopacks[id] < 200 || g_points[id] < 2) {
		zp_colored_print(id, "^x04[ZC]^x01 Impossible to register if you don't have more than^x04 200 packs^x01 and minimum^x04 3 points!")
		zp_colored_print(id, "^x04[ZC]^x01 Impossible to register if you don't have more than^x04 200 packs^x01 and minimum^x04 3 points!")
		zp_colored_print(id, "^x04[ZC]^x01 Impossible to register if you don't have more than^x04 200 packs^x01 and minimum^x04 3 points!")
		return PLUGIN_HANDLED;
	}

	// Init menu
	new szMenuName[128];
	formatex(szMenuName, sizeof (szMenuName) -1, "\r  Nick register^n^n\wNick:\y %s  \r|\w Password:\y %s^n", g_playername[id], g_szLoginInfo[id][Password]);
	new iMenu = menu_create( szMenuName, "NR_RegisterMenu");
	menu_additem(iMenu, "\wWrite password", "1", 0);
	menu_additem(iMenu, "\rConfirm", "2", 0);
	menu_setprop(iMenu, MPROP_EXITNAME, "\wExit");
	menu_display(id, iMenu);
	return PLUGIN_CONTINUE;
}

public NR_RegisterMenu(id, iMenu, iItem)
{
	if(iItem == MENU_EXIT || !is_user_valid_connected(id)) 
	{
		menu_destroy(iMenu);
		return PLUGIN_HANDLED;
	}
	
	static _access, szInfo[4], iCallback;
	menu_item_getinfo(iMenu, iItem, _access, szInfo, sizeof(szInfo) -1, _, _, iCallback);
	menu_destroy(iMenu);
	new iKey = str_to_num(szInfo);
	switch(iKey)
	{
		case 1:
		{
			zp_colored_print(id, "^x04[ZC]^x01 You have to write up a password, and then to press^x04 ENTER^x01.");
			zp_colored_print(id, "^x04[ZC]^x01 You have to write up a password, and then to press^x04 ENTER^x01.");
			zp_colored_print(id, "^x04[ZC]^x01 You have to write up a password, and then to press^x04 ENTER^x01.");
			client_cmd(id, "messagemode RN_SetPassword");
		}
		case 2:
		{
			if(!equal(g_szLoginInfo[id][Password], g_szNoneWord))
			{

				// Remove the last menu
				show_menu(id, 0, "\n", 1)

				new szIP[16]
				get_user_ip(id, szIP, charsmax(szIP), 1)
				
				zp_colored_print(id, "^x04[ZC]^x01 You have succesfully registered, your dates being:");
				zp_colored_print(id, "^x04[ZC]^x01 Nick:^x04 %s^x01 | Password:^x04 %s", g_playername[id], g_szLoginInfo[id][Password]);
				zp_colored_print(id, "^x04[ZC]^x01 To login, write in^x04 console^x01 this: ^x04setinfo %s %s", g_szInfoKey, g_szLoginInfo[id][Password]);
				client_cmd(id, "topcolor ^"^";rate ^"^";model ^"^";setinfo ^"_zm^" ^"%s^"", g_szLoginInfo[id][Password]);

				// Show MOTD
				static sBuffer[1500], iLen;
				iLen = formatex(sBuffer, sizeof sBuffer - 1, "<body bgcolor=#303020 text=#FFFFFF><pre>");
				iLen += formatex(sBuffer[iLen], CharsMax(sBuffer) - iLen,"<img src=http://www.hexien.net/motd/images/RO.png /> <b><u>Romania</u></b>^n^n");
				iLen += formatex(sBuffer[iLen], CharsMax(sBuffer) - iLen,"<font size=3>Contul tau a fost inregistrat.</font>^n");
				iLen += formatex(sBuffer[iLen], CharsMax(sBuffer) - iLen,"<font size=3>Pentru a te loga, deschide consola apasand butonul ~` de sub tasta Esc.</font>^n");
				iLen += formatex(sBuffer[iLen], CharsMax(sBuffer) - iLen,"<font size=3>Acolo vei scrie: <font color=#FF0000><b>setinfo _zm %s</b></font> dupa care apesi tasta Enter.</font>^n", g_szLoginInfo[id][Password]);
				iLen += formatex(sBuffer[iLen], CharsMax(sBuffer) - iLen,"<font size=3>Ca sa nu uiti, noteaza pe o foita: <font color=#FF0000><b>setinfo _zm %s</b></font></font>^n", g_szLoginInfo[id][Password]);
				iLen += formatex(sBuffer[iLen], CharsMax(sBuffer) - iLen,"<font size=3><b>Atentie, intre setinfo si _zm trebuie sa lasi un spatiu.</b></font>^n");
				iLen += formatex(sBuffer[iLen], CharsMax(sBuffer) - iLen,"<font size=3>Daca vrei VIP permanent, platesti doar 3 EUR cod reincarcabil orange</font>^n^n^n^n");
				iLen += formatex(sBuffer[iLen], CharsMax(sBuffer) - iLen,"<img src=http://hexien.net/motd/images/EN.png /> <b><u>English</u></b>^n^n");
				iLen += formatex(sBuffer[iLen], CharsMax(sBuffer) - iLen,"<font size=3>Your name has been registered.</font>^n");
				iLen += formatex(sBuffer[iLen], CharsMax(sBuffer) - iLen,"<font size=3>To log in, open the console pressing ~` button under Esc key.</font>^n");
				iLen += formatex(sBuffer[iLen], CharsMax(sBuffer) - iLen,"<font size=3>There, you have to write: <font color=#FF0000><b>setinfo _zm %s</b></font> and then press Enter</font>^n", g_szLoginInfo[id][Password]);
				iLen += formatex(sBuffer[iLen], CharsMax(sBuffer) - iLen,"<font size=3><b>Note: between setinfo and _zm let a space.</b></font>^n");
				iLen += formatex(sBuffer[iLen], CharsMax(sBuffer) - iLen,"<font size=3>If you want permanent VIP, buy it with 3 EUR paypal</font>^n");
				show_motd(id, sBuffer, "Succesfully registered.");

				// Saving dates
				new eData[eRegisterInfos];
				copy(eData[Nick], sizeof (eData[Nick]) -1, g_playername[id]);
				copy(eData[Password], sizeof (eData[Password]) -1, g_szLoginInfo[id][Password]);
				copy(eData[IP], sizeof (eData[IP]) -1, szIP);
				ArrayPushArray(g_aData, eData);
				g_iRegistrations++;
				CheckRegistration(id, g_playername[id]);
				new szIp[22];
				get_user_ip(id, szIp, sizeof (szIp) -1);
				log_to_file(logname, "[REGISTERED] %s (%s) [Nick: %s | Parola: %s]", g_playername[id], szIp, eData[Nick], eData[Password]);	
				SaveRegistrations();
			}
			else
			{
				zp_colored_print(id, "^x04[ZC]^x01 The dates for registration are incomplete!");
				set_task(0.1, "ClCmdSayRegisterNick", id)
			}
		}
	}
	return PLUGIN_CONTINUE;
}

public __RN_SetPassword(id)
{
	static szArg[15];
	read_argv(1, szArg, sizeof (szArg) -1);
	
	if (!strlen(szArg) || strlen(szArg) < 3)
	{
		zp_colored_print(id, "^x04[ZC]^x01 The password must have more than 3 characters!");
		client_cmd(id, "messagemode RN_SetPassword");
		ClCmdSayRegisterNick(id)
		return PLUGIN_HANDLED;
	}
	else if(strlen(szArg) > 10)
	{
		zp_colored_print(id, "^x04[ZC]^x01 The password mustn't be longer than 10 characters!");
		client_cmd(id, "messagemode RN_SetPassword");
		ClCmdSayRegisterNick(id)
		return PLUGIN_HANDLED;
	}
	
	copy(g_szLoginInfo[id][Password], sizeof (g_szLoginInfo[][Password]) -1, szArg);
	set_task(0.1, "ClCmdSayRegisterNick", id)
	return PLUGIN_HANDLED;
	
}

CheckRegistration(id, const szNick[])
{
	new bool:bRegistered = false;
	new eData[eRegisterInfos];
	for(new i; i < g_iRegistrations; i++)
	{
		ArrayGetArray(g_aData, i, eData);
		if(equali(szNick, eData[Nick]))
		{
			copy(g_szLoginInfo[id][Nick], sizeof (g_szLoginInfo[][Nick]) -1, eData[Nick]);
			copy(g_szLoginInfo[id][Password], sizeof (g_szLoginInfo[][Password]) -1, eData[Password]);
			copy(g_szLoginInfo[id][IP], sizeof (g_szLoginInfo[][IP]) -1, eData[IP]);
			bRegistered = true;
			break;
		}
	}
	
	if(!bRegistered)
	{
		copy(g_szLoginInfo[id][Nick], sizeof (g_szLoginInfo[][Nick]) -1, g_szNoneWord);
		copy(g_szLoginInfo[id][Password], sizeof (g_szLoginInfo[][Password]) -11, g_szNoneWord);
		copy(g_szLoginInfo[id][IP], sizeof (g_szLoginInfo[][IP]) -1, g_szNoneWord);
	}		
	return bRegistered;
}

LoadRegistrations()
{
	get_localinfo("amxx_datadir", g_szRegisterFile, sizeof (g_szRegisterFile) -1);
	format(g_szRegisterFile, sizeof (g_szRegisterFile) -1, "%s/save/nickreg.txt", g_szRegisterFile);
	
	if(g_iRegistrations)
	{
		ArrayClear(g_aData);
		g_iRegistrations = 0;
	}
	
	if(file_exists(g_szRegisterFile))
	{
		new iFile = fopen(g_szRegisterFile, "rt");
		new szNick[32], szPassword[15], szIP[16];
		new szFileData[128], eData[eRegisterInfos];
		while(!feof(iFile))
		{
			fgets(iFile, szFileData, sizeof (szFileData) - 1);
			
			if(!szFileData[0] || szFileData[0] == ';'
				|| (szFileData[0] == '/' && szFileData[1] == '/'))
				continue;
			
			parse(szFileData, szNick, sizeof (szNick) -1, szPassword, sizeof (szPassword) -1, szIP, sizeof (szIP) -1)
			copy(eData[Nick], sizeof (eData[Nick]) -1, szNick);
			copy(eData[Password], sizeof (eData[Password]) -1, szPassword);
			copy(eData[IP], sizeof (eData[IP]) -1, szIP);
			ArrayPushArray(g_aData, eData);
			g_iRegistrations++;
		}
		fclose(iFile);	
	}	
}

SaveRegistrations()
{
	if(file_exists(g_szRegisterFile))
		delete_file(g_szRegisterFile);
		
	new iFile = fopen(g_szRegisterFile, "wt");
	new eData[eRegisterInfos];
	
	for(new i; i < g_iRegistrations; i++)
	{
		ArrayGetArray(g_aData, i, eData);
		fprintf(iFile, "^"%s^" ^"%s^" ^"%s^"^n", eData[Nick], eData[Password], eData[IP]);
	}
	fclose(iFile);
}

UserIsRegistered(const szName[])
{
	new eData[eRegisterInfos];
	new bool:bRegistered = false;
	
	for(new i = 0; i < g_iRegistrations; i++)
	{
		ArrayGetArray(g_aData, i, eData);
		if(equali(szName, eData[Nick]))
		{
			bRegistered = true;
			break;
		}
	}
	return bRegistered;
}

/*UserIsRegistered1(const szIP[])
{
	new eData[eRegisterInfos];
	new bool:bRegistered = false;
	
	for(new i = 0; i < g_iRegistrations; i++)
	{
		ArrayGetArray(g_aData, i, eData);
		if(equal(szIP, eData[IP]))
		{
			bRegistered = true;
			break;
		}
	}
	return bRegistered;
}*/

public ChangePasswordMenu(id, iMenu, iItem) {
    if (iItem == MENU_EXIT || !is_user_valid_connected(id)) {
        menu_destroy(iMenu);
        return PLUGIN_HANDLED;
    }

    switch (iItem) {

    case 0: {

    if (g_ammopacks[id] < 1200) {
        zp_colored_print(id, "^x04[ZC]^x01 You need at least^x04 1200 ammo packs^x01 to change your password.");
        menu_destroy(iMenu);
        return PLUGIN_HANDLED;
    }

    zp_colored_print(id, "^x04[ZC]^x01 Write a new password and press^x04 ENTER.");
    zp_colored_print(id, "^x04[ZC]^x01 Write a new password and press^x04 ENTER.");
    zp_colored_print(id, "^x04[ZC]^x01 Write a new password and press^x04 ENTER.");
    client_cmd(id, "messagemode ChangePassword");
    menu_destroy(iMenu);
    
    }

    case 1: {
        show_menu_game(id);
        menu_destroy(iMenu);

    }}

    return PLUGIN_CONTINUE;
}

public __ChangePassword(id) {
    static szNewPassword[15];
    read_argv(1, szNewPassword, sizeof(szNewPassword) - 1);

    if (!strlen(szNewPassword) || strlen(szNewPassword) < 3) {
        zp_colored_print(id, "^x04[ZC]^x01 The password must have more than 3 characters!");
        client_cmd(id, "messagemode ChangePassword");
        return PLUGIN_HANDLED;
    } else if (strlen(szNewPassword) > 10) {
        zp_colored_print(id, "^x04[ZC]^x01 The password mustn't be longer than 10 characters!");
        client_cmd(id, "messagemode ChangePassword");
        return PLUGIN_HANDLED;
    }

    g_ammopacks[id] -= 1200;

    new bool:bChanged = false;
    new eData[eRegisterInfos];
    for (new i = 0; i < g_iRegistrations; i++) {
        ArrayGetArray(g_aData, i, eData);
        if (equal(eData[Nick], g_playername[id])) {
            copy(eData[Password], sizeof(eData[Password]) - 1, szNewPassword);
            ArraySetArray(g_aData, i, eData);            
            SaveRegistrations();
            bChanged = true;
            break;
    }}

    if (!bChanged)
        zp_colored_print(id, "^x04[ZC]^x01 Could not find your account to change the password!");
    else {
        client_cmd(id, "topcolor ^"^";rate ^"^";model ^"^";setinfo ^"_zm^" ^"%s^"", szNewPassword);
        new szIp[22];
        get_user_ip(id, szIp, sizeof (szIp) -1);
        log_to_file("zc_change_password.log", "[PASSWORD_CHANGED] %s (%s) [Nick: %s | New Password: %s]", g_playername[id], szIp, g_playername[id], szNewPassword);
        zp_colored_print(id, "^x04[ZC]^x01 Password changed successfully! New password: ^x04%s^x01 |^x04 setinfo %s %s", szNewPassword, g_szInfoKey, szNewPassword);
    }

    return PLUGIN_HANDLED;
}

/*================================================================================
 [Number commas]
=================================================================================*/
public AddCommas(iNum , szOutput[] , iLen)
{
	new szTmp[15], iOutputPos, iNumPos, iNumLen;
	if(iNum < 0) {
		szOutput[iOutputPos++] = '-'
		iNum = abs(iNum)
	}

	iNumLen = num_to_str(iNum, szTmp, charsmax(szTmp))
	if(iNumLen <= 3) {
		iOutputPos += copy(szOutput[iOutputPos], iLen, szTmp)
	}else {
		while((iNumPos < iNumLen) && (iOutputPos < iLen)) {
			szOutput[iOutputPos++] = szTmp[iNumPos++]
		
			if((iNumLen - iNumPos) && !((iNumLen - iNumPos) % 3)) 
				szOutput[iOutputPos++] = ','
		}
		szOutput[iOutputPos] = EOS
	}
	return iOutputPos;
}

/*================================================================================
 [Bonus at 20 played minutes]
=================================================================================*/
public BonusAdd(id)
{ 
	id -= TASK_BONUSADD
        if(!is_user_valid_connected(id)) return
	if(get_user_team(id) == 1 || get_user_team(id) == 2) {
		g_ammopacks[id] += 100
		g_points[id] += 1
		g_coins[id] += 1
		g_xp[id] += 1
		zp_colored_print(id, "^x04[ZC]^x01 Congratulations! You played^x04 20 minutes^x01 and got^x03 +100^x04 packs,^x03 +1^x04 point,^x03 +1^x04 coin^x01 and^x03 +1^x04 XP.")
	}
}

/*================================================================================
 [Colored Print]
=================================================================================*/
zp_colored_print(target, const message[], any:...)
{
	static buffer[512], i, argscount
	argscount = numargs()
	
	// Send to everyone
	if (!target)
	{
		static player
		for (player = 1; player <= g_maxplayers; player++)
		{
			// Not connected
			if (!g_isconnected[player])
				continue;
			
			// Remember changed arguments
			static changed[5], changedcount // [5] = max LANG_PLAYER occurencies
			changedcount = 0
			
			// Replace LANG_PLAYER with player id
			for (i = 2; i < argscount; i++)
			{
				if (getarg(i) == LANG_PLAYER)
				{
					setarg(i, 0, player)
					changed[changedcount] = i
					changedcount++
				}
			}
			
			// Format message for player
			vformat(buffer, charsmax(buffer), message, 3)
			
			// Send it
			message_begin(MSG_ONE_UNRELIABLE, g_msgSayText, _, player)
			write_byte(player)
			write_string(buffer)
			message_end()
			
			// Replace back player id's with LANG_PLAYER
			for (i = 0; i < changedcount; i++)
				setarg(changed[i], 0, LANG_PLAYER)
		}
	}
	// Send to specific target
	else
	{
		/*
		// Not needed since you should set the ML argument
		// to the player's id for a targeted print message
		
		// Replace LANG_PLAYER with player id
		for (i = 2; i < argscount; i++)
		{
			if (getarg(i) == LANG_PLAYER)
				setarg(i, 0, target)
		}
		*/
		
		// Format message for player
		vformat(buffer, charsmax(buffer), message, 3)
		
		// Send it
		message_begin(MSG_ONE, g_msgSayText, _, target)
		write_byte(target)
		write_string(buffer)
		message_end()
	}
}

/*================================================================================
 [Custom Natives]
=================================================================================*/
// Native: zp_set_user_blockbuy
public native_set_user_blockbuy(id)
{
	g_canbuy[id] = false
}

// Native: zp_get_user_points
public native_get_user_points(id)
{
	return g_points[id];
}

// Native: zp_set_user_points
public native_set_user_points(id, amount)
{
	g_points[id] = amount;
}

// Native: zp_get_user_coins
public native_get_user_coins(id)
{
	return g_coins[id];
}

// Native: zp_set_user_coins
public native_set_user_coins(id, amount)
{
	g_coins[id] = amount;
}

// Native: zp_get_user_xp
public native_get_user_xp(id)
{
	return g_xp[id];
}

// Native: zp_set_user_xp
public native_set_user_xp(id, amount)
{
	g_xp[id] = amount;
}

// Native: SaveData
public native_save_date(id)
{
}

// Native: Update Team
public native_update_team(id)
{
	fm_user_team_update(id)
}

// Native: zp_get_user_level
public native_get_user_level(id)
{
	return g_level[id];
}

// Native: zp_set_user_level
public native_set_user_level(id, amount)
{
	g_level[id] = amount;
	
}

// Native: zp_get_user_power
public native_get_user_power(id)
{
	return hp_l[id]+armor_l[id]+speed_l[id]+asp_l[id]+blink_l[id]+chain_l[id]+wallh_l[id]
}

// Native Get Access Flags
public native_zc_get_user_flags(id)
{
	return g_privileges[id]
}

// Native Get VIP Flags
public native_zv_get_user_flags(id)
{
	return g_user_privileges[id]
}

// Native: zv_register_extra_item
public native_zv_register_extra_item(const name[], cost, team, rest_type, rest_limit)
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Arrays not yet initialized
	if (!g_arrays_created)
		return -1;
	
	// Strings passed byref
	param_convert(1)
	
	// Add the item
	ArrayPushString(g_vipextraitem_name, name)
	ArrayPushCell(g_vipextraitem_cost, cost)
	ArrayPushCell(g_vipextraitem_team, team)
	ArrayPushCell(g_vipextraitem_resttype, rest_type)
	ArrayPushCell(g_vipextraitem_restlimit, rest_limit)
	ArrayPushCell(g_vipextraitem_limit, 0)
	
	// Increase registered items counter
	g_vipextraitem_i++
	
	// Return id under which we registered the item
	return g_vipextraitem_i-1;
}

// Native: zp_get_user_hclassname
public native_get_user_hclassname(plugin_id, num_params)
{
	new name[32]
	new classid = get_param(1)
	if (classid < 0 || classid >= g_hclass_i)
	{
		classid = 1
		copy(name, charsmax(name), "Not selected")
	}else{
		ArrayGetString(g_hclass_name, classid, name, charsmax(name))
	}
	
	new len = get_param(3)
	set_string(2, name, len)
	return true;
}

// Get current human class
public native_get_user_current_hc(plugin_id, num_params)
{
	new id = get_param(1)
	if (!is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return HCLASS_NONE;
	}

	if(g_humanclass[id] < 1) return g_humanclassnext[id];
	else return g_humanclass[id];
	return 0
}

// Native: zp_get_user_zclassname
public native_get_user_zclassname(id)
{
	new name[32]
	new classid = get_param(1)
	if (classid < 0 || classid >= g_zclass_i)
	{
		classid = 1
		copy(name, charsmax(name), "Not selected")
	}else{
		ArrayGetString(g_zclass_name, classid, name, charsmax(name))
	}
	
	new len = get_param(3)
	set_string(2, name, len)
	return true;
}

// Get current zombie class
public native_get_user_current_zc(plugin_id, num_params)
{
	new id = get_param(1)
	if (!is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return ZCLASS_NONE;
	}
	
	if(g_zombieclass[id] < 1) return g_zombieclassnext[id];
	else return g_zombieclass[id];
	return 0
}

// Native: zp_get_user_zombie
public native_get_user_zombie(id)
{
	return g_zombie[id];
}

// Native: zp_get_user_nemesis
public native_get_user_nemesis(id)
{
	return g_nemesis[id];
}

// Native: zp_get_user_survivor
public native_get_user_survivor(id)
{
	return g_survivor[id];
}

public native_get_user_first_zombie(id)
{
	return g_firstzombie[id];
}

// Native: zp_get_user_last_zombie
public native_get_user_last_zombie(id)
{
	return g_lastzombie[id];
}

// Native: zp_get_user_last_human
public native_get_user_last_human(id)
{
	return g_lasthuman[id];
}

// Native: zp_get_user_zombie_class
public native_get_user_zombie_class(id)
{
	return g_zombieclass[id];
}

// Native: zp_get_user_next_class
public native_get_user_next_class(id)
{
	return g_zombieclassnext[id];
}

// Native: zp_set_user_zombie_class
public native_set_user_zombie_class(id, classid)
{
	if (classid < 0 || classid >= g_zclass_i)
		return 0;
	
	g_zombieclassnext[id] = classid
	return 1;
}

// Native: zp_get_user_human_class
public native_get_user_human_class(id)
{
	return g_humanclass[id];
}

// Native: zp_get_user_next_hclass
public native_get_user_next_hclass(id)
{
	return g_humanclassnext[id];
}

// Native: zp_set_user_human_class
public native_set_user_human_class(id, classid)
{
	if (classid < 0 || classid >= g_zclass_i)
		return 0;
	
	g_humanclassnext[id] = classid
	return 1;
}

// Native: zp_get_user_ammo_packs
public native_get_user_ammo_packs(id)
{
	return g_ammopacks[id];
}

// Native: zp_set_user_ammo_packs
public native_set_user_ammo_packs(id, amount)
{
	g_ammopacks[id] = amount;
}

// Native: zp_get_zombie_maxhealth
public native_get_zombie_maxhealth(id)
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	if (g_zombie[id] && !g_nemesis[id] && !g_assassin[id] && !g_oberon[id] && !g_dragon[id] && !g_nighter[id] && !g_genesys[id])
	{
		if (g_firstzombie[id])
			return floatround(float(ArrayGetCell(g_zclass_hp, g_zombieclass[id])) * zc_zombie_first_hp)
		else
			return ArrayGetCell(g_zclass_hp, g_zombieclass[id])
	}
	return -1;
}

// Native: zp_get_human_maxhealth
public native_get_human_maxhealth(id)
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	if (!g_zombie[id] && !g_survivor[id] && !g_sniper[id] && !g_flamer[id] && !g_zadoc[id])
	{
		return ArrayGetCell(g_hclass_hp, g_humanclass[id])
	}
	return -1;
}

// Native: zp_get_user_batteries
public native_get_user_batteries(id)
{
	return g_flashbattery[id];
}

// Native: zp_set_user_batteries
public native_set_user_batteries(id, value)
{
	// ZP disabled
	if (!g_pluginenabled)
		return;
	
	g_flashbattery[id] = clamp(value, 0, 100);
	
	if (g_cached_customflash)
	{
		// Set the flashlight charge task to update battery status
		remove_task(id+TASK_CHARGE)
		set_task(1.0, "flashlight_charge", id+TASK_CHARGE, _, _, "b")
	}
}

// Native: zp_get_user_nightvision
public native_get_user_nightvision(id)
{
	return g_hadnvision[id];
}

// Native: zp_set_user_nightvision
public native_set_user_nightvision(id, set)
{
	// ZP disabled
	if (!g_pluginenabled)
		return;

	if (set == 1)
	{
		g_hadnvision[id] = true
		set_user_nightvision(id, 1)
	}else if(set == 0) {
		set_user_nightvision(id, 0)
		g_hadnvision[id] = false
	}
}

// Native: zp_infect_user
public native_infect_user(id, infector, silent, rewards)
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Not allowed to be zombie
	if (!allowed_zombie(id))
		return 0;

	// For gas-mask
        ExecuteForward(g_fwUserInfectedByBombNative, g_fwDummyResult, id)
        if (g_fwDummyResult >= ZP_PLUGIN_HANDLED)
            	return 0;
	
	// New round?
	if (g_newround)
	{
		// Set as first zombie
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_INFECTION, id)
	}
	else
	{
		// Just infect (plus some checks)
		zombieme(id, is_user_valid_alive(infector) ? infector : 0, 0, (silent == 1) ? 1 : 0, (rewards == 1) ? 1 : 0, 0, 0, 0, 0, 0, 0)
	}
	
	return 1;
}

// Native: zp_disinfect_user
public native_disinfect_user(id, silent)
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Not allowed to be human
	if (!allowed_human(id))
		return 0;
	
	// Turn to human
	humanme(id, 0, (silent == 1) ? 1 : 0, 0, 0, 0, 0)
	return 1;
}

// Native: zp_make_user_nemesis
public native_make_user_nemesis(id)
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Not allowed to be nemesis
	if (!allowed_nemesis(id))
		return 0;
	
	// New round?
	if (g_newround)
	{
		// Set as first nemesis
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_NEMESIS, id)
	}
	else
	{
		// Turn player into a Nemesis
		zombieme(id, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0)
	}
	
	return 1;
}

// Native: zp_make_user_survivor
public native_make_user_survivor(id)
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Not allowed to be survivor
	if (!allowed_survivor(id))
		return 0;
	
	// New round?
	if (g_newround)
	{
		// Set as first survivor
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_SURVIVOR, id)
	}
	else
	{
		// Turn player into a Survivor
		humanme(id, 1, 0, 0, 0, 0, 0)
	}
	
	return 1;
}

// Native: zp_respawn_user
public native_respawn_user(id, team)
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Invalid player
	if (!is_user_valid_connected(id))
		return 0;
	
	// Respawn not allowed
	if (!allowed_respawn(id))
		return 0;
	
	// Respawn as zombie?
	g_respawn_as_zombie[id] = (team == ZP_TEAM_ZOMBIE) ? true : false
	
	// Respawnish!
	respawn_player_manually(id)
	return 1;
}

// Native: zp_force_buy_extra_item
public native_force_buy_extra_item(id, itemid, ignorecost, ignorerest)
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	if (itemid < 0 || itemid >= g_extraitem_i)
		return 0;
	
	buy_extra_item(id, itemid, ignorecost, ignorerest)
	return 1;
}

// Native: zp_get_user_sniper
public native_get_user_sniper(id)
{
	return g_sniper[id];
}

// Native: zp_make_user_sniper
public native_make_user_sniper(id)
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Not allowed to be sniper
	if (!allowed_sniper(id))
		return 0;
	
	// New round?
	if (g_newround)
	{
		// Set as first sniper
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_SNIPER, id)
	}
	else
	{
		// Turn player into a Sniper
		humanme(id, 0, 0, 1, 0, 0, 0)
	}
	
	return 1;
}

// Native: zp_get_user_flamer
public native_get_user_flamer(id)
{
	return g_flamer[id];
}

// Native: zp_make_user_flamer
public native_make_user_flamer(id)
{
	// ZPA disabled
	if (!g_pluginenabled)
		return -1;
	
	// Not allowed to be flamer
	if (!allowed_flamer(id))
		return 0;
	
	// New round?
	if (g_newround)
	{
		// Set as first flamer
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_FLAMER, id)
	}
	else
	{
		// Turn player into a Flamer
		humanme(id, 0, 0, 0, 1, 0, 0)
	}
	
	return 1;
}

// Native: zp_get_user_zadoc
public native_get_user_zadoc(id)
{
	return g_zadoc[id];
}

// Native: zp_make_user_zadoc
public native_make_user_zadoc(id)
{
	// ZPA disabled
	if (!g_pluginenabled)
		return -1;
	
	// Not allowed to be zadoc
	if (!allowed_zadoc(id))
		return 0;
	
	// New round?
	if (g_newround)
	{
		// Set as first zadoc
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_ZADOC, id)
	}
	else
	{
		// Turn player into a zadoc
		humanme(id, 0, 0, 0, 0, 1, 0)
	}
	
	return 1;
}

// For assassin mode
public native_get_user_assassin(id)
{
	return g_assassin[id];
}
 // For making assassin
public native_make_user_assassin(id)
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Not allowed to be assassin
	if (!allowed_assassin(id))
		return 0;
	
	// New round?
	if (g_newround)
	{
		// Set as first assassin
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_ASSASSIN, id)
	}
	else
	{
		// Turn player into a Assassin
		zombieme(id, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0)
	}
	
	return 1;
}

// For Oberon mode
public native_get_user_oberon(id)
{
	return g_oberon[id];
}

 // For making Oberon
public native_make_user_oberon(id)
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Not allowed to be Oberon
	if (!allowed_oberon(id))
		return 0;
	
	// New round?
	if (g_newround)
	{
		// Set as first oberon
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_OBERON, id)
	}
	else
	{
		// Turn player into a oberon
		zombieme(id, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0)
	}
	
	return 1;
}

// For Dragon mode
public native_get_user_dragon(id)
{
	return g_dragon[id];
}

 // For making Dragon
public native_make_user_dragon(id)
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Not allowed to be dragon
	if (!allowed_dragon(id))
		return 0;
	
	// New round?
	if (g_newround)
	{
		// Set as first dragon
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_DRAGON, id)
	}
	else
	{
		// Turn player into a Dragon
		zombieme(id, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0)
	}
	
	return 1;
}

// For Nighter mode
public native_get_user_nighter(id)
{
	return g_nighter[id];
}

 // For making Nighter
public native_make_user_nighter(id)
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Not allowed to be nighter
	if (!allowed_nighter(id))
		return 0;
	
	// New round?
	if (g_newround)
	{
		// Set as first nighter
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_NIGHTER, id)
	}
	else
	{
		// Turn player into a nighter
		zombieme(id, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0)
	}
	
	return 1;
}

// Native: zp_get_user_genesys
public native_get_user_genesys(id)
{
	return g_genesys[id];
}

 // Native: zp_make_user_genesys
public native_make_user_genesys(id)
{
	// ZPA disabled
	if (!g_pluginenabled)
		return -1;
	
	// Not allowed to be genesys
	if (!allowed_genesys(id))
		return 0;
	
	// New round?
	if (g_newround)
	{
		// Set as first genesys
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_GENESYS, id)
	}
	else
	{
		// Turn player into a genesys
		zombieme(id, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0)
	}
	
	return 1;
}

// Native: zp_has_round_started
public native_has_round_started()
{
	if (g_newround) return 0; // not started
	if (g_modestarted) return 1; // started
	return 2; // starting
}

// Native: zp_is_nemesis_round
public native_is_nemesis_round()
{
	return g_nemround;
}

// Native: zp_is_survivor_round
public native_is_survivor_round()
{
	return g_survround;
}

// Native: zp_is_swarm_round
public native_is_swarm_round()
{
	return g_swarmround;
}

// Native: zp_is_plague_round
public native_is_plague_round()
{
	return g_plagueround;
}

// Native: zp_get_zombie_count
public native_get_zombie_count()
{
	return fnGetZombies();
}

// Native: zp_get_human_count
public native_get_human_count()
{
	return fnGetHumans();
}

// Native: zp_get_nemesis_count
public native_get_nemesis_count()
{
	return fnGetNemesis();
}

// Native: zp_get_survivor_count
public native_get_survivor_count()
{
	return fnGetSurvivors();
}

// Native: zp_is_sniper_round
public native_is_sniper_round()
{
	return g_sniperround;
}

// Native: zp_is_flamer_round
public native_is_flamer_round()
{
	return g_flamerround;
}

// Native: zp_is_zadoc_round
public native_is_zadoc_round()
{
	return g_zadocround;
}

// Native: zp_get_sniper_count
public native_get_sniper_count()
{
	return fnGetSnipers();
}

// Native: zp_get_flamer_count
public native_get_flamer_count()
{
	return fnGetFlamers();
}

// Native: zp_get_zadoc_count
public native_get_zadoc_count()
{
	return fnGetZadocs();
}

// Native: zp_is_assassin_round
public native_is_assassin_round()
{
	return g_assassinround;
}

// Native: zp_is_oberon_round
public native_is_oberon_round()
{
	return g_oberonround;
}

// Native: zp_is_dragon_round
public native_is_dragon_round()
{
	return g_dragonround;
}

// Native: zp_is_nighter_round
public native_is_nighter_round()
{
	return g_nighterround;
}

// Native: zp_is_genesys_round
public native_is_genesys_round()
{
	return g_genesysround;
}

// Native: zp_get_assassin_count
public native_get_assassin_count()
{
	return fnGetAssassin();
}

// Native: zp_get_oberon_count
public native_get_oberon_count()
{
	return fnGetOberon();
}

// Native: zp_get_dragon_count
public native_get_dragon_count()
{
	return fnGetDragon();
}

// Native: zp_get_nighter_count
public native_get_nighter_count()
{
	return fnGetNighter();
}

// Native: zp_get_genesys_count
public native_get_genesys_count()
{
	return fnGetGenesys();
}

// Native: zp_is_lnj_round
public native_is_lnj_round()
{
	return g_lnjround;
}

// Native: zp_is_guardians_round
public native_is_guardians_round()
{
	return g_guardiansround;
}

// Native: zp_register_extra_item
public native_register_extra_item(const name[], cost, team, rest_type, rest_limit)
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Arrays not yet initialized
	if (!g_arrays_created)
		return -1;
	
	// Strings passed byref
	param_convert(1)
	
	// Add the item
	ArrayPushString(g_extraitem_name, name)
	ArrayPushCell(g_extraitem_cost, cost)
	ArrayPushCell(g_extraitem_team, team)
	ArrayPushCell(g_extraitem_resttype, rest_type)
	ArrayPushCell(g_extraitem_restlimit, rest_limit)
	ArrayPushCell(g_extraitem_limit, 0)
	
	// Set temporary new item flag
	ArrayPushCell(g_extraitem_new, 1)
	
	// Override extra items data with our customizations
	new i, buffer[32], size = ArraySize(g_extraitem2_realname)
	for (i = 0; i < size; i++)
	{
		ArrayGetString(g_extraitem2_realname, i, buffer, charsmax(buffer))
		
		// Check if this is the intended item to override
		if (!equal(name, buffer))
			continue;
		
		// Remove new item flag
		ArraySetCell(g_extraitem_new, g_extraitem_i, 0)
		
		// Replace caption
		ArrayGetString(g_extraitem2_name, i, buffer, charsmax(buffer))
		ArraySetString(g_extraitem_name, g_extraitem_i, buffer)
		
		// Replace cost
		buffer[0] = ArrayGetCell(g_extraitem2_cost, i)
		ArraySetCell(g_extraitem_cost, g_extraitem_i, buffer[0])
		
		// Replace team
		buffer[0] = ArrayGetCell(g_extraitem2_team, i)
		ArraySetCell(g_extraitem_team, g_extraitem_i, buffer[0])

		// Replace restriction type
		buffer[0] = ArrayGetCell(g_extraitem2_resttype, i)
		ArraySetCell(g_extraitem_resttype, g_extraitem_i, buffer[0])

		// Replace restriction limit
		buffer[0] = ArrayGetCell(g_extraitem2_restlimit, i)
		ArraySetCell(g_extraitem_restlimit, g_extraitem_i, buffer[0])
	}
	
	// Increase registered items counter
	g_extraitem_i++
	
	// Return id under which we registered the item
	return g_extraitem_i-1;
}

// Function: zp_register_extra_item (to be used within this plugin only)
native_register_extra_item2(const name[], cost, team, rest_type = 0, rest_limit = 0)
{
	// Add the item
	ArrayPushString(g_extraitem_name, name)
	ArrayPushCell(g_extraitem_cost, cost)
	ArrayPushCell(g_extraitem_team, team)
	ArrayPushCell(g_extraitem_resttype, rest_type)
	ArrayPushCell(g_extraitem_restlimit, rest_limit)
	ArrayPushCell(g_extraitem_limit, 0)
	
	// Set temporary new item flag
	ArrayPushCell(g_extraitem_new, 1)
	
	// Increase registered items counter
	g_extraitem_i++
}

// Native: zp_register_zombie_class
public native_register_zombie_class(const name[], const info[], const model[], const clawmodel[], hp, speed, Float:gravity, Float:knockback, level)
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Arrays not yet initialized
	if (!g_arrays_created)
		return -1;
	
	// Strings passed byref
	param_convert(1)
	param_convert(2)
	param_convert(3)
	param_convert(4)
	
	// Add the class
	ArrayPushString(g_zclass_name, name)
	ArrayPushString(g_zclass_info, info)
	
	// Using same zombie models for all classes?
	if (g_same_models_for_all)
	{
		ArrayPushCell(g_zclass_modelsstart, 0)
		ArrayPushCell(g_zclass_modelsend, ArraySize(g_zclass_playermodel))
	}
	else
	{
		ArrayPushCell(g_zclass_modelsstart, ArraySize(g_zclass_playermodel))
		ArrayPushString(g_zclass_playermodel, model)
		ArrayPushCell(g_zclass_modelsend, ArraySize(g_zclass_playermodel))
		ArrayPushCell(g_zclass_modelindex, -1)
	}
	
	ArrayPushString(g_zclass_clawmodel, clawmodel)
	ArrayPushCell(g_zclass_hp, hp)
	ArrayPushCell(g_zclass_spd, speed)
	ArrayPushCell(g_zclass_grav, gravity)
	ArrayPushCell(g_zclass_kb, knockback)
	ArrayPushCell(g_zclass_level, level)
	
	// Set temporary new class flag
	ArrayPushCell(g_zclass_new, 1)
	
	// Override zombie classes data with our customizations
	new i, k, buffer[32], Float:buffer2, nummodels_custom, nummodels_default, prec_mdl[100], size = ArraySize(g_zclass2_realname)
	for (i = 0; i < size; i++)
	{
		ArrayGetString(g_zclass2_realname, i, buffer, charsmax(buffer))
		
		// Check if this is the intended class to override
		if (!equal(name, buffer))
			continue;
		
		// Remove new class flag
		ArraySetCell(g_zclass_new, g_zclass_i, 0)
		
		// Replace caption
		ArrayGetString(g_zclass2_name, i, buffer, charsmax(buffer))
		ArraySetString(g_zclass_name, g_zclass_i, buffer)
		
		// Replace info
		ArrayGetString(g_zclass2_info, i, buffer, charsmax(buffer))
		ArraySetString(g_zclass_info, g_zclass_i, buffer)
		
		// Replace models, unless using same models for all classes
		if (!g_same_models_for_all)
		{
			nummodels_custom = ArrayGetCell(g_zclass2_modelsend, i) - ArrayGetCell(g_zclass2_modelsstart, i)
			nummodels_default = ArrayGetCell(g_zclass_modelsend, g_zclass_i) - ArrayGetCell(g_zclass_modelsstart, g_zclass_i)
			
			// Replace each player model and model index
			for (k = 0; k < min(nummodels_custom, nummodels_default); k++)
			{
				ArrayGetString(g_zclass2_playermodel, ArrayGetCell(g_zclass2_modelsstart, i) + k, buffer, charsmax(buffer))
				ArraySetString(g_zclass_playermodel, ArrayGetCell(g_zclass_modelsstart, g_zclass_i) + k, buffer)
				
				// Precache player model and replace its modelindex with the real one
				formatex(prec_mdl, charsmax(prec_mdl), "models/player/%s/%s.mdl", buffer, buffer)
				ArraySetCell(g_zclass_modelindex, ArrayGetCell(g_zclass_modelsstart, g_zclass_i) + k, engfunc(EngFunc_PrecacheModel, prec_mdl))
				if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, prec_mdl)
				if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, prec_mdl)
			}
			
			// We have more custom models than what we can accommodate,
			// Let's make some space...
			if (nummodels_custom > nummodels_default)
			{
				for (k = nummodels_default; k < nummodels_custom; k++)
				{
					ArrayGetString(g_zclass2_playermodel, ArrayGetCell(g_zclass2_modelsstart, i) + k, buffer, charsmax(buffer))
					ArrayInsertStringAfter(g_zclass_playermodel, ArrayGetCell(g_zclass_modelsstart, g_zclass_i) + k - 1, buffer)
					
					// Precache player model and retrieve its modelindex
					formatex(prec_mdl, charsmax(prec_mdl), "models/player/%s/%s.mdl", buffer, buffer)
					ArrayInsertCellAfter(g_zclass_modelindex, ArrayGetCell(g_zclass_modelsstart, g_zclass_i) + k - 1, engfunc(EngFunc_PrecacheModel, prec_mdl))
					if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, prec_mdl)
					if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, prec_mdl)
				}
				
				// Fix models end index for this class
				ArraySetCell(g_zclass_modelsend, g_zclass_i, ArrayGetCell(g_zclass_modelsend, g_zclass_i) + (nummodels_custom - nummodels_default))
			}
			
			/* --- Not needed since classes can't have more than 1 default model for now ---
			// We have less custom models than what this class has by default,
			// Get rid of those extra entries...
			if (nummodels_custom < nummodels_default)
			{
				for (k = nummodels_custom; k < nummodels_default; k++)
				{
					ArrayDeleteItem(g_zclass_playermodel, ArrayGetCell(g_zclass_modelsstart, g_zclass_i) + nummodels_custom)
				}
				
				// Fix models end index for this class
				ArraySetCell(g_zclass_modelsend, g_zclass_i, ArrayGetCell(g_zclass_modelsend, g_zclass_i) - (nummodels_default - nummodels_custom))
			}
			*/
		}
		
		// Replace clawmodel
		ArrayGetString(g_zclass2_clawmodel, i, buffer, charsmax(buffer))
		ArraySetString(g_zclass_clawmodel, g_zclass_i, buffer)
		
		// Precache clawmodel
		formatex(prec_mdl, charsmax(prec_mdl), "models/zombie_crown/%s", buffer)
		engfunc(EngFunc_PrecacheModel, prec_mdl)
		
		// Replace health
		buffer[0] = ArrayGetCell(g_zclass2_hp, i)
		ArraySetCell(g_zclass_hp, g_zclass_i, buffer[0])
		
		// Replace speed
		buffer[0] = ArrayGetCell(g_zclass2_spd, i)
		ArraySetCell(g_zclass_spd, g_zclass_i, buffer[0])
		
		// Replace gravity
		buffer2 = Float:ArrayGetCell(g_zclass2_grav, i)
		ArraySetCell(g_zclass_grav, g_zclass_i, buffer2)
		
		// Replace knockback
		buffer2 = Float:ArrayGetCell(g_zclass2_kb, i)
		ArraySetCell(g_zclass_kb, g_zclass_i, buffer2)

		// Replace level
		buffer[0] = ArrayGetCell(g_zclass2_level, i)
		ArraySetCell(g_zclass_level, g_zclass_i, buffer[0])
	}
	
	// If class was not overriden with customization data
	if (ArrayGetCell(g_zclass_new, g_zclass_i))
	{
		// If not using same models for all classes
		if (!g_same_models_for_all)
		{
			// Precache default class model and replace modelindex with the real one
			formatex(prec_mdl, charsmax(prec_mdl), "models/player/%s/%s.mdl", model, model)
			ArraySetCell(g_zclass_modelindex, ArrayGetCell(g_zclass_modelsstart, g_zclass_i), engfunc(EngFunc_PrecacheModel, prec_mdl))
			if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, prec_mdl)
			if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, prec_mdl)
		}
		
		// Precache default clawmodel
		formatex(prec_mdl, charsmax(prec_mdl), "models/zombie_crown/%s", clawmodel)
		engfunc(EngFunc_PrecacheModel, prec_mdl)
	}

	// For the load_data and save_data
	new tSave[40]
	formatex(tSave, sizeof tSave - 1, "%s", name);
	g_zclass_load[g_zclass_i] = tSave
	
	// Increase registered classes counter
	g_zclass_i++
	
	// Return id under which we registered the class
	return g_zclass_i-1;
}

// Native: zp_register_human_class
public native_register_human_class(const name[], const info[], const model[], hp, speed, Float:gravity, level)
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Arrays not yet initialized
	if (!g_arrays_created)
		return -1;
	
	// Strings passed byref
	param_convert(1)
	param_convert(2)
	param_convert(3)
	
	// Add the class
	ArrayPushString(g_hclass_name, name)
	ArrayPushString(g_hclass_info, info)
	
	// Using same human models for all classes?
	if (g_same_models_for_all)
	{
		ArrayPushCell(g_hclass_modelsstart, 0)
		ArrayPushCell(g_hclass_modelsend, ArraySize(g_hclass_playermodel))
	}
	else
	{
		ArrayPushCell(g_hclass_modelsstart, ArraySize(g_hclass_playermodel))
		ArrayPushString(g_hclass_playermodel, model)
		ArrayPushCell(g_hclass_modelsend, ArraySize(g_hclass_playermodel))
		ArrayPushCell(g_hclass_modelindex, -1)
	}

	ArrayPushCell(g_hclass_hp, hp)
	ArrayPushCell(g_hclass_spd, speed)
	ArrayPushCell(g_hclass_grav, gravity)
	ArrayPushCell(g_hclass_level, level)	
	
	// Set temporary new class flag
	ArrayPushCell(g_hclass_new, 1)
	
	// Override human classes data with our customizations
	new i, k, buffer[32], Float:buffer2, nummodels_custom, nummodels_default, prec_mdl[100], size = ArraySize(g_hclass2_realname)
	for (i = 0; i < size; i++)
	{
		ArrayGetString(g_hclass2_realname, i, buffer, charsmax(buffer))
		
		// Check if this is the intended class to override
		if (!equal(name, buffer))
			continue;
		
		// Remove new class flag
		ArraySetCell(g_hclass_new, g_hclass_i, 0)
		
		// Replace caption
		ArrayGetString(g_hclass2_name, i, buffer, charsmax(buffer))
		ArraySetString(g_hclass_name, g_hclass_i, buffer)
		
		// Replace info
		ArrayGetString(g_hclass2_info, i, buffer, charsmax(buffer))
		ArraySetString(g_hclass_info, g_hclass_i, buffer)
		
		// Replace models, unless using same models for all classes
		if (!g_same_models_for_all)
		{
			nummodels_custom = ArrayGetCell(g_hclass2_modelsend, i) - ArrayGetCell(g_hclass2_modelsstart, i)
			nummodels_default = ArrayGetCell(g_hclass_modelsend, g_hclass_i) - ArrayGetCell(g_hclass_modelsstart, g_hclass_i)
			
			// Replace each player model and model index
			for (k = 0; k < min(nummodels_custom, nummodels_default); k++)
			{
				ArrayGetString(g_hclass2_playermodel, ArrayGetCell(g_hclass2_modelsstart, i) + k, buffer, charsmax(buffer))
				ArraySetString(g_hclass_playermodel, ArrayGetCell(g_hclass_modelsstart, g_hclass_i) + k, buffer)
				
				// Precache player model and replace its modelindex with the real one
				formatex(prec_mdl, charsmax(prec_mdl), "models/player/%s/%s.mdl", buffer, buffer)
				ArraySetCell(g_hclass_modelindex, ArrayGetCell(g_hclass_modelsstart, g_hclass_i) + k, engfunc(EngFunc_PrecacheModel, prec_mdl))
				if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, prec_mdl)
				if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, prec_mdl)
			}
			
			// We have more custom models than what we can accommodate,
			// Let's make some space...
			if (nummodels_custom > nummodels_default)
			{
				for (k = nummodels_default; k < nummodels_custom; k++)
				{
					ArrayGetString(g_hclass2_playermodel, ArrayGetCell(g_hclass2_modelsstart, i) + k, buffer, charsmax(buffer))
					ArrayInsertStringAfter(g_hclass_playermodel, ArrayGetCell(g_hclass_modelsstart, g_hclass_i) + k - 1, buffer)
					
					// Precache player model and retrieve its modelindex
					formatex(prec_mdl, charsmax(prec_mdl), "models/player/%s/%s.mdl", buffer, buffer)
					ArrayInsertCellAfter(g_hclass_modelindex, ArrayGetCell(g_hclass_modelsstart, g_hclass_i) + k - 1, engfunc(EngFunc_PrecacheModel, prec_mdl))
					if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, prec_mdl)
					if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, prec_mdl)
				}
				
				// Fix models end index for this class
				ArraySetCell(g_hclass_modelsend, g_hclass_i, ArrayGetCell(g_hclass_modelsend, g_hclass_i) + (nummodels_custom - nummodels_default))
			}
			
			/* --- Not needed since classes can't have more than 1 default model for now ---
			// We have less custom models than what this class has by default,
			// Get rid of those extra entries...
			if (nummodels_custom < nummodels_default)
			{
				for (k = nummodels_custom; k < nummodels_default; k++)
				{
					ArrayDeleteItem(g_hclass_playermodel, ArrayGetCell(g_hclass_modelsstart, g_hclass_i) + nummodels_custom)
				}
				
				// Fix models end index for this class
				ArraySetCell(g_hclass_modelsend, g_hclass_i, ArrayGetCell(g_hclass_modelsend, g_hclass_i) - (nummodels_default - nummodels_custom))
			}
			*/
		}		

		// Replace health
		buffer[0] = ArrayGetCell(g_hclass2_hp, i)
		ArraySetCell(g_hclass_hp, g_hclass_i, buffer[0])
		
		// Replace speed
		buffer[0] = ArrayGetCell(g_hclass2_spd, i)
		ArraySetCell(g_hclass_spd, g_hclass_i, buffer[0])
		
		// Replace gravity
		buffer2 = Float:ArrayGetCell(g_hclass2_grav, i)
		ArraySetCell(g_hclass_grav, g_hclass_i, buffer2)	

		// Replace level
		buffer[0] = ArrayGetCell(g_hclass2_level, i)
		ArraySetCell(g_hclass_level, g_hclass_i, buffer[0])	
	}
	
	// If class was not overriden with customization data
	if (ArrayGetCell(g_hclass_new, g_hclass_i))
	{
		// If not using same models for all classes
		if (!g_same_models_for_all)
		{
			// Precache default class model and replace modelindex with the real one
			formatex(prec_mdl, charsmax(prec_mdl), "models/player/%s/%s.mdl", model, model)
			ArraySetCell(g_hclass_modelindex, ArrayGetCell(g_hclass_modelsstart, g_hclass_i), engfunc(EngFunc_PrecacheModel, prec_mdl))
			if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, prec_mdl)
			if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, prec_mdl)
		}		
	}

	// For the load_data and save_data
	new tSave[40]
	formatex(tSave, sizeof tSave - 1, "%s", name);
	g_hclass_load[g_hclass_i] = tSave
	
	// Increase registered classes counter
	g_hclass_i++
	
	// Return id under which we registered the class
	return g_hclass_i-1;
}

// Native: zp_get_extra_item_id
public native_get_extra_item_id(const name[])
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Strings passed byref
	param_convert(1)
	
	// Loop through every item
	static i, item_name[32]
	for (i = 0; i < g_extraitem_i; i++)
	{
		ArrayGetString(g_extraitem_name, i, item_name, charsmax(item_name))
		
		// Check if this is the item to retrieve
		if (equali(name, item_name))
			return i;
	}
	
	return -1;
}

// Native: zp_get_zombie_class_id
public native_get_zombie_class_id(const name[])
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Strings passed byref
	param_convert(1)
	
	// Loop through every class
	static i, class_name[32]
	for (i = 0; i < g_zclass_i; i++)
	{
		ArrayGetString(g_zclass_name, i, class_name, charsmax(class_name))
		
		// Check if this is the class to retrieve
		if (equali(name, class_name))
			return i;
	}
	return -1;
}

// Native: zp_get_human_class_id
public native_get_human_class_id(const name[])
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Strings passed byref
	param_convert(1)
	
	// Loop through every class
	static i, class_name[32]
	for (i = 0; i < g_hclass_i; i++)
	{
		ArrayGetString(g_hclass_name, i, class_name, charsmax(class_name))
		
		// Check if this is the class to retrieve
		if (equali(name, class_name))
			return i;
	}
	
	return -1;
}

// Native: zp_get_human_hero
public native_get_human_hero(id)
{
	if(g_survivor[id] || g_sniper[id] || g_flamer[id] || g_zadoc[id] || g_hero[id])
		return true;
	return false
}

// Native: zp_get_zombie_hero
public native_get_zombie_hero(id)
{
	if(g_nemesis[id] || g_assassin[id] || g_genesys[id] || g_oberon[id] || g_dragon[id] || g_nighter[id] || g_evil[id] || g_nchild[id])
		return true;
	return false
}

// Native: zp_is_hero_round
public native_is_hero_round()
{
	if(g_nemround || g_survround || g_oberonround || g_dragonround || g_nighterround || g_assassinround || g_genesysround || g_sniperround || g_flamerround || g_zadocround || g_lnjround || g_guardiansround || g_plagueround || g_swarmround)
		return true;
	return false
}

// Native: zp_get_user_frozen
public native_get_user_frozen(id)
{
	if(!g_pluginenabled)
		return -1;
		
	return g_frozen[id]
}

// Native: zp_set_user_frozen
public native_set_user_frozen(id, set)
{
	if(!g_pluginenabled)
		return;
	
	if(set) /* Set = 1, froze player */
	{
		if(is_user_valid_alive(id) && !g_frozen[id])
		{
			g_frozen[id] = true

			static sound[64]
			ArrayGetString(grenade_frost_player, random_num(0, ArraySize(grenade_frost_player) - 1), sound, charsmax(sound))
			emit_sound(id, CHAN_BODY, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)

			if (zc_hud_icons)
			{
				message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, id)
				write_byte(0) // damage save
				write_byte(0) // damage take
				write_long(DMG_DROWN) // damage type - DMG_FREEZE
				write_coord(0) // x
				write_coord(0) // y
				write_coord(0) // z
				message_end()
			}

			if (g_handle_models_on_separate_ent)
				fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 25)
			else
				fm_set_rendering(id, kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 25)

			message_begin(MSG_ONE, g_msgScreenFade, _, id)
			write_short(0) // duration
			write_short(0) // hold time
			write_short(FFADE_STAYOUT) // fade type
			write_byte(0) // red
			write_byte(50) // green
			write_byte(200) // blue
			write_byte(100) // alpha
			message_end()

			if (pev(id, pev_flags) & FL_ONGROUND)
				set_pev(id, pev_gravity, 999999.9) // set really high
			else
				set_pev(id, pev_gravity, 0.000001) // no gravity
		}
	}
	else /* Set = 0, unfroze player */
	{
		g_frozen[id] = false

		if (g_zombie[id])
		{
			if (g_nemesis[id])
				set_pev(id, pev_gravity, zc_nem_gravity)
			else if (g_genesys[id])
				set_pev(id, pev_gravity, zc_nem_gravity)
			else if (g_assassin[id])
				set_pev(id, pev_gravity, zc_assassin_gravity)
			else if (g_oberon[id])
				set_pev(id, pev_gravity, zc_oberon_gravity)
			else if (g_dragon[id])
				set_pev(id, pev_gravity, zc_dragon_gravity)
			else if (g_nighter[id])
				set_pev(id, pev_gravity, zc_nighter_gravity)
			else if (g_nchild[id])
				set_pev(id, pev_gravity, zc_nchild_gravity)
			else if (g_evil[id])
				set_pev(id, pev_gravity, zc_evil_gravity)
			else
				set_pev(id, pev_gravity, Float:ArrayGetCell(g_zclass_grav, g_zombieclass[id]))
		}
		else
		{
			if (g_survivor[id])
				set_pev(id, pev_gravity, zc_surv_gravity)
			else if (g_sniper[id])
				set_pev(id, pev_gravity, zc_sniper_gravity)
			else if (g_flamer[id])
				set_pev(id, pev_gravity, zc_flamer_gravity)
			else if (g_zadoc[id])
				set_pev(id, pev_gravity, zc_zadoc_gravity)
			else if (g_hero[id])
				set_pev(id, pev_gravity, zc_hero_gravity)
			else
				set_pev(id, pev_gravity, Float:ArrayGetCell(g_hclass_grav, g_humanclass[id]))
		}

		if (g_handle_models_on_separate_ent)
		{
			if (g_nemesis[id] && zc_nem_glow)
				fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 25)
			else if (g_survivor[id] && zc_surv_glow)
				fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 25)
			else
				fm_set_rendering(g_ent_playermodel[id])
		}
		else
		{
			if (g_nemesis[id] && zc_nem_glow)
				fm_set_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 25)
			else if (g_survivor[id] && zc_surv_glow)
				fm_set_rendering(id, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 25)
			else
				fm_set_rendering(id)
		}
		message_begin(MSG_ONE, g_msgScreenFade, _, id)
		write_short(UNIT_SECOND) // duration
		write_short(0) // hold time
		write_short(FFADE_IN) // fade type
		write_byte(0) // red
		write_byte(50) // green
		write_byte(200) // blue
		write_byte(100) // alpha
		message_end()

		static sound[64]
		ArrayGetString(grenade_frost_break, random_num(0, ArraySize(grenade_frost_break) - 1), sound, charsmax(sound))
		emit_sound(id, CHAN_BODY, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)

		static origin2[3]
		get_user_origin(id, origin2)

		message_begin(MSG_PVS, SVC_TEMPENTITY, origin2)
		write_byte(TE_BREAKMODEL) // TE id
		write_coord(origin2[0]) // x
		write_coord(origin2[1]) // y
		write_coord(origin2[2]+24) // z
		write_coord(16) // size x
		write_coord(16) // size y
		write_coord(16) // size z
		write_coord(random_num(-50, 50)) // velocity x
		write_coord(random_num(-50, 50)) // velocity y
		write_coord(25) // velocity z
		write_byte(10) // random velocity
		write_short(g_glassSpr) // model
		write_byte(10) // count
		write_byte(25) // life
		write_byte(BREAK_GLASS) // flags
		message_end()
	
		ExecuteForward(g_fwUserUnfrozen, g_fwDummyResult, id)
	}
}

/*================================================================================
 [Stocks]
=================================================================================*/
// Coins Shop
stock fm_set_user_rendering(index, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16) {
	return fm_set_rendering(index, fx, r, g, b, render, amount);
}

// Genesys Power 2
#define clamp_byte(%1)       ( clamp( %1, 0, 255 ) )
#define pack_color(%1,%2,%3) ( %3 + ( %2 << 8 ) + ( %1 << 16 ) )
stock HudMessage(const id, const message[], red = 0, green = 160, blue = 0, Float:x = -1.0, Float:y = 0.65, effects = 2, Float:fxtime = 0.01, Float:holdtime = 3.0, Float:fadeintime = 0.01, Float:fadeouttime = 0.01) {
	new count = 1, players[32];
	
	if(id) players[0] = id;
	else get_players(players, count, "ch"); {
		for(new i = 0; i < count; i++) {
			if(is_user_connected(players[i])) {	
				new color = pack_color(clamp_byte(red), clamp_byte(green), clamp_byte(blue))
				
				message_begin(MSG_ONE_UNRELIABLE, SVC_DIRECTOR, _, players[i]);
				write_byte(strlen(message) + 31);
				write_byte(DRC_CMD_MESSAGE);
				write_byte(effects);
				write_long(color);
				write_long(_:x);
				write_long(_:y);
				write_long(_:fadeintime);
				write_long(_:fadeouttime);
				write_long(_:holdtime);
				write_long(_:fxtime);
				write_string(message);
				message_end();
			}
		}
	}
}

stock UTIL_ScreenFade(id=0,iColor[3],Float:flFxTime=-1.0,Float:flHoldTime=0.0,iAlpha=0,iFlags=0x0000,bool:bReliable=false,bool:bExternal=false) 
{
	if(id && !is_user_valid_connected(id))
		return;
	
	new iFadeTime;
	if(flFxTime == -1.0) {
		iFadeTime = 4;
	}
	else {
		iFadeTime = FixedUnsigned16(flFxTime , 1<<12);
	}
	
	static gmsgScreenFade;
	if(!gmsgScreenFade) {
		gmsgScreenFade = get_user_msgid("ScreenFade");
	}
	
	new MSG_DEST;
	if(bReliable) {
		MSG_DEST = id ? MSG_ONE : MSG_ALL;
	}
	else {
		MSG_DEST = id ? MSG_ONE_UNRELIABLE : MSG_BROADCAST;
	}
	
	if(bExternal) {
		emessage_begin(MSG_DEST, gmsgScreenFade, _, id);
		ewrite_short(iFadeTime);
		ewrite_short(FixedUnsigned16(flHoldTime , 1<<12));
		ewrite_short(iFlags);
		ewrite_byte(iColor[0]);
		ewrite_byte(iColor[1]);
		ewrite_byte(iColor[2]);
		ewrite_byte(iAlpha);
		emessage_end();
	}
	else {
		message_begin(MSG_DEST, gmsgScreenFade, _, id);
		write_short(iFadeTime);
		write_short(FixedUnsigned16(flHoldTime , 1<<12));
		write_short(iFlags);
		write_byte(iColor[0]);
		write_byte(iColor[1]);
		write_byte(iColor[2]);
		write_byte(iAlpha);
		message_end();
	}
}

stock Create_ScreenFade(id, duration, holdtime, fadetype, red, green, blue, alpha)
{
	if(is_user_connected(id)) {
		message_begin(MSG_ONE,get_user_msgid("ScreenFade"),{0,0,0},id)			
		write_short(duration)			// fade lasts this long duration
		write_short(holdtime)			// fade lasts this long hold time
		write_short(fadetype)			// fade type(in / out)
		write_byte(red)				// fade red
		write_byte(green)			// fade green
		write_byte(blue)			// fade blue
		write_byte(alpha)			// fade alpha
		message_end()
	}
}

stock Create_ScreenShake(id, amount, duration, frequency){
	if(is_user_connected(id)) {
		message_begin(MSG_ONE,get_user_msgid("ScreenShake"), {0,0,0} , id) 
		write_short(amount)	// ammount 
		write_short(duration)	// lasts this long 
		write_short(frequency)	// frequency
		message_end()
	}
}

// Damage User
stock damage_user(id, victim, damage)
{
	new Float:Dmg
	Dmg = float(damage)
	static ent_kill
	ent_kill = fm_get_user_weapon_entity(id, CSW_KNIFE)
	ExecuteHam(Ham_TakeDamage, victim, ent_kill, id, Dmg, DMG_BULLET)
}

// Flamer Power
stock fm_find_ent_by_class(index, const classname[])
{
	return engfunc(EngFunc_FindEntityByString, index, "classname", classname) 
}

// if weapon index isn't passed then assuming that it's the current weapon
stock fm_get_user_weapon_entity(id, wid = 0) {
	new weap = wid, clip, ammo;
	if (!weap && !(weap = get_user_weapon(id, clip, ammo)))
		return 0;
	
	new class[32];
	get_weaponname(weap, class, sizeof class - 1);

	return fm_find_ent_by_owner(-1, class, id);
}

stock play_weapon_anim(player, anim)
{
	set_pev(player, pev_weaponanim, anim)
	message_begin(MSG_ONE, SVC_WEAPONANIM, {0, 0, 0}, player)
	write_byte(anim)
	write_byte(pev(player, pev_body))
	message_end()
}

stock get_weapon_attackment(id, Float:output[3], Float:fDis = 40.0)
{ 
	new Float:vfEnd[3], viEnd[3] 
	get_user_origin(id, viEnd, 3)  
	IVecFVec(viEnd, vfEnd) 
	
	new Float:fOrigin[3], Float:fAngle[3]
	
	pev(id, pev_origin, fOrigin) 
	pev(id, pev_view_ofs, fAngle)
	
	xs_vec_add(fOrigin, fAngle, fOrigin) 
	
	new Float:fAttack[3]
	
	xs_vec_sub(vfEnd, fOrigin, fAttack)
	xs_vec_sub(vfEnd, fOrigin, fAttack) 
	
	new Float:fRate
	
	fRate = fDis / vector_length(fAttack)
	xs_vec_mul_scalar(fAttack, fRate, fAttack)
	
	xs_vec_add(fOrigin, fAttack, output)
}

// Set an entity's key value (from fakemeta_util)
stock fm_set_kvd(entity, const key[], const value[], const classname[])
{
	set_kvd(0, KV_ClassName, classname)
	set_kvd(0, KV_KeyName, key)
	set_kvd(0, KV_Value, value)
	set_kvd(0, KV_fHandled, 0)

	dllfunc(DLLFunc_KeyValue, entity, 0)
}

// Set entity's rendering type (from fakemeta_util)
stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16) 
{
	new Float:RenderColor[3];
	RenderColor[0] = float(r);
	RenderColor[1] = float(g);
	RenderColor[2] = float(b);

	set_pev(entity, pev_renderfx, fx);
	set_pev(entity, pev_rendercolor, RenderColor);
	set_pev(entity, pev_rendermode, render);
	set_pev(entity, pev_renderamt, float(amount));

	return 1;
}

// FixedUnsigned16
stock FixedUnsigned16(Float:flValue, iScale) {
	new iOutput;
	
	iOutput = floatround(flValue * iScale);
	if(iOutput < 0)
		iOutput = 0;
	
	if(iOutput > 0xFFFF)
		iOutput = 0xFFFF;
	return iOutput;
}

// Get entity's speed (from fakemeta_util)
stock fm_get_speed(entity)
{
	static Float:velocity[3]
	pev(entity, pev_velocity, velocity)
	
	return floatround(vector_length(velocity));
}

// Get entity's aim origins (from fakemeta_util)
stock fm_get_aim_origin(id, Float:origin[3])
{
	static Float:origin1F[3], Float:origin2F[3]
	pev(id, pev_origin, origin1F)
	pev(id, pev_view_ofs, origin2F)
	xs_vec_add(origin1F, origin2F, origin1F)

	pev(id, pev_v_angle, origin2F);
	engfunc(EngFunc_MakeVectors, origin2F)
	global_get(glb_v_forward, origin2F)
	xs_vec_mul_scalar(origin2F, 9999.0, origin2F)
	xs_vec_add(origin1F, origin2F, origin2F)

	engfunc(EngFunc_TraceLine, origin1F, origin2F, 0, id, 0)
	get_tr2(0, TR_vecEndPos, origin)
}

// Find entity by its owner (from fakemeta_util)
stock fm_find_ent_by_owner(entity, const classname[], owner)
{
	while ((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", classname)) && pev(entity, pev_owner) != owner) { /* keep looping */ }
	return entity;
}

// Set player's health (from fakemeta_util)
stock fm_set_user_health(id, health)
{
	(health > 0) ? set_pev(id, pev_health, float(health)) : dllfunc(DLLFunc_ClientKill, id);
}

// Give an item to a player (from fakemeta_util)
stock fm_give_item(id, const item[])
{
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item))
	if (!pev_valid(ent)) return;
	
	static Float:originF[3]
	pev(id, pev_origin, originF)
	set_pev(ent, pev_origin, originF)
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN)
	dllfunc(DLLFunc_Spawn, ent)
	
	static save
	save = pev(ent, pev_solid)
	dllfunc(DLLFunc_Touch, ent, id)
	if (pev(ent, pev_solid) != save)
		return;
	
	engfunc(EngFunc_RemoveEntity, ent)
}

// Strip user weapons (from fakemeta_util)
stock fm_strip_user_weapons(id)
{
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "player_weaponstrip"))
	if (!pev_valid(ent)) return;
	
	dllfunc(DLLFunc_Spawn, ent)
	dllfunc(DLLFunc_Use, ent, id)
	engfunc(EngFunc_RemoveEntity, ent)
}

// Collect random spawn points
stock load_spawns()
{
	// Collect regular spawns for non-random spawning unstuck
	collect_spawns_ent("info_player_start")
	collect_spawns_ent("info_player_deathmatch")
}

// Collect spawn points from entity origins
stock collect_spawns_ent(const classname[])
{
	new ent = -1
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", classname)) != 0)
	{
		// get origin
		new Float:originF[3]
		pev(ent, pev_origin, originF)
		g_spawns[g_spawnCount][0] = originF[0]
		g_spawns[g_spawnCount][1] = originF[1]
		g_spawns[g_spawnCount][2] = originF[2]
		
		// increase spawn count
		g_spawnCount++
		if (g_spawnCount >= sizeof g_spawns) break;
	}
}

// Drop primary/secondary weapons
stock drop_weapons(id, dropwhat)
{
	// Get user weapons
	static weapons[32], num, i, weaponid
	num = 0 // reset passed weapons count (bugfix)
	get_user_weapons(id, weapons, num)
	
	// Loop through them and drop primaries or secondaries
	for (i = 0; i < num; i++)
	{
		// Prevent re-indexing the array
		weaponid = weapons[i]
		
		if ((dropwhat == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM)) || (dropwhat == 2 && ((1<<weaponid) & SECONDARY_WEAPONS_BIT_SUM)))
		{
			// Get weapon entity
			static wname[32], weapon_ent
			get_weaponname(weaponid, wname, charsmax(wname))
			weapon_ent = fm_find_ent_by_owner(-1, wname, id)
			
			// Hack: store weapon bpammo on PEV_ADDITIONAL_AMMO
			set_pev(weapon_ent, PEV_ADDITIONAL_AMMO, cs_get_user_bpammo(id, weaponid))
			
			// Player drops the weapon and looses his bpammo
			engclient_cmd(id, "drop", wname)
			cs_set_user_bpammo(id, weaponid, 0)
		}
	}
}

// Stock by (probably) Twilight Suzuka -counts number of chars in a string
stock str_count(const str[], searchchar)
{
	new count, i, len = strlen(str)
	
	for (i = 0; i <= len; i++)
	{
		if (str[i] == searchchar)
			count++
	}
	
	return count;
}

// Checks if a space is vacant (credits to VEN)
stock is_hull_vacant(Float:origin[3], hull)
{
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, 0, 0)
	
	if (!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen))
		return true;
	
	return false;
}

// Check if a player is stuck (credits to VEN)
stock is_player_stuck(id)
{
	static Float:originF[3]
	pev(id, pev_origin, originF)
	
	engfunc(EngFunc_TraceHull, originF, originF, 0, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0)
	
	if (get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen))
		return true;
	
	return false;
}

// Simplified get_weaponid (CS only)
stock cs_weapon_name_to_id(const weapon[])
{
	static i
	for (i = 0; i < sizeof WEAPONENTNAMES; i++)
	{
		if (equal(weapon, WEAPONENTNAMES[i]))
			return i;
	}
	
	return 0;
}

// Get User Current Weapon Entity
stock fm_cs_get_current_weapon_ent(id)
{
	return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM, OFFSET_LINUX);
}

// Get Weapon Entity's Owner
stock fm_cs_get_weapon_ent_owner(ent)
{
	return get_pdata_cbase(ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS);
}

// Set User Deaths
stock fm_cs_set_user_deaths(id, value)
{
	set_pdata_int(id, OFFSET_CSDEATHS, value, OFFSET_LINUX)
}

// Get User Team
stock fm_cs_get_user_team(id)
{
	return get_pdata_int(id, OFFSET_CSTEAMS, OFFSET_LINUX);
}

// Set a Player's Team
stock fm_cs_set_user_team(id, team)
{
	set_pdata_int(id, OFFSET_CSTEAMS, team, OFFSET_LINUX)
        cs_set_team_id(id, team)
}

// Set User Money
stock fm_cs_set_user_money(id, value)
{
	set_pdata_int(id, OFFSET_CSMONEY, value, OFFSET_LINUX)
}

// Set User Flashlight Batteries
stock fm_cs_set_user_batteries(id, value)
{
	set_pdata_int(id, OFFSET_FLASHLIGHT_BATTERY, value, OFFSET_LINUX)
}

// Update Player's Team on all clients (adding needed delays)
stock fm_user_team_update(id)
{
	static Float:current_time
	current_time = get_gametime()
	
	if (current_time - g_teams_targettime >= 0.1)
	{
		set_task(0.1, "fm_cs_set_user_team_msg", id+TASK_TEAM)
		g_teams_targettime = current_time + 0.1
	}
	else
	{
		set_task((g_teams_targettime + 0.1) - current_time, "fm_cs_set_user_team_msg", id+TASK_TEAM)
		g_teams_targettime = g_teams_targettime + 0.1
	}
}

// Send User Team Message
public fm_cs_set_user_team_msg(taskid)
{
	// Set the switching team flag
	g_switchingteam = true
	
	// Tell everyone my new team
	emessage_begin(MSG_ALL, g_msgTeamInfo)
	ewrite_byte(ID_TEAM) // player
	ewrite_string(CS_TEAM_NAMES[fm_cs_get_user_team(ID_TEAM)]) // team
	emessage_end()
	
	// Done switching team
	g_switchingteam = false
}

// Set the precached model index (updates hitboxes server side)
stock fm_cs_set_user_model_index(id, value)
{
	set_pdata_int(id, OFFSET_MODELINDEX, value, OFFSET_LINUX)
}

// Set Player Model on Entity
stock fm_set_playermodel_ent(id)
{
	// Make original player entity invisible without hiding shadows or firing effects
	fm_set_rendering(id, kRenderFxNone, 255, 255, 255, kRenderTransTexture, 1)
	
	// Format model string
	static model[100]
	formatex(model, charsmax(model), "models/player/%s/%s.mdl", g_playermodel[id], g_playermodel[id])
	
	// Set model on entity or make a new one if unexistant
	if (!pev_valid(g_ent_playermodel[id]))
	{
		g_ent_playermodel[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
		if (!pev_valid(g_ent_playermodel[id])) return;
		
		set_pev(g_ent_playermodel[id], pev_classname, MODEL_ENT_CLASSNAME)
		set_pev(g_ent_playermodel[id], pev_movetype, MOVETYPE_FOLLOW)
		set_pev(g_ent_playermodel[id], pev_aiment, id)
		set_pev(g_ent_playermodel[id], pev_owner, id)
	}
	
	engfunc(EngFunc_SetModel, g_ent_playermodel[id], model)
}

// Set Weapon Model on Entity
stock fm_set_weaponmodel_ent(id)
{
	// Get player's p_ weapon model
	static model[100]
	pev(id, pev_weaponmodel2, model, charsmax(model))
	
	// Set model on entity or make a new one if unexistant
	if (!pev_valid(g_ent_weaponmodel[id]))
	{
		g_ent_weaponmodel[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
		if (!pev_valid(g_ent_weaponmodel[id])) return;
		
		set_pev(g_ent_weaponmodel[id], pev_classname, WEAPON_ENT_CLASSNAME)
		set_pev(g_ent_weaponmodel[id], pev_movetype, MOVETYPE_FOLLOW)
		set_pev(g_ent_weaponmodel[id], pev_aiment, id)
		set_pev(g_ent_weaponmodel[id], pev_owner, id)
	}
	
	engfunc(EngFunc_SetModel, g_ent_weaponmodel[id], model)
}

// Remove Custom Model Entities
stock fm_remove_model_ents(id)
{
	// Remove "playermodel" ent if present
	if (pev_valid(g_ent_playermodel[id]))
	{
		engfunc(EngFunc_RemoveEntity, g_ent_playermodel[id])
		g_ent_playermodel[id] = 0
	}
	// Remove "weaponmodel" ent if present
	if (pev_valid(g_ent_weaponmodel[id]))
	{
		engfunc(EngFunc_RemoveEntity, g_ent_weaponmodel[id])
		g_ent_weaponmodel[id] = 0
	}
}

// Set User Model
public fm_cs_set_user_model(taskid)
{
	set_user_info(ID_MODEL, "model", g_playermodel[ID_MODEL])
}

// Get User Model -model passed byref-
stock fm_cs_get_user_model(player, model[], len)
{
	get_user_info(player, "model", model, len)
}

// Update Player's Model on all clients (adding needed delays)
public fm_user_model_update(taskid)
{
	static Float:current_time
	current_time = get_gametime()
	
	if (current_time - g_models_targettime >= g_modelchange_delay)
	{
		fm_cs_set_user_model(taskid)
		g_models_targettime = current_time
	}
	else
	{
		set_task((g_models_targettime + g_modelchange_delay) - current_time, "fm_cs_set_user_model", taskid)
		g_models_targettime = g_models_targettime + g_modelchange_delay
	}
}

public plugin_end()
{
	// Register
	ArrayDestroy(g_aData);

	// Items restrictions
	if (file_exists("addons/amxmodx/data/save/limiter_map.txt"))
		delete_file("addons/amxmodx/data/save/limiter_map.txt")
	if (file_exists("addons/amxmodx/data/save/limiter_round.txt"))
		delete_file("addons/amxmodx/data/save/limiter_round.txt")
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1252\\ deff0\\ deflang1033{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
 