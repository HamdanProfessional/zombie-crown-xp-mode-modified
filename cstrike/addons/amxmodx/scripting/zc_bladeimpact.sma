#include <amxmodx>
#include <hamsandwich>
#include <fun>
#include <engine>
#include <zombiecrown>
#include <colored_print>

#define Impact_1	10.0
#define Impact_2	20.0
#define SOUND_1		"zombie_crown/items/humanpain1.wav"
#define SOUND_2		"zombie_crown/items/humanpain2.wav"

const Float:normal_speed = 250.0
const UNIT_SECOND = (1<<12)
new bool:g_BladeImpact[33], blade_impact_effect[33], g_count[33], g_itemid, g_msgScreenShake

public plugin_precache()
{
	precache_sound(SOUND_1)
	precache_sound(SOUND_2)
}

public plugin_init()
{
       register_plugin("[ZC Blade Impact]", "1.0", "Krtola")
       register_event("HLTV", "event_newround", "a", "1=0", "2=0")
       RegisterHam(Ham_Killed, "player", "blade_impact_hamKilled", 1)
       RegisterHam(Ham_TakeDamage, "player", "BladeImpack_damage")
       g_msgScreenShake = get_user_msgid("ScreenShake")
       g_itemid = zp_register_extra_item("Blade Impact", 30, ZP_TEAM_ZOMBIE, REST_MAP, 5)
}

public blade_impact_hamKilled(id)
{ 
	delete_impact(id)
}

public client_disconnect(id)
{
       blade_impact_effect[id] = false 
}

public client_connect(id)
{
       blade_impact_effect[id] = false
}

public zp_user_humanized_post(id)
{
	blade_impact_effect[id] = false
}

public zp_extra_item_selected(id, itemid)
{
	if(itemid == g_itemid)
	{
		if(blade_impact_effect[id])
		{
			colored_print(id, GREEN, "[ZC]^x01 You have already bought^x04 Blade Impact")
			return ZP_PLUGIN_HANDLED
	    	}
	    	blade_impact_effect[id] = true
            	item_buy_effect(id)
		colored_print(id, GREEN, "[ZC]^x01 You bought^x04 Blade Impact")
		colored_print(id, GREEN, "[ZC]^x01 Humans will move more slowly when you attack them.")
	}
        return PLUGIN_CONTINUE
}

public BladeImpack_damage(victim, inflictor, attacker, Float:damage, dmgtype)
{
       	if(!is_user_connected(attacker) || !is_user_alive(attacker) || !is_user_connected(victim) || !is_user_alive(victim))
       		return 

       	if(!zp_get_user_zombie(victim) && zp_get_user_zombie(attacker) && blade_impact_effect[attacker] && !g_BladeImpact[victim])
       	{
       		g_BladeImpact[victim] = true
       		set_user_rendering(victim, kRenderFxGlowShell, 200, 0, 0, kRenderNormal, 16)
       		set_user_maxspeed(victim, get_user_maxspeed(victim) - 100.0)
       		impact_effect(victim, attacker) 
       		event_Damage(victim)

       	}
}

public event_Damage(id)
{
	if(!is_user_alive(id))
		return;

	new iWeapID, attacker = get_user_attacker(id , iWeapID);
	if(!is_user_connected(attacker))
		return;

	if(iWeapID == CSW_KNIFE)
	{
		if(!zp_get_user_zombie(id))
		{
			new Float:fVec[3];
			fVec[0] = random_float(Impact_1 , Impact_2);
			fVec[1] = random_float(Impact_1 , Impact_2);
			fVec[2] = random_float(Impact_1 , Impact_2);
			entity_set_vector(id , EV_VEC_punchangle , fVec)
			message_begin(MSG_ONE_UNRELIABLE , get_user_msgid("ScreenFade") , { 0, 0, 0 } , id)
			write_short(1<<10)
			write_short(1<<10)
			write_short(1<<12)
			write_byte(0)
			write_byte(0)
			write_byte(0)
			write_byte(0)
			message_end()
			switch(random_num(0, 1))
			{
				case 0: client_cmd(id, "spk %s", SOUND_1)
				case 1: client_cmd(id, "spk %s", SOUND_2)
			}
		}
	}
}

public impact_effect(id, attacker)
{

       	if(!is_user_connected(id) || !is_user_alive(id))
       		return

       	if(g_count[id] > 10 || zp_get_user_zombie(id) || !g_BladeImpact[id])
       	{
       		delete_impact_effect(id)
       		return
       	}
       	g_count[id]++
       	set_task(3.0, "delete_impact_effect", id)
}

public delete_impact_effect(id)
{
       	if(!is_user_connected(id) || !is_user_alive(id))
       		return
       	set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderNormal, 255)
       	set_user_maxspeed(id, normal_speed)
       	g_BladeImpact[id] = false
}

public delete_impact(id)
{
       	if(!is_user_connected(id))
       		return

       	blade_impact_effect[id] = false                 
}

public event_newround()
{
       	for(new i = 1; i < get_maxplayers(); i++)
       	{   
          	if(is_user_alive(i))
          	{
            		delete_impact_effect(i) 
            		g_BladeImpact[i] = false 
            		blade_impact_effect[i] = false 
          	}    
       	}
}

item_buy_effect(id)
{	
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