#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <cstrike>
#include <zombiecrown>
#include <colored_print>

new AK47_V_MODEL[64] = "models/zombie_crown/v_diamond_ak47.mdl"
new AK47_P_MODEL[64] = "models/zombie_crown/p_diamond_ak47.mdl"
new cvar_dmgmultiplier, cvar_diamondbullets,  cvar_custommodel, cvar_uclip
new g_itemid
//new g_itemid1
new bool:g_HasM4[33]
new g_hasZoom[33]
new bullets[33]
new m_spriteTexture
const Wep_ak47 = ((1<<CSW_AK47))

public plugin_init()
{
	register_plugin("[ZC Diamond AK47]", "1.1", "n00bi2763")
	cvar_dmgmultiplier = register_cvar("zp_diamondak_dmg_multiplier", "5")
	cvar_custommodel = register_cvar("zp_diamondak_custom_model", "1")
	cvar_diamondbullets = register_cvar("zp_diamondak_diamond_bullets", "1")
	cvar_uclip = register_cvar("zp_diamondak_unlimited_clip", "1")
	g_itemid = zp_register_extra_item("Diamond AK47", 800, ZP_TEAM_HUMAN, REST_NONE, 2)
	register_event("DeathMsg", "Death", "a")
	register_event("WeapPickup","checkModel","b","1=19")
	register_event("CurWeapon","checkWeapon","be","1=1")
	register_event("CurWeapon", "make_tracer", "be", "1=1", "3>0")
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	register_forward(FM_CmdStart, "fw_CmdStart")
	RegisterHam(Ham_Spawn, "player", "fwHamPlayerSpawnPost", 1)
	register_concmd("amx_givediamondak", "give_gun_diamondak", ADMIN_LEVEL_C," <name or #userid>")
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
	precache_model(AK47_V_MODEL)
	precache_model(AK47_P_MODEL)
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
	
	if (szWeapID == CSW_AK47 && g_HasM4[id] == true && get_pcvar_num(cvar_custommodel))
	{
		set_pev(id, pev_viewmodel2, AK47_V_MODEL)
		set_pev(id, pev_weaponmodel2, AK47_P_MODEL)
	}
	return PLUGIN_HANDLED
}

public checkWeapon(id)
{
	new plrClip, plrAmmo, plrWeap[32]
	new plrWeapId
	
	plrWeapId = get_user_weapon(id, plrClip , plrAmmo)
	
	if (plrWeapId == CSW_AK47 && g_HasM4[id])
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
    	if (is_user_connected(attacker) && get_user_weapon(attacker) == CSW_AK47 && g_HasM4[attacker])
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
		
		if(szWeapID == CSW_AK47 && g_HasM4[id] == true && !g_hasZoom[id] == true)
		{
			g_hasZoom[id] = true
			cs_set_user_zoom(id, CS_SET_AUGSG552_ZOOM, 0)
			emit_sound(id, CHAN_ITEM, "weapons/zoom.wav", 0.20, 2.40, 0, 100)
		}
		else if (szWeapID == CSW_AK47 && g_HasM4[id] == true && g_hasZoom[id])
		{
			g_hasZoom[id] = false
			cs_set_user_zoom(id, CS_RESET_ZOOM, 0)	
		}
	}
	return PLUGIN_HANDLED
}

public make_tracer(id)
{
	if (get_pcvar_num(cvar_diamondbullets))
	{
		new clip,ammo
		new wpnid = get_user_weapon(id,clip,ammo)
		new pteam[16]
		get_user_team(id, pteam, 15)
		if ((bullets[id] > clip) && (wpnid == CSW_AK47) && g_HasM4[id]) 
		{
			new vec1[3], vec2[3]
			get_user_origin(id, vec1, 1) // origin; your camera point.
			get_user_origin(id, vec2, 4) // termina; where your bullet goes (4 is cs-only)
			
			//BEAMENTPOINTS
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte (0)     //TE_BEAMENTPOINTS 0
			write_coord(vec1[0])
			write_coord(vec1[1])
			write_coord(vec1[2])
			write_coord(vec2[0])
			write_coord(vec2[1])
			write_coord(vec2[2])
			write_short(m_spriteTexture)
			write_byte(1) // framestart
			write_byte(5) // framerate
			write_byte(2) // life
			write_byte(10) // width
			write_byte(0) // noise
			write_byte(51)     // r, g, b
			write_byte(204)       // r, g, b
			write_byte(255)       // r, g, b
			write_byte(200) // brightness
			write_byte(150) // speed
			message_end()
		}
		bullets[id] = clip
	}
}

public give_AK47diamond(player)
{
	if (user_has_weapon(player, CSW_AK47)) drop_prim(player)
	give_item(player, "weapon_ak47")
	g_HasM4[player] = true;
}

public zp_extra_item_selected(player, itemid)
{
	if (itemid == g_itemid)
	{
		give_AK47diamond(player)
	}
	return PLUGIN_HANDLED
}

//public zp_extra_item_selected(id, itemid1)
//{
//	if(itemid1 == g_itemid1)
//	{
//			give_AK47diamond(id)
//	}
//	return PLUGIN_HANDLED
//}

public give_gun_gak47(id, level, cid)
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
		give_AK47diamond(player)
		client_print(id, print_console, "You gave to %s a Diamond AK47 Weapon.", player_name)
		log_to_file("zc_event.log", "[WEAPON EVENT : DIAMOND AK47] --- [%s] - [%s]", admin_name, player_name);
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
		if (Wep_ak47 & (1<<weapons[i])) 
		{
			static wname[32]
			get_weaponname(weapons[i], wname, sizeof wname - 1)
			engclient_cmd(id, "drop", wname)
		}
	}
}