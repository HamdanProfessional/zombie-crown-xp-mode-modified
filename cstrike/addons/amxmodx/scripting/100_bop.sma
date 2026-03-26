#include <amxmodx>
#include <fun>
#include <hamsandwich>
#include <zombiecrown>

new const zclass_name[] = { "Bop" }
new const zclass_info[] = { "Can remove the whole armor" }
new const zclass_model[] = { "zc_model_zm1" }
new const zclass_clawmodel[] = "v_knife_zm1.mdl" // claw model
const zclass_health = 13500
const zclass_speed = 490
const Float:zclass_gravity = 1.0
const Float:zclass_knockback = 1.2
const zclass_ability_amount = 2
const zclass_level = 100
new g_zclass_thief

public plugin_precache() 
{
	new registerText[32]
	formatex( registerText, sizeof registerText - 1, "[ZC %s]", zclass_name)
	register_plugin(registerText, "1.0", "meNe")

	RegisterHam(Ham_TakeDamage, "player", "ham_takedamage")
	g_zclass_thief = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_level)
}

public ham_takedamage(victim, inflictor, attacker, Float:damage, damage_type) 
{
	if(!is_user_connected(attacker) || !is_user_connected(victim) || victim == attacker)
		return HAM_IGNORED
		
	if(!zp_get_user_zombie(attacker) || zp_get_zombie_hero(attacker) || zp_get_user_zombie_class(attacker) != g_zclass_thief)
		return HAM_IGNORED
		
	if(get_user_weapon(attacker) != CSW_KNIFE)
		return HAM_IGNORED
		
	if(zp_get_user_ammo_packs(victim) >= zclass_ability_amount) zp_set_user_ammo_packs(victim, zp_get_user_ammo_packs(victim) - zclass_ability_amount)
	
	if(get_user_armor(victim) == 0)
		return HAM_IGNORED
	
	set_user_armor(victim, 0)
	
	return HAM_SUPERCEDE
}