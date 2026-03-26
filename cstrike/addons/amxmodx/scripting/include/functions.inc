/**
 * Returns a player's Credits count.
 *
 * @param id		Player index.
 * @return		Number of credits owned.
 */
native get_user_coins(id)

/**
 * Sets a player's Credits count.
 *
 * @param id		Player index.
 * @param amount	Number of credits added.
 */
native set_user_coins(id, amount)

/**
 * Activate all plugins.
 *
 * @return		True if it is, false otherwise.
 */
native get_active()

/**
 * Returns a player's XP count.
 *
 * @param id		Player index.
 * @return		Number of XP owned.
 */
native get_user_xp(id)

/**
 * Sets a player's XP count.
 *
 * @param id		Player index.
 * @param amount	Number of XP added.
 */
native set_user_xp(id, amount)

/**
 * Returns whether a player is stunned.
 *
 * @param id		Player index.
 * @return		True if it is, false otherwise.
 */
native get_user_stunned(id)

/**
 * Returns a player's Total Power count.
 *
 * @param id		Player index.
 * @return		Number of coins owned.
 */
native get_user_tpower(id)
native get_user_donater(id)

/**
 * Returns a player's Points count.
 *
 * @param id		Player index.
 * @return		Number of points owned.
 */
native get_user_points(id)
/**
 * Sets a player's Points count.
 *
 * @param id		Player index.
 * @param amount	Number of points added.
 */
native set_user_points(id, amount)

/**
 * SaveCoins player.
 *
 * @param id		Player index.
 */
native SaveXP(id)

/**
 * SaveCoins player.
 *
 * @param id		Player index.
 */
native SavePoints(id)

/**
 * Returns a player's level count.
 *
 * @param id		Player index.
 * @return		Number of level owned.
 */
native get_user_level(id)
