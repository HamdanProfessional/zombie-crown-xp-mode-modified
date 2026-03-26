#include amxmodx
#include hamsandwich
#include colored_print
#include zombiecrown

enum _:RewardType {
    REWARD_POINTS,
    REWARD_COINS,
    REWARD_PACKS,
    REWARD_XP,
    REWARD_LEVEL
}

new const reward_types[][] = {
    "Points",
    "Coins",
    "Packs",
    "XP",
    "Levels"
}

enum _:MissionData {
    MISSION_NAME[64],
    MISSION_PROGRESS,
    REWARD_AMOUNT,
    REWARD_TYPE,
    MIN_LEVEL
}

enum _:Missions {
    MISSION_KILL_300_ZOMBIES,
    MISSION_KILL_15_NEMESIS,
    MISSION_INFECT_150_HUMANS,
    MISSION_KILL_1000HUMANS_NEMESIS,
    MISSION_KILL_20_SURVIVORS,
    MISSION_KILL_10_GENESIS,
    MISSION_INFECT_333_FIRST_ZOMBIE,
    MISSION_KILL_97_LAST_HUMAN,
    MISSION_KILL_666_ZOMBIES_ZADOC,
    MISSION_KILL_767_HUMANS_OBERON,
    TOTAL_MISSIONS
}

new const g_mission[][MissionData] = {
    {"Kill 300 zombies as human", 300, 215, REWARD_COINS, 2},
    {"Kill 15 nemesis", 15, 5, REWARD_LEVEL, 4},
    {"Infect 150 humans as zombie", 150, 117, REWARD_COINS, 8},
    {"Kill 1000 humans as nemesis", 1000, 3500, REWARD_PACKS, 16},
    {"Kill 20 survivors", 20, 500, REWARD_XP, 32},
    {"Kill 10 genesis", 10, 20, REWARD_LEVEL, 45},
    {"Infect 333 humans as first zombie", 333, 500, REWARD_POINTS, 70},
    {"Kill 97 zombies as last human", 97, 500, REWARD_COINS, 85},
    {"Kill 666 zombies as zadoc", 666, 5000, REWARD_PACKS, 100},
    {"Kill 767 humans as oberon", 767, 1000, REWARD_XP, 106}
}

new player_mission[33]
new player_progress[33]
new player_missionname[33][64]

new g_Error[512]
new bool:isDataLoaded[33]

public plugin_init() {

    register_plugin("[ZC Missions]", "1.0", "sNk_DarK")

    register_clcmd("say /missions", "show_missions_menu")
    register_clcmd("say mmenu", "show_missions_menu")
    register_clcmd("say", "say_missioninfo")

    RegisterHam(Ham_Killed, "player", "player_killed")
    set_task(720.0, "CheckInactivePlayers", .flags="b")
    set_task(840.0, "CheckOldPlayers", .flags="b")
}

public plugin_natives() {
    register_native("ShowMissionsMenu", "ShowMissionsMenu", 1)
    register_native("get_mission", "get_mission")
}

public ShowMissionsMenu(id) {
    show_missions_menu(id)
    return 1
}

public get_mission()
{
    new iLen = get_param(2)

    new mission_name[64]
    copy(mission_name, iLen, player_missionname[get_param(1)])

    set_string(2, mission_name, iLen)
}

public client_putinserver(id)
{
    player_mission[id] = -1
    player_progress[id] = 0
    formatex(player_missionname[id], 64, "None")

}

public client_disconnect(id) isDataLoaded[id] = false

public show_missions_menu(id) {
    new menu = menu_create("Zombie Crown XP Mode \rMissions", "mission_menu_handler")

    if (player_mission[id] == -1) menu_additem(menu, "\dCancel current mission \r[Not available]")
    else menu_additem(menu, "Cancel current mission")

    menu_additem(menu, "Browse missions")

    if (player_mission[id] == -1) menu_additem(menu, "\dView current mission progress \r[Not available]")
    else menu_additem(menu, "View current mission progress")

    ZC_MenuDisplay(id, menu)
}

public mission_menu_handler(id, menu, item) {
    if (item == MENU_EXIT)
        return

    if (item == 0) {
        if (player_mission[id] == -1)
            colored_print(id, GREEN, "[MISSIONS]^x01 You do not have a current mission to cancel.")
        else {
            player_mission[id] = -1
            player_progress[id] = 0
            formatex(player_missionname[id], 64, "None")
            colored_print(id, GREEN, "[MISSIONS]^x01 Your current mission has been canceled.")
            show_missions_menu(id)
        }
    } 
    else if (item == 1) show_missions_list(id)
    else if (item == 2) {
        if (player_mission[id] == -1) colored_print(id, GREEN, "[MISSIONS]^x01 You do not have a current mission.")
        else show_progress_menu(id)
    }
}

public show_missions_list(id) {
    new menu = menu_create("Choose a mission", "missions_list_handler")

    for (new i = 0; i < TOTAL_MISSIONS; i++) {
        new mission_display[120]

        if (zp_get_user_level(id) >= g_mission[i][MIN_LEVEL]) {
            if (player_mission[id] == i) {
                formatex(mission_display, sizeof(mission_display), "%s \y(Level: %d) \rfor %d %s \y[SELECTED]",
                g_mission[i][MISSION_NAME], g_mission[i][MIN_LEVEL],
                g_mission[i][REWARD_AMOUNT], reward_types[g_mission[i][REWARD_TYPE]])
            } else {
                formatex(mission_display, sizeof(mission_display), "%s \y(Level: %d) \rfor %d %s",
                g_mission[i][MISSION_NAME], g_mission[i][MIN_LEVEL],
                g_mission[i][REWARD_AMOUNT], reward_types[g_mission[i][REWARD_TYPE]])
            }
            menu_additem(menu, mission_display, "")
        } else {
            formatex(mission_display, sizeof(mission_display), "\d%s (Level: %d) \r[LOCKED]",
            g_mission[i][MISSION_NAME], g_mission[i][MIN_LEVEL])
            menu_additem(menu, mission_display, "locked")
        }
    }

    ZC_MenuDisplay(id, menu)
}

public missions_list_handler(id, menu, item) {
    if (item == MENU_EXIT)
        return

    static buffer[64]
    static dummy

    menu_item_getinfo(menu, item, dummy, buffer, sizeof(buffer), _, _, dummy)

    if (equal(buffer, "locked")) {
        colored_print(id, GREEN, "[MISSIONS]^x01 This mission is locked or cannot be selected.")
        return
    }

    if (player_mission[id] != -1) {
        colored_print(id, GREEN, "[MISSIONS]^x01 You already have an active mission. Cancel it before selecting a new one.")
        return
    }

    player_mission[id] = item
    player_progress[id] = 0
    formatex(player_missionname[id], 64, "%s", g_mission[item][MISSION_NAME])

    colored_print(id, GREEN, "[MISSIONS]^x03 You selected mission:^x04 %s", g_mission[item][MISSION_NAME])
}

public progress_menu_handler(id, menu, item) {
    if (item == MENU_EXIT || item == 0 || item == 1)
        show_missions_menu(id)
}

public show_progress_menu(id) {
    new menu = menu_create("Current Mission Progress", "progress_menu_handler")

    new mission_index = player_mission[id]
    if (mission_index == -1) {
        colored_print(id, GREEN, "[MISSIONS] ^x01You do not have a current mission.")
        return
    }

    new required_amount = g_mission[mission_index][MISSION_PROGRESS]
    new current_progress = player_progress[id]
    new mission_status[128]

    formatex(mission_status, sizeof(mission_status), "Current mission progress:\y^n\w%s \y(Level: %d) ^n\rCompleted: %d / %d\w | \rReward: %d %s^n^n",
             g_mission[mission_index][MISSION_NAME], g_mission[mission_index][MIN_LEVEL],
             current_progress, required_amount, g_mission[mission_index][REWARD_AMOUNT], reward_types[g_mission[mission_index][REWARD_TYPE]])

    menu_additem(menu, mission_status)
    menu_additem(menu, "Back to main menu")
    ZC_MenuDisplay(id, menu)
}

public player_killed(victim, killer, gibs) {
    if (!is_user_alive(killer) || victim == killer)
        return

    new mission_index = player_mission[killer]
    if (mission_index == -1)
        return

    new required_amount = g_mission[mission_index][MISSION_PROGRESS]

    switch (mission_index) {

        case MISSION_KILL_300_ZOMBIES: {
            if (zp_get_user_zombie(victim)) {
                player_progress[killer]++
                if (player_progress[killer] >= required_amount) {
                    give_reward(killer)
                    player_mission[killer] = -1
                    player_progress[killer] = 0
                    formatex(player_missionname[killer], 64, "None")
                }
            }
        }

        case MISSION_KILL_15_NEMESIS: {
            if (zp_get_user_nemesis(victim)) {
                player_progress[killer]++
                if (player_progress[killer] >= required_amount) {
                    give_reward(killer)
                    player_mission[killer] = -1
                    player_progress[killer] = 0
                    formatex(player_missionname[killer], 64, "None")
                }
            }
        }

        case MISSION_KILL_1000HUMANS_NEMESIS: {
            if (zp_get_user_nemesis(killer)) {
                player_progress[killer]++
                if (player_progress[killer] >= required_amount) {
                    give_reward(killer)
                    player_mission[killer] = -1
                    player_progress[killer] = 0
                    formatex(player_missionname[killer], 64, "None")
                }
            }
        }

        case MISSION_KILL_20_SURVIVORS: {
            if (zp_get_user_survivor(victim)) {
                player_progress[killer]++
                if (player_progress[killer] >= required_amount) {
                    give_reward(killer)
                    player_mission[killer] = -1
                    player_progress[killer] = 0
                    formatex(player_missionname[killer], 64, "None")
                }
            }
        }

        case MISSION_KILL_10_GENESIS: {
            if (zp_get_user_genesys(victim)) {
                player_progress[killer]++
                if (player_progress[killer] >= required_amount) {
                    give_reward(killer)
                    player_mission[killer] = -1
                    player_progress[killer] = 0
                    formatex(player_missionname[killer], 64, "None")
                }
            }
        }

        case MISSION_KILL_666_ZOMBIES_ZADOC: {
            if (zp_get_user_zadoc(killer)) {
                player_progress[killer]++
                if (player_progress[killer] >= required_amount) {
                    give_reward(killer)
                    player_mission[killer] = -1
                    player_progress[killer] = 0
                    formatex(player_missionname[killer], 64, "None")
                }
            }
        }

        case MISSION_KILL_97_LAST_HUMAN: {
            if (zp_get_user_last_human(killer)) {
                player_progress[killer]++
                if (player_progress[killer] >= required_amount) {
                    give_reward(killer)
                    player_mission[killer] = -1
                    player_progress[killer] = 0
                    formatex(player_missionname[killer], 64, "None")
                }
            }
        }

        case MISSION_KILL_767_HUMANS_OBERON: {
            if (zp_get_user_oberon(killer)) {
                player_progress[killer]++
                if (player_progress[killer] >= required_amount) {
                    give_reward(killer)
                    player_mission[killer] = -1
                    player_progress[killer] = 0
                    formatex(player_missionname[killer], 64, "None")
                }
            }
        }
    }
}

public zp_user_infected_post(id, infector) {   
    if (infector == 0)
        return

    new mission_index = player_mission[infector]
    if (mission_index == -1)
        return

    new required_amount = g_mission[mission_index][MISSION_PROGRESS]

    if (mission_index == MISSION_INFECT_150_HUMANS) {
        player_progress[infector]++
        if (player_progress[infector] >= required_amount) {
            give_reward(infector)
            player_mission[infector] = -1
            player_progress[infector] = 0
            formatex(player_missionname[infector], 64, "None")
        }

    }
    else if (mission_index == MISSION_INFECT_333_FIRST_ZOMBIE && zp_get_user_first_zombie(infector)) {
        player_progress[infector]++
        if (player_progress[infector] >= required_amount) {
            give_reward(infector)
            player_mission[infector] = -1
            player_progress[infector] = 0
            formatex(player_missionname[infector], 64, "None")
        }
    }
}

public give_reward(id) {
    new reward_amount = g_mission[player_mission[id]][REWARD_AMOUNT]
    new reward_type = g_mission[player_mission[id]][REWARD_TYPE]

    switch (reward_type) {
        case REWARD_POINTS: {
            new log_message[256]
            formatex(log_message, sizeof(log_message), "Player %s has completed [ %s ] and has received %d points.",
            get_name(id), g_mission[player_mission[id]][MISSION_NAME], reward_amount)

            log_to_file("zc_missions.log", log_message)
            zp_set_user_points(id, zp_get_user_points(id) + reward_amount)
            colored_print(id, GREEN, "[MISSIONS]^x03 Mission completed! You received^x04 %d points.", reward_amount)
        }
        case REWARD_COINS: {
            new log_message[256]
            formatex(log_message, sizeof(log_message), "Player %s has completed [ %s ] and has received %d coins.",
            get_name(id), g_mission[player_mission[id]][MISSION_NAME], reward_amount)

            log_to_file("zc_missions.log", log_message)
            zp_set_user_coins(id, zp_get_user_coins(id) + reward_amount)
            colored_print(id, GREEN, "[MISSIONS]^x03 Mission completed! You received^x04 %d coins.", reward_amount)
        }
        case REWARD_PACKS: {
            new log_message[256]
            formatex(log_message, sizeof(log_message), "Player %s has completed [ %s ] and has received %d packs.",
            get_name(id), g_mission[player_mission[id]][MISSION_NAME], reward_amount)

            log_to_file("zc_missions.log", log_message)
            zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + reward_amount)
            colored_print(id, GREEN, "[MISSIONS]^x03 Mission completed! You received^x04 %d packs.", reward_amount)
        }
        case REWARD_XP: {
            new log_message[256]
            formatex(log_message, sizeof(log_message), "Player %s has completed [ %s ] and has received %d XP.",
            get_name(id), g_mission[player_mission[id]][MISSION_NAME], reward_amount)

            log_to_file("zc_missions.log", log_message)
            zp_set_user_xp(id, zp_get_user_xp(id) + reward_amount)
            colored_print(id, GREEN, "[MISSIONS]^x03 Mission completed! You received^x04 %d XP.", reward_amount)
        }
        case REWARD_LEVEL: {
            new log_message[256]
            formatex(log_message, sizeof(log_message), "Player %s has completed [ %s ] and has received %d levels.",
            get_name(id), g_mission[player_mission[id]][MISSION_NAME], reward_amount)

            log_to_file("zc_missions.log", log_message)
            zp_set_user_level(id, zp_get_user_level(id) + reward_amount)
            colored_print(id, GREEN, "[MISSIONS]^x03 Mission completed! You gained^x04 %d levels.", reward_amount)
        }
    }
}



public CheckInactivePlayers()
{

}

public CheckOldPlayers()
{

}

public plugin_end()
{
}

public say_missioninfo(id)
{
	new text[70], arg1[32], target[32], count[32]
	read_args(text, sizeof(text)-1);
	remove_quotes(text);
	arg1[0] = '^0';
	target[0] = '^0';
	count[0] = '^0';
	parse(text, arg1, sizeof(arg1)-1, target, sizeof(target)-1, count, sizeof(count)-1);
	if (equali(arg1, "missioninfo", 11))
	{
		missioninfo_player(id, target);
	}
	if (equali(arg1, "/missioninfo", 12))
	{
		missioninfo_player(id, target);
	}
	return PLUGIN_CONTINUE;
}

public missioninfo_player(id, target[])
{
	new target_2;
	target_2 = find_player("bl", target)
	if(!target_2)
	{
		colored_print(id, GREEN, "[MISSION]^x01 This^x04 player^x01 doen't exist!")
		return PLUGIN_HANDLED
	}
	if(is_user_bot(target_2))
	{
		colored_print(id, GREEN, "^x04[MISSION]^x01 This^x04 player^x01 is a^x04 bot!")
		return PLUGIN_HANDLED
	}
        if (player_mission[target_2] != -1)
        {
	colored_print(id, GREEN, "^x04===============================================")
	colored_print(id, GREEN, "^x01| Nick:^x04 %s^x01 | Mission:^x04 %s^x01 |", get_name(target_2), g_mission[player_mission[target_2]][MISSION_NAME])
	colored_print(id, GREEN, "^x01| Completed:^x04 %d / %d^x01 | Reward:^x04 %d %s^x01 |", player_progress[target_2], g_mission[player_mission[target_2]][MISSION_PROGRESS], g_mission[player_mission[target_2]][REWARD_AMOUNT], reward_types[g_mission[player_mission[target_2]][REWARD_TYPE]])
	colored_print(id, GREEN, "^x04===============================================")
        }
        else
        {
	colored_print(id, GREEN, "^x04===============================================")
	colored_print(id, GREEN, "^x01| Nick:^x04 %s^x01 | Mission:^x04 Not selected^x01 |", get_name(target_2))
	colored_print(id, GREEN, "^x04===============================================")
        }
	return PLUGIN_HANDLED
}

get_name(id) {
new name[32]; get_user_name(id, name, 32)
return name
}

ZC_MenuDisplay(id, menu, page=0)
{
if (!is_user_connected(id)) return
menu_display(id, menu, page)
}
