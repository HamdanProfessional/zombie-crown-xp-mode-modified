#include <amxmodx>
#include <fakemeta>
#include <zombiecrown>

new g_zclass_bhzombie, g_hasBhop[33], pcvar_enabled, pcvar_autojump, bool:g_restorevel[33], Float:g_velocity[33][3]

new const zclass_name[] = { "BunnyHopZM" }
new const zclass_info[] = { "BunnyHop" }
new const zclass_model[] = { "zc_model_zm2" }
new const zclass_clawmodel[] = "v_knife_zm2.mdl" // claw model
const zclass_health = 11500
const zclass_speed = 250
const Float:zclass_gravity = 0.9
const Float:zclass_knockback = 0.0
const zclass_level = 4

public plugin_init()
{
	new registerText[32]
	formatex(registerText, sizeof registerText - 1, "[ZC %s]", zclass_name)
	register_plugin(registerText, "1.0", "meNe")
	register_event("DeathMsg", "event_player_death", "a")
	pcvar_enabled = register_cvar("zp_bhzombie_bunnyhop_enabled", "1")
	pcvar_autojump = register_cvar("zp_bhzombie_autojump", "1")
	register_forward(FM_PlayerPreThink, "forward_prethink")
}

public plugin_precache()
{
	g_zclass_bhzombie = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_level)
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink_Post", 1)
}

public zp_user_infected_post(id, infector)
{
	if (zp_get_user_zombie_class(id) == g_zclass_bhzombie)
	{
		g_hasBhop[id] = true
		pev(id, pev_velocity, g_velocity[id])
	}
}

public client_connect(id)
{
	g_hasBhop[id] = false
}

public event_player_death()
{
	g_hasBhop[read_data(2)] = false
}

public forward_prethink(id)
{
	if(!is_user_alive(id) || !zp_get_user_zombie(id))
 		return PLUGIN_CONTINUE

        if (zp_get_user_zombie_class(id) != g_zclass_bhzombie)
		return PLUGIN_CONTINUE

	if(get_pcvar_num(pcvar_enabled))
	{
		set_pev(id, pev_fuser2, 0.0)
		if(get_pcvar_num(pcvar_autojump) && pev(id, pev_button) & IN_JUMP)
		{
			new szFlags = pev(id, pev_flags)
			if(!(szFlags & FL_WATERJUMP) && pev(id, pev_waterlevel) < 2 && szFlags & FL_ONGROUND)
			{
				new Float: szVelocity[3]
				pev(id, pev_velocity, szVelocity)
				szVelocity[2] += 250.0
				set_pev(id, pev_velocity, szVelocity)
				set_pev(id, pev_gaitsequence, 6)
			}
		}
	}
        return FMRES_IGNORED
}

public fw_PlayerPreThink(id)
{	
	if (!is_user_alive(id) || !is_user_bot(id) || !zp_get_user_zombie(id))
		return FMRES_IGNORED
	
	if (zp_get_user_zombie_class(id) != g_zclass_bhzombie)
		return FMRES_IGNORED
		
	if (pev(id, pev_flags) & FL_ONGROUND)
	{
		pev(id, pev_velocity, g_velocity[id])
		g_restorevel[id] = true
	}
	return FMRES_IGNORED
}

public fw_PlayerPreThink_Post(id)
{
	if (zp_get_user_zombie_class(id) != g_zclass_bhzombie)
		return FMRES_IGNORED
		
	if (g_restorevel[id])
	{
		g_restorevel[id] = false
		if (!(pev(id, pev_flags) & FL_ONTRAIN))
		{
			new groundent = pev(id, pev_groundentity)
			if (pev_valid(groundent) && (pev(groundent, pev_flags) & FL_CONVEYOR))
			{	
				static Float:vecTemp[3]
				pev(id, pev_basevelocity, vecTemp)
				g_velocity[id][0] += vecTemp[0]
				g_velocity[id][1] += vecTemp[1]
				g_velocity[id][2] += vecTemp[2]
			}                
			set_pev(id, pev_velocity, g_velocity[id])
			return FMRES_HANDLED
		}
	}
	return FMRES_IGNORED
}