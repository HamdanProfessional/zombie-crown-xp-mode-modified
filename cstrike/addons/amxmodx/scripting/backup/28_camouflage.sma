#include <amxmodx>
#include <zombiecrown>

// Zombie Atributes
new const zclass_name[] = { "Camouflage" } // name
new const zclass_info[] = { "Looks like a human" } // description
new const zclass_model[] = "zc_model_human" // model
new const zclass_clawmodel[] = { "v_knife_zm6.mdl" } 
const zclass_health = 12000
const zclass_speed = 480
const Float:zclass_gravity = 0.52
const Float:zclass_knockback = 1.0
const zclass_level = 28

new g_zclassid1
	
public plugin_precache()
{
	new registerText[32]
	formatex(registerText, sizeof registerText - 1, "[ZC %s]", zclass_name)
	register_plugin(registerText, "1.0", "meNe")
	g_zclassid1 = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_level)
}

public zp_user_infected_post(id, infector)
{
	if (zp_get_user_zombie_class(id) == g_zclassid1){
		client_print(id, print_chat, "[ZC] You have pretend like a human??")
	}
}