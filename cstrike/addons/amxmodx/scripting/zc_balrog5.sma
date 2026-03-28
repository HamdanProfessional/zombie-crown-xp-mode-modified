#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <cstrike>
#include <fun>
#include <xs>
#include <zombiecrown>

#define PLUGIN "[ZC] Balrog-V"
#define VERSION "1.0"
#define AUTHOR "Zombie Crown Team"

#define CSW_BALROG5 CSW_GALIL
#define weapon_balrog5 "weapon_galil"

#define WEAPON_EVENT "events/galil.sc"
#define WEAPON_ANIM_EXT "carbine"

#define DAMAGE_B 60 // Base damage
#define DAMAGE_EXP 35 // Explosion damage
#define RANGE_EXP 120.0 // Explosion radius

#define V_MODEL "models/v_balrog5.mdl"
#define P_MODEL "models/p_balrog5.mdl"
#define W_MODEL "models/w_balrog5.mdl"

#define V_MODEL_FALLBACK "models/v_galil.mdl"
#define P_MODEL_FALLBACK "models/p_galil.mdl"
#define W_MODEL_FALLBACK "models/w_galil.mdl"

new const WeaponSounds[5][] =
{
	"weapons/balrog5-1.wav",
	"weapons/balrog5_exp.wav",
	"weapons/balrog5_draw.wav",
	"weapons/balrog5_clipin.wav",
	"weapons/balrog5_clipout.wav"
}

new const Balrog_ExplosionSpr[] = "sprites/balrogcritical.spr"

enum
{
	ANIM_IDLE = 0,
	ANIM_RELOAD,
	ANIM_DRAW,
	ANIM_SHOOT1,
	ANIM_SHOOT2,
	ANIM_SHOOT3
}

new g_Had_Balrog5, g_ExplosionSpr, g_MaxPlayers
new g_itemid
new g_MsgCurWeapon, g_MsgWeaponList
new g_VModel[64], g_PModel[64], g_WModel[64]

// Safety
#define Get_BitVar(%1,%2) (%1 & (1 << (%2 & 31)))
#define Set_BitVar(%1,%2) %1 |= (1 << (%2 & 31))
#define UnSet_BitVar(%1,%2) %1 &= ~(1 << (%2 & 31))

new g_IsConnected, g_IsAlive, g_PlayerWeapon[33]
new Float:g_Recoil[33]
new g_OldWeapon[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	Register_SafetyFunc()

	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")

	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")
	register_forward(FM_SetModel, "fw_SetModel")

	RegisterHam(Ham_Item_Deploy, weapon_balrog5, "fw_Item_Deploy_Post", 1)
	RegisterHam(Ham_Item_AddToPlayer, weapon_balrog5, "fw_Item_AddToPlayer_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_balrog5, "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_Reload, weapon_balrog5, "fw_Weapon_Reload")
	RegisterHam(Ham_Weapon_WeaponIdle, weapon_balrog5, "fw_Weapon_WeaponIdle_Post", 1)

	g_MaxPlayers = get_maxplayers()
	g_MsgCurWeapon = get_user_msgid("CurWeapon")
	g_MsgWeaponList = get_user_msgid("WeaponList")

	g_itemid = zp_register_extra_item("Balrog V", 12, ZP_TEAM_HUMAN, REST_NONE, 2)
}

public zp_extra_item_selected(player, itemid)
{
	if (itemid == g_itemid)
	{
		Get_Balrog5(player)
	}
	return PLUGIN_CONTINUE
}

public plugin_precache()
{
	// Check if custom models exist, use fallbacks if not
	if(file_exists(V_MODEL))
	{
		copy(g_VModel, charsmax(g_VModel), V_MODEL)
		engfunc(EngFunc_PrecacheModel, V_MODEL)
		log_amx("[ZC Balrog-V] Using custom model: %s", V_MODEL)
	}
	else
	{
		copy(g_VModel, charsmax(g_VModel), V_MODEL_FALLBACK)
		engfunc(EngFunc_PrecacheModel, V_MODEL_FALLBACK)
		log_amx("[ZC Balrog-V] Custom model not found, using fallback: %s", V_MODEL_FALLBACK)
	}

	if(file_exists(P_MODEL))
	{
		copy(g_PModel, charsmax(g_PModel), P_MODEL)
		engfunc(EngFunc_PrecacheModel, P_MODEL)
	}
	else
	{
		copy(g_PModel, charsmax(g_PModel), P_MODEL_FALLBACK)
		engfunc(EngFunc_PrecacheModel, P_MODEL_FALLBACK)
	}

	if(file_exists(W_MODEL))
	{
		copy(g_WModel, charsmax(g_WModel), W_MODEL)
		engfunc(EngFunc_PrecacheModel, W_MODEL)
	}
	else
	{
		copy(g_WModel, charsmax(g_WModel), W_MODEL_FALLBACK)
		engfunc(EngFunc_PrecacheModel, W_MODEL_FALLBACK)
	}

	for(new i = 0; i < sizeof(WeaponSounds); i++)
		engfunc(EngFunc_PrecacheSound, WeaponSounds[i])

	g_ExplosionSpr = engfunc(EngFunc_PrecacheModel, Balrog_ExplosionSpr)
}

public client_putinserver(id)
{
	Safety_Connected(id)
}

public client_disconnect(id)
{
	Safety_Disconnected(id)

	if(Get_BitVar(g_IsConnected, id))
	{
		UnSet_BitVar(g_Had_Balrog5, id)
		g_Recoil[id] = 0.0
	}
}

public Get_Balrog5(id)
{
	if(!is_player(id, 1))
		return

	Set_BitVar(g_Had_Balrog5, id)
	give_item(id, weapon_balrog5)

	new Ent = get_pdata_cbase(id, 373, 5)
	if(pev_valid(Ent))
	{
		set_pdata_int(Ent, 51, 90, 4)
		set_pdata_int(Ent, 52, 90, 4)
	}

	// Update WeaponList
	message_begin(MSG_ONE, g_MsgWeaponList, _, id)
	write_string("weapon_balrog5")
	write_byte(4) // PrimaryAmmoType
	write_byte(90) // MaxAmmo1
	write_byte(-1) // MaxAmmo2
	write_byte(-1) // Slot
	write_byte(0) // Position
	write_byte(4) // WeaponId
	write_byte(14) // Flags
	message_end()

	engclient_cmd(id, weapon_balrog5)
	ExecuteHamB(Ham_Item_Deploy, get_pdata_cbase(id, 368, 5))
}

public Event_CurWeapon(id)
{
	if(!is_player(id, 1))
		return

	new CSWID = read_data(2)
	if(CSWID == CSW_BALROG5 && Get_BitVar(g_Had_Balrog5, id))
	{
		if(g_OldWeapon[id] != CSW_BALROG5)
		{
			g_OldWeapon[id] = CSW_BALROG5
			set_pev(id, pev_viewmodel2, g_VModel)
			set_pev(id, pev_weaponmodel2, g_PModel)
		}
	} else {
		g_OldWeapon[id] = CSWID
	}
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(!is_player(id, 1))
		return FMRES_IGNORED

	if(get_user_weapon(id) == CSW_BALROG5 && Get_BitVar(g_Had_Balrog5, id))
		set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001)

	return FMRES_HANDLED
}

public fw_PlaybackEvent()
{
	if(!Get_BitVar(g_IsConnected, read_data(1)))
		return FMRES_IGNORED

	new Float:fVec[3]
	pev(read_data(1), pev_punchangle, fVec)

	fVec[0] *= g_Recoil[read_data(1)]
	fVec[1] *= g_Recoil[read_data(1)]
	fVec[2] *= g_Recoil[read_data(1)]

	set_pev(read_data(1), pev_punchangle, fVec)

	return FMRES_HANDLED
}

public fw_SetModel(ent)
{
	if(!pev_valid(ent))
		return FMRES_IGNORED

	static Classname[32]
	pev(ent, pev_classname, Classname, sizeof(Classname))

	if(!equal(Classname, "weaponbox"))
		return FMRES_IGNORED

	static id
	id = pev(ent, pev_owner)

	if(!Get_BitVar(g_IsConnected, id))
		return FMRES_IGNORED

	if(Get_BitVar(g_Had_Balrog5, id))
	{
		static Weapon
		Weapon = find_ent_by_owner(-1, weapon_balrog5, ent)

		if(!pev_valid(Weapon))
			return FMRES_IGNORED

		engfunc(EngFunc_SetModel, ent, g_WModel)
		return FMRES_SUPERCEDE
	}

	return FMRES_IGNORED
}

public fw_Item_Deploy_Post(Ent)
{
	if(!pev_valid(Ent))
		return

	static id; id = get_pdata_cbase(Ent, 41, 4)

	if(!is_player(id, 1))
		return

	if(Get_BitVar(g_Had_Balrog5, id))
	{
		set_pev(id, pev_viewmodel2, g_VModel)
		set_pev(id, pev_weaponmodel2, g_PModel)

		set_pdata_string(id, (492 * 4), WEAPON_ANIM_EXT, -1, 20)

		// Set WeaponList
		message_begin(MSG_ONE, g_MsgWeaponList, _, id)
		write_string("weapon_balrog5")
		write_byte(4)
		write_byte(90)
		write_byte(-1)
		write_byte(-1)
		write_byte(0)
		write_byte(4)
		write_byte(14)
		message_end()

		UTIL_PlayWeaponAnimation(id, ANIM_DRAW)
		set_pdata_float(Ent, 48, 1.0, 4)
		set_pdata_float(id, 83, 1.0, 5)
	}
}

public fw_Item_AddToPlayer_Post(Ent, id)
{
	if(!pev_valid(Ent))
		return

	if(!is_player(id, 1))
		return

	if(pev(Ent, pev_impulse) == 68415)
	{
		Set_BitVar(g_Had_Balrog5, id)
		set_pev(Ent, pev_impulse, 0)
	}
}

public fw_Weapon_PrimaryAttack(Ent)
{
	if(!pev_valid(Ent))
		return HAM_IGNORED

	static id; id = get_pdata_cbase(Ent, 41, 4)

	if(!is_player(id, 1))
		return HAM_IGNORED

	if(!Get_BitVar(g_Had_Balrog5, id))
		return HAM_IGNORED

	// Fire & Create Explosion
	ExecuteHam(Ham_Weapon_PrimaryAttack, Ent)

	static Float:Origin[3], Float:TargetOrigin[3]
	get_position(id, 0.0, 0.0, 0.0, Origin)
	fm_get_aim_origin(id, TargetOrigin)

	Create_Explosion(Origin, TargetOrigin, id)

	// Set next attack
	set_pdata_float(Ent, 46, 0.08, 4)
	set_pdata_float(Ent, 47, 0.08, 4)
	set_pdata_float(id, 83, 0.08, 5)

	// Animation
	new Random = random_num(ANIM_SHOOT1, ANIM_SHOOT3)
	UTIL_PlayWeaponAnimation(id, Random)

	// Recoil
	g_Recoil[id] = 1.5
	set_pdata_float(id, 83, 0.08, 5)

	return HAM_SUPERCEDE
}

public fw_Weapon_Reload(Ent)
{
	if(!pev_valid(Ent))
		return HAM_IGNORED

	static id; id = get_pdata_cbase(Ent, 41, 4)

	if(!is_player(id, 1))
		return HAM_IGNORED

	if(!Get_BitVar(g_Had_Balrog5, id))
		return HAM_IGNORED

	UTIL_PlayWeaponAnimation(id, ANIM_RELOAD)

	return HAM_SUPERCEDE
}

public fw_Weapon_WeaponIdle_Post(Ent)
{
	if(!pev_valid(Ent))
		return

	static id; id = get_pdata_cbase(Ent, 41, 4)

	if(!is_player(id, 1))
		return

	if(Get_BitVar(g_Had_Balrog5, id))
	{
		static Float:flTime; flTime = get_pdata_float(Ent, 48, 4)

		if(flTime > 0.0)
		{
			set_pdata_float(Ent, 48, 0.0, 4)
			UTIL_PlayWeaponAnimation(id, ANIM_IDLE)
		}
	}
}

stock Create_Explosion(Float:Origin[3], Float:TargetOrigin[3], id)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, TargetOrigin[0])
	engfunc(EngFunc_WriteCoord, TargetOrigin[1])
	engfunc(EngFunc_WriteCoord, TargetOrigin[2])
	write_short(g_ExplosionSpr)
	write_byte(10)
	write_byte(30)
	write_byte(14)
	message_end()

	// Damage in radius
	static Victim; Victim = -1
	while((Victim = find_ent_in_sphere(Victim, TargetOrigin, RANGE_EXP)) != 0)
	{
		if(!is_user_alive(Victim))
			continue
		if(Victim == id)
			continue
		if(get_user_team(Victim) == get_user_team(id))
			continue

		ExecuteHamB(Ham_TakeDamage, Victim, 0, id, DAMAGE_EXP, DMG_BULLET)
	}
}

stock get_position(id, Float:forw, Float:right, Float:up, Float:Output[3])
{
	static Float:OriginF[3], Float:Angle[3], Float:Forward[3], Float:Right[3], Float:Up[3]

	pev(id, pev_origin, OriginF)
	pev(id, pev_view_ofs, OriginF)
	pev(id, pev_v_angle, Angle)

	angle_vector(Angle, ANGLEVECTOR_FORWARD, Forward)
	angle_vector(Angle, ANGLEVECTOR_RIGHT, Right)
	angle_vector(Angle, ANGLEVECTOR_UP, Up)

	xs_vec_mul_scalar(Forward, forw, Forward)
	xs_vec_mul_scalar(Right, right, Right)
	xs_vec_mul_scalar(Up, up, Up)

	xs_vec_add(OriginF, Forward, Output)
	xs_vec_add(Output, Right, Output)
	xs_vec_add(Output, Up, Output)
}

stock UTIL_PlayWeaponAnimation(id, Animation)
{
	set_pev(id, pev_weaponanim, Animation)

	message_begin(MSG_ONE, SVC_WEAPONANIM, _, id)
	write_byte(Animation)
	write_byte(pev(id, pev_body))
	message_end()
}

/* Safety */
public Register_SafetyFunc()
{
	register_event("CurWeapon", "Safety_CurWeapon", "be", "1=1")
}

public Safety_Connected(id)
{
	Set_BitVar(g_IsConnected, id)
	UnSet_BitVar(g_IsAlive, id)
	g_PlayerWeapon[id] = 0
}

public Safety_Disconnected(id)
{
	UnSet_BitVar(g_IsConnected, id)
	UnSet_BitVar(g_IsAlive, id)
	g_PlayerWeapon[id] = 0
}

public Safety_CurWeapon(id)
{
	if(!is_player(id, 1))
		return

	new CSWID = read_data(2)
	if(g_PlayerWeapon[id] != CSWID)
	{
		g_PlayerWeapon[id] = CSWID
	}
}

public is_player(id, IsAliveCheck)
{
	if(!(1 <= id <= 32))
		return 0
	if(!Get_BitVar(g_IsConnected, id))
		return 0
	if(IsAliveCheck)
	{
		if(Get_BitVar(g_IsAlive, id)) return 1
		else return 0
	}

	return 1
}

public get_player_weapon(id)
{
	if(!is_player(id, 1))
		return 0

	return g_PlayerWeapon[id]
}
