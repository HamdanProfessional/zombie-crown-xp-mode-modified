#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <zombiecrown>
#include <colored_print>

// Zombie Attributes
new const zclass_name[] = "Lockerz" // name
new const zclass_info[] = "Lock Weapon" // description
new const zclass_model[] = { "zc_model_zm6" }
new const zclass_clawmodel[] = "v_knife_zm6.mdl" // claw model
const zclass_health = 16000 // health
const zclass_speed = 470 // speed
const Float:zclass_gravity = 1.0 // gravity
const Float:zclass_knockback = 1.0 // knockback
const zclass_level = 24

// Class IDs
new g_lockerz

// Main var
new beam
new bool:can_lock[33]
new bool:target_locked[33]

// Main cvar
new cvar_distance
new cvar_cooldown
new cvar_cooldown_target

public plugin_init()
{
	new registerText[32]
	formatex( registerText, sizeof registerText - 1, "[ZC %s]", zclass_name)
	register_plugin(registerText, "1.0", "meNe")
	register_clcmd("drop", "lock_now")
	register_forward(FM_CmdStart, "fw_Start")
	cvar_distance = register_cvar("lz_distance", "750")
	cvar_cooldown = register_cvar("lz_cooldown_time", "30.0")
	cvar_cooldown_target = register_cvar("lz_cooldown_target_time", "10.0")
}

public plugin_precache()
{
	g_lockerz = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_level)	
	beam = precache_model("sprites/lgtning.spr")
}

public zp_user_infected_post(id, infector)
{
	if(is_user_alive(id) && zp_get_user_zombie(id) && zp_get_user_zombie_class(id) == g_lockerz)
	{
		colored_print(id, GREEN, "[ZC]^x01 Put your crosshair on an enemy and press^x04 [G]^x01 to block his weapon.")
		can_lock[id] = true
	}
}

public zp_user_humanized_post(id)
{
	if(is_user_alive(id) && zp_get_user_zombie(id) && zp_get_user_zombie_class(id) == g_lockerz)
	{
		can_lock[id] = false
	}
}

public lock_now(id)
{
	if(is_user_alive(id) && zp_get_user_zombie(id) && zp_get_user_zombie_class(id) == g_lockerz)
	{
		if(is_user_alive(id) && can_lock[id] == true)
		{
			new target1, body1
			static Float:start1[3]
			static Float:end1[3]
			
			pev(id, pev_origin, start1)
			start1[2] += 16.0			
			fm_get_aim_origin(id, end1)
			end1[2] += 16.0			
			
			get_user_aiming(id, target1, body1, cvar_distance)
			if(is_user_alive(target1) && !zp_get_user_zombie(target1) && !zp_get_human_hero(target1))
			{
				lock_target(target1)			
				client_print(id, print_center, "Enemy blocked.")
				} else {
				client_print(id, print_center, "Enemy missed.")
			}
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(0)
			engfunc(EngFunc_WriteCoord, start1[0])
			engfunc(EngFunc_WriteCoord, start1[1])
			engfunc(EngFunc_WriteCoord, start1[2])
			engfunc(EngFunc_WriteCoord, end1[0])
			engfunc(EngFunc_WriteCoord, end1[1])
			engfunc(EngFunc_WriteCoord, end1[2])
			write_short(beam)
			write_byte(0)
			write_byte(30)		
			write_byte(20)
			write_byte(50)
			write_byte(50)
			write_byte(255)
			write_byte(255)
			write_byte(255)
			write_byte(100)
			write_byte(50)
			message_end()
			
			can_lock[id] = false
			set_task(get_pcvar_float(cvar_cooldown), "ability_reload", id)
			} else {
			if(is_user_alive(id) && can_lock[id] == false)
			{
				colored_print(id, GREEN, "[ZC]^x01 You can't use your power now, please wait^x04 %i^x01 seconds.", get_pcvar_num(cvar_cooldown))
			}
		}
	}
}

public lock_target(id)
{
	target_locked[id] = true
	
	set_task(get_pcvar_float(cvar_cooldown_target), "unlock_target", id)
	colored_print(id, GREEN, "[ZC]^x01 Now, all your weapons are blocked, please wait^x04 %i^x01 seconds.", get_pcvar_num(cvar_cooldown_target))
	
	return PLUGIN_HANDLED	
}

public ability_reload(id)
{
	can_lock[id] = true
	colored_print(id, GREEN, "[ZC]^x01 You can use your power now, please press^x04 [G]")
}

public unlock_target(id)
{
	target_locked[id] = false
	colored_print(id, GREEN, "[ZC]^x01 Your weapons are unblocked, now you can shot.")
	
	return PLUGIN_HANDLED	
}

public fw_Start(id, uc_handle, seed)
{
	if(is_user_alive(id) && target_locked[id] == true)
	{
		new button = get_uc(uc_handle,UC_Buttons)
		if(button & IN_ATTACK || button & IN_ATTACK2)
		{
			set_uc(uc_handle,UC_Buttons,(button & ~IN_ATTACK) & ~IN_ATTACK2)
		}
	}
}