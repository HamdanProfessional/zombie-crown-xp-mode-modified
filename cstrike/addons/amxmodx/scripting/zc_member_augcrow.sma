#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <cstrike>
#include <zombiecrown>
#include <colored_print>

new AUG_V_MODEL[64] = "models/zombie_crown/v_augCrow.mdl"
new AUG_P_MODEL[64] = "models/zombie_crown/p_augCrow.mdl"
new cvar_dmgmultiplier,  cvar_custommodel, cvar_uclip
new g_itemid
new bool:g_HasM4[33]
new g_hasZoom[33]
new m_spriteTexture
const Wep_aug = ((1<<CSW_AUG))

public plugin_init()
{
	register_plugin("[ZC AUG Crow]", "1.1", "n00bi2763")
	cvar_dmgmultiplier = register_cvar("zp_augcrow_dmg_multiplier", "1.8")
	cvar_custommodel = register_cvar("zp_augcrow_custom_model", "1")
	cvar_uclip = register_cvar("zp_augcrow_unlimited_clip", "1")
	g_itemid = zv_register_extra_item("Aug Crow", 120, ZV_TEAM_HUMAN, REST_NONE, 2)
	register_event("DeathMsg", "Death", "a")
	register_event("WeapPickup","checkModel","b","1=19")
	register_event("CurWeapon","checkWeapon","be","1=1")
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	register_forward(FM_CmdStart, "fw_CmdStart")
	RegisterHam(Ham_Spawn, "player", "fwHamPlayerSpawnPost", 1)
	register_concmd("amx_giveaugcrow", "give_gun_augcrow", ADMIN_LEVEL_C," <name or #userid>")
}

public client_connect(id)
{
	g_HasM4[id] = false
}

public client_disconnect(id)
{
	g_HasM4[id] = false
}

public Death()
{
	g_HasM4[read_data(2)] = false
}

public fwHamPlayerSpawnPost(id)
{
	g_HasM4[id] = false
}

public plugin_precache()
{
	precache_model(AUG_V_MODEL)
	precache_model(AUG_P_MODEL)
	m_spriteTexture = precache_model("sprites/dot.spr")
	precache_sound("weapons/zoom.wav")
}

public zp_user_infected_post(id)
{
	if (zp_get_user_zombie(id))
	{
		g_HasM4[id] = false
	}
}

public checkModel(id)
{
	if (zp_get_user_zombie(id))
		return PLUGIN_HANDLED
	
	new szWeapID = read_data(2)
	
	if (szWeapID == CSW_AUG && g_HasM4[id] == true && get_pcvar_num(cvar_custommodel))
	{
		set_pev(id, pev_viewmodel2, AUG_V_MODEL)
		set_pev(id, pev_weaponmodel2, AUG_P_MODEL)
	}
	return PLUGIN_HANDLED
}

public checkWeapon(id)
{
	new plrClip, plrAmmo, plrWeap[32]
	new plrWeapId
	
	plrWeapId = get_user_weapon(id, plrClip , plrAmmo)
	
	if (plrWeapId == CSW_AUG && g_HasM4[id])
	{
		checkModel(id)
	}
	else 
	{
		return PLUGIN_CONTINUE
	}
	
	if (plrClip == 0 && get_pcvar_num(cvar_uclip))
	{
		// If the user is out of ammo..
		get_weaponname(plrWeapId, plrWeap, 31)
		// Get the name of their weapon
		give_item(id, plrWeap)
		engclient_cmd(id, plrWeap) 
		engclient_cmd(id, plrWeap)
		engclient_cmd(id, plrWeap)
	}
	return PLUGIN_HANDLED
}



public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
    	if (is_user_connected(attacker) && get_user_weapon(attacker) == CSW_AUG && g_HasM4[attacker])
    	{
       		SetHamParamFloat(4, damage * get_pcvar_float(cvar_dmgmultiplier))
    	}
}

public fw_CmdStart(id, uc_handle, seed)
{
	if(!is_user_alive(id)) 
		return PLUGIN_HANDLED
	
	if((get_uc(uc_handle, UC_Buttons) & IN_ATTACK2) && !(pev(id, pev_oldbuttons) & IN_ATTACK2))
	{
		new szClip, szAmmo
		new szWeapID = get_user_weapon(id, szClip, szAmmo)
		
		if(szWeapID == CSW_AUG && g_HasM4[id] == true && !g_hasZoom[id] == true)
		{
			g_hasZoom[id] = true
			cs_set_user_zoom(id, CS_SET_AUGSG552_ZOOM, 0)
			emit_sound(id, CHAN_ITEM, "weapons/zoom.wav", 0.20, 2.40, 0, 100)
		}
		else if (szWeapID == CSW_AUG && g_HasM4[id] == true && g_hasZoom[id])
		{
			g_hasZoom[id] = false
			cs_set_user_zoom(id, CS_RESET_ZOOM, 0)	
		}
	}
	return PLUGIN_HANDLED
}


public give_augcrow(player)
{
	if (user_has_weapon(player, CSW_AUG)) drop_prim(player)
	give_item(player, "weapon_aug")
	g_HasM4[player] = true;
}

public zv_extra_item_selected(player, itemid)
{
	if (itemid == g_itemid)
	{
		give_augcrow(player)
	}
	return PLUGIN_HANDLED
}

public give_gun_augcrow(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2))
	{
        	return PLUGIN_HANDLED
	}
	new target[32]
    	read_argv(1, target, 31)
	new player = cmd_target(id, target, 8)
    	if(!player) 
	{
		return PLUGIN_HANDLED
	} 
    	if(is_user_alive(player) && !zp_get_user_zombie(player) && !zp_get_human_hero(player) && !zp_get_zombie_hero(player))
	{
		new admin_name [32], player_name[32]
    		get_user_name(id, admin_name, 31)
    		get_user_name(player, player_name, 31)
		give_augcrow(player)
		client_print(id, print_console, "You gave to %s a AUG CROW Weapon.", player_name)
		log_to_file("zc_event.log", "[WEAPON EVENT : AUG CROW] --- [%s] - [%s]", admin_name, player_name);
	}else{
		client_print(id, print_console, "The target must be valid (alive and human).")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

stock drop_prim(id) 
{
	new weapons[32], num
	get_user_weapons(id, weapons, num)
	for (new i = 0; i < num; i++) {
		if (Wep_aug & (1<<weapons[i])) 
		{
			static wname[32]
			get_weaponname(weapons[i], wname, sizeof wname - 1)
			engclient_cmd(id, "drop", wname)
		}
	}
}
