#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#include <zombiecrown>
#include <colored_print>

#define PLUGIN "[ZC KillB]"
#define VERSION "1.0"
#define AUTHOR "yokomo"

const Float:NADE_EXPLOSION_RADIUS = 240.0
const PEV_NADE_TYPE = pev_flTimeStepSound
const NADE_TYPE_KILLBOMB = 6669

const COLOR_R = 237
const COLOR_G = 60
const COLOR_B = 202

new const MODEL_P[] = "models/p_hegrenade.mdl"
new const MODEL_V[] = "models/v_hegrenade.mdl"
new const MODEL_W[] = "models/w_hegrenade.mdl"

new const SPRITES_TRAIL[] = "sprites/laserbeam.spr"
new const SPRITES_EXPLODE[] = "sprites/skull.spr"
new const SOUND_EXPLODE[] = "zombie_crown/items/killbomb_exp.wav"

new g_itemid_killbomb, g_killbomb_spr_trail, g_killbomb_spr_exp, g_maxplayers, g_roundend
new g_haskillbomb[33], g_killedbykillbomb[33]
new cvar_bonushp
new g_fwUserInfectedByKBomb, g_fwDummyResult

public plugin_precache()
{	
	g_killbomb_spr_trail = precache_model(SPRITES_TRAIL)
	g_killbomb_spr_exp = precache_model(SPRITES_EXPLODE)
	precache_sound(SOUND_EXPLODE)
}

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event("HLTV", "EventHLTV", "a", "1=0", "2=0")
	register_event("DeathMsg", "EventDeathMsg", "a")
	register_event("CurWeapon", "EventCurWeapon", "be", "1=1")
	register_logevent("logevent_round_end", 2, "1=Round_End")
	register_message(get_user_msgid("DeathMsg"), "MessageDeathMsg")
	
	register_forward(FM_SetModel, "fw_SetModel")
	RegisterHam(Ham_Think, "grenade", "fw_ThinkGrenade")
	
	cvar_bonushp = register_cvar("zp_killbomb_hp","100")
	g_maxplayers = get_maxplayers()
	g_itemid_killbomb = zv_register_extra_item("Kill Bomb", 50, ZV_TEAM_ZOMBIE, REST_MAP, 2)
	g_fwUserInfectedByKBomb = CreateMultiForward("zp_user_infected_bykillbomb", ET_CONTINUE, FP_CELL) 
}

public client_putinserver(id) g_haskillbomb[id] = 0

public client_disconnect(id) g_haskillbomb[id] = 0

public EventHLTV()
{	
	for(new id = 1; id <= g_maxplayers; id++)
	{
		if(is_user_connected(id)) g_haskillbomb[id] = 0
	}	
}

public EventDeathMsg()
{
	new id = read_data(2)
	if(is_user_connected(id)) g_haskillbomb[id] = 0
}

public EventCurWeapon(id)
{
	if(g_haskillbomb[id])
	{
		if(get_user_weapon(id) == CSW_SMOKEGRENADE)
		{
			set_pev(id, pev_viewmodel2, MODEL_V)
			set_pev(id, pev_weaponmodel2, MODEL_P)
		}
	}
}

public MessageDeathMsg(msg_id, msg_dest, id)
{
	static attacker, victim
	attacker = get_msg_arg_int(1)
	victim = get_msg_arg_int(2)
	
	if(!is_user_connected(attacker) || attacker == victim) return PLUGIN_CONTINUE
	
	if(g_killedbykillbomb[victim]) set_msg_arg_string(4, "grenade")
	
	return PLUGIN_CONTINUE
}

public logevent_round_end() g_roundend = 1

public zp_round_started() g_roundend = 0

public zv_extra_item_selected(id, item)
{
	if(item == g_itemid_killbomb)
	{
		if(g_roundend)
		{
			colored_print(id, GREEN, "[ZC]^x01 Item expired now.")
			return ZP_PLUGIN_HANDLED
		}
		if(user_has_weapon(id, CSW_SMOKEGRENADE))
		{
			colored_print(id, GREEN, "[ZC]^x01 The greande slots are full^x04 (SmokeGrenade).")
			return ZP_PLUGIN_HANDLED
		}
		if(g_haskillbomb[id])
		{
			colored_print(id, GREEN, "[ZC]^x01 You already have^x04 KillBomb.")
			return ZP_PLUGIN_HANDLED
		}
		if(zp_get_zombie_hero(id))
		{
			colored_print(id, GREEN, "[ZC]^x01 You can't buy a^x04 KillBomb.")
			return ZP_PLUGIN_HANDLED
		}
		
		g_haskillbomb[id] = 1
		give_item(id, "weapon_smokegrenade")
		colored_print(id, GREEN, "[ZC]^x01 You have bought a^x04 KillBomb.")
	}
	
	return PLUGIN_CONTINUE
}

public zp_user_humanized_post(id) g_haskillbomb[id] = 0

public fw_SetModel(entity, const model[])
{
	if(!pev_valid(entity)) return FMRES_IGNORED
	
	static Float:dmgtime
	pev(entity, pev_dmgtime, dmgtime)
	
	if(dmgtime == 0.0) return FMRES_IGNORED
	
	static owner; owner = pev(entity, pev_owner)
	if(g_haskillbomb[owner] && equal(model[7], "w_sm", 4))
	{
		set_rendering(entity, kRenderFxGlowShell, COLOR_R, COLOR_G, COLOR_B, kRenderNormal, 0)
			
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMFOLLOW)
		write_short(entity)
		write_short(g_killbomb_spr_trail)
		write_byte(10)
		write_byte(3)
		write_byte(COLOR_R)
		write_byte(COLOR_G)
		write_byte(COLOR_B)
		write_byte(192)
		message_end()
		
		set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_KILLBOMB)
		engfunc(EngFunc_SetModel, entity, MODEL_W)
		g_haskillbomb[owner] = 0
		
		return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
}

public fw_ThinkGrenade(entity)
{
	if(!pev_valid(entity)) return HAM_IGNORED
	
	static Float:dmgtime, Float:current_time
	pev(entity, pev_dmgtime, dmgtime)
	current_time = get_gametime()
	
	if(dmgtime > current_time) return HAM_IGNORED
	
	if(pev(entity, PEV_NADE_TYPE) == NADE_TYPE_KILLBOMB)
	{
		KillBombExplode(entity)
		return HAM_SUPERCEDE
	}
	
	return HAM_IGNORED
}

KillBombExplode(ent)
{
	if (g_roundend) return
	
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	write_coord(floatround(originF[0]))
	write_coord(floatround(originF[1]))
	write_coord(floatround(originF[2]))
	write_short(g_killbomb_spr_exp)
	write_byte(40)
	write_byte(30)
	write_byte(14)
	message_end()
	
	emit_sound(ent, CHAN_WEAPON, SOUND_EXPLODE, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	static attacker
	attacker = pev(ent, pev_owner)
	if (!is_user_connected(attacker))
	{
		engfunc(EngFunc_RemoveEntity, ent)
		return
	}
	
	static victim
	victim = -1
	
	while((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		if(!is_user_alive(victim) || zp_get_user_zombie(victim) || zp_get_human_hero(victim) || zp_get_user_last_human(victim))
			continue

		// For bomb-mask
        	ExecuteForward(g_fwUserInfectedByKBomb, g_fwDummyResult, victim)
        	if (g_fwDummyResult >= PLUGIN_HANDLED)
            		continue;  
		
		g_killedbykillbomb[victim] = 1
		ExecuteHamB(Ham_Killed, victim, attacker, 0)
		g_killedbykillbomb[victim] = 0
		
		static health; health = get_user_health(attacker)
		set_user_health(attacker, health+get_pcvar_num(cvar_bonushp))
	}
	
	engfunc(EngFunc_RemoveEntity, ent)
}