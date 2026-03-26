#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <xs>
#include <engine>
#include <zombiecrown>

/*================================================================================
 [Plugin Customization]
=================================================================================*/

new const zclass_name[] = { "Houndeye" } 
new const zclass_info[] = { "Blast Power - E" } 
new const zclass_model[] = { "zc_model_zm10" } 
new const zclass_clawmodel[] = { "v_knife_zm7.mdl" } 
const zclass_health = 14000 
const zclass_speed = 420 
const Float:zclass_gravity = 0.9
const Float:zclass_knockback = 1.0
const zclass_level = 8

new const beam_cylinder[] = "sprites/white.spr"

new const houndeye_attack[][] = { "zombie_crown/houndeye/he_attack1.wav", "zombie_crown/houndeye/he_attack3.wav" }
new const houndeye_blast[][] = { "zombie_crown/houndeye/he_blast1.wav", "zombie_crown/houndeye/he_blast3.wav" }

/*================================================================================
 [End Customization]
=================================================================================*/

#define is_player(%0)    (1 <= %0 <= giMaxplayers)
#define TASK_BARTIME 16000

// Zombie vars
new gMsgBarTime, gMsgDeathMsg, gSprBeam, gHoundEye, giMaxplayers, cvar_timeblast, cvar_radius, cvar_blast_infect,
cvar_damage, cvar_damage_amount

public plugin_init()
{
	new registerText[32]
	formatex( registerText, sizeof registerText - 1, "[ZC %s]", zclass_name)
	register_plugin(registerText, "1.0", "meNe")
	cvar_timeblast = register_cvar("zp_houndeye_timeblast", "2.5")
	cvar_radius = register_cvar("zp_houndeye_radius", "150.0")
	cvar_blast_infect = register_cvar("zp_houndeye_infect", "0")
	cvar_damage = register_cvar("zp_houndeye_damage", "0")
	cvar_damage_amount = register_cvar("zp_houndeye_damage_amount", "25")
	register_forward( FM_CmdStart, "CmdStart")
	giMaxplayers = get_maxplayers()
	gMsgBarTime = get_user_msgid("BarTime")
	gMsgDeathMsg = get_user_msgid("DeathMsg")
}

public plugin_precache()
{
	gHoundEye = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_level) 
	gSprBeam = precache_model(beam_cylinder)
	
	for (new i = 0; i < sizeof houndeye_attack; i++)
		engfunc(EngFunc_PrecacheSound, houndeye_attack[i])
	for (new i = 0; i < sizeof houndeye_blast; i++)
		engfunc(EngFunc_PrecacheSound, houndeye_blast[i])
}

public CmdStart(id, handle, random_seed)
{
	if(!is_user_alive(id))
		return;

        static iButton; iButton = (get_uc(handle, UC_Buttons) & IN_USE)
	static iOldButton; iOldButton = (get_user_oldbutton(id) & IN_USE)
	
	if(zp_get_user_zombie(id) && (zp_get_user_zombie_class(id) == gHoundEye) && !zp_get_zombie_hero(id))
	{
		if(iButton && !iOldButton)
		{
			if(!is_user_alive(id))
				return;

			message_begin(MSG_ONE, gMsgBarTime, _, id)
			write_byte(get_pcvar_num(cvar_timeblast))
			write_byte(0)
			message_end()
			emit_sound(id, CHAN_VOICE, houndeye_attack[random_num(0, sizeof houndeye_attack - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
			set_task(get_pcvar_float(cvar_timeblast), "blast_players", id+TASK_BARTIME)
		}
			
		if( iOldButton && !iButton )
			set_task(0.1, "blast_stop", id)
	}
}

public blast_stop(id)
{
	message_begin(MSG_ONE, gMsgBarTime, _, id)
	write_byte(0)
	write_byte(0)
	message_end()
	
	remove_task(id+TASK_BARTIME)
}

public blast_players(id)
{
	id -= TASK_BARTIME
	
	new Float: iOrigin[3]
	pev(id, pev_origin, iOrigin)
	
	emit_sound(id, CHAN_VOICE, houndeye_blast[random_num(0, sizeof houndeye_blast - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, iOrigin, 0)
	write_byte(TE_BEAMCYLINDER)
	engfunc(EngFunc_WriteCoord, iOrigin[0])
	engfunc(EngFunc_WriteCoord, iOrigin[1])
	engfunc(EngFunc_WriteCoord, iOrigin[2])
	engfunc(EngFunc_WriteCoord, iOrigin[0])
	engfunc(EngFunc_WriteCoord, iOrigin[1])
	engfunc(EngFunc_WriteCoord, iOrigin[2]+385.0)
	write_short(gSprBeam)
	write_byte(0)
	write_byte(0)
	write_byte(4)
	write_byte(60)
	write_byte(0)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(200)
	write_byte(0)
	message_end()
	
	static Ent, Float: originF[3]
	
	while( (Ent = engfunc(EngFunc_FindEntityInSphere, Ent, iOrigin, get_pcvar_float(cvar_radius))) )
	{
		if( is_player(Ent) && Ent != id )
		{
			if(zp_get_user_zombie(Ent))
				return PLUGIN_CONTINUE;
				
			if(get_pcvar_num(cvar_blast_infect))
			{
				zp_infect_user(Ent, 1)
				SendDeathMsg(id, Ent)
			}
			
			if(get_pcvar_num(cvar_damage))
			{
				if(zp_get_human_hero(Ent))
					return PLUGIN_CONTINUE;
				
				fm_set_user_health(Ent, pev(Ent, pev_health) - get_pcvar_num(cvar_damage_amount))
			}
			
			pev(Ent, pev_origin, originF)
			
			originF[0] = (originF[0] - iOrigin[0]) * 10.0 
			originF[1] = (originF[1] - iOrigin[1]) * 10.0 
			originF[2] = (originF[2] - iOrigin[2]) + 500.0
			
			set_pev(Ent, pev_velocity, originF)
		}
	}
	
	return PLUGIN_HANDLED;
}

SendDeathMsg(attacker, victim)
{
	message_begin(MSG_BROADCAST, gMsgDeathMsg)
	write_byte(attacker)
	write_byte(victim)
	write_byte(1)
	write_string("infection")
	message_end()
}

/*================================================================================
 [Stocks]
=================================================================================*/
stock fm_set_user_health(id, health)
{
	(health > 0) ? set_pev(id, pev_health, float(health)) : dllfunc(DLLFunc_ClientKill, id);
}