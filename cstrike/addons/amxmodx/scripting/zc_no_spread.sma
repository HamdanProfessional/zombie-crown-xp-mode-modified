#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>

#define PLUGIN "[ZC] No Spread"
#define VERSION "1.1"
#define AUTHOR "Zombie Crown Team"

new cvar_enabled

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	cvar_enabled = register_cvar("zc_nospread_enabled", "1")

	// Register PRE-hook for primary attack
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47", "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m4a1", "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_awp", "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_scout", "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_g3sg1", "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_sg550", "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m249", "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_aug", "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_sg552", "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_famas", "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_galil", "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_tmp", "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_mac10", "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_mp5navy", "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ump45", "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_p90", "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_xm1014", "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m3", "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_deagle", "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_usp", "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_glock18", "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_p228", "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_fiveseven", "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_elite", "fw_Weapon_PrimaryAttack")

	// Hook TraceLine to correct bullet path
	register_forward(FM_TraceLine, "fw_TraceLine_Post", 1)
}

public fw_Weapon_PrimaryAttack(Ent)
{
	if(!get_pcvar_num(cvar_enabled))
		return HAM_IGNORED
	if(!pev_valid(Ent))
		return HAM_IGNORED

	// Set accuracy to 0 BEFORE the shot
	set_pdata_float(Ent, 62, 0.0, 4)

	return HAM_HANDLED
}

public fw_TraceLine_Post(Float:start[3], Float:end[3], noMonsters, id, tr)
{
	if(!get_pcvar_num(cvar_enabled))
		return FMRES_IGNORED
	if(!is_user_alive(id))
		return FMRES_IGNORED

	new weapon = get_user_weapon(id)

	// Skip non-guns
	if(weapon == CSW_KNIFE || weapon == CSW_HEGRENADE || weapon == CSW_FLASHBANG || weapon == CSW_SMOKEGRENADE || weapon == CSW_C4)
		return FMRES_IGNORED

	// Get the actual aim position
	new Float:aim_origin[3]
	fm_get_aim_origin(id, aim_origin)

	// Override trace to go exactly where aimed
	set_tr2(tr, TR_vecEndPos, aim_origin)
	set_tr2(tr, TR_flFraction, 1.0)

	return FMRES_SUPERCEDE
}
