#include <amxmodx>
#include <zombiecrown>
#include <colored_print>

new bool:g_bHasBombMask[33], g_iItemID

public plugin_init() 
{
    	register_plugin("[ZC Bomb-Mask]", "1.0", "meNe")
    	register_message(get_user_msgid("DeathMsg"), "message_DeathMsg")
    	g_iItemID = zp_register_extra_item("Bomb-Mask", 150, ZP_TEAM_HUMAN, REST_MAP, 3)
}

public zp_extra_item_selected(id, itemid)
{
    	if(itemid == g_iItemID)
    	{
       		if(g_bHasBombMask[id]) {
            		client_print(id, print_center, "You already have a Bomb-Mask")
            		return ZP_PLUGIN_HANDLED
        	}
        	g_bHasBombMask[id] = true
        	client_print(id, print_center, "Now you have a Bomb-Mask")
    	}
	return PLUGIN_HANDLED
}

public zp_user_infected_bykillbomb(id)
{
    	// Stop if he will be infected by a bomb
    	if(g_bHasBombMask[id])
        	return PLUGIN_HANDLED
        
    	return PLUGIN_CONTINUE
}

public zp_user_infected_post(id)
{
    	// After being infected
    	g_bHasBombMask[id] = false
}

public zp_user_humanized_pre(id)
{
    	// Being a survivor, or disinfected
    	// PD: This isn't called on spawn
    	g_bHasBombMask[id] = false
}

public message_DeathMsg()
{
    	// When killed
    	g_bHasBombMask[read_data(2)] = false
}  