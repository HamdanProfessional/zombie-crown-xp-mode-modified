#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <cstrike>
#include <hamsandwich>
#include <zombiecrown>
#include <fun>

#define HP_AMOUNT 1500
#define ARMOR_AMOUNT 500

new g_iChosenOne;

public plugin_init() {
    register_plugin("ZP LEGEND", "1.1", "n00bi2763");
    register_event("HLTV", "new_round", "a", "1=0", "2=0");
    RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage");
    register_forward(FM_CmdStart, "fw_CmdStart");
}

public new_round() {
    g_iChosenOne = get_random_player();
    if (g_iChosenOne != -1) {
        new playerName[32];
        get_user_name(g_iChosenOne, playerName, sizeof(playerName));
        client_print(0, print_chat, "[ZC] %s is the chosen one this round!", playerName);

        // Give the player an AK47 immediately.
        server_cmd("amx_giveak47 %d", g_iChosenOne);

        // Schedule a task to give health and armor after 5 seconds.
        set_task(5.0, "DelayedGive", g_iChosenOne);
    }
}

public get_random_player() {
    new players[32], count;
    get_players(players, count, "a");
    if (count > 0) {
        return players[random(count)];
    }
    return -1;
}

// This callback is executed 5 seconds after new_round() for the chosen player.
public DelayedGive(id) {
    if (is_user_connected(id)) {
        set_user_health(id, HP_AMOUNT);
        set_user_armor(id, ARMOR_AMOUNT);
    }
}
