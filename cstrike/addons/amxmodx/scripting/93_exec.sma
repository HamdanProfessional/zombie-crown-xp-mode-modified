#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombiecrown>

// Executioner Zombie
new const zclass_name[] = { "ExecZM" }
new const zclass_info[] = { "Faster Attack" }
new const zclass_model[] = { "zc_model_zm6" }
new const zclass_clawmodel[] = "v_knife_zm6.mdl" 
const zclass_health = 13000 // health
const zclass_speed = 500 // speed
const Float:zclass_gravity = 0.50 // gravity
const Float:zclass_knockback = 1.0
const zclass_level = 93

// weapon const
const OFFSET_WEAPONOWNER = 41
const OFFSET_LINUX_WEAPONS = 4
const m_flNextPrimaryAttack = 46
const m_flNextSecondaryAttack = 47

/*================================================================================
 [Global Variables]
=================================================================================*/

// Player vars
new g_bExecutioner[33] // is Executioner Zombie

// Game vars
new g_iExecutionerIndex // index from the class
new g_iMaxPlayers // max player counter

// Cvar Pointer
new cvar_Primary, cvar_PrimarySpeed, cvar_Secondary, cvar_SecondarySpeed, cvar_Nemesis

public plugin_precache()
{
	new registerText[32]
	formatex(registerText, sizeof registerText - 1, "[ZC %s]", zclass_name)
	register_plugin(registerText, "1.0", "meNe")
	g_iExecutionerIndex = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_level)
}

public plugin_init()
{
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_event("DeathMsg", "event_player_death", "a")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "fwd_Knife_PriAtk_Post", 1)
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "fwd_Knife_SecAtk_Post", 1)
	cvar_Primary = register_cvar("zp_executioner_pri", "1")
	cvar_PrimarySpeed = register_cvar("zp_executioner_pri_speed", "0.33")
	cvar_Secondary = register_cvar("zp_executioner_sec", "1")
	cvar_SecondarySpeed = register_cvar("zp_executioner_sec_speed", "0.33")
	cvar_Nemesis = register_cvar("zp_executioner_nemesis", "0")	
	g_iMaxPlayers = get_maxplayers()
}

public client_putinserver(id)
{
	g_bExecutioner[id] = false
}

public client_disconnected(id) 
{
	g_bExecutioner[id] = false
}

/*================================================================================
 [Main Forwards]
=================================================================================*/

public event_round_start()
{
	for (new id = 1; id <= g_iMaxPlayers; id++)
		g_bExecutioner[id] = false
}

public event_player_death()
{
	g_bExecutioner[read_data(2)] = false
}

public fwd_Knife_PriAtk_Post(ent)
{
	if (!get_pcvar_num(cvar_Primary))
		return HAM_IGNORED;
	
	static owner
	owner = ham_cs_get_weapon_ent_owner(ent)
	
	if (!g_bExecutioner[owner])
		return HAM_IGNORED
	
	static Float:Speed, Float:Primary, Float:Secondary
	Speed = get_pcvar_float(cvar_PrimarySpeed)
	Primary = get_pdata_float(ent, m_flNextPrimaryAttack, OFFSET_LINUX_WEAPONS) * Speed
	Secondary = get_pdata_float(ent, m_flNextSecondaryAttack, OFFSET_LINUX_WEAPONS) * Speed
	
	if (Primary > 0.0 && Secondary > 0.0)
	{
		set_pdata_float(ent, m_flNextPrimaryAttack, Primary, OFFSET_LINUX_WEAPONS)
		set_pdata_float(ent, m_flNextSecondaryAttack, Secondary, OFFSET_LINUX_WEAPONS)
	}
	
	return HAM_IGNORED;
}

public fwd_Knife_SecAtk_Post(ent)
{
	if (!get_pcvar_num(cvar_Secondary))
		return HAM_IGNORED;
	
	static owner
	owner = ham_cs_get_weapon_ent_owner(ent)
	
	if (!g_bExecutioner[owner])
		return HAM_IGNORED
	
	static Float:Speed, Float:Primary, Float:Secondary
	Speed = get_pcvar_float(cvar_SecondarySpeed)
	Primary = get_pdata_float(ent, m_flNextPrimaryAttack, OFFSET_LINUX_WEAPONS) * Speed
	Secondary = get_pdata_float(ent, m_flNextSecondaryAttack, OFFSET_LINUX_WEAPONS) * Speed
	
	if (Primary > 0.0 && Secondary > 0.0)
	{
		set_pdata_float(ent, m_flNextPrimaryAttack, Primary, OFFSET_LINUX_WEAPONS)
		set_pdata_float(ent, m_flNextSecondaryAttack, Secondary, OFFSET_LINUX_WEAPONS)
	}
	
	return HAM_IGNORED;
}

public zp_user_infected_post(id, infector, nemesis)
{
	if (nemesis && !get_pcvar_num(cvar_Nemesis)) return
	
	if (zp_get_user_zombie_class(id) == g_iExecutionerIndex)
		g_bExecutioner[id] = true
}

public zp_user_humanized_post(id) g_bExecutioner[id] = false

/*================================================================================
 [Stocks]
=================================================================================*/

stock ham_cs_get_weapon_ent_owner(entity)
{
	return get_pdata_cbase(entity, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS);
}
