#include <amxmodx>
#include <fakemeta>
#include <zombiecrown>
#include <colored_print>
#include <cstrike>

// Zombie Attributes
new const zclass_name[] = "Irichol" // name
new const zclass_info[] = "Create infection ring - C" // description
new const zclass_model[] = { "zc_model_zm7" }
new const zclass_clawmodel[] = "v_knife_zm7.mdl" // claw model
const zclass_health = 16000
const zclass_speed = 450 // speed
const Float:zclass_gravity = 1.0 // gravity
const Float:zclass_knockback = 1.0 // knockback
const zclass_level = 97
new iricholzm

// Others
new const g_szShockWaveSprite[]  =  "sprites/shockwave.spr";
new const g_szInfectSound2[]  =  "ambience/particle_suck1.wav";
new const g_szInfectSound[]  =  "warcraft3/frostnova.wav";
new gCvarInfCoolDown, Float:g_cInfCooldown[33], gShockWaveSprite

public plugin_precache()
{	
	new registerText[32]
	formatex( registerText, sizeof registerText - 1, "[ZC %s]", zclass_name)
	register_plugin(registerText, "1.0", "meNe")
	
	// Register the new class and store ID for reference
	iricholzm = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_level)	
	precache_sound(g_szInfectSound);
	precache_sound(g_szInfectSound2);
	gShockWaveSprite = precache_model(g_szShockWaveSprite);
}

public plugin_init()
{
	register_clcmd("radio3", "ultinfect")
	gCvarInfCoolDown = register_cvar("zp_explode_cooldown", "40");
}

public ultinfect(id)
{	
	if(zp_has_round_started() && is_user_alive(id) && zp_get_user_zombie_class(id) == iricholzm && zp_get_user_zombie(id) && !zp_get_zombie_hero(id) && !zp_is_lnj_round() && !zp_is_plague_round() && !zp_is_swarm_round()) 
	{
		static Float: gametime ; gametime = get_gametime();
		if(gametime - float(get_pcvar_num(gCvarInfCoolDown)) > g_cInfCooldown[id])
		{
			new Float:fOrigin[3], iOrigin[3];
			pev(id, pev_origin, fOrigin);
			FVecIVec(fOrigin, iOrigin);
			CreateBlast(0, 200, 0, iOrigin);
			emit_sound(id, CHAN_WEAPON,  g_szInfectSound2, 1.0, ATTN_NORM, 0, PITCH_NORM);	
			InfectPlayers(id, fOrigin);
			colored_print(id,  GREEN, "[ZC]^x01 The infection ring was felt by victims around you!");	
			g_cInfCooldown[id] = gametime;
		}else{
			colored_print(id, GREEN, "[ZC]^x01 Your power will charge in:^x04 %.1f seconds !", float(get_pcvar_num(gCvarInfCoolDown)) - (gametime - g_cInfCooldown[id]))
			return;
		}	
	}
}

public InfectPlayers(id, const Float:fOrigin[ 3 ])
{
	static iVictim;
	iVictim = -1;
	
	while((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, fOrigin, 200.0)) != 0) 
	{
		if(!is_user_alive(iVictim))
			continue;
			
		if(cs_get_user_team(id) == cs_get_user_team(iVictim))
			continue;

		if(!zp_get_zombie_hero(iVictim) && !zp_get_human_hero(iVictim))
		{
			ShakeScreen(iVictim, 5.5);
			FadeScreen(iVictim, 3.0, 42, 170, 255, 100);
			zp_infect_user(iVictim, id, 0, 1)
		}
	}
}

CreateBlast(const Redx, const Green, const Bluex, const iOrigin[ 3 ]) 
{
	// Small ring
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMCYLINDER);
	write_coord(iOrigin[ 0 ]); // start X
	write_coord(iOrigin[ 1 ]); // start Y
	write_coord(iOrigin[ 2 ]); // start Z
	write_coord(iOrigin[ 0 ]); // something X
	write_coord(iOrigin[ 1 ]); // something Y
	write_coord(iOrigin[ 2 ] + 285); // something Z
	write_short(gShockWaveSprite); // sprite
	write_byte(0); // startframe
	write_byte(0); // framerate
	write_byte(4); // life
	write_byte(60); // width
	write_byte(0); // noise
	write_byte(Redx); // Redx
	write_byte(Green); // green
	write_byte(Bluex); // Bluex
	write_byte(200); // brightness
	write_byte(0); // speed
	message_end();

	// Medium ring
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMCYLINDER);
	write_coord(iOrigin[ 0 ]); // start X
	write_coord(iOrigin[ 1 ]); // start Y
	write_coord(iOrigin[ 2 ]); // start Z
	write_coord(iOrigin[ 0 ]); // something X
	write_coord(iOrigin[ 1 ]); // something Y
	write_coord(iOrigin[ 2 ] + 385); // something Z
	write_short(gShockWaveSprite); // sprite
	write_byte(0); // startframe
	write_byte(0); // framerate
	write_byte(4); // life
	write_byte(60); // width
	write_byte(0); // noise
	write_byte(Redx); // Redx
	write_byte(Green); // green
	write_byte(Bluex); // Bluex
	write_byte(200); // brightness
	write_byte(0); // speed
	message_end();

	// Large ring
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMCYLINDER);
	write_coord(iOrigin[ 0 ]); // start X
	write_coord(iOrigin[ 1 ]); // start Y
	write_coord(iOrigin[ 2 ]); // start Z
	write_coord(iOrigin[ 0 ]); // something X
	write_coord(iOrigin[ 1 ]); // something Y
	write_coord(iOrigin[ 2 ] + 470); // something Z
	write_short(gShockWaveSprite); // sprite
	write_byte(0); // startframe
	write_byte(0); // framerate
	write_byte(4); // life
	write_byte(60); // width
	write_byte(0); // noise
	write_byte(Redx); // Redx
	write_byte(Green); // green
	write_byte(Bluex); // Bluex
	write_byte(200); // brightness
	write_byte(0); // speed
	message_end();
	
	// Largest Ring
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMCYLINDER);
	write_coord(iOrigin[ 0 ]); // start X
	write_coord(iOrigin[ 1 ]); // start Y
	write_coord(iOrigin[ 2 ]); // start Z
	write_coord(iOrigin[ 0 ]); // something X
	write_coord(iOrigin[ 1 ]); // something Y
	write_coord(iOrigin[ 2 ] + 555); // something Z
	write_short(gShockWaveSprite); // sprite
	write_byte(0); // startframe
	write_byte(0); // framerate
	write_byte(4); // life
	write_byte(60); // width
	write_byte(0); // noise
	write_byte(Redx); // Redx
	write_byte(Green); // green
	write_byte(Bluex); // Bluex
	write_byte(200); // brightness
	write_byte(0); // speed
	message_end();
}

public ShakeScreen(id, const Float:seconds)
{
	message_begin(MSG_ONE, get_user_msgid("ScreenShake"), { 0, 0, 0 }, id);
	write_short(floatround(4096.0 * seconds, floatround_round));
	write_short(floatround(4096.0 * seconds, floatround_round));
	write_short(1<<13);
	message_end();
}

public FadeScreen(id, const Float:seconds, const Redx, const green, const Bluex, const alpha)
{      
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"), _, id);
	write_short(floatround(4096.0 * seconds, floatround_round));
	write_short(floatround(4096.0 * seconds, floatround_round));
	write_short(0x0000);
	write_byte(Redx);
	write_byte(green);
	write_byte(Bluex);
	write_byte(alpha);
	message_end();
}