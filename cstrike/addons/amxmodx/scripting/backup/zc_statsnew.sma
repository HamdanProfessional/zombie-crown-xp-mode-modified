#include <amxmodx>
#include <csx>
#include <colored_print>

#define MAX_BUFFER_LENGTH 2047
#define MAX_NAME_LENGTH 31

new g_sBuffer[MAX_BUFFER_LENGTH + 1]
new toggle_sound

public plugin_init()
{
	register_plugin("[ZC Stats New]", "1.0", "meNe")
	register_clcmd("say /rank", "cmdRank")
	register_clcmd("say /top15", "cmdTop15", 0);
	register_clcmd("say_team /top15", "cmdTop15", 0);
	toggle_sound = register_cvar("cfg_top15_sound", "0")
}

public cmdRank(id)
{
	new izStats[8], izBody[8]
	new iRankPos, iRankMax
	
	iRankPos = get_user_stats(id, izStats, izBody)
	iRankMax = get_statsnum()
	
	colored_print(id, GREEN, "[ZC]^x01 Your rank is^x03 %d^x01 from^x03 %d^x01 with^x03 %d^x04 kills^x01 and^x03 %d^x04 deaths.", iRankPos, iRankMax, izStats[0], izStats[1])
	
	return PLUGIN_CONTINUE
}

format_top15(sBuffer[2048])
{
	new loc1 = get_statsnum();
	new loc2 = get_statsnum();
	new loc3 = get_statsnum();

	new iMax = get_statsnum();
	new izStats[8], izBody[8], t_sName[32];
	new iLen = 0;

	if (iMax > 15)
	{
		iMax = 15;
	}

	loc1 = 1;
	loc2 = 2;
	loc3 = 3;

	iLen = format(sBuffer, 2047, "<body bgcolor=black><font color=green><pre>");
	iLen += format(sBuffer[iLen], 2047 - iLen, "%2s %-22.22s %6s %6s^n", "#", "Nickname", "Kills", "Deaths");

	for (new i = 0; i < loc1 && 2047 - iLen > 0; i++)
	{
		get_stats(i, izStats, izBody, t_sName, 31);
		replace_all(t_sName, 31, "<", "[");
		replace_all(t_sName, 31, ">", "]");
		iLen += format(sBuffer[iLen], 2047 - iLen, "%2d <font color=#ff0000>%-22.22s</font> %6d %6d <img src=http://cdn1.iconfinder.com/data/icons/ledicons/trophy.png>^n", i + 1, t_sName, izStats[0], izStats[1]);
	}

	for (new i = 1; i < loc2 && 2047 - iLen > 0; i++)
	{
		get_stats(i, izStats, izBody, t_sName, 31);
		replace_all(t_sName, 31, "<", "[");
		replace_all(t_sName, 31, ">", "]");
		iLen += format(sBuffer[iLen], 2047 - iLen, "%2d <font color=#07fcff>%-22.22s</font> %6d %6d <img src=http://cdn1.iconfinder.com/data/icons/fatcow/16/cup_silver.png>^n", i + 1, t_sName, izStats[0], izStats[1])
	}

	for (new i = 2; i < loc3 && 2047 - iLen > 0; i++)
	{
		get_stats(i, izStats, izBody, t_sName, 31);
		replace_all(t_sName, 31, "<", "[");
		replace_all(t_sName, 31, ">", "]");
		iLen += format(sBuffer[iLen], 2047 - iLen, "%2d <font color=#fff007>%-22.22s</font> %6d %6d <img src=http://cdn1.iconfinder.com/data/icons/customicondesign-office7-shadow-png/16/Trophy-bronze.png>^n", i + 1, t_sName, izStats[0], izStats[1])
	}


	for (new i = 3; i < iMax && 2047 - iLen > 0; i++)
	{
		get_stats(i, izStats, izBody, t_sName, 31);
		replace_all(t_sName, 31, "<", "[");
		replace_all(t_sName, 31, ">", "]");
		iLen += format(sBuffer[iLen], 2047 - iLen, "%2d %-22.22s %6d %6d^n", i + 1, t_sName, izStats[0], izStats[1]);
	}
}

public cmdTop15(id)
{
	format_top15(g_sBuffer);
	show_motd(id, g_sBuffer, "Top 15");

	if (get_pcvar_num(toggle_sound) != 0)
	{
		client_cmd(id,"spk ^"^"")
	}

	return PLUGIN_CONTINUE;
}