#include <amxmodx>
#include <fakemeta>
#include <xs>
#include <colored_print>
#include <hamsandwich>

/*================================================================================
 [Zombie Plague Checking]
=================================================================================*/

// try include "zombiecrown.inc"

#tryinclude <zombiecrown>

#if !defined _zombiecrown_included
	#assert zombiecrown.inc library required!
#endif

/*================================================================================
 [Constants, Offsets, Macros]
=================================================================================*/

// Blick Zombie
new const zclass_name[] = { "Blink" }
new const zclass_info[] = { "Teleport" }
new const zclass_model[] = { "zc_model_zm7" }
new const zclass_clawmodel[] = "v_knife_zm7.mdl" 
const zclass_health = 17000
const zclass_speed = 470
const Float:zclass_gravity = 0.60
const Float:zclass_knockback = 2.0
const zclass_level = 64

// Ham weapon const
const OFFSET_WEAPONOWNER = 41
const OFFSET_LINUX_WEAPONS = 4

// Flashbang sound
new const SOUND_BLINK[] = { "weapons/flashbang-1.wav" }

// ScreenFade
const UNIT_SEC = 0x1000 // 1 second
const FFADE = 0x0000

/*================================================================================
 [Global Variables]
=================================================================================*/

// Player vars
new g_bBlink[33] // is Blink Zombie
new g_bAllowATK[33] // allow to attack
new Float:g_flLastBlink[33] // last blink time

// Game vars
new g_iBlinkIndex // index from the class
new g_iMaxPlayers // max player counter

// Message IDs vars
new g_msgScreenFade

// Sprites
new g_iShockwave, g_iFlare

// Cvar pointers
new cvar_Cooldown, cvar_Range, cvar_Nemesis,
cvar_Button, cvar_Bots, cvar_NoAttack

/*================================================================================
 [Precache and Init]
=================================================================================*/

public plugin_precache()
{
	new registerText[32]
	formatex( registerText, sizeof registerText - 1, "[ZC %s]", zclass_name)
	register_plugin(registerText, "1.0", "meNe")
	g_iBlinkIndex = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_level)
	
	g_iShockwave = precache_model( "sprites/shockwave.spr")
	g_iFlare = precache_model( "sprites/blueflare2.spr")
}

public plugin_init()
{
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_event("DeathMsg", "event_player_death", "a")
	
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "fwd_Knife_Blink")
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "fwd_Knife_Blink")
	
	register_forward(FM_CmdStart, "fwd_CmdStart")
	g_msgScreenFade = get_user_msgid("ScreenFade")
	
	cvar_Cooldown = register_cvar("zp_blink_cooldown", "15.0")
	cvar_NoAttack = register_cvar("zp_blink_no_atk_time", "1.5")
	cvar_Range = register_cvar("zp_blink_range", "1234")
	cvar_Nemesis = register_cvar("zp_blink_nemesis", "0")
	cvar_Button = register_cvar("zp_blink_button", "1")
	cvar_Bots = register_cvar("zp_blink_bots", "1")
	
	g_iMaxPlayers = get_maxplayers()
}

public client_putinserver(id) reset_vars(id)

public client_disconnected(id) reset_vars(id)

/*================================================================================
 [Main Forwards]
=================================================================================*/

public event_round_start()
{
	for (new id = 1; id <= g_iMaxPlayers; id++)
		reset_vars(id)
}

public event_player_death() reset_vars(read_data(2))

public fwd_Knife_Blink(ent)
{
	static owner
	if(!pev_valid(ent))
        	return HAM_IGNORED;

	owner = ham_cs_get_weapon_ent_owner(ent)
	
	if (!g_bBlink[owner] || g_bAllowATK[owner]) return HAM_IGNORED
	
	return HAM_SUPERCEDE
}

public fwd_CmdStart(id, handle)
{
	if (!g_bBlink[id] || !is_user_alive(id) || get_gametime() < g_flLastBlink[id]) return
	
	static button
	button = get_uc(handle, UC_Buttons)
	if (button & IN_USE && !get_pcvar_num(cvar_Button) || button & IN_RELOAD && get_pcvar_num(cvar_Button))
	{
		if (teleport(id))
		{
			emit_sound(id, CHAN_STATIC, SOUND_BLINK, 1.0, ATTN_NORM, 0, PITCH_NORM)
			
			g_bAllowATK[id] = false
			g_flLastBlink[id] = get_gametime() + get_pcvar_float(cvar_Cooldown)
			
			remove_task(id)
			set_task(get_pcvar_float(cvar_NoAttack), "allow_attack", id)
			set_task(get_pcvar_float(cvar_Cooldown), "show_blink", id)
		}
		else
		{
			g_flLastBlink[id] = get_gametime() + 1.0
			
			colored_print(id, GREEN, "[ZC]^x01 It was not find a valid target.")
		}
	}
}

public zp_user_humanized_post(id) reset_vars(id)

public zp_user_infected_post(id, infector, nemesis)
{
	if (nemesis && !get_pcvar_num(cvar_Nemesis)) return
	
	if (zp_get_user_zombie_class(id) == g_iBlinkIndex)
	{
		g_bBlink[id] = true
		g_bAllowATK[id] = true
		g_flLastBlink[id] = get_gametime()
		
		show_blink(id)
	}
}

/*================================================================================
 [Other Functions]
=================================================================================*/

public allow_attack(id)
{
	if (!is_user_connected(id)) return
	
	g_bAllowATK[id] = true
}

reset_vars(id)
{
	remove_task(id)
	g_bBlink[id] = false
	g_bAllowATK[id] = true
}

public show_blink(id)
{
	if (!is_user_connected(id) || !g_bBlink[id] || !is_user_alive(id)) return
	
	if (!get_pcvar_num(cvar_Button))
		colored_print(id, GREEN, "[ZC]^x01 Teleport active, press^x04 [E]")
	else
		colored_print(id, GREEN, "[ZC]^x01 Teleport active, press^x04 [R]")
	
	// Bot support
	if (is_user_bot(id) && get_pcvar_num(cvar_Bots))
		set_task(random_float(1.0, 5.0), "bot_will_teleport", id)
}

public bot_will_teleport(id)
{
	if (!is_user_connected(id) || !g_bBlink[id] || !is_user_alive(id) || !is_user_bot(id)) return
	
	if (teleport(id))
	{
		emit_sound(id, CHAN_STATIC, SOUND_BLINK, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		g_bAllowATK[id] = false
		
		remove_task(id)
		set_task(get_pcvar_float(cvar_NoAttack), "allow_attack", id)
		set_task(get_pcvar_float(cvar_Cooldown), "show_blink", id)
	}
	else
	{
		set_task(random_float(1.0, 3.0), "bot_will_teleport", id)
	}
}

bool:teleport(id)
{
	new	Float:vOrigin[3], Float:vNewOrigin[3],
	Float:vNormal[3], Float:vTraceDirection[3],
	Float:vTraceEnd[3]
	
	pev(id, pev_origin, vOrigin)
	
	velocity_by_aim(id, get_pcvar_num(cvar_Range), vTraceDirection)
	xs_vec_add(vTraceDirection, vOrigin, vTraceEnd)
	
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, DONT_IGNORE_MONSTERS, id, 0)
	
	new Float:flFraction
	get_tr2(0, TR_flFraction, flFraction)
	if (flFraction < 1.0)
	{
		get_tr2(0, TR_vecEndPos, vTraceEnd)
		get_tr2(0, TR_vecPlaneNormal, vNormal)
	}
	
	xs_vec_mul_scalar(vNormal, 40.0, vNormal) // do not decrease the 40.0
	xs_vec_add(vTraceEnd, vNormal, vNewOrigin)
	
	if (is_player_stuck(id, vNewOrigin))
		return false;
	
	emit_sound(id, CHAN_STATIC, SOUND_BLINK, 1.0, ATTN_NORM, 0, PITCH_NORM)
	tele_effect(vOrigin)
	
	engfunc(EngFunc_SetOrigin, id, vNewOrigin)
	
	tele_effect2(vNewOrigin)
	
	emessage_begin(MSG_ONE_UNRELIABLE, g_msgScreenFade, _, id)
	ewrite_short(floatround(UNIT_SEC*get_pcvar_float(cvar_NoAttack)))
	ewrite_short(floatround(UNIT_SEC*get_pcvar_float(cvar_NoAttack)))
	ewrite_short(FFADE)
	ewrite_byte(0)
	ewrite_byte(0)
	ewrite_byte(0)
	ewrite_byte(255)
	emessage_end()
	
	return true;
}

/*================================================================================
 [Stocks]
=================================================================================*/

stock is_player_stuck(id, Float:originF[3])
{
	engfunc(EngFunc_TraceHull, originF, originF, 0, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0)
	
	if (get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen))
		return true;
	
	return false;
}

stock ham_cs_get_weapon_ent_owner(entity)
{
	return get_pdata_cbase(entity, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS);
}

stock tele_effect(const Float:torigin[3])
{
	new origin[3]
	origin[0] = floatround(torigin[0])
	origin[1] = floatround(torigin[1])
	origin[2] = floatround(torigin[2])
	
	message_begin(MSG_PAS, SVC_TEMPENTITY, origin)
	write_byte(TE_BEAMCYLINDER)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+10)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+60)
	write_short(g_iShockwave)
	write_byte(0)
	write_byte(0)
	write_byte(3)
	write_byte(60)
	write_byte(0)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(0)
	message_end()
}

stock tele_effect2(const Float:torigin[3])
{
	new origin[3]
	origin[0] = floatround(torigin[0])
	origin[1] = floatround(torigin[1])
	origin[2] = floatround(torigin[2])
	
	message_begin(MSG_PAS, SVC_TEMPENTITY, origin)
	write_byte(TE_BEAMCYLINDER)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+10)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+60)
	write_short(g_iShockwave)
	write_byte(0)
	write_byte(0)
	write_byte(3)
	write_byte(60)
	write_byte(0)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(0)
	message_end()
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_SPRITETRAIL)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+40)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_short(g_iFlare)
	write_byte(30)
	write_byte(10)
	write_byte(1)
	write_byte(50)
	write_byte(10)
	message_end()
}
