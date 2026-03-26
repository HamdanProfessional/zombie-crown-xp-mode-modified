#include <amxmodx>
#include <zombiecrown>
#include <engine>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <colored_print>

#define ID_FURY (taskid - TASK_FURY)

// Task offsets
enum (+= 100)
{
	TASK_FURY
}


// Zombie Attributes
new const zclass10_name[] = { "Cerberus"}
new const zclass10_info[] = { "Fury" }
new const zclass10_model[] = { "zc_model_zm8" }
new const zclass10_clawmodel[] = { "v_knife_zm4.mdl" }
const zclass10_health = 15000
const zclass10_speed = 450
const Float:zclass10_gravity = 1.0
const Float:zclass10_knockback = 1.0
const zclass_level = 78

new const idle[] = "zombie_crown/cereberus/cerberus_idle.wav"
new const fury[] = "zombie_crown/cereberus/cerberus_fury.wav"
new const normaly[] = "zombie_crown/cereberus/cerberus_normaly.wav"

/*================================================================================
 Customization ends here!
 Any edits will be your responsibility
=================================================================================*/  

// Variables
new g_cerberus, g_veces[33], i_fury_time[33], g_maxplayers

// Cvar Pointers
new cvar_fury, cvar_furytime

/*================================================================================
 [Init, CFG and Precache]
=================================================================================*/

public plugin_init()
{
	new registerText[32]
	formatex( registerText, sizeof registerText - 1, "[ZC %s]", zclass10_name)
	register_plugin(registerText, "1.0", "meNe")
	cvar_fury = register_cvar("zp_cerberus_fury", "1")
	cvar_furytime = register_cvar("zp_cerberus_fury_time", "10.0")
	register_logevent("roundStart", 2, "1=Round_Start")
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	g_maxplayers = get_maxplayers()
}

public plugin_precache()
{
	g_cerberus = zp_register_zombie_class(zclass10_name, zclass10_info, zclass10_model, zclass10_clawmodel, zclass10_health, zclass10_speed, zclass10_gravity, zclass10_knockback, zclass_level)
	
	precache_sound(idle)
	precache_sound(fury)
	precache_sound(normaly)
}

/*================================================================================
 [Zombie Plague Forwards]
=================================================================================*/

public zp_user_infected_post(id, infector)
{
	if (zp_get_user_zombie_class(id) == g_cerberus)
	{
		colored_print(id, GREEN, "[ZC]^x01 You have^x04 fury power^x01 - press^x04 [E].")
		
		g_veces[id] = get_pcvar_num(cvar_fury)
		i_fury_time[id] = get_pcvar_num(cvar_furytime)
		emit_sound(id, CHAN_STREAM, idle, 1.0, ATTN_NORM, 0, PITCH_HIGH)
		remove_task(id)
	}
}

public zp_user_humanized_post(taskid)
{
	new id = ID_FURY
	remove_task(id+TASK_FURY)
	set_user_godmode(id, 0)
}


/*================================================================================
 [Main Forwards]
=================================================================================*/

public fw_PlayerPreThink(id)
{
	if (!is_user_alive(id))
		return FMRES_IGNORED
	
	new button = get_user_button(id)
	new oldbutton = get_user_oldbutton(id)
	
	if (zp_get_user_zombie(id) && (zp_get_user_zombie_class(id) == g_cerberus))
	{
		if (!(oldbutton & IN_USE) && (button & IN_USE))
			clcmd_furia(id)
	}
	
	return PLUGIN_CONTINUE
}

/*================================================================================
 [Internal Functions]
=================================================================================*/
public clcmd_furia(taskid)
{
	new id = ID_FURY
	
	if(!is_user_alive(id) || !is_user_connected(id)|| !zp_get_user_zombie(id) || zp_get_zombie_hero(id) || zp_get_user_zombie_class(id) != g_cerberus)
		return PLUGIN_HANDLED
	
	if(g_veces[id] > 0)
	{
		g_veces[id] = g_veces[id] -1
		
		set_task(0.1, "effects", id+TASK_FURY, _, _, "b")
		i_fury_time[id] = get_pcvar_num(cvar_furytime)
		
		set_task(1.0, "ShowHUD", id+TASK_FURY, _, _, "a", i_fury_time[id])
		
		emit_sound(id, CHAN_STREAM, fury, 1.0, ATTN_NORM, 0, PITCH_HIGH)
	}
	else
	{
		colored_print(id, GREEN, "[ZC]^x01 You have no fury.")
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_HANDLED
}

public effects(id)
{
	if(!is_user_alive(id) || !is_user_connected(id)|| !zp_get_user_zombie(id) || zp_get_zombie_hero(id) || zp_get_user_zombie_class(id) != g_cerberus)
		return
		
	static origin[3]
	get_user_origin(id, origin)
	
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_PARTICLEBURST) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_short(130) // radius
	write_byte(70) // color
	write_byte(3) // duration (will be randomized a bit)
	message_end()
	
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_DLIGHT) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_byte(22) // radius
	write_byte(255) // r
	write_byte(0) // g
	write_byte(30) // b
	write_byte(2) // life
	write_byte(0) // decay rate
	message_end()
	
	set_user_godmode(id, 1)
	
	set_task(get_pcvar_float(cvar_furytime), "remove_fury", id)
}

public ShowHUD(id)
{
	if(is_user_alive(id))
	{
		i_fury_time[id] = i_fury_time[id] - 1;
		set_hudmessage(200, 100, 0, -1.0, -0.46, 0, 1.0, 1.1, 0.0, 0.0, -1)
		show_hudmessage(id, "Fury: %d", i_fury_time[id]+1)
	}
	else
	{
		remove_task(id+TASK_FURY)
	}
}

public remove_fury(taskid)
{
	new id = ID_FURY
	
	remove_task(id+TASK_FURY)
	
	set_user_godmode(id, 0)
	emit_sound(id, CHAN_STREAM, normaly, 1.0, ATTN_NORM, 0, PITCH_HIGH)
}

public roundStart()
{
	for(new i = 1; i <= g_maxplayers; i++)
	{
		i_fury_time[i] = get_pcvar_num(cvar_furytime)
		remove_task(i)
	}
}