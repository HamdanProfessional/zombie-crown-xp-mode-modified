#include <amxmodx>
#include <zombiecrown>
#include <fakemeta>
#include <engine>
#include <fun>
#include <hamsandwich>
#include <colored_print>

#define SPIT_CHEAT_BLOCK
#define BETTER_COOLDOWN

new Float:g_LastSpitTime[33]

new const zclass_name[] = { "Spitter" } 
new const zclass_info[] = { "Launch an acid" } 
new const zclass_model[] = { "zc_model_zm3" }
new const zclass_clawmodel[] = "v_knife_zm3.mdl" 
const zclass_health = 16000 // health
const zclass_speed = 530 // speed
const Float:zclass_gravity = 0.7 // gravity
const Float:zclass_knockback = 1.0
const zclass_level = 74

new g_L4dSpitter
new g_trailSprite
new const g_trail[] = "sprites/xbeam3.spr"
new const spit_model[] = "models/spit.mdl"
new const bubble_model_const[] = "sprites/bubble.spr"
new const Spitter_spitlaunch[] = "zombie_crown/spitter/spitter_spit.wav"
new const Spitter_spithit[] = "bullchicken/bc_spithit2.wav"

new const Spitter_dieacid_start[] = "bullchicken/bc_acid1.wav"
new bubble_model

public plugin_init()
{
	new registerText[32]
	formatex( registerText, sizeof registerText - 1, "[ZC %s]", zclass_name)
	register_plugin(registerText, "1.0", "meNe")
	register_clcmd("spitter_spit", "clcmd_spit")
	register_touch("spit_ent","*","spitTouch")
	register_forward(FM_PlayerPreThink, "CmdStart")
} 

public plugin_precache()
{
	g_L4dSpitter = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_level) 
	g_trailSprite = precache_model(g_trail)
	bubble_model = precache_model(bubble_model_const)
	precache_model(spit_model)
	precache_sound(Spitter_spitlaunch)
	precache_sound(Spitter_spithit)
	precache_sound(Spitter_dieacid_start)
}

public zp_user_infected_post (id, infector)
{
	if (zp_get_user_zombie_class(id) == g_L4dSpitter)
	{
		colored_print(id, GREEN, "[ZC]^x01 You can launch a spit by pressing^x04 R.") 
	}
}  

public CmdStart(id)
{		
	new button = pev(id, pev_button)
	new oldbutton = pev(id, pev_oldbuttons)
	
	if (zp_get_user_zombie(id) && (zp_get_user_zombie_class(id) == g_L4dSpitter) && !zp_is_hero_round())
	{
		if(oldbutton & IN_RELOAD && !(button & IN_RELOAD))
		{
			clcmd_spit(id)
		}
	}
	return FMRES_IGNORED
}

public clcmd_spit(id)
{
	if(!is_user_alive(id) || zp_is_hero_round())
	{
		colored_print(id, GREEN, "[ZC]^x01 You are not^x04 allowed^x01 to spit.")
		return PLUGIN_HANDLED
	}
	
	if (zp_get_user_zombie(id))
	{
		if (zp_get_user_zombie_class(id) == g_L4dSpitter)
		{	
			if (get_gametime() - g_LastSpitTime[id] < 20)
			{
				colored_print(id, GREEN, "[ZC]^x01 You have to wait^x04 %.1f^x01 seconds to spit again.", 20 - (get_gametime() -  g_LastSpitTime[id]))
				return PLUGIN_HANDLED;
			}
			
			Makespit(id)
			emit_sound(id, CHAN_STREAM, Spitter_spitlaunch, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			g_LastSpitTime[id] = get_gametime()
			new Float:dam = 500.0;
			if(get_user_health(id) - 500 > 0)
			{
				fakedamage(id, "Spit acid", dam, 256);				
				static origin1[3]
				get_user_origin(id, origin1)
				bubble_break(id, origin1)
				colored_print(id, GREEN, "[ZC]^x01 You'd been damaged^x04 500^x01 by launching a^x04 spit.")
			}
		}
	}
	return PLUGIN_CONTINUE
}

public spitTouch(spitEnt, Touched)
{
	if(!pev_valid(spitEnt))
		return

	if(!is_valid_ent(spitEnt))
		return
		
	static Class[ 32 ]
	entity_get_string(Touched, EV_SZ_classname, Class, charsmax(Class) )
	new Float:origin[3]
	pev(Touched, pev_origin, origin)
	
	if(equal(Class, "player"))
	{
		if (is_user_alive(Touched) && is_user_connected(Touched))
		{
			if(!zp_get_user_zombie(Touched))
			{
				new SpitterKiller = entity_get_edict(spitEnt, EV_ENT_owner)
				emit_sound(Touched, CHAN_BODY, Spitter_spithit, 1.0, ATTN_NORM, 0, PITCH_NORM)
				zp_infect_user(Touched, SpitterKiller, 1, 1)
				colored_print(SpitterKiller, GREEN, "[ZC]^x01 You receive^x04 150^x01 packs by launching a spit to a human")
				zp_set_user_ammo_packs(SpitterKiller, zp_get_user_ammo_packs(SpitterKiller) + 150)
				static origin1[3]
				get_user_origin(Touched, origin1)
				bubble_break(Touched, origin1)
			}
			else
			{
				emit_sound(Touched, CHAN_BODY, Spitter_spithit, 1.0, ATTN_NORM, 0, PITCH_NORM)
				static origin1[3]
				get_user_origin(Touched, origin1)
				bubble_break(Touched, origin1)
				
			}
		}
	}
	if(equal(Class, "func_breakable") && entity_get_int(Touched, EV_INT_solid) != SOLID_NOT)
	{
		force_use(spitEnt, Touched)
	}
	
	remove_entity(spitEnt)
}

public bubble_break(id, origin1[3])
{
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY, origin1)
	write_byte(TE_BREAKMODEL) 
	write_coord(origin1[0])  
	write_coord(origin1[1])
	write_coord(origin1[2] + 24) 
	write_coord(16) 
	write_coord(16) 
	write_coord(16) 
	write_coord(random_num(-50,50)) 
	write_coord(random_num(-50,50)) 
	write_coord(25)
	write_byte(10) 
	write_short(bubble_model) 
	write_byte(10) 
	write_byte(38)
	write_byte(0x01) 
	message_end();
}

public Makespit(id)
{			
	new Float:Origin[3]
	new Float:Velocity[3]
	new Float:vAngle[3]

	new spitSpeed = 999

	entity_get_vector(id, EV_VEC_origin , Origin)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)

	new NewEnt = create_entity("info_target")

	entity_set_string(NewEnt, EV_SZ_classname, "spit_ent")
	entity_set_model(NewEnt, spit_model)
	entity_set_size(NewEnt, Float:{-1.5, -1.5, -1.5}, Float:{1.5, 1.5, 1.5})
	entity_set_origin(NewEnt, Origin)
	entity_set_vector(NewEnt, EV_VEC_angles, vAngle)
	entity_set_int(NewEnt, EV_INT_solid, 2)
	entity_set_int(NewEnt, EV_INT_rendermode, 5)
	entity_set_float(NewEnt, EV_FL_renderamt, 200.0)
	entity_set_float(NewEnt, EV_FL_scale, 1.00)
	entity_set_int(NewEnt, EV_INT_movetype, 5)
	entity_set_edict(NewEnt, EV_ENT_owner, id)
	velocity_by_aim(id, spitSpeed  , Velocity)
	entity_set_vector(NewEnt, EV_VEC_velocity ,Velocity)
	
	spit_trail(id, NewEnt)
	return PLUGIN_HANDLED
}

public spit_trail(id, Entity)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW) 
	write_short(Entity) 
	write_short(g_trailSprite) 
	write_byte(10) 
	write_byte(10) 
	write_byte(0) 
	write_byte(250) 
	write_byte(0) 
	write_byte(200) 
	message_end()
}