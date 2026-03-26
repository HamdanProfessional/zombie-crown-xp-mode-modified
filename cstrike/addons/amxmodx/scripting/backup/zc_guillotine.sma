#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <cstrike>
#include <xs>
#include <fun>
#include <zombiecrown>

#define PLUGIN "[ZC Guillotine]"
#define VERSION "1.0"
#define AUTHOR "Dias"

#define DAMAGE 200
#define AMMO 10

#define MAX_RADIUS 700.0
#define FLYING_SPEED 1000.0
#define KNOCKBACK 1500.0
#define DAMAGE_DELAY 0.2
#define GUILLOTINE_HITTIME 4.0
#define is_valid_connected(%1) (1 <= %1 <= g_MaxPlayers && is_user_connected(%1))
#define is_valid_alive(%1) (1 <= %1 <= g_MaxPlayers && is_user_alive(%1))

#define MODEL_V "models/zombie_crown/v_guillotine.mdl"
#define MODEL_P "models/zombie_crown/p_guillotine.mdl"
#define MODEL_W "models/zombie_crown/w_guillotine.mdl"

#define MODEL_S "models/zombie_crown/guillotine_projectile.mdl"
#define MODEL_GIB "models/zombie_crown/gibs_guilotine.mdl"

new const Weapon_Sounds[7][] =
{
	"weapons/guillotine_catch2.wav",
	"weapons/guillotine_draw.wav",
	"weapons/guillotine_draw_empty.wav",
	"weapons/guillotine_explode.wav",
	"weapons/guillotine_red.wav",
	"weapons/guillotine-1.wav",
	"weapons/guillotine_wall.wav"
}

enum
{
	ANIM_IDLE = 0, // 1.96
	ANIM_IDLE_EMPTY, // 1.96
	ANIM_SHOOT, // 0.67
	ANIM_DRAW, // 1.13
	ANIM_DRAW_EMPTY, // 1.13
	ANIM_EXPECT, // 1.96
	ANIM_EXPECT_FX, // 1.96
	ANIM_CATCH, // 0.967
	ANIM_LOST // 1.3
}

#define CSW_GUILLOTINE CSW_MP5NAVY
#define weapon_guillotine "weapon_mp5navy"

#define GUILLOTINE_OLDMODEL "models/w_mp5.mdl"
#define WEAPON_ANIMEXT "grenade"
#define WEAPON_ANIMEXT2 "knife"

#define GUILLOTINE_CLASSNAME "guillotine"
#define TASK_RESET 10234220151

const m_iLastHitGroup = 75

// MACROS
#define Get_BitVar(%1,%2) (%1 & (1 << (%2 & 31)))
#define Set_BitVar(%1,%2) %1 |= (1 << (%2 & 31))
#define UnSet_BitVar(%1,%2) %1 &= ~(1 << (%2 & 31))

const pev_eteam = pev_iuser1
const pev_return = pev_iuser2
const pev_extra = pev_iuser3

new g_Had_Guillotine, g_InTempingAttack, g_CanShoot, g_Hit, g_Ammo[33], g_MyGuillotine[33], 
Float:g_DamageTimeA[33], Float:g_DamageTimeB[33], g_PreAmmo[33], g_MyOldWeapon[33]
new g_MsgCurWeapon, g_MsgAmmoX, g_MsgWeaponList, g_CvarFriendlyFire
new g_ExpSprID, g_GibModelID

const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)

// Safety
new g_MaxPlayers

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_SetModel, "fw_SetModel")	
	register_forward(FM_EmitSound, "fw_EmitSound")
	register_forward(FM_TraceLine, "fw_TraceLine")
	register_forward(FM_TraceHull, "fw_TraceHull")
	register_touch(GUILLOTINE_CLASSNAME, "*", "fw_Guillotine_Touch")
	register_think(GUILLOTINE_CLASSNAME, "fw_Guillotine_Think")
	RegisterHam(Ham_Item_Deploy, weapon_guillotine, "fw_Item_Deploy_Post", 1)	
	RegisterHam(Ham_Item_AddToPlayer, weapon_guillotine, "fw_Item_AddToPlayer_Post", 1)
	RegisterHam(Ham_Weapon_WeaponIdle, weapon_guillotine, "fw_Weapon_WeaponIdle_Post", 1)
	g_MsgCurWeapon = get_user_msgid("CurWeapon")
	g_MsgAmmoX = get_user_msgid("AmmoX")
	g_MsgWeaponList = get_user_msgid("WeaponList")
	g_CvarFriendlyFire = get_cvar_pointer("mp_friendlyfire")
	register_clcmd("weapon_guillotine", "HookWeapon")
	g_MaxPlayers = get_maxplayers()
}

public plugin_natives ()
{
	register_native("give_weapon_guillotine", "native_give_weapon_add", 1)
}

public native_give_weapon_add(id)
{
	Get_Guillotine(id)
}

public plugin_precache()
{
	precache_model(MODEL_V)
	precache_model(MODEL_P)
	precache_model(MODEL_W)
	
	precache_model(MODEL_S)
	g_GibModelID = precache_model(MODEL_GIB)
	
	for(new i = 0; i < sizeof(Weapon_Sounds); i++)
		precache_sound(Weapon_Sounds[i])

	precache_generic( "sprites/weapon_guillotine.txt" )
	precache_generic( "sprites/640hud120.spr" )
	precache_generic( "sprites/640hud13.spr" )
	
	g_ExpSprID = precache_model( "sprites/guillotine_lost.spr" )
}

public Get_Guillotine(id)
{
	drop_weapons(id, 1)
	Set_BitVar(g_Had_Guillotine, id)
	Set_BitVar(g_CanShoot, id)
	UnSet_BitVar(g_InTempingAttack, id)
	UnSet_BitVar(g_Hit, id)
	
	g_Ammo[id] = AMMO
	g_MyGuillotine[id] = 0
	
	give_item(id, weapon_guillotine)
}

public Remove_Guillotine(id)
{
	UnSet_BitVar(g_Had_Guillotine, id)
	UnSet_BitVar(g_CanShoot, id)
	UnSet_BitVar(g_InTempingAttack, id)
	UnSet_BitVar(g_Hit, id)
	
	g_Ammo[id] = 0
}

public zp_hclass_param(id)
{
	Remove_Guillotine(id)
}

public client_disconnect(id)
{
	Remove_Guillotine(id)
}

public zp_user_infected_post(id)
{
	Remove_Guillotine(id)
}

public HookWeapon(id)
{
	engclient_cmd(id, weapon_guillotine)
	return PLUGIN_HANDLED
}

public Event_CurWeapon(id)
{
	if(!is_valid_alive(id))
		return
		
	static CSWID; CSWID = read_data(2)
	if(CSWID != CSW_GUILLOTINE && g_MyOldWeapon[id] == CSW_GUILLOTINE && Get_BitVar(g_Had_Guillotine, id))
	{
		cs_set_user_bpammo(id, CSW_GUILLOTINE, g_PreAmmo[id])
	} else if(CSWID == CSW_GUILLOTINE && g_MyOldWeapon[id] != CSW_GUILLOTINE && Get_BitVar(g_Had_Guillotine, id))
	{
		g_PreAmmo[id] = cs_get_user_bpammo(id, CSW_GUILLOTINE)
		update_ammo(id, -1, g_Ammo[id])
	} else if(CSWID == CSW_GUILLOTINE && Get_BitVar(g_Had_Guillotine, id)) {
		update_ammo(id, -1, g_Ammo[id])
	}
		
	g_MyOldWeapon[id] = CSWID
}

public update_ammo(id, Ammo, BpAmmo)
{
	message_begin(MSG_ONE_UNRELIABLE, g_MsgCurWeapon, _, id)
	write_byte(1)
	write_byte(CSW_GUILLOTINE)
	write_byte(Ammo)
	message_end()
	
	message_begin(MSG_ONE_UNRELIABLE, g_MsgAmmoX, _, id)
	write_byte(10)
	write_byte(BpAmmo)
	message_end()
	
	cs_set_user_bpammo(id, CSW_GUILLOTINE, BpAmmo)
}

public client_PostThink(id)
{
	if(!is_valid_alive(id))
		return
	if(get_user_weapon(id) != CSW_GUILLOTINE || !Get_BitVar(g_Had_Guillotine, id))
		return
	
	if(!Get_BitVar(g_CanShoot, id) && !pev_valid(g_MyGuillotine[id]))
	{
		// Reset Player
		Set_PlayerNextAttack(id, 1.0)
		Set_WeaponIdleTime(id, CSW_GUILLOTINE, 1.0)
		
		Set_WeaponAnim(id, ANIM_LOST)
		Set_BitVar(g_CanShoot, id)
		UnSet_BitVar(g_Hit, id)
		
		set_task(0.95, "Reset_Guillotine", id+TASK_RESET)
	}
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(!is_valid_alive(id))
		return FMRES_IGNORED
	if(get_user_weapon(id) != CSW_GUILLOTINE || !Get_BitVar(g_Had_Guillotine, id))
		return FMRES_IGNORED
	
	set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001) 
	
	return FMRES_HANDLED
}

public fw_CmdStart(id, uc_handle, seed)
{
	if(!is_valid_alive(id))
		return FMRES_IGNORED
	if(get_user_weapon(id) != CSW_GUILLOTINE || !Get_BitVar(g_Had_Guillotine, id))
		return FMRES_IGNORED
	
	static CurButton; CurButton = get_uc(uc_handle, UC_Buttons)
	
	if(CurButton & IN_ATTACK)
	{
		CurButton &= ~IN_ATTACK
		set_uc(uc_handle, UC_Buttons, CurButton)
		
		HandleShot_Guillotine(id)
	}
	
	return FMRES_HANDLED
}

public fw_SetModel(entity, model[])
{
	if(!pev_valid(entity))
		return FMRES_IGNORED
	
	static Classname[32]
	pev(entity, pev_classname, Classname, sizeof(Classname))
	
	if(!equal(Classname, "weaponbox"))
		return FMRES_IGNORED
	
	static iOwner
	iOwner = pev(entity, pev_owner)
	
	if(equal(model, GUILLOTINE_OLDMODEL))
	{
		static weapon; weapon = find_ent_by_owner(-1, weapon_guillotine, entity)
		
		if(!pev_valid(weapon))
			return FMRES_IGNORED;
		
		if(Get_BitVar(g_Had_Guillotine, iOwner))
		{
			set_pev(weapon, pev_impulse, 1422015)
			set_pev(weapon, pev_iuser1, g_Ammo[iOwner])
			
			cs_set_user_bpammo(iOwner, CSW_GUILLOTINE, g_PreAmmo[iOwner])
			engfunc(EngFunc_SetModel, entity, MODEL_W)
			
			Remove_Guillotine(iOwner)
			
			return FMRES_SUPERCEDE
		}
	}

	return FMRES_IGNORED;
}

public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	if(!is_valid_connected(id))
		return FMRES_IGNORED
	if(!Get_BitVar(g_InTempingAttack, id))
		return FMRES_IGNORED
		
	if(sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i')
	{
		if(sample[14] == 's' && sample[15] == 'l' && sample[16] == 'a')
			return FMRES_SUPERCEDE
		if (sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't')
		{
			if (sample[17] == 'w')  return FMRES_SUPERCEDE
			else  return FMRES_SUPERCEDE
		}
		if (sample[14] == 's' && sample[15] == 't' && sample[16] == 'a')
			return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED
}

public fw_TraceLine(Float:vector_start[3], Float:vector_end[3], ignored_monster, id, handle)
{
	if(!is_valid_alive(id))
		return FMRES_IGNORED	
	if(!Get_BitVar(g_InTempingAttack, id))
		return FMRES_IGNORED
	
	static Float:vecStart[3], Float:vecEnd[3], Float:v_angle[3], Float:v_forward[3], Float:view_ofs[3], Float:fOrigin[3]
	
	pev(id, pev_origin, fOrigin)
	pev(id, pev_view_ofs, view_ofs)
	xs_vec_add(fOrigin, view_ofs, vecStart)
	pev(id, pev_v_angle, v_angle)
	
	engfunc(EngFunc_MakeVectors, v_angle)
	get_global_vector(GL_v_forward, v_forward)

	xs_vec_mul_scalar(v_forward, 0.0, v_forward)
	xs_vec_add(vecStart, v_forward, vecEnd)
	
	engfunc(EngFunc_TraceLine, vecStart, vecEnd, ignored_monster, id, handle)
	
	return FMRES_SUPERCEDE
}

public fw_TraceHull(Float:vector_start[3], Float:vector_end[3], ignored_monster, hull, id, handle)
{
	if(!is_valid_alive(id))
		return FMRES_IGNORED	
	if(!Get_BitVar(g_InTempingAttack, id))
		return FMRES_IGNORED
	
	static Float:vecStart[3], Float:vecEnd[3], Float:v_angle[3], Float:v_forward[3], Float:view_ofs[3], Float:fOrigin[3]
	
	pev(id, pev_origin, fOrigin)
	pev(id, pev_view_ofs, view_ofs)
	xs_vec_add(fOrigin, view_ofs, vecStart)
	pev(id, pev_v_angle, v_angle)
	
	engfunc(EngFunc_MakeVectors, v_angle)
	get_global_vector(GL_v_forward, v_forward)
	
	xs_vec_mul_scalar(v_forward, 0.0, v_forward)
	xs_vec_add(vecStart, v_forward, vecEnd)
	
	engfunc(EngFunc_TraceHull, vecStart, vecEnd, ignored_monster, hull, id, handle)
	
	return FMRES_SUPERCEDE
}

public fw_Guillotine_Touch(Ent, Touched)
{
	if(!pev_valid(Ent))
		return
		
	static id; id = pev(Ent, pev_owner)
	if(!is_valid_alive(id))
	{
		Guillotine_Broken(Ent)
		return
	}
		
	if(is_valid_connected(Touched))
	{ // Touch Human
		if(!is_valid_alive(Touched))
			return
		if(Get_BitVar(g_Hit, id))
			return
		if(Touched == id)
			return
		if(!get_pcvar_num(g_CvarFriendlyFire))
		{
			if(cs_get_user_team(Touched) == cs_get_user_team(id))
				return
		}
				
		static Float:HeadOrigin[3], Float:HeadAngles[3];
		engfunc(EngFunc_GetBonePosition, Touched, 8, HeadOrigin, HeadAngles);		
				
		static Float:EntOrigin[3]; pev(Ent, pev_origin, EntOrigin)
		
		if(get_distance_f(EntOrigin, HeadOrigin) <= 21.0)
		{
			if(!pev(Ent, pev_return))
			{
				// Set
				Set_BitVar(g_Hit, id)
				Set_WeaponAnim(id, ANIM_EXPECT_FX)
				
				set_pev(Ent, pev_enemy, Touched)
				set_pev(Ent, pev_return, 1)
				set_pev(Ent, pev_movetype, MOVETYPE_FOLLOW)
				set_pev(Ent, pev_velocity, {0.0, 0.0, 0.0})
				set_pev(Ent, pev_fuser1, get_gametime() + GUILLOTINE_HITTIME)
				
				// Animation
				set_pev(Ent, pev_animtime, get_gametime())
				set_pev(Ent, pev_framerate, 5.0)
				set_pev(Ent, pev_sequence, 1)
			} else {
				if(get_gametime() - DAMAGE_DELAY > g_DamageTimeA[id])
				{	
					ExecuteHamB(Ham_TakeDamage, Touched, fm_get_user_weapon_entity(id, CSW_KNIFE), id, float(DAMAGE), DMG_SLASH)
					g_DamageTimeA[id] = get_gametime()
				}
			}
		} else {
			if(get_gametime() - DAMAGE_DELAY > g_DamageTimeA[id])
			{	
				ExecuteHamB(Ham_TakeDamage, Touched, fm_get_user_weapon_entity(id, CSW_KNIFE), id, float(DAMAGE), DMG_SLASH)
				
				// Knockback
				static Float:OriginA[3]; pev(id, pev_origin, OriginA)
				static Float:Origin[3]; pev(Touched, pev_origin, Origin)
				static Float:Velocity[3]; Get_SpeedVector(OriginA, Origin, KNOCKBACK, Velocity)
			
				set_pev(Touched, pev_velocity, Velocity)
				
				g_DamageTimeA[id] = get_gametime()
			}
		}	
	} else { // Touch Wall
		if(!pev(Ent, pev_return))
		{
			set_pev(Ent, pev_velocity, {0.0, 0.0, 0.0})
			
			set_pev(Ent, pev_return, 1)
			emit_sound(Ent, CHAN_BODY, Weapon_Sounds[6], 1.0, 0.4, 0, 94 + random_num(0, 15))
			
			// Reset Angles
			static Float:Angles[3]
			pev(id, pev_v_angle, Angles)
			
			Angles[0] *= -1.0
			set_pev(Ent, pev_angles, Angles)
			
			// Check Damage
			static Float:TakeDamage; pev(Touched, pev_takedamage, TakeDamage)
			if(TakeDamage == DAMAGE_YES) ExecuteHamB(Ham_TakeDamage, Touched, fm_get_user_weapon_entity(id, CSW_KNIFE), id, float(DAMAGE), DMG_SLASH)
		} else {
			static Classname[32];
			pev(Touched, pev_classname, Classname, 31)
			
			if(!Get_BitVar(g_Hit, id) && !equal(Classname, "weaponbox")) Guillotine_Broken(Ent)
			return
		}
	}
}

public fw_Guillotine_Think(Ent)
{
	if(!pev_valid(Ent))
		return
		
	static id; id = pev(Ent, pev_owner)
	if(!is_valid_alive(id))
	{
		Guillotine_Broken(Ent)
		return
	}
	if(!Get_BitVar(g_Had_Guillotine, id))
	{
		Guillotine_Broken(Ent)
		return
	}
	
	static Float:LiveTime
	pev(Ent, pev_fuser2, LiveTime)
			
	if(get_gametime() >= LiveTime)
	{
		Guillotine_Broken(Ent)
		return
	}
	
	if(pev(Ent, pev_return)) // Returning to the owner
	{
		static Target; Target = pev(Ent, pev_enemy)
		if(!is_valid_alive(Target))
		{
			UnSet_BitVar(g_Hit, id)
			
			if(pev(Ent, pev_sequence) != 0) set_pev(Ent, pev_sequence, 0)
			if(pev(Ent, pev_movetype) != MOVETYPE_FLY) set_pev(Ent, pev_movetype, MOVETYPE_FLY)
			set_pev(Ent, pev_aiment, 0)
			
			if(entity_range(Ent, id) > 100.0)
			{
				static Float:Origin[3]; pev(id, pev_origin, Origin)
				Hook_The_Fucking_Ent(Ent, Origin, FLYING_SPEED)
			} else {
				Guillotine_Catch(id, Ent)
				return
			}
		} else {
			static Float:fTimeRemove
			pev(Ent, pev_fuser1, fTimeRemove)
			
			if(get_gametime() >= fTimeRemove)
			{
				set_pev(Ent, pev_enemy, 0)
			} else {
				static Float:HeadOrigin[3], Float:HeadAngles[3];
				engfunc(EngFunc_GetBonePosition, Target, 8, HeadOrigin, HeadAngles);
				
				static Float:Velocity[3];
				pev(Ent, pev_velocity, Velocity)

				set_pev(Ent, pev_velocity, {0.0, 0.0, 0.0})
				set_pev(Ent, pev_angles, HeadAngles)
				
				static Float:EnemyOrigin[3]; pev(Target, pev_origin, EnemyOrigin)
				if(get_distance_f(EnemyOrigin, HeadOrigin) <= 24.0) engfunc(EngFunc_SetOrigin, Ent, HeadOrigin)
				else engfunc(EngFunc_SetOrigin, Ent, EnemyOrigin)
	
				if(get_gametime() - DAMAGE_DELAY > g_DamageTimeB[id])
				{	
					// Animation
					if(!pev(Ent, pev_sequence))
					{
						set_pev(Ent, pev_animtime, get_gametime())
						set_pev(Ent, pev_framerate, 5.0)
						set_pev(Ent, pev_sequence, 1)
					}

					set_pdata_int(Target, m_iLastHitGroup, HIT_HEAD, 5)
					ExecuteHamB(Ham_TakeDamage, Target, fm_get_user_weapon_entity(id, CSW_KNIFE), id, float(DAMAGE), DMG_SLASH)

					g_DamageTimeB[id] = get_gametime()
				}
				
				// Knockback
				static Float:OriginA[3]; pev(id, pev_origin, OriginA)
				static Float:Origin[3]; pev(Target, pev_origin, Origin)
				static Float:VelocityA[3]; Get_SpeedVector(OriginA, Origin, KNOCKBACK / 5.0, VelocityA)
			
				set_pev(Target, pev_velocity, VelocityA)
			}
		}
	} else {
		if(entity_range(Ent, id) >= MAX_RADIUS)
		{
			set_pev(Ent, pev_velocity, {0.0, 0.0, 0.0})
			set_pev(Ent, pev_return, 1)
		}
	}
	
	set_pev(Ent, pev_nextthink, get_gametime() + 0.05)
}

public Guillotine_Broken(Ent)
{
	static Float:Origin[3];
	
	emit_sound(Ent, CHAN_BODY, Weapon_Sounds[3], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	pev(Ent, pev_origin, Origin)
	
	remove_entity(Ent)

	// Effect
	message_begin(MSG_BROADCAST ,SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, Origin[0])
	engfunc(EngFunc_WriteCoord, Origin[1])
	engfunc(EngFunc_WriteCoord, Origin[2])
	write_short(g_ExpSprID)	// sprite index
	write_byte(5)	// scale in 0.1's
	write_byte(30)	// framerate
	write_byte(TE_EXPLFLAG_NOSOUND)	// flags
	message_end()
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_BREAKMODEL)
	engfunc(EngFunc_WriteCoord, Origin[0])
	engfunc(EngFunc_WriteCoord, Origin[1])
	engfunc(EngFunc_WriteCoord, Origin[2])
	write_coord(64); // size x
	write_coord(64); // size y
	write_coord(64); // size z
	write_coord(random_num(-64,64)); // velocity x
	write_coord(random_num(-64,64)); // velocity y
	write_coord(25); // velocity z
	write_byte(10); // random velocity
	write_short(g_GibModelID); // model index that you want to break
	write_byte(32); // count
	write_byte(25); // life
	write_byte(0x01); // flags: BREAK_GLASS
	message_end();  	
}

public Reset_Guillotine(id)
{
	id -= TASK_RESET
	
	if(!is_valid_alive(id))
		return
	if(!Get_BitVar(g_Had_Guillotine, id))
		return
	Set_BitVar(g_CanShoot, id)
	if(get_user_weapon(id) != CSW_GUILLOTINE)
		return
	
	Set_PlayerNextAttack(id, 0.75)
	Set_WeaponIdleTime(id, CSW_GUILLOTINE, 0.75)
	
	if(g_Ammo[id]) 
	{	
		Set_WeaponAnim(id, ANIM_DRAW)
		PlaySound(id, Weapon_Sounds[0])
	}
}

public Guillotine_Catch(id, Ent)
{
	// Remove Entity
	remove_entity(Ent)
	g_MyGuillotine[id] = -1
	
	// Reset Player
	if(get_user_weapon(id) == CSW_GUILLOTINE && Get_BitVar(g_Had_Guillotine, id))
	{
		g_Ammo[id] = min(g_Ammo[id] + 1, AMMO)
		update_ammo(id, -1, g_Ammo[id])
		
		Create_FakeAttack(id)
		
		Set_PlayerNextAttack(id, 1.0)
		Set_WeaponIdleTime(id, CSW_GUILLOTINE, 1.0)
		
		Set_WeaponAnim(id, ANIM_CATCH)
		Set_BitVar(g_CanShoot, id)
		UnSet_BitVar(g_Hit, id)

		emit_sound(id, CHAN_WEAPON, Weapon_Sounds[0], 1.0, 0.4, 0, 94 + random_num(0, 15))
	} else {
		emit_sound(id, CHAN_WEAPON, Weapon_Sounds[3], 1.0, 0.4, 0, 94 + random_num(0, 15))
		Set_BitVar(g_CanShoot, id)
		UnSet_BitVar(g_Hit, id)
	}
}

public fw_Item_Deploy_Post(Ent)
{
	if(pev_valid(Ent) != 2)
		return
	static Id; Id = get_pdata_cbase(Ent, 41, 4)
	if(get_pdata_cbase(Id, 373) != Ent)
		return
	if(!Get_BitVar(g_Had_Guillotine, Id))
		return
	
	set_pev(Id, pev_viewmodel2, MODEL_V)
	set_pev(Id, pev_weaponmodel2, MODEL_P)
	
	static Valid; Valid = pev_valid(g_MyGuillotine[Id])
	if(g_Ammo[Id]) 
	{	
		Set_WeaponAnim(Id, ANIM_DRAW)
		//if(!Valid) PlaySound(Id, Weapon_Sounds[0])
	} else Set_WeaponAnim(Id, ANIM_DRAW_EMPTY)
	
	if(!Valid) Set_BitVar(g_CanShoot, Id)
	else Set_WeaponAnim(Id, ANIM_DRAW_EMPTY)
		
	set_pdata_string(Id, (492) * 4, WEAPON_ANIMEXT, -1 , 20)
}

public fw_Item_AddToPlayer_Post(Ent, id)
{
	if(!pev_valid(Ent))
		return HAM_IGNORED
		
	if(pev(Ent, pev_impulse) == 1422015)
	{
		Set_BitVar(g_Had_Guillotine, id)
		Set_BitVar(g_CanShoot, id)
		
		set_pev(Ent, pev_impulse, 0)
		g_Ammo[id] = pev(Ent, pev_iuser1)
	}
	
	
	if(Get_BitVar(g_Had_Guillotine, id))
	{
		message_begin(MSG_ONE_UNRELIABLE, g_MsgWeaponList, _, id)
		write_string("weapon_guillotine")
		write_byte(10)
		write_byte(120)
		write_byte(-1)
		write_byte(-1)
		write_byte(0)
		write_byte(7)
		write_byte(CSW_GUILLOTINE)
		write_byte(0)
		message_end()
	}
	
	return HAM_HANDLED	
}

public fw_Weapon_WeaponIdle_Post(iEnt)
{
	if(pev_valid(iEnt) != 2)
		return
	static Id; Id = get_pdata_cbase(iEnt, 41, 4)
	//if(get_pdata_cbase(Id, 373) != iEnt)
	//	/return
	if(!Get_BitVar(g_Had_Guillotine, Id))
		return
		
	if(get_pdata_float(iEnt, 48, 4) <= 0.25)
	{
		if(g_Ammo[Id]) 
		{	
			if(Get_BitVar(g_CanShoot, Id)) Set_WeaponAnim(Id, ANIM_IDLE)
			else {
				if(Get_BitVar(g_Hit, Id)) Set_WeaponAnim(Id, ANIM_EXPECT_FX)
				else Set_WeaponAnim(Id, ANIM_EXPECT)
			}
		} else Set_WeaponAnim(Id, ANIM_IDLE_EMPTY)
		
		set_pdata_float(iEnt, 48, 20.0, 4)
	}	
}

public HandleShot_Guillotine(id)
{
	if(get_pdata_float(id, 83, 5) > 0.0)
		return
	if(g_Ammo[id] <= 0)
		return
	if(!Get_BitVar(g_CanShoot, id))
		return
		
	static Ent; Ent = fm_get_user_weapon_entity(id, CSW_GUILLOTINE)
	if(!pev_valid(Ent)) return		
	
	UnSet_BitVar(g_CanShoot, id)
	Create_FakeAttack(id)
	
	Set_WeaponAnim(id, ANIM_SHOOT)
	emit_sound(id, CHAN_WEAPON, Weapon_Sounds[5], 1.0, 0.4, 0, 94 + random_num(0, 15))
	
	Create_Guillotine(id)

	Set_PlayerNextAttack(id, 0.5)
	Set_WeaponIdleTime(id, CSW_GUILLOTINE, 0.5)
	
	g_Ammo[id]--
	update_ammo(id, -1, g_Ammo[id])
}

public Create_Guillotine(id)
{
	new iEnt = create_entity("info_target")
	
	static Float:Origin[3], Float:TargetOrigin[3], Float:Velocity[3], Float:Angles[3]
	
	get_weapon_attachment(id, Origin, 0.0)
	Origin[2] -= 10.0
	get_position(id, 1024.0, 0.0, 0.0, TargetOrigin)
	
	pev(id, pev_v_angle, Angles)
	Angles[0] *= -1.0
	
	// set info for ent
	set_pev(iEnt, pev_movetype, MOVETYPE_FLY)
	entity_set_string(iEnt, EV_SZ_classname, GUILLOTINE_CLASSNAME)
	engfunc(EngFunc_SetModel, iEnt, MODEL_S)
	
	set_pev(iEnt, pev_mins, Float:{-1.0, -1.0, -1.0})
	set_pev(iEnt, pev_maxs, Float:{1.0, 1.0, 1.0})
	set_pev(iEnt, pev_origin, Origin)
	set_pev(iEnt, pev_angles, Angles)
	set_pev(iEnt, pev_gravity, 0.01)
	set_pev(iEnt, pev_solid, SOLID_TRIGGER)
	set_pev(iEnt, pev_owner, id)	
	set_pev(iEnt, pev_eteam, get_user_team(id))
	set_pev(iEnt, pev_return, 0)
	set_pev(iEnt, pev_extra, 0)
	set_pev(iEnt, pev_enemy, 0)
	set_pev(iEnt, pev_fuser2, get_gametime() + 8.0)
	
	get_speed_vector(Origin, TargetOrigin, FLYING_SPEED, Velocity)
	set_pev(iEnt, pev_velocity, Velocity)	
	
	set_pev(iEnt, pev_nextthink, get_gametime() + 0.1)
	
	g_MyGuillotine[id] = iEnt
	
	// Animation
	set_pev(iEnt, pev_animtime, get_gametime())
	set_pev(iEnt, pev_framerate, 2.0)
	set_pev(iEnt, pev_sequence, 0)
}

public Create_FakeAttack(id)
{
	static Ent; Ent = fm_get_user_weapon_entity(id, CSW_KNIFE)
	if(!pev_valid(Ent)) return
	
	Set_BitVar(g_InTempingAttack, id)
	ExecuteHamB(Ham_Weapon_PrimaryAttack, Ent)
	
	// Set Real Attack Anim
	static iAnimDesired,  szAnimation[64]

	formatex(szAnimation, charsmax(szAnimation), (pev(id, pev_flags) & FL_DUCKING) ? "crouch_shoot_%s" : "ref_shoot_%s", WEAPON_ANIMEXT2)
	if((iAnimDesired = lookup_sequence(id, szAnimation)) == -1)
		iAnimDesired = 0
	
	set_pev(id, pev_sequence, iAnimDesired)
	UnSet_BitVar(g_InTempingAttack, id)
}

stock Set_WeaponIdleTime(id, WeaponId ,Float:TimeIdle)
{
	static entwpn; entwpn = fm_get_user_weapon_entity(id, WeaponId)
	if(!pev_valid(entwpn)) 
		return
		
	set_pdata_float(entwpn, 46, TimeIdle, 4)
	set_pdata_float(entwpn, 47, TimeIdle, 4)
	set_pdata_float(entwpn, 48, TimeIdle + 0.5, 4)
}

stock Set_PlayerNextAttack(id, Float:nexttime)
{
	set_pdata_float(id, 83, nexttime, 5)
}

stock Set_WeaponAnim(id, anim)
{
	set_pev(id, pev_weaponanim, anim)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, {0, 0, 0}, id)
	write_byte(anim)
	write_byte(pev(id, pev_body))
	message_end()
}

stock get_weapon_attachment(id, Float:output[3], Float:fDis = 40.0)
{ 
	static Float:vfEnd[3], viEnd[3] 
	get_user_origin(id, viEnd, 3)  
	IVecFVec(viEnd, vfEnd) 
	
	static Float:fOrigin[3], Float:fAngle[3]
	
	pev(id, pev_origin, fOrigin) 
	pev(id, pev_view_ofs, fAngle)
	
	xs_vec_add(fOrigin, fAngle, fOrigin) 
	
	static Float:fAttack[3]
	
	xs_vec_sub(vfEnd, fOrigin, fAttack)
	xs_vec_sub(vfEnd, fOrigin, fAttack) 
	
	static Float:fRate
	
	fRate = fDis / vector_length(fAttack)
	xs_vec_mul_scalar(fAttack, fRate, fAttack)
	
	xs_vec_add(fOrigin, fAttack, output)
}

stock get_position(id,Float:forw, Float:right, Float:up, Float:vStart[])
{
	new Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]
	
	pev(id, pev_origin, vOrigin)
	pev(id, pev_view_ofs,vUp) //for player
	xs_vec_add(vOrigin,vUp,vOrigin)
	pev(id, pev_v_angle, vAngle) // if normal entity ,use pev_angles
	
	angle_vector(vAngle,ANGLEVECTOR_FORWARD,vForward) //or use EngFunc_AngleVectors
	angle_vector(vAngle,ANGLEVECTOR_RIGHT,vRight)
	angle_vector(vAngle,ANGLEVECTOR_UP,vUp)
	
	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
}

stock get_speed_vector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
	
	return 1;
}

stock Hook_The_Fucking_Ent(ent, Float:TargetOrigin[3], Float:Speed)
{
	static Float:fl_Velocity[3], Float:EntOrigin[3], Float:distance_f, Float:fl_Time
	
	pev(ent, pev_origin, EntOrigin)
	
	distance_f = get_distance_f(EntOrigin, TargetOrigin)
	fl_Time = distance_f / Speed
		
	pev(ent, pev_velocity, fl_Velocity)
		
	fl_Velocity[0] = (TargetOrigin[0] - EntOrigin[0]) / fl_Time
	fl_Velocity[1] = (TargetOrigin[1] - EntOrigin[1]) / fl_Time
	fl_Velocity[2] = (TargetOrigin[2] - EntOrigin[2]) / fl_Time

	set_pev(ent, pev_velocity, fl_Velocity)
}

stock PlaySound(id, const sound[])
{
	if(equal(sound[strlen(sound)-4], ".mp3")) client_cmd(id, "mp3 play ^"sound/%s^"", sound)
	else client_cmd(id, "spk ^"%s^"", sound)
}

stock Get_SpeedVector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
	
	return 1;
}


// Drop primary/secondary weapons
stock drop_weapons(id, dropwhat)
{
	// Get user weapons
	static weapons[32], num, i, weaponid
	num = 0 // reset passed weapons count (bugfix)
	get_user_weapons(id, weapons, num)
	
	// Loop through them and drop primaries or secondaries
	for (i = 0; i < num; i++)
	{
		// Prevent re-indexing the array
		weaponid = weapons[i]
		
		if ((dropwhat == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM)) || (dropwhat == 2 && ((1<<weaponid) & SECONDARY_WEAPONS_BIT_SUM)))
		{
			// Get weapon entity
			static wname[32]; get_weaponname(weaponid, wname, charsmax(wname))
			engclient_cmd(id, "drop", wname)
		}
	}
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1042\\ f0\\ fs16 \n\\ par }
*/
