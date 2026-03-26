#include <amxmodx>
#include <zombiecrown>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#include <engine>
#include <colored_print>

#define TASK_BARTIME 5000

new const zclass_name[] = { "SuicideZM" } 
new const zclass_info[] = { "Press - R to explode" } 
new const zclass_model[] = { "zc_model_zm4" }
new const zclass_clawmodel[] = "v_knife_zm4.mdl" // claw model
const zclass_health = 20000 // health
const zclass_speed = 500 // speed
const Float:zclass_gravity = 0.80 // gravity
const Float:zclass_knockback = 0.6 // knockback 
const zclass_level = 82

new const EXPLO_SPRITE[] = "sprites/zerogxplode.spr"

new g_SuicideZ, g_msgBarTime, cvar_explotime, cvar_explobody,
g_ExpSpr, cvar_radius, cvar_reward, cvar_enablereward, cvar_rewarddmg, cvar_herodmg;

public plugin_init()
{
	new registerText[32]
	formatex(registerText, sizeof registerText - 1, "[ZC %s]", zclass_name)
	register_plugin(registerText, "1.0", "meNe")
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1)
	register_forward(FM_CmdStart, "CmdStart")
	cvar_radius = register_cvar("zp_suicide_radius", "150.0")
	cvar_explobody = register_cvar("zp_suicide_explobody", "1")
	cvar_explotime = register_cvar("zp_suicide_explotime", "5")
	g_msgBarTime = get_user_msgid("BarTime")
	cvar_herodmg = register_cvar("zp_suicide_herodamage", "500")
	cvar_reward = register_cvar("zp_suicide_reward", "200")
	cvar_rewarddmg = register_cvar("zp_suicide_rewarddmg", "100")
	cvar_enablereward = register_cvar("zp_suicide_reward_enable", "1")
}  

public plugin_precache()
{
	g_SuicideZ = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_level) 
	g_ExpSpr = precache_model(EXPLO_SPRITE)
}

public zp_respawn_menu_zm(id)
{
	if (zp_get_user_zombie_class(id) == g_SuicideZ) 
		return ZP_PLUGIN_HANDLED
	return PLUGIN_CONTINUE
}

public zp_respawn_menu_hm(id)
{
	if (zp_get_user_zombie_class(id) == g_SuicideZ) 
		return ZP_PLUGIN_HANDLED
	return PLUGIN_CONTINUE
}

public remove_bartime(id)
{
	message_begin(MSG_ONE, g_msgBarTime, _, id)
	write_byte(0) 
	write_byte(0) 
	message_end()
	remove_task(id+TASK_BARTIME)
}

public CmdStart(id, handle, random_seed)
{
	static iButton; iButton = (get_uc(handle, UC_Buttons) & IN_RELOAD)
	static iOldButton; iOldButton = (get_user_oldbutton(id) & IN_RELOAD)
    
	if(is_user_alive(id) && !zp_is_hero_round())
		if (zp_get_user_zombie(id) && (zp_get_user_zombie_class(id) == g_SuicideZ))
		{
			if(iButton && !iOldButton)
			{
				message_begin(MSG_ONE, g_msgBarTime, _, id)
				write_byte(get_pcvar_num(cvar_explotime))
				write_byte(0) 
				message_end()
				set_task(get_pcvar_float(cvar_explotime), "Explo", id+TASK_BARTIME)
			}
            
			if(iOldButton && !iButton)
				set_task(0.1, "remove_bartime", id)
		}
            
	return PLUGIN_HANDLED
}

public client_disconnect(id) 
{
	set_task(0.1, "remove_bartime", id)
}

public Explo(id)
{
	id -= TASK_BARTIME
    
	new Float:origin[3]
	pev(id, pev_origin, origin)
    
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_short(g_ExpSpr)
	write_byte(10) 
	write_byte(15) 
	write_byte(0)
	message_end()
	user_silentkill(id)
	set_task(90.0, "rspfreexp", id)
        
	static victim
	victim = -1
    
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, origin, get_pcvar_float(cvar_radius))) != 0)
	{
		if (is_user_alive(victim) && !zp_get_user_zombie(victim))
		{
			if(get_pcvar_num(cvar_enablereward))
			{
				if (zp_get_human_hero(victim))
				{
					colored_print(id, GREEN, "[ZC]^x01 You've got^x03 %d^x01 packs for damaging an enemy!", get_pcvar_num(cvar_rewarddmg))
					zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + get_pcvar_num(cvar_rewarddmg))
				}
				else
				{
					colored_print(id, GREEN, "[ZC]^x01 You've got^x03 %d^x04 packs^x01 for killing an enemy!", get_pcvar_num(cvar_reward))
					zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + get_pcvar_num(cvar_reward))
				}
			}
            
			if (zp_get_human_hero(victim))
			{
				new health = get_user_health(victim)
				if (health > get_pcvar_num(cvar_herodmg)) {
					set_user_health(victim, health-get_pcvar_num(cvar_herodmg))
				}else {
					log_kill(id, victim, "Suicide Zombie", 0)
				}
			}
			else
				log_kill(id, victim, "Suicide Zombie", 0)
		}
	}
}


stock log_kill(killer, victim, weapon[],headshot) 
{
	user_silentkill(victim);
	set_task(5.0, "rspfreexp", victim)
	message_begin(MSG_ALL, get_user_msgid("DeathMsg"), {0,0,0}, 0);
	write_byte(killer);
	write_byte(victim);
	write_byte(headshot);
	write_string(weapon);
	message_end();
    
	new kfrags = get_user_frags(killer);
	set_user_frags(killer, kfrags + 1);
	new vfrags = get_user_frags(victim);
	set_user_frags(victim, vfrags - 1);

	// Set XP
	zp_set_user_xp(killer, zp_get_user_xp(killer) + 1)
    
	return  PLUGIN_CONTINUE
}  

public fw_PlayerKilled(victim, attacker, shouldgib)
{
	if(zp_get_user_zombie_class(victim) == g_SuicideZ)
	{
		if(get_pcvar_num(cvar_explobody))
		SetHamParamInteger(3, 2)

		set_task(0.10, "remove_bartime", victim)
	}
}
        
public fw_PlayerSpawn_Post(id)
{
	if (!is_user_alive(id))
		return;
    
	set_task(0.10, "remove_bartime", id)
}  

// Respawn after it;
public rspfreexp(id)
{
	if(!zp_is_hero_round())
	{
		zp_respawn_user(id , ZP_TEAM_ZOMBIE)
	}
}