#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombiecrown>
#include <colored_print>

// Zombie Attributes
new const zclass_name[] = "Crawl Zombie" // name
new const zclass_info[] = "Full-Time Duck" // description
new const zclass_model[] = "zc_model_zm11" // model
new const zclass_clawmodel[] = "v_knife_zm8.mdl" // claw model
const zclass_health = 8957 // health
const zclass_speed = 1175 // speed
const Float:zclass_gravity = 0.5 // gravity
const Float:zclass_knockback = 0.8 // knockback
const zclass_level = 40

// Class IDs
new g_zcrawl

// Player is ducked
new g_ducked[33]

// Get server's max players and speed | Create a custom chat print
new g_maxplayers, g_maxspeed

public plugin_init()
{
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_logevent("logevent_round_end", 2, "1=Round_End")
	
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	
	g_maxplayers = get_maxplayers()
	g_maxspeed = get_cvar_pointer("sv_maxspeed")
}

// Zombie Classes MUST be registered on plugin_precache
public plugin_precache()
{
	new registerText[32]
	formatex(registerText, sizeof registerText - 1, "[ZC %s]", zclass_name)
	register_plugin(registerText, "1.0", "meNe")
	// Register the new class and store ID for reference
	g_zcrawl = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_level)
}

// User Infected forward
public zp_user_infected_post(id, infector, nemesis, assassin, genesys, oberon, dragon, nighter)
{
	// Check if the player has been turned into nemesis
	if (nemesis || genesys || assassin || genesys || oberon || dragon || nighter)
	{
		unduck_player(id)
		g_ducked[id] = false
		return;
	}
	
	if (zp_get_user_zombie_class(id) != g_zcrawl)
	{
		g_ducked[id] = false
		return;
	}
	
	client_cmd(id, "cl_forwardspeed %d; cl_backspeed %d; cl_sidespeed %d", Float:zclass_speed, Float:zclass_speed, Float:zclass_speed)
	g_ducked[id] = true
}

// User Humanized forward
public zp_user_humanized_post(id, survivor)
{
	// Stand up
	unduck_player(id)
	g_ducked[id] = false
}

// Player has just connected/reconnected
public client_connect(id)
	g_ducked[id] = false

// Client is disconnecting
public client_disconnect(id)
	// Stop ducking
	unduck_player(id)

// Forward Player PreThink
public fw_PlayerPreThink(id)
{
	// Checks...
	if (zp_get_zombie_hero(id) || !zp_get_user_zombie(id) || is_user_bot(id)
	|| zp_get_user_zombie_class(id) != g_zcrawl || !is_user_alive(id))
		return;
	
	// Make the player crouch
	set_pev(id, pev_bInDuck, 1)
	client_cmd(id, "+duck")
	
	g_ducked[id] = true
}

// Ham Player Killed Forward
public fw_PlayerKilled(id)
{
	// Make the player stand up
	unduck_player(id)
	
	g_ducked[id] = false
}

// Log Event Round End
public logevent_round_end()
{
	static id
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		// Some extra checks on round end aren't bad...i think
		if (zp_get_zombie_hero(id) || !zp_get_user_zombie(id) || zp_get_user_zombie_class(id) != g_zcrawl || !is_user_alive(id))
			g_ducked[id] = false
		else
			g_ducked[id] = true
	}
}

// Event Round Start
public event_round_start()
{
	// Make sure the server isn't blocking our zombie's speed
	if (get_pcvar_float(g_maxspeed) < Float:zclass_speed)
		server_cmd("sv_maxspeed 99999") // Better than setting it to the zombie speed value
	
	static id
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		// Get the hell up
		unduck_player(id)
		
		g_ducked[id] = false
	}
}

// Make the player stand up
public unduck_player(id)
{
	// Isn't ducked | Is a bot
	if (!g_ducked[id] || is_user_bot(id))
		return;
	
	set_pev(id, pev_bInDuck, 0)
	client_cmd(id, "-duck")
	client_cmd(id, "-duck") // Prevent death spectator camera bug
}