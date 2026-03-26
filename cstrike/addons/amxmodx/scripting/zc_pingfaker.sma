#include <amxmodx>
#include <fakemeta>

new g_iCvarPing, g_iCvarFlux;
new g_iPing, g_iFlux;
new g_iMaxPlayers;
new g_iOffset[33][2]
new g_iArgumentPing[33][3];
new g_iPingOverride[33] = { -1, ... };

public plugin_init()
{
	register_plugin("[ZC Ping Faker]", "1.0", "meNe");
	register_forward(FM_UpdateClientData, "fw_UpdateClientData");
	g_iCvarPing = register_cvar("pingfake_ping", "19");
	g_iCvarFlux = register_cvar("pingfake_flux", "5");
	g_iMaxPlayers = get_maxplayers();
}

public plugin_cfg()
{
	set_task(0.5, "ReadCommandVars", 3426422);
}

public ReadCommandVars()
{
	g_iPing = clamp(get_pcvar_num(g_iCvarPing), 0, 4095);
	g_iFlux = clamp(get_pcvar_num(g_iCvarFlux), 0, 4095);
	set_task(2.0, "calculate_arguments", 4235621, _, _, "b");
}

public client_disconnect(id)
{
	g_iPingOverride[id] = -1;
}

public fw_UpdateClientData(id)
{
	if(!(pev(id, pev_button) & IN_SCORE) && !(pev(id, pev_oldbuttons) & IN_SCORE))
		return;
	
	static player, sending;
	sending = 0;
	
	for(player = 1; player <= g_iMaxPlayers; player++)
	{
		if(!is_user_connected(player))
			 continue;
		
		switch(sending)
		{
			case 0:
			{
				message_begin(MSG_ONE_UNRELIABLE, SVC_PINGS, _, id);
				write_byte((g_iOffset[player][0] * 64) + (1 + 2 * (player - 1)));
				write_short(g_iArgumentPing[player][0]);
				sending++;
			}
			
			case 1:
			{
				write_byte((g_iOffset[player][1] * 128) + (2 + 4 * (player - 1)));
				write_short(g_iArgumentPing[player][1]);
				sending++;
			}
			
			case 2:
			{
				write_byte((4 + 8 * (player - 1)));
				write_short(g_iArgumentPing[player][2]);
				write_byte(0);
				message_end();
				sending = 0;
			}
		}
	}
	
	if (sending)
	{
		write_byte(0);
		message_end();
	}
}

public calculate_arguments()
{
	static player, ping;
	
	for(player = 1; player <= g_iMaxPlayers; player++)
	{
		if(g_iPingOverride[player] < 0)
			ping = clamp(g_iPing + random_num(-g_iFlux, g_iFlux), 0, 4095);
		
		else
			ping = g_iPingOverride[player];
		
		for(g_iOffset[player][0] = 0; g_iOffset[player][0] < 4; g_iOffset[player][0]++)
		{
			if((ping - g_iOffset[player][0]) % 4 == 0)
			{
				g_iArgumentPing[player][0] = (ping - g_iOffset[player][0]) / 4;
				break;
			}
		}
		
		for (g_iOffset[player][1] = 0; g_iOffset[player][1] < 2; g_iOffset[player][1]++)
		{
			if((ping - g_iOffset[player][1]) % 2 == 0)
			{
				g_iArgumentPing[player][1] = (ping - g_iOffset[player][1]) / 2;
				break;
			}
		}
		
		g_iArgumentPing[player][2] = ping;
	}
}