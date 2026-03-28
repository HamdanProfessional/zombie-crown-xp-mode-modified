#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <xs>

#define PLUGIN "[ZC] Ultimate Bot Enhancement"
#define VERSION "3.0"
#define AUTHOR "Zombie Crown Team"

// CVars
new cvar_enabled
new cvar_perfect_aim
new cvar_aggressive

new bool:g_ZombieRound
new g_MaxPlayers

// Player tracking for bots to learn from
new Float:player_last_origin[33][3]
new Float:player_last_vel[33][3]
new player_last_buttons[33]
new bool:player_is_jumping[33]

// Bot state
new Float:bot_last_jump_time[33]
new Float:bot_target_update_time[33]
new bot_target[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	cvar_enabled = register_cvar("zc_bot_enhanced", "1")
	cvar_perfect_aim = register_cvar("zc_bot_perfect_aim", "1")
	cvar_aggressive = register_cvar("zc_bot_aggressive", "1")

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

	// Track player movement
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")

	// Bot think - update every 0.1 seconds
	set_task(0.1, "Bot_Think", _, _, _, "b")

	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
	register_logevent("Event_RoundStart", 2, "1=Round_Start")
}

// Track real players for bots to learn from
public fw_PlayerPreThink(id)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED
	if(is_user_bot(id))
		return FMRES_IGNORED

	// Track player movement
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

	static id
	for(id = 1; id <= g_MaxPlayers; id++)
	{
		if(!is_user_bot(id))
			continue
		if(!is_user_alive(id))
			continue

		// Instant reaction time
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

		// Face target
		new Float:dir[3]
		dir[0] = target_origin[0] - bot_origin[0]
		dir[1] = target_origin[1] - bot_origin[1]
		dir[2] = target_origin[2] - bot_origin[2]

		new Float:viewangle[3]
		vector_to_angle(dir, viewangle)
		set_pev(id, pev_v_angle, viewangle)
		set_pev(id, pev_angles, viewangle)
		set_pev(id, pev_fixangle, 1)

		// Attack if close enough
		if(dist < 70.0)
		{
			// In attack range - swing knife
			new buttons = pev(id, pev_button)
			if(!(buttons & IN_ATTACK))
			{
				set_pev(id, pev_button, buttons | IN_ATTACK)
			}
		}
		else
		{
			// Not in range - move toward target
			new flags = pev(id, pev_flags)

			// Check if should jump
			new bool:should_jump = false

			// Jump if target is above
			if(height_diff > 50.0 && (flags & FL_ONGROUND))
				should_jump = true

			// Jump if player is jumping (learn from them)
			if(player_is_jumping[target] && (flags & FL_ONGROUND))
				should_jump = true

			// Jump occasionally to be unpredictable
			if((flags & FL_ONGROUND) && random_num(0, 100) < 3)
				should_jump = true

			// Execute jump
			if(should_jump && (time - bot_last_jump_time[id] > 0.5))
			{
				bot_last_jump_time[id] = time
				new Float:vel[3]
				pev(id, pev_velocity, vel)
				vel[2] = 270.0
				set_pev(id, pev_velocity, vel)
			}

			// Push toward target (gentle push, let game handle movement)
			new Float:push_dir[2]
			push_dir[0] = dir[0]
			push_dir[1] = dir[1]

			new Float:len = floatsqroot(push_dir[0]*push_dir[0] + push_dir[1]*push_dir[1])
			if(len > 0.0)
			{
				push_dir[0] /= len
				push_dir[1] /= len
			}

			// Apply gentle force toward target
			new Float:vel[3]
			pev(id, pev_velocity, vel)

			// Only modify if on ground
			if(flags & FL_ONGROUND)
			{
				vel[0] = push_dir[0] * 200.0
				vel[1] = push_dir[1] * 200.0
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

		// Aim at target
		new Float:dir[3]
		dir[0] = target_origin[0] - bot_origin[0]
		dir[1] = target_origin[1] - bot_origin[1]
		dir[2] = target_origin[2] - bot_origin[2]

		// Predict movement slightly
		new Float:target_vel[3]
		pev(target, pev_velocity, target_vel)

		dir[0] += target_vel[0] * 0.1
		dir[1] += target_vel[1] * 0.1

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
			continue  // Only target real players

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
		bot_target_update_time[i] = 0.0
		player_is_jumping[i] = false
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
