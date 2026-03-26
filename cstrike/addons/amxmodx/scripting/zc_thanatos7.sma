#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <cstrike>
#include <fun>
#include <xs>
#include <zombiecrown>

#define PLUGIN "[ZC] Thanatos-7"
#define VERSION "1.0"
#define AUTHOR "Zombie Crown Team"

#define CSW_THANATOS7 CSW_M4A1
#define weapon_thanatos7 "weapon_m4a1"

#define WEAPON_EVENT "events/m4a1.sc"
#define WEAPON_ANIM_EXT "carbine"

#define DAMAGE_NORMAL 40 // Normal damage
#define DAMAGE_CHARGED 150 // Charged shot damage
#define CHARGE_TIME 2.0 // Time to fully charge (seconds)
#define RANGE_PENETRATION 300.0 // Penetration range

#define V_MODEL "models/v_thanatos7.mdl"
#define P_MODEL "models/p_thanatos7.mdl"
#define W_MODEL "models/w_thanatos7.mdl"

new const WeaponSounds[8][] =
{
	"weapons/thanatos7-1.wav",
	"weapons/thanatos7_chargeshot.wav",
	"weapons/thanatos7_charge_start.wav",
	"weapons/thanatos7_charge_loop.wav",
	"weapons/thanatos7_draw.wav",
	"weapons/thanatos7_clipin.wav",
	"weapons/thanatos7_clipout.wav",
	"weapons/thanatos7_idle.wav"
}

new const Thanatos_BeamSpr[] = "sprites/xenobeam.spr"
new const Thanatos_RailSpr[] = "sprites/laserbeam.spr"

enum
{
	ANIM_IDLE = 0,
	ANIM_RELOAD,
	ANIM_DRAW,
	ANIM_SHOOT,
	ANIM_SHOOT_CHARGED,
	ANIM_CHARGE_START,
	ANIM_CHARGE_LOOP
}

new g_Had_Thanatos7, g_BeamSpr, g_RailSpr, g_MaxPlayers
new g_itemid
new g_MsgCurWeapon, g_MsgWeaponList
new g_Charging[33]
new Float:g_ChargeStartTime[33]

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
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")

	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_CmdStart, "fw_CmdStart")

	RegisterHam(Ham_Item_Deploy, weapon_thanatos7, "fw_Item_Deploy_Post", 1)
	RegisterHam(Ham_Item_AddToPlayer, weapon_thanatos7, "fw_Item_AddToPlayer_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_thanatos7, "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_Reload, weapon_thanatos7, "fw_Weapon_Reload")
	RegisterHam(Ham_Weapon_WeaponIdle, weapon_thanatos7, "fw_Weapon_WeaponIdle_Post", 1)

	g_MaxPlayers = get_maxplayers()
	g_MsgCurWeapon = get_user_msgid("CurWeapon")
	g_MsgWeaponList = get_user_msgid("WeaponList")

	g_itemid = zp_register_extra_item("Thanatos-7", 18, ZP_TEAM_HUMAN, REST_NONE, 2)
}

public zp_extra_item_selected(player, itemid)
{
	if (itemid == g_itemid)
	{
		Get_Thanatos7(player)
	}
	return PLUGIN_CONTINUE
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel, V_MODEL)
	engfunc(EngFunc_PrecacheModel, P_MODEL)
	engfunc(EngFunc_PrecacheModel, W_MODEL)

	for(new i = 0; i < sizeof(WeaponSounds); i++)
		engfunc(EngFunc_PrecacheSound, WeaponSounds[i])

	g_BeamSpr = engfunc(EngFunc_PrecacheModel, Thanatos_BeamSpr)
	g_RailSpr = engfunc(EngFunc_PrecacheModel, Thanatos_RailSpr)
}

public client_putinserver(id)
{
	Safety_Connected(id)
	g_Charging[id] = 0
	g_ChargeStartTime[id] = 0.0
}

public client_disconnect(id)
{
	Safety_Disconnected(id)

	if(Get_BitVar(g_IsConnected, id))
	{
		UnSet_BitVar(g_Had_Thanatos7, id)
		g_Recoil[id] = 0.0
		g_Charging[id] = 0
		g_ChargeStartTime[id] = 0.0
	}
}

public Event_NewRound()
{
	for(new i = 0; i < g_MaxPlayers; i++)
	{
		g_Charging[i] = 0
		g_ChargeStartTime[i] = 0.0
	}
}

public Get_Thanatos7(id)
{
	if(!Get_BitVar(g_IsAlive, id))
		return

	Set_BitVar(g_Had_Thanatos7, id)
	give_item(id, weapon_thanatos7)

	new Ent = get_pdata_cbase(id, 373, 5)
	if(pev_valid(Ent))
	{
		set_pdata_int(Ent, 51, 90, 4)
		set_pdata_int(Ent, 52, 90, 4)
	}

	// Update WeaponList
	message_begin(MSG_ONE, g_MsgWeaponList, _, id)
	write_string("weapon_thanatos7")
	write_byte(4) // PrimaryAmmoType
	write_byte(90) // MaxAmmo1
	write_byte(-1) // MaxAmmo2
	write_byte(-1) // Slot
	write_byte(0) // Position
	write_byte(4) // WeaponId
	write_byte(14) // Flags
	message_end()

	engclient_cmd(id, weapon_thanatos7)
	ExecuteHamB(Ham_Item_Deploy, get_pdata_cbase(id, 368, 5))
}

public Event_CurWeapon(id)
{
	if(!Get_BitVar(g_IsAlive, id))
		return

	new CSWID = read_data(2)
	if(CSWID == CSW_THANATOS7 && Get_BitVar(g_Had_Thanatos7, id))
	{
		if(g_OldWeapon[id] != CSW_THANATOS7)
		{
			g_OldWeapon[id] = CSW_THANATOS7
			set_pev(id, pev_viewmodel2, V_MODEL)
			set_pev(id, pev_weaponmodel2, P_MODEL)
		}
	} else {
		g_OldWeapon[id] = CSWID
	}
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(!Get_BitVar(g_IsAlive, id))
		return FMRES_IGNORED

	if(get_user_weapon(id) == CSW_THANATOS7 && Get_BitVar(g_Had_Thanatos7, id))
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

public fw_CmdStart(id, uc_handle, seed)
{
	if(!Get_BitVar(g_IsAlive, id))
		return

	if(get_user_weapon(id) != CSW_THANATOS7 || !Get_BitVar(g_Had_Thanatos7, id))
		return

	static Button, OldButton
	Button = get_uc(uc_handle, UC_Buttons)
	OldButton = pev(id, pev_oldbuttons)

	// Start charging when holding attack
	if((Button & IN_ATTACK) && !(OldButton & IN_ATTACK))
	{
		g_Charging[id] = 1
		g_ChargeStartTime[id] = get_gametime()
		emit_sound(id, CHAN_WEAPON, WeaponSounds[2], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		UTIL_PlayWeaponAnimation(id, ANIM_CHARGE_START)
		set_pdata_float(id, 83, CHARGE_TIME + 0.1, 5)
	}

	// Check if fully charged
	if(g_Charging[id] && (get_gametime() - g_ChargeStartTime[id]) >= CHARGE_TIME)
	{
		if((Button & IN_ATTACK) && !(OldButton & IN_ATTACK))
		{
			// Release charged shot
			Fire_ChargedShot(id)
			g_Charging[id] = 0
		}
	}
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

	if(Get_BitVar(g_Had_Thanatos7, id))
	{
		static Weapon
		Weapon = find_ent_by_owner(-1, weapon_thanatos7, ent)

		if(!pev_valid(Weapon))
			return FMRES_IGNORED

		engfunc(EngFunc_SetModel, ent, W_MODEL)
		return FMRES_SUPERCEDE
	}

	return FMRES_IGNORED
}

public fw_Item_Deploy_Post(Ent)
{
	if(!pev_valid(Ent))
		return

	static id; id = get_pdata_cbase(Ent, 41, 4)

	if(!Get_BitVar(g_IsAlive, id))
		return

	if(Get_BitVar(g_Had_Thanatos7, id))
	{
		set_pev(id, pev_viewmodel2, V_MODEL)
		set_pev(id, pev_weaponmodel2, P_MODEL)

		set_pdata_string(id, (492 * 4), WEAPON_ANIM_EXT, -1, 20)

		// Set WeaponList
		message_begin(MSG_ONE, g_MsgWeaponList, _, id)
		write_string("weapon_thanatos7")
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

		g_Charging[id] = 0
	}
}

public fw_Item_AddToPlayer_Post(Ent, id)
{
	if(!pev_valid(Ent))
		return

	if(!Get_BitVar(g_IsAlive, id))
		return

	if(pev(Ent, pev_impulse) == 68417)
	{
		Set_BitVar(g_Had_Thanatos7, id)
		set_pev(Ent, pev_impulse, 0)
	}
}

public fw_Weapon_PrimaryAttack(Ent)
{
	if(!pev_valid(Ent))
		return HAM_IGNORED

	static id; id = get_pdata_cbase(Ent, 41, 4)

	if(!Get_BitVar(g_IsAlive, id))
		return HAM_IGNORED

	if(!Get_BitVar(g_Had_Thanatos7, id))
		return HAM_IGNORED

	// Check if charged shot is ready
	if(g_Charging[id] && (get_gametime() - g_ChargeStartTime[id]) >= CHARGE_TIME)
		return HAM_SUPERCEDE // Will be handled by CmdStart

	// Normal shot
	ExecuteHam(Ham_Weapon_PrimaryAttack, Ent)

	// Create beam effect
	static Float:Origin[3], Float:TargetOrigin[3]
	get_position(id, 0.0, 0.0, 0.0, Origin)
	fm_get_aim_origin(id, TargetOrigin)

	Create_Beam(Origin, TargetOrigin, 0)

	// Set next attack
	set_pdata_float(Ent, 46, 0.11, 4)
	set_pdata_float(Ent, 47, 0.11, 4)
	set_pdata_float(id, 83, 0.11, 5)

	// Animation
	UTIL_PlayWeaponAnimation(id, ANIM_SHOOT)

	// Recoil
	g_Recoil[id] = 0.8

	return HAM_SUPERCEDE
}

public Fire_ChargedShot(id)
{
	static Float:Origin[3], Float:TargetOrigin[3]
	get_position(id, 0.0, 0.0, 0.0, Origin)
	fm_get_aim_origin(id, TargetOrigin)

	// Create powerful beam
	Create_Beam(Origin, TargetOrigin, 1)

	// Apply damage with penetration
	static Float:Direction[3]
	xs_vec_sub(TargetOrigin, Origin, Direction)
	xs_vec_normalize(Direction, Direction)
	xs_vec_mul_scalar(Direction, RANGE_PENETRATION, Direction)

	static EndOrigin[3]
	EndOrigin[0] = Origin[0] + Direction[0]
	EndOrigin[1] = Origin[1] + Direction[1]
	EndOrigin[2] = Origin[2] + Direction[2]

	static Victim; Victim = -1
	static Float:CheckOrigin[3]
	static Float:Damage, Float:Distance

	while((Victim = find_ent_in_sphere(Victim, Origin, RANGE_PENETRATION)) != 0)
	{
		if(!is_user_alive(Victim))
			continue
		if(Victim == id)
			continue
		if(get_user_team(Victim) == get_user_team(id))
			continue

		pev(Victim, pev_origin, CheckOrigin)

		// Check if in line of fire
		static Float:Fraction
		TraceLine(Origin, EndOrigin, Victim, Fraction)

		if(Fraction >= 1.0)
			continue

		// Calculate damage based on distance
		Distance = get_distance_f(Origin, CheckOrigin)
		Damage = DAMAGE_CHARGED * (1.0 - (Distance / RANGE_PENETRATION))

		if(Damage > 0)
			ExecuteHamB(Ham_TakeDamage, Victim, 0, id, floatround(Damage), DMG_BULLET)
	}

	// Sound and animation
	emit_sound(id, CHAN_WEAPON, WeaponSounds[1], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	UTIL_PlayWeaponAnimation(id, ANIM_SHOOT_CHARGED)

	g_Recoil[id] = 2.5
	shake_screen(id, 8, 1 << 14)
}

public fw_Weapon_Reload(Ent)
{
	if(!pev_valid(Ent))
		return HAM_IGNORED

	static id; id = get_pdata_cbase(Ent, 41, 4)

	if(!Get_BitVar(g_IsAlive, id))
		return HAM_IGNORED

	if(!Get_BitVar(g_Had_Thanatos7, id))
		return HAM_IGNORED

	g_Charging[id] = 0
	UTIL_PlayWeaponAnimation(id, ANIM_RELOAD)

	return HAM_SUPERCEDE
}

public fw_Weapon_WeaponIdle_Post(Ent)
{
	if(!pev_valid(Ent))
		return

	static id; id = get_pdata_cbase(Ent, 41, 4)

	if(!Get_BitVar(g_IsAlive, id))
		return

	if(Get_BitVar(g_Had_Thanatos7, id))
	{
		static Float:flTime; flTime = get_pdata_float(Ent, 48, 4)

		if(flTime > 0.0)
		{
			set_pdata_float(Ent, 48, 0.0, 4)
			if(g_Charging[id] && (get_gametime() - g_ChargeStartTime[id]) >= CHARGE_TIME)
			{
				UTIL_PlayWeaponAnimation(id, ANIM_CHARGE_LOOP)
			}
			else
			{
				UTIL_PlayWeaponAnimation(id, ANIM_IDLE)
			}
		}
	}
}

stock Create_Beam(Float:Start[3], Float:End[3], Charged)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMENTPOINT)
	write_short(Charged ? g_RailSpr : g_BeamSpr)
	engfunc(EngFunc_WriteCoord, Start[0])
	engfunc(EngFunc_WriteCoord, Start[1])
	engfunc(EngFunc_WriteCoord, Start[2])
	engfunc(EngFunc_WriteCoord, End[0])
	engfunc(EngFunc_WriteCoord, End[1])
	engfunc(EngFunc_WriteCoord, End[2])
	write_byte(0) // framerate
	write_byte(10) // framerate
	write_byte(Charged ? 255 : 100) // life
	write_byte(Charged ? 50 : 10) // width
	write_byte(Charged ? 255 : 100) // noise
	write_byte(Charged ? 255 : 0) // r
	write_byte(Charged ? 100 : 200) // g
	write_byte(Charged ? 0 : 255) // b
	write_byte(Charged ? 200 : 100) // brightness
	write_byte(0) // speed
	message_end()
}

stock TraceLine(Float:Start[3], Float:End[3], Ent, Float:Fraction)
{
	new Tr = create_tr2()
	engfunc(EngFunc_TraceLine, Start, End, DONT_IGNORE_MONSTERS, Ent, Tr)
	get_tr2(Tr, TR_flFraction, Fraction)
	free_tr2(Tr)
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
	if(!Get_BitVar(g_IsAlive, id))
		return

	new CSWID = read_data(2)
	if(g_PlayerWeapon[id] != CSWID)
	{
		g_PlayerWeapon[id] = CSWID
	}
}
