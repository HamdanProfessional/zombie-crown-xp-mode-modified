#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <xs>

#define PLUGIN "[ZC] No Spread"
#define VERSION "1.3"
#define AUTHOR "Zombie Crown Team"

new cvar_enabled
new g_MaxPlayers

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	cvar_enabled = register_cvar("zc_nospread_enabled", "1")

	g_MaxPlayers = get_maxplayers()

	// Register PRE-hook for all custom weapons
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

	// Hook TraceAttack to correct bullet direction for all entities
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack_Post", 1)
	RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack_Post", 1)
	RegisterHam(Ham_TraceAttack, "func_wall", "fw_TraceAttack_Post", 1)
	RegisterHam(Ham_TraceAttack, "func_breakable", "fw_TraceAttack_Post", 1)
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

public fw_TraceAttack_Post(Victim, Attacker, Float:Damage, Float:Direction[3], Tr, DamageBits)
{
	if(!get_pcvar_num(cvar_enabled))
		return HAM_IGNORED
	if(!is_user_connected(Attacker))
		return HAM_IGNORED

	new weapon = get_user_weapon(Attacker)

	// Skip non-guns
	if(weapon == CSW_KNIFE || weapon == CSW_HEGRENADE || weapon == CSW_FLASHBANG || weapon == CSW_SMOKEGRENADE || weapon == CSW_C4)
		return HAM_IGNORED

	// Get the exact aim position
	new Float:Start[3], Float:ViewOfs[3], Float:End[3], Float:ViewAngle[3], Float:Forward[3]

	pev(Attacker, pev_origin, Start)
	pev(Attacker, pev_view_ofs, ViewOfs)
	xs_vec_add(Start, ViewOfs, Start)

	pev(Attacker, pev_v_angle, ViewAngle)
	engfunc(EngFunc_MakeVectors, ViewAngle)
	global_get(glb_v_forward, Forward)
	xs_vec_mul_scalar(Forward, 8192.0, Forward)
	xs_vec_add(Start, Forward, End)

	// Correct the trace direction
	SetHamParamVector(3, End)

	return HAM_HANDLED
}
