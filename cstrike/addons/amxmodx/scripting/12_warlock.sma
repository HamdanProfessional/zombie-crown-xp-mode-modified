#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <fun>
#include <zombiecrown>

#define message_begin_f(%1,%2,%3) (engfunc (EngFunc_MessageBegin, %1, %2, %3))
#define write_coord_f(%1) (engfunc (EngFunc_WriteCoord, %1))

new const zclass_name[] = { "Warlock" }
new const zclass_info[] = { "Can heal teammates - C" }
new const zclass_model[] = { "zc_model_zm3" }
new const zclass_clawmodel[] = { "v_knife_zm3.mdl" }
const zclass_health = 10500
const zclass_speed = 305
const Float:zclass_gravity = 0.8
const Float:zclass_knockback = 1.0
const zclass_level = 12

const zclass_infecthp = 200
new g_zclass_warlock
new i_cooldown_time[33] = 0
new g_cooldown[33] = 0
new g_maxplayers
new heal_count[33] = 0
enum Coord_e {Float:x, Float:y, Float:z}

#define RADIUS 300
#define COLOR_R 0
#define COLOR_G 255
#define COLOR_B 0
new g_can_heal_on_swarm = 1
new Float:g_heal_cooldown = 30.0
new const sound_heal_event[] = "zombie_crown/warlock/BurningSpirit.wav"


public plugin_precache()
{
	g_zclass_warlock = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_level)	
	precache_sound(sound_heal_event)
}

public plugin_init() 
{
	new registerText[32]
	formatex(registerText, sizeof registerText - 1, "[ZC %s]", zclass_name)
	register_plugin(registerText, "1.0", "meNe")
	register_clcmd("radio3", "use_ability_one")
	register_concmd("radio3", "use_ability_one")
	g_maxplayers = get_maxplayers()
	register_logevent("roundStart", 2, "1=Round_Start")
}

public use_ability_one(healer)
{
	if (is_user_alive(healer) && (zp_get_user_zombie_class(healer) == g_zclass_warlock) && zp_get_user_zombie(healer) && !zp_get_zombie_hero(healer) && (g_cooldown[healer] == 0) && (heal_count[healer] > 0))
	{
		new Distance
		for (new i = 1; i <= g_maxplayers; i++)
		{
			if (is_user_alive(i) == 1 && zp_get_user_zombie(i) && !zp_get_zombie_hero(i))
			{
				Distance = get_entity_distance(i, healer)
				if (Distance <= RADIUS) 
				{
					set_user_health(i,zp_get_zombie_maxhealth(i))
				}
			}
		}
		
		emit_sound(healer, CHAN_STREAM, sound_heal_event, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		static Coord_e:vecOrigin [Coord_e]; 
		pev (healer,pev_origin, vecOrigin); 

		message_begin_f (MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0); 
		write_byte (TE_DLIGHT); 
		write_coord_f (vecOrigin [x ]); 
		write_coord_f (vecOrigin [y ]); 
		write_coord_f (vecOrigin [z ]); 
		write_byte (RADIUS); 
		write_byte (COLOR_R); //red 
		write_byte (COLOR_G); //green 
		write_byte (COLOR_B); //blue 
		write_byte (8);//life 
		write_byte (40);//decay 
		message_end();
		
		i_cooldown_time[healer] = floatround(g_heal_cooldown)
		set_task(1.0, "ShowHUD", healer, _, _, "a",i_cooldown_time[healer])
		
		set_task(g_heal_cooldown,"healer_ability_cooldown",healer)
		g_cooldown[healer] = 1
		heal_count[healer] = heal_count[healer] - 1;
		
		new text[100]
		format(text,99,"^x04[ZP]^x01 Now you can heal ^x04%d^x01 times.",heal_count[healer])
		message_begin(MSG_ONE,get_user_msgid("SayText"),{0,0,0},healer) 
		write_byte(healer) 
		write_string(text) 
		message_end()
		
	}else if ((zp_get_user_zombie_class(healer) == g_zclass_warlock) && zp_get_user_zombie(healer) && !zp_get_zombie_hero(healer) && (heal_count[healer] == 0))
	{
		new text[100]
		format(text,99,"^x04[ZP]^x01 Your must infect someone to use your ability.")
		message_begin(MSG_ONE,get_user_msgid("SayText"),{0,0,0},healer) 
		write_byte(healer) 
		write_string(text) 
		message_end()
	}
}

public ShowHUD(id)
{
	if(is_user_alive(id))
	{
		i_cooldown_time[id] = i_cooldown_time[id] - 1;
		set_hudmessage(200, 100, 0, 0.75, 0.92, 0, 1.0, 1.1, 0.0, 0.0, -1)
		show_hudmessage(id, "Renew cooldown: %d",i_cooldown_time[id])
	}else{
		remove_task(id)
	}
}

public healer_ability_cooldown(id)
{
	if ((zp_get_user_zombie_class(id) == g_zclass_warlock) && zp_get_user_zombie(id) && !zp_get_zombie_hero(id))
	{
		g_cooldown[id] = 0
		new text[100]
		format(text,99,"^x04[ZP]^x01 Your ability ^x04Renew^x01 is ready.")
		message_begin(MSG_ONE,get_user_msgid("SayText"),{0,0,0},id) 
		write_byte(id) 
		write_string(text) 
		message_end()
	}
}

public roundStart()
{
	for (new i = 1; i <= g_maxplayers; i++)
	{
		g_cooldown[i] = 0
		heal_count[i] = 0
		i_cooldown_time[i] = floatround(g_heal_cooldown)

		remove_task(i)
	}
}

public zp_user_humanized_post(id)
{
	remove_task(id)
}

public zp_user_infected_post(id, infector)
{
	if ((zp_get_user_zombie_class(id) == g_zclass_warlock) && !zp_get_zombie_hero(id))
	{
		new text[100]
		new note_cooldown = floatround(g_heal_cooldown)
		format(text,99,"^x04[ZP]^x01 Your ability is ^x04Renew^x01. Cooldown:^x04 %d ^x01seconds.",note_cooldown)
		message_begin(MSG_ONE,get_user_msgid("SayText"),{0,0,0},id) 
		write_byte(id) 
		write_string(text) 
		message_end()
		
		i_cooldown_time[id] = floatround(g_heal_cooldown)
		remove_task(id)
		
		g_cooldown[id] = 0
		
		if ((zp_is_swarm_round() || zp_is_plague_round()) && g_can_heal_on_swarm == 1)
		{
			heal_count[id] = 1
		}else{
			heal_count[id] = 0
		}
		client_cmd(id,"bind F1 ability1")
	}
	
	if (zp_get_user_zombie_class(infector) == g_zclass_warlock)
	{
		heal_count[infector] = heal_count[infector] + 1;
		
		new text[100]
		format(text,99,"^x04[ZP]^x01 Now you can heal ^x04%d^x01 times.",heal_count[infector])
		message_begin(MSG_ONE,get_user_msgid("SayText"),{0,0,0},infector) 
		write_byte(infector) 
		write_string(text) 
		message_end()
	}
}
