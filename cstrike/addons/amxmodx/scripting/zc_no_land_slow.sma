#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "[ZC] No Landing Slowdown"
#define VERSION "1.1"
#define AUTHOR "Zombie Crown Team"

new cvar_enabled
new bool:g_InAir[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	cvar_enabled = register_cvar("zc_no_land_slow", "1")

	// Hook when player lands
	RegisterHam(Ham_Player_Jump, "player", "fw_Player_Jump_Post", 1)
	RegisterHam(Ham_Player_PreThink, "player", "fw_Player_PreThink")
	RegisterHam(Ham_Player_PostThink, "player", "fw_Player_PostThink", 1)
}

public fw_Player_Jump_Post(id)
{
	if(!get_pcvar_num(cvar_enabled))
		return
	if(!is_user_alive(id))
		return

	g_InAir[id] = true
}

public fw_Player_PreThink(id)
{
	if(!get_pcvar_num(cvar_enabled))
		return HAM_IGNORED
	if(!is_user_alive(id))
		return HAM_IGNORED

	static oldflags[33]
	new flags = pev(id, pev_flags)

	// Check if player just landed (was in air, now on ground)
	if(g_InAir[id] && (flags & FL_ONGROUND) && !(oldflags[id] & FL_ONGROUND))
	{
		g_InAir[id] = false

		// Get current velocity before CS modifies it
		new Float:vel[3]
		pev(id, pev_velocity, vel)

		// Store horizontal velocity
		new Float:preserve_vel[3]
		preserve_vel[0] = vel[0]
		preserve_vel[1] = vel[1]
		preserve_vel[2] = 0.0

		// Set it in PostThink
		set_pev(id, pev_velocity, preserve_vel)

		// Remove fall damage
		set_pdata_float(id, 251, 0.0, 5) // m_flFallVelocity

		// Prevent friction
		set_pdata_float(id, 229, 0.0, 5) // m_fFriction
	}

	// Track if player goes back in air
	if(flags & FL_ONGROUND)
	{
		new Float:vel[3]
		pev(id, pev_velocity, vel)
		if(vel[2] > 50.0)
		{
			g_InAir[id] = true
		}
	}

	oldflags[id] = flags
	return HAM_IGNORED
}

public fw_Player_PostThink(id)
{
	if(!get_pcvar_num(cvar_enabled))
		return
	if(!is_user_alive(id))
		return

	static Float:last_land_time[33]
	new flags = pev(id, pev_flags)
	new Float:time = get_gametime()

	// For 0.3 seconds after landing, preserve horizontal speed
	if(flags & FL_ONGROUND && time - last_land_time[id] < 0.3)
	{
		new Float:vel[3]
		pev(id, pev_velocity, vel)

		// Ensure we're not stuck and maintain movement
		if(floatabs(vel[0]) > 5.0 || floatabs(vel[1]) > 5.0)
		{
			// Check if player is trying to move
			new move_type = pev(id, pev_movetype)
			if(move_type == MOVETYPE_WALK)
			{
				// Keep the momentum
				set_pev(id, pev_velocity, vel)

				// Zero out friction to prevent slowdown
				set_pdata_float(id, 229, 0.0, 5)
			}
		}
	}

	// Detect landing
	static oldflags[33]
	if((flags & FL_ONGROUND) && !(oldflags[id] & FL_ONGROUND))
	{
		last_land_time[id] = time

		// Completely disable fall velocity
		set_pdata_float(id, 251, 0.0, 5)
		set_pdata_int(id, 244, 0, 5)
	}

	oldflags[id] = flags
}

public client_disconnect(id)
{
	g_InAir[id] = false
}
