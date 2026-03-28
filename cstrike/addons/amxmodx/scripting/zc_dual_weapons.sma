#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#include <cstrike>

#define PLUGIN "[ZC] Dual Weapons"
#define VERSION "1.2"
#define AUTHOR "Zombie Crown Team"

new cvar_enabled
new bool:g_HasDualWeapon[33]
new Float:g_LastShot[33]
new g_Weapon1[33]  // AK47
new g_Weapon2[33]  // M4A1

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	cvar_enabled = register_cvar("zc_dual_weapons", "1")
	register_clcmd("say /dual", "Command_BuyDual")
	register_clcmd("say /dualoff", "Command_RemoveDual")

	RegisterHam(Ham_Item_Deploy, "weapon_ak47", "fw_Item_Deploy_Post", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_m4a1", "fw_Item_Deploy_Post", 1)

	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
}

public Command_BuyDual(id)
{
	if(!get_pcvar_num(cvar_enabled))
		return PLUGIN_CONTINUE
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE

	// Clear weapons
	strip_user_weapons(id)
	give_item(id, "weapon_knife")

	// Give both weapons
	give_item(id, "weapon_ak47")
	give_item(id, "weapon_m4a1")

	// Get weapon entities
	g_Weapon1[id] = get_weapon_ent(id, "weapon_ak47")
	g_Weapon2[id] = get_weapon_ent(id, "weapon_m4a1")

	// Set max ammo
	if(pev_valid(g_Weapon1[id]))
	{
		cs_set_weapon_ammo(g_Weapon1[id], 90)
		set_pdata_int(g_Weapon1[id], 51, 90, 4)
		set_pdata_int(g_Weapon1[id], 52, 90, 4)
	}

	if(pev_valid(g_Weapon2[id]))
	{
		cs_set_weapon_ammo(g_Weapon2[id], 90)
		set_pdata_int(g_Weapon2[id], 51, 90, 4)
		set_pdata_int(g_Weapon2[id], 52, 90, 4)
	}

	cs_set_user_bpammo(id, CSW_AK47, 900)
	cs_set_user_bpammo(id, CSW_M4A1, 900)

	g_HasDualWeapon[id] = true

	engclient_cmd(id, "weapon_ak47")

	client_print(id, print_chat, "[ZC] Dual Weapons! Press attack to fire both!")
	client_print(id, print_chat, "[ZC] Each shot fires AK47 + M4A1 bullets")

	return PLUGIN_HANDLED
}

public Command_RemoveDual(id)
{
	g_HasDualWeapon[id] = false
	client_print(id, print_chat, "[ZC] Dual Weapons Disabled")
	return PLUGIN_HANDLED
}

public fw_Item_Deploy_Post(Ent)
{
	new id = get_pdata_cbase(Ent, 41, 4)
	if(!is_user_alive(id))
		return HAM_IGNORED

	if(g_HasDualWeapon[id])
	{
		// Refresh weapon entities
		g_Weapon1[id] = get_weapon_ent(id, "weapon_ak47")
		g_Weapon2[id] = get_weapon_ent(id, "weapon_m4a1")
	}

	return HAM_IGNORED
}

public fw_PlayerPreThink(id)
{
	if(!get_pcvar_num(cvar_enabled))
		return FMRES_IGNORED
	if(!is_user_alive(id))
		return FMRES_IGNORED
	if(!g_HasDualWeapon[id])
		return FMRES_IGNORED

	// Get current buttons
	new buttons = pev(id, pev_button)

	// Check if player is pressing attack
	if(buttons & IN_ATTACK)
	{
		new Float:time = get_gametime()

		// Fire rate limit (slightly faster than normal)
		if(time - g_LastShot[id] >= 0.08)
		{
			g_LastShot[id] = time

			// Fire both weapons
			if(pev_valid(g_Weapon1[id]))
				Fire_Weapon(id, g_Weapon1[id])
			if(pev_valid(g_Weapon2[id]))
				Fire_Weapon(id, g_Weapon2[id])
		}
	}

	return FMRES_IGNORED
}

Fire_Weapon(id, weapon)
{
	if(!pev_valid(weapon))
		return

	// Remove fire delay
	set_pdata_float(weapon, 46, 0.0, 4)  // m_flNextPrimaryAttack
	set_pdata_float(weapon, 47, 0.0, 4)  // m_flTimeWeaponIdle

	// Execute shot
	ExecuteHam(Ham_Weapon_PrimaryAttack, weapon)
}

get_weapon_ent(id, const weapon_name[])
{
	new ent = -1
	while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", weapon_name)) != 0)
	{
		if(pev_valid(ent))
		{
			new owner = get_pdata_cbase(ent, 41, 4)
			if(owner == id)
				return ent
		}
	}
	return 0
}

public client_disconnect(id)
{
	g_HasDualWeapon[id] = false
	g_Weapon1[id] = 0
	g_Weapon2[id] = 0
}
