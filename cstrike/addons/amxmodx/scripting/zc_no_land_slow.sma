#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "[ZC] No Landing Slowdown"
#define VERSION "1.0"
#define AUTHOR "Zombie Crown Team"

new cvar_enabled
new Float:g_LandTime[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	cvar_enabled = register_cvar("zc_no_land_slow", "1")

	// Hook player think to check for landing
	RegisterHam(Ham_Player_PreThink, "player", "fw_PlayerPreThink")
	RegisterHam(Ham_Player_PostThink, "player", "fw_PlayerPostThink", 1)

	// Hook when player touches ground
	register_forward(FM_Touch, "fw_Touch")
}

public fw_PlayerPreThink(id)
{
	if(!get_pcvar_num(cvar_enabled))
		return HAM_IGNORED
	if(!is_user_alive(id))
		return HAM_IGNORED

	// Get player flags
	new flags = pev(id, pev_flags)

	// Check if player just landed (FL_ONGROUND bit is set now but wasn't before)
	if(flags & FL_ONGROUND)
	{
		new Float:vel[3]
		pev(id, pev_velocity, vel)

		// If player has significant downward velocity, they just landed
		if(vel[2] < -100.0)
		{
			g_LandTime[id] = get_gametime()

			// Preserve horizontal momentum
			// Remove the slowdown that CS applies after landing

			// Also reduce fall damage
			set_pdata_int(id, 244, 0, 5) // m_fFallVelocity
		}
	}

	return HAM_IGNORED
}

public fw_PlayerPostThink(id)
{
	if(!get_pcvar_num(cvar_enabled))
		return

	if(!is_user_alive(id))
		return

	// Check if recently landed (within 0.5 seconds)
	new Float:time = get_gametime()
	if(time - g_LandTime[id] < 0.5)
	{
		// Preserve momentum - don't apply slowdown
		new Float:vel[3]
		pev(id, pev_velocity, vel)

		// Ensure horizontal velocity is maintained
		// CS normally reduces this after landing
		if(floatabs(vel[0]) > 1.0 || floatabs(vel[1]) > 1.0)
		{
			// Maintain current speed
			set_pev(id, pev_velocity, vel)

			// Clear any friction that might be applied
			set_pdata_float(id, 229, 0.0, 5) // m_fFriction
		}
	}
}

public fw_Touch(ent, id)
{
	if(!get_pcvar_num(cvar_enabled))
		return FMRES_IGNORED

	if(!is_user_alive(id))
		return FMRES_IGNORED

	// When player touches ground (world or brushes)
	static classname[32]
	pev(ent, pev_classname, classname, charsmax(classname))

	if(equal(classname, "worldspawn") || equal(classname, "func_wall") || equal(classname, "func_breakable"))
	{
		new flags = pev(id, pev_flags)

		// If player is in air and now touching ground
		if(flags & FL_ONGROUND)
		{
			new Float:vel[3]
			pev(id, pev_velocity, vel)

			// Preserve momentum when landing
			if(floatabs(vel[0]) > 1.0 || floatabs(vel[1]) > 1.0)
			{
				// Don't let CS apply landing slowdown
				set_pev(id, pev_velocity, vel)

				// Prevent fall damage
				set_pdata_int(id, 244, 0, 5) // m_fFallVelocity
			}
		}
	}

	return FMRES_IGNORED
}

// Also hook fall damage to completely eliminate it
public client_PreThink(id)
{
	if(!get_pcvar_num(cvar_enabled))
		return

	if(!is_user_alive(id))
		return

	// Completely disable fall damage
	set_pdata_float(id, 251, 0.0, 5) // m_flFallVelocity
	set_pdata_int(id, 244, 0, 5) // m_fFallVelocity
}
