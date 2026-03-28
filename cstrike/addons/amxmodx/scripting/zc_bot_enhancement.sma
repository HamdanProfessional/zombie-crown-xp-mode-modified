#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <xs>

#define PLUGIN "[ZC] Ultimate Bot Enhancement"
#define VERSION "2.1"
#define AUTHOR "Zombie Crown Team"

// Enable all features by default
new cvar_enabled
new cvar_bot_dodge
new cvar_bot_swarm
new cvar_bot_team
new cvar_zombie_mirror
new cvar_perfect_aim

new player_moving[33]
new Float:player_last_vel[33][3]
new player_last_buttons[33]

new bool:bot_mirror_mode[33]
new bot_mirror_target[33]
new Float:last_mirror_update[33]
new bot_swarm_target[33]

new bool:g_ZombieRound
new g_MaxPlayers

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	cvar_enabled = register_cvar("zc_bot_enhanced", "1")
	cvar_bot_dodge = register_cvar("zc_bot_dodge", "80")
	cvar_bot_swarm = register_cvar("zc_bot_swarm", "1")
	cvar_bot_team = register_cvar("zc_bot_team", "1")
	cvar_zombie_mirror = register_cvar("zc_bot_zombie_mirror", "1")
	cvar_perfect_aim = register_cvar("zc_bot_perfect_aim", "1")

	g_MaxPlayers = get_maxplayers()

	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink_Post", 1)

	// Hook think for perfect aim
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m4a1", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_awp", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m249", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_mp5navy", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_tmp", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_p90", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_deagle", "fw_Weapon_PrimaryAttack_Pre", 0)

	set_task(0.1, "Bot_Think", _, _, _, "b")

	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
	register_logevent("Event_RoundStart", 2, "1=Round_Start")
}

public fw_PlayerPreThink_Post(id)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED
	if(is_user_bot(id))
		return FMRES_IGNORED

	new Float:vel[3], buttons
	pev(id, pev_velocity, vel)
	pev(id, pev_button, buttons)

	player_last_vel[id][0] = vel[0]
	player_last_vel[id][1] = vel[1]
	player_last_vel[id][2] = vel[2]
	player_last_buttons[id] = buttons

	new Float:speed = floatsqroot(vel[0]*vel[0] + vel[1]*vel[1])
	if(speed > 50.0)
		player_moving[id] = 1
	else
		player_moving[id] = 0

	return FMRES_IGNORED
}

public fw_CmdStart(id, uc_handle)
{
	if(!get_pcvar_num(cvar_enabled))
		return FMRES_IGNORED
	if(!is_user_bot(id))
		return FMRES_IGNORED

	new buttons = get_uc(uc_handle, UC_Buttons)

	if(bot_mirror_mode[id])
	{
		new target = bot_mirror_target[id]

		if(target > 0 && is_user_alive(target))
		{
			new Float:time = get_gametime()

			if(time - last_mirror_update[id] >= 0.3)
			{
				last_mirror_update[id] = time

				// Copy player's movement - learn from real player
				if(player_last_buttons[target] & IN_JUMP)
					buttons |= IN_JUMP  // Jump when player jumps
				if(player_last_buttons[target] & IN_DUCK)
					buttons |= IN_DUCK
				if(player_last_buttons[target] & IN_FORWARD)
					buttons |= IN_FORWARD
				if(player_last_buttons[target] & IN_BACK)
					buttons |= IN_BACK
				if(player_last_buttons[target] & IN_MOVELEFT)
					buttons |= IN_MOVELEFT
				if(player_last_buttons[target] & IN_MOVERIGHT)
					buttons |= IN_MOVERIGHT

				// Match player's horizontal speed only (don't copy vertical)
				new Float:target_speed = floatsqroot(player_last_vel[target][0]*player_last_vel[target][0] + player_last_vel[target][1]*player_last_vel[target][1])
				if(target_speed > 50.0)
				{
					new Float:vel[3]
					new flags = pev(id, pev_flags)
					pev(id, pev_velocity, vel)

					// Only copy horizontal movement
					vel[0] = player_last_vel[target][0]
					vel[1] = player_last_vel[target][1]

					// Only add Z velocity if on ground and player jumped
					if((flags & FL_ONGROUND) && (player_last_buttons[target] & IN_JUMP))
						vel[2] = 260.0
					// Otherwise let gravity work naturally
					else if(!(flags & FL_ONGROUND) && vel[2] > 0.0)
						vel[2] *= 0.9  // Slight dampening while falling

					set_pev(id, pev_velocity, vel)
				}
			}
		}
		else
		{
			bot_mirror_mode[id] = false
			bot_mirror_target[id] = 0
		}
	}
	else
	{
		// Dodge when attacking
		if(buttons & IN_ATTACK)
		{
			if(random_num(0, 100) < get_pcvar_num(cvar_bot_dodge))
			{
				if(random_num(0, 1))
				{
					buttons |= IN_MOVERIGHT
					buttons &= ~IN_MOVELEFT
				}
				else
				{
					buttons |= IN_MOVELEFT
					buttons &= ~IN_MOVERIGHT
				}

				if(random_num(0, 100) < 20)
					buttons |= IN_JUMP
			}

			if(random_num(0, 100) < 30)
				buttons |= IN_DUCK
		}
	}

	set_uc(uc_handle, UC_Buttons, buttons)
	return FMRES_HANDLED
}

// Perfect aim - remove spread for bots
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

	// Remove spread for perfect accuracy
	set_pdata_float(Ent, 62, 0.0, 4)

	return HAM_IGNORED
}

public Bot_Think()
{
	if(!get_pcvar_num(cvar_enabled))
		return

	new id
	for(id = 1; id <= g_MaxPlayers; id++)
	{
		if(!is_user_bot(id))
			continue
		if(!is_user_alive(id))
			continue

		// Instant reaction time
		set_pdata_float(id, 237, 0.001, 5) // m_flNextAttack
		set_pdata_float(id, 83, 0.001, 5)  // m_flNextAttack

		new team = get_user_team(id)

		if(team == 1)
			Zombie_Bot_Think(id)
		else
			Human_Bot_Think(id)
	}
}

public Zombie_Bot_Think(id)
{
	// Zombies ONLY target and learn from real players (never other bots)
	new target = Find_Nearest_Human_Target(id)

	if(target > 0)
	{
		new Float:bot_origin[3], Float:target_origin[3]
		pev(id, pev_origin, bot_origin)
		pev(target, pev_origin, target_origin)

		new Float:dist = get_distance_f(bot_origin, target_origin)
		new Float:height_diff = target_origin[2] - bot_origin[2]
		new flags = pev(id, pev_flags)
		new onground = (flags & FL_ONGROUND) ? 1 : 0

		// Player is moving or hard to reach? Enter mirror/learn mode
		if(player_moving[target] || (height_diff > 60.0 && dist > 120.0))
		{
			if(get_pcvar_num(cvar_zombie_mirror))
			{
				// Learn from real player's movement
				bot_mirror_mode[id] = true
				bot_mirror_target[id] = target
			}
		}
		else
		{
			bot_mirror_mode[id] = false
			bot_swarm_target[id] = target

			// Direct approach - chase the player on ground
			new Float:dir[3]
			dir[0] = target_origin[0] - bot_origin[0]
			dir[1] = target_origin[1] - bot_origin[1]
			dir[2] = 0.0  // Keep horizontal only

			new Float:len = floatsqroot(dir[0]*dir[0] + dir[1]*dir[1])
			if(len > 0.0)
			{
				dir[0] /= len
				dir[1] /= len
			}

			// Face target instantly
			new Float:viewangle[3]
			vector_to_angle(dir, viewangle)
			set_pev(id, pev_v_angle, viewangle)
			set_pev(id, pev_angles, viewangle)
			set_pev(id, pev_fixangle, 1)

			// Get current velocity
			new Float:vel[3]
			pev(id, pev_velocity, vel)

			// Only set horizontal speed
			vel[0] = dir[0] * 300.0
			vel[1] = dir[1] * 300.0

			// Smart jumping - ONLY when on ground
			if(onground)
			{
				// Jump if target is significantly above
				if(height_diff > 50.0)
				{
					vel[2] = 270.0
				}
				// Jump if player just jumped
				else if(player_last_buttons[target] & IN_JUMP)
				{
					vel[2] = 260.0
				}
				// Otherwise stay on ground
				else
				{
					vel[2] = 0.0
				}
			}
			// In air - let gravity work, don't add more Z velocity
			else
			{
				// Don't modify Z velocity while in air
				if(vel[2] > 0.0)
					vel[2] *= 0.95  // Slight dampening
			}

			set_pev(id, pev_velocity, vel)
		}
	}
}

public Human_Bot_Think(id)
{
	if(get_pcvar_num(cvar_bot_swarm))
		Swarm_Think(id)

	if(get_pcvar_num(cvar_bot_team))
		Team_Coordination(id)
}

public Swarm_Think(id)
{
	new target = Find_Nearest_Enemy(id)

	if(target > 0)
	{
		bot_swarm_target[id] = target

		new Float:target_origin[3], Float:my_origin[3]
		pev(target, pev_origin, target_origin)
		pev(id, pev_origin, my_origin)

		// Predict target movement
		new Float:target_vel[3]
		pev(target, pev_velocity, target_vel)

		new Float:predict_time = get_distance_f(my_origin, target_origin) / 1200.0
		target_origin[0] += target_vel[0] * predict_time
		target_origin[1] += target_vel[1] * predict_time
		target_origin[2] += target_vel[2] * predict_time

		// Aim at predicted position (horizontal only for movement)
		new Float:dir[3]
		dir[0] = target_origin[0] - my_origin[0]
		dir[1] = target_origin[1] - my_origin[1]
		dir[2] = target_origin[2] - my_origin[2]

		// For aiming, use full direction
		new Float:len = floatsqroot(dir[0]*dir[0] + dir[1]*dir[1] + dir[2]*dir[2])
		if(len > 0.0)
		{
			dir[0] /= len
			dir[1] /= len
			dir[2] /= len
		}

		new Float:viewangle[3]
		vector_to_angle(dir, viewangle)
		set_pev(id, pev_v_angle, viewangle)
		set_pev(id, pev_angles, viewangle)
		set_pev(id, pev_fixangle, 1)

		// If zombie, move fast toward target (horizontal only)
		new team = get_user_team(id)
		if(g_ZombieRound && team == 1)
		{
			new Float:vel[3]
			new flags = pev(id, pev_flags)
			pev(id, pev_velocity, vel)

			// Only horizontal movement
			vel[0] = dir[0] * 320.0
			vel[1] = dir[1] * 320.0

			// Only jump if on ground and target is above
			if(flags & FL_ONGROUND)
			{
				new Float:height_diff = target_origin[2] - my_origin[2]
				if(height_diff > 50.0)
					vel[2] = 260.0
			}

			set_pev(id, pev_velocity, vel)
		}
	}
}

public Team_Coordination(id)
{
	// All bots target same enemy
	new i
	for(i = 1; i <= g_MaxPlayers; i++)
	{
		if(i == id)
			continue
		if(!is_user_bot(i))
			continue
		if(!is_user_alive(i))
			continue

		if(bot_swarm_target[i] > 0 && is_user_alive(bot_swarm_target[i]))
			bot_swarm_target[id] = bot_swarm_target[i]
	}
}

Find_Nearest_Human_Target(id)
{
	// Find nearest REAL player (never bots)
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
			continue  // Skip ALL bots

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

Find_Nearest_Target(id)
{
	return Find_Nearest_Human_Target(id)
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
		bot_swarm_target[i] = 0
		bot_mirror_mode[i] = false
		bot_mirror_target[i] = 0
		player_moving[i] = 0
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
