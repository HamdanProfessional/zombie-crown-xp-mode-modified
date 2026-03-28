#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "[ZC] No Spread"
#define VERSION "1.4"
#define AUTHOR "Zombie Crown Team"

new cvar_enabled

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	cvar_enabled = register_cvar("zc_nospread_enabled", "1")

	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m4a1", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_awp", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_scout", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_g3sg1", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_sg550", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m249", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_aug", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_sg552", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_famas", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_galil", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_tmp", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_mac10", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_mp5navy", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ump45", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_p90", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_xm1014", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m3", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_deagle", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_usp", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_glock18", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_p228", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_fiveseven", "fw_Weapon_PrimaryAttack_Pre", 0)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_elite", "fw_Weapon_PrimaryAttack_Pre", 0)
}

public fw_Weapon_PrimaryAttack_Pre(Ent)
{
	if(!get_pcvar_num(cvar_enabled))
		return HAM_IGNORED
	if(!pev_valid(Ent))
		return HAM_IGNORED

	set_pdata_float(Ent, 62, 0.0, 4)
	return HAM_IGNORED
}
