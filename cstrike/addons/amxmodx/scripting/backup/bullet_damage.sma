#define PLUGIN "Bullet Damage + Combo System"
#define AUTHOR "n00bi2763"
#define VERSION "1.3"

#include <amxmodx>
#include <fakemeta>
#include <time>
#include <zombiecrown>

#define MAX_PLAYERS    32
#define COMBO_TIME_LIMIT  2.5     // Combo expires if no hit occurs within 2.5 seconds
#define DAMAGE_THRESHOLD  100.0    // Every 100 points of combo damage = +1 ammo pack

// Rotating positions for per-hit damage (blue)
new const Float:g_flCoords[][] = 
{
    {0.50, 0.40}, {0.56, 0.44}, {0.60, 0.50}, {0.56, 0.56},
    {0.50, 0.60}, {0.44, 0.56}, {0.40, 0.50}, {0.44, 0.44}
};

new g_iPlayerPos[MAX_PLAYERS+1];
new Float:g_fPlayerComboDamage[MAX_PLAYERS+1];
new Float:g_fLastHitTime[MAX_PLAYERS+1];
new g_iPendingAmmo[MAX_PLAYERS+1];  // Ammo packs to be given at end of combo

// NEW: Hit counter for the current combo
new g_iHitCount[MAX_PLAYERS+1];

new g_iMaxPlayers;
new g_pCvarEnabled;
new g_Msg_Combo; // Fixed HUD for total combo damage (dynamic color)
new g_Msg_Hit;   // Rotating HUD for per-hit damage (blue)
new g_Msg_Hits;  // Fixed HUD for hit count (white)

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    g_pCvarEnabled = register_cvar("bullet_damage", "1");

    register_event("Damage", "Event_Damage", "b", "2>0", "3=0");

    g_iMaxPlayers = get_maxplayers();

    g_Msg_Combo = CreateHudSyncObj(); // For combo damage
    g_Msg_Hit   = CreateHudSyncObj(); // For per-hit damage
    g_Msg_Hits  = CreateHudSyncObj(); // For hit count

    // Start a repeating task to check for combo timeouts
    set_task(1.0, "CheckComboTimeouts", _, _, _, "b");
}

//---------------------------------------------------------------
// Checks for players whose combos expired and awards ammo packs
//---------------------------------------------------------------
public CheckComboTimeouts()
{
    new Float:currentTime = get_gametime();

    for (new id = 1; id <= g_iMaxPlayers; id++)
    {
        if (is_user_connected(id) && g_fPlayerComboDamage[id] > 0.0)
        {
            if (currentTime - g_fLastHitTime[id] > COMBO_TIME_LIMIT)
            {
                // Combo expired; award ammo packs and reset combo data (including hit count)
                GiveAmmoPacks(id);
            }
        }
    }
}

//---------------------------------------------------------------
// Event: Player Deals Damage
//---------------------------------------------------------------
public Event_Damage(iVictim)
{
    // Check if the plugin is enabled and if the damage was of the desired type
    if (get_pcvar_num(g_pCvarEnabled) && (read_data(4) || read_data(5) || read_data(6)))
    {
        new id = get_user_attacker(iVictim);
        if ((1 <= id && id <= g_iMaxPlayers) && is_user_connected(id))
        {
            new damage = read_data(2); // Damage dealt
            new Float:currentTime = get_gametime();

            // If too long since the last hit, end the previous combo first
            if (currentTime - g_fLastHitTime[id] > COMBO_TIME_LIMIT)
            {
                if (g_fPlayerComboDamage[id] > 0.0)
                {
                    GiveAmmoPacks(id);
                }
                // Start a new combo
                g_fPlayerComboDamage[id] = float(damage);
                g_iHitCount[id] = 1;  // NEW: First hit of the new combo
            }
            else
            {
                g_fPlayerComboDamage[id] += float(damage);
                g_iHitCount[id]++;  // NEW: Increment hit count for the current combo
            }
            g_fLastHitTime[id] = currentTime;

            // Calculate pending ammo packs (but do not award them yet)
            g_iPendingAmmo[id] = floatround(g_fPlayerComboDamage[id] / DAMAGE_THRESHOLD, floatround_floor);

            // Determine dynamic HUD color based on total combo damage
            new r, g, b;
            if (g_fPlayerComboDamage[id] < 1000.0)
            {
                r = 0; g = 0; b = 255;  // Blue for 0–1000 damage
            }
            else if (g_fPlayerComboDamage[id] < 5000.0)
            {
                r = 0; g = 255; b = 0;    // Green for 1000–5000 damage
            }
            else if (g_fPlayerComboDamage[id] < 15000.0)
            {
                r = 255; g = 255; b = 0;  // Yellow for 5000–15000 damage
            }
            else
            {
                r = 255; g = 0; b = 0;    // Red for 15000+ damage
            }

            // --- Display Fixed HUD Messages (centered) ---

            // 1. Hit count (displayed at y=0.65)
            set_hudmessage(r, g, b, 0.5, 0.65, 0, 0.5, 1.0, 0.02, 0.02, -1);
            ShowSyncHudMsg(id, g_Msg_Hits, "Total Hits: %d", g_iHitCount[id]);

            // 2. Total combo damage with dynamic color at y=0.67
            set_hudmessage(r, g, b, 0.5, 0.67, 0, 0.5, 1.0, 0.02, 0.02, -1);
            ShowSyncHudMsg(id, g_Msg_Combo, "Total Damage: %.1f DMG", g_fPlayerComboDamage[id]);

            // --- Display Per-Hit Damage (rotating blue HUD, unchanged) ---
            new iPos = ++g_iPlayerPos[id];
            if (iPos == sizeof(g_flCoords))
            {
                iPos = g_iPlayerPos[id] = 0;
            }
            set_hudmessage(0, 0, 255, g_flCoords[iPos][0], g_flCoords[iPos][1], 0, 0.1, 0.5, 0.02, 0.02, -1);
            ShowSyncHudMsg(id, g_Msg_Hit, "%d", damage);

            // Print Debug Info to Console
            client_print(id, print_console, "[Bullet Combo] Hits: %d | Total Combo: %.1f | Hit Damage: %d | Pending Ammo: %d",
                         g_iHitCount[id], g_fPlayerComboDamage[id], damage, g_iPendingAmmo[id]);
        }
    }
}

//---------------------------------------------------------------
// Function: Give Ammo Packs (After Combo Ends)
//---------------------------------------------------------------
public GiveAmmoPacks(id)
{
    if (!is_user_connected(id) || g_fPlayerComboDamage[id] <= 0.0)
        return;

    new currentPacks = zp_get_user_ammo_packs(id);
    zp_set_user_ammo_packs(id, currentPacks + g_iPendingAmmo[id]);

    // Determine dynamic HUD color for the final combo message (same thresholds)
    new r, g, b;
    if (g_fPlayerComboDamage[id] < 1000.0)
    {
        r = 0; g = 0; b = 255;
    }
    else if (g_fPlayerComboDamage[id] < 5000.0)
    {
        r = 0; g = 255; b = 0;
    }
    else if (g_fPlayerComboDamage[id] < 15000.0)
    {
        r = 255; g = 255; b = 0;
    }
    else
    {
        r = 255; g = 0; b = 0;
    }

    // Display Final Combo and Ammo Reward (bottom center)
    set_hudmessage(r, g, b, 0.5, 0.75, 0, 6.0, 1.5, 0.02, 0.02, -1);
    ShowSyncHudMsg(id, g_Msg_Combo, "Total Damage: %.1f DMG | +%d Ammo Packs", g_fPlayerComboDamage[id], g_iPendingAmmo[id]);

    // Print Debug Info to Console
    client_print(id, print_console, "[Bullet Combo] Combo Finished: %.1f Damage | Ammo Rewarded: %d | Total Ammo: %d",
                 g_fPlayerComboDamage[id], g_iPendingAmmo[id], zp_get_user_ammo_packs(id));

    // --- Send private chat message with combo summary ---
    // (Store final values before resetting combo data)
    new finalHits = g_iHitCount[id];
    new Float:finalDamage = g_fPlayerComboDamage[id];
    new finalReward = g_iPendingAmmo[id];

    client_print(id, print_chat, "[ZC] Your Combo Ended, Total Hits: %d, Total Damage: %.1f DMG, Total Reward: %d", finalHits, finalDamage, finalReward);

    // Reset combo data including hit count
    g_fPlayerComboDamage[id] = 0.0;
    g_iPendingAmmo[id] = 0;
    g_iHitCount[id] = 0;
}

//---------------------------------------------------------------
// Event: Player Spawns (Reset Combo Data)
//---------------------------------------------------------------
public event_player_spawn()
{
    new client = read_data(1);

    if (is_user_connected(client))
    {
        g_fPlayerComboDamage[client] = 0.0;
        g_fLastHitTime[client] = 0.0;
        g_iPendingAmmo[client] = 0;
        g_iHitCount[client] = 0;
    }
}
