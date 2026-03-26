#include <amxmodx>	
#include <hamsandwich>
#include <fun>
#include <zombiecrown>

#define is_valid_player(%1) (1 <= %1 <= 32)

new g_spr_rustler, g_itemRustler, g_roundend, g_msgScreenShake, ScreenFadeEffects, bool:using_rustler[33]
#define RustlerSound "zombie_crown/items/zp_rustler_buy.wav"
const UNIT_SECOND = (2<<12)

public plugin_precache()
{
	g_spr_rustler = precache_model("sprites/zp_rustler_play.spr")
	precache_sound(RustlerSound)
}

public plugin_init()
{		
	register_plugin("[ZC Rustler Power]", "1.1", "Krtola")
			
	RegisterHam(Ham_TakeDamage, "player", "Rustler_TakeDamage")
        RegisterHam(Ham_Killed, "player", "Rustler_PlayerKilled")

        register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
        register_logevent("round_end", 2, "1=Round_End")

        g_msgScreenShake = get_user_msgid("ScreenShake")
        ScreenFadeEffects = get_user_msgid("ScreenFade") 
        g_itemRustler = zv_register_extra_item("Rustler", 50, ZV_TEAM_ZOMBIE, REST_NONE, 3)
}

public round_end()
{
    	static id;
    	for(id = 1 ; id <= get_maxplayers() ; id++)
    	{
        	if(!is_user_alive(id))
            		continue
        	g_roundend = true
        	if(using_rustler[id]) using_rustler[id] = false 
    	}
}

public event_round_start()
{
      	g_roundend = false
}

public Rustler_PlayerKilled(victim, attacker, shouldgib)
{
	using_rustler[victim] = false
}

public client_connect(id)
{	
	using_rustler[id] = false 
}

public zv_extra_item_selected(id, itemid)
{
    	if(itemid == g_itemRustler)
    	{  
       		if(using_rustler[id])
            		return ZV_PLUGIN_HANDLED

       		if(g_roundend)
            		return ZV_PLUGIN_HANDLED
 
       		using_rustler[id] = true
       		Rustler_buy_effects(id)
       		Rustler_sound(id, RustlerSound)
    	}
    	return PLUGIN_CONTINUE
}

public zp_user_humanized_post(id)
{
	if(using_rustler[id]) using_rustler[id] = false 
}

public client_PostThink(id)
{
	if(!is_user_alive(id))
		return;

	if(!zp_get_user_zombie(id) || zp_get_user_survivor(id))
		return;

	if(!using_rustler[id])
		return;
		
	static Float:Rustler_Time, Float:Rustler_hud_delay[33]
	Rustler_Time = get_gametime()
	if(Rustler_Time - 0.1 > Rustler_hud_delay[id])
	{
		rustler_sprite(id)
		Rustler_hud_delay[id] = Rustler_Time
	}
}

public Rustler_TakeDamage(victim, inflictor, attacker, Float:damage, damagetype)
{ 
    	if(victim == attacker || !is_user_alive(victim) || !is_user_connected(attacker))
		return HAM_IGNORED

    	if(is_valid_player(attacker) && zp_get_user_zombie(victim) && using_rustler[victim])
    	{
        	if((get_user_health(attacker)) > 30)
        	{
	        	set_user_health(attacker, get_user_health(attacker) - 1)
                	set_user_health(victim, get_user_health(victim) + 50)       
        	}

        	if((get_user_armor(attacker)) > 10)
        	{	
                	set_user_armor(attacker, get_user_armor(attacker) - 1)
        	}
        	Rustler_Effects(attacker)
    	}   
    	return HAM_HANDLED  
}

public Rustler_Effects(id)
{
	if (!is_user_alive(id) && !using_rustler[id]) 
		return;

	message_begin( MSG_ONE_UNRELIABLE, ScreenFadeEffects,.player = id )
	write_short( ( 1<<10 ) )
	write_short( 0 )
	write_short( 0x0000 )
	write_byte( 255 ) // Red color 
	write_byte( 0 ) // G
	write_byte( 0 ) // B
	write_byte( 255 )
	message_end( )
}

rustler_sprite(id)
{
	if (!is_user_alive(id) && !using_rustler[id]) 
		return;
	
	static origin[3]
	get_user_origin(id, origin)
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_SPRITE)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+52)
	write_short(g_spr_rustler)
	write_byte(2)
	write_byte(192)
	message_end()
}

Rustler_buy_effects(id)
{
	if (!is_user_alive(id) && !using_rustler[id]) 
		return;
	
	message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id)
	write_short(UNIT_SECOND*4) // amplitude
	write_short(UNIT_SECOND*3) // duration
	write_short(UNIT_SECOND*10) // frequency
	message_end()
	static origin[3]
	get_user_origin(id, origin)
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_IMPLOSION) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_byte(130) // radius
	write_byte(25) // count
	write_byte(4) // duration
	message_end()
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_PARTICLEBURST) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_short(70) // radius
	write_byte(70) // color
	write_byte(4) // duration (will be randomized a bit)
	message_end()
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_DLIGHT) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_byte(25) // radius
	write_byte(250) // r
	write_byte(0) // g
	write_byte(0) // b
	write_byte(3) // life
	write_byte(0) // decay rate
	message_end()
}

Rustler_sound(id, const sound[])
{
	emit_sound(id, CHAN_VOICE, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
}
