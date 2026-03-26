#include <amxmodx>
#include <hamsandwich>
#include <zombiecrown>

const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<
CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
native get_weapon_m16(id)
native get_weapon_blaster(id)

public plugin_init()
{
	register_plugin("[ZC Reset Weapons]", "1.0", "meNe")
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1)
}

public fw_PlayerSpawn_Post(id)
{
	if(is_user_alive(id) && !zp_get_user_zombie(id) && !zp_is_hero_round() && !get_weapon_m16(id) && !get_weapon_blaster(id)) 
	{
		drop_weapons(id, 1)
	}
}

stock drop_weapons(id, dropwhat)
{
	static weapons[32], num, i, weaponid
	num = 0
	get_user_weapons(id, weapons, num)
     
	for (i = 0; i < num; i++)
	{
		weaponid = weapons[i]
          
		if (dropwhat == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM))
		{
			static wname[32]
			get_weaponname(weaponid, wname, sizeof wname - 1)
			engclient_cmd(id, "drop", wname)
		}
	}
}