#include <amxmodx>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <cstrike>
#include <engine>
#include <zombiecrown>
#include <colored_print>

#define is_valid(%0)    (1 <= %0 <= g_MaxPlayers && is_user_connected(%0) && !is_user_hltv(%0) && !is_user_bot(%0))

// Weapon M16 Model
new M4A1_V_MODEL[64] = "models/zombie_crown/v_m16.mdl"

// Cvars ...
new cvar_m16_dmg, cvar_m16_oneround, cvar_m16_Model, cvar_m16_Clip

// Zoom Cvar...
new g_WepZoom[33]

// Has M16 Cvar
new bool:g_HasM16[33]
new bool:bIsAlive [33]

//Const Weapon ...
const Wep_m4a1 = ((1<<CSW_M4A1))

// Global variables
new g_MaxPlayers, g_Restarted

// No Recoil Float
new Float:gPunchAngle[3] = { 0.0, 0.0, 0.0 }

// Register Name , Cost And Item Id ...
new g_itemid

public plugin_init()
{
	// Register Plugin ...
	register_plugin("[ZC M16]", "1.0", "Dare-Devil")

	// Register Cvars ...
	cvar_m16_Model = register_cvar("zp_m16_costom_model", "1")
	cvar_m16_oneround = register_cvar("zp_m16_one_round", "0")
	cvar_m16_dmg = register_cvar("zp_m16_extra_dmg", "1.3")
	g_MaxPlayers = get_maxplayers()
	cvar_m16_Clip = register_cvar("zp_m16_Clip", "1")

	// Register Extra Item ..
	g_itemid = zp_register_extra_item("M16 Weapon", 350, ZP_TEAM_HUMAN, REST_NONE, 0)

	// Reigister New Round Event ...
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")

	// Weapon Event ...
	register_event("WeapPickup","checkModel","b","1=19")
	register_event("CurWeapon","checkWeapon","be","1=1")

	// Register Ham TakeDamage ...
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	
	// Register Forward (For Weapon Zoom) ...
	register_forward(FM_CmdStart, "fw_CmdStart")
}

public plugin_natives()
{
	register_native("give_weapon_m16", "native_give_weapon_m16", 1)
	register_native("get_weapon_m16", "native_get_weapon_m16", 1)
}

// Precache Sound And Model
public plugin_precache()
{
	precache_model(M4A1_V_MODEL)
}

// Do Not Give Player Weapon M16 When He Connect
public client_connect(id)
{
	g_HasM16[id] = false
	bIsAlive [id] = false
}

// Check Crav zp_m16_oneround If 1 Revome Player Weapon M16
public Event_NewRound ()
{
	if (g_Restarted)
	{
		arrayset (g_HasM16, false, 33)
	}
	g_Restarted = false
	if (get_pcvar_num (cvar_m16_oneround) >= 1)
	{
		// Loop
		for (new i  = 1; i < g_MaxPlayers; i++)
		{
			g_HasM16 [ i ] = false
			
		}
	}	
}

// Creck When Game Restarted ...
public Event_GameRestart ()
{
	g_Restarted = true
}

// Set M16 Model
public checkModel(id)
{
	if (zp_get_user_zombie(id))
		return PLUGIN_HANDLED
	
	new szWeapID = read_data(2)
	if (szWeapID == CSW_M4A1 && g_HasM16[id] == true && get_pcvar_num(cvar_m16_Model))
	{
		set_pev(id, pev_viewmodel2, M4A1_V_MODEL)
	}
	return PLUGIN_HANDLED
}

public checkWeapon(id)
{
	if(is_valid(id)) {
	new plrClip, plrAmmo, plrWeap[32]
	new plrWeapId
	plrWeapId = get_user_weapon(id, plrClip , plrAmmo)
	if (plrWeapId == CSW_M4A1 && g_HasM16[id])
	{
		checkModel(id)
	}
	else 
	{
		return PLUGIN_CONTINUE
	}
	
	if (plrClip == 0 && get_pcvar_num(cvar_m16_Clip))
	{
		// If the user is out of ammo..
		get_weaponname(plrWeapId, plrWeap, 31)
		// Get the name of their weapon
		give_item(id, plrWeap)
		engclient_cmd(id, plrWeap) 
		engclient_cmd(id, plrWeap)
		engclient_cmd(id, plrWeap)
	}
	}
	return PLUGIN_HANDLED
}

// Give Weapon M16 No Recoil...
public server_frame()
{
   	for (new id = 1; id <= g_MaxPlayers; id++)         
    	{
        	if (is_user_alive(id) && g_HasM16[id])
            		set_pev(id, pev_punchangle, gPunchAngle);
	}
}

// Give Zoom For Weapon M16
public fw_CmdStart(id, uc_handle, seed)
{
	if(!is_user_alive(id)) 
		return PLUGIN_HANDLED
	
	if((get_uc(uc_handle, UC_Buttons) & IN_RELOAD) && !(pev(id, pev_oldbuttons) & IN_RELOAD))
	{
		new szClip, szAmmo
		new szWeapID = get_user_weapon(id, szClip, szAmmo)
		
		if(szWeapID == CSW_M4A1 && g_HasM16[id] == true && !g_WepZoom[id] == true)
		{
			g_WepZoom[id] = true
			cs_set_user_zoom(id, CS_SET_AUGSG552_ZOOM, 0)
			emit_sound(id, CHAN_ITEM, "weapons/zoom.wav", 0.20, 2.40, 0, 100)
		}
		
		else if (szWeapID == CSW_M4A1 && g_HasM16[id] == true && g_WepZoom[id])
		{
			g_WepZoom[ id ] = false
			cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
			
		}
		
	}
	return PLUGIN_HANDLED
}

// Check Cvar zp_m16_extra_dmg And Multipli Dmg ...
public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
	if(is_valid(attacker)) {
    		if (get_user_weapon(attacker) == CSW_M4A1 && g_HasM16[attacker])
    		{
        		SetHamParamFloat(4, damage * get_pcvar_float(cvar_m16_dmg))
    		}
	}
}

public native_give_weapon_m16(id)
{
	if(is_user_alive(id))
	{
		give_item(id, "weapon_m4a1")
		g_HasM16[id] = true;
	}
}

public native_get_weapon_m16(id)
{
	return g_HasM16[id];
}

// When Player Buy This Extra Items, Give Him Weapon And Show Message ...
public zp_extra_item_selected(player, itemid)
{
	if (itemid == g_itemid)
	{
		if (user_has_weapon(player, CSW_M4A1))
		{
			drop_prim(player)
		}
		
		give_item(player, "weapon_m4a1")
		colored_print(player, GREEN, "[ZC]^x01 You've got a^x04 M16^x01! Press^x03 E^x01 (Use) for^x04 zoom^x01 ability ...")
		g_HasM16[player] = true;
	}
}

stock drop_prim(id) 
{
	new weapons[32], num
	get_user_weapons(id, weapons, num)
	for (new i = 0; i < num; i++) {
		if (Wep_m4a1 & (1<<weapons[i])) 
		{
			static wname[32]
			get_weaponname(weapons[i], wname, sizeof wname - 1)
			engclient_cmd(id, "drop", wname)
		}
	}
}