#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombiecrown>
#include <colored_print>

new const zclass_name[] = { "Doom" } 
new const zclass_info[] = { "Can make traps" } 
new const zclass_model[] = { "zc_model_zm5" }
new const zclass_clawmodel[] = "v_knife_zm5.mdl" // claw model
const zclass_health = 16000
const zclass_speed = 390
const Float:zclass_gravity = 0.88
const Float:zclass_knockback = 1.0
new const g_trap_sound[] = "zombie_crown/doom/trap.wav" 
new const model[] = "models/trap.mdl"  
const zclass_level = 20

new bool: g_Traped[33]
new spr[] = { "sprites/trap.spr" }
new Float:g_last_use[33], Float:trap_time[33]
new CVAR_INTRAPTIME, CVAR_MAXTRAPS, CVAR_TRAPDELAY, CVAR_SPR_SCALE
new Traps[33]
new g_zclass_doom

public plugin_init()
{	
	register_forward(FM_PlayerPreThink, "fw_PreThink" )
	register_forward(FM_Touch, "fw_touch")
	register_forward(FM_Think, "fw_think")
	register_forward(FM_AddToFullPack, "fw_full_pack", 1)	
	register_logevent("KillEnts", 2, "0=World triggered", "1=Round_Start")
	register_logevent("KillEnts", 2, "0=World triggered", "1=Round_End")
	register_clcmd("drop", "useskill")
	CVAR_INTRAPTIME = register_cvar("zp_intrap_time", "3") //Время в Ловушке
	CVAR_MAXTRAPS = register_cvar("zp_max_traps", "3") //Максимальное количество Ловушек
	CVAR_TRAPDELAY = register_cvar("zp_trapdelay", "3") //Реюз для создания новой Ловушки
	CVAR_SPR_SCALE = register_cvar("zp_trapspr_scale", "1.0") //Размер спрайта
	RegisterHam(Ham_Spawn, "player", "Spawn", 1)	
}

public plugin_precache()
{
	new registerText[32]
	formatex( registerText, sizeof registerText - 1, "[ZC %s]", zclass_name)
	register_plugin(registerText, "1.0", "meNe")
	g_zclass_doom = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_level)	
	precache_model(spr)
	precache_sound(g_trap_sound[0])
	precache_model(model)
}

public zp_user_infected_post(id, infector)
{
	if (zp_get_user_zombie_class(id) == g_zclass_doom  && !zp_get_user_nemesis(id) && !zp_get_user_assassin(id) && !zp_get_user_oberon(id) && !zp_get_user_genesys(id))
	{
		colored_print(id, GREEN, "[ZC]^x01 Nou you are Doom Zombie.")
		Traps[id] = 0
	}
	if(g_Traped[id])
	{
		g_Traped[id] = false
		
	}
}

public KillEnts()
{
	set_task(1.0, "kill_traps")
}

public fw_full_pack(es, e, ent, host, hostflags, player, pSet)
{
	if(player || !pev_valid(ent) || !is_user_alive(host))
	return FMRES_IGNORED
	
	static classname[32]
	pev(ent, pev_classname, classname, 31)
	if(equal(classname, "trap"))
	{
		if(pev(ent, pev_iuser1))
		{
			return FMRES_IGNORED
			
		}
		if(!zp_get_user_zombie(host))
		{
			if(!(get_es(es, ES_Effects) &  EF_NODRAW))
			{
				set_es(es, ES_Effects, get_es(es, ES_Effects) | EF_NODRAW)
			}
		}else if(zp_get_user_zombie(host)) {
			if((get_es(es, ES_Effects) &  EF_NODRAW))
			{
				set_es(es, ES_Effects, get_es(es, ES_Effects) &~ EF_NODRAW)
			}
		}
	}
	return FMRES_IGNORED
}

public fw_think(ent)
{
	if(!pev_valid(ent))
	return FMRES_IGNORED
	
	static classname[32]
	pev(ent, pev_classname, classname, 31)
	if(equal(classname, "trap"))
	{
		engfunc(EngFunc_RemoveEntity, ent)
	}
	return FMRES_IGNORED
}


public useskill(id)
{
	if(!zp_get_user_zombie(id) || zp_get_user_nemesis(id) || zp_get_user_assassin(id) || zp_get_user_genesys(id))
	return PLUGIN_CONTINUE
	
	static Float:the_time 
	the_time = get_gametime()
	static Flags
	Flags = pev(id, pev_flags)

	if(zp_get_user_zombie_class(id) == g_zclass_doom && (Flags & FL_ONGROUND))
	{
		if(g_last_use[id] + get_pcvar_float(CVAR_TRAPDELAY)  <= the_time)
		{
			if(Traps[id] < get_pcvar_num(CVAR_MAXTRAPS))
			{
				create_trap(id)
				g_last_use[id] = the_time
				Traps[id] ++
			}else {
				colored_print(id, GREEN, "[ZC]^x01 You have used all traps.")
			}
		}
		else
		{
			colored_print(id, GREEN, "[ZC]^x01 Wait^x04 %.1f^x01 seconds.", get_pcvar_float(CVAR_TRAPDELAY) - (the_time - g_last_use[id]))
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public kill_traps()
{
	static iEnt
	iEnt = engfunc(EngFunc_FindEntityByString, -1, "classname", "trap")
	while(iEnt > 0)
	{
		engfunc(EngFunc_RemoveEntity, iEnt)
		iEnt = engfunc(EngFunc_FindEntityByString, -1, "classname", "trap")
	}	
}

public CurentWeapon(id)
{
	if(g_Traped[id])
	{
		set_pev(id, pev_maxspeed, 1.0)
	}
}

public client_connect(id)
{
	g_Traped[id] = false
}

public client_disconnect(id)
{
	g_Traped[id] = false	
}

public Spawn(id)
{
	if(is_user_alive(id))
	{
		g_Traped[id] = false
	}	
}

public fw_PreThink(id)
{
	if(g_Traped[id] && is_user_alive(id) && !zp_get_user_zombie(id))
	{
		if(trap_time[id] + get_pcvar_float(CVAR_INTRAPTIME) > get_gametime())
		{
			set_pev(id, pev_maxspeed, 1.0)
			set_pev(id, pev_velocity, Float:{0.0, 0.0, 0.0})
		}else {
			g_Traped[id] = false
			colored_print(id, GREEN, "[ZC]^x01 The trap is off.")
		}
	}
	return FMRES_IGNORED
}

public create_trap(id)
{
	static Float:origin[3], iEnt
	pev(id, pev_origin, origin)
	
	iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(pev_valid(iEnt))
	{
		set_pev(iEnt,pev_origin, origin)
		engfunc(EngFunc_SetModel, iEnt, spr)
		set_pev(iEnt, pev_scale, get_pcvar_float(CVAR_SPR_SCALE))
		fm_set_rendering(iEnt, kRenderFxNone, 0, 0, 0, kRenderTransAdd, 255)
		set_pev(iEnt, pev_classname, "trap")
		set_pev(iEnt, pev_solid, SOLID_TRIGGER)
		engfunc(EngFunc_SetSize, iEnt, Float:{-36.0,-36.0, 0.0}, Float:{36.0,36.0,72.0})
		set_pev(iEnt, pev_iuser1, 0)
	}
}

public fw_touch(tr, id)
{
	if(!is_user_alive(id) || zp_get_user_zombie(id) || !pev_valid(tr))
		return FMRES_IGNORED
	
	static classname[32]
	pev(tr, pev_classname, classname, 31)
	if(equal(classname, "trap"))
	{
		static Float:origin[3]
		pev(id, pev_origin, origin)
		origin[2] -= 10.0
		g_Traped[id] = true 
		engfunc(EngFunc_SetModel, tr, model)
		set_pev(tr, pev_iuser1, 1)
		colored_print(id, GREEN, "[ZC]^x01 You are blocked in a trap.")
		emit_sound(id, CHAN_WEAPON, g_trap_sound[0], 1.0, ATTN_NORM, 0, PITCH_LOW)
		set_pev(tr, pev_nextthink, get_gametime() + (get_pcvar_float(CVAR_INTRAPTIME) - 0.1))
		set_pev(tr, pev_solid, SOLID_NOT)
		set_pev(tr, pev_origin, origin)
		fm_set_rendering(tr)
		
		trap_time[id] = get_gametime()
	}
	return FMRES_IGNORED
}

stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16) 
{
	new Float:RenderColor[3]
	RenderColor[0] = float(r)
	RenderColor[1] = float(g)
	RenderColor[2] = float(b)
	set_pev(entity, pev_renderfx, fx)
	set_pev(entity, pev_rendercolor, RenderColor)
	set_pev(entity, pev_rendermode, render)
	set_pev(entity, pev_renderamt, float(amount))
	return 1
}