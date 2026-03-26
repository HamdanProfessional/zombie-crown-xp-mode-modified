#include <amxmodx>
#include <engine>
#include <xs>
#include <zombiecrown>

new Float:g_fDelay[33], g_ThermalOn[33], sprite_playerheat, cvar_maxdistance, cvar_updatedelay, g_zclass_thermal

// Thermal Zombie Atributes
new const zclass_name[] = { "Thermal" } // name
new const zclass_info[] = { "Looks through walls" } // description
new const zclass_model[] = { "zc_model_zm4" }
new const zclass_clawmodel[] = { "v_knife_zm4.mdl" }
const zclass_health = 15000
const zclass_speed = 470
const Float:zclass_gravity = 0.54
const Float:zclass_knockback = 1.5 // knockback
const zclass_level = 16

public plugin_init()
{
	new registerText[32]
	formatex( registerText, sizeof registerText - 1, "[ZC %s]", zclass_name)
	register_plugin(registerText, "1.0", "meNe")	
	cvar_maxdistance = register_cvar("amx_tig_distance", 	"1500")
	cvar_updatedelay = register_cvar("amx_tig_updatedelay", "0.2")
	register_event("NVGToggle", "Event_NVGToggle", "be")
}

public plugin_precache()
{
	sprite_playerheat = precache_model("sprites/poison.spr")
	g_zclass_thermal = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_level)
}

public Event_NVGToggle(id)
	g_ThermalOn[id] = read_data(1)

public client_PostThink(id)
{
	if(is_user_alive(id) && zp_get_user_zombie(id) && !zp_get_user_nemesis(id) && !zp_get_user_assassin(id) && !zp_get_user_genesys(id) && !zp_get_user_oberon(id))
	{
		if(zp_get_user_zombie_class(id) != g_zclass_thermal) return PLUGIN_CONTINUE
		
		if((g_fDelay[id] + get_pcvar_float(cvar_updatedelay)) > get_gametime())
			return PLUGIN_CONTINUE
	
		g_fDelay[id] = get_gametime()
	
		new Float:fMyOrigin[3]
		entity_get_vector(id, EV_VEC_origin, fMyOrigin)
	
		static Players[32], iNum
		get_players(Players, iNum, "a")
		for(new i = 0; i < iNum; ++i) 
		if(id != Players[i] && !zp_get_user_zombie(Players[i]))
		{
			new target = Players[i]
		
			new Float:fTargetOrigin[3]
			entity_get_vector(target, EV_VEC_origin, fTargetOrigin)
		
			if((get_distance_f(fMyOrigin, fTargetOrigin) > get_pcvar_num(cvar_maxdistance)) 
			|| !is_in_viewcone(id, fTargetOrigin))
				continue

			new Float:fMiddle[3], Float:fHitPoint[3]
			xs_vec_sub(fTargetOrigin, fMyOrigin, fMiddle)
			trace_line(-1, fMyOrigin, fTargetOrigin, fHitPoint)
								
			new Float:fWallOffset[3], Float:fDistanceToWall
			fDistanceToWall = vector_distance(fMyOrigin, fHitPoint) - 10.0
			normalize(fMiddle, fWallOffset, fDistanceToWall)
		
			new Float:fSpriteOffset[3]
			xs_vec_add(fWallOffset, fMyOrigin, fSpriteOffset)
			new Float:fScale, Float:fDistanceToTarget = vector_distance(fMyOrigin, fTargetOrigin)
			if(fDistanceToWall > 100.0)
				fScale = 8.0 * (fDistanceToWall / fDistanceToTarget)
			else
				fScale = 2.0
	
			te_sprite(id, fSpriteOffset, sprite_playerheat, floatround(fScale), 125)
		}
	}
	return PLUGIN_CONTINUE
}

stock te_sprite(id, Float:origin[3], sprite, scale, brightness)
{
	message_begin(MSG_ONE, SVC_TEMPENTITY, _, id)
	write_byte(TE_SPRITE)
	write_coord(floatround(origin[0]))
	write_coord(floatround(origin[1]))
	write_coord(floatround(origin[2]))
	write_short(sprite)
	write_byte(scale) 
	write_byte(brightness)
	message_end()
}

stock normalize(Float:fIn[3], Float:fOut[3], Float:fMul)
{
	new Float:fLen = xs_vec_len(fIn)
	xs_vec_copy(fIn, fOut)
	
	fOut[0] /= fLen, fOut[1] /= fLen, fOut[2] /= fLen
	fOut[0] *= fMul, fOut[1] *= fMul, fOut[2] *= fMul
}