#include <amxmodx>
#include <zombiecrown>
#include <fun>

new const zclass_name[] = { "Tank" }
new const zclass_info[] = { "Can force to sleep" }
new const zclass_model[] = { "zc_model_zm3" }
new const zclass_clawmodel[] = { "v_knife_zm3.mdl" }
const zclass_health = 12500
const zclass_speed = 350
const Float:zclass_gravity = 1.0
const Float:zclass_knockback = 0.25
const zclass_level = 48

new g_zclass_tank
new g_chance[33]
new g_msgScreenFade
const FFADE_IN = 0x0000
const FFADE_STAYOUT = 0x0004
const UNIT_SECOND = (1<<12)

new g_maxplayers
new is_cooldown_time[33] = 0
new is_cooldown[33] = 0

new Float:g_revenge_cooldown = 30.0 //cooldown time
new g_chance_to_cast = 40 //chance in percent, where 10 = 1%, 235= 23.5% e t.c.
new const sound_sleep[] = "zombie_crown/tank/SleepImpact.wav" //cast sound

public plugin_precache()
{
	g_zclass_tank = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_level)
	precache_sound(sound_sleep)
}

public plugin_init() 
{
	new registerText[32]
	formatex(registerText, sizeof registerText - 1, "[ZC %s]", zclass_name)
	register_plugin(registerText, "1.0", "meNe")
	g_msgScreenFade = get_user_msgid("ScreenFade")
	g_maxplayers = get_maxplayers()
	register_logevent("roundStart", 2, "1=Round_Start")
}

public client_damage(attacker,victim)
{
	if ((zp_get_user_zombie_class(victim) == g_zclass_tank) && zp_get_user_zombie(victim) && !zp_get_zombie_hero(victim) && (is_cooldown[victim] == 0))
	{
		g_chance[victim] = random_num(0,999)
		if (g_chance[victim] < g_chance_to_cast)
		{
			message_begin(MSG_ONE, g_msgScreenFade, _, attacker)
			write_short(4) // duration
			write_short(4) // hold time
			write_short(FFADE_STAYOUT) // fade type
			write_byte(0) // red
			write_byte(0) // green
			write_byte(0) // blue
			write_byte(255) // alpha
			message_end()
			
			set_user_health(victim, get_user_health(victim) + ( get_user_health(victim) / 10 ) )
			
			set_task(4.0,"wake_up",attacker)
			set_task(1.0, "ShowHUD", victim, _, _, "a",is_cooldown_time[victim])
			set_task(g_revenge_cooldown,"reset_cooldown",victim)
			
			emit_sound(attacker, CHAN_STREAM, sound_sleep, 1.0, ATTN_NORM, 0, PITCH_NORM);
			
			is_cooldown[victim] = 1
		}
	}
}

public reset_cooldown(id)
{
	if ((zp_get_user_zombie_class(id) == g_zclass_tank) && zp_get_user_zombie(id) && !zp_get_zombie_hero(id))
	{
		is_cooldown[id] = 0
		is_cooldown_time[id] = floatround(g_revenge_cooldown)
		new text[100]
		format(text,99,"^x04[ZP]^x01 Your ability ^x04Revenge^x01 is ready.")
		message_begin(MSG_ONE,get_user_msgid("SayText"),{0,0,0},id) 
		write_byte(id) 
		write_string(text) 
		message_end()
	}
}

public ShowHUD(id)
{
	if(is_user_alive(id))
	{
		is_cooldown_time[id] = is_cooldown_time[id] - 1;
		set_hudmessage(200, 100, 0, 0.75, 0.92, 0, 1.0, 1.1, 0.0, 0.0, -1)
		show_hudmessage(id, "Revenge cooldown: %d",is_cooldown_time[id])
	}else{
		remove_task(id)
	}
}

public wake_up(id)
{
	message_begin(MSG_ONE, g_msgScreenFade, _, id)
	write_short(UNIT_SECOND) // duration
	write_short(0) // hold time
	write_short(FFADE_IN) // fade type
	write_byte(0) // red
	write_byte(0) // green
	write_byte(0) // blue
	write_byte(255) // alpha
	message_end()
}

public zp_user_infected_post(id, infector)
{
	if ((zp_get_user_zombie_class(id) == g_zclass_tank) && !zp_get_zombie_hero(id))
	{
		
		new text[100]
		
		is_cooldown[id] = 0
		is_cooldown_time[id] = floatround(g_revenge_cooldown)
		
		new note_cooldown = floatround(g_revenge_cooldown)
		format(text,99,"^x04[ZP]^x01 Your ability is ^x04Revenge^x01 (passive). Cooldown:^x04 %d ^x01seconds.",note_cooldown)
		message_begin(MSG_ONE,get_user_msgid("SayText"),{0,0,0},id) 
		write_byte(id) 
		write_string(text) 
		message_end()
		
	}
}

public zp_user_humanized_post(id)
{
	remove_task(id)
	is_cooldown[id] = 0
}

public roundStart()
{
	for (new i = 1; i <= g_maxplayers; i++)
	{
		is_cooldown[i] = 0
		is_cooldown_time[i] = floatround(g_revenge_cooldown)
		remove_task(i)
	}
}