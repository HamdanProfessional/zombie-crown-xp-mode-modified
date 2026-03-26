#include <amxmodx>
#include <amxmisc>
#include <cstrike>

// Flags accesses
enum _:database_ztags {
	zctag[50], zcname[50]
}
new g_tag[33][32], tags_database[database_ztags], Array:zc_tags_holder, 
playerhastag[33], g_iMsgID_SayText, g_maxplayers
new g_iAdminChatFlag = ADMIN_ALL;

public plugin_init()
{
	register_plugin("[ZC Tags]", "1.1", "meNe")
	register_clcmd("say", "CmdSay");
	register_clcmd("say_team", "CmdSayTeam");
	g_iMsgID_SayText = get_user_msgid("SayText");
	register_concmd("amx_reloadtags", "reload_tags_command", ADMIN_RCON);
	g_maxplayers = get_maxplayers() 
	reload_tags()

	// Check for admin chat commands
	new szCommand[32], iFlags;
	for(new i = 0; get_concmd(i, szCommand, charsmax(szCommand), iFlags, "", 0, 0, -1); i++) {
		if(equal(szCommand, "amx_chat")) {
			g_iAdminChatFlag = iFlags;
			break;
		}
	}
}

public client_connect(id) 
{
	if(playerhastag[id])
		playerhastag[id] = false

	set_user_tag(id)
}

public set_user_tag(id) 
{
	static name[32], index, size
	get_user_name(id, name, 31)
	
	size = ArraySize(zc_tags_holder)
	for(index=0; index < size; index++) 
	{
		ArrayGetArray(zc_tags_holder, index, tags_database)
		if(equali(name, tags_database[zcname])) 
		{
			copy(g_tag[id], sizeof (g_tag[]) -1, tags_database[zctag])
			playerhastag[id] = true
		}
	}
}

public reload_tags_command(id, level, cid)
{
    	if(!cmd_access(id , level , cid, 1)) 
		return PLUGIN_HANDLED;

	reload_tags()
	server_print("[ZC] The TAGS file was reloaded.")
	client_print(id, print_console, "[ZC] The TAGS file was reloaded.")
	for(new i = 1; i <= g_maxplayers; i++) 
	{
		if(is_user_connected(i)) {
			set_task(2.0, "set_user_tag", i)
		}
	}
	return PLUGIN_HANDLED; 
}

public reload_tags()
{
	// Remove current database
	if(zc_tags_holder)
		ArrayDestroy(zc_tags_holder)

	// Create new database
	zc_tags_holder = ArrayCreate(database_ztags)
	new configsDir[64]
	get_configsdir(configsDir, 63)
	format(configsDir, 63, "%s/zombie_crown/zc_tags.ini", configsDir)
	new File=fopen(configsDir, "r")
	
	if (File)
	{
		static date[512], get_zname[50], get_ztag[32]
		while (!feof(File))
		{
			fgets(File,date,sizeof(date)-1);
			trim(date)

			if (date[0]==';') {
				continue
			}
			
			get_zname[0] = 0
			get_ztag[0] = 0

			if (parse(date, get_zname, sizeof(get_zname) - 1, get_ztag, sizeof(get_ztag) - 1) < 2) {
				continue
			}

			tags_database[zcname] = get_zname
			tags_database[zctag] = get_ztag
			ArrayPushArray(zc_tags_holder, tags_database)
		}
		fclose(File)
	}
	else log_amx("Error: zc_tags.ini file doesn't exist")
}

public CmdSay(id)
{
	if(!playerhastag[id] || !is_user_connected(id))
	{
		return PLUGIN_CONTINUE
	}
	
	new szArgs[194], ids[32], iNum, szName[32], szMessage[192], iTarget
	if(!is_valid_message(id, false, szArgs, charsmax(szArgs)))
	{
		return PLUGIN_HANDLED_MAIN
	}
	
	new iAlive = is_user_alive(id)
	new CsTeams:iTeam = cs_get_user_team(id)
	get_players(ids, iNum)
	get_user_name(id, szName, charsmax(szName))
	
	new const szPrefixes[2][CsTeams][] =
	{
		{
			"^1*DEAD* ",
			"^1*DEAD* ",
			"^1*DEAD* ",
			"^1*SPEC* "
		},
		{
			"",
			"",
			"",
			""
		}
	}
	console_print(0, "%s : %s", szName, szArgs)
	formatex(szMessage, charsmax(szMessage), "^4%s ^1%s^3%s^1 :  %s", g_tag[id], szPrefixes[iAlive][iTeam], szName, szArgs)
	for(new i = 0; i < iNum; i++)
	{
		iTarget = ids[i]
		if(iTarget == id || (iAlive || is_user_connected(iTarget)) && is_user_alive(iTarget) == iAlive)
		{
			message_begin(MSG_ONE_UNRELIABLE, g_iMsgID_SayText, _, iTarget)
			write_byte(id)
			write_string(szMessage)
			message_end()
		}
	}
	return PLUGIN_HANDLED_MAIN
}

public CmdSayTeam(id)
{
	if(!playerhastag[id] || !is_user_connected(id))
	{
		return PLUGIN_CONTINUE
	}
	
	new szArgs[194], ids[32], iNum, szName[32], szMessage[192]
	if(!is_valid_message(id, true, szArgs, charsmax(szArgs)))
	{
		return PLUGIN_HANDLED_MAIN
	}
	
	new iAlive = is_user_alive(id)
	new CsTeams:iTeam = CsTeams:((_:cs_get_user_team(id)) % 3)
	get_players(ids, iNum)
	get_user_name(id, szName, charsmax(szName))
	
	new const szPrefixes[2][CsTeams][] =
	{
		{
			"(Spectator)",
			"*DEAD*(Zombie)",
			"*DEAD*(Human)",
			""
		},
		{
			"(Spectator)",
			"(Zombie)",
			"(Human)",
			""
		}
	}
	console_print(0, "%s : %s", szName, szArgs)
	formatex(szMessage, charsmax(szMessage), "^4%s ^1%s^3 %s^1 :  %s", g_tag[id], szPrefixes[iAlive][iTeam], szName, szArgs);
	for(new i = 0, iTeammate; i < iNum; i++)
	{
		iTeammate = ids[i]
		if(iTeammate == id || (iAlive || is_user_connected(iTeammate)) && is_user_alive(iTeammate) == iAlive && CsTeams:((_:cs_get_user_team(iTeammate)) % 3) == iTeam)
		{
			message_begin(MSG_ONE_UNRELIABLE, g_iMsgID_SayText, _, iTeammate)
			write_byte(id)
			write_string(szMessage)
			message_end()
		}
	}
	return PLUGIN_HANDLED_MAIN
}

bool:is_valid_message(id, bool:bTeamSay, szMessage[], iLen)
{
	read_args(szMessage, iLen)
	remove_quotes(szMessage)

	if(!szMessage[0]) {
		return false
	}
	
	new iPos, cChar, i
	while((cChar = szMessage[iPos]) == '@') {
		i++
		iPos++
	}

	if(i > 0) {
		return (!(bTeamSay ? (i == 1) : (1 <= i <= 3)) || !access(id, g_iAdminChatFlag))
	}

	while(0 < (cChar = szMessage[iPos++]) <= 255) {
		if(cChar != ' ' && cChar != '%') {
			return true
		}
	}
	return false
}