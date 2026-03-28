#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <fun>
#include <cstrike>

#define PLUGIN "[ZC] Dual Weapons"
#define VERSION "1.1"
#define AUTHOR "Zombie Crown Team"

new cvar_enabled
new bool:g_HasDualWeapon[33]
new g_MsgCurWeapon
new bool:g_IsFiring[33]
new Float:g_LastFireTime[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	cvar_enabled = register_cvar("zc_dual_weapons", "1")
	register_clcmd("say /dual", "Command_BuyDual")
	register_clcmd("say /dualoff", "Command_RemoveDual")

	g_MsgCurWeapon = get_user_msgid("CurWeapon")

	// Hook PrimaryAttack for both weapons to make them fire together
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m4a1", "fw_Weapon_PrimaryAttack_Post", 1)
}

public Command_BuyDual(id)
{
	if(!get_pcvar_num(cvar_enabled))
		return PLUGIN_CONTINUE
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE

	// Clear any existing weapons first
	strip_user_weapons(id)
	give_item(id, "weapon_knife")

	// Give both weapons
	give_item(id, "weapon_ak47")
	give_item(id, "weapon_m4a1")

	// Set maximum ammo for both
	new ent1 = fm_get_user_weapon_entity(id, CSW_AK47)
	if(pev_valid(ent1))
	{
		cs_set_weapon_ammo(ent1, 90)
		set_pdata_int(ent1, 51, 90, 4)
		set_pdata_int(ent1, 52, 90, 4)
	}

	new ent2 = fm_get_user_weapon_entity(id, CSW_M4A1)
	if(pev_valid(ent2))
	{
		cs_set_weapon_ammo(ent2, 90)
		set_pdata_int(ent2, 51, 90, 4)
		set_pdata_int(ent2, 52, 90, 4)
	}

	// Set extra backpack ammo
	cs_set_user_bpammo(id, CSW_AK47, 900)
	cs_set_user_bpammo(id, CSW_M4A1, 900)

	g_HasDualWeapon[id] = true
	g_IsFiring[id] = false

	engclient_cmd(id, "weapon_ak47")

	client_print(id, print_chat, "[ZC] Dual Weapons Activated! Both weapons fire together!")
	client_print(id, print_chat, "[ZC] Use /dualoff to disable")

	return PLUGIN_HANDLED
}

public Command_RemoveDual(id)
{
	g_HasDualWeapon[id] = false
	client_print(id, print_chat, "[ZC] Dual Weapons Disabled")
	return PLUGIN_HANDLED
}

public fw_Weapon_PrimaryAttack_Post(Ent)
{
	if(!get_pcvar_num(cvar_enabled))
		return HAM_IGNORED
	if(!pev_valid(Ent))
		return HAM_IGNORED

	// Get owner of this weapon
	new owner = get_pdata_cbase(Ent, 41, 4)
	if(!is_user_alive(owner))
		return HAM_IGNORED
	if(!g_HasDualWeapon[owner])
		return HAM_IGNORED

	// Get weapon ID
	new weapon_id = cs_get_weapon_id(Ent)

	// If firing AK47, also fire M4A1
	if(weapon_id == CSW_AK47)
	{
		new Float:time = get_gametime()
		if(time - g_LastFireTime[owner] > 0.05) // Small delay to prevent double-firing in same frame
		{
			g_LastFireTime[owner] = time
			new m4 = fm_get_user_weapon_entity(owner, CSW_M4A1)
			if(pev_valid(m4))
			{
				// Fire the M4A1 as well
				new Float:next_attack = get_pdata_float(m4, 46, 4)
				new Float:time_idle = get_pdata_float(m4, 47, 4)
				new Float:time_fire = get_pdata_float(m4, 48, 4)

				// Force the M4A1 to be ready to fire
				set_pdata_float(m4, 46, 0.0, 4) // m_flNextPrimaryAttack
				set_pdata_float(m4, 47, 0.0, 4) // m_flTimeWeaponIdle
				set_pdata_float(m4, 48, 0.0, 4) // m_flNextAttack

				// Execute the attack
				ExecuteHam(Ham_Weapon_PrimaryAttack, m4)

				// Restore timing
				set_pdata_float(m4, 46, next_attack, 4)
				set_pdata_float(m4, 47, time_idle, 4)
				set_pdata_float(m4, 48, time_fire, 4)
			}
		}
	}
	// If firing M4A1, also fire AK47
	else if(weapon_id == CSW_M4A1)
	{
		new Float:time = get_gametime()
		if(time - g_LastFireTime[owner] > 0.05)
		{
			g_LastFireTime[owner] = time
			new ak = fm_get_user_weapon_entity(owner, CSW_AK47)
			if(pev_valid(ak))
			{
				// Fire the AK47 as well
				new Float:next_attack = get_pdata_float(ak, 46, 4)
				new Float:time_idle = get_pdata_float(ak, 47, 4)
				new Float:time_fire = get_pdata_float(ak, 48, 4)

				// Force the AK47 to be ready to fire
				set_pdata_float(ak, 46, 0.0, 4)
				set_pdata_float(ak, 47, 0.0, 4)
				set_pdata_float(ak, 48, 0.0, 4)

				// Execute the attack
				ExecuteHam(Ham_Weapon_PrimaryAttack, ak)

				// Restore timing
				set_pdata_float(ak, 46, next_attack, 4)
				set_pdata_float(ak, 47, time_idle, 4)
				set_pdata_float(ak, 48, time_fire, 4)
			}
		}
	}

	return HAM_IGNORED
}

public client_disconnect(id)
{
	g_HasDualWeapon[id] = false
	g_IsFiring[id] = false
}
