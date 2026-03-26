#include <amxmodx>
#include <amxmisc>
#include <colored_print>

#define SELECTMAPS  5
#define charsof(%1) (sizeof(%1)-1)
#define is_user_valid(%1) (1 <= %1 <= g_maxplayers && is_user_connected(%1) && !is_user_hltv(%1) && !is_user_bot(%1))

new Array:g_mapName, g_mapNums, g_maxplayers
new g_nextName[SELECTMAPS]
new g_voteCount[SELECTMAPS + 2]
new g_mapVoteNum, g_teamScore[2], g_lastMap[32]
new cvar_MapFile1, cvar_MapFile2, rtv_count, rtv_index[33], rtv_stop
new g_coloredMenus, rounds, ten, fifteen, twenty, chosen
new delay = 5

public plugin_init()
{
	register_plugin("[ZC MapChooser]", "1.0", "meNe")
	register_dictionary("mapchooser.txt")
	register_dictionary("common.txt")
	register_clcmd("say timeleft", "sayTimeLeft", 0, "- displays timeleft")
	register_clcmd("say /timeleft", "sayTimeLeft", 0, "- displays timeleft")
	register_clcmd("say thetime", "sayTheTime", 0, "- displays current time")
	register_clcmd("say /rtv", "rtv_cmd", 0, "- manual map changing")
	g_mapName=ArrayCreate(32);
	new MenuName[64]
	format(MenuName, 63, "%L", "en", "CHOOSE_NEXTM")
	register_menucmd(register_menuid(MenuName), (-1^(-1<<(SELECTMAPS+2))), "countVote")
	cvar_MapFile1 = register_cvar("zp_mapfile_few", "mapcycle_few.txt");
	cvar_MapFile2 = register_cvar("zp_mapfile_many", "mapcycle_many.txt");
	register_logevent("EndRound", 2, "1=Round_End")

	if (cstrike_running())
	{
		register_event("TeamScore", "team_score", "a")
	}
	get_localinfo("lastMap", g_lastMap, 31)
	set_localinfo("lastMap", "")
	g_maxplayers = get_maxplayers()
	g_coloredMenus = colored_menus()
	ten = 0
	fifteen = 0
	twenty = 0
	chosen = 0
	set_task(30.0, "startcounter")
}

public rtv_cmd(id)
{
	if(rtv_stop > 0)
		return PLUGIN_HANDLED

	if(rtv_index[id] >= 1)
	{
		colored_print(id, GREEN, "[ZC]^x01 You already votted.")
		return PLUGIN_HANDLED
	}
	new players = get_playersnum(1)
	if(players <= 15)
	{
		if(rtv_count >= 5)
		{
			nom()
			rtv_stop++
		}else {
			rtv_count++
			rtv_index[id]++
			colored_print(id, GREEN, "[ZC]^x01 Thanks for your^x04 vote^x01, but to change map is still needed^x03 %d^x04 votes", 5-rtv_count)
		}
	}else if(players >= 16) {
		if(rtv_count >= 10)
		{
			nom()
			rtv_stop++
		}else {
			rtv_count++
			rtv_index[id]++
			colored_print(id, GREEN, "[ZC]^x01 Thanks for your^x04 vote^x01, but to change map is still needed^x03 %d^x04 votes", 10-rtv_count)
		}
	}


	return PLUGIN_HANDLED
}

public startcounter()
{
    	for(new id = 1; id <= g_maxplayers; id++) 
 	{
		set_task(15.0, "Number", id)
		set_task(40.0, "EndNumberVote", id)
	}
}

public Number(id)
{
	if(get_user_team(id) == 0)
		return PLUGIN_HANDLED

	new menu = menu_create( "\wHow many\r rounds\w do you want to play on this\y map\w?:", "menu_handler" );
	menu_additem(menu, "\r10\w rounds", "", 0)
	menu_additem(menu, "\r15\w rounds", "", 0)
	menu_additem(menu, "\r20\w rounds", "", 0)
	menu_display(id, menu, 0)

	return PLUGIN_HANDLED
}
 
public menu_handler(id, menu, item)
{
	new name[32]
	get_user_name(id, name, 31)
	switch(item)	
	{
		case 0: {
			ten++
			colored_print(0, GREEN, "[ZC]^x01 Player^x03 %s^x01 chooses^x03 10^x04 rounds^x01 for this map.", name)
		}
		case 1: {
			fifteen++
			colored_print(0, GREEN, "[ZC]^x01 Player^x03 %s^x01 chooses^x03 15^x04 rounds^x01 for this map.", name)
		}
		case 2: {
			twenty++
			colored_print(0, GREEN, "[ZC]^x01 Player^x03 %s^x01 chooses^x03 20^x04 rounds^x01 for this map.", name)
		}
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public EndNumberVote(id)
{

	if(ten > fifteen && ten > twenty) {
		colored_print(id, GREEN, "[ZC]^x01 Vote finished! You will play^x03 10^x04 rounds^x01 this map. Good game!")
		delay = 10
		chosen = 1
	}else if(fifteen > ten && fifteen > twenty) {
		colored_print(id, GREEN, "[ZC]^x01 Vote finished! You will play^x03 15^x04 rounds^x01 this map. Good game!")
		delay = 15
		chosen = 1
	}else if(twenty > ten && twenty > fifteen) {
		colored_print(id, GREEN, "[ZC]^x01 Vote finished! You will play^x03 20^x04 rounds^x01 this map. Good game!")
		delay = 20
		chosen = 1
	}else {
		colored_print(id, GREEN, "[ZC]^x01 Vote finished! You will play^x03 12^x04 rounds^x01 this map. Good game!")
		delay = 12
		chosen = 1
	}
	
}

public sayTimeLeft()
{
	if(chosen == 1) {
		colored_print(0, GREEN, "[ZC]^x01 Map will change in^x03 %d^x04 rounds^x01. Good game!", delay-rounds)
	}else {
		colored_print(0, GREEN, "[ZC]^x01 The ^x04timeleft^x01 was not chosen. In few^x04 seconds^x01 you will^x03 vote^x01 it!")
	}
}
public sayTheTime(id)
{
	new ctime[64]
	get_time("%d/%m/%Y - %H:%M:%S", ctime, 63)
	colored_print(0, GREEN, "[ZC]^x01 The Romanian time is now:^x04   %s", ctime)
	
	return PLUGIN_CONTINUE
}

public checkVotes()
{
	new b = 0
	
	for (new a = 0; a < g_mapVoteNum; ++a)
		if (g_voteCount[b] < g_voteCount[a])
			b = a
	
	new smap[32]
	if (g_voteCount[b] && g_voteCount[SELECTMAPS + 1] <= g_voteCount[b])
	{
		ArrayGetString(g_mapName, g_nextName[b], smap, charsof(smap));
		set_cvar_string("amx_nextmap", smap);
	}
	
	get_cvar_string("amx_nextmap", smap, 31)
	colored_print(0, GREEN, "[ZC]^x01 Choosing finished. The nextmap will be^x04 %s", smap)
	log_amx("Vote: Voting for the nextmap finished. The nextmap will be %s", smap)
}

public countVote(id, key)
{
	if (get_cvar_float("amx_vote_answers"))
	{
		new name[32]
		get_user_name(id, name, 31)
		
		if (key < SELECTMAPS)
		{
			new map[32];
			ArrayGetString(g_mapName, g_nextName[key], map, charsof(map));
			colored_print(0, GREEN, "[ZC]^x01 The player^x04 %s^x01 chose^x04 %s", name, map);
		}
	}
	++g_voteCount[key]
	
	return PLUGIN_HANDLED
}

bool:isInMenu(id)
{
	for (new a = 0; a < g_mapVoteNum; ++a)
		if (id == g_nextName[a])
			return true
	return false
}

public EndRound()
{
	rounds = rounds + 1
	if(delay-rounds == 1)
	{
		set_task(20.0, "nom")
	}

	if(delay-rounds <= 0)
	{
		log_amx("Timeleft expired. The map will be changed in few seconds ...")
		new smap[32]
		get_cvar_string("amx_nextmap", smap, 31)
		server_cmd("amx_map %s", smap)
	}
	if(rtv_stop > 0)
	{
		new smap[32]
		get_cvar_string("amx_nextmap", smap, 31)
		server_cmd("amx_map %s", smap)
	}
}

public nom()
{
	new filename[256];
	new players = get_playersnum(1)
	if(players <= 15)
	{
		get_pcvar_string(cvar_MapFile1, filename, sizeof(filename)-1);
	}else if(players >= 16) {
		get_pcvar_string(cvar_MapFile2, filename, sizeof(filename)-1);
	}
	loadSettings(filename)
	set_task(5.0, "voteNextmap")
}

public voteNextmap()
{
	new menu[512], a, mkeys = (1<<SELECTMAPS + 1)
	new pos = format(menu, 511, g_coloredMenus ? "\r%L:\w^n^n" : "%L:^n^n", LANG_SERVER, "CHOOSE_NEXTM")
	new dmax = (g_mapNums > SELECTMAPS) ? SELECTMAPS : g_mapNums
	
	for (g_mapVoteNum = 0; g_mapVoteNum < dmax; ++g_mapVoteNum)
	{
		a = random_num(0, g_mapNums - 1)
		
		while (isInMenu(a))
			if (++a >= g_mapNums) a = 0
		
		g_nextName[g_mapVoteNum] = a
		pos += format(menu[pos], 511, "%d. %a^n", g_mapVoteNum + 1, ArrayGetStringHandle(g_mapName, a));
		mkeys |= (1<<g_mapVoteNum)
		g_voteCount[g_mapVoteNum] = 0
	}
	
	menu[pos++] = '^n'
	g_voteCount[SELECTMAPS] = 0
	g_voteCount[SELECTMAPS + 1] = 0
	
	new mapname[32]
	get_mapname(mapname, 31)

	format(menu[pos], 511, "%d. %L", SELECTMAPS+2, LANG_SERVER, "NONE")
	new MenuName[64]
	
	format(MenuName, 63, "%L", "en", "CHOOSE_NEXTM")
	show_menu(0, mkeys, menu, 15, MenuName)
	set_task(15.0, "checkVotes")
	colored_print(0, GREEN, "[ZC]^x01 It's time to chose the next map! Be attentive !")
	colored_print(0, GREEN, "[ZC]^x01 It's time to chose the next map! Be attentive !")
	colored_print(0, GREEN, "[ZC]^x01 It's time to chose the next map! Be attentive !")
	client_cmd(0, "spk Gman/Gman_Choose2")
	log_amx("Vote: Voting for the nextmap started")
}

stock bool:ValidMap(mapname[])
{
	if ( is_map_valid(mapname) )
	{
		return true;
	}
	// If the is_map_valid check failed, check the end of the string
	new len = strlen(mapname) - 4;
	
	// The mapname was too short to possibly house the .bsp extension
	if (len < 0)
	{
		return false;
	}
	if ( equali(mapname[len], ".bsp") )
	{
		// If the ending was .bsp, then cut it off.
		// the string is byref'ed, so this copies back to the loaded text.
		mapname[len] = '^0';
		
		// recheck
		if ( is_map_valid(mapname) )
		{
			return true;
		}
	}
	
	return false;
}

loadSettings(filename[])
{
	if (!file_exists(filename))
		return 0

	new szText[32]
	new currentMap[32]
	
	new buff[256];
	
	get_mapname(currentMap, 31)

	new fp=fopen(filename,"r");
	
	while (!feof(fp))
	{
		buff[0]='^0';
		szText[0]='^0';
		
		fgets(fp, buff, charsof(buff));
		
		parse(buff, szText, charsof(szText));
		
		
		if (szText[0] != ';' &&
			ValidMap(szText) &&
			!equali(szText, g_lastMap) &&
			!equali(szText, currentMap))
		{
			ArrayPushString(g_mapName, szText);
			++g_mapNums;
		}
		
	}
	
	fclose(fp);

	return g_mapNums
}

public team_score()
{
	new team[2]
	
	read_data(1, team, 1)
	g_teamScore[(team[0]=='C') ? 0 : 1] = read_data(2)
}

stock get_realplayersnum()
{
	new players[32], playerCnt;
	get_players(players, playerCnt, "ch");
	
	return playerCnt;
}

public plugin_end()
{
	new current_map[32]

	get_mapname(current_map, 31)
	set_localinfo("lastMap", current_map)
	rounds = 0
}
