#include <amxmodx>
#include <fakemeta>
#include <fun>
#include <cstrike>
#include <hamsandwich>
#include <zombiecrown>
#include <engine>
#include <fakemeta_util>
#include <colored_print>

// Human Attributes 1
new const hclass_name_retros[] = { "Retros" } // name
new const hclass_info_retros[] = { "Balanced" } // description
new const hclass_model_retros[] = { "zc_model_human" } // class model
const hclass_health_retros = 200 // health
const hclass_speed_retros = 350 // speed
const Float:hclass_gravity_retros = 1.00 // gravity
const hclass_level_retros = 1 // level required to use

// Human Attributes 2
new const hclass_name_poratri[] = { "Poratri" } // name
new const hclass_info_poratri[] = { "600 HP + Speed" } // description
new const hclass_model_poratri[] = { "zc_model_human" } // class model
const hclass_health_poratri = 600 // health
const hclass_speed_poratri = 400 // speed
const Float:hclass_gravity_poratri = 0.8 // gravity
const hclass_level_poratri = 4 // level required to use

// Human Attributes 3
new const hclass_name_lemow[] = { "Lemow" } // name
new const hclass_info_lemow[] = { "High Jump" } // description
new const hclass_model_lemow[] = { "zc_model_human" } // class model
const hclass_health_lemow = 300 // health
const hclass_speed_lemow = 350 // speed
const Float:hclass_gravity_lemow = 0.5 // gravity
const hclass_level_lemow = 8 // level required to use

// Human Attributes 4
new const hclass_name_iceman[] = { "Iceman" } // name
new const hclass_info_iceman[] = { "Free 5x frost grenades" } // description
new const hclass_model_iceman[] = { "zc_model_human" } // class model
const hclass_health_iceman = 1200 // health
const hclass_speed_iceman = 400 // speed
const Float:hclass_gravity_iceman = 0.85 // gravity
const hclass_level_iceman = 12 // level required to use

// Human Attributes 5
new bool:g_laser[33], sprite
new const hclass_name_lsaber[] = { "Light Saber" } // name
new const hclass_info_lsaber[] = { "Free Lightsaber" } // description
new const hclass_model_lsaber[] = { "zc_model_human" } // class model
const hclass_health_lsaber = 500 // health
const hclass_speed_lsaber = 350 // speed
const Float:hclass_gravity_lsaber = 0.85 // gravity
const hclass_level_lsaber = 16 // level required to use

// Human Attributes 6
new const hclass_name_spectral[] = { "Spectral" } // name
new const hclass_info_spectral[] = { "1/2 visibility" } // description
new const hclass_model_spectral[] = { "zc_model_human" } // class model
const hclass_health_spectral = 450 // health
const hclass_speed_spectral = 350 // speed
const Float:hclass_gravity_spectral = 0.85 // gravity
const hclass_level_spectral = 20 // level required to use

// Human Attributes 7
new const hclass_name_visioner[] = { "Visioner" } // name
new const hclass_info_visioner[] = { "Free NightVision" } // description
new const hclass_model_visioner[] = { "zc_model_human" } // class model
const hclass_health_visioner = 500 // health
const hclass_speed_visioner = 350 // speed
const Float:hclass_gravity_visioner = 0.85 // gravity
const hclass_level_visioner = 24 // level required to use

// Human Attributes 8
new bool:g_mad[33]
new const hclass_name_wicked[] = { "Wicked One" } // name
new const hclass_info_wicked[] = { "Invulnerable 5s after inf" } // description
new const hclass_model_wicked[] = { "zc_model_human" } // class model
const hclass_health_wicked = 400 // health
const hclass_speed_wicked = 430 // speed
const Float:hclass_gravity_wicked = 0.91 // gravity
const hclass_level_wicked = 28 // level required to use

// Human Attributes 9
new Float:g_lastLeaptime[33]
new bool:g_leap[33]
new const hclass_name_briz[] = { "Brizsat" } // name
new const hclass_info_briz[] = { "Can Leap" } // description
new const hclass_model_briz[] = { "zc_model_human" } // class model
const hclass_health_briz = 400 // health
const hclass_speed_briz = 330 // speed
const Float:hclass_gravity_briz = 0.91 // gravity
const hclass_level_briz = 32 // level required to use

// Human Attributes 10
new bool:g_samurai[33]
const m_pPlayer = 		41
const m_flNextPrimaryAttack = 	46
const m_flNextSecondaryAttack =	47
const m_flTimeWeaponIdle = 	48 
new const hclass_name_samurai[] = { "Samurai" } // name
new const hclass_info_samurai[] = { "Fast knife" } // description
new const hclass_model_samurai[] = { "zc_model_human" } // class model
const hclass_health_samurai = 800 // health
const hclass_speed_samurai = 370 // speed
const Float:hclass_gravity_samurai = 0.79 // gravity
const hclass_level_samurai = 36 // level required to use

// Human Attributes 11
new const hclass_name_armorer[] = { "Armorer" } // name
new const hclass_info_armorer[] = { "Balanced" } // description
new const hclass_model_armorer[] = { "zc_model_human" } // class model
const hclass_health_armorer = 1200 // health
const hclass_speed_armorer = 340 // speed
const Float:hclass_gravity_armorer = 0.85 // gravity
const hclass_level_armorer = 40 // level required to use

// Human Attributes 12
new Float: cl_pushangle[33][3]
new bool:g_norecoil[33]
new const hclass_name_sharp[] = { "Sharpshooter" } // name
new const hclass_info_sharp[] = { "No Recoil" } // description
new const hclass_model_sharp[] = { "zc_model_human" } // class model
const hclass_health_sharp = 500 // health
const hclass_speed_sharp = 340 // speed
const Float:hclass_gravity_sharp = 0.88 // gravity
const hclass_level_sharp = 44 // level required to use

// Human Attributes 13
new const hclass_name_runner[] = { "Runner" } // name
new const hclass_info_runner[] = { "Speed" } // description
new const hclass_model_runner[] = { "zc_model_human" } // class model
const hclass_health_runner = 900 // health
const hclass_speed_runner = 650 // speed
const Float:hclass_gravity_runner = 0.76 // gravity
const hclass_level_runner = 48 // level required to use

// Human Attributes 14
new const hclass_name_manod[] = { "Man of Dispair" } // name
new const hclass_info_manod[] = { "+15% DMG" } // description
new const hclass_model_manod[] = { "zc_model_human" } // class model
const hclass_health_manod = 1100 // health
const hclass_speed_manod = 400 // speed
const Float:hclass_gravity_manod = 0.70 // gravity
const hclass_level_manod = 52 // level required to use

// Human Attributes 15
new bool:g_medic[33]
new bool:g_used[33]
new const hclass_name_medic[] = { "Medic" } // name
new const hclass_info_medic[] = { "1 antidote" } // description
new const hclass_model_medic[] = { "zc_model_human" } // class model
const hclass_health_medic = 1400 // health
const hclass_speed_medic = 450 // speed
const Float:hclass_gravity_medic = 0.70 // gravity
const hclass_level_medic = 56 // level required to use

// Human Attributes 16
new const hclass_name_wiseman[] = { "Wiseman" } // name
new const hclass_info_wiseman[] = { "Shotgun + Unlimited Clip" } // description
new const hclass_model_wiseman[] = { "zc_model_human" } // class model
const hclass_health_wiseman = 1300 // health
const hclass_speed_wiseman = 420 // speed
const Float:hclass_gravity_wiseman = 0.74 // gravity
const hclass_level_wiseman = 60 // level required to use

// Human Attributes 17
new const hclass_name_robber[] = { "Robber" } // name
new const hclass_info_robber[] = { "+50 packs/kill" } // description
new const hclass_model_robber[] = { "zc_model_human" } // class model
const hclass_health_robber = 1800 // health
const hclass_speed_robber = 490 // speed
const Float:hclass_gravity_robber = 0.7 // gravity
const hclass_level_robber = 64 // level required to use

// Human Attributes 18
new const hclass_name_jack[] = { "Jack" } // name
new const hclass_info_jack[] = { "Free CSO Weapon" } // description
new const hclass_model_jack[] = { "zc_model_human" } // class model
const hclass_health_jack = 1700 // health
const hclass_speed_jack = 380 // speed
const Float:hclass_gravity_jack = 0.8 // gravity
const hclass_level_jack = 67 // level required to use

// Human Attributes 19
new const hclass_name_faster[] = { "Faster" } // name
new const hclass_info_faster[] = { "2x points" } // description
new const hclass_model_faster[] = { "zc_model_human" } // class model
const hclass_health_faster = 1800 // health
const hclass_speed_faster = 480 // speed
const Float:hclass_gravity_faster = 0.8 // gravity
const hclass_level_faster = 70 // level required to use

// Human Attributes 20
new const hclass_name_ravenous[] = { "Ravenous" } // name
new const hclass_info_ravenous[] = { "Create explosion ring - C" } // description
new const hclass_model_ravenous[] = { "zc_model_human" } // class model
const hclass_health_ravenous = 2200 // health
const hclass_speed_ravenous = 510 // speed
const Float:hclass_gravity_ravenous = 0.70 // gravity
const hclass_level_ravenous = 74 // level required to use

// Human Attributes 21
new const hclass_name_mutant[] = { "Mutant" } // name
new const hclass_info_mutant[] = { "Nemesis after infection - 10 sec" } // description
new const hclass_model_mutant[] = { "zc_model_human" } // class model
const hclass_health_mutant = 1900 // health
const hclass_speed_mutant = 480 // speed
const Float:hclass_gravity_mutant = 0.7 // gravity
const hclass_level_mutant = 78 // level required to use

// Human Attributes 22
new const hclass_name_survivor[] = { "Survivor" } // name
new const hclass_info_survivor[] = { "Last human survivor" } // description
new const hclass_model_survivor[] = { "zc_model_human" } // class model
const hclass_health_survivor = 1900 // health
const hclass_speed_survivor = 500 // speed
const Float:hclass_gravity_survivor = 0.7 // gravity
const hclass_level_survivor = 82 // level required to use

// Human Attributes 23
new const hclass_name_magician[] = { "Magician" } // name
new const hclass_info_magician[] = { "Create entangles - C" } // description
new const hclass_model_magician[] = { "zc_model_human" } // class model
const hclass_health_magician = 2200 // health
const hclass_speed_magician = 510 // speed
const Float:hclass_gravity_magician = 0.70 // gravity
const hclass_level_magician = 86 // level required to use

// Human Attributes 24
new const hclass_name_leucocyt[] = { "Leucocyt" } // name
new const hclass_info_leucocyt[] = { "Immune to infection grenade" } // description
new const hclass_model_leucocyt[] = { "zc_model_human" } // class model
const hclass_health_leucocyt = 2200 // health
const hclass_speed_leucocyt = 510 // speed
const Float:hclass_gravity_leucocyt = 0.70 // gravity
const hclass_level_leucocyt = 89 // level required to use

// Human Attributes 25
new const hclass_name_arnodelo[] = { "Arnodelo" } // name
new const hclass_info_arnodelo[] = { "Freeze power - C" } // description
new const hclass_model_arnodelo[] = { "zc_model_human" } // class model
const hclass_health_arnodelo = 2200 // health
const hclass_speed_arnodelo = 500 // speed
const Float:hclass_gravity_arnodelo = 0.70 // gravity
const hclass_level_arnodelo = 93 // level required to use

// Human Attributes 26
new const hclass_name_trix[] = { "Trix" } // name
new const hclass_info_trix[] = { "Get +3 XP/kill" } // description
new const hclass_model_trix[] = { "zc_model_human" } // class model
const hclass_health_trix = 1800 // health
const hclass_speed_trix = 500 // speed
const Float:hclass_gravity_trix = 0.70 // gravity
const hclass_level_trix = 97 // level required to use

// Human Attributes 27
new const hclass_name_zolo[] = { "Zolo" } // name
new const hclass_info_zolo[] = { "Get +2 coins/kill" } // description
new const hclass_model_zolo[] = { "zc_model_human" } // class model
const hclass_health_zolo = 2100 // health
const hclass_speed_zolo = 500 // speed
const Float:hclass_gravity_zolo = 0.70 // gravity
const hclass_level_zolo = 100 // level required to use

new g_hclassid_briz, g_hclassid_wicked, g_hclassid_spectral, g_hclassid_visioner, g_hclassid_lsaber, g_hclassid_sharp, g_hclassid_samurai, 
g_hclassid_armorer, g_hclassid_iceman, g_hclassid_manod, g_hclassid_medic, g_hclassid_wiseman, g_hclassid_robber, g_hclassid_jack,
g_hclassid_faster, g_hclassid_magician, g_hclassid_leucocyt, g_hclassid_mutant, g_hclassid_survivor, g_hclassid_ravenous, g_hclassid_arnodelo, g_hclassid_trix, g_hclassid_zolo

const PRIMARY_WEAPONS_BIT_SUM = 
(1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<
CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)

// Class Sharpshooter
const WEAPONS_BITSUM = (1<<CSW_KNIFE|1<<CSW_HEGRENADE|1<<CSW_FLASHBANG|1<<CSW_SMOKEGRENADE|1<<CSW_C4)
const SECONDARY_WEAPONS_BITSUM = (1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)|(1<<CSW_P228)|(1<<CSW_USP)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)

// Class Medic
new g_maxplayers

// Class Wiseman
new g_wiseman_uclip[33]
#if cellbits == 32
const OFFSET_CLIPAMMO = 51
#else
const OFFSET_CLIPAMMO = 65
#endif
const OFFSET_LINUX_WEAPONS = 4
new const MAXCLIP[] = { -1, 13, -1, 10, 1, 7, -1, 30, 30, 1, 30, 20, 25, 30, 35, 25, 12, 20,
			10, 30, 100, 8, 30, 30, 20, 2, 7, 30, 30, -1, 50 }


// Class Faster
#define	TASK_HPADD 13322

// Class Ravenous
new const g_szShockWaveSprite[]  =  "sprites/shockwave.spr";
new const g_szExplodeSound2[]  =  "ambience/particle_suck1.wav";
new const g_szExplodeSound[]  =  "warcraft3/frostnova.wav";
new gCvarExCoolDown, Float:g_cexCooldown[33]

// Class Mutant
new bool:g_mutant[33]

// Class Magician
new SPR_TRAIL, SPR_BEAM
#define	ENTANGLE_TIME		3.0
#define	TASK_RESETSPEED		512
#define TASK_SEARCHING		1738
#define	TASK_ENTANGLEWAIT	928
#define SOUND_ENTANGLING	"zombie_crown/humans/entanglingrootstarget1.wav"						
new IsStunned[33], Float:LastSpeed[33], entangle_can[33], Float:g_cenCooldown[33], gCvarEnCoolDown

// Class Arnodelo
new const g_szGlassGibsModel[] =  "models/glassgibs.mdl";	
new const g_szFreezeSound[] =  "warcraft3/impalehit.wav";	
new const g_szBreakSound[] =  "warcraft3/impalelaunch1.wav";
new gCvarFrCoolDown, gCvarDuration;
new Float:g_cfrCooldown[33], gShockWaveSprite, gGlassGibsModel, bool:gbIsFrosted[33]

public plugin_init()
{
	// Class Brizsat
	register_forward(FM_PlayerPreThink, "FW_playerprethink")

	// Class Lightsaber
	register_event("DeathMsg", "DeathMsg", "a")

	// Class Sharpshooter
	new weapon_name[24]
	for (new i = 1; i <= 30; i++)
	{
		if (!(WEAPONS_BITSUM & 1 << i) && get_weaponname(i, weapon_name, 23))
		{
			RegisterHam(Ham_Weapon_PrimaryAttack, weapon_name, "fw_Weapon_PrimaryAttack_Pre")
			RegisterHam(Ham_Weapon_PrimaryAttack, weapon_name, "fw_Weapon_PrimaryAttack_Post", 1)
		}
	}

	// Class Samurai // 11
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "fw_Knife_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "fw_Knife_SecondaryAttack_Post", 1)
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Pre")	

	// Class Medic
	register_event("HLTV", "NewRound", "a", "1=0", "2=0")
	g_maxplayers = get_maxplayers()

	// Class Wiseman
	register_message(get_user_msgid("CurWeapon"), "message_cur_weapon")

	// Class Man of Dispair
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")

	// Class Magician
	gCvarEnCoolDown = register_cvar("zp_entangle_cooldown", "35")
	register_clcmd("radio3", "ulteng")

	// Class Ravenous & 21
	register_clcmd("radio3", "ultexplode")
	register_clcmd("radio3", "ultfrost")
	register_event("ResetHUD",  "event_ResetHud", "be");
	gCvarFrCoolDown = register_cvar("zp_frost_cooldown", "35");
	gCvarExCoolDown = register_cvar("zp_explode_cooldown", "30");
	gCvarDuration = register_cvar("zp_frost_duration", "3");
	set_msg_block(get_user_msgid("ClCorpse"), BLOCK_SET);
}

public plugin_precache()
{
	new registerText[32]
	formatex(registerText, sizeof registerText - 1, "[ZC Humans]")
	register_plugin(registerText, "1.0", "meNe")

	// Class Retros
	zp_register_human_class(hclass_name_retros, hclass_info_retros, hclass_model_retros, hclass_health_retros , hclass_speed_retros, hclass_gravity_retros, hclass_level_retros)

	// Class Poratri
	zp_register_human_class(hclass_name_poratri, hclass_info_poratri, hclass_model_poratri, hclass_health_poratri , hclass_speed_poratri, hclass_gravity_poratri, hclass_level_poratri)

	// Class Lemow
	zp_register_human_class(hclass_name_lemow, hclass_info_lemow, hclass_model_lemow, hclass_health_lemow , hclass_speed_lemow, hclass_gravity_lemow, hclass_level_lemow)

	// Class Iceman
	g_hclassid_iceman = zp_register_human_class(hclass_name_iceman, hclass_info_iceman, hclass_model_iceman, hclass_health_iceman, hclass_speed_iceman, hclass_gravity_iceman, hclass_level_iceman)

	// Class Lightsaber
	sprite = precache_model("sprites/white.spr")
	g_hclassid_lsaber = zp_register_human_class(hclass_name_lsaber, hclass_info_lsaber, hclass_model_lsaber, hclass_health_lsaber, hclass_speed_lsaber, hclass_gravity_lsaber, hclass_level_lsaber)

	// Class Spectral
	g_hclassid_spectral = zp_register_human_class(hclass_name_spectral, hclass_info_spectral, hclass_model_spectral, hclass_health_spectral, hclass_speed_spectral, hclass_gravity_spectral, hclass_level_spectral)

	// Class Visioner
	g_hclassid_visioner = zp_register_human_class(hclass_name_visioner, hclass_info_visioner, hclass_model_visioner, hclass_health_visioner, hclass_speed_visioner, hclass_gravity_visioner, hclass_level_visioner)

	// Class Wiked One
	g_hclassid_wicked = zp_register_human_class(hclass_name_wicked, hclass_info_wicked, hclass_model_wicked, hclass_health_wicked, hclass_speed_wicked, hclass_gravity_wicked, hclass_level_wicked)

	// Class Brizsat
	g_hclassid_briz = zp_register_human_class(hclass_name_briz, hclass_info_briz, hclass_model_briz, hclass_health_briz, hclass_speed_briz, hclass_gravity_briz, hclass_level_briz)

	// Class Samurai
	g_hclassid_samurai = zp_register_human_class(hclass_name_samurai, hclass_info_samurai, hclass_model_samurai, hclass_health_samurai, hclass_speed_samurai, hclass_gravity_samurai, hclass_level_samurai)

	// Class Armorer
	g_hclassid_armorer = zp_register_human_class(hclass_name_armorer, hclass_info_armorer, hclass_model_armorer, hclass_health_armorer, hclass_speed_armorer, hclass_gravity_armorer, hclass_level_armorer)
		
	// Class Sharpshooter
	g_hclassid_sharp = zp_register_human_class(hclass_name_sharp, hclass_info_sharp, hclass_model_sharp, hclass_health_sharp, hclass_speed_sharp, hclass_gravity_sharp, hclass_level_sharp)

	// Class Runner
	zp_register_human_class(hclass_name_runner, hclass_info_runner, hclass_model_runner, hclass_health_runner, hclass_speed_runner, hclass_gravity_runner, hclass_level_runner)

	// Class Man of Dispair 
	g_hclassid_manod = zp_register_human_class(hclass_name_manod, hclass_info_manod, hclass_model_manod, hclass_health_manod, hclass_speed_manod, hclass_gravity_manod, hclass_level_manod)

	// Class Medic
	g_hclassid_medic = zp_register_human_class(hclass_name_medic, hclass_info_medic, hclass_model_medic, hclass_health_medic, hclass_speed_medic, hclass_gravity_medic, hclass_level_medic)

	// Class Wiseman
	g_hclassid_wiseman = zp_register_human_class(hclass_name_wiseman, hclass_info_wiseman, hclass_model_wiseman, hclass_health_wiseman, hclass_speed_wiseman, hclass_gravity_wiseman, hclass_level_wiseman)

	// Class Robber
	g_hclassid_robber = zp_register_human_class(hclass_name_robber, hclass_info_robber, hclass_model_robber, hclass_health_robber, hclass_speed_robber, hclass_gravity_robber, hclass_level_robber)

	// Class Jack
	g_hclassid_jack = zp_register_human_class(hclass_name_jack, hclass_info_jack, hclass_model_jack, hclass_health_jack, hclass_speed_jack, hclass_gravity_jack, hclass_level_jack)

	// Class Faster
	g_hclassid_faster = zp_register_human_class(hclass_name_faster, hclass_info_faster, hclass_model_faster, hclass_health_faster, hclass_speed_faster, hclass_gravity_faster, hclass_level_faster)

	// Class Ravenous
	g_hclassid_ravenous = zp_register_human_class(hclass_name_ravenous, hclass_info_ravenous, hclass_model_ravenous, hclass_health_ravenous, hclass_speed_ravenous, hclass_gravity_ravenous, hclass_level_ravenous)
	gShockWaveSprite = precache_model(g_szShockWaveSprite);
	precache_sound(g_szExplodeSound);
	precache_sound(g_szExplodeSound2);

	// Class Mutant
	g_hclassid_mutant = zp_register_human_class(hclass_name_mutant, hclass_info_mutant, hclass_model_mutant, hclass_health_mutant, hclass_speed_mutant, hclass_gravity_mutant, hclass_level_mutant)

	// Class Survivor
	g_hclassid_survivor = zp_register_human_class(hclass_name_survivor, hclass_info_survivor, hclass_model_survivor, hclass_health_survivor, hclass_speed_survivor, hclass_gravity_survivor, hclass_level_survivor)

	// Class Magician
	g_hclassid_magician = zp_register_human_class(hclass_name_magician, hclass_info_magician, hclass_model_magician, hclass_health_magician, hclass_speed_magician, hclass_gravity_magician, hclass_level_magician)
	SPR_TRAIL = precache_model("sprites/smoke.spr");
	SPR_BEAM = precache_model("sprites/ef_shockwave.spr");
	precache_sound(SOUND_ENTANGLING)

	// Class Leucocyt
	g_hclassid_leucocyt = zp_register_human_class(hclass_name_leucocyt, hclass_info_leucocyt, hclass_model_leucocyt, hclass_health_leucocyt, hclass_speed_leucocyt, hclass_gravity_leucocyt, hclass_level_leucocyt)

	// Class Arnodelo
	g_hclassid_arnodelo = zp_register_human_class(hclass_name_arnodelo, hclass_info_arnodelo, hclass_model_arnodelo, hclass_health_arnodelo, hclass_speed_arnodelo, hclass_gravity_arnodelo, hclass_level_arnodelo)
	gGlassGibsModel = precache_model(g_szGlassGibsModel);
	precache_sound(g_szFreezeSound);
	precache_sound(g_szBreakSound);

	// Class Trix
	g_hclassid_trix = zp_register_human_class(hclass_name_trix, hclass_info_trix, hclass_model_trix, hclass_health_trix, hclass_speed_trix, hclass_gravity_trix, hclass_level_trix)

	// Class Zolo
	g_hclassid_zolo = zp_register_human_class(hclass_name_zolo, hclass_info_zolo, hclass_model_zolo, hclass_health_zolo, hclass_speed_zolo, hclass_gravity_zolo, hclass_level_zolo)

}

public client_putinserver(id)
{
	// Class Faster
	set_task(300.0, "HPointsAdd", id+TASK_HPADD,_,_, "b")

	// Class Arnodelo
	if(is_user_connected(id))
	{
		gbIsFrosted[id] = false;
	}
}

public client_disconnect(id)
{
	// Class Faster
	remove_task(id+TASK_HPADD)

	// Class Arnodelo
	gbIsFrosted[id] = false;
}

public zp_user_infected_post(id, infector)
{
	if (zp_get_user_human_class(id) == g_hclassid_briz)
	{
		g_leap[id] = false
	}

	if(zp_get_user_human_class(id) == g_hclassid_wicked && g_mad[id] == true)
	{
		set_user_godmode(id, 1)
		set_task(5.0, "remove_mad", id)
	}

	if (zp_get_user_human_class(id) == g_hclassid_lsaber)
	{
		g_laser[id] = false
	}

	if (zp_get_user_human_class(id) == g_hclassid_spectral && is_user_alive(id))
	{
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 255)
	}

	if (zp_get_user_human_class(id) == g_hclassid_sharp)
	{
		g_norecoil[id] = false
	}

	if (zp_get_user_human_class(id) == g_hclassid_samurai)
	{
		g_samurai[id] = false
	}

	if (zp_get_user_human_class(id) == g_hclassid_medic && !zp_is_hero_round())
	{
		if(g_medic[id] == true)
		{
			if(g_used[id] == false)
			{
				set_task(10.0, "disinfect", id)
			}
		}
	}	

	if (zp_get_user_human_class(id) == g_hclassid_wiseman)
	{
		g_wiseman_uclip[id] = false
	}

	if (zp_get_user_human_class(id) == g_hclassid_mutant && !zp_is_hero_round())
	{
		if(g_mutant[id] == true)
		{
			nemesize(id)
		}
	}
}

public zp_hclass_param(id)
{
	// Remove automatically
	if(g_laser[id]) g_laser[id] = false

	if (zp_get_user_human_class(id) == g_hclassid_briz)
	{
		g_leap[id] = true
	}

	if (zp_get_user_human_class(id) == g_hclassid_spectral)
	{
		if (zp_get_human_hero(id) && is_user_alive(id))
    		{
        		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 255)
    		}else {
			set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 127)
		}
	}

	if (zp_get_user_human_class(id) == g_hclassid_visioner)
	{
		if (!zp_get_user_nightvision(id))
			zp_set_user_nightvision(id, 1)

		colored_print(id, GREEN, "[ZC]^x01 You've got free^x04 NightVision^x01. Press^x03 N^x01 to^x04 switch on/off^x01 it.")
	}

	if (zp_get_user_human_class(id) == g_hclassid_lsaber)
	{
		g_laser[id] = true
	}

	if (zp_get_user_human_class(id) == g_hclassid_sharp)
	{
		g_norecoil[id] = true
	}

	if (zp_get_user_human_class(id) == g_hclassid_samurai)
	{
    		if (zp_get_human_hero(id))
    		{
        		g_samurai[id] = false
    		}else {
			g_samurai[id] = true
		}
	}

	if (zp_get_user_human_class(id) == g_hclassid_armorer)
	{
		set_task(1.0, "armhl", id)
	}

	if (zp_get_user_human_class(id) == g_hclassid_iceman)
	{
		set_task(2.0, "iceman_get", id)
	}

	if (zp_get_user_human_class(id) == g_hclassid_medic)
	{
		if(!g_medic[id]) {
			g_medic[id] = true
		}
	}

	if (zp_get_user_human_class(id) == g_hclassid_wiseman && !zp_get_human_hero(id))
	{
		zp_set_user_blockbuy(id)
		set_task(0.3, "giveweapons_wiseman", id)
	}

	if (zp_get_user_human_class(id) == g_hclassid_jack && !zp_get_human_hero(id))
	{
		zp_set_user_blockbuy(id)
		set_task(0.3, "giveweapons_jack", id)
	}	

	if (zp_get_user_human_class(id) == g_hclassid_mutant)
	{
		if(!g_mutant[id]) {
			g_mutant[id] = true
		}
	}

	if (zp_get_user_human_class(id) == g_hclassid_leucocyt)
	{
		zp_force_buy_extra_item(id, zp_get_extra_item_id("Gas-Mask"), 1)
	}
}

public FW_playerprethink(id)
{	
	// Class Poratri
	if(zp_get_user_human_class(id) == g_hclassid_briz && !(zv_get_user_flags(id) & ZV_MULTI))
	{
		if(can_leap(id) && g_leap[id] == true)
		{
			static Float:velocity[3]
			velocity_by_aim(id, 570, velocity)
			velocity[2] = 475.00
			set_pev(id, pev_velocity, velocity)
			g_lastLeaptime[id] = get_gametime()
		}
	}

	// Class Lightsaber
	if(g_laser[id] == true)
	{
		new e[3]
		get_user_origin(id, e, 3)
		message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte (TE_BEAMENTPOINT)
		write_short(id | 0x1000)
		write_coord (e[0])			
		write_coord (e[1])			
		write_coord (e[2])			

		write_short(sprite)			
		
		write_byte (1)      						
		write_byte (10)     								
		write_byte (1)				
		write_byte (5)   						
		write_byte (0)    			
		write_byte (255) 			
		write_byte (0)				
		write_byte (0)				
		write_byte (150)     							
		write_byte (25)      				
		message_end()
	}

	// Class Medic
	if(zp_get_user_human_class(id) == g_hclassid_magician) 
	{
		new Target, Body;
		get_user_aiming(id, Target, Body, 9999999);
		
		// Entangle Power
		if(is_user_alive(Target) && !zp_get_user_first_zombie(Target) && is_user_alive(id) && zp_has_round_started() && !zp_get_zombie_hero(Target) && !zp_get_human_hero(Target)) 
		{
			if(entangle_can[id] && !IsStunned[Target]) 
			{
				if(zp_get_user_zombie(id) && zp_get_user_zombie(Target))
				{
					return 0;
				}

				if(!zp_get_user_zombie(id) && !zp_get_user_zombie(Target))
				{
					return 0;
				}
				Ultimate_Entangle(id, Target)
				entangle_can[id] = false
			}
		}
	}

	if(is_user_alive(id) && IsStunned[id])
	{
		set_pev(id, pev_maxspeed, 1.0);
		set_pev(id, pev_velocity, Float:{0.0,0.0,0.0})
	}

	// Class Robber
	if(gbIsFrosted[id])
	{
		set_pev(id,  pev_velocity, Float:{0.0,0.0,0.0})	
		set_pev(id,  pev_flags, pev(id, pev_flags) | FL_FROZEN)
	}
	return PLUGIN_CONTINUE
}

can_leap(id)
{
	static buttons
	buttons = pev(id, pev_button)
	if (!(pev(id, pev_flags) & FL_ONGROUND) || fm_get_speed(id) < 20 || !(buttons & IN_JUMP) || !(buttons & IN_DUCK))
		return false
	if (get_gametime() - g_lastLeaptime[id] < 3.0)
		return false
	return true
}


// Class Lemow
public zp_round_ended(team)
{
	if(team == WIN_NO_ONE || team == WIN_HUMANS || team == WIN_ZOMBIES) {
		for (new id = 1; id <= g_maxplayers; id++) {
			if (zp_get_user_human_class(id) == g_hclassid_spectral && is_user_alive(id)) {
				set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 255)
			}
		}
	}
}

// Class Brizsat
public fw_Weapon_PrimaryAttack_Post(entity)
{
	new id = pev(entity, pev_owner)
	if (g_norecoil[id] == true && zp_get_user_human_class(id) == g_hclassid_sharp)
	{
		new Float: push[3]
		pev(id, pev_punchangle, push)
		xs_vec_sub(push, cl_pushangle[id], push)
		xs_vec_mul_scalar(push, 0.0, push)
		xs_vec_add(push, cl_pushangle[id], push)
		set_pev(id, pev_punchangle, push)
		return HAM_IGNORED;
	}
	return HAM_IGNORED;
}

public fw_Weapon_PrimaryAttack_Pre(entity)
{
	new id = pev(entity, pev_owner)
	if (g_norecoil[id] == true && zp_get_user_human_class(id) == g_hclassid_sharp)
	{
		pev(id, pev_punchangle, cl_pushangle[id])
		return HAM_IGNORED;
	}
	return HAM_IGNORED;
}

// Class Wicked One
public remove_mad(id)
{
	set_user_godmode(id, 0)
}

// Class Lightsaber
public DeathMsg()
{
	new id = read_data(2)
	g_laser[id] = false
}

// Class Spectral
public fw_Knife_PrimaryAttack_Post(knife)
{
	static id
	if(!pev_valid(knife))
        	return HAM_IGNORED;

	id = get_pdata_cbase(knife, m_pPlayer, 4)
	if(g_samurai[id] && zp_get_user_human_class(id) == g_hclassid_samurai && !zp_get_user_zombie(id))
	{
		static Float:flRate
		flRate = 0.1
		
		set_pdata_float(knife, m_flNextPrimaryAttack, flRate, 4)
		set_pdata_float(knife, m_flNextSecondaryAttack, flRate, 4)
		set_pdata_float(knife, m_flTimeWeaponIdle, flRate, 4)		
	}
	return HAM_IGNORED
}

public fw_Knife_SecondaryAttack_Post(knife)
{
	static id
	if(!pev_valid(knife))
        	return HAM_IGNORED;
	id = get_pdata_cbase(knife, m_pPlayer, 4)

	if(g_samurai[id] && zp_get_user_human_class(id) == g_hclassid_samurai && !zp_get_user_zombie(id))
	{
		static Float:flRate
		flRate = 0.3
		set_pdata_float(knife, m_flNextPrimaryAttack, flRate, 4)
		set_pdata_float(knife, m_flNextSecondaryAttack, flRate, 4)
		set_pdata_float(knife, m_flTimeWeaponIdle, flRate, 4)
	}
	return HAM_IGNORED
}

public fw_TakeDamage_Pre(victim, inflictor, attacker, Float:damage, damage_type)
{ 
    	if(!is_user_connected(attacker) || !is_user_connected(victim))
        	return HAM_IGNORED
        
	// Class Spectral
    	if(get_user_weapon(attacker) == CSW_KNIFE && zp_get_user_human_class(attacker) == g_hclassid_samurai && !zp_get_user_zombie(attacker))
    	{
        	SetHamParamFloat(4, damage * 2.0)
    	}

	// Class Samurai
    	if(zp_get_user_human_class(attacker) == g_hclassid_manod && !zp_get_user_zombie(attacker) && !zp_get_human_hero(attacker))
    	{
        	SetHamParamFloat(4, damage * 1.5)
    	}
    	return HAM_IGNORED
}

// Class Visioner
public armhl(id)
{
	if(is_user_alive(id))
	{
		set_user_armor(id, get_user_armor(id) + 500)
	}
}

// Class Armorer
public disinfect(id)
{
	zp_disinfect_user(id)
	g_used[id] = true
}

public NewRound()
{
	for (new id = 1; id <= g_maxplayers; id++)
	{
		if (zp_get_user_human_class(id) == g_hclassid_medic && g_used[id])
		{
			g_used[id] = false
		}
		
		// Class Ravenous
		if(entangle_can[id])
			entangle_can[id] = false
	}	
}

// Class Iceman
public iceman_get(id)
{
	if (zp_get_user_human_class(id) == g_hclassid_iceman && is_user_alive(id) && is_user_connected(id))
	{
		give_item(id, "weapon_flashbang")
		cs_set_user_bpammo(id, CSW_FLASHBANG, 5)
	}
}

// Class Wiseman
public giveweapons_wiseman(id)
{
	if (zp_get_user_human_class(id) == g_hclassid_wiseman && is_user_alive(id) && is_user_connected(id))
	{
		show_menu(id, 0, "\n", 1);
		drop_weapons(id, 1)
		g_wiseman_uclip[id] = true
		give_item(id, "weapon_xm1014")
		cs_set_user_bpammo(id, CSW_XM1014, 120)
		give_item(id, "weapon_hegrenade")
		cs_set_user_bpammo(id, CSW_HEGRENADE, 1)
		give_item(id, "weapon_smokegrenade")
		cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 1)
		give_item(id, "weapon_flashbang")
		cs_set_user_bpammo(id, CSW_FLASHBANG, 1)
	}
}

public message_cur_weapon(msg_id, msg_dest, msg_entity)
{
	if (zp_get_user_human_class(msg_entity) == g_hclassid_wiseman)
	{
		if (!g_wiseman_uclip[msg_entity])
			return;

		if (!is_user_alive(msg_entity) || get_msg_arg_int(1) != 1)
			return;
		
		static weapon, clip
		weapon = get_msg_arg_int(2) 
		clip = get_msg_arg_int(3) 
		if (MAXCLIP[weapon] > 2)
		{
			set_msg_arg_int(3, get_msg_argtype(3), MAXCLIP[weapon])
			if (clip < 2)
			{
				static wname[32], weapon_ent
				get_weaponname(weapon, wname, sizeof wname - 1)
				weapon_ent = fm_find_ent_by_owner(-1, wname, msg_entity)
				fm_set_weapon_ammo(weapon_ent, MAXCLIP[weapon])
			}
		}
	}
}

stock fm_set_weapon_ammo(entity, amount)
{
	set_pdata_int(entity, OFFSET_CLIPAMMO, amount, OFFSET_LINUX_WEAPONS);
}

// Class Man of Dispair
public fw_PlayerKilled(victim, attacker, shouldgib)
{
	static sk;
	sk = (victim == attacker || is_user_connected(attacker)) ? true : false
	if (sk)
	{
		if(!is_user_alive(attacker))
			return HAM_IGNORED;
	
		// Class Man of Dispair
		if (zp_get_user_human_class(attacker) == g_hclassid_robber && !zp_get_user_zombie(attacker) && !zp_get_zombie_hero(attacker))
		{
			zp_set_user_ammo_packs(attacker, zp_get_user_ammo_packs(attacker) + 50)
		}

		// Class Trix
		if (zp_get_user_human_class(attacker) == g_hclassid_trix && !zp_get_user_zombie(attacker) && !zp_get_zombie_hero(attacker))
		{
			zp_set_user_xp(attacker, zp_get_user_xp(attacker) + 3)
		}

		// Class Zolo
		if (zp_get_user_human_class(attacker) == g_hclassid_zolo && !zp_get_user_zombie(attacker) && !zp_get_zombie_hero(attacker))
		{
			zp_set_user_coins(attacker, zp_get_user_coins(attacker) + 2)
		}
	}
	return HAM_IGNORED
}

// Class Jack
public giveweapons_jack(id)
{
	if (zp_get_user_human_class(id) == g_hclassid_jack && is_user_alive(id) && is_user_connected(id))
	{
		show_menu(id, 0, "\n", 1);
		drop_weapons(id, 1)
		give_item(id, "weapon_hegrenade")
		cs_set_user_bpammo(id, CSW_HEGRENADE, 1)
		give_item(id, "weapon_smokegrenade")
		cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 1)
		give_item(id, "weapon_flashbang")
		cs_set_user_bpammo(id, CSW_FLASHBANG, 1)
        //give_AK47diamond(player)
	}
}

// Class Faster
public HPointsAdd(id)
{ 
	id -= TASK_HPADD
	if (zp_get_user_human_class(id) == g_hclassid_faster && is_user_connected(id))
	{
		if(get_user_team(id) == 1 || get_user_team(id) == 2) 
			zp_set_user_points(id, zp_get_user_points(id) + 1)
	}
}

// Class Ravenous
public ulteng(id)
{	
	if(is_user_alive(id) && !entangle_can[id] && zp_get_user_human_class(id) == g_hclassid_magician && !zp_get_user_zombie(id) && !zp_get_zombie_hero(id)) 
	{
		static Float: gametime ; gametime = get_gametime();
		if(gametime - float(get_pcvar_num(gCvarEnCoolDown)) > g_cenCooldown[id])
		{
			entangle_can[id] = true;
			colored_print(id, GREEN, "[ZC]^x01 Put^x04 your crosshair^x01 on a^x04 victim!")
			g_cenCooldown[id] = gametime
		}else{
			colored_print(id, GREEN, "[ZC]^x01 Your power will charge in:^x04 %.1f seconds !", float(get_pcvar_num(gCvarEnCoolDown)) - (gametime - g_cenCooldown[id]))
			return;
		}	
	}
}

public Ultimate_Entangle(Caster, Enemy) 
{
	new qRed, qGreen, qBlue
	if(get_user_team(Enemy) == 1)
		qRed = 0, qGreen = 0, qBlue = 200
	else
		qRed = 200, qGreen = 0, qBlue = 0
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW)
	write_short(Enemy)			// entity
	write_short(SPR_TRAIL)			// model
	write_byte(10)				// life
	write_byte(5)				// width
	write_byte(qRed)			// red
	write_byte(qGreen)			// green
	write_byte(qBlue)			// blue
	write_byte(200)				// brightness
	message_end()
	
	IsStunned[Enemy] = true;
	pev(Enemy, pev_maxspeed, LastSpeed[Enemy])
	set_pev(Enemy, pev_maxspeed, 1.0);
	set_pev(Enemy, pev_movetype, MOVETYPE_NONE);
	
	new parm[4];
	parm[0] = Enemy;
	parm[1] = 0;
	parm[2] = 0;
	parm[3] = 0;
	EntangleWait(parm);
}

public EntangleWait(parm[4]) 
{
	new id = parm[0];
	
	if(id >= TASK_ENTANGLEWAIT)
		id -= TASK_ENTANGLEWAIT;
	
	if(is_user_connected(id)) {	
		new Origin[3];
		get_user_origin(id, Origin);
		
		if(Origin[0] == parm[1] && Origin[1] == parm[2] && Origin[2] == parm[3] && (pev(id, pev_flags))) {
			set_task(ENTANGLE_TIME, "Entangle_ResetMaxSpeed", TASK_RESETSPEED + id);
			EntangleEffect(id)
		}
		else {
			parm[1] = Origin[0];
			parm[2] = Origin[1];
			parm[3] = Origin[2];
			set_task(0.001, "EntangleWait", TASK_ENTANGLEWAIT + id, parm, 4);
		}
	}
}

public EntangleEffect(id) 
{
	new Origin[3];
	get_user_origin(id, Origin);
	
	emit_sound(id, CHAN_STATIC, SOUND_ENTANGLING, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	new Start[3], End[3], Height;
	new Radius = 20, Counter = 0;
	new x1, y1, x2, y2;
	
	while(Counter <= 7) {
		if(Counter == 0 || Counter == 8)
			x1 = -Radius;
		else if(Counter == 1 || Counter == 7)
			x1 = -Radius * 100/141;
		else if(Counter == 2 || Counter == 6)
			x1 = 0;
		else if(Counter == 3 || Counter == 5)
			x1 = Radius*100/141
		else if(Counter == 4)
			x1 = Radius
		
		if(Counter <= 4)
			y1 = sqroot(Radius*Radius-x1*x1);
		else
			y1 = -sqroot(Radius*Radius-x1*x1);
		
		++Counter;
		
		if(Counter == 0 || Counter == 8)
			x2 = -Radius;
		else if(Counter == 1 || Counter==7)
			x2 = -Radius*100/141;
		else if(Counter == 2 || Counter==6)
			x2 = 0;
		else if(Counter == 3 || Counter==5)
			x2 = Radius*100/141;
		else if(Counter == 4)
			x2 = Radius;
		
		if(Counter <= 4)
			y2 = sqroot(Radius*Radius-x2*x2);
		else
			y2 = -sqroot(Radius*Radius-x2*x2);
		
		Height = 16 + 2 * Counter;
		
		while(Height > -40) 
		{
			Start[0]	= Origin[0] + (x1 * 2);
			Start[1]	= Origin[1] + (y1 * 2);
			Start[2]	= Origin[2] + (Height * 2);
			End[0]		= Origin[0] + (x2 * 2);
			End[1]		= Origin[1] + (y2 * 2);
			End[2]		= Origin[2] + (Height * 2);
			
			new qRed, qGreen, qBlue
			if(get_user_team(id) == 1)
				qRed = 0, qGreen = 0, qBlue = 200
			else
				qRed = 200, qGreen = 0, qBlue = 0
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_BEAMPOINTS)
			write_coord(Start[0])
			write_coord(Start[1])
			write_coord(Start[2])
			write_coord(End[0])
			write_coord(End[1])
			write_coord(End[2])
			write_short(SPR_BEAM)				// model
			write_byte(0)					// start frame
			write_byte(0)					// framerate
			write_byte((floatround(ENTANGLE_TIME) * 10));	// life
			write_byte(30)					// width
			write_byte(15)					// noise
			write_byte(qRed)				// red
			write_byte(qGreen)				// green
			write_byte(qBlue)				// blue
			write_byte(200)					// brightness
			write_byte(0)					// speed
			message_end()
			
			Height -= 16;
		}
	}
}

public Entangle_ResetMaxSpeed(id) {
	if(id >= TASK_RESETSPEED)
		id -= TASK_RESETSPEED;
	
	task_exists(TASK_ENTANGLEWAIT + id) ? remove_task(TASK_ENTANGLEWAIT + id) : 0;
	IsStunned[id] = false;
	if(is_user_alive(id))
		set_pev(id, pev_maxspeed, LastSpeed[id]);
}

// Class Mutant
public nemesize(id)
{
	zp_make_user_nemesis(id)
	set_task(10.0, "make_zomb", id)
}

public make_zomb(id)
{
	if(zp_get_user_nemesis(id))
	{
		zp_infect_user(id)
	}
	g_mutant[id] = false
}

// Class Survivor
public zp_user_last_human(id)
{
	if(zp_get_user_human_class(id) == g_hclassid_survivor && !zp_is_hero_round())
	{
		set_task(1.0, "survivorize", id)
	}
}

public survivorize(id)
{
	zp_make_user_survivor(id)
	set_task(0.2, "assign", id)
}

public assign(id)
{
	set_user_health(id, 1000)
	set_user_armor(id, 100)	
}

// Class Magician
public ultexplode(id)
{	
	if(zp_has_round_started() && is_user_alive(id) && zp_get_user_human_class(id) == g_hclassid_ravenous && !zp_get_user_zombie(id)) 
	{
		static Float: gametime ; gametime = get_gametime();
		if(gametime - float(get_pcvar_num(gCvarExCoolDown)) > g_cexCooldown[id])
		{
			new Float:fOrigin[3], iOrigin[3];
			pev(id, pev_origin, fOrigin);
			FVecIVec(fOrigin, iOrigin);
			CreateBlast(42, 170, 255, iOrigin);
			emit_sound(id, CHAN_WEAPON,  g_szExplodeSound2, 1.0, ATTN_NORM, 0, PITCH_NORM);	
			ExplodeAndDamageNearPlayers(id, fOrigin);
			colored_print(id,  GREEN, "[ZC]^x01 The explosion was felt by victims around you!");	
			g_cexCooldown[id] = gametime;
		}else{
			colored_print(id, GREEN, "[ZC]^x01 Your power will charge in:^x04 %.1f seconds !", float(get_pcvar_num(gCvarExCoolDown)) - (gametime - g_cexCooldown[id]))
			return;
		}	
	}
}

public ExplodeAndDamageNearPlayers(id, const Float:fOrigin[ 3 ])
{
	static iVictim;
	iVictim = -1;
	
	while((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, fOrigin, 300.0)) != 0) 
	{
		if(!is_user_alive(iVictim))
			continue;
			
		if(cs_get_user_team(id) == cs_get_user_team(iVictim))
			continue;

		if(!zp_get_zombie_hero(iVictim) && !zp_get_human_hero(iVictim))
		{
			if(zp_get_user_zombie(iVictim)) {
				new Float:Damage
				static ent_kill
				Damage = random_float(700.0, 2900.0)
				ent_kill = fm_get_user_weapon_entity(id, CSW_KNIFE)
				ExecuteHam(Ham_TakeDamage, iVictim, ent_kill, id, Damage, DMG_FREEZE)
			}
			if(is_user_alive(iVictim))
			{
				ShakeScreen(iVictim, 5.5);
				FadeScreen(iVictim, 3.0, 42, 170, 255, 100);
			}
		}
	}
}

// Class Arnodelo
public ultfrost(id)
{	
	if(zp_has_round_started() && is_user_alive(id) && zp_get_user_human_class(id) == g_hclassid_arnodelo && !zp_get_user_zombie(id)) 
	{
		static Float: gametime ; gametime = get_gametime();
		if(gametime - float(get_pcvar_num(gCvarFrCoolDown)) > g_cfrCooldown[id])
		{
			new Float:fOrigin[3], iOrigin[3];
			pev(id, pev_origin, fOrigin);
			FVecIVec(fOrigin, iOrigin);
			CreateBlast(255, 25, 25, iOrigin);
			emit_sound(id, CHAN_WEAPON,  g_szExplodeSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
			FreezeNearPlayers(id, fOrigin);
			g_cfrCooldown[id] = gametime;
		}else{
			colored_print(id, GREEN, "[ZC]^x01 Your power will charge in:^x04 %.1f seconds !", float(get_pcvar_num(gCvarFrCoolDown)) - (gametime - g_cfrCooldown[id]))
			return;
		}	
	}
}

public event_ResetHud(id) 
{
	event_PlayerSpawn(id);
}

public event_PlayerSpawn(id) 
{
	if(gbIsFrosted[id]) 
		RemovePlayerFrost(id);
}

public evDeathMsg()
{
	new id = read_data(2);
	if(gbIsFrosted[id]) {
		RemovePlayerFrost(id)
	}	
}

public FreezeNearPlayers(id, const Float:fOrigin[3])
{
	static iVictim;
	iVictim = -1;
	
	while((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, fOrigin, 300.0)) != 0) 
	{
		if(!is_user_alive(iVictim) || gbIsFrosted[iVictim])
			continue;	
		
		if(cs_get_user_team(id) == cs_get_user_team(iVictim))
			continue;

		if(!zp_get_zombie_hero(iVictim) && !zp_get_human_hero(iVictim))
		{
			if(zp_get_user_zombie(iVictim)) {
				new Float:Damage
				static ent_kill
				Damage = random_float(700.0, 2900.0)
				ent_kill = fm_get_user_weapon_entity(id, CSW_KNIFE)
				ExecuteHam(Ham_TakeDamage, iVictim, ent_kill, id, Damage, DMG_FREEZE)
			}
			if(is_user_alive(iVictim))
			{
				ShakeScreen(iVictim, 5.5);
				set_rendering(iVictim, kRenderFxGlowShell,  255, 25, 25, kRenderNormal, 25);
				emit_sound(iVictim, CHAN_WEAPON, g_szFreezeSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
				message_begin(MSG_ONE, get_user_msgid("ScreenFade"), _, iVictim);
				write_short(~0); 	// duration
				write_short(~0); 	// hold time
				write_short(0x0004); 	// flags: FFADE_STAYOUT
				write_byte(255);	// r
				write_byte(25);		// g
				write_byte(25);		// b
				write_byte(100); 	// alpha
				message_end();
				gbIsFrosted[iVictim] = true;	
				set_task(get_pcvar_float(gCvarDuration), "RemovePlayerFrost", iVictim);
			}
		}
	}
}

public RemovePlayerFrost(id) 
{
	if(!gbIsFrosted[id])
		return	

	// unfreeze
	gbIsFrosted[id] = false;
	set_pev(id, pev_flags, pev(id, pev_flags) & ~FL_FROZEN);
	
	emit_sound(id, CHAN_WEAPON, g_szBreakSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
	set_rendering(id);
	
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"), _, id);
	write_short(0); // duration
	write_short(0); // hold time
	write_short(0); // flags
	write_byte(0); // Redx
	write_byte(0); // green
	write_byte(0); // Bluex
	write_byte(0); // alpha
	message_end();
	
	static iOrigin[3], Float:fOrigin[ 3 ];
	entity_get_vector(id, EV_VEC_origin, fOrigin);
	FVecIVec(fOrigin, iOrigin);

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BREAKMODEL);
	write_coord(iOrigin[ 0 ]);		// x
	write_coord(iOrigin[ 1 ]);		// y
	write_coord(iOrigin[ 2 ] + 24);	// z
	write_coord(16);		// size x
	write_coord(16);		// size y
	write_coord(16);		// size z
	write_coord(random_num(-50, 50));// velocity x
	write_coord(random_num(-50, 50));// velocity y
	write_coord(25);		// velocity z
	write_byte(10);			// random velocity
	write_short(gGlassGibsModel);		// model
	write_byte(10);			// count
	write_byte(25);			// life
	write_byte(0x01);		// flags: BREAK_GLASS
	message_end();
}

// Stocks
stock drop_weapons(id, dropwhat)
{
     	static weapons[32], num, i, weaponid
     	num = 0
     	get_user_weapons(id, weapons, num)
     	
     	for (i = 0; i < num; i++)
     	{
          	weaponid = weapons[i]
          	if (dropwhat == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM))
          	{
               		static wname[32]
               		get_weaponname(weaponid, wname, sizeof wname - 1)
               		engclient_cmd(id, "drop", wname)
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

// Respawn after it;
public rspfreexp(id)
{
	if(!zp_is_hero_round())
	{
		zp_respawn_user(id , ZP_TEAM_ZOMBIE)
	}
}