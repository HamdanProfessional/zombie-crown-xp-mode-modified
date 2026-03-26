/************************************************************************************\
		   ========================================
		       * || Zombie Crown XP Mode v8.3 || *
		   ========================================
\************************************************************************************/

#if defined _zombiecrown_included
  #endinput
#endif
#define _zombiecrown_included

/* Flags */
#define ZV_MAIN (1<<0)
#define ZV_MULTI (1<<1)
#define ZV_UNLIMITED (1<<2)
#define ZV_DAMAGE (1<<3)

/* Teams for zp_register_extra_item() */
#define ZP_TEAM_ANY 0
#define ZP_TEAM_ZOMBIE 1
#define ZP_TEAM_HUMAN 2
#define ZP_TEAM_NEMESIS 3
#define ZP_TEAM_SURVIVOR 4
#define ZP_TEAM_SNIPER 5
#define ZP_TEAM_ASSASSIN 6
#define ZP_TEAM_FLAMER 7
#define ZP_TEAM_GENESYS 8
#define ZP_TEAM_OBERON 9
#define ZP_TEAM_ZADOC 10
#define ZP_TEAM_DRAGON 11
#define ZP_TEAM_NIGHTER 12
#define ZP_TEAM_NCHILD 13

/* Teams for zv_register_extra_item() */
#define ZV_TEAM_ANY 0
#define ZV_TEAM_ZOMBIE 1
#define ZV_TEAM_HUMAN 2
#define ZV_TEAM_NEMESIS 3
#define ZV_TEAM_SURVIVOR 4
#define ZV_TEAM_SNIPER 5
#define ZV_TEAM_ASSASSIN 6
#define ZV_TEAM_FLAMER 7
#define ZV_TEAM_GENESYS 8
#define ZV_TEAM_OBERON 9
#define ZV_TEAM_ZADOC 10
#define ZV_TEAM_DRAGON 11
#define ZV_TEAM_NIGHTER 12
#define ZV_TEAM_NCHILD 13

/* Flags for zc_get_user_flags() */
#define MODE_FLAG_A (1<<0)	// (a) access to menu
#define MODE_FLAG_B (1<<1) 	// (b) model
#define MODE_FLAG_C (1<<2) 	// (c) zombie
#define MODE_FLAG_D (1<<3) 	// (d) human
#define MODE_FLAG_E (1<<4) 	// (e) respawn
#define MODE_FLAG_F (1<<5) 	// (f) nemesis
#define MODE_FLAG_G (1<<6) 	// (g) survivor
#define MODE_FLAG_H (1<<7) 	// (h) assassin
#define MODE_FLAG_I (1<<8) 	// (i) sniper
#define MODE_FLAG_J (1<<9) 	// (j) genesys
#define MODE_FLAG_K (1<<10) 	// (k) flamer
#define MODE_FLAG_L (1<<11) 	// (l) oberon
#define MODE_FLAG_M (1<<12) 	// (m) zadoc
#define MODE_FLAG_N (1<<13) 	// (n) dragon
#define MODE_FLAG_O (1<<14) 	// (o) nighter
#define MODE_FLAG_P (1<<15) 	// (p) multi-infection
#define MODE_FLAG_Q (1<<16) 	// (q) swarm
#define MODE_FLAG_R (1<<17) 	// (r) plague
#define MODE_FLAG_S (1<<18) 	// (s) LNJ
#define MODE_FLAG_T (1<<19) 	// (t) weapons menu
#define MODE_FLAG_U (1<<20) 	// (u) weapons menu
#define MODE_FLAG_V (1<<21) 	// (w) weapons menu
#define MODE_FLAG_W (1<<22) 	// (v) weapons menu	
#define MODE_FLAG_X (1<<23) 	// (x) event
#define MODE_FLAG_Y (1<<24) 	// (y) free flag
#define MODE_FLAG_Z (1<<25) 	// (z) on / off mode

/* Game modes for zp_round_started() */
enum
{
	MODE_INFECTION = 1,
	MODE_NEMESIS,
	MODE_SURVIVOR,
	MODE_SWARM,
	MODE_MULTI,
	MODE_PLAGUE,
	MODE_SNIPER,
	MODE_ASSASSIN,
	MODE_GENESYS,
	MODE_FLAMER,
	MODE_OBERON,
	MODE_DRAGON,
	MODE_ZADOC,
	MODE_NIGHTER,
	MODE_LNJ
}

/* Winner teams for zp_round_ended() */
enum
{
	WIN_NO_ONE = 0,
	WIN_ZOMBIES,
	WIN_HUMANS
}

/* Restriction types for zp_register_extra_item( ) */
enum
{
	REST_NONE = 0, 		// No restriction
	REST_ROUND, 		// x times per round
	REST_MAP		// x times per map
}

/* Custom forward return values */
#define ZC_PLUGIN_HANDLED 97
#define ZP_PLUGIN_HANDLED 97
#define ZV_PLUGIN_HANDLED 97

/**
 * Returns whether a player is a zombie.
 *
 * @param id		Player index.
 * @return		True if it is, false otherwise.
 */
native zp_get_user_zombie(id)


/**
 * Returns whether a player is a nemesis.
 *
 * @param id		Player index.
 * @return		True if it is, false otherwise.
 */
native zp_get_user_nemesis(id)

/**
 * Returns whether a player is a survivor.
 *
 * @param id		Player index.
 * @return		True if it is, false otherwise.
 */
native zp_get_user_survivor(id)

/**
 * Returns whether a player is the first zombie.
 *
 * @param id		Player index.
 * @return		True if it is, false otherwise.
 */
native zp_get_user_first_zombie(id)

/**
 * Returns whether a player is the last zombie.
 *
 * @param id		Player index.
 * @return		True if it is, false otherwise.
 */
native zp_get_user_last_zombie(id)

/**
 * Returns whether a player is the last human.
 *
 * @param id		Player index.
 * @return		True if it is, false otherwise.
 */
native zp_get_user_last_human(id)

/**
 * Returns whether a player is zombie hero.
 *
 * @param id		Player index.
 * @return		True if it is, false otherwise.
 */
native zp_get_zombie_hero(id)

/**
 * Returns whether a player is a human hero.
 *
 * @param id		Player index.
 * @return		True if it is, false otherwise.
 */
native zp_get_human_hero(id)

/**
 * Returns whether a round is hero.
 *
 * @return		True if it is, false otherwise.
 */
native zp_is_hero_round()

/**
 * Returns a player's current zombie class ID.
 *
 * @param id		Player index.
 * @return		Internal zombie class ID, or -1 if not yet chosen.
 */
native zp_get_user_zombie_class(id)


/**
 * Returns a player's next zombie class ID (for the next infection).
 *
 * @param id		Player index.
 * @return		Internal zombie class ID, or -1 if not yet chosen.
 */
native zp_get_user_next_class(id)

/**
 * Sets a player's next zombie class ID (for the next infection).
 *
 * @param id		Player index.
 * @param classid	A valid zombie class ID.
 * @return		True on success, false otherwise.
 */
native zp_set_user_zombie_class(id, classid)

/**
 * Returns a player's current human class ID.
 *
 * @param id		Player index.
 * @return		Internal human class ID, or -1 if not yet chosen.
 */
native zp_get_user_human_class(id)

/**
 * Returns a player's next human class ID (for the next disinfection).
 *
 * @param id		Player index.
 * @return		Internal human class ID, or -1 if not yet chosen.
 */
native zp_get_user_next_hclass(id)

/**
 * Sets a player's next human class ID (for the next disinfection).
 *
 * @param id		Player index.
 * @param classid	A valid human class ID.
 * @return		True on success, false otherwise.
 */
native zp_set_user_human_class(id, classid)

/**
 * Returns a player's ammo pack count.
 *
 * @param id		Player index.
 * @return		Number of ammo packs owned.
 */
native zp_get_user_ammo_packs(id)

/**
 * Sets a player's ammo pack count.
 *
 * @param id		Player index.
 * @param amount	New quantity of ammo packs owned.
 */
native zp_set_user_ammo_packs(id, amount)

/**
 * Returns the default maximum health of a zombie.
 *
 * Note: Takes into account first zombie's HP multiplier.
 *
 * @param id		Player index.
 * @return		Maximum amount of health points, or -1 if not a normal zombie.
 */
native zp_get_zombie_maxhealth(id)

/**
 * Returns the default maximum health of a human.
 *
 * @param id		Player index.
 * @return		Maximum amount of health points, or -1 if not a normal human.
 */
native zp_get_human_maxhealth(id)

/**
 * Returns a player's custom flashlight batteries charge.
 *
 * @param id		Player index.
 * @return		Charge percent (0 to 100).
 */
native zp_get_user_batteries(id)

/**
 * Sets a player's custom flashlight batteries charge.
 *
 * @param id		Player index.
 * @param value		New charge percent (0 to 100).
 */
native zp_set_user_batteries(id, charge)

/**
 * Returns whether a player has night vision.
 *
 * @param id		Player index.
 * @return		True if it has, false otherwise.
 */
native zp_get_user_nightvision(id)

/**
 * Sets whether a player has night vision.
 *
 * @param id		Player index.
 * @param set		True to give, false for removing it.
 */
native zp_set_user_nightvision(id, set)

/**
 * Forces a player to become a zombie.
 *
 * Note: Unavailable for last human/survivor/sniper/flamer.
 *
 * @param id		Player index to be infected.
 * @param infector	Player index who infected him (optional).
 * @param silent	If set, there will be no HUD messages or infection sounds.
 * @param rewards	Whether to show DeathMsg and reward frags, hp, and ammo packs to infector.
 * @return		True on success, false otherwise.
 */
native zp_infect_user(id, infector = 0, silent = 0, rewards = 0)

/**
 * Forces a player to become a human.
 *
 * Note: Unavailable for last zombie/nemesis.
 *
 * @param id		Player index to be cured.
 * @param silent	If set, there will be no HUD messages or antidote sounds.
 * @return		True on success, false otherwise.
 */
native zp_disinfect_user(id, silent = 0)

/**
 * Forces a player to become a nemesis.
 *
 * Note: Unavailable for last human/survivor/sniper/flamer.
 *
 * @param id		Player index to turn into nemesis.
 * @return		True on success, false otherwise.
 */
native zp_make_user_nemesis(id)

/**
 * Forces a player to become a survivor.
 *
 * Note: Unavailable for last zombie/nemesis.
 *
 * @param id		Player index to turn into survivor.
 * @return		True on success, false otherwise.
 */
native zp_make_user_survivor(id)

/**
 * Respawns a player into a specific team.
 *
 * @param id		Player index to be respawned.
 * @param team		Team to respawn the player into (ZP_TEAM_ZOMBIE or ZP_TEAM_HUMAN).
 * @return		True on success, false otherwise.
 */
native zp_respawn_user(id, team)

/**
 * Forces a player to buy an extra item.
 *
 * @param id		Player index.
 * @param itemid	A valid extra item ID.
 * @param ignorecost	If set, item's cost won't be deduced from player.
 * @param ignorerest	If set, item's restriction will be ignored.
 * @return		True on success, false otherwise.
 */
native zp_force_buy_extra_item(id, itemid, ignorecost = 0, ignorerest = 0)

/**
 * Returns whether a player is a sniper.
 *
 * @param id		Player index.
 * @return		True if it is, false otherwise.
 */
native zp_get_user_sniper(id)

/**
 * Forces a player to become a sniper.
 *
 * Note: Unavailable for last zombie/nemesis/assassin.
 *
 * @param id		Player index to turn into sniper.
 * @return		True on success, false otherwise.
 */
native zp_make_user_sniper(id)

/**
 * Returns whether a player is a flamer.
 *
 * @param id		Player index.
 * @return		True if it is, false otherwise.
 */
native zp_get_user_flamer(id)

/**
 * Returns whether the current round is a flamer round.
 *
 * @return		True if it is, false otherwise.
 */
native zp_is_flamer_round()

/**
 * Forces a player to become a flamer.
 *
 * Note: Unavailable for last zombie/nemesis/assassin/genesys.
 *
 * @param id		Player index to turn into flamer.
 * @return		True on success, false otherwise.
 */
native zp_make_user_flamer(id)

/**
 * Forces a player to become a genesys.
 *
 * Note: Unavailable for last human/survivor/sniper/flamer.
 *
 * @param id		Player index to turn into genesys.
 * @return		True on success, false otherwise.
 */
native zp_make_user_genesys(id)

/**
 * Returns whether a player is a genesys.
 *
 * @param id		Player index.
 * @return		True if it is, false otherwise.
 */
native zp_get_user_genesys(id)

/**
 * Returns whether the current round is a genesys round.
 *
 * @return		True if it is, false otherwise.
 */
native zp_is_genesys_round()

/**
 * Forces a player to become a oberon.
 *
 * Note: Unavailable for last human/survivor/sniper/flamer/zadoc.
 *
 * @param id		Player index to turn into oberon.
 * @return		True on success, false otherwise.
 */
native zp_make_user_oberon(id)

/**
 * Returns whether a player is a oberon.
 *
 * @param id		Player index.
 * @return		True if it is, false otherwise.
 */
native zp_get_user_oberon(id)

/**
 * Returns whether the current round is a oberon round.
 *
 * @return		True if it is, false otherwise.
 */
native zp_is_oberon_round()

/**
 * Returns whether a player is an assassin.
 *
 * @param id		Player index.
 * @return		True if it is, false otherwise.
 */
native zp_get_user_assassin(id)

/**
 * Returns whether a player is an dragon.
 *
 * @param id		Player index.
 * @return		True if it is, false otherwise.
 */
native zp_get_user_dragon(id)

/**
 * Returns whether a player is an nighter.
 *
 * @param id		Player index.
 * @return		True if it is, false otherwise.
 */
native zp_get_user_nighter(id)

/**
 * Returns whether a player is an zadoc.
 *
 * @param id		Player index.
 * @return		True if it is, false otherwise.
 */
native zp_get_user_zadoc(id)

/**
 * Forces a player to become a assassin.
 *
 * Note: Unavailable for last human/survivor/sniper/flamer.
 *
 * @param id		Player index to turn into assassin.
 * @return		True on success, false otherwise.
 */
native zp_make_user_assassin(id)

/**
 * Forces a player to become a dragon.
 *
 * Note: Unavailable for last human/survivor/sniper/flamer/zadoc.
 *
 * @param id		Player index to turn into dragon.
 * @return		True on success, false otherwise.
 */
native zp_make_user_dragon(id)

/**
 * Forces a player to become a nighter.
 *
 * Note: Unavailable for last human/survivor/sniper/flamer/zadoc.
 *
 * @param id		Player index to turn into nighter.
 * @return		True on success, false otherwise.
 */
native zp_make_user_nighter(id)

/**
 * Forces a player to become a assassin.
 *
 * Note: Unavailable for last human
 *
 * @param id		Player index to turn into zadoc.
 * @return		True on success, false otherwise.
 */
native zp_make_user_zadoc(id)

/**
 * Returns whether the ZP round has started, i.e. first zombie
 * has been chosen or a game mode has begun.
 *
 * @return		0 - Round not started
 *			1 - Round started
 *			2 - Round starting
 */
native zp_has_round_started()

/**
 * Returns whether the current round is a nemesis round.
 *
 * @return		True if it is, false otherwise.
 */
native zp_is_nemesis_round()

/**
 * Returns whether the current round is a survivor round.
 *
 * @return		True if it is, false otherwise.
 */
native zp_is_survivor_round()

/**
 * Returns whether the current round is a swarm round.
 *
 * @return		True if it is, false otherwise.
 */
native zp_is_swarm_round()

/**
 * Returns whether the current round is a plague round.
 *
 * @return		True if it is, false otherwise.
 */
native zp_is_plague_round()

/**
 * Returns whether the current round is a LNJ round.
 *
 * @return		True if it is, false otherwise.
 */
native zp_is_lnj_round()

/**
 * Returns whether the current round is a Guardians round.
 *
 * @return		True if it is, false otherwise.
 */
native zp_is_guardians_round()

/**
 * Returns number of alive zombies.
 *
 * @return		Zombie count.
 */
native zp_get_zombie_count()

/**
 * Returns number of alive humans.
 *
 * @return		Human count.
 */
native zp_get_human_count()

/**
 * Returns number of alive nemesis.
 *
 * @return		Nemesis count.
 */
native zp_get_nemesis_count()

/**
 * Returns number of alive survivors.
 *
 * @return		Survivor count.
 */
native zp_get_survivor_count()

/**
 * Returns whether the current round is a sniper round.
 *
 * @return		True if it is, false otherwise.
 */
native zp_is_sniper_round()

/**
 * Returns whether the current round is a assassin round.
 *
 * @return		True if it is, false otherwise.
 */
native zp_is_assassin_round()

/**
 * Returns whether the current round is a dragon round.
 *
 * @return		True if it is, false otherwise.
 */
native zp_is_dragon_round()

/**
 * Returns whether the current round is a nighter round.
 *
 * @return		True if it is, false otherwise.
 */
native zp_is_nighter_round()

/**
 * Returns whether the current round is a zadoc round.
 *
 * @return		True if it is, false otherwise.
 */
native zp_is_zadoc_round()

/**
 * Returns number of alive snipers.
 *
 * @return		Sniper count.
 */
native zp_get_sniper_count()

/**
 * Returns number of alive assassins.
 *
 * @return		Assassin count.
 */
native zp_get_assassin_count()

/**
 * Returns number of alive dragons.
 *
 * @return		Dragon count.
 */
native zp_get_dragon_count()

/**
 * Returns number of alive nighters.
 *
 * @return		nighter count.
 */
native zp_get_nighter_count()

/**
 * Returns number of alive zadocs.
 *
 * @return		Zadoc count.
 */
native zp_get_zadoc_count()

/**
 * Registers a custom item which will be added to the extra items menu of ZP.
 *
 * Note: The returned extra item ID can be later used to catch item
 * purchase events for the zp_extra_item_selected() forward.
 *
 * Note: ZP_TEAM_NEMESIS, ZP_TEAM_SURVIVOR, ZP_TEAM_ASSASSIN, ZP_TEAM_SNIPER,
 * ZP_TEAM_GENESYS, ZP_TEAM_FLAMER, ZP_TEAM_OBERON, ZP_TEAM_DRAGON, ZP_TEAM_ZADOC, 
 * ZP_TEAM_NIGHTER and, ZP_TEAM_NCHILD can be used to make an item available to Nemesis,
 * Survivors, Assassins, Snipers, Genesys, Flamers, Oberons, Dragons, Nighters or Nchildren.
 *
 * @param name		Caption to display on the menu.
 * @param cost		Ammo packs to be deducted on purchase.
 * @param teams		Bitsum of teams it should be available for.
 * @param restriction	Type of restriction
 * @param limit		Limit of the restriction
 * @return		An internal extra item ID, or -1 on failure.
 */
native zp_register_extra_item(const name[], cost, teams, restriction = 0, limit = 0)

/**
 * @param itemid 	ItemID
 * @param name		Player Name
 * @param limit		Limit of the restriction
 * @return		An internal extra item ID, or -1 on failure.
 */
native zp_set_limit(id, itemid, const name[], limit)

/**
 * Registers a custom class which will be added to the zombie classes menu of ZP.
 *
 * Note: The returned zombie class ID can be later used to identify
 * the class when calling the zp_get_user_zombie_class() natives.
 *
 * @param name		Caption to display on the menu.
 * @param info		Brief description of the class.
 * @param model		Player model to be used.
 * @param clawmodel	Player model to be used.
 * @param hp		Initial health points.
 * @param speed		Maximum speed.
 * @param gravity	Gravity multiplier.
 * @param knockback	Knockback multiplier.
 * @param level		Level.
 * @return		An internal zombie class ID, or -1 on failure.
 */
native zp_register_zombie_class(const name[], const info[], const model[], const clawmodel[], hp, speed, Float:gravity, Float:knockback, level)

/**
 * Registers a custom class which will be added to the human classes menu of ZP.
 *
 * Note: The returned human class ID can be later used to identify
 * the class when calling the zp_get_user_human_class() natives.
 *
 * @param name		Caption to display on the menu.
 * @param info		Brief description of the class.
 * @param model		Player model to be used.
 * @param hp		Initial health points.
 * @param speed		Maximum speed.
 * @param gravity	Gravity multiplier.
 * @param level		Level.
 * @return		An internal human class ID, or -1 on failure.
 */
native zp_register_human_class(const name[], const info[], const model[], hp, speed, Float:gravity, level)

/**
 * Returns an extra item's ID.
 *
 * @param name		Item name to look for.
 * @return		Internal extra item ID, or -1 if not found.
 */
native zp_get_extra_item_id(const name[])

/**
 * Returns a zombie class' ID.
 *
 * @param name		Class name to look for.
 * @return		Internal zombie class ID, or -1 if not found.
 */
native zp_get_zombie_class_id(const name[])

/**
 * Called when the ZP round starts, i.e. first zombie
 * is chosen or a game mode begins.
 *
 * @param gamemode	Mode which has started.
 * @param id		Affected player's index (if applicable).
 */
forward zp_round_started(gamemode, id)

/**
 * Called when the round ends.
 *
 * @param winteam	Team which has won the round.
 */
forward zp_round_ended(winteam)

/**
 * Called when a player gets infected.
 *
 * @param id		Player index who was infected.
 * @param infector	Player index who infected him (if applicable).
 * @param nemesis	Whether the player was turned into a nemesis.
 */
forward zp_user_infected_pre(id, infector, nemesis, assassin, genesys, oberon, dragon, nighter)
forward zp_user_infected_post(id, infector, nemesis, assassin, genesys, oberon, dragon, nighter)

/**
 * Called when a player turns back to human.
 *
 * @param id		Player index who was cured.
 * @param survivor	Whether the player was turned into a survivor.
 */
forward zp_user_humanized_pre(id, survivor, sniper, flamer, zadoc)
forward zp_user_humanized_post(id, survivor, sniper, flamer, zadoc)

/**
 * Called on a player infect/cure attempt. You can use this to block
 * an infection/humanization by returning ZP_PLUGIN_HANDLED in your plugin.
 *
 * Note: Right now this is only available after the ZP round starts, since some
 * situations (like blocking a first zombie's infection) are not yet handled.
 */
forward zp_user_infect_attempt(id, infector, nemesis, assassin, genesys, oberon, dragon, nighter)
forward zp_user_humanize_attempt(id, survivor, sniper, flamer, zadoc)

/**
 * Called when a player buys an extra item from the ZP menu.
 *
 * Note: You can now return ZP_PLUGIN_HANDLED in your plugin to block
 * the purchase and the player will be automatically refunded.
 *
 * @param id		Player index of purchaser.
 * @param itemid	Internal extra item ID.
 */
forward zp_extra_item_selected(id, itemid)

/**
 * Called when a player gets unfrozen (frostnades).
 *
 * @param id		Player index.
 */
forward zp_user_unfrozen(id)

/**
 * Called when a player gets infection-grenade.
 *
 * @param id		Player index.
 */
forward zp_user_infected_bybomb_native(id)

/**
 * Called when a player gets kill-grenade.
 *
 * @param id		Player index.
 */
forward zp_user_infected_bykillbomb(id)

/**
 * Called when a player spawned.
 *
 * @param id		Player index who was cured. 
 */
forward zp_user_spawned_pre(id)
forward zp_user_spawned_post(id)

/**
 * Called on hclass.
 *
 * @param id		Player hclass. 
 */
forward zp_hclass_param(id)

/**
 * Called on Respawn.
 *
 * @param id		Player ID. 
 */
forward zp_respawn_menu_zm(id)

/**
 * Called on Respawn.
 *
 * @param id		Player ID. 
 */
forward zp_respawn_menu_hm(id)

/**
 * Called when a player becomes the last zombie.
 *
 * Note: This is called for the first zombie too.
 *
 * @param id		Player index.
 */
forward zp_user_last_zombie(id)

/**
 * Called when a player becomes the last human.
 *
 * @param id		Player index.
 */
forward zp_user_last_human(id)

/**
 * Returns a player's powers count.
 *
 * @param id		Player index.
 * @return		Number of powers owned.
 */
native zp_get_user_power(id)

/**
 * Returns a player's current human class ID.
 *
 * @param id		Player index.
 * @return			Internal zombie class ID, or HCLASS_NONE if not yet chosen.
 */
native zp_get_user_current_hc(id)

/**
 * Returns a human class' name.
 *
 * @param classid	A valid zombie class ID.
 * @param name		The buffer to store the string in.
 * @param len		Character size of the output buffer.
 * @return			True on success, false otherwise.
 */
native zp_get_user_hclassname(classid, name[], len)

/**
 * Returns a player's current zombie class ID.
 *
 * @param id		Player index.
 * @return			Internal zombie class ID, or ZCLASS_NONE if not yet chosen.
 */
native zp_get_user_current_zc(id)

/**
 * Returns a zombie class' name.
 *
 * @param classid	A valid zombie class ID.
 * @param name		The buffer to store the string in.
 * @param len		Character size of the output buffer.
 * @return			True on success, false otherwise.
 */
native zp_get_user_zclassname(classid, name[], len)

/**
 * Returns a player's level count.
 *
 * @param id		Player index.
 * @return		Number of level owned.
 */
native zp_get_user_level(id)

/**
 * Set player level
 *
 * @param id		Player index.
 * @return		Number of level owned.
 */
native zp_set_user_level(id, amount)

/**
 * Returns a player's points count.
 *
 * @param id		Player index.
 * @return		Number of points owned.
 */
native zp_get_user_points(id)

/**
 * Sets a player's points count.
 *
 * @param id		Player index.
 * @param amount	Number of points added.
 */
native zp_set_user_points(id, amount)

/**
 * Returns a player's XP count.
 *
 * @param id		Player index.
 * @return		Number of xp owned.
 */
native zp_get_user_xp(id)

/**
 * Sets a player's XP count.
 *
 * @param id		Player index.
 * @param amount	Number of xp added.
 */
native zp_set_user_xp(id, amount)

/**
 * Returns a player's coins count.
 *
 * @param id		Player index.
 * @return		Number of coins owned.
 */
native zp_get_user_coins(id)

/**
 * Sets a player's coins count.
 *
 * @param id		Player index.
 * @param amount	Number of coins added.
 */
native zp_set_user_coins(id, amount)

/**
 * Sets a player's off buy custom.
 *
 * @param id		Player index.
 */
native zp_set_user_blockbuy(id)

/**
 * Returns whether a player is stunned.
 *
 * @param id		Player index.
 * @return		True if it is, false otherwise.
 */
native zp_get_user_stunned(id)

/**
 * SaveLevel player.
 *
 * @param id		Player index.
 */
native SaveLevel(id)

/**
 * SaveDate player.
 *
 * @param id		Player index.
 */
native SaveDate(id)

/**
 * Update Team player.
 *
 * @param id		Player index.
 */
native zp_update_team(id)

/**
 * If the user is frozen
 *
 * @param id		Player index.
 */
native zp_get_user_frozen(id)

/**
 * Set if user should be frozen
 *
 * @param id		Player index.
 * @param set		True to set, false for removing it.
 */
native zp_set_user_frozen(id, set)

/* Gets user flags - access
* 
*  @param id             Player index.
*  @return               Player flags.
*/
native zc_get_user_flags(id)

/**
 * Registers a custom item which will be added to the extra items menu of ZP.
 *
 * Note: The returned extra item ID can be later used to catch item
 * purchase events for the zp_extra_item_selected() forward.
 *
 * Note: ZV_TEAM_NEMESIS, ZV_TEAM_SURVIVOR, ZV_TEAM_ASSASSIN, ZV_TEAM_SNIPER,
 * ZV_TEAM_GENESYS, ZV_TEAM_FLAMER, ZV_TEAM_OBERON, ZV_TEAM_DRAGON, ZV_TEAM_ZADOC, 
 * ZV_TEAM_NIGHTER and, ZV_TEAM_NCHILD can be used to make an item available to Nemesis,
 * Survivors, Assassins, Snipers, Genesys, Flamers, Oberons, Dragons, Nighters or Nchildren.
 *
 * @param name		Caption to display on the menu.
 * @param cost		Ammo packs to be deducted on purchase.
 * @param teams		Bitsum of teams it should be available for.
 * @param restriction	Type of restriction
 * @param limit		Limit of the restriction
 * @return		An internal extra item ID, or -1 on failure.
 */
native zv_register_extra_item(const name[], cost, teams, restriction = 0, limit = 0)

/* Gets user flags - VIP
* 
*  @param id             Player index.
*  @return               Player flags.
*/
native zv_get_user_flags(id)

/* Called then player selects extra item in his VIP meniu.
*
*  You can stop player of buing item returning ZV_PLUGIN_HANDLED.
*  Player will be refunded automaticaly
*
*  @param id             Player index.
*  @param itemid         Extra item id, witch player bought.
*/
forward zv_extra_item_selected(id, itemid)

/*==============================================================================
 * NEW FEATURES API - Player Profiles, HUD, Achievements, Prestige, Effects, Challenges
 *==============================================================================*/

/**
 * Player Profile Natives
 * Get a player's database ID from the profile system
 *
 * @param id		Player index.
 * @return		Player's database ID, or 0 if not loaded.
 */
native zc_get_user_database_id(id)

/**
 * Gets a player's total playtime in seconds
 *
 * @param id		Player index.
 * @return		Total playtime in seconds.
 */
native zc_get_user_playtime(id)

/**
 * Gets a specific player statistic
 *
 * @param id		Player index.
 * @param stat	Statistic name (e.g., "total_kills", "infections")
 * @return		Statistic value.
 */
native zc_get_user_stat(id, const stat[])

/**
 * Sets a player's statistic value
 *
 * @param id		Player index.
 * @param stat	Statistic name.
 * @param value	New value.
 */
native zc_set_user_stat(id, const stat[], value)

/**
 * Adds to a player's statistic
 *
 * @param id		Player index.
 * @param stat	Statistic name.
 * @param amount	Amount to add (can be negative).
 */
native zc_update_user_stat(id, const stat[], amount)

/**
 * Update player kills/deaths statistics
 *
 * @param attacker	Attacker index.
 * @param victim		Victim index.
 */
native zc_update_player_kills(attacker, victim)

/**
 * Update player deaths
 *
 * @param victim		Victim index.
 */
native zc_update_player_deaths(victim)

/**
 * Update player infections
 *
 * @param id		Player index.
 * @param amount	Amount to add.
 */
native zc_update_player_infections(id, amount)

/**
 * Update player round statistics
 *
 * @param id		Player index.
 * @param won		Whether the round was won (1) or lost (0).
 */
native zc_update_player_round(id, won)

/**
 * Modern HUD Natives
 * Shows a priority message on HUD
 *
 * @param id		Player index.
 * @param message	Message text.
 * @param priority	Message priority (0=critical, 1=high, 2=normal, 3=low).
 * @param duration	Display duration in seconds.
 */
native zc_hud_show_message(id, const message[], priority, Float:duration = 5.0)

/**
 * Queues a message in the HUD message queue
 *
 * @param id		Player index.
 * @param message	Message text.
 * @param priority	Message priority.
 * @param duration	Display duration in seconds.
 */
native zc_hud_queue_message(id, const message[], priority, Float:duration = 5.0)

/**
 * Updates a HUD element's text
 *
 * @param id		Player index.
 * @param name		Element name.
 * @param text		New text to display.
 */
native zc_hud_update_element(id, const name[], const text[])

/**
 * Sets element visibility
 *
 * @param elementName	Element name.
 * @param visible		True to show, false to hide.
 */
native zc_hud_set_element_visibility(const elementName[], visible)

/**
 * Check if modern HUD is enabled
 *
 * @return		1 if enabled, 0 otherwise.
 */
native zc_hud_is_enabled()

/**
 * Show achievement notification
 *
 * @param id		Player index.
 * @param achievementName	Achievement name.
 * @param description	Achievement description.
 * @param rewardAmount	Reward amount.
 * @param rewardType	Reward type (coins, points, xp, packs).
 */
native zc_hud_show_achievement(id, const achievementName[], const description[], rewardAmount, const rewardType[])

/**
 * Show prestige notification
 *
 * @param id		Player index.
 * @param prestigeLevel	New prestige level.
 */
native zc_hud_show_prestige(id, prestigeLevel)

/**
 * Show challenge progress notification
 *
 * @param id		Player index.
 * @param challengeName	Challenge name.
 * @param progress	Current progress.
 * @param target		Target value.
 * @param rewardAmount	Reward amount.
 * @param rewardType	Reward type.
 */
native zc_hud_show_challenge(id, const challengeName[], progress, target, rewardAmount, const rewardType[])

/**
 * Achievement Natives
 * Gets total number of achievements
 *
 * @return		Achievement count.
 */
native zc_get_achievement_count()

/**
 * Checks if player has unlocked an achievement
 *
 * @param id		Player index.
 * @param achievementId	Achievement ID.
 * @return		true if unlocked, false otherwise.
 */
native zc_is_achievement_unlocked(id, achievementId)

/**
 * Gets achievement progress
 *
 * @param id		Player index.
 * @param achievementId	Achievement ID.
 * @return		Progress value (0 to required value).
 */
native zc_get_achievement_progress(id, achievementId)

/**
 * Registers a custom achievement
 *
 * @param key		Unique achievement key.
 * @param name		Achievement name.
 * @param description	Achievement description.
 * @param req_type	Requirement type (kills, infections, etc.).
 * @param req_value	Required value.
 * @param reward_type	Reward type (coins, points, etc.).
 * @param reward_amount	Reward amount.
 * @return		Achievement ID on success, -1 on failure.
 */
native zc_register_custom_achievement(const key[], const name[], const description[], const req_type[], req_value, const reward_type[], reward_amount)

/**
 * Force unlock an achievement
 *
 * @param id		Player index.
 * @param achievementId	Achievement ID.
 * @return		1 on success, 0 on failure.
 */
native zc_force_unlock_achievement(id, achievementId)

/**
 * Prestige Natives
 * Gets player's prestige level
 *
 * @param id		Player index.
 * @return		Prestige level (0 to MAX_PRESTIGE).
 */
native zc_get_user_prestige(id)

/**
 * Gets player's prestige points (shop currency)
 *
 * @param id		Player index.
 * @return		Prestige points.
 */
native zc_get_user_prestige_points(id)

/**
 * Checks if player can prestige
 *
 * @param id		Player index.
 * @return		true if can prestige, false otherwise.
 */
native zc_can_prestige(id)

/**
 * Prestiges a player (resets level, grants bonuses)
 *
 * @param id		Player index.
 * @return		true on success, false on failure.
 */
native zc_prestige_player(id)

/**
 * Gets prestige bonus multiplier
 *
 * @param id		Player index.
 * @param bonus_type	Bonus type ("xp_mult", "coin_mult", etc.).
 * @return		Bonus multiplier (100 = 1.0x).
 */
native zc_get_prestige_bonus(id, const bonus_type[])

/**
 * Gets player's XP multiplier (from prestige)
 *
 * @param id		Player index.
 * @return		XP multiplier (100 = 100%).
 */
native zc_get_xp_multiplier(id)

/**
 * Gets player's Coin multiplier (from prestige)
 *
 * @param id		Player index.
 * @return		Coin multiplier (100 = 100%).
 */
native zc_get_coin_multiplier(id)

/**
 * Kill Effects Natives
 * Gets player's equipped kill effect
 *
 * @param id		Player index.
 * @return		Effect ID, or -1 for default.
 */
native zc_get_player_kill_effect(id)

/**
 * Sets player's equipped kill effect
 *
 * @param id		Player index.
 * @param effectId	Effect ID.
 * @return		true on success, false if effect not unlocked.
 */
native zc_set_player_kill_effect(id, effectId)

/**
 * Checks if player has unlocked a kill effect
 *
 * @param id		Player index.
 * @param effectId	Effect ID.
 * @return		true if unlocked, false otherwise.
 */
native zc_is_kill_effect_unlocked(id, effectId)

/**
 * Unlocks a kill effect for player
 *
 * @param id		Player index.
 * @param effectId	Effect ID.
 * @return		1 on success, 0 on failure.
 */
native zc_unlock_kill_effect(id, effectId)

/**
 * Registers a custom kill effect
 *
 * @param key		Unique effect key.
 * @param name		Effect name.
 * @param type		Effect type (screen_fade, sprite_burst, etc.).
 * @param data		Effect data (JSON string).
 * @return		Effect ID on success, -1 on failure.
 */
native zc_register_custom_kill_effect(const key[], const name[], type, const data[])

/**
 * Leaderboard Natives
 * Gets player's rank on a leaderboard
 *
 * @param id		Player index.
 * @param type		Leaderboard type (LEVEL=0, XP=1, KILLS=2, INFECTIONS=3, PLAYTIME=4, PRESTIGE=5, COINS=6).
 * @return		Player's rank, or 0 on error.
 */
native zc_get_player_rank(id, type)

/**
 * Gets a leaderboard entry
 *
 * @param type		Leaderboard type.
 * @param rank		Rank position (1-10).
 * @param name		Buffer to store player name.
 * @param len		Buffer length.
 * @return		Entry value (kills, XP, etc.).
 */
native zc_get_leaderboard_entry(type, rank, name[], len)

/**
 * Refreshes a specific leaderboard
 *
 * @param type		Leaderboard type.
 * @return		1 on success.
 */
native zc_refresh_leaderboard(type)

/**
 * Gets leaderboard count
 *
 * @return		Number of leaderboard types.
 */
native zc_get_leaderboard_count()

/**
 * Daily Challenges Natives
 * Gets player's progress on a daily challenge
 *
 * @param id		Player index.
 * @param challengeIndex	Challenge index (0-2).
 * @return		Progress value.
 */
native zc_get_daily_challenge_progress(id, challengeIndex)

/**
 * Gets number of active daily challenges
 *
 * @return		Challenge count (usually 3).
 */
native zc_get_daily_challenge_count()

/**
 * Registers a custom challenge template
 *
 * @param key		Unique challenge key.
 * @param name		Challenge name.
 * @param desc		Challenge description.
 * @param type		Challenge type (kill_zombies, infect_humans, etc.).
 * @param target		Target value.
 * @param difficulty	Difficulty (1=easy, 2=medium, 3=hard).
 * @param reward_type	Reward type.
 * @param reward_amount	Reward amount.
 * @param min_level	Minimum level requirement.
 * @return		Template ID on success, -1 on failure.
 */
native zc_register_custom_challenge(const key[], const name[], const desc[], const type[], target, difficulty, const reward_type[], reward_amount, min_level)

/**
 * Force complete a daily challenge
 *
 * @param id		Player index.
 * @param challengeIndex	Challenge index.
 * @return		1 on success.
 */
native zc_force_daily_complete(id, challengeIndex)

/**
 * NEW FEATURES FORWARDS
 * Called when a player's profile is loaded from database
 *
 * @param id		Player index.
 */
forward zc_profile_loaded(id)

/**
 * Called when a player's profile is saved to database
 *
 * @param id		Player index.
 */
forward zc_profile_saved(id)

/**
 * Called when a player's stat changes
 *
 * @param id		Player index.
 * @param stat		Statistic name.
 * @param old_value	Old value.
 * @param new_value	New value.
 */
forward zc_player_stat_changed(id, const stat[], old_value, new_value)

/**
 * Called when an achievement is unlocked
 *
 * @param id		Player index.
 * @param achievementId	Achievement ID.
 */
forward zc_achievement_unlocked(id, achievementId)

/**
 * Called when achievement progress updates
 *
 * @param id		Player index.
 * @param achievementId	Achievement ID.
 * @param progress	New progress value.
 */
forward zc_achievement_progress_updated(id, achievementId, progress)

/**
 * Called when a player prestiges
 *
 * @param id		Player index.
 * @param new_prestige_level	New prestige level.
 */
forward zc_player_prestiged(id, new_prestige_level)

/**
 * Called when a prestige perk is granted
 *
 * @param id		Player index.
 * @param perk_id	Perk ID.
 */
forward zc_prestige_perk_granted(id, perk_id)

/**
 * Called when daily challenge progress updates
 *
 * @param id		Player index.
 * @param challengeIndex	Challenge index.
 * @param progress	New progress value.
 */
forward zc_daily_challenge_updated(id, challengeIndex, progress)

/**
 * Called when a daily challenge is completed
 *
 * @param id		Player index.
 * @param challengeIndex	Challenge index.
 */
forward zc_daily_challenge_completed(id, challengeIndex)

/**
 * Called when a leaderboard is refreshed
 *
 * @param type		Leaderboard type.
 */
forward zc_leaderboard_refreshed(type)

/**
 * Called when HUD element is updated
 *
 * @param id		Player index.
 * @param element_name	Element name.
 * @param new_text	New text content.
 */
forward zc_hud_element_updated(id, const element_name[], const new_text[])

/**
 * Called when a kill effect is unlocked
 *
 * @param id		Player index.
 * @param effectId	Effect ID.
 */
forward zc_kill_effect_unlocked(id, effectId)