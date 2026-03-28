#include <amxmodx>

#define PLUGIN "[ZC] Full Brightness"
#define VERSION "1.0"
#define AUTHOR "Zombie Crown Team"

new cvar_enabled
new cvar_brightness_level

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	cvar_enabled = register_cvar("zc_fullbright_enabled", "1")
	cvar_brightness_level = register_cvar("zc_fullbright_level", "100")

	register_logevent("Event_RoundStart", 2, "1=Round_Start")
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")

	set_task(10.0, "Apply_Lighting", _, _, _, "b")
}

public plugin_cfg()
{
	set_task(1.0, "Apply_Lighting")
}

public Event_NewRound()
{
	set_task(0.5, "Apply_Lighting")
}

public Event_RoundStart()
{
	Apply_Lighting()
}

public Apply_Lighting()
{
	if(!get_pcvar_num(cvar_enabled))
		return

	new brightness = get_pcvar_num(cvar_brightness_level)

	// Clamp brightness
	if(brightness < 0) brightness = 0
	if(brightness > 255) brightness = 255

	// Calculate light level (a-z)
	new level = 'a' + floatround((brightness / 255.0) * 25.0)
	if(level > 'z') level = 'z'
	if(level < 'a') level = 'a'

	// Create lights string (26 characters of same brightness)
	new lights[27]
	for(new i = 0; i < 26; i++)
	{
		lights[i] = level
	}
	lights[26] = 0

	// Set map lighting
	server_cmd("set_lights %s", lights)

	// Force all clients to update lighting
	new players[32], num
	get_players(players, num)

	for(new i = 0; i < num; i++)
	{
		// Update light style
		message_begin(MSG_ONE, SVC_LIGHTSTYLE, _, players[i])
		write_byte(0)
		write_string(lights)
		message_end()

		// Also update all light styles
		for(new j = 1; j < 4; j++)
		{
			message_begin(MSG_ONE, SVC_LIGHTSTYLE, _, players[i])
			write_byte(j)
			write_string(lights)
			message_end()
		}
	}

	// Log
	log_amx("[ZC FullBright] Set lighting to level %d (%s)", brightness, lights)
}
