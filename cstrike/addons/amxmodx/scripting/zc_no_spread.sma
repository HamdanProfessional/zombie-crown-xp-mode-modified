#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <xs>

#define PLUGIN "[ZC] No Spread"
#define VERSION "1.0"
#define AUTHOR "Zombie Crown Team"

// Weapon accuracy offset (m_flAccuracy)
#define OFFSET_WEAPONACCURACY 62

new cvar_enabled

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	cvar_enabled = register_cvar("zc_nospread_enabled", "1")

	// Register primary attack for all weapons
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m4a1", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_awp", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_scout", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_g3sg1", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_sg550", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m249", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_aug", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_sg552", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_famas", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_galil", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_eli5", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_tmp", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_mac10", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_mp5navy", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ump45", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_p90", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_xm1014", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m3", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_deagle", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_usp", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_glock18", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_p228", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_fiveseven", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_elite", "fw_Weapon_PrimaryAttack_Post", 1)
}

public fw_Weapon_PrimaryAttack_Post(Ent)
{
	if(!get_pcvar_num(cvar_enabled))
		return HAM_IGNORED
	if(!pev_valid(Ent))
		return HAM_IGNORED

	// Reset weapon accuracy to 0 (no spread)
	set_pdata_float(Ent, OFFSET_WEAPONACCURACY, 0.0, 4)

	return HAM_HANDLED
}
