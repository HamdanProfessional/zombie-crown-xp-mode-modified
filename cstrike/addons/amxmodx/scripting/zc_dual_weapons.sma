#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <fun>
#include <cstrike>

#define PLUGIN "[ZC] Dual Weapons"
#define VERSION "1.0"
#define AUTHOR "Zombie Crown Team"

new cvar_enabled
new bool:g_HasDualWeapon[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	cvar_enabled = register_cvar("zc_dual_weapons", "1")
	register_clcmd("say /dual", "Command_BuyDual")
}

public Command_BuyDual(id)
{
	if(!get_pcvar_num(cvar_enabled))
		return
	if(!is_user_alive(id))
		return

	strip_user_weapons(id)
	give_item(id, "weapon_ak47")
	give_item(id, "weapon_m4a1")

	new ent1 = fm_get_user_weapon_entity(id, CSW_AK47)
	if(pev_valid(ent1))
	{
		set_pdata_int(ent1, 51, 30, 4)
		set_pdata_int(ent1, 52, 90, 4)
	}

	new ent2 = fm_get_user_weapon_entity(id, CSW_M4A1)
	if(pev_valid(ent2))
	{
		set_pdata_int(ent2, 51, 30, 4)
		set_pdata_int(ent2, 52, 90, 4)
	}

	g_HasDualWeapon[id] = true
	engclient_cmd(id, "weapon_ak47")

	client_print(id, print_chat, "[ZC] Dual Weapons! Both AK47 and M4A1 fire together.")
}

public client_PreThink(id)
{
	if(!get_pcvar_num(cvar_enabled))
		return
	if(!is_user_alive(id))
		return
	if(!g_HasDualWeapon[id])
		return

	new buttons = pev(id, pev_button)
	new old_buttons = pev(id, pev_oldbuttons)

	if((buttons & IN_ATTACK) && !(old_buttons & IN_ATTACK))
	{
		new ent2 = fm_get_user_weapon_entity(id, CSW_M4A1)
		if(pev_valid(ent2))
		{
			new Float:next_attack = get_pdata_float(ent2, 46, 4)
			new Float:time = get_gametime()

			if(time >= next_attack)
			{
				ExecuteHam(Ham_Weapon_PrimaryAttack, ent2)
			}
		}
	}
}
