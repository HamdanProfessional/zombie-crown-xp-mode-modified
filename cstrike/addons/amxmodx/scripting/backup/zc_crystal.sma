#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fvault>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <colored_print>
#include <zombiecrown>
#include <hamsandwich>

#define PLUGIN "[ZC Crystal System]"
#define VERSION "1.0"
#define AUTHOR "meNe"

#define CRYSTAL_CLASS	"Crystals"

new const g_models[][] = 
{ 
	"models/zombie_crown/zc_crystal.mdl"
}

#define TAKEBOX_SOUND	"zombie_crown/zc_sound_crystal.wav"
#define TASK_CRYSTAL_SHOW 943515319
new g_crystals[33], g_chances[33], bool:g_vipPassword[33], g_cvar_chances
new const g_vault_name[] = "chances"

new const numeint[][] = 
{
	"Player",
	"www",
	"(1)",
	".ro",
	".net"
}

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_logevent("LOGEVENT_RoundStart",2,"1=Round_Start")
	register_event("DeathMsg", "EVENT_Death", "a")
	register_think(CRYSTAL_CLASS, "CrystalC_Think") 
	register_forward(FM_Touch, "CrystalC_Touch")
   	register_clcmd("say /crystal" , "reload_crystal" , -1);
   	register_clcmd("say /vipchances" , "vipchances" , -1);
	register_clcmd("amx_vipc_password", "vipc", ADMIN_USER, "<password>");
	g_cvar_chances = register_cvar("zc_crystals_vip_chances", "100")
}

public plugin_precache() 
{
	for (new i = 0; i < sizeof g_models; i++)
		precache_model(g_models[i])	
	
	precache_sound(TAKEBOX_SOUND)
}

public plugin_natives()
{
	register_native("zp_get_user_crystals", "native_get_user_crystals", 1)
	register_native("zp_set_user_chances", "native_set_user_chances", 1)
}

public LOGEVENT_RoundStart()
{
	remove_entity_name(CRYSTAL_CLASS) 
}

public EVENT_Death() 
{
	new victim = read_data(2);
	if(is_user_connected(victim) && cs_get_user_team(victim) != CS_TEAM_SPECTATOR && !is_stuck(victim) && zp_get_user_zombie(victim) && !zp_is_survivor_round() && !zp_is_flamer_round() && !zp_is_sniper_round() && !zp_is_zadoc_round() && !zp_is_plague_round() && !zp_is_lnj_round() && !zp_is_guardians_round() && !zp_is_nighter_round())
	{
		new ent = create_entity("info_target")
		entity_set_string(ent, EV_SZ_classname, CRYSTAL_CLASS)
		entity_set_model(ent, g_models[random_num(0, sizeof g_models - 1)])	
		entity_set_size(ent,Float:{-2.0,-2.0,-2.0},Float:{5.0,5.0,5.0})
		entity_set_int(ent,EV_INT_solid,1)
		entity_set_int(ent,EV_INT_movetype,6)
		set_pev(ent, pev_animtime, get_gametime());
		set_pev(ent, pev_framerate, 1.0);
		set_pev(ent, pev_nextthink, halflife_time() + 0.01);
		static Float:fOrigin[3], origin[3]
		get_user_origin(victim, origin, 0)
		IVecFVec(origin, fOrigin)
		engfunc(EngFunc_SetOrigin, ent, fOrigin)
	}	
	remove_task(victim+TASK_CRYSTAL_SHOW)
}

public CrystalC_Think(entity) 
{ 
	if(is_valid_ent(entity)) 
	{
		Light(entity, 4, 0, 200, 20)
		set_pev(entity, pev_nextthink, halflife_time() + 0.01)
	}
}

public CrystalC_Touch(box, id) 
{
	if(!pev_valid(box))
		return FMRES_IGNORED
	static classname[32]
	entity_get_string(box,EV_SZ_classname,classname,31)

	if (equal(classname, CRYSTAL_CLASS))
	{
		if(is_user_connected(id) && zp_get_user_zombie(id)) 
		{
			// Init
			remove_entity(box)
			if(g_crystals[id] < 5)
			{
				g_crystals[id] = g_crystals[id] + 1
				if(g_crystals[id] >= 5)
				{
					show_menu_crystal(id)
				}
			} 

			// Effects
			client_cmd (id, "spk %s", TAKEBOX_SOUND)
			new Clr[3]
			Clr[0] = 000; Clr[1] = 150; Clr[2] = 000
			UTIL_ScreenFade(id, Clr, 0.5, 0.5, 125)
			new Shock[3]
			Shock[0] = 3; Shock[1] = 2; Shock[2] = 3
			message_begin(MSG_ONE, get_user_msgid("ScreenShake"), _, id)
			write_short((1<<12)*Shock[0])
			write_short((1<<12)*Shock[1])
			write_short((1<<12)*Shock[2])
			message_end()	
		}
	}
	return FMRES_IGNORED
} 

public zp_hclass_param(id)
{
	remove_task(id+TASK_CRYSTAL_SHOW)
}

public client_disconnected(id)
{
	remove_task(id+TASK_CRYSTAL_SHOW)
}

public zp_user_infected_post(id)
{
	if (zp_get_user_zombie(id) && !zp_get_zombie_hero(id))
	{
		set_task(1.0, "CrystalHUD", id+TASK_CRYSTAL_SHOW, _, _, "b")
	}else if(zp_get_zombie_hero(id)) {
		remove_task(id+TASK_CRYSTAL_SHOW)
	}
}

public CrystalHUD(id)
{
	id -= TASK_CRYSTAL_SHOW
	if(!zp_get_user_zombie(id) || zp_get_zombie_hero(id)) return
	new message[128]
	set_hudmessage(0, 50, 255, -1.0, 0.8, 0, 6.0, 1.1, 0.0, 0.0, -1)
	if(g_crystals[id] == 0) formatex(message, sizeof(message)-1, "Crystal status: 0/5^n[________________________]")
	else if(g_crystals[id] == 1) formatex(message, sizeof(message)-1, "Crystal status: 1/5^n[|||||___________________]")
	else if(g_crystals[id] == 2) formatex(message, sizeof(message)-1, "Crystal status: 2/5^n[||||||||||______________]")
	else if(g_crystals[id] == 3) formatex(message, sizeof(message)-1, "Crystal status: 3/5^n[|||||||||||||||_________]")
	else if(g_crystals[id] == 4) formatex(message, sizeof(message)-1, "Crystal status: 4/5^n[||||||||||||||||||||____]")
	else if(g_crystals[id] == 5) formatex(message, sizeof(message)-1, "Crystal status: 5/5^n[||||||||||||||||||||||||]")
	show_hudmessage(id, message);
}

public reload_crystal(id)
{
	if(zp_get_user_zombie(id) && g_crystals[id] >= 5)
	{
		show_menu_crystal(id)
	}else {
		colored_print(id, GREEN, "[ZC]^x01 You can not use^x04 Crystals^x01 right now!")
	}	
}

public show_menu_crystal(id)
{
	show_menu(id, 0, "\n", 1)
	new menu = menu_create("\rChoose what to get:", "menu_handler")
	new szmenu[512]
	new chances = get_pcvar_num(g_cvar_chances);

	if(g_chances[id] < chances) formatex(szmenu, 511,"\wGet +1 chance \r| \w%d\y/\w%d^n    \yYou can get \rFull VIP\y for \r15 days\y with %d chances.", g_chances[id], chances, chances)
	else formatex(szmenu, 511, "Now you can get Full VIP for 15 days^n    \yType: /vipchances")
	menu_additem(menu, szmenu)

	menu_additem(menu, "\wGet benefits^n    \yGet XP, packs, points, or coins!", "", 0)
	menu_additem(menu, "\wNothing", "", 0)
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
}
 
public menu_handler(id, menu, item)
{
	switch(item)	
	{
		case 0:
		{
			if(g_chances[id] < get_pcvar_num(g_cvar_chances))
			{
				g_chances[id] += 1
				Save(id)
				colored_print(id, GREEN, "[ZC]^x01 You have now^x03 %d^x04 chances^x01 to get a^x04 15 days VIP^x01.", g_chances[id])
				g_crystals[id] = 0
			}else if (g_chances[id] >= get_pcvar_num(g_cvar_chances)) {
				get_vip_task(id)
				g_crystals[id] = 0
			}
		}
		case 1:
		{
			show_menu_benefits(id)
		}
		case 2:
		{
			g_crystals[id] = 0
			colored_print(id, GREEN, "[ZC]^x01 You lost your^x04 Crystals^x01.")
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public show_menu_benefits(id)
{
	show_menu(id, 0, "\n", 1)
	new menu = menu_create("\rChoose the benefit wanted below:", "menu_handler_benefits")
	menu_additem(menu, "\wGet \y1\r XP", "", 0)
	menu_additem(menu, "\wGet \y1\r point", "", 0)
	menu_additem(menu, "\wGet \y2\r coins", "", 0)
	menu_additem(menu, "\wGet \y100\r packs", "", 0)
	menu_display(id, menu, 0)
}
 
public menu_handler_benefits(id, menu, item)
{
	switch(item)	
	{
		case 0:
		{
			zp_set_user_xp(id, zp_get_user_xp(id) + 1)
			colored_print(id, GREEN, "[ZC]^x01 You have got^x03 +1^x04 XP^x01 with^x04 Crystals.")
			g_crystals[id] = 0
		}
		case 1:
		{
			zp_set_user_points(id, zp_get_user_points(id) + 1)
			colored_print(id, GREEN, "[ZC]^x01 You have got^x03 +1^x04 point^x01 with^x04 Crystals.")
			g_crystals[id] = 0
		}
		case 2:
		{
			zp_set_user_coins(id, zp_get_user_coins(id) + 2)
			colored_print(id, GREEN, "[ZC]^x01 You have got^x03 +2^x04 coins^x01 with^x04 Crystals.")
			g_crystals[id] = 0
		}
		case 3:
		{
			zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + 100)
			colored_print(id, GREEN, "[ZC]^x01 You have got^x03 +100^x04 packs^x01 with^x04 Crystals.")
			g_crystals[id] = 0
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

// Chances
public vipchances(id)
{
	if(g_chances[id] >= get_pcvar_num(g_cvar_chances))
	{
		get_vip_task(id)
	}else {
		colored_print(id, GREEN, "[ZC]^x01 You still need^x03 %d^x04 chances.", (get_pcvar_num(g_cvar_chances) - g_chances[id]))
	}
}

public get_vip_task(id)
{
	if ((zv_get_user_flags(id) & ZV_DAMAGE) || g_chances[id] < get_pcvar_num(g_cvar_chances)) 
	{
		colored_print(id, GREEN, "[ZC]^x01 === YOU CAN'T BUY!!! ===")
		return PLUGIN_HANDLED
	}
	g_vipPassword[id] = true;
	client_cmd(id, "messagemode amx_vipc_password");
	colored_print(id, GREEN, "[ZC]^x01 SCRIE PAROLA DORITA. WRITE A PASSWORD.")
	colored_print(id, GREEN, "[ZC]^x01 SCRIE PAROLA DORITA. WRITE A PASSWORD.")
	colored_print(id, GREEN, "[ZC]^x01 SCRIE PAROLA DORITA. WRITE A PASSWORD.")
	return PLUGIN_HANDLED
}

public vipc(id) 
{
	if (!g_vipPassword[id]) 
	{
		colored_print(id, GREEN, "[ZC]^x01 === YOU CAN'T BUY!!! ===");
		return PLUGIN_HANDLED;
	}

	new password[35], holder[200], vsdate[20];
	get_date(15, vsdate, charsmax(vsdate))
    	new name[32]
    	get_user_name(id, name, sizeof(name) - 1)
	read_args(password, 34);
	remove_quotes(password);
	if (equal(password, "")) 
	{
		colored_print(id, GREEN, "[ZC]^x01 SCRIE PAROLA DORITA. WRITE A PASSWORD.");
		colored_print(id, GREEN, "[ZC]^x01 SCRIE PAROLA DORITA. WRITE A PASSWORD.");
		colored_print(id, GREEN, "[ZC]^x01 SCRIE PAROLA DORITA. WRITE A PASSWORD.");
		client_cmd(id, "messagemode amx_vipc_password");
		return PLUGIN_HANDLED;
	}
	g_vipPassword[id] = false;

	// Announce
	colored_print(id, GREEN, "[ZC]^x01 Nick:^x04 %s^x01 | Password:^x04 %s", name, password);
	colored_print(id, GREEN, "[ZC]^x01 To login, write in^x04 console^x01 this: ^x04setinfo _pw %s", password);

	// Set access
	g_chances[id] = 0
	Save(id)
	client_cmd(id, "topcolor ^"^";rate ^"^";model ^"^";setinfo ^"_pw^" ^"%s^"", password);
	formatex(holder, charsmax(holder), "^"%s^" ^"%s^" ^"abcde^" ^"e^"; Exp: %s", name, password, vsdate)
	new configdir[200]
	get_configsdir(configdir, 199)
	new configfile1[200]
	format(configfile1,199,"%s/zombie_crown/zc_vip.ini",configdir)
	write_file(configfile1, holder, -1)
	server_cmd("amx_reloadvips")
	return PLUGIN_HANDLED;
}

public client_putinserver(id)
{
	if(is_user_connected(id))
	{
		Load(id)
		g_crystals[id] = 0
	}
}

public Load(id)  
{ 
    	new name[32], data[16]
    	get_user_name(id, name, sizeof(name) - 1)
    	if(fvault_get_data(g_vault_name, name, data, sizeof(data) - 1)) {
        	g_chances[id] = str_to_num(data)
    	}else {
        	g_chances[id] = 0
	}
}

public Save(id) 
{	
    	new name[32], data[16]
    	get_user_name(id, name, sizeof(name) - 1)
	for (new i = 0; i<sizeof(numeint); i++)
	{
		if(containi(name, numeint[i]) != -1) {
			return PLUGIN_HANDLED;
		}		
	}
    	num_to_str(g_chances[id], data, sizeof(data) - 1)
    	fvault_pset_data(g_vault_name, name, data)
	return PLUGIN_CONTINUE;
}

stock get_date(days, string[], chars) 
{
	
	new y, m, d
	date(y, m ,d)
	
	d+=days
	
	new go = true
	while(go) {
		switch(m) {
			case 1,3, 5, 7, 8, 10: {
				if(d>31) { d=d-31; m++; }
				else go = false
			}
			case 2: {
				if(d>28) { d=d-28; m++; }
				else go = false
			}
			case 4, 6, 9, 11: {
				if(d>30) { d=d-30; m++; }
				else go = false
			}
			case 12: {
				if(d>31) { d=d-31; y++; m=1; }
				else go = false
			}
		}
	}
	formatex(string, chars, "m%dd%dy%d", m, d ,y)
}

// Stocks
stock UTIL_ScreenFade(id=0,iColor[3],Float:flFxTime=-1.0,Float:flHoldTime=0.0,iAlpha=0,iFlags=0x0000,bool:bReliable=false,bool:bExternal=false) 
{
	if(id && !is_user_connected(id))
		return;
	
	new iFadeTime;
	if(flFxTime == -1.0) 
	{
		iFadeTime = 4;
	}
	else {
		iFadeTime = FixedUnsigned16(flFxTime , 1<<12);
	}
	
	static gmsgScreenFade;
	if(!gmsgScreenFade) {
		gmsgScreenFade = get_user_msgid("ScreenFade");
	}
	
	new MSG_DEST;
	if(bReliable) {
		MSG_DEST = id ? MSG_ONE : MSG_ALL;
	}
	else {
		MSG_DEST = id ? MSG_ONE_UNRELIABLE : MSG_BROADCAST;
	}
	
	if(bExternal) {
		emessage_begin(MSG_DEST, gmsgScreenFade, _, id);
		ewrite_short(iFadeTime);
		ewrite_short(FixedUnsigned16(flHoldTime , 1<<12));
		ewrite_short(iFlags);
		ewrite_byte(iColor[0]);
		ewrite_byte(iColor[1]);
		ewrite_byte(iColor[2]);
		ewrite_byte(iAlpha);
		emessage_end();
	}
	else {
		message_begin(MSG_DEST, gmsgScreenFade, _, id);
		write_short(iFadeTime);
		write_short(FixedUnsigned16(flHoldTime , 1<<12));
		write_short(iFlags);
		write_byte(iColor[0]);
		write_byte(iColor[1]);
		write_byte(iColor[2]);
		write_byte(iAlpha);
		message_end();
	}
}

stock FixedUnsigned16(Float:flValue, iScale) 
{
	new iOutput;
	
	iOutput = floatround(flValue * iScale);
	if(iOutput < 0)
		iOutput = 0;
	
	if(iOutput > 0xFFFF)
		iOutput = 0xFFFF;
	return iOutput;
}

public is_stuck(id) 
{
	static Float:originF[3]
	pev(id, pev_origin, originF)
	engfunc(EngFunc_TraceHull, originF, originF, 0,(pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0)
	if(get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen))
		return true
	return false
}

stock Light(entity, radius, red, green, blue) 
{	
	if(is_valid_ent(entity)) 
	{
		static Float:origin[3]
		pev(entity, pev_origin, origin)
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY, _, entity);
		write_byte(TE_DLIGHT)
		engfunc(EngFunc_WriteCoord, origin[0])
		engfunc(EngFunc_WriteCoord, origin[1])
		engfunc(EngFunc_WriteCoord, origin[2])
		write_byte(radius) 
		write_byte(red)
		write_byte(green)
		write_byte(blue)
		write_byte(1)
		write_byte(0)
		message_end();
	}
}

// Native: zp_set_user_chances
public native_set_user_chances(id, amount)
{
	g_chances[id] = amount;
	Save(id)
}

// Native: zp_get_user_crystals
public native_get_user_crystals(id)
{
	return g_crystals[id];
}
