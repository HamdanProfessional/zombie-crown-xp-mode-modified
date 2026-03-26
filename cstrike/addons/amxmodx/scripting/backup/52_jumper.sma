#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <zombiecrown>
#include <colored_print>

new const zclass_name[] = "SuperJump"
new const zclass_info[] = "50 Jumps"
new const zclass_model[] = { "zc_model_zm4" }
new const zclass_clawmodel[] = "v_knife_zm4.mdl" // claw model
const zclass_health = 13000
const zclass_speed = 410
const Float:zclass_gravity = 1.0
const Float:zclass_knockback = 1.0
const zclass_level = 52

new Jumpnum[33] = false 
new bool:canJump[33] = false
new g_zclass_super_jumper, g_super_jumper_maxjumps

public plugin_init() 
{
	new registerText[32]
	formatex( registerText, sizeof registerText - 1, "[ZC %s]", zclass_name)
	register_plugin(registerText, "1.0", "meNe")	
	g_super_jumper_maxjumps = register_cvar("zp_super_jumper_zombie_maxjumps", "50")
	register_forward(FM_PlayerPreThink, "fm_PlayerPreThink")
	register_forward(FM_PlayerPostThink, "fm_PlayerPostThink")		
}

public plugin_precache()
{
	g_zclass_super_jumper = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_level)
}

public client_putinserver(id)
{
	Jumpnum[id] = 0
	canJump[id] = false
}

public client_disconnect(id)
{
	Jumpnum[id] = 0
	canJump[id] = false
}

public zp_user_infected_post(player, infector)
{
	if (zp_get_user_zombie_class(player) == g_zclass_super_jumper)
	{
		canJump[player] = true
		Jumpnum[player] = true
	}
}

public fm_PlayerPreThink(id)
{
	if (!is_user_alive(id) || !zp_get_user_zombie(id))
		return FMRES_IGNORED
	
	if (zp_get_user_zombie_class(id) != g_zclass_super_jumper)
		return FMRES_IGNORED
		
	new nbut = pev(id, pev_button)
	new obut = pev(id, pev_oldbuttons)
	
	if ((nbut & IN_JUMP) && !(pev(id, pev_flags) & FL_ONGROUND) && !(obut & IN_JUMP))
	{
		if (Jumpnum[id] < get_pcvar_num(g_super_jumper_maxjumps))
		{
			canJump[id] = true 
			Jumpnum[id]++
			colored_print(id, GREEN, "[ZC]^x01 You did^x04 %d^x01/^x04 %d^x01 jumps.", Jumpnum[id], get_pcvar_num(g_super_jumper_maxjumps))
		}
		else
		{
			colored_print(id, GREEN, "[ZC]^x01 You did maximum jumps number this round.")
		}
	}
	
	else if ((nbut & IN_JUMP) && !(pev(id, pev_flags) & FL_ONGROUND) && !(obut & IN_JUMP))
	{
		if (Jumpnum[id] == get_pcvar_num(g_super_jumper_maxjumps) || (nbut & IN_JUMP))
		{
			canJump[id] = false
			Jumpnum[id] = false
		}
	}
	return FMRES_IGNORED
}

public fm_PlayerPostThink(id)
{
	if (!is_user_alive(id) || !zp_get_user_zombie(id)) 
		return FMRES_IGNORED
	
	if (zp_get_user_zombie_class(id) != g_zclass_super_jumper)
		return FMRES_IGNORED

	if (canJump[id] == true)
	{
		new Float:velocity[3]	
		pev(id, pev_velocity, velocity)
		velocity[2] = random_float(265.0,285.0)
		set_pev(id, pev_velocity, velocity)
		canJump[id] = false
		return FMRES_IGNORED
	}
	return FMRES_IGNORED
}
