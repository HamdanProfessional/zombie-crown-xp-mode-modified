#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <fun>
#include <cstrike>

#define PLUGIN "[ZC] Dual Weapons"
#define VERSION "1.3"
#define AUTHOR "Zombie Crown Team"

new cvar_enabled
new bool:g_HasDualWeapon[33]
new Float:g_LastShot[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	cvar_enabled = register_cvar("zc_dual_weapons", "1")
	register_clcmd("say /dual", "Command_BuyDual")
	register_clcmd("say /dualoff", "Command_RemoveDual")

	// Use CmdStart instead of PreThink - more stable
	register_forward(FM_CmdStart, "fw_CmdStart")
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

	// Set max ammo for both
	new weapons[32], num
	get_user_weapons(id, weapons, num)

	for(new i = 0; i < num; i++)
	{
		new weapon = weapons[i]
		if(weapon == CSW_AK47)
		{
			new ent = fm_get_user_weapon_entity(id, CSW_AK47)
			if(pev_valid(ent))
			{
				cs_set_weapon_ammo(ent, 90)
			}
			cs_set_user_bpammo(id, CSW_AK47, 900)
		}
		else if(weapon == CSW_M4A1)
		{
			new ent = fm_get_user_weapon_entity(id, CSW_M4A1)
			if(pev_valid(ent))
			{
				cs_set_weapon_ammo(ent, 90)
			}
			cs_set_user_bpammo(id, CSW_M4A1, 900)
		}
	}

	g_HasDualWeapon[id] = true
	g_LastShot[id] = 0.0

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

public fw_CmdStart(id, uc_handle)
{
	if(!get_pcvar_num(cvar_enabled))
		return FMRES_IGNORED
	if(!is_user_alive(id))
		return FMRES_IGNORED
	if(!g_HasDualWeapon[id])
		return FMRES_IGNORED

	// Get current buttons
	new buttons = get_uc(uc_handle, UC_Buttons)

	// Check if player is pressing attack
	if(buttons & IN_ATTACK)
	{
		new Float:time = get_gametime()

		// Fire rate limit (same as normal fire rate)
		if(time - g_LastShot[id] >= 0.1)
		{
			g_LastShot[id] = time

			// Get current weapon
			new weapon = get_user_weapon(id)

			// Fire both weapons
			if(weapon == CSW_AK47)
			{
				// Fire AK47 (already firing from button press)
				// Also fire M4A1
				new m4 = fm_get_user_weapon_entity(id, CSW_M4A1)
				if(pev_valid(m4))
				{
					// Reset fire delay
					set_pdata_float(m4, 46, 0.0, 4)
					set_pdata_float(m4, 47, 0.0, 4)

					// Fire
					ExecuteHam(Ham_Weapon_PrimaryAttack, m4)
				}
			}
			else if(weapon == CSW_M4A1)
			{
				// Fire M4A1 (already firing from button press)
				// Also fire AK47
				new ak = fm_get_user_weapon_entity(id, CSW_AK47)
				if(pev_valid(ak))
				{
					// Reset fire delay
					set_pdata_float(ak, 46, 0.0, 4)
					set_pdata_float(ak, 47, 0.0, 4)

					// Fire
					ExecuteHam(Ham_Weapon_PrimaryAttack, ak)
				}
			}
		}
	}

	return FMRES_IGNORED
}

public client_disconnect(id)
{
	g_HasDualWeapon[id] = false
	g_LastShot[id] = 0.0
}
