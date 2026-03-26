#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <zombiecrown>
#include <colored_print>

new g_zclass_crow
new bool:has_jp[33];
new const CVAR_JP_SPEED[]  = "jp_speed";

// Crow Zombie Atributes
new const zclass_name[] = { "Crow Zombie" } // name
new const zclass_info[] = { "Can Fly" } // description
new const zclass_model[] = { "zc_model_zm9" } // model
new const zclass_clawmodel[] = { "v_knife_zm3.mdl" } // claw model
const zclass_health = 10000
const zclass_speed = 600
const Float:zclass_gravity = 0.45
const Float:zclass_knockback = 1.0
const zclass_level = 86

public plugin_init()
{
	new registerText[32]
	formatex(registerText, sizeof registerText - 1, "[ZC %s]", zclass_name)
	register_plugin(registerText, "1.0", "meNe")
	register_cvar(CVAR_JP_SPEED, "250");
}

public plugin_precache()
{
	g_zclass_crow = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_level)
}

public client_PreThink(id) 
{
	if(!is_user_alive(id) || !zp_get_user_zombie(id)) 
		return PLUGIN_CONTINUE
	if(zp_get_user_zombie_class(id) == g_zclass_crow && !zp_get_zombie_hero(id)) 
	{
		new Float:fAim[3] , Float:fVelocity[3];
		VelocityByAim(id , get_cvar_num(CVAR_JP_SPEED) , fAim);
	
		if(!(get_user_button(id) & IN_JUMP))
		{
			fVelocity[0] = fAim[0];
			fVelocity[1] = fAim[1];
			fVelocity[2] = fAim[2];

			set_user_velocity(id , fVelocity);
			fm_set_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 16);
		}
	}
	return PLUGIN_CONTINUE;
}

// User Infected forward
public zp_user_infected_post(id, infector)
{		
	if (zp_get_user_zombie_class(id) == g_zclass_crow)
	{
		has_jp[id] = true
	}	
}

// Set entity's rendering type (from fakemeta_util)
stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16)
{
	static Float:color[3]
	color[0] = float(r)
	color[1] = float(g)
	color[2] = float(b)
	
	set_pev(entity, pev_renderfx, fx)
	set_pev(entity, pev_rendercolor, color)
	set_pev(entity, pev_rendermode, render)
	set_pev(entity, pev_renderamt, float(amount))
}