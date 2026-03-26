#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <zombiecrown>
#include <xs>
#include <colored_print>

#define PLUGIN "[ZC SupplyBox]"
#define VERSION "1.1"
#define AUTHOR "Dias"

#define SUPPLYBOX_CLASSNAME "supplybox"
#define TASK_SUPPLYBOX 9998256
#define TASK_SUPPLYBOX2 888138266
#define TASK_SUPPLYBOX_HELP 877129257
#define TASK_SUPPLYBOX_WAIT 7641130259
const MAX_SUPPLYBOX_ENT = 100
new const supplybox_spawn_file[] = "%s/zombie_crown/zc_others/zc_supplybox/%s.cfg"
new const supplybox_item_file[] = "%s/zombie_crown/zc_others/zc_supplybox.ini"
new const supplybox_icon_spr[] = "sprites/zombie_crown/icon_supplybox.spr"
new const supplybox_model[][] = 
{
    "models/zombie_crown/zcz_bb1.mdl",
    "models/zombie_crown/zcz_bb2.mdl",
    "models/zombie_crown/zcz_bb3.mdl",
    "models/zombie_crown/zcz_bb4.mdl",
    "models/zombie_crown/zcz_bb5.mdl",
    "models/zombie_crown/zcz_bb6.mdl",
    "models/zombie_crown/zcz_bb7.mdl",
    "models/zombie_crown/zcz_bb8.mdl",
    "models/zombie_crown/zcz_bb9.mdl"
}
new const supplybox_drop_sound[][] = 
{
	"zombie_crown/zc_sound_supplydrop.wav"
}
new const supplybox_pickup_sound[][] = 
{
	"zombie_crown/zc_sound_supplypick.wav"
}



new g_supplybox_num, g_supplybox_wait[33], supplybox_count, Array:supplybox_item, 
supplybox_ent[MAX_SUPPLYBOX_ENT], g_supplybox_icon_id, Float:g_supplybox_spawn[MAX_SUPPLYBOX_ENT][3],g_total_supplybox_spawn
new cvar_supplybox_icon, cvar_supplybox_max, cvar_supplybox_num, cvar_supplybox_totalintime, 
cvar_supplybox_time, cvar_supplybox_delaytime, cvar_supplybox_icon_size, cvar_supplybox_icon_light
new bool:made_supplybox, Float:g_icon_delay[33], g_newround, g_endround

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("HLTV", "event_newround", "a", "1=0", "2=0")
	register_logevent("logevent_round_end", 2, "1=Round_End")

	register_forward(FM_Touch, "fw_supplybox_touch")


	cvar_supplybox_max = register_cvar("zp_supplybox_max", "16")
	cvar_supplybox_num = register_cvar("zp_supplybox_num", "2")
	cvar_supplybox_totalintime = register_cvar("zp_supplybox_totalintime", "4")
	cvar_supplybox_time = register_cvar("zp_supplybox_time", "20")
	cvar_supplybox_icon = register_cvar("zp_supplybox_icon", "1")
	cvar_supplybox_delaytime = register_cvar("zp_supplybox_icon_delay_time", "0.03")	
	cvar_supplybox_icon_size = register_cvar("zp_supplybox_icon_size", "1")
	cvar_supplybox_icon_light = register_cvar("zp_supplybox_icon_light", "100")
	set_task(2.0, "update_radar", _, _, _, "b")
}

public plugin_precache()
{
	supplybox_item = ArrayCreate(64, 1)
	load_supplybox_spawn()
	load_supplybox_item()
	
	static i
	for(i = 0; i < sizeof(supplybox_model); i++)
		engfunc(EngFunc_PrecacheModel, supplybox_model[i])
	for(i = 0; i < sizeof(supplybox_drop_sound); i++)
		engfunc(EngFunc_PrecacheSound, supplybox_drop_sound[i])		
	for(i = 0; i < sizeof(supplybox_pickup_sound); i++)
		engfunc(EngFunc_PrecacheSound, supplybox_pickup_sound[i])
	g_supplybox_icon_id = engfunc(EngFunc_PrecacheModel, supplybox_icon_spr)
}

public plugin_cfg()
{
	set_task(0.5, "event_newround")
}

public load_supplybox_spawn()
{
	// Check for spawns points of the current map
	new cfgdir[32], mapname[32], filepath[386], linedata[64]
	get_configsdir(cfgdir, charsmax(cfgdir))
	get_mapname(mapname, charsmax(mapname))
	formatex(filepath, charsmax(filepath), supplybox_spawn_file, cfgdir, mapname)
	
	// Load spawns points
	if (file_exists(filepath))
	{
		new file = fopen(filepath,"rt"), row[4][6]
		
		while (file && !feof(file))
		{
			fgets(file, linedata, charsmax(linedata))
			
			// invalid spawn
			if(!linedata[0] || str_count(linedata,' ') < 2) continue;
			
			// get spawn point data
			parse(linedata,row[0],5,row[1],5,row[2],5)
			
			// origin
			g_supplybox_spawn[g_total_supplybox_spawn][0] = floatstr(row[0])
			g_supplybox_spawn[g_total_supplybox_spawn][1] = floatstr(row[1])
			g_supplybox_spawn[g_total_supplybox_spawn][2] = floatstr(row[2])

			g_total_supplybox_spawn++
			if (g_total_supplybox_spawn >= MAX_SUPPLYBOX_ENT) 
				break
		}
		if (file) fclose(file)
	}
}

public load_supplybox_item() 
{
	new filepath[386]
	get_configsdir(filepath, charsmax(filepath))
	format(filepath, charsmax(filepath), supplybox_item_file, filepath)
	
	if (!file_exists(filepath))	
	{
		new error_msg[100]
		formatex(error_msg, charsmax(error_msg), "[ZC] Item File Not Found")
		set_fail_state(error_msg)
		return
	}
	
	new line[1024], key[64], value[960]
	new file = fopen(filepath, "rt")
	
	while (!feof(file) && file)
	{
		fgets(file, line, charsmax(line));
		replace(line, charsmax(line), "^n", "")
		
		if (!line[0] || line[0] == ';')
			continue
		
		strtok(line, key, charsmax(key), value, charsmax(value), '=')
		trim(key)
		trim(value)
		
		if (equali(key, "SUPPLYBOX_ITEM")) 
		{
			while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ',')) 
			{
				trim(key)
				trim(value)
				ArrayPushString(supplybox_item, key)
			}
		}
	}
}

public update_radar()
{	
	for (new id = 1; id <= get_maxplayers(); id++)
	{
		if (!is_user_alive(id) || !supplybox_count || zp_get_user_zombie(id)|| zp_get_human_hero(id)) 
			continue
		
		static i, next_ent
		i = 1
		while(i <= supplybox_count)
		{
			next_ent = supplybox_ent[i]
			if (next_ent && is_valid_ent(next_ent))
			{
				static Float:origin[3]
				pev(next_ent, pev_origin, origin)
				
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HostagePos"), {0,0,0}, id)
				write_byte(id)
				write_byte(i)		
				write_coord(floatround(origin[0]))
				write_coord(floatround(origin[1]))
				write_coord(floatround(origin[2]))
				message_end()
			
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HostageK"), {0,0,0}, id)
				write_byte(i)
				message_end()
			}

			i++
		}
	}
}

public event_newround()
{
	made_supplybox = false
	g_newround = 1
	g_endround = 0
	
	remove_supplybox()
	supplybox_count = 0
	
	if(task_exists(TASK_SUPPLYBOX)) remove_task(TASK_SUPPLYBOX)
	if(task_exists(TASK_SUPPLYBOX2)) remove_task(TASK_SUPPLYBOX2)
	if(task_exists(TASK_SUPPLYBOX_HELP)) remove_task(TASK_SUPPLYBOX_HELP)
}

public logevent_round_end() g_endround = 1

public zp_user_infected_post()
{
	if(!made_supplybox)
	{
		g_newround = 0
		made_supplybox = true
		
		if(task_exists(TASK_SUPPLYBOX)) remove_task(TASK_SUPPLYBOX)
		
		if(!g_total_supplybox_spawn)
		{
			client_print(0, print_console, "[ZC] Spawn Point Not Found. Please Create Spawn Point")
		} else {
			set_task(get_pcvar_float(cvar_supplybox_time), "create_supplybox", TASK_SUPPLYBOX)
		}
	}
}

public client_PostThink(id)
{
	if (!get_pcvar_num(cvar_supplybox_icon) || !is_user_alive(id) || zp_get_user_zombie(id) || zp_get_human_hero(id))
		return
	if((g_icon_delay[id] + get_pcvar_float(cvar_supplybox_delaytime)) > get_gametime())
		return
		
	g_icon_delay[id] = get_gametime()

	if (supplybox_count)
	{
		static i, box_ent
		i = 1
		
		while (i <= supplybox_count)
		{
			box_ent = supplybox_ent[i]
			create_icon_origin(id, box_ent, g_supplybox_icon_id)
			i++
		}
	}
}

public create_supplybox()
{
	if (supplybox_count >= get_pcvar_num(cvar_supplybox_max) || g_newround || g_endround || zp_is_survivor_round() || zp_is_sniper_round() || zp_is_flamer_round() || zp_is_zadoc_round() || zp_is_guardians_round()) 
		return

	if (task_exists(TASK_SUPPLYBOX)) remove_task(TASK_SUPPLYBOX)
	set_task(get_pcvar_float(cvar_supplybox_time), "create_supplybox", TASK_SUPPLYBOX)
	
	if (get_total_supplybox() >= get_pcvar_num(cvar_supplybox_totalintime)) 
		return
	
	g_supplybox_num = 0
	create_supplybox2()
	
	static random_sound
	random_sound = random_num(0, charsmax(supplybox_drop_sound))
	client_cmd(0, "spk ^"%s^"", supplybox_drop_sound[random_sound])

	if (task_exists(TASK_SUPPLYBOX2)) remove_task(TASK_SUPPLYBOX2)
	set_task(0.5, "create_supplybox2", TASK_SUPPLYBOX2, _, _, "b")	
}

public create_supplybox2()
{
	if (supplybox_count >= get_pcvar_num(cvar_supplybox_max)
	|| get_total_supplybox() >= get_pcvar_num(cvar_supplybox_totalintime) || g_newround || g_endround)
	{
		remove_task(TASK_SUPPLYBOX2)
		return
	}
	
	supplybox_count++
	g_supplybox_num++

	static item
	item = random(ArraySize(supplybox_item))

	new ent = create_entity("info_target")
	entity_set_string(ent, EV_SZ_classname, SUPPLYBOX_CLASSNAME)
	entity_set_model(ent, supplybox_model[random_num(0, charsmax(supplybox_model))])	
	entity_set_size(ent,Float:{-2.0,-2.0,-2.0},Float:{5.0,5.0,5.0})
	entity_set_int(ent,EV_INT_solid,1)
	entity_set_int(ent,EV_INT_movetype,6)
	entity_set_int(ent, EV_INT_iuser1, item)
	entity_set_int(ent, EV_INT_iuser2, supplybox_count)
	set_pev(ent, pev_animtime, get_gametime());
	set_pev(ent, pev_framerate, 1.0);
	set_pev(ent, pev_nextthink, halflife_time() + 0.01);
	
	static Float:Origin[3]
	collect_spawn_point(Origin)
	engfunc(EngFunc_SetOrigin, ent, Origin)
	
	supplybox_ent[supplybox_count] = ent

	if ((g_supplybox_num >= get_pcvar_num(cvar_supplybox_num)) && task_exists(TASK_SUPPLYBOX2)) 
		remove_task(TASK_SUPPLYBOX2)
}

public get_total_supplybox()
{
	new total
	for (new i = 1; i <= supplybox_count; i++)
	{
		if (supplybox_ent[i]) total += 1
	}
	return total
}

public remove_supplybox()
{
	remove_ent_by_class(SUPPLYBOX_CLASSNAME)
	new supplybox_ent_reset[MAX_SUPPLYBOX_ENT]
	supplybox_ent = supplybox_ent_reset
}

public fw_supplybox_touch(ent, id)
{
	if (!pev_valid(ent) || !is_user_alive(id) || zp_get_user_zombie(id)
	|| zp_get_human_hero(id) || zp_get_zombie_hero(id) || g_supplybox_wait[id]) 
		return FMRES_IGNORED
	
	static classname[32]
	entity_get_string(ent,EV_SZ_classname,classname,31)
	
	if (equal(classname, SUPPLYBOX_CLASSNAME))
	{
		static item_id, item[64]
		item_id = entity_get_int(ent, EV_INT_iuser1)
		ArrayGetString(supplybox_item, item_id, item, charsmax(item))
		
		zp_force_buy_extra_item(id, zp_get_extra_item_id(item), 1, 1)
			
		static name[32]
		get_user_name(id, name, sizeof(name))
		colored_print(id, GREEN, "[ZC]^x03 %s^x01 has received a(n)^x04 %s^x01.", name, item)

		static random_sound
		random_sound = random_num(0, charsmax(supplybox_pickup_sound))
		emit_sound(id, CHAN_VOICE, supplybox_pickup_sound[random_sound], 1.0, ATTN_NORM, 0, PITCH_NORM)

		new num_box = entity_get_int(ent, EV_INT_iuser2)
		supplybox_ent[num_box] = 0
		remove_entity(ent)

		g_supplybox_wait[id] = 1
		if (task_exists(id+TASK_SUPPLYBOX_WAIT)) remove_task(id+TASK_SUPPLYBOX_WAIT)
		set_task(2.0, "remove_supplybox_wait", id+TASK_SUPPLYBOX_WAIT)
	}
	
	return FMRES_IGNORED
}

public remove_supplybox_wait(id)
{
	id -= TASK_SUPPLYBOX_WAIT
	
	g_supplybox_wait[id] = 0
	if (task_exists(id+TASK_SUPPLYBOX_WAIT)) remove_task(id+TASK_SUPPLYBOX_WAIT)
}

stock collect_spawn_point(Float:origin[3]) // By Sontung0
{
	for (new i = 1; i <= g_total_supplybox_spawn *3 ; i++)
	{
		origin = g_supplybox_spawn[random(g_total_supplybox_spawn)]
		if (check_spawn_box(origin)) return 1;
	}

	return 0;
}
stock check_spawn_box(Float:origin[3]) // By Sontung0
{
	new Float:originE[3], Float:origin1[3], Float:origin2[3]
	new ent = -1
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", SUPPLYBOX_CLASSNAME)) != 0)
	{
		pev(ent, pev_origin, originE)
		
		// xoy
		origin1 = origin
		origin2 = originE
		origin1[2] = origin2[2] = 0.0
		if (vector_distance(origin1, origin2) <= 32.0) return 0;
	}
	return 1;
}

stock create_icon_origin(id, ent, sprite) // By sontung0
{
	if (!pev_valid(ent)) return;
	
	new Float:fMyOrigin[3]
	entity_get_vector(id, EV_VEC_origin, fMyOrigin)
	
	new target = ent
	new Float:fTargetOrigin[3]
	entity_get_vector(target, EV_VEC_origin, fTargetOrigin)
	fTargetOrigin[2] += 40.0
	
	if (!is_in_viewcone(id, fTargetOrigin)) return;

	new Float:fMiddle[3], Float:fHitPoint[3]
	xs_vec_sub(fTargetOrigin, fMyOrigin, fMiddle)
	trace_line(-1, fMyOrigin, fTargetOrigin, fHitPoint)
							
	new Float:fWallOffset[3], Float:fDistanceToWall
	fDistanceToWall = vector_distance(fMyOrigin, fHitPoint) - 10.0
	normalize(fMiddle, fWallOffset, fDistanceToWall)
	
	new Float:fSpriteOffset[3]
	xs_vec_add(fWallOffset, fMyOrigin, fSpriteOffset)
	new Float:fScale
	fScale = 0.01 * fDistanceToWall
	
	new scale = floatround(fScale)
	scale = max(scale, 1)
	scale = min(scale, get_pcvar_num(cvar_supplybox_icon_size))
	scale = max(scale, 1)

	te_sprite(id, fSpriteOffset, sprite, scale, get_pcvar_num(cvar_supplybox_icon_light))
}

stock te_sprite(id, Float:origin[3], sprite, scale, brightness) // By sontung0
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

stock normalize(Float:fIn[3], Float:fOut[3], Float:fMul) // By sontung0
{
	new Float:fLen = xs_vec_len(fIn)
	xs_vec_copy(fIn, fOut)
	
	fOut[0] /= fLen, fOut[1] /= fLen, fOut[2] /= fLen
	fOut[0] *= fMul, fOut[1] *= fMul, fOut[2] *= fMul
}

stock str_count(const str[], searchchar) // By Twilight Suzuka
{
	new count, i, len = strlen(str)
	
	for (i = 0; i <= len; i++)
	{
		if(str[i] == searchchar)
			count++
	}
	
	return count;
}

stock remove_ent_by_class(classname[])
{
	new nextitem  = find_ent_by_class(-1, classname)
	while(nextitem)
	{
		remove_entity(nextitem)
		nextitem = find_ent_by_class(-1, classname)
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1066\\ f0\\ fs16 \n\\ par }
*/
