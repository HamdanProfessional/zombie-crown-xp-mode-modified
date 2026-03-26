#include <amxmodx>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <cstrike>
#include <zombiecrown>
#include <colored_print>

// Task offsets
enum (+= 100) {
	TASK_AURA
}

#define ID_AURA (taskid - TASK_AURA)

// Fleshpound Zombie
new const zclass_name[] = { "Fleshpound" } 
new const zclass_info[] = { "Powerful Rage" } 
new const zclass_model[] = { "zc_model_zm2" } // model
new const zclass_clawmodel[] = { "v_knife_zm2.mdl" } 
const zclass_health = 15100
const zclass_speed = 480
const Float:zclass_gravity = 0.8
const Float:zclass_knockback = 1.0
const zclass_level = 70

new g_Rage[] = "zombie_crown/fleshpound/fleshpound_rage.wav"

// Cooldown hook
new Float:g_iLastFury[33]

new g_speed[33]
new r, g, b
new g_maxplayers

new cvar_fury_cooldown
new g_KfFleshpound

public plugin_init()
{
    	new registerText[32]
    	formatex(registerText, sizeof registerText - 1, "[ZC %s]", zclass_name)
    	register_plugin(registerText, "1.0", "meNe")
	cvar_fury_cooldown = register_cvar("zp_fleshpound_cooldown", "15.0")
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1)
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	register_forward(FM_PlayerPreThink, "client_prethink")
	register_logevent("roundStart", 2, "1=Round_Start")
	g_maxplayers = get_maxplayers()
} 

public plugin_precache()										
{
	g_KfFleshpound = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_level)
	precache_sound(g_Rage)
}

public zp_user_infected_post(id, infector)
{
	if (zp_get_user_zombie_class(id) == g_KfFleshpound)
	{
		if(zp_get_user_nemesis(id))
			return
		
		colored_print(id, GREEN, "[ZC]^x01 To use rage, press^x04 E^x01.")
		r = 255
		g = 255
		b = 0
		set_task(0.1, "fleshpound_aura", id+TASK_AURA, _, _, "b")
	}
}

public zp_user_humanized_post(id)
{
	remove_task(id+TASK_AURA)
	g_speed[id] = 0
}

public client_disconnect(id)
	remove_task(id+TASK_AURA)

// Ham Player Spawn Post Forward
public fw_PlayerSpawn_Post(id)
{
	// Not alive or didn't join a team yet
	if (!is_user_alive(id) || !cs_get_user_team(id))
		return;
	
	// Remove previous tasks
	remove_task(id+TASK_AURA)
}

public fw_PlayerPreThink(id)
{
	if(!is_user_alive(id))
		return;
	
	static iButton; iButton = pev(id, pev_button)
	static iOldButton; iOldButton = pev(id, pev_oldbuttons)
	
	if(zp_get_user_zombie(id) && (zp_get_user_zombie_class(id) == g_KfFleshpound) && !zp_get_user_nemesis(id))
	{
		if((iButton & IN_USE) && !(iOldButton & IN_USE))
			MakeRage(id)
	}
}

public MakeRage(id)
{
	if(get_gametime() - g_iLastFury[id] < get_pcvar_float(cvar_fury_cooldown))
	{
		colored_print(id, GREEN, "[ZC]^x01 Wait^x04 %.1f^x01 seconds, to return to rage.", get_pcvar_float(cvar_fury_cooldown)-(get_gametime() - g_iLastFury[id]))
		return PLUGIN_HANDLED
	}
	
	g_iLastFury[id] = get_gametime()
	
	r = 255
	g = 0
	b = 0
	
	g_speed[id] = 1
	emit_sound(id, CHAN_STREAM, g_Rage, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	set_task(5.0, "normal", id)
	
	return PLUGIN_HANDLED
}


public normal(id)
{
	r = 255
	g = 255
	b = 0
	g_speed[id] = 0
	colored_print(id, GREEN, "[ZC]^x01 You're back to normal.") 
}

public client_prethink(id)
{
	if (zp_get_user_zombie_class(id) == g_KfFleshpound)
	{
		if(is_user_alive(id) && zp_get_user_zombie(id) && (zp_get_user_zombie_class(id) == g_KfFleshpound) && !zp_get_user_nemesis(id))
			Action(id)
	}
}

public Action(id)
{
	if(g_speed[id] == 1)
	{
		set_pev(id, pev_maxspeed, 800.0)
	}
	else if(g_speed[id] == 0)
	{
		set_pev(id, pev_maxspeed, 480.0)
	}
	
	return PLUGIN_HANDLED;
}

// Fleshpound aura task
public fleshpound_aura(taskid)
{
	if(!is_user_alive(ID_AURA))
	{
		// Task not needed anymore
		remove_task(taskid);
		return;
	}
	
	if(zp_get_user_nemesis(ID_AURA))
	{
		// Task not needed anymore
		remove_task(taskid);
		return;
	}
	
	// Set aura for fleshpound
	if (zp_get_user_zombie_class(ID_AURA) == g_KfFleshpound)
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
		write_byte(13) // radius
		write_byte(r) // r
		write_byte(g) // g
		write_byte(b) // b
		write_byte(1) // life
		write_byte(0) // decay rate
		message_end()
	}
	else
	{
		// Task not needed anymore
		remove_task(taskid);
		return;
	}
}

public roundStart()
{
	for (new i = 1; i <= g_maxplayers; i++)
	{
		remove_task(i+TASK_AURA)
		g_speed[i] = 0
	}
}