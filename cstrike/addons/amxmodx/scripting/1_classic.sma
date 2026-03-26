#include <amxmodx>
#include <fakemeta>
#include <zombiecrown>

// Zombie Attributes
new const zclass_name[] = "Classic" // name
new const zclass_info[] = "Balanced" // description
new const zclass_model[] = { "zc_model_zm1" }
new const zclass_clawmodel[] = "v_knife_zm1.mdl" // claw model
const zclass_health = 12000
const zclass_speed = 450 // speed
const Float:zclass_gravity = 1.0 // gravity
const Float:zclass_knockback = 1.0 // knockback
const zclass_level = 1

public plugin_precache()
{	
	new registerText[32]
	formatex( registerText, sizeof registerText - 1, "[ZC %s]", zclass_name)
	register_plugin(registerText, "1.0", "meNe")
	
	// Register the new class and store ID for reference
	zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_level)	
}
