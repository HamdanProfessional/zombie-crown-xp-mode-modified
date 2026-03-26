#include <amxmodx>
#include <fakemeta>
#include <zombiecrown>
#include <colored_print>

/*================================================================================
 [Plugin Customization]
=================================================================================*/
new g_itemid_humanarmor
const g_armor_amount = 120
const g_armor_limit = 999
/*============================================================================*/

public plugin_init()
{
	register_plugin("[ZC HArmor]", "1.0", "meNe")
	g_itemid_humanarmor = zv_register_extra_item("Armor Anti-Infection", 25, ZV_TEAM_HUMAN, REST_ROUND, 7)
}

// Human buys our upgrade, give him some armor
public zv_extra_item_selected(player, itemid)
{
	if (itemid == g_itemid_humanarmor)
	{
		set_pev(player, pev_armorvalue, float(min(pev(player, pev_armorvalue)+g_armor_amount, g_armor_limit)))
	}
	return PLUGIN_CONTINUE
}