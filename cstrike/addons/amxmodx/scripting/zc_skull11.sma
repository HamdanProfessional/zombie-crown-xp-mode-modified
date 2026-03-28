#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <cstrike>
#include <fun>
#include <xs>
#include <zombiecrown>

#define PLUGIN "[ZC] Skull-11"
#define VERSION "1.0"
#define AUTHOR "Zombie Crown Team"

#define CSW_SKULL11 CSW_M4A1
#define weapon_skull11 "weapon_m4a1"

#define WEAPON_EVENT "events/m4a1.sc"
#define WEAPON_ANIM_EXT "carbine"

#define DAMAGE_NORMAL 45 // Base damage
#define DAMAGE_HEADSHOT 120 // Headshot damage
#define DAMAGE_EXPLOSION 50 // Explosion damage
#define RANGE_EXPLOSION 100.0 // Explosion radius

#define V_MODEL "models/v_skull11.mdl"
#define P_MODEL "models/p_skull11.mdl"
#define W_MODEL "models/w_skull11.mdl"

#define V_MODEL_FALLBACK "models/v_m4a1.mdl"
#define P_MODEL_FALLBACK "models/p_m4a1.mdl"
#define W_MODEL_FALLBACK "models/w_m4a1.mdl"

new const WeaponSounds[6][] =
{
	"weapons/skull11-1.wav",
	"weapons/skull11_exp.wav",
	"weapons/skull11_draw.wav",
	"weapons/skull11_clipin.wav",
	"weapons/skull11_clipout.wav",
	"weapons/skull11_idle.wav"
}

new const Skull_ExplosionSpr[] = "sprites/skull3_ammo.spr"

enum
{
	ANIM_IDLE = 0,
	ANIM_RELOAD,
	ANIM_DRAW,
	ANIM_SHOOT1,
	ANIM_SHOOT2,
	ANIM_SHOOT3
}

new g_Had_Skull11, g_ExplosionSpr, g_MaxPlayers
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
	register_forward(FM_TraceLine, "fw_TraceLine_Post", 1)

	RegisterHam(Ham_Item_Deploy, weapon_skull11, "fw_Item_Deploy_Post", 1)
	RegisterHam(Ham_Item_AddToPlayer, weapon_skull11, "fw_Item_AddToPlayer_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_skull11, "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_Reload, weapon_skull11, "fw_Weapon_Reload")
	RegisterHam(Ham_Weapon_WeaponIdle, weapon_skull11, "fw_Weapon_WeaponIdle_Post", 1)

	g_MaxPlayers = get_maxplayers()
	g_MsgCurWeapon = get_user_msgid("CurWeapon")
	g_MsgWeaponList = get_user_msgid("WeaponList")

	g_itemid = zp_register_extra_item("Skull-11", 15, ZP_TEAM_HUMAN, REST_NONE, 2)
}

public zp_extra_item_selected(player, itemid)
{
	if (itemid == g_itemid)
	{
		Get_Skull11(player)
	}
	return PLUGIN_HANDLED
}

public plugin_precache()
{
	// Check if custom models exist, use fallbacks if not
	if(file_exists(V_MODEL))
	{
		copy(g_VModel, charsmax(g_VModel), V_MODEL)
		engfunc(EngFunc_PrecacheModel, V_MODEL)
		log_amx("[ZC Skull-11] Using custom model: %s", V_MODEL)
	}
	else
	{
		copy(g_VModel, charsmax(g_VModel), V_MODEL_FALLBACK)
		engfunc(EngFunc_PrecacheModel, V_MODEL_FALLBACK)
		log_amx("[ZC Skull-11] Custom model not found, using fallback: %s", V_MODEL_FALLBACK)
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

	g_ExplosionSpr = engfunc(EngFunc_PrecacheModel, Skull_ExplosionSpr)
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
		UnSet_BitVar(g_Had_Skull11, id)
		g_Recoil[id] = 0.0
	}
}

public Get_Skull11(id)
{
	Set_BitVar(g_Had_Skull11, id)
	give_item(id, weapon_skull11)

	// Clip & Ammo
	static Ent; Ent = fm_get_user_weapon_entity(id, CSW_SKULL11)
	if(!pev_valid(Ent)) return

	cs_set_weapon_ammo(Ent, 90)
	cs_set_user_bpammo(id, CSW_SKULL11, 90)

	message_begin(MSG_ONE_UNRELIABLE, g_MsgCurWeapon, _, id)
	write_byte(1)
	write_byte(CSW_SKULL11)
	write_byte(90)
	message_end()
}

public Event_CurWeapon(id)
{
	if(!is_player(id, 1))
		return

	new CSWID = read_data(2)
	if(CSWID == CSW_SKULL11 && Get_BitVar(g_Had_Skull11, id))
	{
		if(g_OldWeapon[id] != CSW_SKULL11)
		{
			g_OldWeapon[id] = CSW_SKULL11
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

	if(get_user_weapon(id) == CSW_SKULL11 && Get_BitVar(g_Had_Skull11, id))
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

public fw_TraceLine_Post(Float:Origin1[3], Float:Origin2[3], NoMonsters, id, ptr)
{
	if(!is_player(id, 1))
		return FMRES_IGNORED

	if(get_user_weapon(id) != CSW_SKULL11 || !Get_BitVar(g_Had_Skull11, id))
		return FMRES_IGNORED

	new Victim = get_tr2(ptr, TR_pHit)

	if(!is_user_alive(Victim))
		return FMRES_IGNORED

	if(get_user_team(Victim) == get_user_team(id))
		return FMRES_IGNORED

	static HitGroup; HitGroup = get_tr2(ptr, TR_iHitgroup)

	if(HitGroup == HIT_HEAD)
	{
		set_tr2(ptr, TR_iHitgroup, HIT_GENERIC)
		return FMRES_SUPERCEDE
	}

	return FMRES_IGNORED
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

	if(Get_BitVar(g_Had_Skull11, id))
	{
		static Weapon
		Weapon = find_ent_by_owner(-1, weapon_skull11, ent)

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

	if(Get_BitVar(g_Had_Skull11, id))
	{
		set_pev(id, pev_viewmodel2, g_VModel)
		set_pev(id, pev_weaponmodel2, g_PModel)

		set_pdata_string(id, (492 * 4), WEAPON_ANIM_EXT, -1, 20)

		// Set WeaponList
		message_begin(MSG_ONE, g_MsgWeaponList, _, id)
		write_string("weapon_skull11")
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

	if(pev(Ent, pev_impulse) == 68416)
	{
		Set_BitVar(g_Had_Skull11, id)
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

	if(!Get_BitVar(g_Had_Skull11, id))
		return HAM_IGNORED

	// Check for headshot
	static Float:Origin[3], Float:TargetOrigin[3]
	get_position(id, 0.0, 0.0, 0.0, Origin)
	fm_get_aim_origin(id, TargetOrigin)

	static Victim; Victim = fm_get_aim_target(id)
	static IsHeadshot; IsHeadshot = false

	if(is_user_alive(Victim))
	{
		static HitGroup
		get_user_aiming(id, Victim, HitGroup)

		if(HitGroup == HIT_HEAD)
		{
			IsHeadshot = true
			ExecuteHamB(Ham_TakeDamage, Victim, 0, id, DAMAGE_HEADSHOT, DMG_BULLET)
			Create_Explosion(TargetOrigin, id, 1)
		}
		else
		{
			ExecuteHam(Ham_Weapon_PrimaryAttack, Ent)
			ExecuteHamB(Ham_TakeDamage, Victim, 0, id, DAMAGE_NORMAL, DMG_BULLET)
		}
	}
	else
	{
		ExecuteHam(Ham_Weapon_PrimaryAttack, Ent)
	}

	// Set next attack
	set_pdata_float(Ent, 46, 0.09, 4)
	set_pdata_float(Ent, 47, 0.09, 4)
	set_pdata_float(id, 83, 0.09, 5)

	// Animation
	new Random = random_num(ANIM_SHOOT1, ANIM_SHOOT3)
	UTIL_PlayWeaponAnimation(id, Random)

	// Recoil
	g_Recoil[id] = 1.2
	if(IsHeadshot)
	{
		g_Recoil[id] = 2.0
		// Screen shake for headshot
		shake_screen(id, 5, 1 << 14)
	}

	return HAM_SUPERCEDE
}

public fw_Weapon_Reload(Ent)
{
	if(!pev_valid(Ent))
		return HAM_IGNORED

	static id; id = get_pdata_cbase(Ent, 41, 4)

	if(!is_player(id, 1))
		return HAM_IGNORED

	if(!Get_BitVar(g_Had_Skull11, id))
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

	if(Get_BitVar(g_Had_Skull11, id))
	{
		static Float:flTime; flTime = get_pdata_float(Ent, 48, 4)

		if(flTime > 0.0)
		{
			set_pdata_float(Ent, 48, 0.0, 4)
			UTIL_PlayWeaponAnimation(id, ANIM_IDLE)
		}
	}
}

stock Create_Explosion(Float:Origin[3], id, Headshot)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, Origin[0])
	engfunc(EngFunc_WriteCoord, Origin[1])
	engfunc(EngFunc_WriteCoord, Origin[2])
	write_short(g_ExplosionSpr)
	write_byte(Headshot ? 15 : 10)
	write_byte(Headshot ? 40 : 30)
	write_byte(14)
	message_end()

	if(!Headshot)
		return

	// Damage in radius for headshot explosion
	static Victim; Victim = -1
	while((Victim = find_ent_in_sphere(Victim, Origin, RANGE_EXPLOSION)) != 0)
	{
		if(!is_user_alive(Victim))
			continue
		if(Victim == id)
			continue
		if(get_user_team(Victim) == get_user_team(id))
			continue

		ExecuteHamB(Ham_TakeDamage, Victim, 0, id, DAMAGE_EXPLOSION, DMG_BULLET)
	}
}

stock fm_get_aim_target(id)
{
	static Float:Start[3], Float:ViewOfs[3], Float:End[3], Float:ViewAngle[3], Float:Forward[3]

	pev(id, pev_origin, Start)
	pev(id, pev_view_ofs, ViewOfs)
	xs_vec_add(Start, ViewOfs, Start)

	pev(id, pev_v_angle, ViewAngle)
	engfunc(EngFunc_MakeVectors, ViewAngle)

	global_get(glb_v_forward, Forward)
	xs_vec_mul_scalar(Forward, 8192.0, Forward)
	xs_vec_add(Start, Forward, End)

	static Tr; Tr = create_tr2()
	engfunc(EngFunc_TraceLine, Start, End, 0, id, Tr)

	static Hit; Hit = get_tr2(Tr, TR_pHit)
	free_tr2(Tr)

	return Hit
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

stock shake_screen(id, amplitude, duration)
{
	message_begin(MSG_ONE, get_user_msgid("ScreenShake"), _, id)
	write_short(amplitude << 14) // amount
	write_short(duration) // duration
	write_short(1 << 14) // frequency
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
