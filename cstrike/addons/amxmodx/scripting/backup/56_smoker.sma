#include <amxmodx>
#include <zombiecrown>
#include <fakemeta>
#include <hamsandwich>
#include <engine>
#include <colored_print>

//Main Class, modelT & Sprite Beam
new g_zclass_smoker, g_Line
new const generic_models[][] = { "models/player/zc_model_zm5/zc_model_zm5.mdl" } 
//Sounds
new g_sndMiss[] = "zombie_crown/smoker/Smoker_TongueHit_miss.wav"
new g_sndDrag[] = "zombie_crown/smoker/Smoker_TongueHit_drag.wav"
//Some vars
new g_hooked[33], g_hooksLeft[33], g_unable2move[33], g_ovr_dmg[33]
new Float:g_lastHook[33]
new bool: g_bind_use[33] = false, bool: g_bind_or_not[33] = false, bool: g_drag_i[33] = false
//Cvars
new cvar_maxdrags, cvar_dragspeed, cvar_cooldown, cvar_dmg2stop, cvar_mates, cvar_extrahook, cvar_unb2move, cvar_zhero, cvar_hhero
//Menu keys
new keys = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3
//Smoker Atributes
new const zclass_name[] = { "SmokerZM" }
new const zclass_info[] = { "Can drag players" }
new const zclass_model[] = { "zc_model_zm5" }
new const zclass_clawmodel[] = "v_knife_zm5.mdl" // claw model
const zclass_health = 15000
const zclass_speed = 460
const Float:zclass_gravity = 1.0
const Float:zclass_knockback = 1.0
const zclass_level = 56

public plugin_init()
{
	cvar_dragspeed = register_cvar("zp_smoker_dragspeed", "160")
	cvar_maxdrags = register_cvar("zp_smoker_maxdrags", "10")
	cvar_cooldown = register_cvar("zp_smoker_cooldown", "10")
	cvar_dmg2stop = register_cvar("zp_smoker_dmg2stop", "500")
	cvar_mates = register_cvar("zp_smoker_mates", "0")
	cvar_extrahook = register_cvar("zp_smoker_extrahook", "2")
	cvar_unb2move = register_cvar("zp_smoker_unable_move", "1")
	cvar_hhero = register_cvar("zp_zombie_hero_allow", "0")
	cvar_zhero = register_cvar("zp_human_hero_allow", "0")
	register_event("ResetHUD", "newSpawn", "b")
	register_event("DeathMsg", "smoker_death", "a")
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	register_clcmd("+drag","drag_start", ADMIN_USER, "bind ^"key^" ^"+drag^"")
	register_clcmd("-drag","drag_end")
	register_menucmd(register_menuid("Do you want to bind V +drag?"), keys, "bind_v_key")
}
public plugin_precache()
{
	new registerText[32]
	formatex( registerText, sizeof registerText - 1, "[ZC %s]", zclass_name)
	register_plugin(registerText, "1.0", "meNe")
	g_zclass_smoker = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_level)
	precache_sound(g_sndDrag)
	precache_sound(g_sndMiss)
	g_Line = precache_model("sprites/zbeam4.spr")
	
	for (new i = 0; i < sizeof generic_models; i++)
	precache_model(generic_models[i])
}

public zp_user_infected_post(id, infector)
{
	if ((zp_get_user_zombie_class(infector) == g_zclass_smoker) && (get_pcvar_num(cvar_extrahook) > 0))
	{
		g_hooksLeft[infector] = g_hooksLeft[infector] + get_pcvar_num(cvar_extrahook)
		set_hudmessage(255, 0, 0, -1.0, 0.45, 0, 0.0, 3.0, 0.01, 0.01, -1)
		show_hudmessage(infector, "+%d drag%s!", get_pcvar_num(cvar_extrahook), (get_pcvar_num(cvar_extrahook) < 2) ? "" : "s")
	}
	
	if (zp_get_user_zombie_class(id) == g_zclass_smoker)
	{
		g_hooksLeft[id] = get_pcvar_num(cvar_maxdrags)
		
		if (!g_bind_or_not[id])
		{
			new menu[192]
			format(menu, 191, "Do you want to bind V +drag?^n^n1. Yes^n2. No^n3. Drag on +USE")
			show_menu(id, keys, menu)
		}
	}
}

public newSpawn(id)
{
	if (g_hooked[id])
		drag_end(id)
}

public drag_start(id) // starts drag, checks if player is Smoker, checks cvars
{		
	if (zp_get_user_zombie(id) && (zp_get_user_zombie_class(id) == g_zclass_smoker) && !g_drag_i[id]) {
		
		static Float:cdown
		cdown = get_pcvar_float(cvar_cooldown)

		if (!is_user_alive(id)) {
			colored_print(id, GREEN, "[ZC]^x01 You can't drag now.")
			return PLUGIN_HANDLED
		}

		if (g_hooksLeft[id] <= 0) {
			colored_print(id, GREEN, "[ZC]^x01 You can't drag anybody.!")
			return PLUGIN_HANDLED
		}

		if (get_gametime() - g_lastHook[id] < cdown) {
			colored_print(id, GREEN, "[ZC]^x01 Wait^x04 %.f^x01 seconds to drag again!", get_pcvar_float(cvar_cooldown) - (get_gametime() - g_lastHook[id]))
			return PLUGIN_HANDLED
		}
		
		new hooktarget, body
		get_user_aiming(id, hooktarget, body)
		
		if (zp_get_zombie_hero(id) && get_pcvar_num(cvar_zhero) == 0) {
			colored_print(id, GREEN, "[ZC]^x01 You can't drag if you are Mode!")
			return PLUGIN_HANDLED
		}

		if (is_user_alive(hooktarget)) {
			if (!zp_get_user_zombie(hooktarget))
			{
				if (zp_get_human_hero(hooktarget) && get_pcvar_num(cvar_hhero) == 0) {
					colored_print(id, GREEN, "[ZC]^x01 You can't drag a Mode!")
					return PLUGIN_HANDLED
				}
				g_hooked[id] = hooktarget
				emit_sound(hooktarget, CHAN_BODY, g_sndDrag, 1.0, ATTN_NORM, 0, PITCH_HIGH)
			}
			else
			{
				if (get_pcvar_num(cvar_mates) == 1)
				{
					g_hooked[id] = hooktarget
					emit_sound(hooktarget, CHAN_BODY, g_sndDrag, 1.0, ATTN_NORM, 0, PITCH_HIGH)
				}
				else
				{
					colored_print(id, GREEN, "[ZC]^x01 You can't drag a friend!")
					return PLUGIN_HANDLED
				}
			}

			if (get_pcvar_float(cvar_dragspeed) <= 0.0)
				cvar_dragspeed = 1
			
			new parm[2]
			parm[0] = id
			parm[1] = hooktarget
			
			set_task(0.1, "smoker_reelin", id, parm, 2, "b")
			harpoon_target(parm)
			
			g_hooksLeft[id]--
			colored_print(id, GREEN, "[ZC]^x01 You can drag your enemies by %d times.", g_hooksLeft[id])
			g_drag_i[id] = true
			
			if(get_pcvar_num(cvar_unb2move) == 1)
				g_unable2move[hooktarget] = true
				
			if(get_pcvar_num(cvar_unb2move) == 2)
				g_unable2move[id] = true
				
			if(get_pcvar_num(cvar_unb2move) == 3)
			{
				g_unable2move[hooktarget] = true
				g_unable2move[id] = true
			}
		} else {
			g_hooked[id] = 33
			noTarget(id)
			emit_sound(hooktarget, CHAN_BODY, g_sndMiss, 1.0, ATTN_NORM, 0, PITCH_HIGH)
			g_drag_i[id] = true
			g_hooksLeft[id]--
			colored_print(id, GREEN, "[ZC]^x01 You can drag your enemies by %d times.", g_hooksLeft[id])
		}
	}
	else
		return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}

public smoker_reelin(parm[]) // dragging player to smoker
{
	new id = parm[0]
	new victim = parm[1]

	if (!g_hooked[id] || !is_user_alive(victim))
	{
		drag_end(id)
		return
	}

	new Float:fl_Velocity[3]
	new idOrigin[3], vicOrigin[3]

	get_user_origin(victim, vicOrigin)
	get_user_origin(id, idOrigin)

	new distance = get_distance(idOrigin, vicOrigin)

	if (distance > 1) {
		new Float:fl_Time = distance / get_pcvar_float(cvar_dragspeed)

		fl_Velocity[0] = (idOrigin[0] - vicOrigin[0]) / fl_Time
		fl_Velocity[1] = (idOrigin[1] - vicOrigin[1]) / fl_Time
		fl_Velocity[2] = (idOrigin[2] - vicOrigin[2]) / fl_Time
	} else {
		fl_Velocity[0] = 0.0
		fl_Velocity[1] = 0.0
		fl_Velocity[2] = 0.0
	}

	entity_set_vector(victim, EV_VEC_velocity, fl_Velocity) //<- rewritten. now uses engine
}

public drag_end(id) // drags end function
{
	g_hooked[id] = 0
	beam_remove(id)
	remove_task(id)
	
	if (g_drag_i[id])
		g_lastHook[id] = get_gametime()
	
	g_drag_i[id] = false
	g_unable2move[id] = false
}

public smoker_death() // if smoker dies drag off
{
	new id = read_data(2)
	
	beam_remove(id)
	
	if (g_hooked[id])
		drag_end(id)
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage) // if take damage drag off
{
	if (is_user_alive(attacker) && (get_pcvar_num(cvar_dmg2stop) > 0))
	{
		g_ovr_dmg[victim] = g_ovr_dmg[victim] + floatround(damage)
		if (g_ovr_dmg[victim] >= get_pcvar_num(cvar_dmg2stop))
		{
			g_ovr_dmg[victim] = 0
			drag_end(victim)
			return HAM_IGNORED;
		}
	}

	return HAM_IGNORED;
}

public fw_PlayerPreThink(id)
{
	if (!is_user_alive(id))
		return FMRES_IGNORED
	
	new button = get_user_button(id)
	new oldbutton = get_user_oldbutton(id)
	
	if (g_bind_use[id] && zp_get_user_zombie(id) && (zp_get_user_zombie_class(id) == g_zclass_smoker))
	{
		if (!(oldbutton & IN_USE) && (button & IN_USE))
			drag_start(id)
		
		if ((oldbutton & IN_USE) && !(button & IN_USE))
			drag_end(id)
	}
	
	if (!g_drag_i[id]) {
		g_unable2move[id] = false
	}
		
	if (g_unable2move[id] && get_pcvar_num(cvar_unb2move) > 0)
	{
		set_pev(id, pev_maxspeed, 1.0)
	}
	
	return PLUGIN_CONTINUE
}

public client_disconnect(id) // if client disconnects drag off
{
	if (id <= 0 || id > 32)
		return
	
	if (g_hooked[id])
		drag_end(id)
	
	if(g_unable2move[id])
		g_unable2move[id] = false
}

public harpoon_target(parm[]) // set beam (ex. tongue:) if target is player
{
	new id = parm[0]
	new hooktarget = parm[1]

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(8)	// TE_BEAMENTS
	write_short(id)
	write_short(hooktarget)
	write_short(g_Line)	// sprite index
	write_byte(0)	// start frame
	write_byte(0)	// framerate
	write_byte(200)	// life
	write_byte(8)	// width
	write_byte(1)	// noise
	write_byte(155)	// r, g, b
	write_byte(155)	// r, g, b
	write_byte(55)	// r, g, b
	write_byte(90)	// brightness
	write_byte(10)	// speed
	message_end()
}

public bind_v_key(id, keys)
{
	g_bind_or_not[id] = true
	switch(keys)
	{
		case 0:
			client_cmd(id, "bind v ^"+drag^"")
	
		case 1:
			colored_print(id, GREEN, "[ZC]^x01 To use your drag power, write in console (bind ^'^'key^'^' ^'^'+drag^'^'), then press that key.")
			
		case 2:
			g_bind_use[id] = true
			
		default:
			g_bind_or_not[id] = false
	}
	
	return PLUGIN_HANDLED
}

public noTarget(id) // set beam if target isn't player
{
	new endorigin[3]

	get_user_origin(id, endorigin, 3)

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte( TE_BEAMENTPOINT ); // TE_BEAMENTPOINT
	write_short(id)
	write_coord(endorigin[0])
	write_coord(endorigin[1])
	write_coord(endorigin[2])
	write_short(g_Line) // sprite index
	write_byte(0)	// start frame
	write_byte(0)	// framerate
	write_byte(200)	// life
	write_byte(8)	// width
	write_byte(1)	// noise
	write_byte(155)	// r, g, b
	write_byte(155)	// r, g, b
	write_byte(55)	// r, g, b
	write_byte(75)	// brightness
	write_byte(0)	// speed
	message_end()
}

public beam_remove(id) // remove beam
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(99)	//TE_KILLBEAM
	write_short(id)	//entity
	message_end()
}