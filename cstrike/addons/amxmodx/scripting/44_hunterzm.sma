#include <amxmodx>
#include <fakemeta>
#include <zombiecrown>
#include <colored_print>

/*================================================================================
[Customizations]
=================================================================================*/

// Zombie Attributes
new const zclass_name[] = "Hunter L4D2"
new const zclass_info[] = "Super jumps"
new const zclass_model[] = "zc_model_zm2"
new const zclass_clawmodel[] = "v_knife_zm2.mdl"
const zclass_health = 16000
const zclass_speed = 460
const Float:zclass_gravity = 0.5
const Float:zclass_knockback = 1.0
const zclass_level = 44

new const leap_sound[4][] = { "zombie_crown/hunter/hunter_jump.wav", "zombie_crown/hunter/hunter_jump1.wav", "zombie_crown/hunter/hunter_jump2.wav", "zombie_crown/hunter/hunter_jump3.wav" }

/*================================================================================
Customization ends here!
Any edits will be your responsibility
=================================================================================*/

// Variables
new g_hunter

// Arrays
new Float:g_lastleaptime[33]

// Cvar pointers
new cvar_force, cvar_cooldown

/*================================================================================
[Init, CFG and Precache]
=================================================================================*/

public plugin_precache()
{
    	// Register the new class and store ID for reference
    	g_hunter = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_level)
    
    	// Sound
    	static i
    	for(i = 0; i < sizeof leap_sound; i++)
        	precache_sound(leap_sound[i])
}

public plugin_init() 
{
    	// Plugin Info
    	new registerText[32]
    	formatex( registerText, sizeof registerText - 1, "[ZC %s]", zclass_name)
    	register_plugin(registerText, "1.0", "meNe")
    
    	// Forward
    	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink") 
    
    	// Cvars
    	cvar_force = register_cvar("zp_hunter_jump_force", "890") 
    	cvar_cooldown = register_cvar("zp_hunter_jump_cooldown", "1.0")
}

/*================================================================================
[Zombie Plague Forwards]
=================================================================================*/
public zp_user_infected_post(id, infector)
{
    	// It's the selected zombie class
    	if(zp_get_user_zombie_class(id) == g_hunter)
    	{
        	// Message
        	colored_print(id, GREEN, "[ZC]^x01 To use your power, press - ^"CTRL + E^"")
    	}
}

/*================================================================================
[Main Forwards]
=================================================================================*/

public fw_PlayerPreThink(id)
{
    	if(!is_user_alive(id))
        	return
        
    	if(zp_get_zombie_hero(id))
        	return
    
    	if(is_user_connected(id) && zp_get_user_zombie(id))
    	{
        	if (allowed_hunterjump(id))
        	{
            		static Float:velocity[3]
            		velocity_by_aim(id, get_pcvar_num(cvar_force), velocity)
            		set_pev(id, pev_velocity, velocity)
            		emit_sound(id, CHAN_STREAM, leap_sound[random_num(0, sizeof leap_sound -1)], 1.0, ATTN_NORM, 0, PITCH_HIGH)
           		// Set the current super jump time
            		g_lastleaptime[id] = get_gametime()
        	}
    	}
}

/*================================================================================
[Internal Functions]
=================================================================================*/

allowed_hunterjump(id)
{    
    	if (!zp_get_user_zombie(id) && zp_get_zombie_hero(id))
        	return false
    
    	if (zp_get_user_zombie_class(id) != g_hunter)
       	 	return false
    
    	if (!((pev(id, pev_flags) & FL_ONGROUND) && (pev(id, pev_flags) & FL_DUCKING)))
        	return false
    
    	static buttons
    	buttons = pev(id, pev_button)
    
    	// Not doing a longjump (added bot support)
    	if (!(buttons & IN_USE) && !is_user_bot(id))
        	return false
    
    	static Float:cooldown
    	cooldown = get_pcvar_float(cvar_cooldown)
    
    	if (get_gametime() - g_lastleaptime[id] < cooldown)
        	return false
    	return true
}  