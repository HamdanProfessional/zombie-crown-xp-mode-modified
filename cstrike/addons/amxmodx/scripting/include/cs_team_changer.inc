/*
	CS Team Changer Functions
	
	by Hattrick @ www.CsRedDevil.com
	
	For Counter-Strike and Counter-Strike: Condition Zero
*/

#if defined _cs_team_changer_included
	#endinput
#endif // _cs_team_changer_included

#define _cs_team_changer_included

#include "svn_version.inc"

#if AMXX_VERSION_NUM >= 175
	#pragma reqlib cs_team_changer
	
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib cs_team_changer
	#endif
#else
	#pragma library cs_team_changer
#endif // AMXX_VERSION_NUM

/*
	The teams you can use:
*/
enum
{
	TEAM_UNASSIGNED = 0,
	TEAM_TERRORIST,		// This will be defined as 1
	TEAM_CT,		// This will be defined as 2
	TEAM_SPECTATOR		// This will be defined as 3
};

/*
	You can make like 60 transfers in one second with this extension! This server won't crash!
	The CStrike module with the cs_set_user_team native will crash the server at like 25 transfers in one second!
*/

/*
	Completly change the team at a player! The player's model won't be updated for avoid lagging!
	
	@param	_index		The player's index ( INT )
	@param	_team		The player's team ( INT )
	
	Example:	cs_set_team( id, 2 );
		cs_set_team( id, TEAM_CT );
*/
native cs_set_team( _index, _team );

/*
	Update the AMXX API team's ID at a player!
	
	@param	_index		The player's index ( INT )
	@param	_team		The player's team ( INT )
	
	Example:	cs_set_team_id( id, 2 );
		cs_set_team_id( id, TEAM_CT );
*/
native cs_set_team_id( _index, _team );

/*
	Change the team's offset at a player. This won't update the tablescore or something else...
	It is like set_pdata_int!
	
	@param	_index		The player's index ( INT )
	@param	_team		The player's team ( INT )
	
	Example:	cs_set_team_offset( id, 2 );
		cs_set_team_offset( id, TEAM_CT );
*/
native cs_set_team_offset( _index, _team );

/*
	This will send a fast TeamInfo message from the engine!
	It will update the tablescore at all players with the player you want to move from a team to another team!
	This will just update the tablescore... If the player was a terrorist, it will be also a terrorist...
	
	@param	_index		The player's index ( INT )
	@param	_team		The player's team ( INT )
	
	Example:	cs_set_team_tablescore( id, 2 );
		cs_set_team_tablescore( id, TEAM_CT );
*/
native cs_set_team_tablescore( _index, _team );
