#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <zombiecrown>
#include <colored_print>

new const ClassnameJetPack[] = "n4d_jetpack"
new const ClassnameRocket[] = "n4d_bazooka"
new const ModelVJetPack[] = "models/v_egon.mdl"
new const ModelPJetPack[] = "models/p_egon.mdl"
new const ModelWJetPack[] = "models/w_egon.mdl"
new const ModelRocket[] = "models/rpgrocket.mdl"
new const SoundPickup[] = "items/gunpickup2.wav"
new const SoundShoot[] = "zombie_crown/items/at4-1.wav"
new const SoundTravel[] = "zombie_crown/items/bfuu.wav"
new const SoundFly[] = "zombie_crown/items/jetpack.wav"
new const SoundBlow[] = "zombie_crown/items/blow.wav"

new bool:bHasJetPack[33], g_maxplayers, Float:fJetpackFuel[33], Float:fLastShoot[33]
new SprExp, SprTrail, SprRing, SprFlame, ItemJetPack_ZP, ItemJetPack_ZV, iAllocInfoTarget
new CvarMaxFuel, CvarRadius, CvarDamage, CvarSpeed, CvarCooldown, CvarRegen, CvarRocketSpeed
new Float:CMaxFuel, Float:CRadius, Float:CDamage, CSpeed, Float:CCooldown, Float:CRegen, CRocketSpeed
#define IsPlayer(%1) (1 <= %1 <= g_maxplayers && is_user_connected(%1) && !is_user_hltv(%1) && !is_user_bot(%1))
#define PevEntType pev_flSwimTime
#define EntTypeJetPack 3904
#define EntTypeRocket 9340

public plugin_precache()
{
	precache_sound(SoundPickup)
	precache_sound(SoundShoot)
	precache_sound(SoundTravel)
	precache_sound(SoundFly)
	precache_sound(SoundBlow)

	SprExp = precache_model("sprites/zerogxplode.spr")
	SprTrail = precache_model("sprites/smoke.spr")

	SprFlame = precache_model("sprites/xfireball3.spr")
	SprRing = precache_model("sprites/shockwave.spr")

	precache_model(ModelVJetPack)
	precache_model(ModelPJetPack)
	precache_model(ModelWJetPack)
	precache_model(ModelRocket)
}

public plugin_init()
{
	register_plugin("[ZC Jetpack]", "1.0", "meNe")
	register_event("HLTV", "OnNewRound", "a", "1=0", "2=0")
	register_logevent("OnRoundEnd", 2, "1=Round_End")
	RegisterHam(Ham_Killed, "player", "OnPlayerKilled")
	RegisterHam(Ham_Player_Jump, "player", "OnPlayerJump")
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "OnKnifeSecAtkPost", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "OnKnifeDeployPost", 1)
	register_forward(FM_PlayerPreThink, "OnPlayerPreThink")
	register_forward(FM_Touch, "OnTouch")
	g_maxplayers=get_maxplayers()
	CvarMaxFuel = register_cvar("jp_maxfuel", "340.0")
	CvarRadius = register_cvar("jp_radius", "400.0")
	CvarDamage = register_cvar("jp_damage", "700.0")
	CvarSpeed = register_cvar("jp_speed", "300")
	CvarCooldown = register_cvar("jp_cooldown", "15.0")
	CvarRegen = register_cvar("jp_regen", "0.5")
	CvarRocketSpeed = register_cvar("jp_rocket_speed", "1300")
	ItemJetPack_ZP = zp_register_extra_item("Jetpack + Bazooka", 100, ZP_TEAM_HUMAN, REST_MAP, 7)
	ItemJetPack_ZV = zv_register_extra_item("Jetpack + Bazooka", 60, ZV_TEAM_HUMAN, REST_MAP, 10)
	register_clcmd("drop", "CmdDropJP")
	register_concmd("amx_givejetpack", "givejetpack", ADMIN_LEVEL_C," <name or #userid>")
}

public plugin_natives()
{
	register_native("zp_has_jetpack", "native_has_jetpack", 1)
}

public plugin_cfg()
{
	iAllocInfoTarget = engfunc(EngFunc_AllocString, "info_target")
}

public client_putinserver(id)
{
	ResetValues(id)
}

public client_disconnect(id)
{
	ResetValues(id)
}

public OnNewRound()
{
	RemoveAllJetPack()
	CMaxFuel = get_pcvar_float(CvarMaxFuel)
	CRadius = get_pcvar_float(CvarRadius)
	CDamage = get_pcvar_float(CvarDamage)
	CSpeed = get_pcvar_num(CvarSpeed)
	CCooldown = get_pcvar_float(CvarCooldown)
	CRegen = get_pcvar_float(CvarRegen)
	CRocketSpeed = get_pcvar_num(CvarRocketSpeed)
}

public OnRoundEnd()
{
	RemoveAllJetPack()
}

public OnPlayerKilled(id)
{
	if(bHasJetPack[id])
	{
		DropJetPack(id);
		ResetValues(id)
	}
}

public OnPlayerJump(id)
{
	if(bHasJetPack[id] && !zp_get_human_hero(id) && fJetpackFuel[id] > 0.0 && pev(id, pev_button) & IN_DUCK && ~pev(id, pev_flags) & FL_ONGROUND)
	{
		static Float:vVelocity[3], Float:upSpeed
		pev(id, pev_velocity, vVelocity)
		upSpeed = vVelocity[2] + 35.0
		velocity_by_aim(id, CSpeed, vVelocity)
		vVelocity[2] = upSpeed > 300.0 ? 300.0 : upSpeed
		set_pev(id, pev_velocity, vVelocity)
		pev(id, pev_origin, vVelocity)
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vVelocity, 0)
		write_byte(TE_SPRITE)
		engfunc(EngFunc_WriteCoord, vVelocity[0])
		engfunc(EngFunc_WriteCoord, vVelocity[1])
		engfunc(EngFunc_WriteCoord, vVelocity[2])
		write_short(SprFlame)
		write_byte(8)
		write_byte(128)
		message_end()
		fJetpackFuel[id] > 80.0 ? emit_sound(id, CHAN_STREAM, SoundFly, VOL_NORM, ATTN_NORM, 0,  PITCH_NORM) : emit_sound(id, CHAN_STREAM, SoundBlow, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		if(zp_is_hero_round()) fJetpackFuel[id] -= 3.0
		else fJetpackFuel[id] -= 1.0
	}
}

public zp_user_infected_pre(id)
{
	if(bHasJetPack[id])
	{
		DropJetPack(id)
		ResetValues(id)
	}
}

public zp_user_humanized_pre(id, survivor, sniper, flamer)
{
	if(bHasJetPack[id])
	{
		DropJetPack(id)
		ResetValues(id)
	}
}

public zp_extra_item_selected(id, item)
{
	if(item == ItemJetPack_ZP)
	{
		if(bHasJetPack[id])
		{
			colored_print(id, GREEN, "[ZC]^x01 You already have this item!")
			return ZP_PLUGIN_HANDLED;
		}

		bHasJetPack[id] = true
		colored_print(id, GREEN, "[ZC]^x01 Press^x03 CTRL+SPACE^x01 (duck+jump) for fly with jetpack !" );
		engclient_cmd(id, "weapon_knife")
		ReplaceModel(id)
	}
	return PLUGIN_CONTINUE;
}

public zv_extra_item_selected(id, item)
{
	if(item == ItemJetPack_ZV)
	{
		if(bHasJetPack[id])
		{
			colored_print(id, GREEN, "[ZC]^x01 You already have this item!")
			return ZP_PLUGIN_HANDLED;
		}

		bHasJetPack[id] = true
		colored_print(id, GREEN, "[ZC]^x01 Press^x03 CTRL+SPACE^x01 (duck+jump) for fly with jetpack !" );
		engclient_cmd(id, "weapon_knife")
		ReplaceModel(id)
	}
	return PLUGIN_CONTINUE;
}

public givejetpack(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2))
	{
        	return PLUGIN_HANDLED
	}

	new target[32]
    	read_argv(1, target, 31)
	new player = cmd_target(id, target, 8)
    	if(!player) 
	{
		return PLUGIN_HANDLED
	} 
    	if(is_user_alive(player) && !zp_get_user_zombie(player) && !zp_get_human_hero(player) && !zp_get_zombie_hero(player))  
	{
		new admin_name [32], player_name[32]
    		get_user_name(id, admin_name, 31)
    		get_user_name(player, player_name, 31)
		bHasJetPack[player] = true
		colored_print(player, GREEN, "[ZC]^x01 Press^x03 CTRL+SPACE^x01 (duck+jump) for fly with jetpack !" );
		engclient_cmd(player, "weapon_knife")
		ReplaceModel(player)
		client_print(id, print_console, "You gave to %s a Jetpack.", player_name)
	}else{
		client_print(id, print_console, "The target must be valid (alive and human).")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public OnKnifeSecAtkPost(ent2)
{
	if(pev_valid(ent2) == 2)
	{
		static id, Float:ctime
		id = get_pdata_cbase(ent2, 41, 4)
		ctime = get_gametime()
		if(is_user_alive(id) && bHasJetPack[id] && fLastShoot[id] < ctime)
		{
			new ent = engfunc(EngFunc_CreateNamedEntity, iAllocInfoTarget)
			if(ent)
			{
				engfunc(EngFunc_SetModel, ent, ModelRocket)
				engfunc(EngFunc_SetSize, ent, Float:{0.0, 0.0, 0.0}, Float:{0.0, 0.0, 0.0})
				new Float:fOrigin[3]
				pev(id, pev_origin, fOrigin)
				fOrigin[2] += 16.0
				engfunc(EngFunc_SetOrigin, ent, fOrigin)
				set_pev(ent, pev_classname, ClassnameRocket)
				set_pev(ent, pev_dmg, 100.0)
				set_pev(ent, pev_owner, id)
				velocity_by_aim(id, CRocketSpeed, fOrigin)
				set_pev(ent, pev_velocity, fOrigin)
				new Float:vecAngles[3]
				engfunc(EngFunc_VecToAngles, fOrigin, vecAngles)
				set_pev(ent, pev_angles, vecAngles)
				set_pev(ent, PevEntType, EntTypeRocket)	
				set_pev(ent, pev_movetype, MOVETYPE_FLY)
				set_pev(ent, pev_effects, EF_LIGHT)
				set_pev(ent, pev_solid, SOLID_BBOX)

				emit_sound(id, CHAN_STATIC, SoundShoot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				emit_sound(ent, CHAN_WEAPON, SoundTravel, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

				message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
				write_byte(TE_BEAMFOLLOW)
				write_short(ent)
				write_short(SprTrail)
				write_byte(40)
				write_byte(5)
				write_byte(224)
				write_byte(224)
				write_byte(255)
				write_byte(192)
				message_end()
				fLastShoot[id] = ctime+CCooldown
			}
			else
			{
				client_print(id, print_chat, "[ZC] Failed to create rocket!")
				fLastShoot[id] = ctime+1.5
			}
		}
	}
}

public OnKnifeDeployPost(ent)
{
	if(pev_valid(ent) == 2)
	{
		static id; id = get_pdata_cbase(ent, 41, 4)
		if(is_user_alive(id) && bHasJetPack[id]) ReplaceModel(id);
	}
}

public OnPlayerPreThink(id)
{
	if(bHasJetPack[id] && fJetpackFuel[id] < CMaxFuel)
	{
		static button; button = pev(id, pev_button)
		if(!(button & IN_DUCK) && !(button & IN_JUMP)) fJetpackFuel[id] += CRegen;
	}
}

public OnTouch(ent, id)
{
	if(pev_valid(ent))
	{
		if(pev(ent, PevEntType) == EntTypeJetPack)
		{
			if(IsPlayer(id) && is_user_alive(id) && !zp_get_user_zombie(id) && !zp_get_human_hero(id) && !bHasJetPack[id])
			{
				engfunc(EngFunc_RemoveEntity, ent)
				bHasJetPack[id] = true
				emit_sound(id, CHAN_STATIC, SoundPickup, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				engclient_cmd(id,"weapon_knife")
				ReplaceModel(id)
			}
		}
		else if(pev(ent, PevEntType) == EntTypeRocket)
		{
			static Float:fOrigin[3]
			pev(ent, pev_origin, fOrigin)

			engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, fOrigin, 0)
			write_byte(TE_EXPLOSION)
			engfunc(EngFunc_WriteCoord, fOrigin[0])
			engfunc(EngFunc_WriteCoord, fOrigin[1])
			engfunc(EngFunc_WriteCoord, fOrigin[2])
			write_short(SprExp)
			write_byte(40)
			write_byte(30)
			write_byte(10)
			message_end()

			engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, fOrigin, 0)
			write_byte(TE_BEAMCYLINDER)
			engfunc(EngFunc_WriteCoord, fOrigin[0])
			engfunc(EngFunc_WriteCoord, fOrigin[1])
			engfunc(EngFunc_WriteCoord, fOrigin[2])
			engfunc(EngFunc_WriteCoord, fOrigin[0])
			engfunc(EngFunc_WriteCoord, fOrigin[1])
			engfunc(EngFunc_WriteCoord, fOrigin[2]+555.0)
			write_short(SprRing)
			write_byte(0)
			write_byte(1)
			write_byte(6)
			write_byte(8)
			write_byte(10)
			write_byte(224)
			write_byte(224)
			write_byte(255)
			write_byte(192)
			write_byte(5)
			message_end()

			static attacker; attacker = pev(ent, pev_owner)
			if(!is_user_connected(attacker))
			{
				engfunc(EngFunc_RemoveEntity, ent)
				return FMRES_IGNORED;
			}

			if(pev_valid(id) && !is_user_connected(id))
			{
				static szClassname[32]
				pev(id, pev_classname, szClassname, 31)
				if(equal(szClassname, "func_breakable") && (pev(id, pev_solid) != SOLID_NOT))
				{
					dllfunc(DLLFunc_Use, id, ent)
				}
			}

			static victim; victim = -1
			while((victim = engfunc(EngFunc_FindEntityInSphere, victim, fOrigin, CRadius)) != 0)
			{
				if(is_user_alive(victim) && zp_get_user_zombie(victim))
				{
					static Float:originV[3], Float:dist, Float:damage
					pev(victim, pev_origin, originV)
					dist = get_distance_f(fOrigin, originV)
					damage = (CDamage+200)-(CDamage/CRadius)*dist
					if(damage > 0.0)
					{
						ExecuteHamB(Ham_TakeDamage, victim, ent, attacker, damage, DMG_BULLET)
						new name[32];
						get_user_name(victim, name, 31);
						colored_print(attacker, GREEN, "[ZC]^x01 Damage to ^x03%s^x01 :: ^x04%.1f damage", name, damage)
					}
				}
			}

			engfunc(EngFunc_RemoveEntity, ent)
		}
	}

	return FMRES_IGNORED;
}

public CmdDropJP(id)
{
	if(is_user_alive(id) && bHasJetPack[id] && get_user_weapon(id) == CSW_KNIFE)
	{
		DropJetPack(id)
		ResetValues(id)
		set_pev(id, pev_viewmodel2, "models/v_knife.mdl")
		set_pev(id, pev_weaponmodel2, "models/p_knife.mdl")
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

ReplaceModel(id)
{
	set_pev(id, pev_viewmodel2, ModelVJetPack)
	set_pev(id, pev_weaponmodel2, ModelPJetPack)
}

DropJetPack(id)
{
	new Float:fAim[3], Float:fOrigin[3]
	velocity_by_aim(id, 64, fAim)
	pev(id, pev_origin, fOrigin)
	fOrigin[0] += fAim[0]
	fOrigin[1] += fAim[1]

	new ent = engfunc(EngFunc_CreateNamedEntity, iAllocInfoTarget)
	if(ent)
	{
		engfunc(EngFunc_SetModel, ent, ModelWJetPack)
		engfunc(EngFunc_SetSize, ent, Float:{-4.0,-4.0,-4.0}, Float:{4.0,4.0,4.0})
		engfunc(EngFunc_SetOrigin, ent, fOrigin)
		set_pev(ent, pev_classname, ClassnameJetPack)
		set_pev(ent, pev_dmg, 100.0)
		set_pev(ent, PevEntType, EntTypeJetPack)
		set_pev(ent, pev_movetype, MOVETYPE_TOSS)
		set_pev(ent, pev_solid, SOLID_TRIGGER)
	}
}

RemoveAllJetPack()
{
	new ent = engfunc(EngFunc_FindEntityByString, -1, "classname", ClassnameJetPack)
	while(ent > 0)
	{
		engfunc(EngFunc_RemoveEntity, ent)
		ent = engfunc(EngFunc_FindEntityByString, -1, "classname", ClassnameJetPack)
	}
}

ResetValues(id)
{
	if(is_user_bot(id)) return;
	bHasJetPack[id] = false
	fJetpackFuel[id] = get_pcvar_float(CvarMaxFuel)
}

// Native: zp_has_jetpack
public native_has_jetpack(id)
{
	return bHasJetPack[id];
}