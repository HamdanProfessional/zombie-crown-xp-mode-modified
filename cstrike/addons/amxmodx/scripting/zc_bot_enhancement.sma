#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <zombiecrown>

#define PLUGIN "[ZC] Ultimate Bot Enhancement"
#define VERSION "5.1"
#define AUTHOR "Zombie Crown Team"

// CVars
new cvar_enabled
new cvar_perfect_aim
new cvar_bot_items
new cvar_debug

new bool:g_ZombieRound
new g_MaxPlayers

// Item IDs
new g_itemid_knife_blink = -1
new g_itemid_zombie_madness = -1
new bool:g_items_initialized = false

// Player tracking
new Float:player_last_origin[33][3]
new Float:player_last_vel[33][3]
new player_last_buttons[33]
new bool:player_is_jumping[33]

// Bot state
new Float:bot_last_jump_time[33]
new Float:bot_last_strafe_time[33]
new Float:bot_last_doublejump_time[33]
new Float:bot_last_item_time[33]
new Float:bot_target_update_time[33]
new bot_target[33]
new bot_strafe_dir[33]
new bool:bot_has_jumped_once[33]
new bool:bot_stacking_enabled[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	cvar_enabled = register_cvar("zc_bot_enhanced", "1")
	cvar_perfect_aim = register_cvar("zc_bot_perfect_aim", "1")
	cvar_bot_items = register_cvar("zc_bot_buy_items", "1")
	cvar_debug = register_cvar("zc_bot_debug", "0")

	g_MaxPlayers = get_maxplayers()

	// Perfect aim for bots
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m4a1", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_awp", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m249", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_mp5navy", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_tmp", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_p90", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_deagle", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_elite", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_fiveseven", "fw_Weapon_PrimaryAttack_Pre", 0)

	// Track player movement and control bot actions
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_StartFrame, "fw_StartFrame")

	// Bot think - update every 0.1 seconds
	set_task(0.1, "Bot_Think", _, _, _, "b")

	// Initialize items after ZP loads
	set_task(5.0, "Init_Items")

	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
	register_logevent("Event_RoundStart", 2, "1=Round_Start")

	log_amx("[ZC Bot Enhancement] Plugin loaded")
}

public Init_Items()
{
	log_amx("[ZC Bot Enhancement] Initializing item IDs...")

	g_itemid_knife_blink = zp_get_extra_item_id("Knife Blink")
	g_itemid_zombie_madness = zp_get_extra_item_id("Zombie Madness")

	if(get_pcvar_num(cvar_debug))
	{
		log_amx("[ZC Bot Enhancement] Knife Blink ID: %d", g_itemid_knife_blink)
		log_amx("[ZC Bot Enhancement] Zombie Madness ID: %d", g_itemid_zombie_madness)
	}

	g_items_initialized = true
}

// Track real players
public fw_PlayerPreThink(id)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED
	if(is_user_bot(id))
		return FMRES_IGNORED

	new Float:origin[3], Float:vel[3], buttons
	pev(id, pev_origin, origin)
	pev(id, pev_velocity, vel)
	pev(id, pev_button, buttons)

	player_last_origin[id][0] = origin[0]
	player_last_origin[id][1] = origin[1]
	player_last_origin[id][2] = origin[2]

	player_last_vel[id][0] = vel[0]
	player_last_vel[id][1] = vel[1]
	player_last_vel[id][2] = vel[2]

	player_last_buttons[id] = buttons
	player_is_jumping[id] = (vel[2] > 100.0) ? true : false

	return FMRES_IGNORED
}

// Handle bot stacking (disable collision when player is high)
public fw_StartFrame()
{
	if(!get_pcvar_num(cvar_enabled))
		return FMRES_IGNORED

	new bool:player_high = false
	new Float:player_highest_z = -9999.0

	// Check if any player is very high
	new i
	for(i = 1; i <= g_MaxPlayers; i++)
	{
		if(!is_user_alive(i))
			continue
		if(is_user_bot(i))
			continue

		new Float:origin[3]
		pev(i, pev_origin, origin)

		if(origin[2] > player_highest_z)
			player_highest_z = origin[2]
	}

	// If player is high, enable stacking
	if(player_highest_z > 200.0)
		player_high = true

	// Enable/disable bot collision based on player height
	for(i = 1; i <= g_MaxPlayers; i++)
	{
		if(!is_user_alive(i))
			continue
		if(!is_user_bot(i))
			continue

		if(player_high)
		{
			// Disable solid with other bots (allow stacking)
			if(!bot_stacking_enabled[i])
			{
				set_pev(i, pev_solid, SOLID_NOT)
				bot_stacking_enabled[i] = true
			}
		}
		else
		{
			// Re-enable solid
			if(bot_stacking_enabled[i])
			{
				set_pev(i, pev_solid, SOLID_SLIDEBOX)
				bot_stacking_enabled[i] = false
			}
		}
	}

	return FMRES_IGNORED
}

// Control bot movement
public fw_CmdStart(id, uc_handle)
{
	if(!get_pcvar_num(cvar_enabled))
		return FMRES_IGNORED
	if(!is_user_bot(id))
		return FMRES_IGNORED
	if(!is_user_alive(id))
		return FMRES_IGNORED

	new team = get_user_team(id)
	new Float:time = get_gametime()

	// Zombie behavior
	if(team == 1 && g_ZombieRound)
	{
		new target = bot_target[id]

		if(target > 0 && is_user_alive(target))
		{
			new Float:bot_origin[3], Float:target_origin[3]
			pev(id, pev_origin, bot_origin)
			pev(target, pev_origin, target_origin)

			new Float:dist = get_distance_f(bot_origin, target_origin)
			new Float:height_diff = target_origin[2] - bot_origin[2]

			// Strafe while chasing
			if(dist > 100.0 && dist < 400.0)
			{
				if(time - bot_last_strafe_time[id] > 0.3)
				{
					bot_last_strafe_time[id] = time
					bot_strafe_dir[id] = !bot_strafe_dir[id]
				}

				// Add strafe to movement
				new buttons = get_uc(uc_handle, UC_Buttons)

				if(bot_strafe_dir[id] == 0)
					buttons |= IN_MOVELEFT
				else
					buttons |= IN_MOVERIGHT

				// Random jump while strafing
				new flags = pev(id, pev_flags)
				if((flags & FL_ONGROUND) && random_num(0, 100) < 15)
				{
					buttons |= IN_JUMP
					new Float:vel[3]
					pev(id, pev_velocity, vel)
					vel[2] = 260.0
					set_pev(id, pev_velocity, vel)
				}

				set_uc(uc_handle, UC_Buttons, buttons)
			}

			// Duck randomly
			if(random_num(0, 100) < 5)
			{
				new buttons = get_uc(uc_handle, UC_Buttons)
				buttons |= IN_DUCK
				set_uc(uc_handle, UC_Buttons, buttons)
			}

			// Double jump if target is very high
			if(height_diff > 100.0)
			{
				new flags = pev(id, pev_flags)
				if((flags & FL_ONGROUND) && !bot_has_jumped_once[id])
				{
					// First jump
					bot_has_jumped_once[id] = true
					bot_last_doublejump_time[id] = time

					new buttons = get_uc(uc_handle, UC_Buttons)
					buttons |= IN_JUMP
					set_uc(uc_handle, UC_Buttons, buttons)

					new Float:vel[3]
					pev(id, pev_velocity, vel)
					vel[2] = 300.0
					set_pev(id, pev_velocity, vel)

					if(get_pcvar_num(cvar_debug))
						log_amx("[ZC Bot] Bot %d double jumping (height diff: %.1f)", id, height_diff)
				}
				else if(!(flags & FL_ONGROUND) && bot_has_jumped_once[id] && (time - bot_last_doublejump_time[id] < 0.3))
				{
					// Double jump in air
					if(time - bot_last_doublejump_time[id] > 0.15)
					{
						new Float:vel[3]
						pev(id, pev_velocity, vel)
						vel[2] = 280.0
						set_pev(id, pev_velocity, vel)
						bot_has_jumped_once[id] = false
					}
				}
			}
			else if(pev(id, pev_flags) & FL_ONGROUND)
			{
				bot_has_jumped_once[id] = false
			}
		}
	}
	// Human bot behavior
	else
	{
		// Strafe while shooting
		new buttons = get_uc(uc_handle, UC_Buttons)
		if(buttons & IN_ATTACK)
		{
			if(time - bot_last_strafe_time[id] > 0.2)
			{
				bot_last_strafe_time[id] = time
				bot_strafe_dir[id] = !bot_strafe_dir[id]
			}

			if(bot_strafe_dir[id] == 0)
			{
				buttons |= IN_MOVELEFT
				buttons &= ~IN_MOVERIGHT
			}
			else
			{
				buttons |= IN_MOVERIGHT
				buttons &= ~IN_MOVELEFT
			}

			// Random duck
			if(random_num(0, 100) < 20)
				buttons |= IN_DUCK

			set_uc(uc_handle, UC_Buttons, buttons)
		}
	}

	return FMRES_HANDLED
}

// Perfect aim
public fw_Weapon_PrimaryAttack_Pre(Ent)
{
	if(!get_pcvar_num(cvar_perfect_aim))
		return HAM_IGNORED
	if(!get_pcvar_num(cvar_enabled))
		return HAM_IGNORED
	if(!pev_valid(Ent))
		return HAM_IGNORED

	new owner = get_pdata_cbase(Ent, 41, 4)
	if(!is_user_bot(owner))
		return HAM_IGNORED

	set_pdata_float(Ent, 62, 0.0, 4)
	return HAM_IGNORED
}

public Bot_Think()
{
	if(!get_pcvar_num(cvar_enabled))
		return

	static id
	for(id = 1; id <= g_MaxPlayers; id++)
	{
		if(!is_user_bot(id))
			continue
		if(!is_user_alive(id))
			continue

		set_pdata_float(id, 237, 0.001, 5)
		set_pdata_float(id, 83, 0.001, 5)

		new team = get_user_team(id)

		if(team == 1 && g_ZombieRound)
			Zombie_Bot_Think(id)
		else
			Human_Bot_Think(id)
	}
}

public Zombie_Bot_Think(id)
{
	new Float:time = get_gametime()

	// Find target every 0.2 seconds
	if(time - bot_target_update_time[id] >= 0.2)
	{
		bot_target_update_time[id] = time
		bot_target[id] = Find_Nearest_Human(id)
	}

	new target = bot_target[id]

	if(target > 0)
	{
		new Float:bot_origin[3], Float:target_origin[3]
		pev(id, pev_origin, bot_origin)
		pev(target, pev_origin, target_origin)

		new Float:dist = get_distance_f(bot_origin, target_origin)
		new Float:height_diff = target_origin[2] - bot_origin[2]

		// Predict where player will be
		new Float:pred_origin[3]
		pred_origin[0] = target_origin[0] + player_last_vel[target][0] * 0.15
		pred_origin[1] = target_origin[1] + player_last_vel[target][1] * 0.15
		pred_origin[2] = target_origin[2]

		// Face predicted position
		new Float:dir[3]
		dir[0] = pred_origin[0] - bot_origin[0]
		dir[1] = pred_origin[1] - bot_origin[1]
		dir[2] = pred_origin[2] - bot_origin[2]

		new Float:viewangle[3]
		vector_to_angle(dir, viewangle)
		set_pev(id, pev_v_angle, viewangle)
		set_pev(id, pev_angles, viewangle)
		set_pev(id, pev_fixangle, 1)

		// Buy items occasionally
		if(get_pcvar_num(cvar_bot_items) && g_items_initialized && (time - bot_last_item_time[id] > 30.0))
		{
			// Buy knife blink if target is far or high
			if((dist > 300.0 || height_diff > 80.0) && g_itemid_knife_blink != -1)
			{
				if(random_num(0, 100) < 30)
				{
					zp_force_buy_extra_item(id, g_itemid_knife_blink, 1)
					bot_last_item_time[id] = time

					if(get_pcvar_num(cvar_debug))
						log_amx("[ZC Bot] Bot %d bought Knife Blink (dist: %.1f, height: %.1f)", id, dist, height_diff)
				}
			}
			// Buy zombie madness if close to target
			else if(dist < 200.0 && g_itemid_zombie_madness != -1)
			{
				if(random_num(0, 100) < 25)
				{
					zp_force_buy_extra_item(id, g_itemid_zombie_madness, 1)
					bot_last_item_time[id] = time

					if(get_pcvar_num(cvar_debug))
						log_amx("[ZC Bot] Bot %d bought Zombie Madness (dist: %.1f)", id, dist)
				}
			}
		}

		// Attack if close enough
		if(dist < 70.0)
		{
			new buttons = pev(id, pev_button)
			if(!(buttons & IN_ATTACK))
			{
				set_pev(id, pev_button, buttons | IN_ATTACK)
			}
		}
		else
		{
			// Chase target
			new flags = pev(id, pev_flags)
			new bool:should_jump = false

			// Smart jumping
			if(height_diff > 50.0 && (flags & FL_ONGROUND))
				should_jump = true

			if(player_is_jumping[target] && (flags & FL_ONGROUND))
				should_jump = true

			// Jump over obstacles
			if((flags & FL_ONGROUND) && random_num(0, 100) < 5)
				should_jump = true

			if(should_jump && (time - bot_last_jump_time[id] > 0.5))
			{
				bot_last_jump_time[id] = time
				new Float:vel[3]
				pev(id, pev_velocity, vel)
				vel[2] = 270.0
				set_pev(id, pev_velocity, vel)
			}

			// Move toward target
			new Float:push_dir[2]
			push_dir[0] = dir[0]
			push_dir[1] = dir[1]

			new Float:len = floatsqroot(push_dir[0]*push_dir[0] + push_dir[1]*push_dir[1])
			if(len > 0.0)
			{
				push_dir[0] /= len
				push_dir[1] /= len
			}

			new Float:vel[3]
			pev(id, pev_velocity, vel)

			if(flags & FL_ONGROUND)
			{
				// Faster when far, slower when close
				new Float:speed = (dist > 200.0) ? 250.0 : 180.0
				vel[0] = push_dir[0] * speed
				vel[1] = push_dir[1] * speed
				set_pev(id, pev_velocity, vel)
			}
		}
	}
}

public Human_Bot_Think(id)
{
	new target = Find_Nearest_Enemy(id)

	if(target > 0)
	{
		new Float:bot_origin[3], Float:target_origin[3]
		pev(id, pev_origin, bot_origin)
		pev(target, pev_origin, target_origin)

		// Predict target movement
		new Float:target_vel[3]
		pev(target, pev_velocity, target_vel)

		new Float:predict_time = get_distance_f(bot_origin, target_origin) / 1500.0
		target_origin[0] += target_vel[0] * predict_time
		target_origin[1] += target_vel[1] * predict_time
		target_origin[2] += target_vel[2] * predict_time

		// Aim at predicted position
		new Float:dir[3]
		dir[0] = target_origin[0] - bot_origin[0]
		dir[1] = target_origin[1] - bot_origin[1]
		dir[2] = target_origin[2] - bot_origin[2]

		new Float:viewangle[3]
		vector_to_angle(dir, viewangle)
		set_pev(id, pev_v_angle, viewangle)
		set_pev(id, pev_angles, viewangle)
		set_pev(id, pev_fixangle, 1)

		// Attack
		new buttons = pev(id, pev_button)
		set_pev(id, pev_button, buttons | IN_ATTACK)
	}
}

Find_Nearest_Human(id)
{
	new target = 0
	new Float:nearest_dist = 9999.0
	new team = get_user_team(id)

	new i
	for(i = 1; i <= g_MaxPlayers; i++)
	{
		if(!is_user_alive(i))
			continue
		if(get_user_team(i) == team)
			continue
		if(is_user_bot(i))
			continue

		new Float:origin[3], Float:my_origin[3]
		pev(i, pev_origin, origin)
		pev(id, pev_origin, my_origin)

		new Float:dist = get_distance_f(my_origin, origin)

		if(dist < nearest_dist)
		{
			nearest_dist = dist
			target = i
		}
	}

	return target
}

Find_Nearest_Enemy(id)
{
	new target = 0
	new Float:nearest_dist = 9999.0
	new team = get_user_team(id)

	new i
	for(i = 1; i <= g_MaxPlayers; i++)
	{
		if(!is_user_alive(i))
			continue
		if(get_user_team(i) == team)
			continue

		new Float:origin[3], Float:my_origin[3]
		pev(i, pev_origin, origin)
		pev(id, pev_origin, my_origin)

		new Float:dist = get_distance_f(my_origin, origin)

		if(dist < nearest_dist)
		{
			nearest_dist = dist
			target = i
		}
	}

	return target
}

public Event_NewRound()
{
	g_ZombieRound = false

	new i
	for(i = 1; i <= g_MaxPlayers; i++)
	{
		bot_target[i] = 0
		bot_last_jump_time[i] = 0.0
		bot_last_strafe_time[i] = 0.0
		bot_last_doublejump_time[i] = 0.0
		bot_last_item_time[i] = 0.0
		bot_target_update_time[i] = 0.0
		bot_strafe_dir[i] = 0
		bot_has_jumped_once[i] = false
		bot_stacking_enabled[i] = false
	}
}

public Event_RoundStart()
{
	new zombie_count = 0
	new i
	for(i = 1; i <= g_MaxPlayers; i++)
	{
		new team = get_user_team(i)
		if(is_user_alive(i) && team == 1)
			zombie_count++
	}

	if(zombie_count > 0)
		g_ZombieRound = true
}
