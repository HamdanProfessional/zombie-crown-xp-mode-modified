#include <amxmodx>
#include <fakemeta>
#include <zombiecrown>
#include <colored_print>

/*================================================================================
 [Plugin Customization]
=================================================================================*/

// CS Offsets
#if cellbits == 32
const OFFSET_CLIPAMMO = 51
#else
const OFFSET_CLIPAMMO = 65
#endif
const OFFSET_LINUX_WEAPONS = 4

// Max Clip for weapons
new const MAXCLIP[] = { -1, 13, -1, 10, 1, 7, -1, 30, 30, 1, 30, 20, 25, 30, 35, 25, 12, 20,
			10, 30, 100, 8, 30, 30, 20, 2, 7, 30, 30, -1, 50 }

new g_itemid_minfammo, g_has_munlimited_clip[33], g_allmapuc[33]

public plugin_init()
{
	register_plugin("[ZC Unlimited Clip]", "1.0", "meNe")
	g_itemid_minfammo = zp_register_extra_item("Unlimited Clip - 1 map", 125, ZP_TEAM_HUMAN, REST_NONE, 0)	
	register_message(get_user_msgid("CurWeapon"), "message_cur_weapon")
}

public client_connect(id)
{
	g_has_munlimited_clip[id] = false
	g_allmapuc[id] = false
}

// Player buys our upgrade, set the unlimited ammo flag
public zp_extra_item_selected(player, itemid)
{
	if (itemid == g_itemid_minfammo)
	{
		if(g_has_munlimited_clip[player])
		{
			colored_print(player, GREEN, "[ZC]^x01 You already have this item.")
			return ZP_PLUGIN_HANDLED
		}
		g_has_munlimited_clip[player] = true
		if(!g_allmapuc[player])
		{
			g_allmapuc[player] = true
		}
		colored_print(player, GREEN, "[ZC]^x01 Enjoy! You have^x04 the whole map^x03 unlimited clip.")
	}
	return PLUGIN_HANDLED
}

public zp_hclass_param(id)
{
    	if(g_allmapuc[id] && !zp_get_human_hero(id) && !g_has_munlimited_clip[id])  
	{
		g_has_munlimited_clip[id] = true
	}
}

// Unlimited clip code
public message_cur_weapon(msg_id, msg_dest, msg_entity)
{
	// Player doesn't have the unlimited clip upgrade
	if (!g_has_munlimited_clip[msg_entity])
		return;
	
	// Player not alive or not an active weapon
	if (!is_user_alive(msg_entity) || get_msg_arg_int(1) != 1)
		return;
	
	static weapon, clip
	weapon = get_msg_arg_int(2) // get weapon ID
	clip = get_msg_arg_int(3) // get weapon clip
	
	// Unlimited Clip Ammo
	if (MAXCLIP[weapon] > 2) // skip grenades
	{
		set_msg_arg_int(3, get_msg_argtype(3), MAXCLIP[weapon]) // HUD should show full clip all the time
		
		if (clip < 2) // refill when clip is nearly empty
		{
			// Get the weapon entity
			static wname[32], weapon_ent
			get_weaponname(weapon, wname, sizeof wname - 1)
			weapon_ent = fm_find_ent_by_owner(-1, wname, msg_entity)
			
			// Set max clip on weapon
			fm_set_weapon_ammo(weapon_ent, MAXCLIP[weapon])
		}
	}
}

// Find entity by its owner (from fakemeta_util)
stock fm_find_ent_by_owner(entity, const classname[], owner)
{
	while ((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", classname)) && pev(entity, pev_owner) != owner) {}
	
	return entity;
}

// Set Weapon Clip Ammo
stock fm_set_weapon_ammo(entity, amount)
{
	set_pdata_int(entity, OFFSET_CLIPAMMO, amount, OFFSET_LINUX_WEAPONS);
}