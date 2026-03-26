#include <amxmodx>
#include <fakemeta>
#include <zombiecrown>
#include <colored_print>

/*================================================================================
 [Plugin Customization]
=================================================================================*/
const g_armor_amount = 100
const g_armor_limit = 999
/*============================================================================*/

// Item IDs
new g_itemid_humanarmor

public plugin_init()
{
	register_plugin("[ZC PArmor]", "1.0", "meNe")
	g_itemid_humanarmor = zp_register_extra_item("Anti-Infection Armor", 20, ZP_TEAM_HUMAN, REST_ROUND, 5)
}

public zp_extra_item_selected(player, itemid)
{
	if (itemid == g_itemid_humanarmor)
	{
		set_pev(player, pev_armorvalue, float(min(pev(player, pev_armorvalue)+g_armor_amount, g_armor_limit)))
	}
	return PLUGIN_CONTINUE
}