#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "[ZC] No Landing Slowdown"
#define VERSION "1.2"
#define AUTHOR "Zombie Crown Team"

new cvar_enabled
new Float:g_LandTime[33]
new Float:g_PreservedVel[33][3]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	cvar_enabled = register_cvar("zc_no_land_slow", "1")

	// Hook player jump and land
	RegisterHam(Ham_Player_Jump, "player", "fw_Player_Jump_Post", 1)

	// PreThink to detect landing and preserve velocity
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")

	// PostThink to restore preserved velocity
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink", 1)
}

public fw_Player_Jump_Post(id)
{
	if(!get_pcvar_num(cvar_enabled))
		return
	if(!is_user_alive(id))
		return

	// Player is now in air, start tracking
	new flags = pev(id, pev_flags)
	if(flags & FL_ONGROUND)
	{
		// Just jumped
	}
}

public fw_PlayerPreThink(id)
{
	if(!get_pcvar_num(cvar_enabled))
		return FMRES_IGNORED
	if(!is_user_alive(id))
		return FMRES_IGNORED

	static oldflags[33]
	new flags = pev(id, pev_flags)

	// Detect landing: was in air, now on ground
	if(!(oldflags[id] & FL_ONGROUND) && (flags & FL_ONGROUND))
	{
		// Just landed - preserve current horizontal velocity
		new Float:vel[3]
		pev(id, pev_velocity, vel)

		g_PreservedVel[id][0] = vel[0]
		g_PreservedVel[id][1] = vel[1]
		g_PreservedVel[id][2] = 0.0  // Reset Z velocity

		g_LandTime[id] = get_gametime()

		// Remove fall damage
		set_pdata_float(id, 251, 0.0, 5) // m_flFallVelocity
		set_pdata_int(id, 244, 0, 5)     // m_fFallVelocity
	}

	oldflags[id] = flags
	return FMRES_IGNORED
}

public fw_PlayerPostThink(id)
{
	if(!get_pcvar_num(cvar_enabled))
		return FMRES_IGNORED
	if(!is_user_alive(id))
		return FMRES_IGNORED

	new Float:time = get_gametime()

	// For 0.5 seconds after landing, preserve horizontal speed
	if(time - g_LandTime[id] < 0.5)
	{
		// Check if player is moving
		new Float:vel[3]
		pev(id, pev_velocity, vel)

		new Float:speed = floatsqroot(vel[0]*vel[0] + vel[1]*vel[1])

		// If there's preserved speed to maintain
		if(speed > 1.0)
		{
			// Use the greater of current or preserved velocity
			new Float:preserve_speed = floatsqroot(g_PreservedVel[id][0]*g_PreservedVel[id][0] + g_PreservedVel[id][1]*g_PreservedVel[id][1])

			if(preserve_speed > speed)
			{
				// Restore preserved velocity
				vel[0] = g_PreservedVel[id][0]
				vel[1] = g_PreservedVel[id][1]
				vel[2] = vel[2]  // Keep current Z velocity

				set_pev(id, pev_velocity, vel)

				// Remove friction
				set_pdata_float(id, 229, 0.0, 5) // m_fFriction
			}
		}
	}
	else if(time - g_LandTime[id] >= 0.5 && time - g_LandTime[id] < 0.6)
	{
		// After preservation period, gradually fade
		new Float:vel[3]
		pev(id, pev_velocity, vel)

		// Slight boost to maintain momentum
		if(floatabs(vel[0]) > 1.0 || floatabs(vel[1]) > 1.0)
		{
			set_pev(id, pev_velocity, vel)
			set_pdata_float(id, 229, 0.0, 5)
		}
	}

	return FMRES_IGNORED
}

public client_disconnect(id)
{
	g_LandTime[id] = 0.0
	g_PreservedVel[id][0] = 0.0
	g_PreservedVel[id][1] = 0.0
	g_PreservedVel[id][2] = 0.0
}
