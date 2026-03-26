#include <amxmodx>

public plugin_init()
{
	register_plugin("[ZC Block Radio]", "1.0", "meNe")	
   	register_clcmd("radio1", "block", -1)
   	register_clcmd("radio2", "block", -1)
   	register_clcmd("radio3", "block", -1)
}

public block(id)
{
	return PLUGIN_HANDLED
}