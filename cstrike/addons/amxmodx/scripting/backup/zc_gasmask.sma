#include <amxmodx>
#include <zombiecrown>
#include <colored_print>

new bool:g_bHasGasMask[33], g_iItemID

public plugin_init() 
{
    	register_plugin("[ZC Gas-Mask]", "1.0", "meNe")
    	register_message(get_user_msgid("DeathMsg"), "message_DeathMsg")
    	g_iItemID = zp_register_extra_item("Gas-Mask", 60, ZP_TEAM_HUMAN, REST_MAP, 3)
}

public zp_extra_item_selected(id, itemid)
{
    	if(itemid == g_iItemID)
    	{
       		if(g_bHasGasMask[id]){
            		client_print(id, print_center, "You already have a Gas-Mask")
            		return ZP_PLUGIN_HANDLED
        	}
        	g_bHasGasMask[id] = true
        	client_print(id, print_center, "Now you have a Gas-Mask")
    	}
	return PLUGIN_HANDLED
}

public zp_user_infected_bybomb_native(id)
{
    	// Stop if he will be infected by a bomb
    	if(g_bHasGasMask[id])
        	return ZP_PLUGIN_HANDLED
        
    	return PLUGIN_CONTINUE
}

public zp_user_infected_post(id)
{
    	// After being infected
    	g_bHasGasMask[id] = false
}

public zp_user_humanized_pre(id)
{
    	// Being a survivor, or disinfected
    	// PD: This isn't called on spawn
    	g_bHasGasMask[id] = false
}

public message_DeathMsg()
{
    	// When killed
    	g_bHasGasMask[read_data(2)] = false
}  