#include <amxmodx>
#include <fakemeta>
#include <amxmisc>

#define PLUGIN_NAME "[ZC Nick Func]"
#define PLUGIN_VERSION "1.1"
#define PLUGIN_AUTHOR "meNe"

new const g_reason[] = "It is NOT allowed to change nick names."
new const g_name[] = "name"
new g_iTarget = 0

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	register_forward(FM_ClientUserInfoChanged, "fwClientUserInfoChanged") 
	register_event("HLTV", "NewRound", "a", "1=0", "2=0") 
	register_concmd("amx_nume", "cmdNick", ADMIN_RCON, "<name or #userid> <new nick>") 
}

new g_szRestrictedThings[][] =
{
	"Player",
	"www",
	"(1)",
	".ro",
	".net"
}

new const g_newnames[][] =
{
	"iuLIKEmeN",
	"soro__j",
	"polo[]",
	"aktiwS4s-_-",
	"RoNiN_b",
	"WizardDDD",
	"Darky_ZMD_",
	"Mutu_Radu",
	"XfunkyX",
	"butterflies",
	"ana&cornelMG",
	"texasSs",
	"crackeru7",
	"JoInTtT",
	"m1Tre",
	"MariI1I",
	"alexovk",
	"macelarul_nebun",
	"BabyFaceX",
	"Bogdane1",
	"CastorikS",
	"Lov3z",
	"FreeZeX",
	"ecstasy1",
	"Lalau4"
}

public cmdNick(id, level, cid)
{
    	if (!cmd_access(id, level, cid, 3))
        	return PLUGIN_HANDLED

    	new arg1[32], arg2[32], name[32], name2[32]

   	read_argv(1, arg1, 31)
    	read_argv(2, arg2, 31)

    	new player = cmd_target(id, arg1, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF)

    	if (!player)
        	return PLUGIN_HANDLED
    	get_user_name(id, name, 31)
    	get_user_name(player, name2, 31)
    	g_iTarget = 1
    	set_user_info(player, "name", arg2)
    	show_activity_key("ADMIN_NICK_1", "ADMIN_NICK_2", name, name2, arg2);
    	console_print(id, "[AMXX] %L", id, "CHANGED_NICK", name2, arg2)
	return PLUGIN_HANDLED
}

public fwClientUserInfoChanged(id, buffer)
{
    	if(!is_user_connected(id))
        	return FMRES_IGNORED;

    	static name[32], val[32]
    	get_user_name(id, name, 31)
    	engfunc(EngFunc_InfoKeyValue, buffer, g_name, val, 31)
    	if(equal(val, name))
       		return FMRES_IGNORED;

    	if(g_iTarget != 1)
    	{
        	engfunc(EngFunc_SetClientKeyValue, id, buffer, g_name, name)
        	console_print(id, "%s", g_reason)
        	return FMRES_SUPERCEDE;
    	}
        g_iTarget = 0
    	return FMRES_IGNORED
} 

public NewRound()
{
   	new iPlayers[32], iNum
   	get_players(iPlayers, iNum,  "ch")
   
   	if(iNum)
   	{
      		new  id
      		for(--iNum; iNum >= 0; iNum--)
      		{
         		id = iPlayers[iNum]
         		BeginDelayedNameChange(id)
      		}
   	}
}

public BeginDelayedNameChange(id)
{
   	switch(id)
   	{
      		case 1:  set_task(1.0, "ChangeNameWithDelay", id)
      		case 2:  set_task(1.2, "ChangeNameWithDelay", id)
      		case 3:  set_task(1.4, "ChangeNameWithDelay", id)
      		case 4:  set_task(1.6, "ChangeNameWithDelay", id)
      		case 5:  set_task(1.8, "ChangeNameWithDelay", id)
      		case 6:  set_task(2.0, "ChangeNameWithDelay", id)
      		case 7:  set_task(2.2, "ChangeNameWithDelay", id)
      		case 8:  set_task(2.4, "ChangeNameWithDelay", id)
      		case 9:  set_task(2.6, "ChangeNameWithDelay", id)
      		case 10:  set_task(2.8, "ChangeNameWithDelay", id)
      		case 11:  set_task(3.0, "ChangeNameWithDelay", id)
      		case 12:  set_task(3.2, "ChangeNameWithDelay", id)
      		case 13:  set_task(3.4, "ChangeNameWithDelay", id)
      		case 14:  set_task(3.6, "ChangeNameWithDelay", id)
      		case 15:  set_task(3.8, "ChangeNameWithDelay", id)
      		case 16:  set_task(4.0, "ChangeNameWithDelay", id)
      		case 17:  set_task(4.2, "ChangeNameWithDelay", id)
      		case 18:  set_task(4.4, "ChangeNameWithDelay", id)
      		case 19:  set_task(4.6, "ChangeNameWithDelay", id)
      		case 20:  set_task(4.8, "ChangeNameWithDelay", id)
      		case 21:  set_task(5.0, "ChangeNameWithDelay", id)
      		case 22:  set_task(5.0, "ChangeNameWithDelay", id)
      		case 23:  set_task(5.2, "ChangeNameWithDelay", id)
      		case 24:  set_task(5.4, "ChangeNameWithDelay", id)
      		case 25:  set_task(5.6, "ChangeNameWithDelay", id)
      		case 26:  set_task(5.8, "ChangeNameWithDelay", id)
      		case 27:  set_task(6.0, "ChangeNameWithDelay", id)
      		case 28:  set_task(6.2, "ChangeNameWithDelay", id)
      		case 29:  set_task(6.4, "ChangeNameWithDelay", id)
      		case 30:  set_task(6.6, "ChangeNameWithDelay", id)
      		case 31:  set_task(6.8, "ChangeNameWithDelay", id)
      		case 32:  set_task(7.0, "ChangeNameWithDelay", id)
   	}
}

public ChangeNameWithDelay(id)
{
   	if(!is_user_alive(id))
		return;

	new szName[32]
	get_user_name(id, szName, 31)
	for(new i = 0; i < sizeof (g_szRestrictedThings); i++)
	{
		if(containi(szName, g_szRestrictedThings[i]) != -1)
		{	
			if(is_user_alive(id)) {
				g_iTarget = 1
				set_user_info(id, "name", g_newnames[random_num(0, sizeof g_newnames - 1)])
			}
		}
	}
}
